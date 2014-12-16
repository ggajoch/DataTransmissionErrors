library ieee;
use ieee.std_logic_1164.all;

entity test_bench_display is
end test_bench_display;

architecture Test of test_bench_display is
	
	signal speed_string : string(8 downto 1) := "12345678";
	signal speed_dots : std_logic_vector(8 downto 1) := "00000000";
	
	signal actual_string : string(8 downto 1) := "--test--";
	signal actual_dots : std_logic_vector(8 downto 1) := "00000000";
	
	type displayStates is (Speed, Protocol, WaitTicks, Wait1sec, WelcomeSpeed, WelcomeProtocol, Welcome);
	signal buttonMiddleDebounced : std_logic := '0';
	signal clock_1kHz : std_logic;
begin
	
	
	process is
	begin
		for i in 1 to 500 loop
			clock_1kHz <= '0';
			wait for 10 ns;
			clock_1kHz <= '1';
			wait for 10 ns;
		end loop;
		
		buttonMiddleDebounced <= '1';
		wait for 10 ns;
		for i in 1 to 500 loop
			clock_1kHz <= '0';
			wait for 10 ns;
			clock_1kHz <= '1';
			wait for 10 ns;
		end loop; 
		buttonMiddleDebounced <= '0';
		wait for 10 ns;
	end process ;
	
	
	
	displayStateMaching : process(clock_1kHz) is
		variable State : displayStates := Welcome;
		variable StateAfterWait : displayStates;
		variable ticks_left : integer := 0;
		variable last_change_button : std_logic := '1';
		variable middle_pressed : boolean := FALSE;
	begin
		if( rising_edge(clock_1kHz) ) then
			middle_pressed := ( last_change_button = '0' and buttonMiddleDebounced = '1' );
			actual_dots <= (others => '0'); 
			case State is
				when Speed =>
					actual_dots <= speed_dots;
					actual_string <= speed_string;
					if( middle_pressed ) then
						State := WelcomeProtocol;
					end if;
				when Protocol =>
					actual_string <= "prot-val";
					if( middle_pressed ) then
						State := WelcomeSpeed;
					end if;
				when WelcomeSpeed =>
					actual_string <= "-speed--";
					StateAfterWait := Speed;
					State := Wait1sec;
				when WelcomeProtocol =>
					actual_string <= "--prot--";
					StateAfterWait := Protocol;
					State := Wait1sec;
				when Welcome =>
					actual_string <= "-hello--";
					StateAfterWait := WelcomeSpeed;
					State := Wait1sec;
				when Wait1sec => 
					ticks_left := 99;
					State := WaitTicks;
				when WaitTicks =>
					if( ticks_left > 0 ) then
						ticks_left := ticks_left-1;
					else
						State := StateAfterWait;
					end if;
			end case;
			last_change_button := buttonMiddleDebounced;
		end if;
	end process displayStateMaching;
end architecture Test;
