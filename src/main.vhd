library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is
	port (
		digits : out std_logic_vector(7 downto 0);
		segments : out std_logic_vector(7 downto 0);
		buttonMiddleRaw : in std_logic;
		buttonLeftRaw : in std_logic;
		buttonRightRaw : in std_logic;
		buttonUpRaw : in std_logic;
		buttonDownRaw : in std_logic;
		switchesRaw : in std_logic_vector(7 downto 0);
		LED : out std_logic_vector(7 downto 0);
		out_clock : out std_logic;
		uart_out : out std_logic;
		clock_100MHz : in std_logic
	);
end entity main;

architecture RTL of main is
signal clock_1MHz : std_logic;
signal clock_1kHz : std_logic;
signal clock_10Hz : std_logic;
signal clock_1Hz : std_logic;

signal buttonMiddle : std_logic;
signal buttonLeft : std_logic;
signal buttonRight : std_logic;
signal buttonUp : std_logic;
signal buttonDown : std_logic;

signal prescaler_value : integer range 0 to 10**8 := 1;
signal clock_prescaled : std_logic;

signal uart_data : std_logic_vector(7 downto 0) := "00000000";
signal uart_TC : std_logic := '0';

signal actual_string : string(8 downto 1);
signal actual_dots : std_logic_vector(8 downto 1);

signal protocol_sel : integer range 0 to 99;
signal speed_integer : integer range 0 to 99;
signal speed_exponent : integer range 0 to 9;

begin
	
	display_inst : entity work.displayController
		port map(buttonMiddle                => buttonMiddle,
			     buttonLeft                  => buttonLeft,
			     buttonRight                 => buttonRight,
			     buttonUp                    => buttonUp,
			     buttonDown                  => buttonDown,
			     clock_dot                   => clock_10Hz,
			     clock_keyboard              => clock_1kHz,
			     protocol_sel_out            => protocol_sel,
			     sci_controller_integer_out  => speed_integer,
			     sci_controller_exponent_out => speed_exponent,
			     display_string 			 => actual_string,
			     display_dots				 => actual_dots);
	
	out_clock <= clock_prescaled;
--	prescalerTestControlled : entity work.prescaler
--       port map(clk_input => clock_100MHz,
--                clk_output => clock_prescaled,
--                reset => '0',
--                presc => prescaler_value);



	SevenSegControl_inst : entity work.SevenSegControl
		port map(input => actual_string,
				 input_dots => actual_dots,
			     digits => digits,
			     segments => segments,
			     segment_change_clock => clock_1kHz);

	--------------- CLOCK GENERATION ------------------------


	clock_gen_inst : entity work.clockController
		port map(speed_integer => speed_integer,
			     speed_exp     => speed_exponent,
			     clock_100MHz  => clock_100MHz,
			     clock_out     => clock_prescaled,
			     reset_presc   => '0');


	--------------- UART ------------------------------------

	uart_inst : entity work.UART_Tx	
		port map(TxPin    => uart_out,
			     TxClock  => clock_prescaled,
			     Data     => uart_data,
			     DataFlag => clock_10Hz,
			     TC       => uart_TC);

	uart_proc : process(clock_10Hz) is
	begin
		if( rising_edge(clock_10Hz) ) then
			uart_data <= std_logic_vector(unsigned(uart_data)+1);
		end if;
	end process uart_proc;
		
--------------- DEBOUNCING ------------------------------------
			     
	debouncerButtonMiddle : entity work.debouncer
		generic map(TicksBetweenEdges => 10)
		port map(input  => buttonMiddleRaw,
			     output => buttonMiddle,
			     clock  => clock_1kHz);
	debouncerButtonLeft : entity work.debouncer
		generic map(TicksBetweenEdges => 10)
		port map(input  => buttonLeftRaw,
			     output => buttonLeft,
			     clock  => clock_1kHz);
	
	debouncerButtonRight : entity work.debouncer
		generic map(TicksBetweenEdges => 10)
		port map(input  => buttonRightRaw,
			     output => buttonRight,
			     clock  => clock_1kHz);
	
	debouncerUpRight : entity work.debouncer
         generic map(TicksBetweenEdges => 10)
         port map(input  => buttonUpRaw,
                  output => buttonUp,
                  clock  => clock_1kHz);
                  
	debouncerDownRight : entity work.debouncer
          generic map(TicksBetweenEdges => 10)
          port map(input  => buttonDownRaw,
                   output => buttonDown,
                   clock  => clock_1kHz);

--------------- PRESCALERS ------------------------------------
                   
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