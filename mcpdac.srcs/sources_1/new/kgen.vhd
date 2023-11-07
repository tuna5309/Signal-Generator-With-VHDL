library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.NUMERIC_STD.ALL;

entity kgen is
port(
  i_reset                   :in  std_logic;
  i_clk                     :in  std_logic;
  i_buton_freq_up           :in  std_logic;
  i_buton_freq_down         :in  std_logic;
  s_CS                      :in  std_logic;
  i_buton_up_pwm            :in  std_logic;
  i_buton_down_pwm          :in  std_logic;
  o_sqout                   :out std_logic_vector(10 downto 0);
  o_square_freq             :out std_logic_vector(15 downto 0)
);
end kgen;

architecture kgendes of kgen is

attribute mark_debug              : string;

constant  freq_last               : integer:=1_000_000;
constant  qoutduty_lim            : integer:=100;

signal    frequ                   : integer range 0 to 100:= 20;
signal    freq                    : integer:=100_000_000;
signal    square_freq	          : integer:=0;
signal    pwm_duty                : integer range 0 to 100:=50;
signal    pwm_limit               : integer:=50;
signal    counter                 : integer:=0;
signal    cs_counter              : integer range 0 to 6;
signal    sqout                   : std_logic_vector (10 downto 0);
signal    high                    : integer :=1000;
signal    low                     : integer :=1000;
--------------------------------------------------------------
signal  i_buton_freq_up_d1        : std_logic;
signal  i_buton_freq_up_re        : std_logic;
signal  i_buton_freq_down_d1      : std_logic;
signal  i_buton_freq_down_re      : std_logic;
--------------------------------------------------------------
signal  i_buton_up_pwm_d1         : std_logic;
signal  i_buton_up_pwm_re         : std_logic;
signal  i_buton_down_pwm_d1       : std_logic;
signal  i_buton_down_pwm_re       : std_logic;
--------------------------------------------------------------
signal  s_CS_d1                   : std_logic;
signal  s_CS_re                   : std_logic;

signal  dividend_i                : std_logic_vector ( 19 downto 0 ) ;
signal  divisor_i                 : std_logic_vector ( 19 downto 0 ) ;

attribute mark_debug of counter: signal is "true";
attribute mark_debug of i_buton_down_pwm_re: signal is "true";
attribute mark_debug of i_buton_up_pwm_re: signal is "true";
attribute mark_debug of i_buton_freq_up_re: signal is "true";
attribute mark_debug of i_buton_freq_down_re: signal is "true";
attribute mark_debug of sqout: signal is "true";
attribute mark_debug of high: signal is "true"; 
attribute mark_debug of low: signal is "true";

type    square_state is (S_READY,S_1, S_0) ;
signal  squ_state      : square_state := S_READY; 

type    buton_freq_state   is (S_WAIT,S_UP,S_DOWN);  
signal  but_freq_state   : buton_freq_state :=S_WAIT;

type    buton_pwm_state   is (S_PWAIT,S_PUP,S_PDOWN);  
signal  but_pwm_state    : buton_pwm_state :=S_PWAIT;

begin                                                                                                                                                                         

process(i_clk) begin 
  if(i_reset='1') then 
    frequ     <= 20;
    high      <= 500;
    low       <= 500;
    
  else
   if (rising_edge(i_clk)) then
       
   --    pwm_limit   <=  qoutduty_lim - pwm_duty;
       low         <= (frequ* (qoutduty_lim - pwm_duty));
       high	       <= (frequ*pwm_duty);
       square_freq <= (100_000)/((frequ));
    	   	
	   i_buton_freq_down_d1           <=  i_buton_freq_down; 
	   i_buton_freq_down_re           <=  i_buton_freq_down and not i_buton_freq_down_d1;
	 
	   i_buton_freq_up_d1             <=  i_buton_freq_up; 
	   i_buton_freq_up_re             <=  i_buton_freq_up   and not i_buton_freq_up_d1; 
	  	   
	   case but_freq_state is   
	   when S_WAIT => 
		 if (i_buton_freq_up_re       = '1' ) then 
		   but_freq_state             <= S_UP; 
		 elsif (i_buton_freq_down_re  = '1' ) then 
           but_freq_state             <= S_DOWN;
         else
           but_freq_state             <= S_WAIT;
  	 end if;
  	 	 
	   when S_UP   =>                             	    
	     if ( frequ <= 5  ) then 
	       frequ                 <= 5;
	       but_freq_state        <= S_WAIT;   
         else 
	      frequ                  <= frequ -1;
	      but_freq_state         <= S_WAIT;   
	     end if; 
	                                             	                                               
	   when S_DOWN =>                                          
	     if ( frequ >= 20 ) then 
	       frequ                   <=20;
	       but_freq_state          <= S_WAIT;
	     else 
	       frequ                   <= frequ + 1;                           
           but_freq_state          <= S_WAIT; 
         end if;
      end case;                                
    end if;
   end if;                                     
end process;     

process(i_clk) begin 
  if(i_reset='1') then     
    pwm_duty <= 50;   
  else                     
   if (rising_edge(i_clk)) then 	   	
	   i_buton_down_pwm_d1 <=  i_buton_down_pwm; 
	   i_buton_down_pwm_re <=  i_buton_down_pwm and not i_buton_down_pwm_d1;
	   
	   i_buton_up_pwm_d1   <=  i_buton_up_pwm; 
	   i_buton_up_pwm_re   <=  i_buton_up_pwm   and not i_buton_up_pwm_d1; 
	  	   
	   case but_pwm_state is   
	   when S_PWAIT => 
		 if (i_buton_up_pwm_re        = '1' ) then 
		   but_pwm_state             <= S_PUP; 
		 elsif (i_buton_down_pwm_re   = '1' ) then 
           but_pwm_state             <= S_PDOWN;
         else
           but_pwm_state             <= S_PWAIT;  
  		 end if;
  	 	 
	   when S_PUP   =>       
	     if(pwm_duty >= 90) then
	       pwm_duty <= 90;
	     else
	       pwm_duty                    <= pwm_duty +1;
	     end if;                     
	       but_pwm_state               <= S_PWAIT; 
	                                             	                                               
	   when S_PDOWN =>    
	     if(pwm_duty <= 10) then
	       pwm_duty <= 10;
	     else
	       pwm_duty                    <= pwm_duty - 1;
	     end if;                                                                
         but_pwm_state                 <= S_PWAIT; 
     
      end case;                                
    end if;
   end if;                                    
end process;     

process (i_clk) begin 
if(i_reset='1') then 
  counter           <=0;
  squ_state         <= S_READY;
   
  else if (rising_edge (i_clk)) then 
	 s_CS_d1 <= s_CS;                 
     s_CS_re <= s_CS and not s_CS_d1;	  
	 
	  case squ_state is 
	   
	    when S_READY => 
	--   if(s_CS_re = '1') then
	        counter           <= 0;
            sqout             <= (others => '1');
	        squ_state         <= S_1;
	 --   else 
	--        squ_state         <= S_READY;
    --  end if;
          
          
	    when S_1 =>      
	 --     if(s_CS_re = '1') then
	        if(counter        < high-1) then
	           counter        <= counter +1;
               sqout          <= (others => '1'); 
	    	 else 
		       squ_state      <= S_0;
		  	   counter        <= 0;
		  	   sqout          <= (others => '0'); 
             end if;
      --    else 
      --  	squ_state         <= S_1;
		--  end if;
		
		  when S_0 =>		  
	--	    if(s_CS_re = '1') then 	   		
	    	  if(counter      <  low-1) then 
	    	    counter       <= counter +1;
	    	    sqout         <= (others => '0');
	    	  else 
	    	    squ_state     <= S_1;
	    	    counter       <= 0;
	    	    sqout         <= (others => '1');
	    	  end if;
	  --  	else 
	    --	  squ_state       <= S_0; 
     --   end if;
    end case;
   end if;
end if;
end process;
o_sqout       <=sqout ;
o_square_freq <= std_logic_vector(to_unsigned(square_freq,16)); -- square wave freq
end kgendes;
