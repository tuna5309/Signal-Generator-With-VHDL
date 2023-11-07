library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.NUMERIC_STD.ALL;
use IEEE.std_logic_signed.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity uart_rx is
Port (
	i_clk        	           : in  std_logic;
	i_sys_rst                  : in  std_logic; 
	i_rx     	               : in  std_logic;
	i_baud                     : in  integer;
	o_rx_en                    : out std_logic;
	o_rx_data                  : out std_logic_vector(7 downto 0)
 );
end uart_rx;

architecture uartrx of uart_rx is

attribute mark_debug : string;

type      t_uart_rx is (S_IDLE, S_START, S_DATA, S_STOP);
signal    uart_state         : t_uart_rx := S_IDLE; 	      

signal    clk_count                : integer;
signal    cnt                      : integer range 0 to 7 := 0;
signal    rx_1                     : std_logic; 
signal    rx_2                     : std_logic;   
signal    rx_data                  : std_logic_vector(7 downto 0);

attribute mark_debug of uart_state : signal is "true";
attribute mark_debug of clk_count  : signal is "true";
attribute mark_debug of cnt        : signal is "true";
attribute mark_debug of rx_2       : signal is "true";
attribute mark_debug of rx_data    : signal is "true";

begin

P_RX_MAIN : process (i_clk) begin

	if(i_sys_rst = '1') then 
	   uart_state  		               <= S_IDLE; 
	   rx_data                         <= "00000000"; 
	   clk_count 		               <= 0;
	   cnt       		               <= 0;	   
	else if (rising_edge(i_clk)) then 
	   rx_1                            <= i_rx;
	   rx_2                            <= rx_1;	
		 o_rx_en                       <='0';
		case uart_state is 
		when S_IDLE =>           
	    
		  if ( rx_2 = '0') then 
			  uart_state               <= S_START;
		  else   
            uart_state                 <= S_IDLE;
            cnt                        <= 0;
		    clk_count                  <= 0;
		  end if;
		
		when S_START => 
	    if (clk_count = (i_baud-1)/2) then
        if (rx_2 = '0') then
          clk_count                    <= 0;  
          uart_state                   <= S_DATA;
        else
          uart_state                   <=S_IDLE;
          clk_count                    <= 0;  
        end if;
      else
        clk_count                      <= clk_count + 1;
        uart_state                     <= S_START;
      end if;	  
		
		when S_DATA  =>
	     if clk_count                  < (i_baud-1) then
	       clk_count                   <= clk_count + 1;
	       uart_state                  <= S_DATA;
	     else
	       clk_count                   <= 0;
	       rx_data(cnt)                <= rx_2;             
	       if cnt < 7 then
	         cnt                       <= cnt + 1;
	         uart_state                <= S_DATA;
	       else
	         cnt <= 0;
	         uart_state                <= S_STOP;
	       end if;
	     end if;
		
		when S_STOP   =>
      if clk_count              < (i_baud-1) then
        clk_count               <= clk_count + 1;
        uart_state              <= S_STOP;
      else
        if (rx_2 = '1') then 
       	  o_rx_data             <=rx_data;
          o_rx_en               <='1';
		  clk_count             <= 0;
          uart_state            <= S_IDLE;
        else
          uart_state            <= S_IDLE;
          clk_count             <= 0;
      	end if;
		end if;
		end case;
	 end if;
	end if; 
end process;	 

end uartrx;
