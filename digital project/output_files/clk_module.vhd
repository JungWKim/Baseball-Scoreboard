library ieee; 
use ieee.std_logic_1164.all; 

entity clk_module is

	port(		clk_100k		: in std_logic;					-- 100kHz
				reset		: in std_logic;
				clk_10k	: buffer std_logic;					-- 10kHz
				clk_1k		: buffer std_logic);				-- 1kHz
		
end clk_module;


architecture clk_module of clk_module is
begin

-------------------------------------------------------------generate 1kHz
	P1K : process(clk_100k, reset)
	
		variable	cnt : integer range 0 to 49;
	
	begin
		if( reset = '0' ) then
			cnt := 0;
			clk_1k <= '0' ;
		elsif( clk_100k'event and clk_100k ='1' ) then
			if( cnt = 49 ) then
				cnt := 0;
				clk_1k <= not clk_1k;
			else
				cnt := cnt + 1;
			end if;
		end if;
	end process;
--------------------------------------------------------------


	

--------------------------------------------------------------generate 10kHz	
	P10K : process(clk_100k, reset)
	
		variable	cnt : integer range 0 to 4;
	
	begin
		if( reset = '0' ) then
			cnt := 0;
			clk_10k <= '0' ;
		elsif( clk_100k'event and clk_100k ='1' ) then
			if( cnt = 4 ) then
				cnt := 0;
				clk_10k <= not clk_10k;
			else
				cnt := cnt + 1;
			end if;
		end if;
	end process;
--------------------------------------------------------------
	
end clk_module;