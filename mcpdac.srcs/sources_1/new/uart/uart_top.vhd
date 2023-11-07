library ieee;
use ieee.STD_LOGIC_1164.ALL;
use ieee.NUMERIC_STD.ALL;


entity uart_top  is
generic(
	clk_freq  :  integer := 100_000_000
);
    port (
                i_clk           : in  std_logic;
                i_sys_rst       : in  std_logic;                 
                i_rx     	    : in  std_logic;
                switch          : in  std_logic_vector(2 downto 0);
                o_tx	        : out std_logic
    );
end entity;

architecture rtl of uart_top is 

attribute mark_debug : string;


signal o_tx_done     : std_logic;
signal clk_out       : std_logic;
signal TX_out        : std_logic;
signal baud_conf     : integer;
signal rx_data       : std_logic_vector(7 downto 0);
signal o_rx_en       : std_logic;
signal locked        : std_logic;
signal sys_rst       : std_logic;
signal baudgen       : integer;



attribute mark_debug of o_tx_done: signal is "true";
attribute mark_debug of TX_out   : signal is "true";
attribute mark_debug of rx_data  : signal is "true";
attribute mark_debug of o_rx_en  : signal is "true";

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
	port  (i_clk        	           :   in  std_logic;
	        i_sys_rst                  :   in  std_logic; 
	        i_rx     	               :   in  std_logic;
	        i_baud                     :   in integer;
	        o_rx_en                    :   out std_logic;
	        o_rx_data                  :   out std_logic_vector(7 downto 0)
    );
	end component;

   begin
   

sys_rst <= (not locked) or i_sys_rst;

    
    -- ----------------------------------------------------------------------
    --  baudsel  
    -- -------------------------------------------------------------------------
   baudsel_top:baudsel
   generic map ( clk_freq       => 100_000_000)
    port map(
        switch                  => switch,
        baudgen                 => baudgen
    );
  
    -- -------------------------------------------------------------------------
    --   UART-TX 
    -- -------------------------------------------------------------------------
    uart_tx_port:uart_tx
    port map (
        i_clk                    => i_clk,
        i_sys_rst                => sys_rst,
        i_baud                   => baudgen,
        o_tx                     => TX_out,
        i_tx_en                  => o_rx_en,
        o_tx_done                => o_tx_done,
        i_tx_data                => rx_data 
    );  
    -- -------------------------------------------------------------------------
    --   UART-RX 
    -- -------------------------------------------------------------------------
    uart_rx_port:uart_rx
    port map (
        i_clk                     => i_clk,
        i_sys_rst                 => sys_rst,
        i_rx                      => i_rx,
        i_baud                    => baudgen,
        o_rx_en                   => o_rx_en,
        o_rx_data                 => rx_data);  
   
    o_tx <= TX_out;
    
    
    end rtl;
    


