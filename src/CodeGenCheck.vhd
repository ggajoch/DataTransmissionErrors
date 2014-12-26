library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CodeGen is
	port (
		clk : in std_logic;
		packet : out std_logic_vector(7 downto 0)
	);
end entity CodeGen;


architecture RTL of CodeGen is
begin
	process(clk) is
		variable cnt : unsigned(3 downto 0) := (others => '0');
		variable cnt_vec : std_logic_vector(3 downto 0) := (others => '0');
	begin
		if( rising_edge(clk) ) then
			cnt := cnt+1;
			cnt_vec := std_logic_vector(cnt);
			packet <= cnt_vec & (not cnt_vec);
		end if;
	end process ;
	
end architecture RTL;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CodeCheck is
	port (
		packet : in std_logic_vector(7 downto 0);
		result : out std_logic
	);
end entity CodeCheck;


architecture RTL of CodeCheck is
	signal res : boolean;
begin
	
	res <= (packet(7 downto 4) = not packet(3 downto 0)); 
	
	result <= '1' when res = TRUE else
			  '0';	
	
end architecture RTL;
