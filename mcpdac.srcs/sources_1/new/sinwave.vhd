library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity sinwave is
  generic ( 
    NUM_POINT     : integer:=64;
    MAX_AMPLITUDE : integer:=2047);
  port    ( 
    i_clk                 : in  std_logic;
    i_reset               : in  std_logic;
    i_buton_freq_up       : in  std_logic; 
    i_buton_freq_down     : in  std_logic; 
    s_CS                  : in  std_logic;
    o_sin_data            : out std_logic_vector(10 downto 0);
    o_sin_freq            : out integer );
end sinwave;

architecture Behavioral of sinwave is
 
attribute mark_debug : string;

type    sin_state is (S_READY,S_1QUART,S_2QUART,S_3QUART,S_4QUART) ;
signal  sin_quarter_state   : sin_state := S_READY; 

type    buton_state   is (S_WAIT,S_UP,S_DOWN) ;  
signal  but_state   : buton_state :=S_WAIT;

signal  sin_index                 : integer range 0 to NUM_POINT;
signal  sin_data                  : std_logic_vector(10 downto 0) ;
signal  s_CS_d1                   : std_logic;
signal  s_CS_re                   : std_logic;
signal  freq_control              : integer range 1 to 10:=1;
signal  i_buton_freq_up_d1        : std_logic;
signal  i_buton_freq_up_re        : std_logic;
signal  i_buton_freq_down_d1      : std_logic;
signal  i_buton_freq_down_re      : std_logic;
signal  sin_freq                  : integer:=0;




type memory is array  ( 0 to (NUM_POINT)-1) of integer range 0 to MAX_AMPLITUDE;
signal sine:memory:=(1024,1049,1074,1099,1124,1149,1174,1198,
1223,1248,1272,1296,1321,1345,1368,1392,
1415,1438,1461,1484,1506,1528,1550,1571,
1592,1613,1633,1653,1673,1692,1711,1729,
1747,1765,1782,1799,1815,1830,1846,1860,
1875,1888,1901,1914,1926,1938,1949,1959,
1969,1978,1987,1995,2003,2010,2016,2022,
2027,2032,2036,2039,2042,2044,2046,2047);

attribute mark_debug of sin_index  :  signal is "true";
attribute mark_debug of sin_data   :  signal is "true";

begin

sin_freq <= (100_000_000) / (166*(256/freq_control));


process(i_clk) begin 
  if(i_reset='1') then 
    freq_control <= 1;
  else  
   if (rising_edge(i_clk)) then 	   	
	   i_buton_freq_down_d1 <=  i_buton_freq_down; 
	   i_buton_freq_down_re <=  i_buton_freq_down and not i_buton_freq_down_d1;
	   
	   i_buton_freq_up_d1   <=  i_buton_freq_up; 
	   i_buton_freq_up_re   <=  i_buton_freq_up   and not i_buton_freq_up_d1; 
	  	   
	   case but_state is   
	   when S_WAIT => 
		 if (i_buton_freq_up_re      = '1' ) then 
		   but_state                <= S_UP; 
		 elsif (i_buton_freq_down_re  = '1' ) then 
           but_state                <= S_DOWN;
         else
           freq_control             <= freq_control ;
  		 end if;

  	 	 
	   when S_UP   =>                                 
	     freq_control               <= freq_control +1;
	     but_state                  <= S_WAIT; 
	                                             	                                               
	   when S_DOWN =>                                         
	     freq_control               <= freq_control -1;                           
       but_state                    <= S_WAIT; 
     
      end case;                                
    end if;
   end if;                                     
end process;        


  process (i_clk) begin
  if(i_reset='1') then 
	   sin_quarter_state  <=  S_READY;
	   sin_index          <=  0;
	   
  else 
    if (rising_edge (i_clk)) then
      s_CS_d1 <= s_CS;
   	  s_CS_re <= s_CS and not s_CS_d1;	
    
 	case sin_quarter_state is 
    
    when S_READY =>   
      if(s_CS_re = '1') then
        sin_quarter_state              <= S_1QUART;
        sin_data                       <= std_logic_vector(to_unsigned(sine(sin_index),sin_data'length));
        sin_index                      <=  0;       
      else 
        sin_quarter_state              <= S_READY;        
        sin_index                      <=  0;  
      end if;

    when S_1QUART =>  
       if(s_CS_re = '1') then
         if ( sin_index = NUM_POINT-1 or sin_index+freq_control > NUM_POINT-1  ) then
           sin_index                   <= 62;
           sin_data                    <= std_logic_vector(to_unsigned(sine(sin_index-1),sin_data'length));
           sin_quarter_state           <= S_2QUART;          
         else
           sin_data                    <= std_logic_vector(to_unsigned(sine(sin_index+freq_control),sin_data'length));
           sin_index                   <= sin_index + freq_control;
         end if;
          
         end if;    		

    when S_2QUART => 
      if(s_CS_re = '1') then
        if ( sin_index = 0  or sin_index-freq_control < 0) then
          sin_index                     <= freq_control;
          sin_data                      <= std_logic_vector(to_unsigned(2048-sine(sin_index+1),sin_data'length));
          sin_quarter_state             <= S_3QUART;           
        else                            
          sin_data                      <= std_logic_vector(to_unsigned(sine(sin_index-freq_control),sin_data'length));
          sin_index                     <= sin_index - freq_control;           
          end if;
        end if;  
      
     when S_3QUART => 
   		 if(s_CS_re = '1') then	
   		 	 if ( sin_index =  NUM_POINT-1 or sin_index+freq_control > NUM_POINT-1) then
   		 	   sin_index                <= 62;
  		 	   sin_data                 <= std_logic_vector(to_unsigned(2048-sine(sin_index-1),sin_data'length));
   		 	   sin_quarter_state        <= S_4QUART;                   
             else                                                                                                                                                  
               sin_data                 <= std_logic_vector(to_unsigned(2048-sine(sin_index+freq_control),sin_data'length));      
               sin_index                <= sin_index + freq_control;                                                                                        
           end if;
         end if;   	
 
   
      when S_4QUART => 
        if(s_CS_re = '1') then
          if ( sin_index = 0 or sin_index-freq_control < 0) then
   		 	sin_index                   <=freq_control;
   		 	sin_data                    <= std_logic_vector(to_unsigned(sine(sin_index+1),sin_data'length));
   		 	sin_quarter_state           <= S_1QUART;                   
          else        	                         
            sin_data                    <= std_logic_vector(to_unsigned(2048-sine(sin_index-freq_control),sin_data'length));      
            sin_index                   <= sin_index -freq_control ;                                                                                       
         end if;   	
       end if; 
     end case;
   end if;
 end if;
end process;

o_sin_data <= sin_data;
o_sin_freq <= sin_freq; -- sine signal freq 
end behavioral;  
