library ieee;
use ieee.std_logic_1164.all;

entity PLL_testbench is
end entity PLL_testbench;

architecture RTL of PLL_testbench is
	signal data_valid : std_logic;
	signal response : std_logic_vector(1 downto 0);
	signal done : std_logic;
	signal PLL_locked : std_logic;
	signal PLL_clock_out : std_logic;
	signal clock_100MHz : std_logic;
	
begin
	plll: entity work.PLLValues
		port map(DIVCLK_DIVIDE    => 10,
			     CLKFBOUT_MULT    => 1,
			     CLKFBOUT_FRAC    => 156,
			     CLKFBOUT_FRAC_EN => '1',
			     data_valid       => data_valid,
			     response         => response,
			     done             => done,
			     clock_100MHz     => clock_100MHz,
			     PLL_clock_out    => PLL_clock_out,
			     PLL_locked       => PLL_locked);
			     
			     
			     
	clockProcess : process is
	begin
		clock_100MHz <= '0';
		wait for 10 ns;
		clock_100MHz <= '1';
		wait for 10 ns;
	end process clockProcess;
	
	validProcess : process is
	begin
		wait for 100 ns;
		data_valid <= '0';
		wait for 100 ns;
		data_valid <= '1';
	end process validProcess;
	
end architecture RTL;
