library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity ul0525ctl is
  port (
	    clk50      : in std_logic ;    --  50 MHz clock
	    reset_in   : in std_logic ;    -- input reset circuit
	    clk        : out std_logic ;   -- 12.5 MHz clock
	    reset_out  : out std_logic ;   -- start of frame
		  int        : out std_logic ;   -- integration signal
		  serdat     : out std_logic     -- serial data
		 ) ;
end ul0525ctl ;

architecture arc_ul0525ctl of ul0525ctl is
  constant CLKX: integer := 4 ;
  constant H: integer := 15 ;
  constant V: integer := 5 ;  
  constant RESET_TIME: integer := 2 ;
  constant INT_TIME: integer := H ;
  constant INT_PERIOD: integer := H+17 ;
  type state_type is (ST_PowerOn,ST_Reset,ST_Operate) ;
  signal state: state_type := ST_PowerOn ;
  signal counter : integer range 0 to 16367 := 0 ;
  signal count4: integer range 0 to 3 := 0 ;
  signal period_counter : integer range 0 to 16367 := 0 ;
  signal int_counter : integer range 0 to 16367 := 0 ;
  signal line_counter : integer range 0 to 1023 := 0 ;
  signal clk12_5 : std_logic := '0' ;
  signal clk_ena : std_logic := '1' ;
begin
  clk <= clk12_5 and clk_ena ;
  process (clk50)
    begin
      if rising_edge(clk50) then
        count4 <= count4 + 1 ;
        if count4=1 then
          clk12_5 <= not clk12_5 ;
          count4 <= 0 ;
        end if ;
      end if ;
    end process ;
  process (clk50)
    begin
      if rising_edge(clk50) then
      	if reset_in='1' then
	       state <= ST_PowerOn ;
      			counter <= 0 ; -- 1 ms
      			int <= '0' ;
      			reset_out <= '0' ;
      			serdat <= '0' ;
 			 elsif state=ST_PowerOn then
 			   counter <= counter + 1 ;
 			 	 if counter=CLKX*2 then -- 1 ms power on timeout
 			 	   clk_ena <= '1' ;
 			 	   counter <= 0 ;
 			 	   reset_out <= '1' ;
 			 	   state <= ST_Reset ;
 				 end if ; 
 			 elsif state=ST_Reset then
 			   if counter<CLKX-1 then
 			     counter <= counter + 1 ;
 			   else
 			     reset_out <= '0' ;
 			     int <= '1' ;
 			 	   period_counter <= 0 ;
 			 	   int_counter <= 0 ;
 	  		 	   line_counter <= 0 ;
 			     state <= ST_Operate ;
 			   end if ;
 			 elsif state=ST_Operate then
 			   if int_counter<(INT_TIME*CLKX-1) then
 			     int_counter <= int_counter + 1 ;
 			   else 
 			     int <= '0' ;
 			   end if ;
 			   if line_counter<(V-1) then
 			     -- regular line
 			     if period_counter<(INT_PERIOD*CLKX-1) then
 			       period_counter <= period_counter + 1 ; 			     
 			     else
     			     line_counter <= line_counter + 1 ;
 			       int <= '1' ;
 			 	     period_counter <= 0 ;
 			 	     int_counter <= 0 ;
 			     end if ;
 			   else
 			     -- end of frame
 			     if period_counter<(INT_PERIOD*CLKX-1) then
 			       period_counter <= period_counter + 1 ; 			     
 			       if period_counter=((INT_PERIOD-1)*CLKX-1) then
 			         reset_out <= '1' ;
 			       end if ;
 			     else
 			       int <= '1' ;
 			 	     period_counter <= 0 ;
 			 	     int_counter <= 0 ;
 			 	     reset_out <= '0' ;
 			 	     line_counter <= 0 ;
 			     end if ; 			      			      
 			   end if ; 			   
		   end if ;
	   end if ;
  end process ;
end architecture arc_ul0525ctl ;