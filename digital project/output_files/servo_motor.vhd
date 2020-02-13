library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity servo_motor is

	port(		resetn : in std_logic;
				clk_10k : in std_logic;						-- 10kHz
				button9 : in std_logic;						-- push button no.10
				servo : out std_logic);						-- degree of servo motor
		  
end servo_motor;


architecture dc_servo of servo_motor is

	signal cnt : integer range 0 to 199;
	signal val : integer range 0 to 100 := 7;
	
begin


	p_cnt : process(resetn, clk_10k)
	begin
	
		if resetn = '0' then
			cnt <= 0;
		elsif clk_10k'event and clk_10k = '1' then
			if cnt >= 199 then
				cnt <= 0;
			else
				cnt <= cnt+1;
			end if;
		end if;

	end process;
		
		
	val <= 15 WHEN resetn  = '0' ELSE
			  7 WHEN button9  = '0' ELSE					-- when button is released, 0 degree
			 23 WHEN button9  = '1'; 						-- when button is pressed, 180 degree
				  
	servo <= '1'  WHEN cnt < val ELSE '0';
	
	
end dc_servo;