library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clockController is
	port (
		speed_integer : in integer range 10 to 99;
		speed_exp : in integer range 0 to 9;
		clock_100MHz : in std_logic;
		clock_out : out std_logic;
		reset_presc : in std_logic
	);
end entity clockController;


architecture RTL of clockController is
	type LUT_Sources_t is array(10 to 729) of integer;
	signal LUT_Sources : LUT_Sources_t := (1, 5, 2, 2, 4, 2, 1, 5, 3, 2, 1, 8, 4, 4, 2, 1, 2, 5, 4, 3, 2, 1, 1, 5, 5, 4, 3, 1, 2, 2, 1, 3, 5, 1, 1, 3, 8, 1, 2, 1, 1, 4, 2, 1, 5, 2, 4, 7, 7, 2, 2, 5, 1, 5, 1, 2, 4, 4, 5, 3, 4, 5, 3, 1, 1, 2, 1, 1, 2, 6, 1, 1, 3, 3, 6, 5, 1, 4, 3, 1, 3, 1, 8, 2, 6, 1, 2, 3, 8, 1, 1, 5, 2, 2, 4, 2, 1, 5, 3, 5, 1, 1, 4, 3, 2, 1, 2, 4, 4, 5, 2, 5, 1, 3, 5, 4, 3, 7, 2, 2, 1, 8, 8, 3, 1, 3, 3, 8, 2, 7, 1, 7, 2, 1, 6, 2, 4, 6, 5, 1, 2, 1, 5, 8, 1, 2, 1, 7, 5, 2, 4, 7, 3, 1, 7, 2, 2, 2, 2, 3, 1, 5, 6, 1, 5, 5, 7, 5, 3, 1, 3, 3, 1, 5, 1, 6, 2, 6, 6, 1, 1, 5, 2, 2, 4, 2, 1, 5, 3, 1, 1, 1, 4, 4, 2, 1, 2, 8, 4, 8, 2, 6, 1, 5, 5, 4, 3, 3, 5, 2, 1, 8, 1, 6, 1, 3, 2, 6, 2, 8, 1, 6, 2, 1, 8, 2, 4, 3, 5, 2, 2, 5, 6, 1, 1, 2, 4, 4, 5, 1, 4, 2, 3, 4, 2, 2, 2, 1, 2, 4, 1, 8, 8, 3, 8, 5, 6, 1, 3, 8, 3, 1, 2, 6, 1, 4, 2, 3, 8, 1, 1, 5, 2, 2, 4, 2, 1, 5, 3, 6, 1, 6, 4, 1, 2, 1, 2, 5, 4, 1, 2, 3, 1, 3, 5, 4, 3, 1, 1, 2, 1, 1, 1, 3, 1, 3, 4, 4, 2, 6, 1, 6, 2, 5, 5, 2, 4, 2, 3, 4, 2, 6, 6, 1, 1, 2, 1, 2, 5, 1, 4, 1, 3, 3, 1, 2, 5, 1, 2, 5, 1, 7, 2, 2, 1, 5, 5, 1, 3, 6, 3, 1, 8, 7, 4, 7, 2, 1, 6, 1, 1, 5, 2, 2, 4, 2, 1, 5, 3, 4, 1, 6, 4, 6, 2, 1, 2, 4, 4, 4, 2, 3, 1, 5, 5, 4, 3, 7, 6, 2, 1, 1, 6, 5, 1, 3, 3, 7, 2, 8, 1, 2, 2, 8, 6, 2, 4, 6, 5, 2, 2, 7, 5, 7, 1, 2, 4, 2, 5, 1, 4, 2, 3, 1, 7, 2, 1, 2, 2, 3, 1, 4, 1, 8, 1, 5, 8, 4, 3, 8, 3, 3, 3, 3, 5, 5, 3, 6, 8, 1, 1, 5, 2, 2, 4, 2, 1, 5, 3, 7, 1, 5, 4, 8, 2, 1, 2, 8, 4, 8, 2, 4, 1, 3, 5, 4, 3, 3, 4, 2, 1, 3, 6, 2, 1, 3, 4, 3, 3, 6, 1, 3, 2, 7, 8, 2, 4, 4, 8, 2, 2, 3, 2, 2, 1, 2, 1, 1, 5, 2, 4, 3, 3, 1, 2, 2, 6, 1, 2, 4, 1, 6, 3, 1, 6, 5, 4, 1, 3, 5, 3, 1, 2, 1, 3, 1, 3, 2, 2, 1, 1, 5, 2, 2, 4, 2, 1, 5, 3, 5, 1, 8, 4, 1, 3, 1, 2, 5, 4, 1, 2, 1, 1, 5, 5, 4, 3, 1, 7, 2, 1, 8, 5, 1, 1, 3, 1, 2, 3, 8, 1, 8, 2, 4, 5, 2, 6, 1, 1, 3, 2, 3, 3, 5, 6, 2, 4, 2, 5, 1, 4, 2, 3, 4, 1, 2, 4, 1, 2, 7, 1, 5, 6, 2, 6, 5, 8, 1, 3, 1, 3, 1, 4, 1, 6, 2, 8, 6, 1, 1, 1, 5, 3, 2, 4, 2, 1, 5, 3, 1, 1, 1, 4, 2, 3, 1, 2, 4, 2, 6, 2, 5, 6, 3, 5, 4, 3, 7, 5, 2, 1, 8, 8, 7, 4, 3, 6, 6, 5, 2, 1, 3, 3, 6, 6, 2, 2, 1, 4, 4, 3, 3, 8, 8, 6, 2, 1, 1, 5, 4, 4, 3, 3, 3, 7, 7, 7, 2, 2, 1, 1, 1, 8, 8, 8, 5, 5, 4, 4, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2);
	type LUT_Dividers_t is array(10 to 729) of integer;
	signal LUT_Dividers : LUT_Dividers_t := (400000000, 309090909, 325000000, 300000000, 250000000, 260000000, 250000000, 200000000, 200000000, 205263158, 200000000, 119047619, 159090909, 152173913, 162500000, 160000000, 150000000, 125925926, 125000000, 124137931, 130000000, 129032258, 125000000, 103030303, 100000000, 100000000, 100000000, 108108108, 102631579, 100000000, 100000000, 87804878, 80952381, 93023256, 90909091, 80000000, 54347826, 85106383, 81250000, 81632653, 80000000, 68627451, 75000000, 75471698, 62962963, 70909091, 62500000, 52631579, 51724138, 66101695, 65000000, 55737705, 64516129, 53968254, 62500000, 60000000, 53030303, 52238806, 50000000, 52173913, 50000000, 47887324, 50000000, 54794521, 54054054, 52000000, 52631579, 51948052, 50000000, 40506329, 50000000, 49382716, 43902439, 43373494, 38095238, 40000000, 46511628, 40229885, 40909091, 44943820, 40000000, 43956044, 27173913, 41935484, 34042553, 42105263, 40625000, 37113402, 25510204, 40404040, 40000000, 30909091, 32500000, 30000000, 25000000, 26000000, 25000000, 20000000, 20000000, 17894737, 20000000, 19047619, 15909091, 15652174, 16250000, 16000000, 15000000, 12962963, 12500000, 11724138, 13000000, 10967742, 12500000, 10909091, 10000000, 10000000, 10000000, 8108108, 10263158, 10000000, 10000000, 6097561, 5952381, 8372093, 9090909, 8000000, 7826087, 5319149, 8125000, 6122449, 8000000, 5882353, 7500000, 7547170, 5925926, 7090909, 6250000, 5614035, 5862069, 6779661, 6500000, 6557377, 5483871, 3968254, 6250000, 6000000, 6060606, 4477612, 5000000, 5652174, 5000000, 4225352, 5000000, 5479452, 4054054, 5200000, 5131579, 5064935, 5000000, 4556962, 5000000, 4197531, 3902439, 4819277, 4047619, 4000000, 3488372, 3908046, 4090909, 4494382, 4000000, 3956044, 4347826, 3655914, 4255319, 3368421, 4062500, 3298969, 3265306, 4040404, 4000000, 3090909, 3250000, 3000000, 2500000, 2600000, 2500000, 2000000, 2000000, 2105263, 2000000, 1904762, 1590909, 1521739, 1625000, 1600000, 1500000, 925926, 1250000, 862069, 1300000, 1032258, 1250000, 1030303, 1000000, 1000000, 1000000, 972973, 894737, 1000000, 1000000, 609756, 952381, 744186, 909091, 800000, 847826, 680851, 812500, 510204, 800000, 627451, 750000, 754717, 462963, 709091, 625000, 631579, 586207, 661017, 650000, 557377, 516129, 634921, 625000, 600000, 530303, 522388, 500000, 579710, 500000, 549296, 500000, 479452, 527027, 520000, 513158, 519481, 500000, 443038, 500000, 308642, 304878, 433735, 297619, 400000, 372093, 459770, 409091, 280899, 400000, 439560, 423913, 344086, 425532, 368421, 406250, 371134, 255102, 404040, 400000, 309091, 325000, 300000, 250000, 260000, 250000, 200000, 200000, 168421, 200000, 152381, 159091, 173913, 162500, 160000, 150000, 125926, 125000, 137931, 130000, 116129, 125000, 109091, 100000, 100000, 100000, 108108, 105263, 100000, 100000, 97561, 95238, 83721, 90909, 80000, 76087, 74468, 81250, 65306, 80000, 62745, 75000, 64151, 62963, 70909, 62500, 68421, 62069, 59322, 65000, 52459, 51613, 63492, 62500, 60000, 60606, 58209, 50000, 57971, 50000, 56338, 50000, 49315, 54054, 52000, 44737, 51948, 50000, 43038, 50000, 37037, 47561, 46988, 47619, 40000, 39535, 45977, 40909, 35955, 40000, 43956, 27174, 32258, 37234, 31579, 40625, 41237, 32653, 40404, 40000, 30909, 32500, 30000, 25000, 26000, 25000, 20000, 20000, 18421, 20000, 15238, 15909, 13913, 16250, 16000, 15000, 12963, 12500, 12069, 13000, 11613, 12500, 10303, 10000, 10000, 10000, 8108, 8421, 10000, 10000, 9756, 7619, 7907, 9091, 8000, 7826, 6383, 8125, 5102, 8000, 7647, 7500, 4717, 5926, 7091, 6250, 5614, 5862, 6610, 6500, 4918, 5484, 4762, 6250, 6000, 5303, 5821, 5000, 5797, 5000, 5493, 5000, 5479, 4054, 5200, 5263, 5065, 5000, 4557, 5000, 4321, 4878, 3012, 4762, 4000, 2907, 4023, 4091, 2809, 4000, 3956, 3913, 3871, 3617, 3579, 3750, 3299, 2551, 4040, 4000, 3091, 3250, 3000, 2500, 2600, 2500, 2000, 2000, 1579, 2000, 1619, 1591, 1087, 1625, 1600, 1500, 926, 1250, 862, 1300, 1129, 1250, 1091, 1000, 1000, 1000, 973, 921, 1000, 1000, 878, 762, 907, 909, 800, 761, 766, 750, 653, 800, 706, 750, 566, 463, 709, 625, 614, 431, 661, 650, 590, 629, 619, 625, 600, 606, 597, 500, 565, 500, 507, 500, 548, 527, 520, 421, 519, 500, 443, 500, 395, 439, 482, 381, 400, 407, 460, 409, 382, 400, 440, 424, 430, 383, 421, 375, 402, 398, 404, 400, 309, 325, 300, 250, 260, 250, 200, 200, 179, 200, 119, 159, 174, 150, 160, 150, 126, 125, 138, 130, 129, 125, 103, 100, 100, 100, 108, 79, 100, 100, 61, 81, 93, 91, 80, 87, 83, 75, 51, 80, 49, 75, 66, 63, 71, 57, 70, 69, 61, 65, 59, 58, 54, 50, 60, 53, 58, 50, 58, 50, 55, 50, 48, 54, 52, 46, 52, 50, 38, 50, 42, 39, 47, 38, 40, 29, 46, 41, 45, 40, 44, 38, 43, 34, 41, 26, 33, 41, 40, 40, 31, 30, 30, 25, 26, 25, 20, 20, 21, 20, 19, 16, 17, 15, 16, 15, 13, 14, 11, 13, 11, 10, 11, 10, 10, 10, 8, 9, 10, 10, 6, 6, 7, 8, 8, 7, 7, 7, 8, 8, 7, 7, 6, 6, 7, 7, 7, 6, 6, 6, 6, 4, 4, 5, 6, 6, 6, 5, 5, 5, 5, 5, 5, 4, 4, 4, 5, 5, 5, 5, 5, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4);
	
	
	--400e6, 390e6, 360e6, 350e6, 340e6, 320e6, 300e6, 250e6
	signal PLL_vals : std_logic_vector(1 to 8);
	
	signal presc_in : std_logic;
	signal presc_out : std_logic;
	signal presc_rst : std_logic;
	signal presc_val : integer;
	signal index : integer range 10 to 730;
begin
	
	--------------- PLL -----------------
	
	PLL_vals <= clock_100MHz & clock_100MHz & clock_100MHz & clock_100MHz & clock_100MHz & clock_100MHz & clock_100MHz & clock_100MHz;
	
	------------- PRESCALER -------------
	
	index <= speed_integer + 90*speed_exp;
	presc_in <= PLL_vals(LUT_Sources(index));
	presc_val <= LUT_Dividers(index);

	presc_rst <= reset_presc;
	
	presc_inst : entity work.prescaler
		port map(clk_input  => presc_in,
			     clk_output => presc_out,
			     reset      => presc_rst,
			     presc      => presc_val);
	
	
	------------- BUFG -----------------
	clock_out <= presc_out;
	
	

end architecture RTL;