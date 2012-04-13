library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity hvsync is
  port (
        clk        : in std_logic ;
        reset      : in std_logic ;
        ul_reset   : out std_logic ;
        ul_int     : out std_logic ;
        ad_hd      : out std_logic ;
        ad_vd      : out std_logic 
		 ) ;
end hvsync ;

architecture a_hvsync of hvsync is
  constant H: integer := 10 ;
  constant V: integer := 2 ;
  constant INT_TIME: integer := 2 ;
  constant INT_PERIOD: integer := H+17 ;
  signal count: integer range 0 to 2047 := 0 ;
  signal lcount: integer range 0 to 1023 := 0 ;
begin
process(clk,reset)
begin
  if reset='1' then
    count <= INT_PERIOD-3 ;
    lcount <= V-1 ;
    ul_reset <= '0' ;
    ul_int <= '0' ;
    ad_hd <= '1' ;
    ad_vd <= '1' ;
  elsif rising_edge(clk) then
    count <= count + 1 ;
    case count is
      when 0 =>
        ul_int <= '1' ;
      when INT_TIME =>
        ul_int <= '0' ;
      when INT_TIME+17 =>
        ad_hd <= '0' ;
        if lcount=V-1 then
         ad_vd <= '0' ;
        end if ;
      when INT_TIME+18 =>
        ad_hd <= '1' ;
        ad_vd <= '1' ;
      when INT_PERIOD-2 =>
        if lcount=V-1 then
          ul_reset <= '1' ;
          lcount <= 0 ;
        else
          lcount <= lcount + 1 ;
        end if ;
      when INT_PERIOD-1 =>
        ul_reset <= '0' ;
        count <= 0 ;
      when others =>
    end case ;
  end if ;
end process ;
end architecture a_hvsync ;
