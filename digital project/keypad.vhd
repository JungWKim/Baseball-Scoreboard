library ieee;
use ieee.std_logic_1164.all;

entity keypad is

	port( led_on : out std_logic_vector(6 downto 0); -- leds
			button : in std_logic_vector(10 downto 0); -- 11 push buttons
			dip0 : in std_logic;	-- dip switch No.1
			
			resetn_all : in std_logic; 					 -- reset button
			clk_100k_signal : in std_logic; 				 -- others come from this clock
			piezo_again : buffer std_logic; 				 -- piezo speaker
			 
			servo_again : out std_logic; 					 -- servo motor
			
			seg_com_out : out std_logic_vector(7 downto 0);  -- array fnd common select
			seg_data_out : out std_logic_vector(7 downto 0); -- array fnd data
			
			seg_7_out: out std_logic_vector(7 downto 0) ); 	 -- isolated 7 segment
			
end keypad;

architecture keypad_arch of keypad is

	----------------------------------------------------------------------automatic music play
	component music_play 
	
		PORT( resetn : IN STD_LOGIC; 
				clk_100k : IN STD_LOGIC;								-- 100kHz
				button9 : in std_logic; 								-- push button no.10(home run!)
				piezo_out : OUT STD_LOGIC ); 							-- output : sound
				
	end component;
	----------------------------------------------------------------------
	
	
	
	----------------------------------------------------------------------generation clocks from 'clk_100k_signal'
	component clk_module
	
		port(
				clk_100k		: in std_logic; 							-- input 100kHz
				reset			: in std_logic;
				clk_10k		: buffer std_logic; 						-- generate 10kHz
				clk_1k		: buffer std_logic ); 					-- generate 1kHz
				
	end component;
	----------------------------------------------------------------------
	
	
	
	----------------------------------------------------------------------move the pivot of servo motor
	component servo_motor
	
		port( resetn : in std_logic;
			   clk_10k : in std_logic;									-- 10kHz
			   button9 : in std_logic; 								-- push button no.10(home run!)
			   servo : out std_logic); 								-- output : degree of servo motor
				
	end component;
	----------------------------------------------------------------------
	
	
	
	----------------------------------------------------------------------array fnd display
	component D_7SEG
	
		PORT(	CLK_1k : IN STD_LOGIC;									-- 1kHz
		
				away_score : in std_logic_Vector(7 downto 0);	-- away team score
				home_score : in std_logic_Vector(7 downto 0);	-- home team score
		
				SEG_COM : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);		-- 7-SEGMENT COMMON SELECT 
				SEG_DATA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) );	
				
	end component;
	----------------------------------------------------------------------
	
	
	
	----------------------------------------------------------------------isolated 7 segment display
	component seg_7
	
		PORT(	CLK_100k : IN STD_LOGIC;									-- 1kHz
				round : IN STD_LOGIC_VECTOR(7 DOWNTO 0);				-- count how many times you pushed button no.11
				SEG_DATA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)	);		-- round data
				
	end component;
	----------------------------------------------------------------------
	
	signal clk_10k_signal : std_logic;									-- 10kHz
	signal clk_1k_signal : std_logic;									-- 1kHz
	
	signal away_team : std_logic_vector(7 downto 0);				-- away_digit10 & away_digit1
	signal home_team : std_logic_Vector(7 downto 0);				-- home_digit10 & home_digit1
	signal round_count : std_logic_Vector(7 downto 0);				-- transfer to seg_7.vhdl
	
	signal away_digit10 : std_logic_Vector(3 downto 0);			-- tenth digit of away score
	signal away_digit1 : std_logic_vector(3 downto 0);				-- units digit of away score
	signal home_digit10 : std_logic_Vector(3 downto 0);			-- tenth digit of home score
	signal home_digit1 : std_logic_vector(3 downto 0);				-- units digit of home score
	
	signal plus1, plus2, plus3 : std_logic;							-- flag of push button no.4,5,6
											
	signal button3_d, button3_dd, button4_d, button4_dd, button5_d, button5_dd : std_logic;			-- delay buffers of push button no.4,5,6
	
	signal strike_plus1, strike_minus1  : std_logic;				-- flag of plus/minus 1 point of strike
	signal ball_plus1, ball_minus1  : std_logic; 					-- flag of plus/minus 1 point of ball
	signal out_plus1, out_minus1   : std_logic;						-- flag of plus/minus 1 point of out
	
	signal button0_d, button0_dd, button1_d, button1_dd, button2_d, button2_dd, button6_d, button6_dd, button7_d, button7_dd, button8_d, button8_dd : std_logic; -- delay buffers of push button no.1,2,3,7,8,9
	
	
	signal away_score, home_score : integer := 0;					-- away team score & home team score
	signal digit10 : integer range 0 to 9;								-- common tenth digit buffer
	signal digit1 : integer range 0 to 9;								-- common units digit buffer
	
	signal strike_count, out_count, ball_count : integer := 0;  -- the number of strike, ball and out
	
	signal up_flag, down_flag, transition_flag, round_flag : std_logic;	-- up_flag : rising edge of dip switch
																								-- down_flag : falling edge of dip switch
																								-- transition_flag : only detect the change of dip switch
																								-- round_flag : rising edge of push button no.11
																								
	signal status_d, status_dd, round_d, round_dd : std_logic;				-- status_d, status_dd : delay buffer of dip switch
																								-- round_d, round_dd : delay buffer of push button no.11
	
begin

-------------------------------------------------------------------------------generate flags to plus or minus strike_count
	strike_flag : process(clk_100k_signal)
	begin
	
	
		if(rising_edge(clk_100k_signal)) then						-- when button no.1 is pressed
			button0_d <= button(0);
			button0_dd <= button0_d;
		end if;
		
		if(rising_edge(clk_100k_signal)) then						-- when button no.7 is pressed
			button6_d <= button(6);
			button6_dd <= button6_d;
		end if;
		
		strike_plus1 <= button0_d and not button0_dd;			-- generate a flag to plus 1strike
		strike_minus1 <= button6_d and not button6_dd;			-- generate a flag to minus 1strike
		

	end process;
-------------------------------------------------------------------------------
	
	
	

-------------------------------------------------------------------------------generate flags to plus or minus ball_count
	ball_flag : process(clk_100k_signal)
	begin
	
	
		if(rising_edge(clk_100k_signal)) then						-- when button no.2 is pressed
			button1_d <= button(1);
			button1_dd <= button1_d;
		end if;
		
		if(rising_edge(clk_100k_signal)) then						-- when button no.8 is pressed
			button7_d <= button(7);
			button7_dd <= button7_d;
		end if;
		
		ball_plus1 <= button1_d and not button1_dd;				-- generate a flag to plus 1ball
		ball_minus1 <= button7_d and not button7_dd;				-- generate a flag to minus 1ball

		
	end process;
--------------------------------------------------------------------------------	
	
	
	

--------------------------------------------------------------------------------generate flags to plus or minus out_count
	out_flag : process(clk_100k_signal)
	begin
	
	
		if(rising_edge(clk_100k_signal)) then						-- when button no.3 is pressed
			button2_d <= button(2);
			button2_dd <= button2_d;
		end if;
		
		if(rising_edge(clk_100k_signal)) then						-- when button no.9 is pressed
			button8_d <= button(8);
			button8_dd <= button8_d;
		end if;
		
		out_plus1 <= button2_d and not button2_dd;				-- generate a flag to plus 1out	
		out_minus1 <= button8_d and not button8_dd;				-- generate a flag to minus 1out

		
	end process;
---------------------------------------------------------------------------------	
	
	
	
	
---------------------------------------------------------------------------------
	led_control : process(button)
	begin
	
	
		if(rising_edge(clk_100k_signal)) then
			
			if transition_flag = '1' then						-- when dip switch's flag is detected, reset every count
				strike_count <= 0;
				ball_count <= 0;
				out_count <= 0;
			end if;
			
			
---------------------------------------------------------------strike processing part

			if(strike_plus1 = '1') then						-- when strike_plus1 is detected, increment strike_count
				strike_count <= strike_count + 1;
			end if;
			
			if (strike_minus1 = '1') then						-- when strike_minus1 is detected, decrement strike_count
				strike_count <= strike_count - 1;
			end if;
			
			if strike_count > 2 then
				if out_count = 2 then							-- when strike and out count are already full, no more change in strike and out leds
					strike_count <= 2;
				else													-- when out is not full counted but strike occurs 3 times, increment out_count
					strike_count <= 0;
					out_count <= out_count + 1;
				end if;
			elsif strike_count < 0 then						-- keep strike_count from 0 to 2
				strike_count <= 0;
			end if;
			
			if(strike_count = 1) then							
				led_on(0) <= '1';
				led_on(1) <= '0';
			elsif(strike_count = 2) then
				led_on(0) <= '1';									-- light on led no.1, 2 depending on strike_count
				led_on(1) <= '1';
			else
				led_on(0) <= '0';
				led_on(1) <= '0';
			end if;
			
			
---------------------------------------------------------------ball processing part

			if(ball_plus1 = '1') then							-- when ball_plus1 is detected, increment ball_count
				ball_count <= ball_count + 1;
			end if;
			
			if (ball_minus1 = '1') then						-- when ball_minus1 is detected, decrement ball_count
				ball_count <= ball_count - 1;
			end if;
			
			if ball_count > 3 then								-- keep ball_count from 0 to 3
				ball_count <= 3;
			elsif ball_count < 0 then
				ball_count <= 0;
			end if;
			
			if(ball_count = 1) then
				led_on(2) <= '1';
				led_on(3) <= '0';
				led_on(4) <= '0';
			elsif(ball_count = 2) then
				led_on(2) <= '1';
				led_on(3) <= '1';
				led_on(4) <= '0';									-- light on led no. 3, 4, 5 depending on ball_count
			elsif(ball_count = 3) then
				led_on(2) <= '1';
				led_on(3) <= '1';
				led_on(4) <= '1';
			else
				led_on(2) <= '0';
				led_on(3) <= '0';
				led_on(4) <= '0';
			end if;
----------------------------------------------------------------out processing part

			if(out_plus1 = '1') then							-- when out_plus1 is detected, increment out_count
				out_count <= out_count + 1;
			end if;
			
			if (out_minus1 = '1') then							-- when out_minus1 is detected, decrement out_count
				out_count <= out_count - 1;
			end if;
			
			if out_count > 2 then								-- keep out_count from 0 to 2
				out_count <= 2;
			elsif out_count < 0 then
				out_count <= 0;
			end if;
			
			if(out_count = 1) then
				led_on(5) <= '1';
				led_on(6) <= '0';
			elsif(out_count = 2) then
				led_on(5) <= '1';									-- light on led no.6, 7 depending on out_count
				led_on(6) <= '1';
			else
				led_on(5) <= '0';
				led_on(6) <= '0';
			end if;

		end if;
	end process;
------------------------------------------------------------------
	
	
	
	
------------------------------------------------------------------generate a flag to plus 1 point to any score
	point_1_flag : process(clk_100k_signal)
	begin
	
		if(rising_edge(clk_100k_signal)) then				-- when button no.4 is pressed
			button3_d <= button(3);
			button3_dd <= button3_d;
		end if;
		
		plus1 <= button3_d and not button3_dd;
		
	end process;
-------------------------------------------------------------------




-------------------------------------------------------------------generate a flag to plus 2 points to any score
	point_2_flag : process(clk_100k_signal)
	begin
		if(rising_edge(clk_100k_signal)) then
			button4_d <= button(4);								-- when button no.5 is pressed
			button4_dd <= button4_d;
		end if;
		
		plus2 <= button4_d and not button4_dd;
		
	end process;
--------------------------------------------------------------------




--------------------------------------------------------------------generate a flag to plus 3 points to any score	
	point_3_flag : process(clk_100k_signal)
	begin
		if(rising_edge(clk_100k_signal)) then
			button5_d <= button(5);								-- when button no.6 is pressed
			button5_dd <= button5_d;
		end if;
		
		plus3 <= button5_d and not button5_dd;
		
	end process;
--------------------------------------------------------------------




--------------------------------------------------------------------		
	score2seg : process(button)
	begin
		if(rising_edge(clk_100k_signal)) then
			if dip0 = '1' then
				if plus1 = '1' then
					away_score <= away_score + 1;
				end if;
			
				if plus2 = '1' then
					away_score <= away_score + 2;					-- increment away_score depending on flags
				end if;
			
				if plus3 = '1' then
					away_score <= away_score + 3;
				end if;
				
				if away_score > 99 then								-- keep away_score from 0 to 99
					away_score <= 0;
				end if;
				
				digit10 <= away_score / 10;						-- decide away_digit10
				case digit10 is
					when 0 => away_digit10 <= "0000";
					when 1 => away_digit10 <= "0001";
					when 2 => away_digit10 <= "0010";
					when 3 => away_digit10 <= "0011";
					when 4 => away_digit10 <= "0100";
					when 5 => away_digit10 <= "0101";
					when 6 => away_digit10 <= "0110";
					when 7 => away_digit10 <= "0111";
					when 8 => away_digit10 <= "1000";
					when 9 => away_digit10 <= "1001";
				end case;
			
				digit1 <= away_score mod 10;						-- decide away_digit1
				case digit1 is
					when 0 => away_digit1 <= "0000";
					when 1 => away_digit1 <= "0001";
					when 2 => away_digit1 <= "0010";
					when 3 => away_digit1 <= "0011";
					when 4 => away_digit1 <= "0100";
					when 5 => away_digit1 <= "0101";
					when 6 => away_digit1 <= "0110";
					when 7 => away_digit1 <= "0111";
					when 8 => away_digit1 <= "1000";
					when 9 => away_digit1 <= "1001";
				end case;
				
			else
				if plus1 = '1' then									
					home_score <= home_score + 1;
				end if;
			
				if plus2 = '1' then
					home_score <= home_score + 2;					-- increment home_score depending on flags
				end if;
			
				if plus3 = '1' then
					home_score <= home_score + 3;
				end if;
				
				if home_score > 99 then								-- keep home_score from 0 to 99
					home_score <= 0;
				end if;
				
				digit10 <= home_score / 10;						-- decide home_digit10
				case digit10 is
					when 0 => home_digit10 <= "0000";
					when 1 => home_digit10 <= "0001";
					when 2 => home_digit10 <= "0010";
					when 3 => home_digit10 <= "0011";
					when 4 => home_digit10 <= "0100";
					when 5 => home_digit10 <= "0101";
					when 6 => home_digit10 <= "0110";
					when 7 => home_digit10 <= "0111";
					when 8 => home_digit10 <= "1000";
					when 9 => home_digit10 <= "1001";
				end case;
			
				digit1 <= home_score mod 10;						-- decide home_digit1
				case digit1 is
					when 0 => home_digit1 <= "0000";
					when 1 => home_digit1 <= "0001";
					when 2 => home_digit1 <= "0010";
					when 3 => home_digit1 <= "0011";
					when 4 => home_digit1 <= "0100";
					when 5 => home_digit1 <= "0101";
					when 6 => home_digit1 <= "0110";
					when 7 => home_digit1 <= "0111";
					when 8 => home_digit1 <= "1000";
					when 9 => home_digit1 <= "1001";
				end case;
				
			end if;
			
			away_team <= away_digit10 & away_digit1;				-- assemble digit10 and digit1
			home_team <= home_digit10 & home_digit1;
			
		end if;
	end process;
-----------------------------------------------------------------------





-----------------------------------------------------------------------generate a flag to increment round_count
	round_change_flag : process(button(10))
	begin
		if(rising_edge(clk_100k_signal)) then
			round_d <= button(10);
			round_dd <= round_d;
		end if;
		
		round_flag <= round_d and not round_dd;
		
	end process;
-----------------------------------------------------------------------





-----------------------------------------------------------------------decide data which will be sent to isolated 7 segment
	seg_7_process : process(dip0)

		variable count : integer := 1;
		
	begin
		if rising_edge(clk_100k_signal) then
			if round_flag = '1' then
				count := count + 1;
				if count > 18 then								-- keep count from 1 to 18
					count := 1;
				end if;
			end if;
			
			if count = 1 then
				round_count <= "00000001";
			elsif count = 2 then
				round_count <= "00000010";
			elsif count = 3 then
				round_count <= "00000011";
			elsif count = 4 then
				round_count <= "00000100";
			elsif count = 5 then
				round_count <= "00000101";
			elsif count = 6 then
				round_count <= "00000110";
			elsif count = 7 then
				round_count <= "00000111";
			elsif count = 8 then
				round_count <= "00001000";
			elsif count = 9 then
				round_count <= "00001001";
			elsif count = 10 then
				round_count <= "00010001";
			elsif count = 11 then
				round_count <= "00010010";
			elsif count = 12 then
				round_count <= "00010011";
			elsif count = 13 then
				round_count <= "00010100";
			elsif count = 14 then
				round_count <= "00010101";
			elsif count = 15 then
				round_count <= "00010110";
			elsif count = 16 then
				round_count <= "00010111";
			elsif count = 17 then
				round_count <= "00011000";
			elsif count = 18 then
				round_count <= "00011001";
			else
				round_count <= "11111111";
			end if;
		end if;
	end process;
----------------------------------------------------------------------




----------------------------------------------------------------------generate transition flag only when the change of dip switch occurs(0 -> 1 or 1 -> 0)
	switch_detect : process(dip0)
	begin
	
		if rising_edge(clk_100k_signal) then
			status_d <= dip0;
			status_dd <= status_d;
			up_flag <= status_d and not status_dd;
			down_flag <= not status_d and status_dd;
			
			if up_flag = '1' or down_flag = '1' then
				transition_flag <= '1';
			else
				transition_flag <= '0';
			end if;
		end if;
		
	end process;
----------------------------------------------------------------------
	
	
	
	sound_map : music_play port map(resetn_all, clk_100k_signal, button(9), piezo_again);
	clk_module_map : clk_module port map(clk_100k_signal, resetn_all, clk_10k_signal, clk_1k_signal);
	servo_motor_map : servo_motor port map(resetn_all, clk_10k_signal, button(9), servo_again);
	array_FND_map : D_7SEG port map(clk_1k_signal, away_team, home_team , seg_com_out, seg_data_out);
	seg_7_map : seg_7 port map(clk_100k_signal, round_count, seg_7_out);
	
	
	
end keypad_arch;