library ieee;
use ieee.std_logic_1164.all;

entity test_bench_uartTx is
end test_bench_uartTx;

architecture Test of test_bench_uartTx is
	
	signal TxPin : std_logic;
	signal TxClock : std_logic := '0';
	signal Data : std_logic_vector(0 to 7);
	signal DataFlag : std_logic := '0';
	signal TC : std_logic;
	
begin
	uart_inst : entity work.UART_Tx
		port map(TxPin    => TxPin,
			     TxClock  => TxClock,
			     Data     => Data,
			     DataFlag => DataFlag,
			     TC       => TC);
		
		     
			     
	uartTx : process is
	begin
		Data <= "10101010";
		for i in 0 to 15 loop
			TxClock <= '1';
			wait for 10 ns;
			TxClock <= '0';
			wait for 10 ns;
		end loop;
		
		DataFlag <= '1';
		wait for 10 ns;
		TxClock <= '1';
		wait for 10 ns;
		TxClock <= '0';
		wait for 10 ns;
		DataFlag <= '0';
		
		Data <= "00000000";
		
		for i in 0 to 15 loop
			TxClock <= '1';
			wait for 10 ns;
			TxClock <= '0';
			wait for 10 ns;
		end loop;
		
		DataFlag <= '1';
		wait for 10 ns;
		TxClock <= '1';
		wait for 10 ns;
		TxClock <= '0';
		wait for 10 ns;
		DataFlag <= '0';
		
	end process uartTx;
	
end architecture Test;
