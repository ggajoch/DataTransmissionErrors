library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SevenSegControl is
	port (
		input : in string(8 downto 1);
		input_dots : in std_logic_vector(8 downto 1);
		digits : out std_logic_vector(7 downto 0);		
		segments : out std_logic_vector(7 downto 0);
		segment_change_clock : in std_logic
	);
end entity SevenSegControl;


architecture RTL of SevenSegControl is
    signal segments_buffer : std_logic_vector(7 downto 1);
    signal digits_buffer : std_logic_vector(7 downto 0);  
    signal actual_character : character;
    signal actual_dot : std_logic;
begin
	with actual_character select
		segments_buffer <=
			"1111110" when '0',
			"0110000" when '1',
			"1101101" when '2',
			"1111001" when '3',
			"0110011" when '4',
			"1011011" when '5',
			"1011111" when '6',
			"1110000" when '7',
			"1111111" when '8',
			"1111011" when '9',
			"1110111" when 'a',
			"0011111" when 'b',
			"0001101" when 'c',
			"0111101" when 'd',
			"1001111" when 'e',
			"1000111" when 'f',
			"1111011" when 'g',
			"0010111" when 'h',
			"0010000" when 'i',
			"1111000" when 'j',
			--"0000000" when 'k',
			"0000110" when 'l',
			--"0000000" when 'm',
			"0010101" when 'n',
			"0011101" when 'o',
			"1100111" when 'p',
			"0000101" when 'r',
			"1011011" when 's',
			"0001111" when 't',
			"0011100" when 'u',
			--"0000000" when 'w',
			"0110111" when 'x',
			"0111011" when 'y',
			"1101101" when 'z',
			"0000000" when others;
	
	
	segments <= not ( segments_buffer & actual_dot );
	
	seg_chage : process(segment_change_clock) is
		variable dig_enable : integer range 0 to 7 := 0;
		variable one:std_logic_vector(7 downto 0) := "00000001";
	begin
		if( rising_edge(segment_change_clock) ) then
			if( dig_enable = 7 ) then 
				dig_enable := 0;
			else
				dig_enable := dig_enable + 1;
			end if;
			digits_buffer <= to_stdlogicvector(to_bitvector(one) sll dig_enable);
			actual_character <= input(dig_enable+1);
			actual_dot <= input_dots(dig_enable+1);
		end if;
	end process seg_chage;
	
	digits <= not digits_buffer;
end architecture RTL;
