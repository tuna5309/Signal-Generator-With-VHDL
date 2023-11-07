
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity uart_spi_top is

port (
  i_clk          :  in  std_logic;
  i_reset        :  in  std_logic;
  i_rx           :  in  std_logic;
  i_baud         :  in  integer;
  i_switch_baud  :  in  std_logic_vector( 2 downto 0 ); 
  o_tx           :  out std_logic;
  o_controller   :  out std_logic_vector ( 3 downto 0 ) 
);

end uart_spi_top;

architecture Behavioral of uart_spi_top is  
    signal baudgen         : integer;
    signal o_uart_data     : std_logic_vector ( 7 downto 0 ) ;
    signal o_tx_done       : std_logic;
    signal i_tx_en         : std_logic;
    signal i_uart_data     : std_logic_vector ( 7 downto 0 ); 
    signal o_rx_en         : std_logic;
    signal i_rx_en         : std_logic;
    signal o_tx_en         : std_logic;
    signal i_tx_done       : std_logic;
   
 component uart_to_spi is   
    Port (                                                      
    i_clk       : in std_logic;                               
    i_reset     : in std_logic; 
    i_rx_en     : in std_logic; 
    i_tx_done   : in std_logic;                            
    i_uart_data : in std_logic_vector (7 downto 0);                                
    o_controller: out std_logic_vector (3 downto 0 ); 
    o_tx_en     : out std_logic;        
    o_uart_data : out std_logic_vector (7 downto 0)                                                                                         
  );                                                          
end component;                                                
   

   
   component baudsel is 
   generic(
   	clk_freq  :  integer := 100_000_000
   );
        port(
        switch    : in  std_logic_vector(2 downto 0) ; 
        baudgen   : out integer
        );
   end component;
  
 component uart_tx 
	port(i_clk                        : in  std_logic;
        i_sys_rst                     : in  std_logic;
        i_tx_data                     : in std_logic_vector(7 downto 0);
        i_tx_en                       : in std_logic;
        i_baud                        : in integer;
        o_tx_done                     : out std_logic;
        o_tx	                      : out std_logic
    );
	end component;
	
	component uart_rx
	port  ( 
	  i_clk        	                  :   in  std_logic;
	  i_sys_rst                       :   in  std_logic; 
	  i_rx     	                      :   in  std_logic;
	  i_baud                          :   in integer;
	  o_rx_en                         :   out std_logic;
	  o_rx_data                       :   out std_logic_vector(7 downto 0)
    );
	end component;

begin
    
    baudsel_top:baudsel
   generic map ( clk_freq       => 100_000_000)
    port map(
        switch                  => i_switch_baud,
        baudgen                 => baudgen
    );
  
    -- -------------------------------------------------------------------------
    --   UART-TX 
    -- -------------------------------------------------------------------------
    uart_tx_port:uart_tx
    port map (
        i_clk                    => i_clk,
        i_sys_rst                => i_reset,
        i_baud                   => baudgen,
        o_tx                     => o_tx,
        i_tx_en                  => o_tx_en,
        o_tx_done                => o_tx_done,
        i_tx_data                => o_uart_data 
    );  
    -- -------------------------------------------------------------------------
    --   UART-RX 
    -- -------------------------------------------------------------------------
    uart_rx_port:uart_rx
    port map (
        i_clk                     => i_clk,  
        i_sys_rst                 => i_reset,
        i_rx                      => i_rx,
        i_baud                    => baudgen,
        o_rx_en                   => o_rx_en,
        o_rx_data                 => i_uart_data);  
 
     
     
     uart_to_spi_port:uart_to_spi
     port map ( 
        i_clk                     =>  i_clk ,
        i_reset                   =>  i_reset ,
        i_rx_en                   =>  o_rx_en,
        i_tx_done                 =>  o_tx_done,                             
        i_uart_data               =>  i_uart_data,
        o_controller              =>  o_controller,
        o_tx_en                   =>  o_tx_en,
        o_uart_data               =>  o_uart_data);

end Behavioral;
