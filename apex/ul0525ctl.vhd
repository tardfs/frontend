library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity ul0525ctl is
  port (
	    clk50      : in std_logic ;    --  50 MHz clock
	    reset_in   : in std_logic ;    -- input reset circuit
	    reset_out  : out std_logic ;   -- start of frame
		 int        : out std_logic     -- integration signal
		 ) ;
end ul0525ctl ;

architecture arc_ul0525ctl of ul0525ctl is
signal state: integer range 0 to 4 := 0 ;
signal counter: integer range 0 to 1023 := 0 ;
begin
  process (clk)
  begin
  if rising_edge(clk50) then
	if reset_in='1' then
		-- reset circuit
		state <= 0 ;
		counter <= 15*4 ; -- 15 TMC
		int <= '0' ;
		reset_out <= '0' ;
	elsif state=0 then
	   if counter>0 then
			counter <= counter - 1 ;
		else
		   state <= 1 ;
			reset_out <= '1' ;
		end if ;
	elsif state=1 then
	   reset_out <= '0' ;
		counter <= 1024 ;
		int <= '1' ;
		state <= 2 ;
	elsif state=2 then
	   if counter>0 then
			counter <= counter - 1 ;
		else
		   state <= 3 ;
			int <= '0' ;
		end if ;
	end if ;
  end if ;
  end process ;
end architecture arc_ul0525ctl ;