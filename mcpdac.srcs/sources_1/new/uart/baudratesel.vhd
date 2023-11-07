library ieee;
use ieee.STD_LOGIC_1164.ALL;
use ieee.NUMERIC_STD.ALL;

entity baudsel is 
generic(
	clk_freq  :  integer := 100_000_000
);
     port(
     switch    : in  std_logic_vector(2 downto 0) ; 
     baudgen   : out integer
     );
end baudsel;

  architecture tuna of baudsel is 

    begin
    
    baudgen <=	      clk_freq/2400   when switch = "000" ELSE
                      clk_freq/4800   when switch = "001" ELSE
                      clk_freq/9600   when switch = "010" ELSE
                      clk_freq/19200  when switch = "011" ELSE
                      clk_freq/57600  when switch = "100" ELSE
                      clk_freq/76800  when switch = "101" ELSE
                      clk_freq/115200 when switch = "110" ELSE
                      clk_freq/230400 when switch = "111";

    end tuna;