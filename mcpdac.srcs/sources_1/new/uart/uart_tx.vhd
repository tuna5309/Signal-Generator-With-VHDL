library ieee;
use ieee.STD_LOGIC_1164.ALL;
use ieee.NUMERIC_STD.ALL;

entity uart_tx is 

port ( 
  i_clk                  :  in std_logic;
  i_sys_rst              :  in std_logic;
  i_tx_data              :  in std_logic_vector ( 7 downto 0);
  i_tx_en		         :  in std_logic;
  i_baud                 :  in integer; 
  o_tx_done              :  out std_logic;
  o_tx	                 :  out std_logic
);
end uart_tx;

architecture uartx 	of uart_tx is 

attribute mark_debug : string;

type t_uart is (S_IDLE,S_START,S_DATA,S_STOP);
signal uart_state    : t_uart := S_IDLE;


signal clk_count   	 : integer;
signal cnt           : integer range 0 to 15 := 0; 

attribute mark_debug of uart_state  : signal is "true";
attribute mark_debug of clk_count   : signal is "true";
attribute mark_debug of cnt         : signal is "true";

begin 

P_TX_MAIN : process (i_clk) 
begin
	if(i_sys_rst = '1') then
	  uart_state            <= S_IDLE;
	  o_tx_done  			<= '0';
		o_tx       			<= '1';
		clk_count           <= 0;
		cnt                 <= 0;
	else
		
		if (rising_edge (i_clk)) then
      case uart_state  is 
			  when S_IDLE =>  
	   	    if ( i_tx_en           = '1') then 
	   	      o_tx_done           <= '0';
	   	      o_tx                <= '0';
	   	      uart_state          <= S_START;
	   	    else
	   	    	uart_state        <= S_IDLE;
	   	    	o_tx              <= '1';
	   	    	clk_count         <= 0;
	   	    end if; 
			  when S_START => 
			  	if (clk_count             = (i_baud) - 1 ) then  
			  		 uart_state          <=  S_DATA;
			  		 cnt                 <= 0;
			  		 clk_count           <= 0;
			  	else                 
			  		clk_count            <=  clk_count+1 ; 	
			  		uart_state  		 <= S_START;
			  		o_tx        		 <= '0';		     
			    end if;		              				     
			  when S_DATA  =>
			  	if (cnt                 <= i_tx_data'length - 1) then
			  		uart_state          <=  S_DATA;
			  	  if ( clk_count        = (i_baud) - 1) then
			  	    cnt                 <= cnt+1;
			  	    clk_count           <= 0;
			  	  else
			  			o_tx        	<= i_tx_data(cnt);
			  			clk_count       <=  clk_count+1 ;
			  	  end if;
			  	else
			  		uart_state          <= S_STOP;
			  		clk_count           <= 0;
			  	end if;				   
			  when S_STOP  =>    
			  	if ( clk_count          = (i_baud) - 1 ) then
			  		uart_state         <= S_IDLE;
			  		o_tx_done          <= '1';
			  		clk_count          <= 0;
			  		cnt                <= 0;
			  	else
			  		clk_count          <=  clk_count+1 ; 
			  		o_tx        	   <=  '1';
			  		uart_state         <= S_STOP;
			  	end if;
		end case;
	end if;
end if; 
end process;
end uartx;