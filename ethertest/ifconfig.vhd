-- see 22.2.4 Management functions 
-- of http://standards.ieee.org/getieee802/download/802.3-2008_section2.pdf
-- http://www.xilinx.com/support/documentation/application_notes/xapp1042.pdf
-- http://iosifk.narod.ru/el_info_fast_ethernet_mii.pdf
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity ifconfig is
  port (
        
        reset   : in std_logic ;
        clk50   : in std_logic ;
        
        mdc     : out std_logic ;
        mdio    : inout std_logic 
        
		) ;
end ifconfig ;

architecture ar_ifconfig of ifconfig is
signal data: std_logic_vector(31 downto 0) := 
    b"01_01_10000_00000_10_00100001101_00000" ;
constant CLKX: integer := 10 ;
signal clk_mdc : std_logic := '0' ;
signal clk_count: integer range 0 to CLKX ;
signal mdc_count: integer range 0 to 32 ;
type state_type is (StateIdle,StatePreamble,StateWriteData ) ;
signal state: state_type := StatePreamble ;
begin
    mdc <= clk_mdc ;
    process(clk50)
    begin
        if rising_edge(clk50) then
            if reset='1' then
                mdio <= '1' ;
                clk_count <= 0 ;
                mdc_count <= 0 ;
                state <= StatePreamble ;
            else
                clk_count <= clk_count + 1 ;
                if clk_count=(CLKX-1) then
                    clk_count <=0 ;
                    clk_mdc <= '1' ;
                elsif clk_count=(CLKX/2)-1 then
                    clk_mdc <= '0' ;
                    if state=StateIdle then
                        mdc_count <= 0 ;
                    elsif state=StatePreamble then
                        if mdc_count<31 then
                            mdc_count <= mdc_count + 1 ;
                        else
                            state <= StateWriteData ;
                            mdc_count <= 1 ;
                            mdio <= data(31) ;
                        end if ;
                    elsif state=StateWriteData then
                        if mdc_count<32 then
                            mdc_count <= mdc_count + 1 ;
                            mdio <= data(31-mdc_count) ;
                        else
                            mdio <= '1' ;
                            mdc_count <= 0 ;
                            state <= StateIdle ;
                        end if ;
                    end if ;
                end if ;
            end if ;
        end if ;
    end process ;
end architecture ar_ifconfig ;
