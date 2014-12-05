LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity prescaler is
	port( clk_input : in std_logic;
			clk_output : out std_logic;
			reset : in std_logic;
			presc : positive := 1);
end prescaler;
architecture prescaler_arch of prescaler is
begin
	process(reset, clk_input) is
	variable cnt : integer := 0;
	variable state : std_logic := '0';
	begin
		if( reset = '1' ) then
			cnt := 0;
		elsif( rising_edge(clk_input) ) then
			if ( 2*(cnt + 1) < presc) then
				cnt := cnt+1;
			else
				cnt := 0;
				state := not state;
			end if;
			clk_output <= state;
		end if;
	end process;
end;
