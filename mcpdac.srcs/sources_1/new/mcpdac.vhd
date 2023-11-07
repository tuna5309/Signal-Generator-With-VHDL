library IEEE;
Library xpm;
use IEEE.STD_LOGIC_1164.ALL;
use xpm.vcomponents.all;


entity mcpdac is
port (i_reset                : in  std_logic;
      i_clk_100              : in  std_logic;
      i_clk_10               : in  std_logic;
      i_GA                   : in  std_logic;
      i_SHDN                 : in  std_logic;
      i_switch               : in  std_logic_vector(3 downto 0);
      i_saw_switch           : in  std_logic; 
      i_buton_freq_up        : in  std_logic;
      i_buton_freq_down      : in  std_logic;
      i_buton_up_pwm         : in  std_logic;
      i_buton_down_pwm       : in  std_logic;
      ---------------------------------------
      o_sevendisp            : out std_logic_vector ( 6 downto 0 ) ;   
      o_sevencontro          : out std_logic_vector ( 7 downto 0 ) ;   
      CS                     : out std_logic;
      SDI                    : out std_logic;
      LDAC                   : out std_logic;
      SCK                    : out std_logic
);
end mcpdac;


architecture design of mcpdac is

attribute mark_debug : string;

signal wave_data                              : std_logic_vector ( 10 downto 0 );
signal button                                 : std_logic;
signal result                                 : std_logic;
signal debounced_i_reset                      : std_logic;
signal reset_sig                              : std_logic;  
signal GA     								  : std_logic:='1';
signal SHDN    								  : std_logic:='1';
signal src_clk                                : std_logic;
signal s_CS                                   : std_logic;




attribute mark_debug of debounced_i_reset: signal is "true";
--attribute mark_debug of debounced_i_GA:    signal is "true";
--attribute mark_debug of debounced_i_SHDN:  signal is "true";


component spi_interface 
  port(                                                               
    i_clk      : in std_logic;                     
    i_GA       : in std_logic;
    i_SHDN     : in std_logic;                     
    i_reset    : in std_logic;                     
  	i_data     : in std_logic_vector(10 downto 0);  
  	CS         : out std_logic;                     
  	SDI        : out std_logic;                     
  	LDAC       : out std_logic;                     
  	SCK        : out std_logic);                                                
end component;

component waveselect 
  port (
     i_reset               : in  std_logic;
     i_clk_100             : in  std_logic;
     i_clk_10              : in  std_logic;
     i_switch              : in  std_logic_vector(3 downto 0);
     s_CS                  : in  std_logic;
     i_saw_switch          : in  std_logic; 
     i_buton_freq_up       : in  std_logic;                        
     i_buton_freq_down     : in  std_logic;                        
     i_buton_up_pwm        : in  std_logic;                        
     i_buton_down_pwm      : in  std_logic; 
     o_sevendisp           : out std_logic_vector ( 6 downto 0 ) ; 
     o_sevencontro         : out std_logic_vector ( 7 downto 0 ) ;                          
     o_wave_out            : out std_logic_vector ( 10 downto 0));  
end component;


begin

CS<= s_CS;




 spi_int_port : spi_interface
   port map ( 
     i_clk                => i_clk_100,   
     i_GA                 => i_GA,  
     i_SHDN               => i_SHDN,   
     i_reset              => i_reset, 
     i_data               => wave_data,  
     CS                   => s_CS,       
     SDI                  => SDI,      
     LDAC                 => LDAC,     
     SCK                  => SCK );
  
 wave_sel_port :waveselect
   port map (
     i_reset              => i_reset,
     i_clk_100            => i_clk_100,
     i_clk_10             => i_clk_10,
     i_switch             => i_switch,
     i_saw_switch         => i_saw_switch,
     i_buton_freq_up      => i_buton_freq_up,
     s_CS                 => s_CS,
     i_buton_freq_down    => i_buton_freq_down,
     i_buton_up_pwm       => i_buton_up_pwm,
     i_buton_down_pwm     => i_buton_down_pwm,
     o_sevendisp          => o_sevendisp,   
     o_sevencontro        => o_sevencontro, 
     o_wave_out           => wave_data );
  

end design;
