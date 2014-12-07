library ieee;
use ieee.std_logic_1164.all;

entity test_bench is
end test_bench;

architecture Test of test_bench is
	signal displayString : string(8 downto 1);
	signal displayDots : std_logic_vector(8 downto 1);		
	signal buttonLeft : std_logic := '0';
	signal buttonRight : std_logic := '0';
	signal buttonUp : std_logic := '0';
	signal buttonDown : std_logic := '0';
	signal keyboard_clock : std_logic := '0';
	signal dot_clock : std_logic := '0';
begin
	num1 : entity work.numberController(RTL)
		port map( displayString => displayString,
				displayDots =>  displayDots,		
				buttonLeft =>  buttonLeft,
				buttonRight =>  buttonRight,
				buttonUp =>  buttonUp,
				buttonDown =>  buttonDown,
				keyboard_clock =>  keyboard_clock,
				dot_clock =>  dot_clock			
				);
				
				
	keys : process is
	begin
		keyboard_clock <= '1';
		wait for 1 ns;
		keyboard_clock <= '0';
		wait for 1 ns;
	end process keys;
	
	dot : process is
	begin
		dot_clock <= '1';
		wait for 2 ns;
		dot_clock <= '0';
		wait for 2 ns;
	end process dot;
	
	test : process is
	begin
		wait for 100 ns;
		buttonUp <= '1';
		wait for 10 ns;
		buttonUp <= '0';
		wait for 10 ns;
		buttonLeft <= '1';
		wait for 10 ns;
		buttonLeft <= '0';
		wait for 10 ns;
		buttonUp <= '1';
		wait for 10 ns;
		buttonUp <= '0';
		wait for 10 ns;
		
	end process test;
	
	
end architecture Test;
