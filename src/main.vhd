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
		out_clock : out std_logic;
		clock_100MHz : in std_logic
	);
end entity main;

architecture RTL of main is
signal clock_1MHz : std_logic;
signal clock_1kHz : std_logic;
signal clock_10Hz : std_logic;
signal clock_1Hz : std_logic;
signal actual_string : string(8 downto 1) := "12345678";
signal actual_dots : std_logic_vector(8 downto 1) := "00000000";
signal changing_nr : integer range 0 to 7 := 0;

signal buttonMiddleDebounced : std_logic;
signal buttonLeftDebounced : std_logic;
signal buttonRightDebounced : std_logic;
signal buttonUpDebounced : std_logic;
signal buttonDownDebounced : std_logic;

signal prescaler_value : integer range 0 to 10**8 := 1;
begin
	
	numController_inst : entity work.numberController
		generic map(nr_of_digits => 8)
		port map(displayString  => actual_string,
			     displayDots    => actual_dots,
			     integer_value  => prescaler_value,
			     buttonLeft     => buttonLeftDebounced,
			     buttonRight    => buttonRightDebounced,
			     buttonUp       => buttonUpDebounced,
			     buttonDown     => buttonDownDebounced,
			     keyboard_clock => clock_1kHz,
			     dot_clock      => clock_10Hz);

	prescalerTestControlled : entity work.prescaler
       port map(clk_input => clock_100MHz,
                clk_output => out_clock,
                reset => '0',
                presc => prescaler_value);

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
	prescaler10 : entity work.prescaler
           port map(clk_input => clock_1kHz,
                    clk_output => clock_10Hz,
                    reset => '0',
                    presc => 100);
    prescaler1 : entity work.prescaler
           port map(clk_input => clock_1kHz,
                    clk_output => clock_1Hz,
                    reset => '0',
                    presc => 1000);

end architecture RTL;