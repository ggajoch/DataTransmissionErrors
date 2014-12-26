library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CodeGenCheck_test_bench is
end CodeGenCheck_test_bench;

architecture Test of CodeGenCheck_test_bench is
	signal clk : std_logic;
	signal packet : std_logic_vector(7 downto 0);
	signal result : std_logic;
	signal packetIn : std_logic_vector(7 downto 0);
	signal packetU : unsigned(7 downto 0);
begin
	
	clk_proc : process is
	begin
		clk <= '1';
		wait for 10 ps;
		clk <= '0';
		wait for 10 ps;
	end process clk_proc;
	
	
	generator : entity work.CodeGen
		port map(clk    => clk,
			     packet => packet);
	
	packetIn <= std_logic_vector(shift_right(packetU, 1));
	
	packetU <= unsigned(packet);
	
	checker : entity work.CodeCheck
		port map(packet => packetIn,
			     result => result);
end architecture Test;
