----------------- TX -------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity USART_Tx is
	port( TxPin : out std_logic;
		  TxSynchPin : out std_logic;
		  TxClock : in std_logic;
		  Data : in std_logic_vector(7 downto 0);
		  DataFlag : in std_logic;
		  TC : out std_logic);
end USART_Tx;

architecture RTL of USART_Tx is
type State_t is (Idle, Send);
signal StateOut : State_t;
begin
	TxSynchPin <= not TxClock;
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



----------------- RX -------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity USART_Rx is
	port( RxPin : in std_logic;
		  RxSynchPin : in std_logic;
		  Data : out std_logic_vector(7 downto 0);
		  DataFlag : out std_logic;
		  TransmissionError : out std_logic
		);
end USART_Rx;

architecture RTL of USART_Rx is
type State_t is (Idle, Receive, SetFlag, ClearFlag);
signal StateOut : State_t;
begin
	process(RxSynchPin) is
		variable DataRecv : std_logic_vector(9 downto 0);
		variable BitsLeft : natural := 0;
		variable State : State_t := Idle;
		variable last_input : std_logic;
	begin
		if( rising_edge(RxSynchPin) ) then
			case State is
				when Idle =>
					if last_input = '1' and RxPin = '0' then
						DataRecv(9) := RxPin;
						State := Receive;
						BitsLeft := 8;
					end if;
				when Receive =>
					DataRecv(BitsLeft) := RxPin;
					if( BitsLeft > 0 ) then
						BitsLeft := BitsLeft - 1;
					else --all data received
						if DataRecv(9) /= '0' or DataRecv(0) /= '1' then
							TransmissionError <= '1';
						end if;
						Data <= DataRecv(8 downto 1);
						State := SetFlag;
					end if;
				when SetFlag =>
					DataFlag <= '1';
					State := ClearFlag;
				when ClearFlag =>
					TransmissionError <= '0';
					DataFlag <= '0';
					State  := Idle;
			end case;
			StateOut <= State;
			last_input := RxPin;
		end if;
	end process;
end;

