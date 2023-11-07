library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;



entity triangular is
  generic ( 
    TRI_MAX_AMPLITUDE : integer:=2047);
  port  ( 
    i_clk                    : in std_logic;
    i_reset                  : in std_logic;
    i_buton_freq_up          : in std_logic; 
    i_buton_freq_down        : in std_logic; 
    s_CS                     : in std_logic;
    o_trian_data             : out std_logic_vector(10 downto 0);
    o_trian_freq             : out integer);
  end triangular;

architecture Behavioral of triangular is

type    trian_state is (S_UP,S_DOWN) ;
signal  triangular_state   : trian_state := S_UP; 

type    buton_state   is (S_WAIT,S_UP,S_DOWN) ;  
signal  but_state   : buton_state :=S_WAIT;

signal  s_CS_d1                   : std_logic;
signal  s_CS_re                   : std_logic;
signal  tri_index                 : integer:=2047;
signal  out_data                  : std_logic_vector(10 downto 0);
signal  i_buton_freq_up_d1        : std_logic;
signal  i_buton_freq_up_re        : std_logic;
signal  i_buton_freq_down_d1      : std_logic;
signal  i_buton_freq_down_re      : std_logic;
signal  freq_control              : integer range 1 to 10:=1;
signal  triangular_freq           : integer;


begin

triangular_freq <= (100_000_000) / (332*(2047/freq_control));

process(i_clk) begin 
   if(i_reset='1') then    
     freq_control<= 1;   
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
	   triangular_state   <=  S_UP;
	   tri_index          <=  0;
  else 
    if (rising_edge (i_clk)) then
      s_CS_d1           <= s_CS;
   	  s_CS_re           <= s_CS and not s_CS_d1;	
    
 	case triangular_state is 
    
    when S_UP =>  
          if(s_CS_re = '1') then
            if ( tri_index       = TRI_MAX_AMPLITUDE-1) then
              tri_index         <= 2046 ;
              triangular_state  <= S_DOWN;
            else 
              if ( tri_index+freq_control > TRI_MAX_AMPLITUDE-1) then
                out_data           <= (others=>'1');
                tri_index          <= 2046;
              else           
                out_data           <= std_logic_vector(to_unsigned(tri_index,out_data'length)); 
                tri_index          <= tri_index+freq_control;   
							end if;
						end if;
					end if;      
 
    when S_DOWN =>
          if(s_CS_re = '1') then
            if ( tri_index       = 0) then
              tri_index          <= 0 ; 
              triangular_state   <= S_UP;
						else    
						   if ( tri_index-freq_control < 0) then
                 out_data           <= (others=>'0');
                 tri_index          <= 0;
						   else 
                 out_data           <= std_logic_vector(to_unsigned(tri_index,out_data'length)); 
						     tri_index          <= tri_index-freq_control;
						   end if;
					end if;
				 end if;
				end case;
		end if;	 
  end if;
end process;
o_trian_data <= out_data;
o_trian_freq <= triangular_freq; -- triang freq 
end Behavioral;
