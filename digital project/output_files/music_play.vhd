LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY music_play IS

	PORT( resetn : IN STD_LOGIC; 
			clk_100k : IN STD_LOGIC;										-- 100kHz
			button9 : in std_logic;											-- push button no.10
			piezo_out : OUT STD_LOGIC );									-- output : piezo sound
		
END music_play;


ARCHITECTURE sample OF music_play IS 

	COMPONENT piezo 
		PORT (	resetn	: IN STD_LOGIC;
					clk_100k	: IN STD_LOGIC;								-- 100kHz
					key	: IN STD_LOGIC_VECTOR(7 DOWNTO 0);			-- frequency data
					piezo	: OUT STD_LOGIC );
	END COMPONENT;
	
	SIGNAL	cnt100K		: integer range 0 to 49999;
	SIGNAL	cnt_tempo		: integer range 0 to 63;
	SIGNAL	base_tempo		: std_logic;
	SIGNAL	key		: std_logic_vector(7 DOWNTO 0);
	
BEGIN

	sound : Piezo PORT MAP (resetn, clk_100k, key, piezo_out);
	
	
	mk_tempo : PROCESS(resetn, clk_100k)
	BEGIN
		IF( resetn = '0' ) THEN
			cnt100k <= 0;
		ELSIF (clk_100k'EVENT and clk_100k='1') THEN
			IF( cnt100k /= 9999 ) THEN
				cnt100k <= cnt100k + 1;
			ELSE
				cnt100k <= 0;
				base_tempo <= not base_tempo;
			END IF;
		END IF;
	END process;
	
	
	PROCESS(resetn, base_tempo)
	BEGIN
		IF( resetn = '0' ) THEN
			cnt_tempo <= 0;
		ELSIF (base_tempo'EVENT and base_tempo='1') THEN
			IF( cnt_tempo /= 12 ) THEN
				cnt_tempo <= cnt_tempo + 1;
			ELSE
				cnt_tempo <= 0;
			END IF;
		END IF;
	END process;

	
	rom : PROCESS(cnt_tempo)
	BEGIN
		if  ( button9 = '1') then							-- when button is pressed, play the music
			CASE cnt_tempo iS
				WHEN 0 => key <= "00010000";
				WHEN 1 => key <= "01000000";
				WHEN 2 => key <= "00010000";
				WHEN 3 => key <= "00000010";
				WHEN 4 => key <= "00000010";
				WHEN 5 => key <= "00000001";
				WHEN 6 => key <= "00000100";
				WHEN 7 => key <= "00001000";
				WHEN 8 => key <= "00100000";
				WHEN 9 => key <= "00000001";
				WHEN others => key <= "00000000";
			end case;
		else
			CASE cnt_tempo iS
				WHEN 0 => key <= "00000000";
				WHEN others => key <= "00000000";
			end case;
		end if;
	END process;
	
	
END sample;

