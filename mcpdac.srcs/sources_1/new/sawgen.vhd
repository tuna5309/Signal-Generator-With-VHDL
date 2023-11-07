library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity sawgen is
  generic ( 
    SAW_MAX_AMPLITUDE : integer:=2047);
  port (
    i_clk                    : in std_logic;
    i_reset                  : in std_logic;
    i_saw_switch             : in std_logic;
    i_buton_freq_up          : in std_logic; 
    i_buton_freq_down        : in std_logic; 
    s_CS                     : in std_logic;
    o_trian_data             : out std_logic_vector(10 downto 0);
    o_sawgen_freq             : out integer);
end sawgen;

architecture Behavioral of sawgen is

type    saw_state is (S_RIGHT,S_LEFT) ;
signal  sawgen_state   : saw_state;

type    buton_state   is (S_WAIT,S_UP,S_DOWN) ;  
signal  but_state   : buton_state :=S_WAIT;     

signal  s_CS_d1                   : std_logic;
signal  s_CS_re                   : std_logic;
signal  saw_index                 : integer range 0 to 2047;
signal  out_data                  : std_logic_vector (10 downto 0);
signal  none                      : std_logic;
signal  freq_control              : integer range 1 to 10:=1;
signal  i_buton_freq_up_d1        : std_logic;
signal  i_buton_freq_up_re        : std_logic;
signal  i_buton_freq_down_d1      : std_logic;
signal  i_buton_freq_down_re      : std_logic;
signal  sawgen_freq               : integer:=0;

begin
 sawgen_freq <= (100_000_000) / (166*(2047/freq_control)); 
 
  process(i_clk) begin 
    if(i_reset='1') then   
      freq_control<= 1;  
    else                   
   if (rising_edge(i_clk)) then 	   	
	   i_buton_freq_down_d1 <=  i_buton_freq_down; 
	   i_buton_freq_down_re <=  i_buton_freq_down and not i_buton_freq_down_d1;
	   
	   i_buton_freq_up_d1   <=  i_buton_freq_up; 
	   i_buton_freq_up_re   <=  i_buton_freq_up   and not i_buton_freq_up_d1; 
	  	   
--	   case but_state is   
--	   when S_WAIT => 
--		 if (i_buton_freq_up_re      = '1' ) then 
--		   but_state                <= S_UP; 
--		 else
--		 if (i_buton_freq_down_re    = '1' ) then 
--           but_state                <= S_DOWN;
--       else
--         freq_control               <= freq_control ;
--  		 end if;
--  	 end if;
  	 	 
--	   when S_UP   =>                                 
--	     freq_control             <= freq_control +1;
--	     but_state                <= S_WAIT; 
	                                           	                                               
--	   when S_DOWN =>                                       
--	     freq_control             <= freq_control -1;                           
--         but_state                <= S_WAIT; 
     
--      end case;  

    case but_state is   
	   when S_WAIT => 
		 if (i_buton_freq_up_re      = '1' ) then 
		   but_state                <= S_UP; 
		   freq_control             <= freq_control + 1 ;
		 else
		   but_state                <= S_WAIT;
		   freq_control             <= freq_control;
		 end if;
		 
		 if (i_buton_freq_down_re  = '1' ) then 
           but_state              <= S_DOWN;
           freq_control           <= freq_control - 1;
         else
           but_state              <= S_WAIT;
           freq_control           <= freq_control;
  		 end if;
  	 	 
	   when S_UP   =>                                 
	     but_state                <= S_WAIT; 
	                                           	                                               
	   when S_DOWN =>                                                                 
         but_state                <= S_WAIT; 
      end case;
                          
    end if;
   end if;                                     
end process;                                    

 process (i_clk) begin
  if(i_reset='1') then 
	   saw_index          <=  0;
  else 
    if (rising_edge (i_clk)) then
      s_CS_d1           <= s_CS;
   	  s_CS_re           <= s_CS and not s_CS_d1;	
  
    case sawgen_state is 
     
      when S_RIGHT=>  
        if(s_CS_re = '1') then 
          if ( saw_index         = SAW_MAX_AMPLITUDE-1) then
            out_data             <= (others=>'0');
            saw_index            <= 0;
          else 
            if ( saw_index+freq_control > SAW_MAX_AMPLITUDE-1) then
              out_data           <= (others=>'0');
              saw_index          <= 0;
            else               
              out_data           <= std_logic_vector(to_unsigned(saw_index,out_data'length)); 
              saw_index          <= saw_index+freq_control;  
    			  end if;
    			end if;
    		end if;
    	
    	 when S_LEFT=>  
        if(s_CS_re = '1') then 
          if ( saw_index         = 0) then
            out_data             <= (others=>'1');
            saw_index            <= 2046;
          else 
            if( saw_index-freq_control < 0) then
              out_data           <= (others=>'1');
              saw_index          <= 2046;          
            else
              out_data           <= std_logic_vector(to_unsigned(saw_index,out_data'length)); 
              saw_index          <= saw_index-freq_control;
            end if;   
    		 	end if;
    		end if;
	  end case;
   end if;
 end if;
end process;

process (i_clk) 
begin
  case i_saw_switch is
      when '0'     => sawgen_state <= S_RIGHT;     
      when '1'     => sawgen_state <= S_LEFT ; 
      when others  => none         <= '1';     
   end case;             
end process;
  o_trian_data       <= out_data;
  o_sawgen_freq      <= sawgen_freq;
end Behavioral;
