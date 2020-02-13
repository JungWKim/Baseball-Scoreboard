LIBRARY IEEE; 
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; 

ENTITY seg_7 IS 

	PORT(	CLK_100k : IN STD_LOGIC;									-- 1kHz
			round : IN STD_LOGIC_VECTOR(7 DOWNTO 0);				-- round_count
			SEG_DATA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)	);		-- 7-SEGMENT DATA 
			
END seg_7; 


ARCHITECTURE seg_7 OF seg_7 IS 

	function dec_7_seg( inbin : STD_LOGIC_VECTOR(7 downto 0) ) return std_logic_vector is	-- 7 segment decoder
			
		variable	res : std_logic_vector(7 downto 0);
		
	begin

		case inbin is
			when "00000001" => res := "00000110"; 		--1
			when "00000010" => res := "10000110"; 		--1.
			when "00000011" => res := "01011011"; 		--2
			when "00000100" => res := "11011011"; 		--2.
			when "00000101" => res := "01001111"; 		--3
			when "00000110" => res := "11001111"; 		--3.
			when "00000111" => res := "01100110"; 		--4
			when "00001000" => res := "11100110"; 		--4.
			when "00001001" => res := "01101101"; 		--5
			when "00010001" => res := "11101101"; 		--5.
			when "00010010" => res := "01111101"; 		--6
			when "00010011" => res := "11111101"; 		--6.
			when "00010100" => res := "00000111"; 		--7
			when "00010101" => res := "10000111"; 		--7.
			when "00010110" => res := "01111111"; 		--8
			when "00010111" => res := "11111111"; 		--8.
			when "00011000" => res := "01101111"; 		--9
			when "00011001" => res := "11101111"; 		--9.
			when others     => res := "01110001";
		end case;
		
		return res;

	end dec_7_seg;
	
BEGIN

	process(clk_100k)														-- display isolated 7 segment
	begin
		if clk_100k'event and clk_100k = '1' then
			seg_data <= dec_7_seg(round);
		end if;
	end process;

END seg_7;