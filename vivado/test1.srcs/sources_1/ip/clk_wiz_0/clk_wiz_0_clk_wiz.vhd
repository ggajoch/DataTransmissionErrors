-- file: clk_wiz_0_clk_wiz.vhd
-- 
-- (c) Copyright 2008 - 2013 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
------------------------------------------------------------------------------
-- User entered comments
------------------------------------------------------------------------------
-- None
--
------------------------------------------------------------------------------
--  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
--   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
------------------------------------------------------------------------------
-- CLK_OUT1___194.961______0.000______50.0______234.074____403.233
-- CLK_OUT2___174.653______0.000______50.0______237.555____403.233
-- CLK_OUT3___149.702______0.000______50.0______242.526____403.233
-- CLK_OUT4___130.990______0.000______50.0______246.924____403.233
-- CLK_OUT5___209.583______0.000______50.0______231.817____403.233
-- CLK_OUT6___116.435______0.000______50.0______250.875____403.233
--
------------------------------------------------------------------------------
-- Input Clock   Freq (MHz)    Input Jitter (UI)
------------------------------------------------------------------------------
-- __primary_________100.000____________0.010

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity clk_wiz_0_clk_wiz is
port
 (-- Clock in ports
  clk_in1           : in     std_logic;
  -- Clock out ports
  clk_out1          : out    std_logic;
  clk_out2          : out    std_logic;
  clk_out3          : out    std_logic;
  clk_out4          : out    std_logic;
  clk_out5          : out    std_logic;
  clk_out6          : out    std_logic
 );
end clk_wiz_0_clk_wiz;

architecture xilinx of clk_wiz_0_clk_wiz is
  -- Input clock buffering / unused connectors
  signal clk_in1_clk_wiz_0      : std_logic;
  -- Output clock buffering / unused connectors
  signal clkfbout_clk_wiz_0         : std_logic;
  signal clkfboutb_unused : std_logic;
  signal clk_out1_clk_wiz_0          : std_logic;
  signal clkout0b_unused         : std_logic;
  signal clk_out2_clk_wiz_0          : std_logic;
  signal clkout1b_unused         : std_logic;
  signal clk_out3_clk_wiz_0          : std_logic;
  signal clkout2b_unused         : std_logic;
  signal clk_out4_clk_wiz_0          : std_logic;
  signal clkout3b_unused  : std_logic;
  signal clk_out5_clk_wiz_0          : std_logic;
  signal clk_out6_clk_wiz_0          : std_logic;
  signal clkout6_unused   : std_logic;
  -- Dynamic programming unused signals
  signal do_unused        : std_logic_vector(15 downto 0);
  signal drdy_unused      : std_logic;
  -- Dynamic phase shift unused signals
  signal psdone_unused    : std_logic;
  signal locked_int : std_logic;
  -- Unused status signals
  signal clkfbstopped_unused : std_logic;
  signal clkinstopped_unused : std_logic;

begin


  -- Input buffering
  --------------------------------------
  clkin1_ibufg : IBUF
  port map
   (O => clk_in1_clk_wiz_0,
    I => clk_in1);



  -- Clocking PRIMITIVE
  --------------------------------------
  -- Instantiation of the MMCM PRIMITIVE
  --    * Unused inputs are tied off
  --    * Unused outputs are labeled unused
  mmcm_adv_inst : MMCME2_ADV
  generic map
   (BANDWIDTH            => "OPTIMIZED",
    CLKOUT4_CASCADE      => FALSE,
    COMPENSATION         => "ZHOLD",
    STARTUP_WAIT         => FALSE,
    DIVCLK_DIVIDE        => 6,
    CLKFBOUT_MULT_F      => 62.875,
    CLKFBOUT_PHASE       => 0.000,
    CLKFBOUT_USE_FINE_PS => FALSE,
    CLKOUT0_DIVIDE_F     => 5.375,
    CLKOUT0_PHASE        => 0.000,
    CLKOUT0_DUTY_CYCLE   => 0.500,
    CLKOUT0_USE_FINE_PS  => FALSE,
    CLKOUT1_DIVIDE       => 6,
    CLKOUT1_PHASE        => 0.000,
    CLKOUT1_DUTY_CYCLE   => 0.500,
    CLKOUT1_USE_FINE_PS  => FALSE,
    CLKOUT2_DIVIDE       => 7,
    CLKOUT2_PHASE        => 0.000,
    CLKOUT2_DUTY_CYCLE   => 0.500,
    CLKOUT2_USE_FINE_PS  => FALSE,
    CLKOUT3_DIVIDE       => 8,
    CLKOUT3_PHASE        => 0.000,
    CLKOUT3_DUTY_CYCLE   => 0.500,
    CLKOUT3_USE_FINE_PS  => FALSE,
    CLKOUT4_DIVIDE       => 5,
    CLKOUT4_PHASE        => 0.000,
    CLKOUT4_DUTY_CYCLE   => 0.500,
    CLKOUT4_USE_FINE_PS  => FALSE,
    CLKOUT5_DIVIDE       => 9,
    CLKOUT5_PHASE        => 0.000,
    CLKOUT5_DUTY_CYCLE   => 0.500,
    CLKOUT5_USE_FINE_PS  => FALSE,
    CLKIN1_PERIOD        => 10.0)
  port map
    -- Output clocks
   (
    CLKFBOUT            => clkfbout_clk_wiz_0,
    CLKFBOUTB           => clkfboutb_unused,
    CLKOUT0             => clk_out1_clk_wiz_0,
    CLKOUT0B            => clkout0b_unused,
    CLKOUT1             => clk_out2_clk_wiz_0,
    CLKOUT1B            => clkout1b_unused,
    CLKOUT2             => clk_out3_clk_wiz_0,
    CLKOUT2B            => clkout2b_unused,
    CLKOUT3             => clk_out4_clk_wiz_0,
    CLKOUT3B            => clkout3b_unused,
    CLKOUT4             => clk_out5_clk_wiz_0,
    CLKOUT5             => clk_out6_clk_wiz_0,
    CLKOUT6             => clkout6_unused,
    -- Input clock control
    CLKFBIN             => clkfbout_clk_wiz_0,
    CLKIN1              => clk_in1_clk_wiz_0,
    CLKIN2              => '0',
    -- Tied to always select the primary input clock
    CLKINSEL            => '1',
    -- Ports for dynamic reconfiguration
    DADDR               => (others => '0'),
    DCLK                => '0',
    DEN                 => '0',
    DI                  => (others => '0'),
    DO                  => do_unused,
    DRDY                => drdy_unused,
    DWE                 => '0',
    -- Ports for dynamic phase shift
    PSCLK               => '0',
    PSEN                => '0',
    PSINCDEC            => '0',
    PSDONE              => psdone_unused,
    -- Other control and status signals
    LOCKED              => locked_int,
    CLKINSTOPPED        => clkinstopped_unused,
    CLKFBSTOPPED        => clkfbstopped_unused,
    PWRDWN              => '0',
    RST                 => '0');


  -- Output buffering
  -------------------------------------



  clkout1_buf : BUFG
  port map
   (O   => clk_out1,
    I   => clk_out1_clk_wiz_0);



  clkout2_buf : BUFG
  port map
   (O   => clk_out2,
    I   => clk_out2_clk_wiz_0);

  clkout3_buf : BUFG
  port map
   (O   => clk_out3,
    I   => clk_out3_clk_wiz_0);

  clkout4_buf : BUFG
  port map
   (O   => clk_out4,
    I   => clk_out4_clk_wiz_0);

  clkout5_buf : BUFG
  port map
   (O   => clk_out5,
    I   => clk_out5_clk_wiz_0);

  clkout6_buf : BUFG
  port map
   (O   => clk_out6,
    I   => clk_out6_clk_wiz_0);

end xilinx;
