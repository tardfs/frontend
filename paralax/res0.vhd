library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

entity res0 is
  port (
   raw_reset    : in std_logic ;
   clk          : in std_logic ;
   reset        : out std_logic
 ) ;
end res0 ;

architecture a_res0 of res0 is
begin
process(clk)
begin
 if rising_edge(clk) then 
   reset <= not raw_reset ;
 end if ;
end process ;

end architecture ;