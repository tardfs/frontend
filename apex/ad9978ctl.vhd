library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity ad9978ctl is
  port (
	   clk50   : in std_logic ; --  50 MHz clock 
	   reset   : in std_logic ; --  async reset
		 SL      : out std_logic ; -- SL signal
		 SDATA   : out std_logic ; -- SDATA signal
		 SCK     : out std_logic ; -- SCK signal
		 HD      : out std_logic ; -- HD signal
		 VD      : out std_logic   -- VD signal
		 ) ;
end ad9978ctl ;

architecture arc_ad9978ctl of ad9978ctl is
begin
  process (clk)
  begin
  if rising_edge(clk) then
	if reset='1' then
		-- reset circuit
		HD <= '1' ;
		VD <= '1' ;		
		SL <= '1' ;
		SDATA <= '1' ;
		SCK <= '1' ;
	else
	end if ;
  end if ;
  end process ;
end architecture arc_ad9978ctl ;