library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity dataport is
  port (
        data       : in std_logic_vector(31 downto 0) ;
        clk        : in std_logic ;
		  reset      : in std_logic
		) ;
end dataport ;

architecture a_dataport of dataport is
begin
end architecture a_dataport ;


