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
		variable BitsLeft : integer range 0 to 9 := 0;
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

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_Rx is
	port( RxPin : in std_logic;
		  fast_clock : in std_logic;
		  sampling_clock : in std_logic;
		  sampling_clock_reset : out std_logic;
		  Data : out std_logic_vector(7 downto 0);
		  DataFlag : out std_logic;
		  TransmissionError : out std_logic
		);
end UART_Rx;

architecture RTL of UART_Rx is
	type State_t is (Idle, ResetOff, WaitForDataFlag);
	signal State_SamplingOut : State_t;
	signal DataFlag_sig : std_logic;
	signal timeout_wait : std_logic;
	signal timeout_occured : std_logic;
begin
	
	process(fast_clock) is
		variable last_in : std_logic;
		variable State : State_t;
	begin
		if( rising_edge(fast_clock) ) then
			
			sampling_clock_reset <= '0';
			case State is 
				when Idle =>
					if( last_in = '1' and RxPin = '0' ) then
						sampling_clock_reset <= '1';
						timeout_wait <= '1';
						State := ResetOff;
					end if;
				when ResetOff =>
					timeout_wait <= '0';
					sampling_clock_reset <= '0';
					State := WaitForDataFlag;
				when WaitForDataFlag =>
					timeout_wait <= '0';					
					if( DataFlag_sig = '1' ) then
						State := Idle;
					end if;
					if( timeout_occured = '1' ) then
						State := Idle;
					end if;
			end case;
			last_in := RxPin;
			State_SamplingOut <= State;
		end if;
	end process ;
	
	timeout_process : process(timeout_wait, sampling_clock) is
		variable waitt : integer range 0 to 10 := 0;
	begin
		if( timeout_wait = '1' ) then
			timeout_occured <= '0';
			waitt := 10;
		elsif( rising_edge(sampling_clock) ) then
			if( waitt > 0 ) then
				waitt := waitt-1;
			else
				timeout_occured <= '1';
			end if;
		end if;
	end process timeout_process;
	
	
	
	DataFlag <= DataFlag_sig;
	
	usart_recv: entity work.USART_Rx
		port map(RxPin             => RxPin,
			     RxSynchPin        => sampling_clock,
			     Data              => Data,
			     DataFlag          => DataFlag_sig,
			     TransmissionError => TransmissionError);
end;
