library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity hvsync is
  port (
	    clk        : in std_logic ;
	    reset      : in std_logic ;
        ul_reset   : out std_logic ;
        ul_int     : out std_logic
		 ) ;
end hvsync ;

architecture a_hvsync of hvsync is
  constant H: integer := 1024 ;
  constant V: integer := 768 ;
  constant INT_TIME: integer := H ;
  constant INT_PERIOD: integer := H+17 ;
  signal count: std_logic_vector(10 downto 0) := b"000_0000_0000" ;
begin
process(clk,reset)
begin
  if reset='1' then
    count <= b"000_0000_0000" ;
  elsif rising_edge(clk) then
    count <= count + 1 ;
    case count is
      when b"000_0000_0000" =>
        ul_int <= '1' ;
      when (b"000_0000_0000"+INT_TIME) =>
        ul_int <= '0' ;
      when (b"000_0000_0000"+(INT_PERIOD-1)) =>
        count <= b"000_0000_0000" ;
    end case ;
  end if ;
end
end architecture a_hvsync ;
