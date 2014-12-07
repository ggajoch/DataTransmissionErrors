library ieee;
use ieee.std_logic_1164.all;

entity numberController is
	generic ( nr_of_digits : integer range 1 to 8 := 8);
	port (
		displayString : out string(nr_of_digits downto 1);
		displayDots : out std_logic_vector(nr_of_digits downto 1);
		integer_value : out integer range 0 to (10**nr_of_digits-1);
		buttonLeft : in std_logic;
		buttonRight : in std_logic;
		buttonUp : in std_logic;
		buttonDown : in std_logic;
		keyboard_clock : in std_logic;
		dot_clock : in std_logic
	);
end entity numberController;

architecture RTL of numberController is
	signal digits_string : string(nr_of_digits downto 1);
	signal output_integer : integer range 0 to (10**nr_of_digits-1);
	signal Zeros : std_logic_vector(nr_of_digits-2 downto 0) := (others => '0');
	signal changing_nr : integer range 1 to nr_of_digits := 1;
begin
	displayDots <= to_stdlogicvector(to_bitvector(Zeros & dot_clock) sll (changing_nr-1));
	displayString <= digits_string;
	integer_value <= output_integer;
	process(keyboard_clock) is
			variable last_Left : std_logic := '0';
			variable last_Right : std_logic := '0';
			variable last_Up : std_logic := '0';
			variable last_Down : std_logic := '0';
			
			variable increment : integer range 0 to (10**nr_of_digits-1) := 1;
		begin
			if( rising_edge(keyboard_clock) ) then
				if( last_Left = '0' and buttonLeft = '1') then
					if( changing_nr < nr_of_digits ) then
						changing_nr <= changing_nr+1;
						increment := 10*increment;
					end if;
				end if;
				
				if( last_Right = '0' and buttonRight = '1') then
					if( changing_nr > 1 ) then
						changing_nr <= changing_nr-1;
						increment := increment/10;
					end if;
				end if;
				
				if( last_Up = '0' and buttonUp = '1') then
					if( character'pos(digits_string(changing_nr)) < 9 ) then
						output_integer <= output_integer + increment;
		                digits_string(changing_nr) <= character'val(character'pos(digits_string(changing_nr)) + 1);
		            end if;
	            end if;
				
				if( last_Down = '0' and buttonDown = '1') then
					if( character'pos(digits_string(changing_nr)) > 0 ) then
						output_integer <= output_integer - increment;
		                digits_string(changing_nr) <= character'val(character'pos(digits_string(changing_nr)) - 1);
		            end if;
	            end if;
	                        
				last_Left := buttonLeft;
				last_Right := buttonRight;
				last_Up := buttonUp;
				last_Down := buttonDown;
			end if;
	end process;
end architecture RTL;
	