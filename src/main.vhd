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

signal prescaler_value : integer range 0 to 10**8 := 1;
signal clock_prescaled : std_logic;

signal uart_data : std_logic_vector(7 downto 0) := "00000000";
signal uart_TC : std_logic := '0';

signal actual_string : string(8 downto 1);
signal actual_dots : std_logic_vector(8 downto 1);

signal protocol_sel : integer range 0 to 99;
signal speed_integer : integer range 0 to 99;
signal speed_exponent : integer range 0 to 9;


signal usart_out : std_logic;
signal usart_out_clock_SIG : std_logic;
signal usart_TC : std_logic;
signal uart_prescaler_reset : std_logic;
signal clock_prescaled_TX : std_logic;

signal fast_TX : std_logic;
signal fast_RX : std_logic;
signal uart_trigger : std_logic;
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


	--------------- CLOCK GENERATION ------------------------

	usart_out_clock <= clock_prescaled_TX;
	
	clock_gen_TX_inst : entity work.clockController
		port map(speed_integer => speed_integer,
			     speed_exp     => speed_exponent,
			     clock_100MHz  => clock_100MHz,
			     clock_out     => clock_prescaled_TX,
			     reset_presc   => '0',
			     fast_clock    => fast_TX);

	clock_gen_RX_inst : entity work.clockController
		port map(speed_integer => speed_integer,
			     speed_exp     => speed_exponent,
			     clock_100MHz  => clock_100MHz,
			     clock_out     => clock_prescaled,
			     reset_presc   => uart_prescaler_reset,
			     fast_clock    => fast_RX);



	--------------- UART ------------------------------------

	uart_inst : entity work.UART_Tx	
		port map(TxPin    => uart_out,
			     TxClock  => clock_prescaled_TX,
			     Data     => switchesRaw(7 downto 0),--uart_data,
			     DataFlag => uart_trigger,
			     TC       => uart_TC);

	clock_trig : entity work.prescaler
		generic map(max_presc => 21)
		port map(clk_input  => clock_prescaled_TX,
			     clk_output => uart_trigger,
			     reset      => '0',
			     presc      => 20);
			     
	uart_recv : entity work.UART_Rx
		port map(RxPin                => usart_in_data,
			     fast_clock           => fast_TX,
			     sampling_clock       => clock_prescaled,
			     sampling_clock_reset => uart_prescaler_reset,
			     Data                 => LED(7 downto 0),
			     DataFlag             => LED(8),
			     TransmissionError    => LED(9));
	
	--------------- USART ------------------------------------
	
--	usartTX_inst : entity work.USART_Tx
--		port map(TxPin      => usart_out,
--			     TxSynchPin => usart_out_clock_SIG,
--			     TxClock    => clock_prescaled,
--			     Data       => uart_data,
--			     DataFlag   => clock_10Hz,
--			     TC         => usart_TC); 
--	
--	usart_out_clock <= usart_out_clock_SIG;
--	usart_out_data <= usart_out;
--	
--	
--	usartRX_inst : entity work.USART_Rx
--		port map(RxPin             => usart_in_data,
--			     RxSynchPin        => usart_in_clock,
--			     Data              => LED(7 downto 0),
--			     DataFlag          => LED(8),
--			     TransmissionError => LED(9));
		
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

