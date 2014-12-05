library ieee;
use ieee.std_logic_1164.all;
entity debouncer is
	generic (
		TicksBetweenEdges : integer := 10
	);
	port (
		input : in std_logic;
		output : out std_logic;
		clock : in std_logic
	);
end entity debouncer;

architecture RTL of debouncer is
	signal outBuffer : std_logic;
	type state_t is (Idle, Waiting);
	
	signal ticks_left : integer range 0 to TicksBetweenEdges := 0;
begin
	process(clock) is
		variable state : state_t := Idle;
	begin
		if( rising_edge(clock) ) then
			
			if( state = Waiting ) then
				if( ticks_left > 0 ) then
					ticks_left <= ticks_left-1;
				else
					state := Idle;
				end if;
			elsif( input /= outBuffer and state = Idle ) then
				outBuffer <= input;
				ticks_left <= TicksBetweenEdges;
				state := Waiting;
			end if;
		end if;		  
	end process ;
	
	output <= outBuffer;
		
end architecture RTL;
