-- generation of commands to be written to PLL to set clock
-- ref: http://www.xilinx.com/support/documentation/ip_documentation/clk_wiz/v5_1/pg065-clk-wiz.pdf

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PLLValues is
	port (
		DIVCLK_DIVIDE : integer range 0 to 255;
		CLKFBOUT_MULT : integer range 0 to 255;
		CLKFBOUT_FRAC : integer range 0 to 1023;
		CLKFBOUT_FRAC_EN : std_logic;
		
		data_valid : std_logic;
		
		response : out std_logic_vector(1 downto 0);
		done : out std_logic;
		clock_100MHz : in std_logic;
		

		PLL_clock_out : out std_logic;
		PLL_locked : out std_logic
	);
end entity PLLValues;

architecture RTL of PLLValues is
	signal C_BASEADDR : std_logic_vector(10 downto 0) := "00000000000";
		
	signal clock_output : std_logic;
	signal locked : std_logic;
	signal write_address : std_logic_vector(10 downto 0);
	signal write_data : std_logic_vector(31 downto 0);
	signal write_valid : std_logic;
	signal axi4_write_response : std_logic_vector(1 downto 0); -- 00 - OK
	signal commmand_done : std_logic;
	
	type FSMStates_t is (Idle, Valid1, Valid2, Write, WaitTicks, WaitF);
	
begin
	
	PLL_clock_out <= clock_output;
	PLL_locked <= locked;
	axi4masterPLL_inst : entity work.axi4masterPLL
		port map(clock_100MHz        => clock_100MHz,
			     clock_output        => clock_output,
			     locked              => locked,
			     write_address       => write_address,
			     write_data          => write_data,
			     write_valid         => write_valid,
			     axi4_write_response => axi4_write_response,
			     commmand_done       => commmand_done);
	
	mainProc : process(clock_100MHz) is
		variable State : FSMStates_t := Idle;
		variable NextState : FSMStates_t := Idle;
		variable last_data_valid : std_logic := '0';
		variable ticks_left : integer := 0;
		variable address_Reg0 : std_logic_vector(10 downto 0) := "01000000000"; --0x200
		variable address_Reg23 : std_logic_vector(10 downto 0) := "01001011100"; --0x25C
	begin
		if( rising_edge(clock_100MHz) ) then
			case State is 
				when Idle =>
					write_valid <= '0';
					response <= "00";
					done <= '1';
				
					if( last_data_valid = '0' and data_valid = '1' ) then
						State := Write;
						NextState := Valid1;
						
						write_address <= std_logic_vector(unsigned(C_BASEADDR) + unsigned(address_Reg0));
						write_data <= "00000" & CLKFBOUT_FRAC_EN & 
									  std_logic_vector(to_unsigned(CLKFBOUT_FRAC, 10)) & 
									  std_logic_vector(to_unsigned(CLKFBOUT_MULT, 8)) & 
									  std_logic_vector(to_unsigned(DIVCLK_DIVIDE, 8));
					end if;
				
				when Valid1 =>
					write_address <= std_logic_vector(unsigned(C_BASEADDR) + unsigned(address_Reg23));
					write_data <= "00000000000000000000000000000111";
					State := Write;
					NextState := Valid2;
				when Valid2 =>
					write_address <= std_logic_vector(unsigned(C_BASEADDR) + unsigned(address_Reg23));
					write_data <= "00000000000000000000000000000010";
					State := Write;
					NextState := Valid2;
					
				when Write =>
					write_valid <= '1';
					ticks_left := 10;
					NextState := WaitF;
					State := WaitTicks;
				when WaitTicks =>
					if( ticks_left > 0 ) then
						ticks_left := ticks_left-1;
					else
						State := NextState;
					end if;
				when WaitF =>
					write_valid <= '0';
					if( commmand_done = '1' ) then
						response <= axi4_write_response;
						State := NextState;
					end if;
			end case;
			
			last_data_valid := data_valid;
		end if;
	end process mainProc;
	
end architecture RTL;
