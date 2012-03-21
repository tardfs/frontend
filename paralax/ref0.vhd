library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

entity ref0 is
  port (
   raw_clk    : in std_logic ;
   clk2       : out std_logic ;
   clk4       : out std_logic
 ) ;
end ref0 ;

architecture a_ref0 of ref0 is
signal count: std_logic_vector(1 downto 0) := b"00" ;
begin
clk2 <= count(0) ;
clk4 <= count(1) ;
process(raw_clk)
begin
 if rising_edge(raw_clk) then 
   count <= count + 1 ;
 end if ;
end process ;

end architecture ;