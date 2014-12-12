library ieee;
use ieee.std_logic_1164.all;

entity scientificNumberController is
	generic ( nr_of_significant_digits : integer range 1 to 8 := 2);
	port (
		displayString : out string(nr_of_significant_digits+3 downto 1);
		displayDots : out std_logic_vector(nr_of_significant_digits+3 downto 1);
		integer_base : out integer range 0 to (10**(nr_of_significant_digits+1)-1);
		integer_exponent : out integer range 0 to 9;
		buttonLeft : in std_logic;
		buttonRight : in std_logic;
		buttonUp : in std_logic;
		buttonDown : in std_logic;
		keyboard_clock : in std_logic;
		dot_clock : in std_logic;
		control_enable : in std_logic
	);
end entity scientificNumberController;

architecture RTL of scientificNumberController is
	constant zeros_string : string(nr_of_significant_digits+1 downto 1) := (others => '0');
	signal digits_string : string(nr_of_significant_digits+3 downto 1) := zeros_string & "e1";
	signal buf_integer_base : integer range 0 to (10**(nr_of_significant_digits+1)-1) := 0;
	signal buf_integer_exponent : integer range 0 to 9 := 1;
	constant Zeros : std_logic_vector(nr_of_significant_digits+1 downto 1) := (others => '0');
	signal changing_nr : integer range 1 to nr_of_significant_digits+3 := 3;
	
	signal digits_actual : integer range 1 to nr_of_significant_digits := nr_of_significant_digits;
begin
	
	displayString <= digits_string;
	
	dot_process : process(changing_nr, dot_clock, digits_actual) is
	begin
		if( changing_nr = digits_actual+3 ) then
			displayDots <= dot_clock & Zeros & '0'; 
		else
			displayDots <= "1" & to_stdlogicvector(to_bitvector(Zeros & dot_clock) sll (changing_nr-1));			
		end if;
	end process dot_process;
	
	integer_base <= buf_integer_base;
	integer_exponent <= buf_integer_exponent;
	process(keyboard_clock) is
			variable last_Left : std_logic := '0';
			variable last_Right : std_logic := '0';
			variable last_Up : std_logic := '0';
			variable last_Down : std_logic := '0';
			
			variable increment_base : integer range 0 to (10**(nr_of_significant_digits+1)-1) := 1;
		begin
			if( rising_edge(keyboard_clock) ) then
				if ( control_enable = '1' ) then					
					if( last_Left = '0' and buttonLeft = '1') then
						if( changing_nr = 1 ) then 
							changing_nr <= changing_nr+2;
							increment_base := 1;
						elsif( changing_nr < nr_of_significant_digits+3 ) then
							changing_nr <= changing_nr+1;
							increment_base := 10*increment_base;
						end if;
					end if;
					
					if( last_Right = '0' and buttonRight = '1') then
						if( changing_nr > 3 ) then
							changing_nr <= changing_nr-1;
							increment_base := increment_base/10;
						elsif ( changing_nr = 3 ) then
							changing_nr <= 1;
							increment_base := 0;
						end if;
					end if;
					
					if( last_Up = '0' and buttonUp = '1') then
						if( character'pos(digits_string(changing_nr)) < character'pos('9') ) then
							if ( changing_nr = 1 ) then
								buf_integer_exponent <= buf_integer_exponent + 1;
							else
								buf_integer_base <= buf_integer_base + increment_base; 
							end if;
			                digits_string(changing_nr) <= character'val(character'pos(digits_string(changing_nr)) + 1);
			            end if;
		            end if;
					
					if( last_Down = '0' and buttonDown = '1') then
						if( character'pos(digits_string(changing_nr)) > character'pos('0') ) then
							if ( changing_nr = 1 ) then
								buf_integer_exponent <= buf_integer_exponent - 1;
							else
								buf_integer_base <= buf_integer_base - increment_base; 
							end if;
			                digits_string(changing_nr) <= character'val(character'pos(digits_string(changing_nr)) - 1);
			            end if;
		            end if;
	      		end if;                  
				last_Left := buttonLeft;
				last_Right := buttonRight;
				last_Up := buttonUp;
				last_Down := buttonDown;
			end if;
	end process;
end architecture RTL;
	