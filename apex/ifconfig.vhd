-- see 22.2.4 Management functions 
-- of http://standards.ieee.org/getieee802/download/802.3-2008_section2.pdf
-- http://www.xilinx.com/support/documentation/application_notes/xapp1042.pdf
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity ifconfig is
  port (
        
        reset   : in std_logic ;
        clk50   : in std_logic ;
        
        mdc     : out std_logic ;
        mdio    : inout std_logic ;
        
		) ;
end ifconfig ;

architecture arc_ifconfig of ifconfig is
constant CLKX: integer := 10 ;
signal clk_mdc : std_logic := '0' ;
signal clk_count: integer range 0 to CLKX ;
type state_type is (StateIdle,StatePreamble,StateSfd,
                    StateDeviceAddr,StateRegAddr,StateTurnAround,
                    StateRegData ) ;
signal state: type := StateIdle ;
begin
    mdc <= clk_mdc ;
    if rising_edge(clk50) then
        if reset='1' then
            mdio <= '1' ;
            clk_count = 0 ;
            state <= StateIdle ;
        else
            clk_count <= clk_count + 1 ;
            if clk_count=(CLKX-1) then
                clk_mdc <= '1' ;
            elsif  clk_count=(CLKX/2) then
                clk_mdc <= '0' ;
            end if ;
        end if ;
    end if ;
end architecture ifconfig ;
