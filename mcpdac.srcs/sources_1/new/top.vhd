library ieee;
Library xpm;
Library UNISIM;
use ieee.STD_LOGIC_1164.ALL;
use xpm.vcomponents.all;
use UNISIM.vcomponents.all;

entity top is 
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
    LDAC               : out std_logic
    );
   end entity;
 
 architecture Behavioral of top is
 
 signal uart_to_spi_data                       : std_logic;
 signal i_switch_mcp                           : std_logic_vector ( 3 downto 0);
 signal out_data                               : std_logic;
 signal o_uart_data                            : std_logic;
 signal debounced_i_GA                         : std_logic; 
 signal debounced_i_SHDN                       : std_logic; 
 signal debounced_i_buton_freq_up              : std_logic; 
 signal debounced_i_buton_freq_down            : std_logic; 
 signal debounced_i_buton_up_pwm               : std_logic; 
 signal debounced_i_buton_down_pwm             : std_logic; 
 signal debounced_i_saw_switch                 : std_logic; 
 signal debounced_i_reset                      : std_logic;
 signal i_baud                                 : integer;
 signal locked                                 : std_logic;
 signal clk_10                                 : std_logic;
 signal clk_100                                : std_logic;
 signal clk_100_buf                            : std_logic;
 signal clk_10_buf                             : std_logic;
 signal sys_rst                                : std_logic;
 
 component clk_wiz_0                         
port                                        
 (-- Clock in ports                         
  -- Clock out ports                        
  clk_out1          : out    std_logic;     
  clk_out2          : out    std_logic;     
  -- Status and control signals             
  reset             : in     std_logic;     
  locked            : out    std_logic;     
  clk_in1           : in     std_logic      
 );                                         
end component;                              
 
 component uart_spi_top
   port (                                                      
  i_clk          :  in  std_logic;                          
  i_reset        :  in  std_logic;                          
  i_rx           :  in  std_logic;                          
  i_baud         :  in  integer;                            
  i_switch_baud  :  in  std_logic_vector( 2 downto 0 );     
  o_tx           :  out std_logic;                          
  o_controller   :  out std_logic_vector ( 3 downto 0 )     
);                                                           
 end component;


 component mcpdac is 
   port (i_reset             : in  std_logic;
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
end component;
   
   begin 
   
   sys_rst <= not locked;

   uart_spi_top_inst:uart_spi_top
     port map ( 
      i_clk           =>  clk_100 ,
      i_reset         =>  sys_rst,
      i_rx            =>  i_data ,
      i_baud          =>  i_baud ,
      i_switch_baud   =>  i_switch_baud ,
      o_tx            =>  o_data ,
      o_controller    =>  i_switch_mcp);
      
   mcpdac_inst:  mcpdac
     port map ( 
       i_reset              =>  sys_rst,            
       i_clk_100            =>  clk_100,
       i_clk_10             =>  clk_10,              
       i_GA                 =>  debounced_i_GA,               
       i_SHDN               =>  debounced_i_SHDN,             
       i_switch             =>  i_switch_mcp,    
       i_saw_switch         =>  debounced_i_saw_switch,  
       i_buton_freq_up      =>  debounced_i_buton_freq_up,    
       i_buton_freq_down    =>  debounced_i_buton_freq_down,   
       i_buton_up_pwm       =>  debounced_i_buton_up_pwm,        
       i_buton_down_pwm     =>  debounced_i_buton_down_pwm,      
       o_sevendisp          =>  o_sevendisp,
       o_sevencontro        =>  o_sevencontro,     
       CS                   =>  CS,                 
       SDI                  =>  SDI,                
       LDAC                 =>  LDAC,               
       SCK                  =>  SCK);  
       
       freq_up : xpm_cdc_single
    generic map (
       DEST_SYNC_FF   => 4,   -- DECIMAL; range: 2-10
       INIT_SYNC_FF   => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
       SIM_ASSERT_CHK => 0,   -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
       SRC_INPUT_REG  => 1    -- DECIMAL; 0=do not register input, 1=register input
    )
    port map (
       dest_out => debounced_i_buton_freq_up, 
       dest_clk => clk_100,               -- 1-bit input: Clock signal for the destination clock domain.
       src_clk  => clk_100,               -- 1-bit input: optional; required when SRC_INPUT_REG = 1
       src_in   => i_buton_freq_up      -- 1-bit input: Input signal to be synchronized to dest_clk domain.
    );
 
 
  freq_down : xpm_cdc_single
    generic map (
       DEST_SYNC_FF   => 4,   -- DECIMAL; range: 2-10
       INIT_SYNC_FF   => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
       SIM_ASSERT_CHK => 0,   -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
       SRC_INPUT_REG  => 1    -- DECIMAL; 0=do not register input, 1=register input
    )
    port map (
       dest_out => debounced_i_buton_freq_down, 
       dest_clk => clk_100,                 -- 1-bit input: Clock signal for the destination clock domain.
       src_clk  => clk_100,                 -- 1-bit input: optional; required when SRC_INPUT_REG = 1
       src_in   => i_buton_freq_down      -- 1-bit input: Input signal to be synchronized to dest_clk domain.
    );
 
 
 i_GA_buton : xpm_cdc_single
    generic map (
       DEST_SYNC_FF   => 4,   -- DECIMAL; range: 2-10
       INIT_SYNC_FF   => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
       SIM_ASSERT_CHK => 0,   -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
       SRC_INPUT_REG  => 1    -- DECIMAL; 0=do not register input, 1=register input
    )
    port map (
       dest_out => debounced_i_GA, 
       dest_clk => clk_100,     -- 1-bit input: Clock signal for the destination clock domain.
       src_clk  => clk_100,     -- 1-bit input: optional; required when SRC_INPUT_REG = 1
       src_in   => i_GA       -- 1-bit input: Input signal to be synchronized to dest_clk domain.
    );
 
 
 i_SHDN_buton : xpm_cdc_single
    generic map (
       DEST_SYNC_FF   => 4,   -- DECIMAL; range: 2-10
       INIT_SYNC_FF   => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
       SIM_ASSERT_CHK => 0,   -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
       SRC_INPUT_REG  => 1    -- DECIMAL; 0=do not register input, 1=register input
    )
    port map (
       dest_out => debounced_i_SHDN, 
       dest_clk => clk_100,    -- 1-bit input: Clock signal for the destination clock domain.
       src_clk  => clk_100,    -- 1-bit input: optional; required when SRC_INPUT_REG = 1
       src_in   => i_SHDN    -- 1-bit input: Input signal to be synchronized to dest_clk domain.
    );
 
 
  pwm_up : xpm_cdc_single
    generic map (
       DEST_SYNC_FF   => 4,   -- DECIMAL; range: 2-10
       INIT_SYNC_FF   => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
       SIM_ASSERT_CHK => 0,   -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
       SRC_INPUT_REG  => 1    -- DECIMAL; 0=do not register input, 1=register input
    )
    port map (
       dest_out => debounced_i_buton_up_pwm, 
       dest_clk => clk_100,              -- 1-bit input: Clock signal for the destination clock domain.
       src_clk  => clk_100,              -- 1-bit input: optional; required when SRC_INPUT_REG = 1
       src_in   => i_buton_up_pwm      -- 1-bit input: Input signal to be synchronized to dest_clk domain.
    );
 
 
 pwm_down : xpm_cdc_single
    generic map (
       DEST_SYNC_FF   => 4,   -- DECIMAL; range: 2-10
       INIT_SYNC_FF   => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
       SIM_ASSERT_CHK => 0,   -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
       SRC_INPUT_REG  => 1    -- DECIMAL; 0=do not register input, 1=register input
    )
    port map (
       dest_out => debounced_i_buton_down_pwm, 
       dest_clk => clk_100,               -- 1-bit input: Clock signal for the destination clock domain.
       src_clk  => clk_100,               -- 1-bit input: optional; required when SRC_INPUT_REG = 1
       src_in   => i_buton_down_pwm     -- 1-bit input: Input signal to be synchronized to dest_clk domain.
    );
 
 
 xpm_cdc_sync_rst_inst : xpm_cdc_sync_rst
   generic map (
      DEST_SYNC_FF   => 4,   -- DECIMAL; range: 2-10
      INIT => 1,             -- DECIMAL; 0=initialize synchronization registers to 0, 1=initialize
                             -- synchronization registers to 1
      INIT_SYNC_FF   => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0    -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   )
   port map (
      dest_rst => debounced_i_reset, -- 1-bit output: src_rst synchronized to the destination clock domain. This output
                                     -- is registered.

      dest_clk => i_clk,             -- 1-bit input: Destination clock.
      src_rst  => i_reset            -- 1-bit input: Source reset signal.
   );
  
   saw_switch : xpm_cdc_single
    generic map (
       DEST_SYNC_FF   => 4,   -- DECIMAL; range: 2-10
       INIT_SYNC_FF   => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
       SIM_ASSERT_CHK => 0,   -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
       SRC_INPUT_REG  => 1    -- DECIMAL; 0=do not register input, 1=register input
    )
    port map (
       dest_out => debounced_i_saw_switch, 
       dest_clk => clk_100,       -- 1-bit input: Clock signal for the destination clock domain.
       src_clk  => clk_100,       -- 1-bit input: optional; required when SRC_INPUT_REG = 1
       src_in   => i_saw_switch -- 1-bit input: Input signal to be synchronized to dest_clk domain.
    );
   
   clk_wiz : clk_wiz_0      
      port map (                       
     -- Clock out ports                
      clk_out1 => clk_100,            
      clk_out2 => clk_10,            
     -- Status and control signals     
      reset => debounced_i_reset,                  
      locked => locked,                
      -- Clock in ports                
      clk_in1 => i_clk               
    );   
                                  
 
 end Behavioral; 
 