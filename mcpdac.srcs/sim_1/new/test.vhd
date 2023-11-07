library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity test is
end test;

architecture Behavioral of test is
component top
 port (  
   i_clk              : in  std_logic;                              
   i_reset            : in  std_logic;                              
   i_data             : in  std_logic;                              
   i_switch_baud      : in  std_logic_vector ( 2 downto 0 );        
   i_saw_switch       : in  std_logic;                              
   i_buton_freq_up    : in  std_logic;                              
   i_buton_freq_down  : in  std_logic;                              
   i_buton_up_pwm     : in  std_logic;                              
   i_buton_down_pwm   : in  std_logic;                              
   i_GA               : in  std_logic;                              
   i_SHDN             : in  std_logic;
   o_sevendisp        : out std_logic_vector ( 6 downto 0 ) ;    
   o_sevencontro      : out std_logic_vector ( 7 downto 0 ) ;                                  
   o_data             : out std_logic;                              
   CS                 : out std_logic;                              
   SDI                : out std_logic;                              
   SCK                : out std_logic;                              
   LDAC               : out std_logic);                                                                            
end component;

constant clock_freq            : integer :=100_000_000;
constant clock_period          : time:= 1sec/clock_freq;
constant c_BIT_PERIOD 	       : time := 8680 ns;


signal     tb_i_clk                :   std_logic;                               
signal     tb_i_reset              :   std_logic;                               
signal     tb_i_data               :   std_logic;                               
signal     tb_i_switch_baud        :   std_logic_vector ( 2 downto 0 );         
signal     tb_i_saw_switch         :   std_logic;                               
signal     tb_i_buton_freq_up      :   std_logic;                               
signal     tb_i_buton_freq_down    :   std_logic;                               
signal     tb_i_buton_up_pwm       :   std_logic;                               
signal     tb_i_buton_down_pwm     :   std_logic;                               
signal     tb_i_GA                 :   std_logic;                               
signal     tb_i_SHDN               :   std_logic;                               
signal     tb_o_data               :   std_logic;                               
signal     tb_CS                   :   std_logic;                               
signal     tb_SDI                  :   std_logic;                               
signal     tb_SCK                  :   std_logic;                               
signal     tb_LDAC                 :   std_logic;                              
signal     tb_o_sevendisp          :   std_logic_vector ( 6 downto 0 ) ;
signal     tb_o_sevencontro        :   std_logic_vector ( 7 downto 0 ) ;


procedure WRITE_BYTE( 
        byte_in       : in STD_LOGIC_VECTOR(7 downto 0);
        signal data_o : out STD_LOGIC
    ) is
    begin
    		data_o  <= '1';
    		wait for c_BIT_PERIOD; 
             data_o <= '0';
            wait for c_BIT_PERIOD;
            for i in 0 to 7 loop 
             data_o <= byte_in(i);
            wait for c_BIT_PERIOD;
            end loop;
            data_o <= '1'; 
            wait for c_BIT_PERIOD;
    end procedure;



begin   
 tb_i_GA    <= '0';
 tb_i_SHDN  <= '1';

port_top : top
  port map ( 
    i_clk             => tb_i_clk,           
    i_reset           => tb_i_reset,          
    i_data            => tb_i_data,           
    i_switch_baud     => tb_i_switch_baud,    
    i_saw_switch      => tb_i_saw_switch,     
    i_buton_freq_up   => tb_i_buton_freq_up,  
    i_buton_freq_down => tb_i_buton_freq_down,
    i_buton_up_pwm    => tb_i_buton_up_pwm,   
    i_buton_down_pwm  => tb_i_buton_down_pwm, 
    i_GA              => tb_i_GA,             
    i_SHDN            => tb_i_SHDN,           
    o_data            => tb_o_data,           
    CS                => tb_CS,               
    SDI               => tb_SDI,              
    SCK               => tb_SCK,             
    LDAC              => tb_LDAC);             


p_clk : process begin                      
   tb_i_clk         <= '0';     
   wait for clock_period/2;    
   tb_i_clk         <= '1';     
   wait for clock_period/2;    
end process p_clk;                         


p_rst : process begin                      
   tb_i_reset       <= '1';     
   wait for 1*clock_period;   
   tb_i_reset       <= '0';     
   wait;                     
end process p_rst;                         


process begin 
 wait for 10*clock_period;
 tb_i_buton_freq_up     <= '1';
  tb_i_buton_freq_down  <= '0';
  wait for 5*clock_period;
 tb_i_buton_freq_up     <= '0';

 wait;
end process;

process begin 
wait for 10*clock_period;
tb_i_switch_baud <= "110";
 WRITE_BYTE(x"31", tb_i_data);
wait for 30*clock_period;

 
end process;
end Behavioral;

