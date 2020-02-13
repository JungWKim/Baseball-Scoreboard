LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY piezo IS

	PORT( resetn	: IN STD_LOGIC; 
			clk_100k		: IN STD_LOGIC;								-- 100kHz
			key			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);		-- push button no.10
			piezo			: BUFFER STD_LOGIC );						-- piezo sound data 
		
END piezo;



ARCHITECTURE sample OF piezo IS 

	CONSTANT LDO : INTEGER RANGE 0 TO 255 := 190;	-- 100000/261.6256/2-1
	CONSTANT RE : INTEGER RANGE 0 TO 255 := 169;		-- 100000/293.6648/2-1
	CONSTANT MI : INTEGER RANGE 0 TO 255 := 151;
	CONSTANT FA : INTEGER RANGE 0 TO 255 := 142;
	CONSTANT SO : INTEGER RANGE 0 TO 255 := 127;
	CONSTANT RA : INTEGER RANGE 0 TO 255 := 113;
	CONSTANT SI : INTEGER RANGE 0 TO 255 := 100;
	CONSTANT HDO : INTEGER RANGE 0 TO 255 := 95;		-- 100000/523.2511/2-1

	SIGNAL cnt	: INTEGER RANGE 0 TO 255;
	SIGNAL freq	: INTEGER RANGE 0 TO 255;
	
BEGIN


	PROCESS(key)
	BEGIN
		CASE key IS
			WHEN "00000001" => freq <= LDO;
			WHEN "00000010" => freq <= RE;
			WHEN "00000100" => freq <= MI;
			WHEN "00001000" => freq <= FA;
			WHEN "00010000" => freq <= SO;
			WHEN "00100000" => freq <= RA;
			WHEN "01000000" => freq <= SI;
			WHEN "10000000" => freq <= HDO;
			WHEN OTHERS 	 => freq <= 0;
		END CASE;
	END PROCESS;


	PROCESS(resetn, clk_100k)
	BEGIN
		IF resetn = '0' THEN
			cnt <= 0;
			piezo <= '0';
		ELSIF clk_100k'EVENT AND clk_100k = '1' THEN
			IF cnt >= freq THEN 
				cnt <= 0;
				piezo <= NOT piezo;
			ELSE
				cnt <= cnt + 1;
			END IF;
		END IF;
	END PROCESS;
	
	
END sample;