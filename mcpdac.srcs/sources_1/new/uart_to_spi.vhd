library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_to_spi is
  Port ( 
    i_clk         : in  std_logic;
    i_reset       : in  std_logic;
    i_rx_en       : in  std_logic;
    i_tx_done     : in  std_logic;
    i_uart_data   : in  std_logic_vector (7 downto 0 );
    o_controller  : out std_logic_vector (3 downto 0 );
    o_tx_en       : out std_logic;
    o_uart_data   : out std_logic_vector (7 downto 0 )
 
  );
end uart_to_spi;

architecture Behavioral of uart_to_spi is

type data_1 is array (0 to 22) of std_logic_vector( 7 downto 0 ) ;
signal S_1_DATA: data_1 := (x"53",x"45",x"4C",x"45",x"43",x"54",x"45",x"44",x"20",x"57",x"41",x"56",x"45",x"3A",x"20",x"53", x"51", x"55", x"41",x"52",x"45",x"0D",x"0A");

type data_2 is array (0 to 20) of std_logic_vector( 7 downto 0 ) ;
signal S_2_DATA: data_2 := (x"53",x"45",x"4C",x"45",x"43",x"54",x"45",x"44",x"20",x"57",x"41",x"56",x"45",x"3A",x"20",x"53", x"49", x"4E", x"45",x"0D",x"0A");

type data_3 is array (0 to 21) of std_logic_vector( 7 downto 0 ) ;
signal S_3_DATA: data_3 := (x"53",x"45",x"4C",x"45",x"43",x"54",x"45",x"44",x"20",x"57",x"41",x"56",x"45",x"3A",x"20",x"54", x"52", x"49", x"41",x"4E",x"0D",x"0A");

type data_4 is array (0 to 20) of std_logic_vector( 7 downto 0 ) ;
signal S_4_DATA: data_4 := (x"53",x"45",x"4C",x"45",x"43",x"54",x"45",x"44",x"20",x"57",x"41",x"56",x"45",x"3A",x"20",x"52", x"41", x"4D", x"50",x"0D",x"0A");

type data_0 is array (0 to 15) of std_logic_vector( 7 downto 0 ) ;     
signal S_0_DATA: data_0 := (x"55", x"41", x"52", x"54",x"20",x"4E",x"45",x"54",x"41",x"20",x"32",x"30",x"32",x"33",x"0D",x"0A");  

type data_v is array (0 to 8) of std_logic_vector ( 7 downto 0 ) ;    
signal S_V_DATA: data_v := (x"49", x"4E", x"56", x"41",x"4C",x"49",x"44",x"0D",x"0A"); 

type data_welcome is array (0 to 73) of std_logic_vector( 7 downto 0 ) ;         
signal S_welcome_DATA: data_welcome := (x"4E",x"45",x"54",x"41",x"20",x"55",x"41",x"52",x"54",x"20",x"56",x"45",x"52",x"31",
x"2E",x"30",x"20",x"13",x"10",x"50",x"4C",x"45",x"41",x"53",x"45",x"20",x"53",x"45",x"4C",x"45",x"43",x"54",x"20",x"57",x"41",x"56",x"45",
x"0D",x"0A",x"31",x"2D",x"53", x"51", x"55", x"41",x"52",x"45",
x"0D",x"0A",x"32",x"2D",x"53", x"49", x"4E", x"45",
x"0D",x"0A",x"33",x"2D",x"54", x"52", x"49", x"41",x"4E",
x"0D",x"0A",x"34",x"2D",x"52", x"41", x"4D", x"50",x"0D",x"0A");



type      uart_data is (S_IDLE,S_DATA,S_0,S_1,S_2,S_3,S_4,S_V,S_ENTER,S_WELCOME,S_WAIT);
signal    uart_data_write   : uart_data := S_IDLE; 

signal    enable            : std_logic;
signal    counter           : integer:=0;
signal    none              : std_logic;
signal    i_tx_done_d1      : std_logic;
signal    i_tx_done_re      : std_logic;
signal    data_sig          : std_logic_vector ( 2 downto 0 ) ;
signal    counter_enter     : integer:=0;

begin
 
process (i_clk) begin
    if(i_reset='1') then 
       uart_data_write      <=  S_IDLE;
  	   o_controller         <= "1111";
  	   data_sig             <= "000"; 
  	   counter_enter        <= 0;
    else 
      if (rising_edge (i_clk)) then 
      	i_tx_done_d1 <= i_tx_done;                
      	i_tx_done_re <= i_tx_done and not i_tx_done_d1;


      	case uart_data_write is 
 
      when S_IDLE =>       
        counter_enter                <=  0;
        data_sig                     <=  "000";
        o_uart_data                  <=  S_welcome_DATA(counter); 
        counter                      <=  counter + 1 ;     
        uart_data_write              <=  S_WELCOME;
                        
      
      when S_WELCOME =>                                      
        o_tx_en                      <= '1';                     
          if ( i_tx_done_re          = '1' ) then                
            if ( counter             <  data_welcome'length+1 ) then                
              o_uart_data            <= S_welcome_DATA(counter);       
              counter                <= counter + 1;             
            else                                                                       
                 uart_data_write     <=  S_WAIT;                 
                 counter             <=  0 ;                     
                 o_tx_en             <= '0';                     
                 o_uart_data         <= (others=>'0');           
            end if;
          else
            uart_data_write          <= S_WELCOME;
          end if;                                              
                                 
      
      when S_WAIT => 
        counter_enter       <= 0;
        data_sig            <= "000";
        if (i_rx_en = '1') then  
          uart_data_write   <=  S_DATA;
        else 
          uart_data_write   <=  S_WAIT;
        end if;

    
        
      when S_DATA =>  
        o_tx_en <= '1'; 
        counter <= 0; 
       if   ( i_uart_data =  x"30"  ) then  --0                   
         if ( i_tx_done_re          = '1' ) then  
           o_uart_data       <= S_0_DATA(0);
           counter           <= counter + 1 ;
           uart_data_write   <=  S_0; 
         else 
           uart_data_write   <=  S_DATA;
         end if;

       elsif ( i_uart_data =  x"31" ) then  --1
        if ( i_tx_done_re          = '1' ) then        
          uart_data_write   <=  S_1;
          o_uart_data       <= S_1_DATA(0);
          counter           <= counter + 1 ;
        else 
          uart_data_write   <=  S_DATA;
        end if;
        
       elsif ( i_uart_data =  x"32") then  --2
         if ( i_tx_done_re          = '1' ) then        
           uart_data_write   <=  S_2;
           o_uart_data       <=  S_2_DATA(0); 
           counter           <= counter + 1 ;
         else 
          uart_data_write    <=  S_DATA;
         end if;
         
         
       elsif ( i_uart_data =  x"33") then --3
         if ( i_tx_done_re          = '1' ) then
           uart_data_write   <=  S_3;
           o_uart_data       <= S_3_DATA(0); 
           counter           <= counter + 1 ;
         else                            
          uart_data_write    <=  S_DATA;   
         end if;                
         
                   
       elsif  ( i_uart_data = x"34") then --4
         if ( i_tx_done_re          = '1' ) then      
           uart_data_write    <=  S_4;
           o_uart_data        <= S_4_DATA(0); 
           counter            <= counter + 1 ;
         else                               
           uart_data_write    <=  S_DATA;    
         end if;                                    
       
       else
        if ( i_tx_done_re     = '1' ) then           
          uart_data_write    <=  S_V;            
          o_uart_data        <=  S_V_DATA(0);     
          counter            <= counter + 1 ;    
        else                                     
          uart_data_write    <=  S_DATA;         
        end if;                                  
 
        end if;

      when S_0 =>                                       
        o_tx_en                 <= '1';                 
        if ( i_tx_done_re       = '1' ) then            
          if ( counter          <  data_0'length-1 ) then             
            o_uart_data         <= S_0_DATA(counter);   
            counter             <= counter + 1;         
          else                                          
            counter             <=  0 ;                 
            o_tx_en             <= '0';                 
            uart_data_write     <= S_WAIT;
            o_uart_data         <= (others=>'0');
          end if;                                       
        else                                            
            none                <= '0';                 
        end if;                                         
 
   
      when S_1 =>  
        o_tx_en                 <= '1'; 
        if ( i_tx_done_re        = '1' ) then
          if ( counter          <  data_1'length ) then               
            o_uart_data         <= S_1_DATA(counter);
            counter             <= counter + 1; 
          else 
            counter             <=  0 ;
            uart_data_write     <=  S_ENTER;
            data_sig            <=  "001"; 
            o_uart_data         <= (others=>'0');
          end if;
        else 
            uart_data_write     <= S_1;       
        end if;

        when S_2 =>  
        o_tx_en               <= '1';
        if ( i_tx_done_re      = '1' ) then
          if ( counter        < data_2'length) then            
            o_uart_data       <= S_2_DATA(counter);
            counter           <= counter + 1; 
           else 
            counter           <=  0 ;          
            uart_data_write   <= S_ENTER;
            data_sig          <= "010";        
            o_uart_data       <= (others=>'0');
          end if;
        else 
          uart_data_write     <= S_2;       
        end if;
       
        when S_3 =>  
        o_tx_en                   <= '1'; 
          if ( i_tx_done_re       = '1' ) then
            if ( counter          <  data_3'length ) then  
            o_uart_data           <= S_3_DATA(counter);
            counter               <= counter + 1; 
          else 
            counter               <=  0 ;           
            uart_data_write       <= S_ENTER;
            data_sig              <= "011";         
            o_uart_data           <= (others=>'0'); 
          end if;
          else 
            uart_data_write       <= S_3;     
          end if;
       
        when S_4 =>  
        o_tx_en                   <= '1';
          if ( i_tx_done_re       = '1' ) then 
            if ( counter          <  data_4'length ) then        
              o_uart_data         <= S_4_DATA(counter);
              counter             <= counter + 1; 
            else 
              counter             <=  0 ;            
              uart_data_write     <= S_ENTER;
              data_sig            <= "100";          
              o_uart_data         <= (others=>'0');                                  
          end if;
          else 
           uart_data_write        <= S_4;            
         end if;
         
         when S_V =>                                   
         o_tx_en                  <= '1';                 
         if ( i_tx_done_re         = '1' ) then           
           if ( counter           <  data_v'length+1 ) then             
             o_uart_data          <= S_V_DATA(counter);   
             counter              <= counter + 1;         
            else                                          
             counter              <=  0 ;                 
             uart_data_write      <= S_WAIT;              
             o_uart_data          <= (others=>'0');       
           end if;                                     
         else                                          
           uart_data_write        <= S_V;                 
         end if;                                       
      
         when S_ENTER =>                                          
           if ( counter_enter < 500_000_000) then 
             counter_enter    <= counter_enter + 1; 
             if   ( i_uart_data =  x"0D" and  data_sig = "001"  ) then          
               if ( i_tx_done_re    = '1' ) then                                         
                 o_controller      <= "0001";
                 uart_data_write   <=  S_WAIT;
                 data_sig          <= "000";                 
               else                                          
                 uart_data_write   <=  S_ENTER;               
               end if;                                        
             elsif ( i_uart_data =  x"0D" and  data_sig = "010"  ) then    
               if ( i_tx_done_re    = '1' ) then                          
                 o_controller      <= "0010";
                 uart_data_write   <=  S_WAIT; 
                 data_sig          <= "000";                                
               else                                                       
                 uart_data_write   <=  S_ENTER;                           
               end if;                                                    
             elsif ( i_uart_data =  x"0D" and  data_sig = "011"  ) then 
               if ( i_tx_done_re    = '1' ) then                        
                 o_controller      <= "0100";                           
                 uart_data_write   <=  S_WAIT;                          
                 data_sig          <= "000";                            
               else                                                     
                 uart_data_write   <=  S_ENTER;                         
               end if;                                                  
             elsif ( i_uart_data =  x"0D" and  data_sig = "100"  ) then 
               if ( i_tx_done_re    = '1' ) then                        
                 o_controller      <= "1000";                           
                 uart_data_write   <=  S_WAIT;                          
                 data_sig          <= "000";                            
               else                                                     
                 uart_data_write   <=  S_ENTER;                         
               end if;                                                  
             else 
               uart_data_write     <=  S_ENTER;
             end if;
           else  
               uart_data_write     <=  S_WAIT;
               counter_enter       <=  0;
           end if;                
      end case;
     end if;
    end if;
  end process;  
   
end Behavioral;


