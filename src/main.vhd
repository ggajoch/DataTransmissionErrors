library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library UNISIM;
use UNISIM.vcomponents.all;

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
		
		diff_out_clock_p : out std_logic;
		diff_out_clock_n : out std_logic;
		diff_out_data_p : out std_logic;
		diff_out_data_n : out std_logic;
		diff_in_clock_p : in std_logic;
		diff_in_clock_n : in std_logic;
		diff_in_data_p : in std_logic;
		diff_in_data_n : in std_logic;
		
		clock_100MHz : in std_logic;
		
		JC : out std_logic_vector(8 downto 1)
	);
end entity main;
	
architecture RTL of main is
	signal rcv_data_out : std_logic;
	signal rcv_clock_out : std_logic;
	
	signal diff_out_clock : std_logic;
	signal diff_out_data : std_logic;
	signal diff_in_clock : std_logic;
	signal diff_in_data : std_logic;
	
	signal clock_1MHz : std_logic;
	signal clock_1kHz : std_logic;
	signal clock_10Hz : std_logic;
	signal clock_1Hz : std_logic;
	
	signal buttonMiddle : std_logic;
	signal buttonLeft : std_logic;
	signal buttonRight : std_logic;
	signal buttonUp : std_logic;
	signal buttonDown : std_logic;


    signal usart_in_data_signal : std_logic;
    signal usart_in_clock_signal : std_logic;

	signal receiver_out_debug : std_logic_vector(7 downto 0);

	type IO_to_device_t is record
		buttonMiddle : std_logic;
		buttonLeft : std_logic;
		buttonRight : std_logic;
		buttonUp : std_logic;
		buttonDown : std_logic;
		switchesRaw : std_logic_vector(15 downto 0);
		
		digits : std_logic_vector(7 downto 0);
		segments : std_logic_vector(7 downto 0);
		LED : std_logic_vector(15 downto 0);
	end record IO_to_device_t;

	signal IO_TX : IO_to_device_t;
	signal IO_RX : IO_to_device_t;
	
	signal control_pin : std_logic;
begin
	
	diff_out_data <= rcv_data_out;
	usart_out_data <= rcv_data_out;
	diff_out_clock <= rcv_clock_out;
	usart_out_clock <= rcv_clock_out;
	
	usart_in_data_signal <=  diff_in_data when switchesRaw(13) = '0' else
	                         usart_in_data;
	
	usart_in_clock_signal <=  diff_in_clock when switchesRaw(13) = '0' else
                             usart_in_clock;
		
---------------LVDS WORKAROUND ---------------------------
	diff_out_clock_p <= diff_out_clock;
	diff_out_clock_n <= not diff_out_clock;
	
	diff_out_data_p <= diff_out_data;
	diff_out_data_n <= not diff_out_data;

---------------LVDS INPUTS -------------------------------		
		
	IBUFDS_inst : IBUFDS
		port map (
			O => diff_in_clock,  -- Buffer output
			I => diff_in_clock_p,  -- Diff_p buffer input (connect directly to top-level port)
			IB => diff_in_clock_n -- Diff_n buffer input (connect directly to top-level port)
		);
	
	IBUFDS_inst2 : IBUFDS
		port map (
			O => diff_in_data,  -- Buffer output
			I => diff_in_data_p,  -- Diff_p buffer input (connect directly to top-level port)
			IB => diff_in_data_n -- Diff_n buffer input (connect directly to top-level port)
		);
	
	control_pin <= switchesRaw(15);
	
	LED(14 downto 8) <= receiver_out_debug(6 downto 0);
	
	JC(8 downto 1) <= receiver_out_debug(7 downto 0);
	LED(7 downto 0) <= IO_RX.LED(7 downto 0);
	IO_TX.switchesRaw <= switchesRaw;
	IO_RX.switchesRaw <= (others => '0');
	
	switching_control_process : process(control_pin, IO_RX, IO_TX, buttonDown, 
										buttonUp, buttonRight, buttonLeft, buttonMiddle) is
	begin
		if( control_pin = '1' ) then
			digits <= IO_TX.digits;
			segments <= IO_TX.segments;
			--LED <= IO_TX.LED;
			
			IO_TX.buttonDown <= buttonDown;
			IO_TX.buttonUp <= buttonUp;
			IO_TX.buttonRight <= buttonRight;
			IO_TX.buttonLeft <= buttonLeft;
			IO_TX.buttonMiddle <= buttonMiddle;
			--IO_TX.switchesRaw <= switchesRaw;
			
			IO_RX.buttonDown <= '0';
			IO_RX.buttonUp <= '0';
			IO_RX.buttonRight <= '0';
			IO_RX.buttonLeft <= '0';
			IO_RX.buttonMiddle <= '0';
--			IO_RX.switchesRaw <= (others => '0');
		else
			digits <= IO_RX.digits;
			segments <= IO_RX.segments;
			--LED <= IO_RX.LED;
			
			IO_RX.buttonDown <= buttonDown;
			IO_RX.buttonUp <= buttonUp;
			IO_RX.buttonRight <= buttonRight;
			IO_RX.buttonLeft <= buttonLeft;
			IO_RX.buttonMiddle <= buttonMiddle;
--			IO_RX.switchesRaw <= switchesRaw;
			
			IO_TX.buttonDown <= '0';
			IO_TX.buttonUp <= '0';
			IO_TX.buttonRight <= '0';
			IO_TX.buttonLeft <= '0';
			IO_TX.buttonMiddle <= '0';
--			IO_TX.switchesRaw <= (others => '0');
		end if;
	end process switching_control_process;
	
	
--------------- TRANSMITTER -----------------------------------

	Tx_inst : entity work.Tx_MAIN
		port map(digits       => IO_TX.digits,
			     segments     => IO_TX.segments,
			     buttonMiddle => IO_TX.buttonMiddle,
			     buttonLeft   => IO_TX.buttonLeft,
			     buttonRight  => IO_TX.buttonRight,
			     buttonUp     => IO_TX.buttonUp,
			     buttonDown   => IO_TX.buttonDown,
			     switchesRaw  => switchesRaw,
			     LED          => IO_TX.LED,
			     clock_100MHz => clock_100MHz,
			     clock_1MHz   => clock_1MHz,
			     clock_1kHz   => clock_1kHz,
			     clock_10Hz   => clock_10Hz,
			     clock_1Hz    => clock_1Hz,
			     output_data  => rcv_data_out,
			     output_clock => rcv_clock_out,
			     output3      => out_clock);
	
--------------- RECEIVER --------------------------------------
	
	Rx_inst : entity work.Rx_MAIN
		port map(digits       => IO_RX.digits,
			     segments     => IO_RX.segments,
			     buttonMiddle => IO_RX.buttonMiddle,
			     buttonLeft   => IO_RX.buttonLeft,
			     buttonRight  => IO_RX.buttonRight,
			     buttonUp     => IO_RX.buttonUp,
			     buttonDown   => IO_RX.buttonDown,
			     switchesRaw  => IO_RX.switchesRaw,
			     LED          => IO_RX.LED,
			     clock_100MHz => clock_100MHz,
			     clock_1MHz   => clock_1MHz,
			     clock_1kHz   => clock_1kHz,
			     clock_10Hz   => clock_10Hz,
			     clock_1Hz    => clock_1Hz,
			     input_data  => usart_in_data_signal,
			     input_clock => usart_in_clock_signal,
			     input3      => '0',
			     debug   => receiver_out_debug);
			     
			     
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

