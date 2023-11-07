library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;  

 entity sevensegment is
  Port (
          i_clk       : in std_logic;
          i_reset     : in std_logic;
          i_switch    : in std_logic_vector(3 downto 0 ) ;
          sine_freq   : in integer;
          trian_freq  : in integer;
          square_freq : in integer;
          sawgen_freq : in integer;
          sevendisp   : out std_logic_vector ( 6 downto 0); 
          sevencontro : out std_logic_vector ( 7 downto 0) 
   );
end sevensegment;

architecture Behavioral of sevensegment is

signal digit_4         : integer range 0 to 9;
signal digit_3         : integer range 0 to 9;
signal digit_2         : integer range 0 to 9;
signal digit_1         : integer range 0 to 9;
signal digit_0         : integer range 0 to 9;
signal LED_BCD         : integer range 0 to 9;
signal div_counter     : unsigned(23 downto 0);
signal AN_VECTOR       : std_logic_vector(2 downto 0);

signal value           : integer;
signal count           : integer:=1;
signal tmp             : std_logic:='0';
signal clock_out       : std_logic;

type    segment_state is (AN4,AN3,AN2,AN1,AN0) ;
signal  seg_state      : segment_state := AN0;
 
begin

digit_0 <=  value - ((value/10)*10);
digit_1 <= (value - ((value/100)*100))/10;
digit_2 <= (value - ((value/1000)*1000))/100;
digit_3 <= (value - ((value/10000)*10000))/1000;
digit_4 <= value/10000;

sevendisp     <=  "1000000" when LED_BCD = 0 else
                  "1111001" when LED_BCD = 1 else
                  "0100100" when LED_BCD = 2 else
                  "0110000" when LED_BCD = 3 else
                  "0011001" when LED_BCD = 4 else
                  "0010010" when LED_BCD = 5 else
                  "0000010" when LED_BCD = 6 else
                  "1111000" when LED_BCD = 7 else
                  "0000000" when LED_BCD = 8 else
                  "0010000" when LED_BCD = 9 else
                  "1000000";
                  
  value <= square_freq  when i_switch = "0001" else 
           sine_freq    when i_switch = "0010" else
           trian_freq   when i_switch = "0100" else
           sawgen_freq  when i_switch = "1000" else 
           0;               
                  
AN_VECTOR         <= std_logic_vector(div_counter(19 downto 17));           

process (i_clk) begin 
  if (rising_edge (i_clk)) then 		 
   case AN_VECTOR is 
     when "000" =>      
       sevencontro <= "11111110";
       LED_BCD     <= digit_0;
     when "001" =>                                   
       sevencontro <= "11111101";
       LED_BCD     <= digit_1;
     when "010" =>                            
       sevencontro <= "11111011"; 
       LED_BCD     <= digit_2;
     when "011" =>                   
       sevencontro <= "11110111"; 
       LED_BCD     <= digit_3;                
     when "101" =>                      
       sevencontro <= "11101111"; 
       LED_BCD     <= digit_4;  
     when others =>
       sevencontro <= "11111110";
       LED_BCD     <= digit_0;                     
     end case;
   end if;
 end process;
  
 process (i_clk) begin 
   if (rising_edge (i_clk)) then   
     if(i_reset = '1') then
       div_counter <= (others => '0');
     else
       div_counter <= div_counter + 1;      
   end if;
  end if;
  end process;
  
end Behavioral;
