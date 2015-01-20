library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Rx_MAIN is
	port (
		digits : out std_logic_vector(7 downto 0);
		segments : out std_logic_vector(7 downto 0);
		buttonMiddle : in std_logic;
		buttonLeft : in std_logic;
		buttonRight : in std_logic;
		buttonUp : in std_logic;
		buttonDown : in std_logic;
		switchesRaw : in std_logic_vector(15 downto 0);
		LED : out std_logic_vector(15 downto 0);
		
		clock_100MHz : in std_logic;
		clock_1MHz : in std_logic;
		clock_1kHz : in std_logic;
		clock_10Hz : in std_logic;
		clock_1Hz : in std_logic;
			
		input_data : in std_logic;
		input_clock : in std_logic;
		input3 : in std_logic;
		
		debug : out std_logic_vector(7 downto 0);
		
		LVDS_On : out std_logic
	);
end entity Rx_MAIN;

architecture RTL of Rx_MAIN is
	
	--------------- CLOCKS ------------------------------------
	signal clock_prescaled : std_logic;
	signal data_trigger : std_logic;
	
	
	--------------- USER INPUT --------------------------------
	
	signal protocol_sel : integer range 0 to 99;
	signal speed_integer : integer range 0 to 99;
	signal speed_exponent : integer range 0 to 9;
	
	signal LVDS_Rx_On : std_logic;
	
	--------------- COMMON ------------------------------------
	signal data_out : std_logic_vector(7 downto 0);
	signal data_rcvd : std_logic_vector(7 downto 0);
	signal data_latch : std_logic;
	
	--------------- ERROR -------------------------------------
	signal errorDots : std_logic_vector(4 downto 1);
	signal errorPercent : string(4 downto 1);
	signal errorTrasmissionError : std_logic;
		
	--------------- UART --------------------------------------
	
	type uartData_t is record
		in_pin : std_logic;
		data : std_logic_vector(7 downto 0);
		data_flag : std_logic;
		transmission_error : std_logic;
		fast_clock : std_logic;
		sampling_clock : std_logic;
		sampling_clock_reset : std_logic;
		out_debug : std_logic_vector(7 downto 0);
	end record uartData_t;
	
	signal uart_struct : uartData_t;
	
	signal sampling_clock_reset : std_logic;
	signal fast_clock : std_logic;
		
	--------------- USART -------------------------------------
	
	type usartData_t is record
		in_pin_data : std_logic;
		in_pin_clock : std_logic;
		data : std_logic_vector(7 downto 0);
		data_flag : std_logic;
		transmission_error : std_logic;
	end record usartData_t;
	
	signal usart_struct : usartData_t;
	signal out_debug : std_logic_vector(7 downto 0);
	
	
	
begin
	
	LVDS_On <= LVDS_Rx_On;
	
	--------------- DISPLAY CONTROL ---------------------------
	
	display_inst : entity work.displayController_RX
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
			     digits 			 		 => digits,
			     segments				 	 => segments,
			     segment_mux_clock			 => clock_1kHz,
			     errorPercent				 => errorPercent,
			     errorDots					 => errorDots,
			     LVDS_Rx_On				     => LVDS_Rx_On);

	

	--------------- CLOCK GENERATION --------------------------

	clock_inst : entity work.clockController
		port map(speed_integer => speed_integer,
			     speed_exp     => speed_exponent,
			     clock_100MHz  => clock_100MHz,
			     clock_out     => clock_prescaled,
			     reset_presc   => sampling_clock_reset,
			     fast_clock	   => fast_clock);

	trigger_gen_inst : entity work.prescaler
		generic map(max_presc => 30)
		port map(clk_input  => clock_prescaled,
			     clk_output => data_trigger,
			     reset      => '0',
			     presc      => 30);

	--------------- DATA GENERATION ---------------------------
	
	data_out <= switchesRaw(7 downto 0);
	
	
	--------------- USER INPUTS -------------------------------
	
	LED(7 downto 0) <= data_rcvd;
	
	process(protocol_sel, uart_struct, usart_struct.data) is
	begin
		case protocol_sel is
			when 0 =>
				data_rcvd <= uart_struct.data;
				data_latch <= uart_struct.data_flag;
				errorTrasmissionError <= uart_struct.transmission_error;
			when 1 =>
				data_rcvd <= usart_struct.data;
				data_latch <= usart_struct.data_flag;
				errorTrasmissionError <= usart_struct.transmission_error;
			when others =>
				data_rcvd <= (others => '0');
				data_latch <= '0';
				errorTrasmissionError <= '0';
		end case;
	end process;
	
	--------------- ERRORS ------------------------------------
	
	err_calc : entity work.ErrorsCalc
		port map(displayPercent => errorPercent,
			     displayDots    => errorDots,
			     data           => data_rcvd,
			     data_latch     => data_latch,
			     data_transmissionError		=> errorTrasmissionError,
			     tick           => data_trigger,
			     clock_1kHz     => clock_1kHz);
	
	errorDetector : entity work.CodeCheck
		port map(packet => uart_struct.data,
			     result => debug(7));
	
	debug(6) <= data_trigger;
	debug(5) <= data_latch;
	
	--------------- UART --------------------------------------

	uart_struct.fast_clock <= fast_clock;
	uart_struct.in_pin <= input_data;
	uart_struct.sampling_clock <= clock_prescaled;
	sampling_clock_reset <= uart_struct.sampling_clock_reset;
	 
	uartRx_inst : entity work.UART_Rx
		port map(RxPin                => uart_struct.in_pin,
			     fast_clock           => uart_struct.fast_clock,
			     sampling_clock       => uart_struct.sampling_clock,
			     sampling_clock_reset => uart_struct.sampling_clock_reset,
			     Data                 => uart_struct.data,
			     DataFlag             => uart_struct.data_flag,
			     TransmissionError    => uart_struct.transmission_error,
			     out_debug			  => out_debug);

	debug(4 downto 0) <= out_debug(4 downto 0);

	
	--------------- USART -------------------------------------
	
	usart_struct.in_pin_data <= input_data;
	usart_struct.in_pin_clock <= input_clock;
	
	usart_Rx_inst : entity work.USART_Rx
		port map(RxPin             => usart_struct.in_pin_data,
			     RxSynchPin        => usart_struct.in_pin_clock,
			     Data              => usart_struct.data,
			     DataFlag          => usart_struct.data_flag,
			     TransmissionError => usart_struct.transmission_error);


end architecture RTL;

