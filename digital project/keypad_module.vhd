library ieee;
use ieee.std_logic_1164.all;

entity keypad_module is
	port( clk_1k : in std_logic;
			resetn : in std_logic;
			buttonIn : in std_logic_vector(9 downto 0);
			code : out std_logic_Vector(9 downto 0));
			
end keypad_module;

architecture actions of keypad_module is
	SIGNAL CNT_SCAN : INTEGER RANGE 0 TO 9 := 0;
begin
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

	distinguish : process(clk_1k, cnt_scan)
	begin
		if clk_1k'event and clk_1k = '1' and buttonIn(0) = '1' then
			code <= "0000000001";
		elsif clk_1k'event and clk_1k = '1' and buttonIn(1) = '1' then
			code <= "0000000010";
		elsif clk_1k'event and clk_1k = '1' and buttonIn(2) = '1' then
			code <= "0000000100";
		elsif clk_1k'event and clk_1k = '1' and buttonIn(3) = '1' then
			code <= "0000001000";
		elsif clk_1k'event and clk_1k = '1' and buttonIn(4) = '1' then
			code <= "0000010000";
		elsif clk_1k'event and clk_1k = '1' and buttonIn(5) = '1' then
			code <= "0000100000";
		elsif clk_1k'event and clk_1k = '1' and buttonIn(6) = '1' then
			code <= "0001000000";
		elsif clk_1k'event and clk_1k = '1' and buttonIn(7) = '1' then
			code <= "0010000000";
		elsif clk_1k'event and clk_1k = '1' and buttonIn(8) = '1' then
			code <= "0100000000";
		elsif clk_1k'event and clk_1k = '1' and buttonIn(9) = '1' then
			code <= "1000000000";
		end if;
	end process;
end actions;