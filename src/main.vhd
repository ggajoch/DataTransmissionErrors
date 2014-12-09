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

signal speed_string : string(8 downto 1);
signal speed_dots : std_logic_vector(8 downto 1);
signal speed_enable : std_logic := '0';

signal prot_string : string(8 downto 1);
signal prot_dots : std_logic_vector(8 downto 1);
signal prot_enable : std_logic := '0';
signal prot_selected_mode : integer range 0 to 1;

signal actual_string : string(8 downto 1);
signal actual_dots : std_logic_vector(8 downto 1);

type displayStates is (Speed, Protocol, WaitTicks, Wait1sec, WelcomeSpeed, WelcomeProtocol, Welcome);

begin
	
	displayStateMaching : process(clock_1kHz) is
		variable State : displayStates := Welcome;
		variable StateAfterWait : displayStates;
		variable ticks_left : integer := 0;
		variable last_change_button : std_logic := '1';
		variable middle_pressed : boolean := FALSE;
	begin
		if( rising_edge(clock_1kHz) ) then
			middle_pressed := ( last_change_button = '0' and buttonMiddle = '1' );
			actual_dots <= (others => '0'); 
			case State is
				when Speed =>
					speed_enable <= '1';
					actual_dots <= speed_dots;
					actual_string <= speed_string;
					if( middle_pressed ) then
						speed_enable <= '0';
						State := WelcomeProtocol;
					end if;
				when Protocol =>
					actual_string <= prot_string;
					prot_enable <= '1';
					if( middle_pressed ) then
						prot_enable <= '0';
						State := WelcomeSpeed;
					end if;
				when WelcomeSpeed =>
					actual_string <= "-speed--";
					StateAfterWait := Speed;
					State := Wait1sec;
				when WelcomeProtocol =>
					actual_string <= "--prot--";
					StateAfterWait := Protocol;
					State := Wait1sec;
				when Welcome =>
					actual_string <= "-hello--";
					StateAfterWait := WelcomeSpeed;
					State := Wait1sec;
				when Wait1sec => 
					ticks_left := 999;
					State := WaitTicks;
				when WaitTicks =>
					if( ticks_left > 0 ) then
						ticks_left := ticks_left-1;
					else
						State := StateAfterWait;
					end if;
			end case;
			last_change_button := buttonMiddle;
		end if;
	end process displayStateMaching;
	
	numController_inst : entity work.numberController
		generic map(nr_of_digits => 8)
		port map(displayString  => speed_string,
			     displayDots    => speed_dots,
			     integer_value  => prescaler_value,
			     buttonLeft     => buttonLeft,
			     buttonRight    => buttonRight,
			     buttonUp       => buttonUp,
			     buttonDown     => buttonDown,
			     keyboard_clock => clock_1kHz,
			     dot_clock      => clock_10Hz,
			     control_enable => speed_enable);

	prot_chooser_int : entity work.protocolChooser
		port map(displayString  => prot_string,
			     displayDots    => prot_dots,
			     modeOut        => prot_selected_mode,
			     buttonLeft     => buttonLeft,
			     buttonRight    => buttonRight,
			     keyboard_clock => clock_1kHz,
			     control_enable => prot_enable);
	
	out_clock <= clock_prescaled;
	prescalerTestControlled : entity work.prescaler
       port map(clk_input => clock_100MHz,
                clk_output => clock_prescaled,
                reset => '0',
                presc => prescaler_value);



	SevenSegControl_inst : entity work.SevenSegControl
		port map(input => actual_string,
				 input_dots => actual_dots,
			     digits => digits,
			     segments => segments,
			     segment_change_clock => clock_1kHz);


--------------- UART ------------------------------------

	uart_inst : entity work.TxTest
		port map(TxPin    => LED(0),
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