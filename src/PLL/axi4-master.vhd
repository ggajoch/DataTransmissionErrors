-- basic implementation of AXI4-Lite master module
-- ref: http://www.xilinx.com/support/documentation/ip_documentation/clk_wiz/v5_1/pg065-clk-wiz.pdf

library ieee;
use ieee.std_logic_1164.all;

entity axi4masterPLL is
	port (
		clock_100MHz : in std_logic;
		clock_output : out std_logic;
		locked : out std_logic;
		write_address : in std_logic_vector(10 downto 0);
		write_data : in std_logic_vector(31 downto 0);
		write_valid : in std_logic;
		axi4_write_response : out std_logic_vector(1 downto 0); -- 00 - OK
		commmand_done : out std_logic
	);
end entity axi4masterPLL;

architecture RTL of axi4masterPLL is
	------------------------------------------------
	---------- AXI4-LITE SIGNALS -------------------
	------------------------------------------------
	
	signal s_axi_aclk : std_logic := '0';
	signal s_axis_aclk : std_logic := '0';
	signal s_axi_aresetn : std_logic := '0';
	-------------------- WRITE ---------------------
	signal s_axi_awaddr : std_logic_vector(10 downto 0) := (others => '0'); -- address to be written
	signal s_axi_awvalid : std_logic := '0'; -- valid address
	signal s_axi_awready : std_logic := '0'; -- IN address ready to be written
	signal s_axi_wdata : std_logic_vector(31 downto 0) := (others => '0'); -- data to be written
	signal s_axi_wstb : std_logic_vector(3 downto 0) := (others => '0'); -- strobes for bytes
	signal s_axi_wvalid : std_logic := '0'; -- valid data
	signal s_axi_wready : std_logic := '0'; -- IN data ready to be written
	signal s_axi_bresp : std_logic_vector(1 downto 0) := (others => '0'); -- IN write response
	signal s_axi_bvalid : std_logic := '0'; -- IN valid response -> written!
	signal s_axi_bready : std_logic := '0'; -- ready to read response
	-------------------- READ ---------------------
	signal s_axi_araddr : std_logic_vector(10 downto 0) := (others => '0');
	signal s_axi_arvalid : std_logic := '0';
	signal s_axi_arready : std_logic := '0';
	signal s_axi_rdata : std_logic_vector(31 downto 0) := (others => '0');
	signal s_axi_rresp : std_logic_vector(1 downto 0) := (others => '0');
	signal s_axi_rvalid : std_logic := '0';
	signal s_axi_rready : std_logic := '0';
	
	------------------------------------------------
	-------------------- MISC ----------------------
	------------------------------------------------
	
	signal commmand_done_sig : std_logic := '0';
	type ProcessAXI4State_t is (Idle, addressWait, addressValid, dataWait, dataValid, waitResponse);
	
	signal State : ProcessAXI4State_t := Idle;
begin
	
	------------------------------------------------
	---------------- PLL INSTANCE ------------------
	------------------------------------------------
		
	s_axi_aclk <= clock_100MHz;
	s_axis_aclk <= clock_100MHz;
	s_axi_aresetn <= '1';
	
	------------------------------------------------
	---------------- MAIN PROCESS ------------------
	------------------------------------------------
	
	commmand_done <= commmand_done_sig;
	s_axi_wready <= '1';
	s_axi_awready <= '1';
	s_axi_bvalid <= '1';
	s_axi_bresp <= "01";
	
	mainProc : process(clock_100MHz) is
		variable last_write_valid : std_logic := '0';
		
	begin
		if( rising_edge(clock_100MHz) ) then
			commmand_done_sig <= '0';
			case State is 
				when Idle =>
					if( last_write_valid = '0' and write_valid = '1' ) then
						s_axi_awaddr <= write_address;
						s_axi_wdata <= write_data;
						s_axi_wstb <= "1111";
						State <= addressWait;
						
						s_axi_bready <= '0';
						s_axi_awvalid <= '0';
						s_axi_wvalid <= '0';
					else
						commmand_done_sig <= '1';
					end if;
				when addressWait =>
					if ( s_axi_awready = '1' ) then
						State <= addressValid;
					end if;
				when addressValid =>
					s_axi_awvalid <= '1';
					State <= dataWait;
				when dataWait =>
					if ( s_axi_wready = '1' ) then
						State <= dataValid;
					end if;
				when dataValid =>
					s_axi_awvalid <= '0';
					s_axi_wvalid <= '1';
					s_axi_bready <= '1';				
				when waitResponse =>
					if ( s_axi_bvalid = '1' ) then
						s_axi_wvalid <= '0';
						axi4_write_response <= s_axi_bresp;
						State <= Idle;
					end if;
			end case;
			
			last_write_valid := write_valid;
		end if;
	end process mainProc;
		
end architecture RTL;
