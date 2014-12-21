library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity main is
	port (
		digits : out std_logic_vector(7 downto 0);
		segments : out std_logic_vector(7 downto 0);
		buttonMiddleRaw : in std_logic;
		buttonLeftRaw : in std_logic;
		buttonRightRaw : in std_logic;
		buttonUpRaw : in std_logic;
		buttonDownRaw : in std_logic;
		switchesRaw : in std_logic_vector(7 downto 0);
		LED : out std_logic_vector(7 downto 0);
		out_clock : out std_logic;
		uart_out : out std_logic;
		clock_100MHz : in std_logic
	);
end entity main;

architecture RTL of main is
signal clock_1MHz : std_logic;
signal clock_1kHz : std_logic;
signal clock_10Hz : std_logic;
signal clock_1Hz : std_logic;

signal buttonMiddle : std_logic;
signal buttonLeft : std_logic;
signal buttonRight : std_logic;
signal buttonUp : std_logic;
signal buttonDown : std_logic;

signal prescaler_value : integer range 0 to 10**8 := 1;
signal clock_prescaled : std_logic;

signal uart_data : std_logic_vector(7 downto 0) := "00000000";
signal uart_TC : std_logic := '0';

signal actual_string : string(8 downto 1);
signal actual_dots : std_logic_vector(8 downto 1);

signal protocol_sel : integer range 0 to 99;
signal speed_integer : integer range 0 to 99;
signal speed_exponent : integer range 0 to 9;

COMPONENT selectio_wiz_0
  PORT (
    data_out_to_pins : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    clk_in : IN STD_LOGIC;
    clk_div_in : IN STD_LOGIC;
    data_out_from_device : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    clk_reset : IN STD_LOGIC;
    io_reset : IN STD_LOGIC;
    clk_to_pins : OUT STD_LOGIC
  );
END COMPONENT;

signal uart_out_vec : std_logic_vector(0 downto 0);
signal clock_1kHzBuf: std_logic;
begin
	
	LED(0) <= clock_1Hz;

    uart_out <= uart_out_vec(0);

    presc_in_buf : BUFG
       port map
        (O   => clock_1kHzBuf,
         I   => clock_1kHz);

selectIOTest : selectio_wiz_0
  PORT MAP (
    data_out_to_pins => uart_out_vec,
    clk_in => clock_1kHzBuf,
    clk_div_in => clock_1kHzBuf,
    data_out_from_device => "1011000101",
    clk_reset => '0',
    io_reset => '0',
    clk_to_pins => out_clock
  );
--------------- PRESCALERS ------------------------------------
                   
    prescaler1M : entity work.prescaler
        port map(clk_input => clock_100MHz,
                 clk_output => clock_1MHz,
                 reset => '0',
                 presc => 100);
    prescaler1k : entity work.prescaler
         port map(clk_input => clock_1MHz,
                  clk_output => clock_1kHz,
                  reset => '0',
                  presc => 1000);
	prescaler10 : entity work.prescaler
           port map(clk_input => clock_1kHz,
                    clk_output => clock_10Hz,
                    reset => '0',
                    presc => 100);
    prescaler1 : entity work.prescaler
           port map(clk_input => clock_1kHz,
                    clk_output => clock_1Hz,
                    reset => '0',
                    presc => 1000);

end architecture RTL;

