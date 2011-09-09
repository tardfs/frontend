-- see 22.2.4 Management functions 
-- of http://standards.ieee.org/getieee802/download/802.3-2008_section2.pdf
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity ifconfig is
  port (
        
        reset   : in std_logic ;
        clk     : in std_logic ;
        
        mdc     : out std_logic ;
        mdio    : inout std_logic ;
        
		) ;
end ifconfig ;

architecture arc_ifconfig of ifconfig is
type state_type is (Idle,WriteReg) ;
signal state: type := Idle ;
begin
  if rising_edge(clk50) then
	if reset='1' then
        mdio <= 'z' ;
    else
    end if ;
  end if ;
end architecture ifconfig ;
