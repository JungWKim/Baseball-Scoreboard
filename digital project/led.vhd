library ieee;
use ieee.std_logic_1164.all;

entity led is
	port( button : in std_logic_vector(9 downto 0);
			led : out std_logic_vector(6 downto 0);
			clk_1k : in std_logic);
end led;

architecture example of led is
	SIGNAL CNT_SCAN : INTEGER RANGE 0 TO 7 := 0;
begin
	count : process(button)
		variable strike_count : integer range 0 to 3 := 0;
		variable ball_count : integer range 0 to 4 := 0;
		variable out_count : integer range 0 to 3 := 0;
	begin
		if button = "0000000001" then
			strike_count := strike_count + 1;
			if strike_count = 3 then
				strike_count := 2;
			end if;
		elsif cnt_scan = 7 and button = "0010000000" then
			strike_count := strike_count - 1;
		end if;
		
		if strike_count = 0 then
			led(0) <= '0';
			led(1) <= '0';
		elsif strike_count = 1 then
			led(0) <= '1';
			led(1) <= '0';
		elsif strike_count = 2 then
			led(0) <= '1';
			led(1) <= '1';
		elsif strike_count = 3 then
			led(0) <= '1';
			led(1) <= '1';
		else
			led(0) <= '0';
			led(1) <= '0';
		end if;
	end process;
	
	clk : PROCESS(CLK_1k) 
	BEGIN 
		IF CLK_1k'EVENT AND CLK_1k = '1' THEN 
			IF CNT_SCAN /= 9 THEN  
				CNT_SCAN <= CNT_SCAN + 1; 
			else
				cnt_scan <= 0;
			END IF; 
		END IF; 
	END PROCESS;
	
end example;