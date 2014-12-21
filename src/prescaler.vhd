LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity prescaler is
	generic ( max_presc : integer := 400000000 );
	port( clk_input : in std_logic;
			clk_output : out std_logic;
			reset : in std_logic;
			presc : integer range 1 to max_presc := 2);
end prescaler;
architecture prescaler_arch of prescaler is
	subtype max_time is integer range 0 to (max_presc/2);
	
	signal timeLow : max_time;
	signal timeHigh : max_time;
begin
	
	timeLow <= presc/2;
	timeHigh <= presc-timeLow;
	
	process(reset, clk_input) is
		variable cnt : max_time := 0;
		variable state : std_logic := '0';
	begin
		if( reset = '1' ) then
			cnt := 0;
			state := '0';
		elsif( rising_edge(clk_input) ) then
			if( state = '0' and cnt = timeLow ) then
				cnt := 1;
				state := '1';
			elsif( state = '1' and cnt = timeHigh ) then
				cnt := 1;
				state := '0';
			else
				cnt := cnt+1;
			end if;	
		end if;
		clk_output <= state;
	end process;
end;
