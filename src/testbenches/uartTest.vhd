library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test_bench_usart is
end test_bench_usart;

architecture Test of test_bench_usart is
	signal clk : std_logic;
	signal clk_presc : std_logic;
	signal reset_presc : std_logic;
	signal clk_send : std_logic;
	
	signal send_data : std_logic_vector(7 downto 0);
	signal TxPin : std_logic;
	signal TC : std_logic;
	signal Data : std_logic_vector(7 downto 0);
	signal DataFlag : std_logic;
	signal TransmissionError : std_logic;
	signal clk_recv : std_logic;
	
begin

	clock_proc : process is
	begin
		clk <= '1';
		wait for 1 ns;
		clk <= '0';
		wait for 1 ns;
	end process clock_proc;
	
	
	presc_inst : entity work.prescaler
		generic map(max_presc => 30)
		port map(clk_input  => clk,
			     clk_output => clk_presc,
			     reset      => '0',
			     presc      => 10);
	
	send_clock : entity work.prescaler
		generic map(max_presc => 1000)
		port map(clk_input  => clk_presc,
			     clk_output => clk_send,
			     reset      => '0',
			     presc      => 20);
	
	send_data_proc : process(clk_send) is
		variable x : std_logic_vector(7 downto 0) := (others => '0');
	begin
		if( rising_edge(clk_send) ) then
			send_data <= x;
			x := x+1;
		end if;
	end process send_data_proc;
	
	
	sender_inst : entity work.UART_Tx
		port map(TxPin    => TxPin,
			     TxClock  => clk_presc,
			     Data     => send_data,
			     DataFlag => clk_send,
			     TC       => TC);
	
	
	recv_clock : entity work.prescaler
		generic map(max_presc => 1000)
		port map(clk_input  => clk,
			     clk_output => clk_recv,
			     reset      => reset_presc,
			     presc      => 10);		     
			     
	recv_inst : entity work.UART_Rx
		port map(RxPin                => TxPin,
			     fast_clock           => clk,
			     sampling_clock       => clk_recv,
			     sampling_clock_reset => reset_presc,
			     Data                 => Data,
			     DataFlag             => DataFlag,
			     TransmissionError    => TransmissionError);
end architecture Test;
