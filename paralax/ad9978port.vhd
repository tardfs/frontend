library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity ad9978port is
  port (

   reset        : in std_logic ;
   clk          : in std_logic ;
   ch_data_addr : in std_logic_vector(23 downto 0) ;
   wr           : in std_logic ;
   
   sl      : out std_logic ; -- SL signal
   sdata   : out std_logic ; -- SDATA signal
   sck     : out std_logic   -- SCK signal
 
 ) ;
end ad9978port ;

architecture arc_ad9978port of ad9978port is
 signal datareg: std_logic_vector(23 downto 0) ;
 signal count: integer range 0 to 23 := 0 ;
 type state_type is (StateIdle,StateTrx) ;
 signal state: state_type := StateIdle ;
begin
 sck <= not clk ;
 process(clk)
 begin
   if reset='1' then
      state <= StateIdle ;
      SL <= '1' ;
   elsif rising_edge(clk) then
      case state is
       when StateIdle =>
         if wr='1' then 
            datareg <= ch_data_addr ;
            count <= 0 ;
            state <= StateTrx ;
         end if ;
       when StateTrx => 
         if count<23 then
            sl <= '0' ; 
            sdata <= datareg(0) ;
            datareg <= '0' & datareg(23 downto 1) ;
            count <= count + 1 ;
         else
            sl <= '1' ;
            state <= StateIdle ;
         end if ;
      end case ;
   end if ;
 end process ;
end architecture ;
