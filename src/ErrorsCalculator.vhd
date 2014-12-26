library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ErrorsDisplay is
	port (
		displayString : out string(8 downto 1);
		displayDots : out std_logic_vector(8 downto 1);
		buttonLeft : in std_logic;
		buttonRight : in std_logic;
		keyboard_clock : in std_logic;
		control_enable : in std_logic;
		displayPercent : in string(8 downto 1);
		displayWanted : in string(8 downto 1);
		displayGot : in string(8 downto 1)
	);
end entity ErrorsDisplay;


architecture RTL of ErrorsDisplay is
	type State_t is (Prcnt, Wanted, Got);
	signal State : State_t;
begin
	process(keyboard_clock) is
		variable last_Left : std_logic := '0';
		variable last_Right : std_logic := '0';
		variable left_pressed : boolean := false;
		variable right_pressed : boolean := false;
	begin
		if( rising_edge(keyboard_clock) ) then
			left_pressed := ( last_Left = '0' and buttonLeft = '1' );
			right_pressed := ( last_Right = '0' and buttonRight = '1' );
			if( control_enable = '1' ) then
				
				case State is 
					when Prcnt =>
						if( left_pressed ) then
							State <= Got;
						elsif ( right_pressed ) then
							State <= Wanted;
						end if;
					when Wanted =>
						if( left_pressed ) then
							State <= Prcnt;
						elsif ( right_pressed ) then
							State <= Got;
						end if;
					when Got =>
						if( left_pressed ) then
							State <= Wanted;
						elsif ( right_pressed ) then
							State <= Prcnt;
						end if;
				end case;
				
				last_Left := buttonLeft;
				last_Right := buttonRight;
			end if;
		end if;
	end process;
	
	with State select
		displayString <=
			displayPercent when Prcnt,
			displayWanted when Wanted,
			displayGot when others;
	
	
end architecture RTL;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity ErrorsCalc is
	port (
		displayPercent : out string(8 downto 1);
		displayWanted : out string(8 downto 1);
		displayGot : out string(8 downto 1);
		displayDots : out std_logic_vector(8 downto 1);
		data : in std_logic_vector(7 downto 0);
		data_latch : in std_logic;
		data_transmissionError : in std_logic;
		tick : in std_logic;
		clock_100MHz : in std_logic; 
		clock_1kHz : in std_logic
	);
end entity ErrorsCalc;


architecture RTL of ErrorsCalc is
	signal received_count : natural := 0;
	signal received_reset : std_logic;
	
	signal expected_count : natural := 0;
	signal expected_reset : std_logic;
	
	signal displayDotsSig : std_logic_vector(8 downto 1) := (others => '0');
	
	signal data_OK : std_logic;
	
	function int_to_string( input : integer ) return string is
		variable str : string(7 downto 1);
	begin
		str(1) := character'val(48 + (input mod 10));
		str(2) := character'val(48 + ((input/10) mod 10));
		str(3) := character'val(48 + ((input/100) mod 10));
		str(4) := character'val(48 + ((input/1000) mod 10));
		str(5) := character'val(48 + ((input/10000) mod 10));
		str(6) := character'val(48 + ((input/100000) mod 10));
		str(7) := character'val(48 + ((input/1000000) mod 10));
		--str(8) := character'val(48 + ((input/10000000) mod 10));
		return str; 
	end int_to_string;
	
begin
	
	displayDots <= displayDotsSig;
	
	
	update_disp : process(clock_1kHz) is
		variable count : integer range 0 to 1002 := 0;
		variable res : natural := 0; 
	begin
		if ( rising_edge(clock_1kHz) ) then
			count := count+1;
			received_reset <= '0';
			expected_reset <= '0';
			if( count >= 1000 ) then
				count := 0;

				received_reset <= '1';
				expected_reset <= '1';
				
				res := received_count;
				res := 1000*res;
				res := res/expected_count;
				
				displayPercent <= "p" & int_to_string(res);
				displayWanted <= "e" & int_to_string(expected_count);
				displayGot <= "g" & int_to_string(received_count);
				
				displayDotsSig(1) <= not displayDotsSig(1);
			end if;
		end if;
	end process update_disp;
	
	

	
	tickCount : process(tick, expected_reset) is
	begin
		if( expected_reset = '1' ) then
			expected_count <= 0;
		elsif( rising_edge(tick) ) then
			expected_count <= expected_count+1;
		end if;
	end process tickCount;

	errorDetector : entity work.CodeCheck
		port map(packet => data,
			     result => data_OK);
	
	main : process(data_latch, received_reset) is
	begin
		if( received_reset = '1' ) then
			received_count <= 0;
		elsif( rising_edge(data_latch) ) then
			if ( data_OK = '1' ) then
				received_count <= received_count+1; 
			end if;
		end if;
	end process main;
	
	
	
end architecture RTL;

