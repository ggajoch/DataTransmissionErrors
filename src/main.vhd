library ieee;
use ieee.std_logic_1164.all;

entity main is
	port (
		digits : out std_logic_vector(7 downto 0);
		segments : out std_logic_vector(7 downto 0);
		buttonMiddle : in std_logic;
		buttonLeft : in std_logic;
		buttonRight : in std_logic;
		buttonUp : in std_logic;
		buttonDown : in std_logic;
		switches : in std_logic_vector(7 downto 0);
		LED : in std_logic_vector(7 downto 0);
		clock_100MHz : in std_logic
	);
end entity main;

architecture RTL of main is
signal clock_1MHz : std_logic;
signal clock_1kHz : std_logic;
signal clock_1Hz : std_logic;
signal actual_string : string(8 downto 1) := "12345678";
signal actual_dots : std_logic_vector(8 downto 1) := "00000000";
signal changing_nr : integer range 0 to 7 := 0;

signal buttonMiddleDebounced : std_logic;
signal buttonLeftDebounced : std_logic;
signal buttonRightDebounced : std_logic;
signal buttonUpDebounced : std_logic;
signal buttonDownDebounced : std_logic;

signal one:std_logic_vector(6 downto 0) := "0000000";

begin
	
	actual_dots <= to_stdlogicvector(to_bitvector(one & clock_1Hz) sll changing_nr);
	
	
	process(clock_1kHz) is
		variable last_Left : std_logic := '0';
		variable last_Right : std_logic := '0';
		variable last_Up : std_logic := '0';
		variable last_Down : std_logic := '0';
	begin
		if( rising_edge(clock_1kHz) ) then
			if( last_Left = '1' and buttonLeftDebounced = '0') then
				if( changing_nr < 7 ) then
					changing_nr <= changing_nr+1;
				end if;
			end if;
			
			if( last_Right = '1' and buttonRightDebounced = '0') then
				if( changing_nr > 0 ) then
					changing_nr <= changing_nr-1;
				end if;
			end if;
			
			if( last_Up = '1' and buttonUpDebounced = '0') then
                actual_string(changing_nr+1) <= character'val(character'pos(actual_string(changing_nr+1)) + 1);
            end if;
			
			if( last_Down = '1' and buttonDownDebounced = '0') then
                actual_string(changing_nr+1) <= character'val(character'pos(actual_string(changing_nr+1)) - 1);
            end if;
                        
			last_Left := buttonLeftDebounced;
			last_Right := buttonRightDebounced;
			last_Up := buttonUpDebounced;
			last_Down := buttonDownDebounced;
		end if;
	end process ;
	
	SevenSegControl_inst : entity work.SevenSegControl
		port map(input => actual_string,
				 input_dots => actual_dots,
			     digits => digits,
			     segments => segments,
			     segment_change_clock => clock_1kHz);
			     
	debouncerButtonMiddle : entity work.debouncer
		generic map(TicksBetweenEdges => 10)
		port map(input  => buttonMiddle,
			     output => buttonMiddleDebounced,
			     clock  => clock_1kHz);
	debouncerButtonLeft : entity work.debouncer
		generic map(TicksBetweenEdges => 10)
		port map(input  => buttonLeft,
			     output => buttonLeftDebounced,
			     clock  => clock_1kHz);
	
	debouncerButtonRight : entity work.debouncer
		generic map(TicksBetweenEdges => 10)
		port map(input  => buttonRight,
			     output => buttonRightDebounced,
			     clock  => clock_1kHz);
	
	debouncerUpRight : entity work.debouncer
         generic map(TicksBetweenEdges => 10)
         port map(input  => buttonUp,
                  output => buttonUpDebounced,
                  clock  => clock_1kHz);
                  
	debouncerDownRight : entity work.debouncer
          generic map(TicksBetweenEdges => 10)
          port map(input  => buttonDown,
                   output => buttonDownDebounced,
                   clock  => clock_1kHz);
                   
    prescaler1M : entity work.prescaler
        port map(clk_input => clock_100MHz,
                 clk_output => clock_1MHz,
                 reset => '0',
                 presc => 100);
    prescaler1k : entity work.prescaler
         port map(clk_input => clock_1MHz,
                  clk_output => clock_1kHz,
                  reset => '0',
                  presc => 1000);
    prescaler1 : entity work.prescaler
           port map(clk_input => clock_1kHz,
                    clk_output => clock_1Hz,
                    reset => '0',
                    presc => 1000);

end architecture RTL;