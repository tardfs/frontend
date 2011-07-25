library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity ul0525ctl is
  port (
	    clk     : in std_logic ; --  12.5 MHz clock 
	    reset   : in std_logic ;
		 int     : out std_logic
		 ) ;
end ul0525ctl ;

architecture arc_ul0525ctl of ul0525ctl is
begin
  process (clk)
  begin
  if rising_edge(clk) then
	if reset='1' then
		-- reset circuit
		int <= '1' ;
	else
		int <= '0' ;
	end if ;
  end if ;
  end process ;
end architecture arc_ul0525ctl ;