library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity spi_interface is
port(
    i_clk       : in  std_logic;
    i_GA        : in  std_logic;
    i_SHDN      : in  std_logic;
    i_reset     : in  std_logic;
	i_data      : in  std_logic_vector(10 downto 0);
	CS          : out std_logic;
	SDI         : out std_logic;
	LDAC        : out std_logic;
	SCK         : out std_logic
);
end spi_interface;

architecture design of spi_interface is

attribute mark_debug : string;

type      dac_state is (S_IDLE,S_WAIT,S_DELAY, S_DATA) ;
signal    dac_stat   : dac_state := S_IDLE; 

signal A_B           : std_logic:='0';
signal BUF           : std_logic:='1';
signal reg           : std_logic_vector(15 downto 0);
signal SDI_I         : std_logic;
signal CS_I          : std_logic;
signal tmp           : std_logic:= '0';
signal clk_10        : std_logic:='0';
signal cnt_delay     : integer range 0 to 10 :=0;
signal cnt_idle      : integer:=0; 
signal cnt_data      : integer range 0 to 16 :=0;
signal cnt_wait      : integer range 0 to 7  :=0;
signal count         : integer:=1;
signal enable_sck    : std_logic:='0';


attribute mark_debug of cnt_delay:  signal is "true";
attribute mark_debug of cnt_wait:   signal is "true";
attribute mark_debug of cnt_data:   signal is "true";
attribute mark_debug of reg:        signal is "true";
attribute mark_debug of dac_stat:   signal is "true";
attribute mark_debug of CS_I:       signal is "true";
attribute mark_debug of SDI_I:      signal is "true";
attribute mark_debug of clk_10:     signal is "true";


begin
LDAC                <= '0';
reg(0)              <= '0';
reg(1)              <= '1';
reg(2)              <= i_GA;
reg(3)              <= i_SHDN;
reg(4)              <= '0';
reg(5)              <= i_data(10);
reg(6)              <= i_data(9);
reg(7)              <= i_data(8);
reg(8)              <= i_data(7);
reg(9)              <= i_data(6);
reg(10)             <= i_data(5);
reg(11)             <= i_data(4);
reg(12)             <= i_data(3);
reg(13)             <= i_data(2);
reg(14)             <= i_data(1);
reg(15)             <= i_data(0);


process(i_clk,i_reset)
begin
   if ( enable_sck  = '1' ) then
    if(i_reset      = '1') then
      count        <=5; 
      tmp          <='0';
      elsif(rising_edge (i_clk)) then
        count      <= count+1;
      if (count     = 5) then
        tmp        <= NOT tmp;
        count      <= 1;
      else 
    end if;
  end if;
 end if;
clk_10 <= tmp;
end process;

process (i_clk) begin
  if(i_reset='1') then 
	   dac_stat        <=  S_IDLE;
	   CS_I            <= '1';
	   cnt_data        <=  0;
	   cnt_wait        <=  0;
	   cnt_delay       <=  0;

  else 
    if (falling_edge (i_clk)) then 
    	case dac_stat is 
    	  when S_IDLE =>
    	  	cnt_wait                 <= 0;
          CS_I                       <= '1';
          if (cnt_idle               <  1) then
          	cnt_idle                 <= cnt_idle +1;
    	  	else
    	  		dac_stat             <= S_WAIT;
    	  		cnt_delay            <= 0;
    	  		cnt_idle             <= 0;
    	    end if;
    	  	    	 
     	  when S_WAIT =>
           CS_I <='0';           
    	     if( cnt_wait             < 2) then 
    	   	     cnt_wait             <= cnt_wait+1;
    	     else    	   	   
    	  	   cnt_data               <= 0; 
    	  	   cnt_wait               <= 0; 
    	  	   dac_stat               <= S_DATA;	    
    	     end if;  
     
        when S_DELAY =>          
          if ( cnt_data    = 17 ) then 
             CS_I          <='1';
             SDI_I         <='0';
             cnt_data      <= 0;
             dac_stat      <= S_IDLE;
		  else 
            if ( cnt_delay  = 8 ) then             
             dac_stat      <= S_DATA;
            else 
             cnt_delay     <= cnt_delay + 1 ;
            end if;
          end if;  
 				
       
        when S_DATA =>     
			enable_sck                <= '1';           
			if( cnt_data              <  16 ) then   	
			  SDI_I                   <= reg(cnt_data);
			  cnt_data                <= cnt_data +1;
			  cnt_delay               <= 0;
		      dac_stat                <= S_DELAY;            
            else            
              cnt_data                <=  0;
              CS_I                    <= '1';
              SDI_I                   <= '0';
              dac_stat                <=  S_IDLE;
              enable_sck              <= '0';
              cnt_delay               <= 0;   
            end if;   	
    end case;
   end if;
  end if;
 end process;

SCK <=  clk_10;
SDI <=  SDI_I;
CS  <=  CS_I ;
end design;
