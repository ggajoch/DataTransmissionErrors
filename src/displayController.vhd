library ieee;
use ieee.std_logic_1164.all;

entity displayController is
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
		display_string : out string(8 downto 1);
		display_dots : out std_logic_vector(8 downto 1)
	);
end entity displayController;

architecture RTL of displayController is
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

	type displayStates is (Speed, Protocol, WaitTicks, Wait1sec, WelcomeSpeed, WelcomeProtocol, Welcome);
begin
	
	display_string <= actual_string;
	display_dots <= actual_dots;
	
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
		variable middle_pressed : boolean := FALSE;
	begin
		if( rising_edge(clock_keyboard) ) then
			middle_pressed := ( last_change_button = '0' and buttonMiddle = '1' );
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
end architecture RTL;
