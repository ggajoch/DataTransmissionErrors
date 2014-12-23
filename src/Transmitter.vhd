library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Tx_MAIN is
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
		
		
		
		output_data : out std_logic;
		output_clock : out std_logic;
		output3 : out std_logic
	);
end entity Tx_MAIN;

architecture RTL of Tx_MAIN is
	
	--------------- CLOCKS ------------------------------------
	signal clock_prescaled : std_logic;
	signal data_trigger : std_logic;
	
	
	--------------- USER INPUT --------------------------------
	
	signal protocol_sel : integer range 0 to 99;
	signal speed_integer : integer range 0 to 99;
	signal speed_exponent : integer range 0 to 9;
	
	--------------- COMMON ------------------------------------
	signal data_out : std_logic_vector(7 downto 0);
	
	
	--------------- UART --------------------------------------
	signal uart_out : std_logic;
	signal uart_trigger : std_logic;
	signal uart_TC : std_logic;
	
	--------------- USART -------------------------------------
	signal usart_out_data : std_logic;
	signal usart_out_clock : std_logic;
	signal usart_trigger : std_logic;
	signal usart_TC : std_logic;
	

begin
	
	--------------- DISPLAY CONTROL ---------------------------
	
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
			     digits 			 		 => digits,
			     segments				 	 => segments,
			     segment_mux_clock			 => clock_1kHz);

	

	--------------- CLOCK GENERATION --------------------------

	clock_inst : entity work.clockController
		port map(speed_integer => speed_integer,
			     speed_exp     => speed_exponent,
			     clock_100MHz  => clock_100MHz,
			     clock_out     => clock_prescaled,
			     reset_presc   => '0');

	trigger_gen_inst : entity work.prescaler
		generic map(max_presc => 30)
		port map(clk_input  => clock_prescaled,
			     clk_output => data_trigger,
			     reset      => '0',
			     presc      => 30);


	--------------- DATA GENERATION ---------------------------
	
	data_out <= switchesRaw(7 downto 0);
	
	
	--------------- USER INPUTS -------------------------------
	
	process(protocol_sel, uart_out, usart_out_clock, usart_out_data) is
	begin
		case protocol_sel is
			when 0 =>
				output_data <= uart_out;
				output_clock <= '0';
			when 1 =>
				output_data <= usart_out_data;
				output_clock <= usart_out_clock;
			when others =>
				output_data <= '0';
				output_clock <= '0';
		end case;
	end process;
	
	
	--------------- UART --------------------------------------

	uart_trigger <= data_trigger;
	
	uart_inst : entity work.UART_Tx	
		port map(TxPin    => uart_out,
			     TxClock  => clock_prescaled,
			     Data     => data_out,
			     DataFlag => uart_trigger,
			     TC       => uart_TC);

	--------------- USART -------------------------------------
	
	usart_trigger <= data_trigger;
	usartTX_inst : entity work.USART_Tx
		port map(TxPin      => usart_out_data,
			     TxSynchPin => usart_out_clock,
			     TxClock    => clock_prescaled,
			     Data       => data_out,
			     DataFlag   => usart_trigger,
			     TC         => usart_TC); 


end architecture RTL;

