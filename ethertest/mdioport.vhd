-- see 22.2.4 Management functions 
-- of http://standards.ieee.org/getieee802/download/802.3-2008_section2.pdf
-- http://www.xilinx.com/support/documentation/application_notes/xapp1042.pdf
-- http://iosifk.narod.ru/el_info_fast_ethernet_mii.pdf
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity mdioport is
  port (
        
        clk50   : in std_logic ; -- system clock
        reset   : in std_logic ; -- system reset
		
        op_en   : in std_logic ; -- enable operation
        
		-- data in/out
        opcode  : in std_logic_vector(1 downto 0) ;
        phyaddr : in std_logic_vector(4 downto 0) ;
        regaddr : in std_logic_vector(4 downto 0) ;
        datain  : in std_logic_vector(15 downto 0) ;
        datout  : out std_logic_vector(15 downto 0) ;
        ready   : out std_logic ;
        
		-- mdio control interface
        mdc     : out std_logic ;
        mdio    : inout std_logic
        
        ) ;
end mdioport ;

architecture ar_mdioport of mdioport is
signal data: std_logic_vector(31 downto 0) := 
    b"01_01_10000_00000_10_00100001101_00000" ;
constant CLKX: integer := 10 ;
signal clk_mdc : std_logic := '0' ;
signal clk_count: integer range 0 to CLKX := 0 ;
signal mdc_count: integer range 0 to 32 := 0 ;
type state_type is (StateIdle,StatePreamble,StateWriteData ) ;
signal state: state_type := StateIdle ;
begin
    mdc <= clk_mdc ;
		ready <= '1' when (state=StateIdle) else '0' ;
    process(clk50)
    begin
        if rising_edge(clk50) then
            -- external control phase - reset and start op
            -- all external control is sync to clk50
            if reset='1' then
                mdio <= '1' ;
                clk_count <= 0 ;
                mdc_count <= 0 ;
                state <= StateIdle ;
                datout <= ext("0",16) ;
            elsif op_en='1' and state=StateIdle then
                datout <= ext("0",16) ;
                mdio <= '1' ;
                mdc_count <= 0 ;
                state <= StatePreamble ;
				data(31 downto 30) <= "01" ;
				data(29 downto 28) <= opcode ;
				data(27 downto 23) <= phyaddr ;
				data(22 downto 18) <= regaddr ;
				data(17 downto 16) <= "10" ;
				data(15 downto 0) <= datain ;
            else
                clk_count <= clk_count + 1 ;
                if clk_count=(CLKX-1) then
                    clk_count <=0 ;
                    clk_mdc <= '1' ; -- latch on MDIO
                elsif clk_count=(CLKX/2)-1 then
                    clk_mdc <= '0' ; -- time to prepare new data on MDIO
                    if state=StateIdle then
                        mdc_count <= 0 ;
                    elsif state=StatePreamble then
                        -- preamble is 32 bit lenght sequence of '1' 
                        if mdc_count<31 then
                            mdc_count <= mdc_count + 1 ;
                        else
                            state <= StateWriteData ;
                            mdc_count <= 1 ;
                            mdio <= data(31) ;
                        end if ;
                    elsif state=StateWriteData then
                        if mdc_count<32 then
                            if opcode(1)='0'  then -- write
                                mdio <= data(31-mdc_count) ;
                            else -- read 
                                if mdc_count<14 then
                                    mdio <= data(31-mdc_count) ;                                    
                                elsif mdc_count=14 then -- turn around
                                    mdio <= 'Z' ;
                                elsif mdc_count>15 then
                                    datout(31-mdc_count) <= mdio ;
                                end if ;
                            end if ;
                            mdc_count <= mdc_count + 1 ;
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
end architecture ar_mdioport ;
