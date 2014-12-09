LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity TxTest is
	port( TxPin : out std_logic;
		  TxClock : in std_logic;
		  Data : in std_logic_vector(7 downto 0);
		  DataFlag : in std_logic;
		  TC : out std_logic);
end TxTest;

architecture TxTest_arch of TxTest is
type State_t is (Idle, Send);
signal StateOut : State_t;
begin
	
	process(TxClock) is
		variable DataToSend : std_logic_vector(9 downto 0);
		variable BitsLeft : natural := 0;
		variable last_flag : std_logic;
		variable State : State_t := Idle;
	begin
		if( rising_edge(TxClock) ) then
			if( last_flag = '0' and DataFlag = '1' and State = Idle ) then
				DataToSend := '0' & Data & '1';
				State := Send;
				BitsLeft := DataToSend'high;
			end if;
			TC <= '0';
			case State is
				when Idle =>
					TxPin <= '1';
					TC <= '1';
				when Send =>
					TxPin <= DataToSend(BitsLeft);
					if( BitsLeft > 0 ) then
						BitsLeft := BitsLeft - 1;
					else
						State := Idle;
					end if;
			end case;
			last_flag := DataFlag;
			StateOut <= State;
		end if;
	end process;
end;