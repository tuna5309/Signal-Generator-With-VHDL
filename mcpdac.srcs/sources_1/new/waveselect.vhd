library IEEE;
Library xpm;
use IEEE.STD_LOGIC_1164.ALL;
use xpm.vcomponents.all;
use ieee.NUMERIC_STD.ALL;

entity waveselect is
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
end waveselect;

architecture Behavioral of waveselect is

signal sqout      : std_logic_vector(10 downto 0 );
signal sqout_cdc  : std_logic_vector(10 downto 0 );
signal sinout     : std_logic_vector(10 downto 0 );
signal trianout   : std_logic_vector(10 downto 0 );
signal sawout     : std_logic_vector(10 downto 0 );
                                                            
signal square_freq_up                         : std_logic;  
signal sine_freq_up                           : std_logic;  
signal trian_freq_up                          : std_logic;  
signal ramp_freq_up                           : std_logic;  
                                                            
signal square_freq_down                       : std_logic;  
signal sine_freq_down                         : std_logic;  
signal trian_freq_down                        : std_logic;  
signal ramp_freq_down                         : std_logic;  

signal squ_pwm_up                             : std_logic;
signal squ_pwm_down                           : std_logic;


signal sine_freq                              : integer ;
signal trian_freq                             : integer ;
signal square_freq                            : std_logic_vector(15 downto 0 );
signal square_freq_cdc                        : std_logic_vector(15 downto 0 );
signal sawgen_freq                            : integer ;

signal squ_pwm_down_cdc                       : std_logic;
signal squ_pwm_up_cdc                         : std_logic;
signal square_freq_up_cdc                     : std_logic;
signal square_freq_down_cdc                   : std_logic;
signal s_CS_cdc                               : std_logic;



component kgen 
	port (
  	i_reset               :in  std_logic;                           
    i_clk                 :in  std_logic;                           
    i_buton_freq_up       :in  std_logic;
    s_CS                  :in  std_logic; 
    i_buton_freq_down     :in  std_logic;
    i_buton_up_pwm        :in  std_logic;                          
    i_buton_down_pwm      :in  std_logic;                                                   
    o_sqout               :out std_logic_vector(10 downto 0);  
    o_square_freq         :out std_logic_vector(15 downto 0));                                                    	
end component ;

component sinwave
    generic ( 
    NUM_POINT     : integer:=64;
    MAX_AMPLITUDE : integer:=2047);
  port    ( 
    i_clk                 : in  std_logic;
    i_reset               : in  std_logic;
    i_buton_freq_up       : in  std_logic; 
    i_buton_freq_down     : in  std_logic; 
    s_CS                  : in  std_logic;
    o_sin_freq            : out integer;
    o_sin_data            : out std_logic_vector(10 downto 0));
end component;

component triangular 
  generic ( 
    TRI_MAX_AMPLITUDE        : integer:=2047);
  port  ( 
    i_clk                    : in  std_logic;
    i_reset                  : in  std_logic;
    i_buton_freq_up          : in  std_logic; 
    i_buton_freq_down        : in  std_logic; 
    s_CS                     : in  std_logic;
    o_trian_freq             : out integer;
    o_trian_data             : out std_logic_vector(10 downto 0));
  end component;

component sawgen
generic ( 
    SAW_MAX_AMPLITUDE : integer:=2047);
  port (
    i_clk                    : in  std_logic;
    i_reset                  : in  std_logic;
    i_saw_switch             : in  std_logic;
    i_buton_freq_up          : in  std_logic; 
    i_buton_freq_down        : in  std_logic; 
    s_CS                     : in  std_logic;
    o_sawgen_freq            : out integer;
    o_trian_data             : out std_logic_vector(10 downto 0));
  end component;

component sevensegment
Port (                                                       
    i_clk                 : in std_logic;                          
    i_reset               : in std_logic;                          
    i_switch              : in std_logic_vector(3 downto 0 ) ;     
    sine_freq             : in integer;                            
    trian_freq            : in integer;                            
    square_freq           : in integer;                            
    sawgen_freq           : in integer;                            
    sevendisp             : out std_logic_vector ( 6 downto 0);    
    sevencontro           : out std_logic_vector ( 7 downto 0)     
 );                                                          
  end component;


begin


process(i_clk_100) begin                                                                            
    if (rising_edge (i_clk_100)) then                                                               
      if      ( i_buton_freq_up = '1'  and  i_switch = "0001") then                             
         square_freq_up                  <= i_buton_freq_up;                                                                             
      elsif ( i_buton_freq_up   = '1'  and  i_switch = "0010") then                                      
         sine_freq_up                    <= i_buton_freq_up;                                                                                                                       
      elsif ( i_buton_freq_up   = '1'  and  i_switch = "0100") then                             
         trian_freq_up                   <= i_buton_freq_up;                                                                                                                                                                 
      elsif ( i_buton_freq_up   = '1'  and  i_switch = "1000") then                             
         ramp_freq_up                   <= i_buton_freq_up;                                                                                                                                 
      else                                                                                      
            square_freq_up     <= '0';                                                          
            sine_freq_up       <= '0';                                                          
            trian_freq_up      <= '0';                                                          
            ramp_freq_up       <= '0';                                                          
      end if;                                                                                   
  end if;                                                                                       
 end process;                                                                                   
                                                                                                
                                                                                                
 process(i_clk_100) begin                                                                                                                                                                   
     if (rising_edge (i_clk_100)) then                                                              
       if      ( i_buton_freq_down = '1'  and  i_switch = "0001") then                          
          square_freq_down         <= i_buton_freq_down;                                                                                                                                                  
       elsif ( i_buton_freq_down   = '1'  and  i_switch = "0010") then                          
          sine_freq_down           <= i_buton_freq_down;                                                       
       elsif ( i_buton_freq_down   = '1'  and  i_switch = "0100") then                          
          trian_freq_down          <= i_buton_freq_down;                                                       
       elsif ( i_buton_freq_down   = '1'  and  i_switch = "1000") then                           
          ramp_freq_down           <= i_buton_freq_down;                                                       
       else                                                                                     
             square_freq_down     <= '0';                                                          
             sine_freq_down       <= '0';                                                          
             trian_freq_down      <= '0';                                                          
             ramp_freq_down       <= '0';                                                          
       end if;                                                                                  
    end if;                                                                                                                                                                          
end process;                                                                                    


process(i_clk_100) begin 
   if (rising_edge (i_clk_100)) then                                                              
     if ( i_buton_up_pwm = '1' and i_switch = "0001" ) then 
        squ_pwm_up         <= i_buton_up_pwm;
     else 
        squ_pwm_up         <= '0';
     end if;
   end if;
 end process;
 
 process(i_clk_100) begin                                                           
    if (rising_edge (i_clk_100)) then                                               
      if ( i_buton_down_pwm = '1' and i_switch = "0001" ) then                    
         squ_pwm_down         <= '1';                                             
      else                                                                      
         squ_pwm_down         <= '0';                                             
      end if;                                                                   
    end if;                                                                     
  end process;                                                                  

kare_port :kgen
port map ( 
  i_reset           =>   i_reset,    
  i_clk             =>   i_clk_10,  
  i_buton_freq_up   =>   square_freq_up_cdc,
  s_CS              =>   s_CS_cdc,   
  i_buton_freq_down =>   square_freq_down_cdc, 
  i_buton_up_pwm    =>   squ_pwm_up_cdc,
  i_buton_down_pwm  =>   squ_pwm_down_cdc,
  o_square_freq     =>   square_freq,
  o_sqout           =>   sqout );

sin_port :sinwave
  generic map ( 
    NUM_POINT         => 64,
    MAX_AMPLITUDE     => 2047)
  port  map  ( 
    i_clk             => i_clk_100,
    i_reset           => i_reset,
    i_buton_freq_up   => sine_freq_up,   
    i_buton_freq_down => sine_freq_down, 
    s_CS              => s_CS,
    o_sin_freq        => sine_freq,
    o_sin_data        => sinout);

triang_port : triangular
  generic map (                                                         
    TRI_MAX_AMPLITUDE        => 2047)                      
  port map (                                                           
    i_clk                    => i_clk_100,
    i_reset                  => i_reset,
    i_buton_freq_up          => trian_freq_up,   
    i_buton_freq_down        => trian_freq_down, 
    s_CS                     => s_CS,
    o_trian_freq             => trian_freq,
    o_trian_data             => trianout);
 
sawgen_port : sawgen  
  generic map ( 
    SAW_MAX_AMPLITUDE        =>     2047)
  port map (
    i_clk                    => i_clk_100,        
    i_reset                  => i_reset,
    i_buton_freq_up          => ramp_freq_up,   
    i_buton_freq_down        => ramp_freq_down,       
    i_saw_switch             => i_saw_switch, 
    s_CS                     => s_CS,
    o_sawgen_freq            => sawgen_freq,         
    o_trian_data             => sawout);

sevenseg_port : sevensegment 
  port map (                                               
        i_clk                =>  i_clk_100,        
        i_reset              =>  i_reset,      
        i_switch             =>  i_switch,     
        sine_freq            =>  sine_freq,    
        trian_freq           =>  trian_freq,  
        square_freq          =>  to_integer(unsigned(square_freq_cdc)),  
        sawgen_freq          =>  sawgen_freq,  
        sevendisp            =>  o_sevendisp,    
        sevencontro          =>  o_sevencontro   );                                                          
        
   sqout_gen_xpm : xpm_cdc_array_single
   generic map (
      DEST_SYNC_FF   => 4,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,            -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1,             -- DECIMAL; 0=do not register input, 1=register input
      WIDTH          => sqout'length           -- DECIMAL; range: 1-1024
   )
   port map (
      dest_out => sqout_cdc, -- WIDTH-bit output: src_in synchronized to the destination clock domain. This

      dest_clk => i_clk_100, -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => i_clk_10,   -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => sqout      -- WIDTH-bit input: Input single-bit array to be synchronized to destination clock
   );

   sqout_freq_gen_xpm : xpm_cdc_array_single
   generic map (
      DEST_SYNC_FF   => 4,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,            -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1,             -- DECIMAL; 0=do not register input, 1=register input
      WIDTH          => square_freq'length           -- DECIMAL; range: 1-1024
   )
   port map (
      dest_out => square_freq_cdc, -- WIDTH-bit output: src_in synchronized to the destination clock domain. This

      dest_clk => i_clk_100, -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => i_clk_10,   -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => square_freq      -- WIDTH-bit input: Input single-bit array to be synchronized to destination clock
   );

karegen_freq_up : xpm_cdc_single
   generic map (
      DEST_SYNC_FF => 4,   -- DECIMAL; range: 2-10
      INIT_SYNC_FF => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG => 1   -- DECIMAL; 0=do not register input, 1=register input
   )
   port map (
      dest_out => square_freq_up_cdc, -- 1-bit output: src_in synchronized to the destination clock domain. This output
                            -- is registered.

      dest_clk => i_clk_10, -- 1-bit input: Clock signal for the destination clock domain.
      src_clk => i_clk_100,   -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in => square_freq_up      -- 1-bit input: Input signal to be synchronized to dest_clk domain.
   );



karegen_freq_down : xpm_cdc_single
   generic map (
      DEST_SYNC_FF => 4,   -- DECIMAL; range: 2-10
      INIT_SYNC_FF => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG => 1   -- DECIMAL; 0=do not register input, 1=register input
   )
   port map (
      dest_out => square_freq_down_cdc, -- 1-bit output: src_in synchronized to the destination clock domain. This output
                            -- is registered.

      dest_clk => i_clk_10, -- 1-bit input: Clock signal for the destination clock domain.
      src_clk => i_clk_100,   -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in => square_freq_down      -- 1-bit input: Input signal to be synchronized to dest_clk domain.
   );



karegen_pwm_up : xpm_cdc_single
   generic map (
      DEST_SYNC_FF => 4,   -- DECIMAL; range: 2-10
      INIT_SYNC_FF => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG => 1   -- DECIMAL; 0=do not register input, 1=register input
   )
   port map (
      dest_out => squ_pwm_up_cdc, -- 1-bit output: src_in synchronized to the destination clock domain. This output
                            -- is registered.

      dest_clk => i_clk_10, -- 1-bit input: Clock signal for the destination clock domain.
      src_clk => i_clk_100,   -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in => squ_pwm_up      -- 1-bit input: Input signal to be synchronized to dest_clk domain.
   );


karegen_pwm_down : xpm_cdc_single                                                                                                
   generic map (                                                                                                               
      DEST_SYNC_FF => 4,   -- DECIMAL; range: 2-10                                                                             
      INIT_SYNC_FF => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values                       
      SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages                             
      SRC_INPUT_REG => 1   -- DECIMAL; 0=do not register input, 1=register input                                               
   )                                                                                                                           
   port map (                                                                                                                  
      dest_out => squ_pwm_down_cdc, -- 1-bit output: src_in synchronized to the destination clock domain. This output            
                            -- is registered.                                                                                  
                                                                                                                               
      dest_clk => i_clk_10, -- 1-bit input: Clock signal for the destination clock domain.                                     
      src_clk => i_clk_100,   -- 1-bit input: optional; required when SRC_INPUT_REG = 1                                        
      src_in => squ_pwm_down      -- 1-bit input: Input signal to be synchronized to dest_clk domain.                            
   );                                                                                                                          


s_cs_cdc_inst : xpm_cdc_single                                                                                             
   generic map (                                                                                                              
      DEST_SYNC_FF => 4,   -- DECIMAL; range: 2-10                                                                            
      INIT_SYNC_FF => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values                      
      SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages                            
      SRC_INPUT_REG => 1   -- DECIMAL; 0=do not register input, 1=register input                                              
   )                                                                                                                          
   port map (                                                                                                                 
      dest_out => s_CS_cdc, -- 1-bit output: src_in synchronized to the destination clock domain. This output         
                            -- is registered.                                                                                 
                                                                                                                              
      dest_clk => i_clk_10, -- 1-bit input: Clock signal for the destination clock domain.                                    
      src_clk => i_clk_100,   -- 1-bit input: optional; required when SRC_INPUT_REG = 1                                       
      src_in => s_cs      -- 1-bit input: Input signal to be synchronized to dest_clk domain.                         
   );                                                                                                                         --process (i_clk_100) 
                                                                                                                              --begin
                                                                                                                              --  case (i_switch) is
--    when "0001" => o_wave_out <= sqout;     
--    when "0010" => o_wave_out <= sinout; 
--    when "0100" => o_wave_out <= trianout;
--    when "1000" => o_wave_out <= sawout;
--    when others => o_wave_out <= (others => '0');           
--   end case;             
--end process;


o_wave_out <= sqout_cdc when i_switch = "0001" else 
              sinout    when i_switch = "0010" else 
              trianout  when i_switch = "0100" else 
              sawout    when i_switch = "1000" else 
              "00000000000";

end Behavioral;
