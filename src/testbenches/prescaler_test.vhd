library ieee;
use ieee.std_logic_1164.all;

entity test_bench_presc is
end test_bench_presc;

architecture Test of test_bench_presc is
	signal clock : std_logic;
	signal clock1 : std_logic;
	signal clock2 : std_logic;
	signal clock3 : std_logic;
	signal clock5 : std_logic;
	signal clock10 : std_logic;
begin
	
	clock_proc : process is
	begin
		clock <= '0';
		wait for 10 ps;
		clock <= '1';
		wait for 10 ps;
	end process clock_proc;
	
	
	presc_1 : entity work.prescaler
		port map(clk_input  => clock,
			     clk_output => clock1,
			     reset      => '0',
			     presc      => 1);
	presc_2 : entity work.prescaler
		port map(clk_input  => clock,
			     clk_output => clock2,
			     reset      => '0',
			     presc      => 2);
	presc_3 : entity work.prescaler
		port map(clk_input  => clock,
			     clk_output => clock3,
			     reset      => '0',
			     presc      => 3);
	presc_5 : entity work.prescaler
		port map(clk_input  => clock,
			     clk_output => clock5,
			     reset      => '0',
			     presc      => 5);	
	presc_10 : entity work.prescaler
		port map(clk_input  => clock,
			     clk_output => clock10,
			     reset      => '0',
			     presc      => 10);
end architecture Test;
