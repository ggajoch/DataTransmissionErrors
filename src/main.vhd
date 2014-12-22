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
		switchesRaw : in std_logic_vector(15 downto 0);
		LED : out std_logic_vector(15 downto 0);
		
		
		out_clock : out std_logic;
		uart_out : out std_logic;
		
		usart_out_clock : out std_logic;
		usart_out_data : out std_logic;
		usart_in_clock : in std_logic;
		usart_in_data : in std_logic;
		
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

begin
	
--------------- TRANSMITTER -----------------------------------
	
	Tx_inst : entity work.Tx_MAIN
		port map(digits       => digits,
			     segments     => segments,
			     buttonMiddle => buttonMiddle,
			     buttonLeft   => buttonLeft,
			     buttonRight  => buttonRight,
			     buttonUp     => buttonUp,
			     buttonDown   => buttonDown,
			     switchesRaw  => switchesRaw,
			     LED          => LED,
			     clock_100MHz => clock_100MHz,
			     clock_1MHz   => clock_1MHz,
			     clock_1kHz   => clock_1kHz,
			     clock_10Hz   => clock_10Hz,
			     clock_1Hz    => clock_1Hz,
			     output_data  => usart_out_data,
			     output_clock => usart_out_clock,
			     output3      => out_clock);
	
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

