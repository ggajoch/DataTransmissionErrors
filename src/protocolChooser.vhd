library ieee;
use ieee.std_logic_1164.all;

entity protocolChooser is
	generic ( nr_of_digits : integer range 1 to 8 := 8;
			  nr_of_modes : integer := 2 
	);
	port (
		displayString : out string(nr_of_digits downto 1);
		displayDots : out std_logic_vector(nr_of_digits downto 1);
		modeOut : out integer range 0 to nr_of_modes-1;
		buttonLeft : in std_logic;
		buttonRight : in std_logic;
		keyboard_clock : in std_logic;
		control_enable : in std_logic
	);
end entity protocolChooser;


architecture RTL of protocolChooser is
	type modesArray_t is array(0 to nr_of_modes-1) of string(8 downto 1);
	signal modesArray : modesArray_t := ("--uart--", "--usart-");
	
	signal modeIter : integer range 0 to nr_of_modes-1 := 0;
begin 
	displayDots <= (others => '0');
	displayString <= modesArray(modeIter);-- & character'val(48+modeIter);
	modeOut <= modeIter;
	
	process(keyboard_clock) is
			variable last_Left : std_logic := '0';
			variable last_Right : std_logic := '0';
			variable left_pressed : boolean := false;
			variable right_pressed : boolean := false;
		begin
			if( rising_edge(keyboard_clock) ) then
				left_pressed := ( last_Left = '0' and buttonLeft = '1' );
				right_pressed := ( last_Right = '0' and buttonRight = '1' );
				
				if ( control_enable = '1' ) then 
					if( left_pressed ) then
						if( modeIter > 0 ) then
							modeIter <= modeIter-1;
						else
							modeIter <= nr_of_modes-1;
						end if; 
					end if;
					
					if( last_Right = '0' and buttonRight = '1') then
						if( modeIter < nr_of_modes-1 ) then
							modeIter <= modeIter+1;
						else
							modeIter <= 0;
						end if;
					end if;
	      		end if;                  
				last_Left := buttonLeft;
				last_Right := buttonRight;
			end if;
	end process;
end architecture RTL;
