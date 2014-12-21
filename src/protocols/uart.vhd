LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity UART_Tx is
	port( TxPin : out std_logic;
		  TxClock : in std_logic;
		  Data : in std_logic_vector(7 downto 0);
		  DataFlag : in std_logic;
		  TC : out std_logic);
end UART_Tx;

architecture RTL of UART_Tx is
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


-------------------------- RX -------------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity UART_Rx is
	port( RxPin : in std_logic;
			data : out std_logic_vector(0 to 7);
			DataFlag : out std_logic;
			DataFlagRst : in std_logic;
			clk : in std_logic;
			dbg_wire : out std_logic);
end UART_Rx;
architecture RxTest_arch of UART_Rx is
type State_t is (Idle, StartBit, Capture, NearChange, StopBit);
signal State : State_t;
signal StateBegin : State_t;
signal RxClock : std_logic;
signal RstCnt : std_logic := '0';

signal dbg_wire_state : std_logic := '0';
begin
	
	presc0 : entity work.prescaler(prescaler_arch)
		port map(clk, RxClock, RstCnt, 25);--27 > 2604);
	
	process(DataFlagRst, RxPin, RxClock) is
	variable BitsLeft : natural := 0;
	begin
		if( DataFlagRst = '1' ) then 
			DataFlag <= '0';
		elsif( RxPin = '0' and State = Idle ) then
			RstCnt <= '0';
			State <= StartBit;
		elsif( rising_edge(RxClock) ) then
			case State is
				when Idle =>
					RstCnt <= '1';
				when StartBit =>
					--DataFlag <= '0';
					RstCnt <= '0';
					State <= NearChange;
					BitsLeft := 8;
				when Capture =>
					if( BitsLeft > 0 ) then
						dbg_wire <= dbg_wire_state;
						dbg_wire_state <= not dbg_wire_state;
						data(BitsLeft-1) <= RxPin;
						BitsLeft := BitsLeft-1;
						State <= NearChange;
					else
						State <= StopBit;
					end if;
				when NearChange =>
					State <= Capture;
				when StopBit =>
					State <= Idle;
					DataFlag <= '1';
				when others =>
					State <= Idle;
			end case;
		end if;
	end process;
end architecture;
