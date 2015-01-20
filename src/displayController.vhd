library ieee;
use ieee.std_logic_1164.all;

entity displayController_TX is
	port (
		buttonMiddle : in std_logic;
		buttonLeft : in std_logic;
		buttonRight : in std_logic;
		buttonUp : in std_logic;
		buttonDown : in std_logic;
		clock_dot : in std_logic;
		clock_keyboard : in std_logic;
		protocol_sel_out : out integer range 0 to 99;
		sci_controller_integer_out : out integer range 0 to 99;
		sci_controller_exponent_out : out integer range 0 to 9;
		digits : out std_logic_vector(7 downto 0);		
		segments : out std_logic_vector(7 downto 0);
		segment_mux_clock : in std_logic;
		LVDS_Tx_On : out std_logic
	);
end entity displayController_TX;

architecture RTL of displayController_TX is
	signal sci_controller_string : string(4 downto 1);
	signal sci_controller_dots : std_logic_vector(4 downto 1);
	signal sci_controller_integer : integer range 0 to 99;
	signal sci_controller_exponent : integer range 0 to 9;
	signal sci_controller_enable : std_logic;
	
	signal protocol_string : string(8 downto 1);
	signal protocol_dots : std_logic_vector(8 downto 1);
	signal protocol_selected : integer range 0 to 99;
	signal protocol_enable : std_logic;
	
	signal actual_string : string(8 downto 1);
	signal actual_dots : std_logic_vector(8 downto 1);

	type displayStates is (Speed, Protocol, WaitTicks, Wait1sec, WelcomeSpeed, WelcomeProtocol, Welcome, WelcomeLVDS, LVDS);
begin
	
	segControl : entity work.SevenSegControl
		port map(input                => actual_string,
			     input_dots           => actual_dots,
			     digits               => digits,
			     segments             => segments,
			     segment_change_clock => segment_mux_clock);
	
	sci_controller_integer_out <= sci_controller_integer;
	sci_controller_exponent_out <= sci_controller_exponent;
	protocol_sel_out <= protocol_selected;
	
	scientific_inst : entity work.scientificNumberController
		generic map(nr_of_significant_digits => 1)
		port map(displayString    => sci_controller_string,
			     displayDots      => sci_controller_dots,
			     integer_base     => sci_controller_integer,
			     integer_exponent => sci_controller_exponent,
			     buttonLeft       => buttonLeft,
			     buttonRight      => buttonRight,
			     buttonUp         => buttonUp,
			     buttonDown       => buttonDown,
			     keyboard_clock   => clock_keyboard,
			     dot_clock        => clock_dot,
			     control_enable   => sci_controller_enable);
			     
			     
	prot_chooser_int : entity work.protocolChooser
		port map(displayString  => protocol_string,
			     displayDots    => protocol_dots,
			     modeOut        => protocol_selected,
			     buttonLeft     => buttonLeft,
			     buttonRight    => buttonRight,
			     keyboard_clock => clock_keyboard,
			     control_enable => protocol_enable);
			     
			     
	displayStateMaching : process(clock_keyboard) is
		variable State : displayStates := Welcome;
		variable StateAfterWait : displayStates;
		variable ticks_left : integer := 0;
		variable last_change_button : std_logic := '1';
		variable last_change_button_right : std_logic := '1';
		variable last_change_button_left : std_logic := '1';
		variable middle_pressed : boolean := FALSE;
		variable right_pressed : boolean := FALSE;
		variable left_pressed : boolean := FALSE;
		variable LVDS_On : std_logic := '0';
	begin
		if( rising_edge(clock_keyboard) ) then
			middle_pressed := ( last_change_button = '0' and buttonMiddle = '1' );
			right_pressed := ( last_change_button_right = '0' and buttonRight = '1' );
			left_pressed := ( last_change_button_left = '0' and buttonLeft = '1' );
			actual_dots <= (others => '0'); 
			case State is
				when Speed =>
					sci_controller_enable <= '1';
					actual_dots <= "0000" & sci_controller_dots;
					actual_string <= "----" & sci_controller_string;
					if( middle_pressed ) then
						sci_controller_enable <= '0';
						State := WelcomeProtocol;
					end if;
				when Protocol =>
					actual_string <= protocol_string;
					actual_dots <= protocol_dots; 
					protocol_enable <= '1';
					if( middle_pressed ) then
						protocol_enable <= '0';
						State := WelcomeLVDS;
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
				when WelcomeLVDS =>
					actual_string <= "----lvds";
					StateAfterWait := LVDS;
					State := Wait1sec;
				when LVDS =>
					if ( right_pressed or left_pressed ) then
						if( LVDS_On = '1' ) then
							LVDS_On := '0';
						else
							LVDS_On := '1';
						end if;
					end if;
					
					if ( LVDS_On = '1' ) then
						actual_string <= "-----on-";
					else 
						actual_string <= "-----off";
					end if;
					
					actual_dots <= "00000000";
					if( middle_pressed ) then
						protocol_enable <= '0';
						State := WelcomeSpeed;
					end if;
			end case;
			last_change_button := buttonMiddle;
			last_change_button_right := buttonRight;
			last_change_button_left := buttonLeft;
			LVDS_Tx_On <= LVDS_On;
		end if;
	end process displayStateMaching;
end architecture RTL;


------------------ RX -----------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity displayController_RX is
	port (
		buttonMiddle : in std_logic;
		buttonLeft : in std_logic;
		buttonRight : in std_logic;
		buttonUp : in std_logic;
		buttonDown : in std_logic;
		clock_dot : in std_logic;
		clock_keyboard : in std_logic;
		protocol_sel_out : out integer range 0 to 99;
		sci_controller_integer_out : out integer range 0 to 99;
		sci_controller_exponent_out : out integer range 0 to 9;
		digits : out std_logic_vector(7 downto 0);
		segments : out std_logic_vector(7 downto 0);
		segment_mux_clock : in std_logic;

		errorPercent : in string(4 downto 1);
		errorDots : in std_logic_vector(4 downto 1);
		LVDS_Rx_On : out std_logic
	);
end entity displayController_RX;

architecture RTL of displayController_RX is
	signal sci_controller_string : string(4 downto 1);
	signal sci_controller_dots : std_logic_vector(4 downto 1);
	signal sci_controller_integer : integer range 0 to 99;
	signal sci_controller_exponent : integer range 0 to 9;
	signal sci_controller_enable : std_logic;
	
	signal protocol_string : string(8 downto 1);
	signal protocol_dots : std_logic_vector(8 downto 1);
	signal protocol_selected : integer range 0 to 99;
	signal protocol_enable : std_logic;
	
	signal actual_string : string(8 downto 1);
	signal actual_dots : std_logic_vector(8 downto 1);

	type displayStates is (Speed, Protocol, Errors, WaitTicks, Wait1sec, WelcomeSpeed, WelcomeProtocol, WelcomeErrors, Welcome, WelcomeLVDS, LVDS);
	
begin
	
	segControl : entity work.SevenSegControl
		port map(input                => actual_string,
			     input_dots           => actual_dots,
			     digits               => digits,
			     segments             => segments,
			     segment_change_clock => segment_mux_clock);
	
	sci_controller_integer_out <= sci_controller_integer;
	sci_controller_exponent_out <= sci_controller_exponent;
	protocol_sel_out <= protocol_selected;
	
	scientific_inst : entity work.scientificNumberController
		generic map(nr_of_significant_digits => 1)
		port map(displayString    => sci_controller_string,
			     displayDots      => sci_controller_dots,
			     integer_base     => sci_controller_integer,
			     integer_exponent => sci_controller_exponent,
			     buttonLeft       => buttonLeft,
			     buttonRight      => buttonRight,
			     buttonUp         => buttonUp,
			     buttonDown       => buttonDown,
			     keyboard_clock   => clock_keyboard,
			     dot_clock        => clock_dot,
			     control_enable   => sci_controller_enable);
			     
			     
	prot_chooser_int : entity work.protocolChooser
		port map(displayString  => protocol_string,
			     displayDots    => protocol_dots,
			     modeOut        => protocol_selected,
			     buttonLeft     => buttonLeft,
			     buttonRight    => buttonRight,
			     keyboard_clock => clock_keyboard,
			     control_enable => protocol_enable);
	
	displayStateMaching : process(clock_keyboard) is
		variable State : displayStates := Welcome;
		variable StateAfterWait : displayStates;
		variable ticks_left : integer := 0;
		variable last_change_button : std_logic := '1';
		variable last_change_button_right : std_logic := '1';
		variable last_change_button_left : std_logic := '1';
		variable middle_pressed : boolean := FALSE;
		variable right_pressed : boolean := FALSE;
		variable left_pressed : boolean := FALSE;
		variable LVDS_On : std_logic := '0';
	begin
		if( rising_edge(clock_keyboard) ) then
			middle_pressed := ( last_change_button = '0' and buttonMiddle = '1' );
			right_pressed := ( last_change_button_right = '0' and buttonRight = '1' );
			left_pressed := ( last_change_button_left = '0' and buttonLeft = '1' );
			actual_dots <= (others => '0'); 
			case State is
				when Speed =>
					sci_controller_enable <= '1';
					actual_dots <= "0010" & sci_controller_dots;
					actual_string <= errorPercent & sci_controller_string;
					if( middle_pressed ) then
						sci_controller_enable <= '0';
						State := WelcomeProtocol;
					end if;
				when Protocol =>
					actual_string <= protocol_string;
					actual_dots <= protocol_dots; 
					protocol_enable <= '1';
					if( middle_pressed ) then
						protocol_enable <= '0';
						State := WelcomeLVDS; --disable error screen
					end if;
				when Errors =>
					actual_string <= "----" & errorPercent;
					actual_dots <= "0000" & errorDots; 
					if( middle_pressed ) then
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
				when WelcomeErrors => 
					actual_string <= "-errors-";
					StateAfterWait := Errors;
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
				when WelcomeLVDS =>
					actual_string <= "----lvds";
					StateAfterWait := LVDS;
					State := Wait1sec;
				when LVDS =>
					if ( right_pressed or left_pressed ) then
						if( LVDS_On = '1' ) then
							LVDS_On := '0';
						else
							LVDS_On := '1';
						end if;
					end if;
					
					if ( LVDS_On = '1' ) then
						actual_string <= "-----on-";
					else 
						actual_string <= "-----off";
					end if;
					
					actual_dots <= "00000000";
					if( middle_pressed ) then
						protocol_enable <= '0';
						State := WelcomeSpeed;
					end if;
			end case;
			last_change_button := buttonMiddle;
			last_change_button_right := buttonRight;
			last_change_button_left := buttonLeft;
			LVDS_Rx_On <= LVDS_On;
		end if;
	end process displayStateMaching;
end architecture RTL;
