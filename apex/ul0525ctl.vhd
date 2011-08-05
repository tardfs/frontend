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
		  int        : out std_logic     -- integration signal
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
begin
  clk <= clk12_5 ;
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
      			counter <= 0 ; -- 15 TMC
      			int <= '0' ;
      			reset_out <= '0' ;
 			 elsif state=ST_PowerOn then
 			   counter <= counter + 1 ;
 			 	 if counter=(14*CLKX) then
 			 	   counter <= 0 ;
 			 	   reset_out <= '1' ;
 			 	   state <= ST_Reset ;
 				 end if ;
 			 elsif state=ST_Reset then
 			   counter <= counter+1 ;
 			   if counter=(RESET_TIME*CLKX) then
 			     reset_out <= '0' ;
 			   elsif counter=(RESET_TIME+1)*CLKX
 			     int <= '1' ;
 			     counter <= 0 ;
 			     state <= ST_Operate ;
 			 	   period_counter <= 0 ;--INT_PERIOD*CLKX ;
 			 	   int_counter <= 0 ;--INT_TIME*CLKX ;
 	  		 	   line_counter <= 0 ;
 			 	   state <= ST_Operate ;
 			   end if ;
 			 elsif state=ST_Operate then
 			   period_counter <= period_counter + 1 ;
 			   if int_counter<(INT_TIME*CLKX-1) then
 			     int_counter <= int_counter + 1 ;
 			   else 
 			     int <= '0' ;
 			   end if ;
 			   if period_counter<(INT_TIME*CLKX-1) then
 			   else
 			   end if ;
 			   
 			 	 if int_counter=0 then
   			 	  int <= '0' ;
 			 	 else
 			 	  int_counter <= int_counter - 1 ; 
 			 	 end if ;
 			 	 if period_counter=0 then
 			 	   if line_counter=(V-1) then
 			 	     state <= ST_Reset ;
 			 	     line_counter <= 0 ;
 			 	   else
     			 	   int <= '1' ;
 			 	     line_counter <= line_counter+1 ;
 			 	   end if ;
 			 	 else
 			 	   period_counter <= period_counter-1 ;
 			 	 end if ;
		   end if ;
	   end if ;
  end process ;
end architecture arc_ul0525ctl ;