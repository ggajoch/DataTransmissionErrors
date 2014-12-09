library ieee;
use ieee.std_logic_1164.all;

entity test_bench_exp_num_ctrl is
end test_bench_exp_num_ctrl;

architecture Test of test_bench_exp_num_ctrl is
	signal displayString : string(5 downto 1);
	signal displayDots : std_logic_vector(5 downto 1);		
	signal buttonLeft : std_logic := '0';
	signal buttonRight : std_logic := '0';
	signal buttonUp : std_logic := '0';
	signal buttonDown : std_logic := '0';
	signal keyboard_clock : std_logic := '0';
	signal dot_clock : std_logic := '0';
	signal speed_enable : std_logic := '0';
	
	signal integer_base : integer range 0 to 999;
	signal integer_exponent : integer range 0 to 9;
begin
	
	num : entity work.scientificNumberController
		generic map(nr_of_significant_digits => 2)
		port map(displayString    => displayString,
			     displayDots      => displayDots,
			     integer_base     => integer_base,
			     integer_exponent => integer_exponent,
			     buttonLeft       => buttonLeft,
			     buttonRight      => buttonRight,
			     buttonUp         => buttonUp,
			     buttonDown       => buttonDown,
			     keyboard_clock   => keyboard_clock,
			     dot_clock        => dot_clock,
			     control_enable   => '1');
				
				
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
		wait for 100 ns;
		
		wait for 100 ns;
		buttonRight <= '1';
		wait for 10 ns;
		buttonRight <= '0';
		wait for 100 ns;
		
		buttonUp <= '1';
		wait for 10 ns;
		buttonUp <= '0';
		wait for 10 ns;
		buttonUp <= '1';
		wait for 10 ns;
		buttonUp <= '0';
		wait for 10 ns;
		
		
		buttonLeft <= '1';
		wait for 10 ns;
		buttonLeft <= '0';
		wait for 10 ns;
		buttonUp <= '1';
		
		buttonLeft <= '1';
		wait for 10 ns;
		buttonLeft <= '0';
		wait for 10 ns;
		
		wait for 10 ns;
		buttonUp <= '0';
		wait for 10 ns;
		
	end process test;
	
	
end architecture Test;
