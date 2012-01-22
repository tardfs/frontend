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
        
        status  : out std_logic_vector(3 downto 0) ;
        
        mdc     : out std_logic ;
        mdio    : inout std_logic 
        
        ) ;
end ifconfig ;

architecture ar_ifconfig of ifconfig is
constant PHY_ADDR: std_logic_vector(4 downto 0) := "10000" ;
constant REG_ID0: std_logic_vector(4 downto 0)  := "00010" ;
constant REG_ID1: std_logic_vector(4 downto 0)  := "00011" ;

constant MPHY_CONTROL_REG: std_logic_vector(4 downto 0) := b"00000" ;
constant MPHY_CONTROL_LOOPBACK      : integer := 14 ;
constant MPHY_CONTROL_AUTONEG       : integer := 12 ;
constant MPHY_CONTROL_SPD_SEL_LSB   : integer := 13 ;
constant MPHY_CONTROL_SPD_SEL_MSB   : integer := 6 ;
constant MPHY_CONTROL_SPD_SEL_1000  : integer := 1 ;
constant MPHY_CONTROL_SPD_SEL_100   : integer := 0 ;
--       MPHY_CONTROL_SPD_SEL_10    : bits 0,1 <= "00" ;
constant MPHY_CONTROL_RSTRT_AUTONEG : integer := 9 ;
constant MPHY_CONTROL_DUPLEX        : integer := 8 ;

constant MPHY_STATUS_REG: std_logic_vector(4 downto 0) := b"00001" ;
constant MPHY_STATUS_LINK           : integer := 2 ;

constant MPHY_1000BT_CONTROL_REG: std_logic_vector(4 downto 0) := b"01001" ;
constant MPHY_1000BT_CONTROL_ADV_1000BT_FD: integer := 9 ;
constant MPHY_1000BT_CONTROL_ADV_1000BT_HD: integer := 8 ;

constant MPHY_SPCFC_STAT_SPD_1000      : integer := 15 ;
constant MPHY_SPCFC_STAT_SPD_100       : integer := 14 ;
constant MPHY_SPCFC_STAT_SPD_10        : integer := 13 ;
constant MPHY_SPCFC_STAT_DUPLEX        : integer := 12 ;
constant MPHY_SPCFC_STAT_SPD_DUP_RSLVD : integer := 10 ;
constant MPHY_SPCFC_STAT_LINK_RT       : integer := 9 ;       
constant MPHY_SPCFC_STAT_MDIX          : integer := 8 ;
 
constant ID0_MARVELL_OUI: std_logic_vector(15 downto 0) := x"0141" ;

type state_type is (StateIdle,StatePreamble,StateWriteData) ;
signal state: integer range 0 to 1023 := 0 ;
component mdioport is
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
end component ;
signal op_en : std_logic := '0' ;
signal opcode  : std_logic_vector(1 downto 0) ;
signal phyaddr : std_logic_vector(4 downto 0) ;
signal regaddr : std_logic_vector(4 downto 0) ;
signal datain  : std_logic_vector(15 downto 0) ;
signal datout  : std_logic_vector(15 downto 0) ;
signal ready   : std_logic ;
signal start0  : std_logic := '0' ;

begin
port0:
mdioport
    port map (
        clk50 => clk50,
        reset => reset,
        op_en => op_en,
        opcode => opcode,
        phyaddr => phyaddr,
        regaddr => regaddr,
        datain => datain,
        datout => datout,
        ready => ready,
        mdc => mdc,
        mdio => mdio        
    ) ;
    process(clk50)
    variable data16: std_logic_vector(15 downto 0) ;
    begin
        if rising_edge(clk50) then
            if reset='1' then
                state <= 0 ;
                status <= "0000" ;
            else
                op_en <= '0' ;
                if start0='1' then
                    op_en <= '1' ;
                    start0 <= '0' ;
                elsif ready='1' and state<10 then
                    if state=0 then
                        -- prepare read Id0
                        opcode <= "10" ;
                        phyaddr <= PHY_ADDR ;
                        regaddr <= REG_ID0 ;
                        start0 <= '1' ;
                        state <= state + 1 ;
                    elsif state=1 then
                        -- check ID0
                        if datout=ID0_MARVELL_OUI then
                            status(0) <= '1' ;
                        end if ;
                        state <= state + 1 ;
                    elsif state=2 then
                        -- read status
                        opcode <= "10" ;
                        phyaddr <= PHY_ADDR ;
                        regaddr <= MPHY_STATUS_REG ;
                        start0 <= '1' ;
                        state <= state + 1 ;
                    elsif state=3 then
                        if datout(MPHY_SPCFC_STAT_LINK_RT)='1' then
                            -- link is Ok
                            status(1) <= '1' ;
                            if datout(MPHY_SPCFC_STAT_SPD_10)='1' then
                                -- link speed is 10Mbps
                                status(2) <= '1' ;
                                state <= 7 ;
                            else
                                -- link speed is not 10Mbps, re-negotiate
                                -- 1) read 1000Mbps control register
                                opcode <= "10" ;
                                phyaddr <= PHY_ADDR ;
                                regaddr <= MPHY_1000BT_CONTROL_REG ;
                                start0 <= '1' ;
                                state <= state + 1 ;                                
                            end if ;
                        else
                            -- link is not ready - wait
                            state <= 2 ;
                        end if ;
                    elsif state=4 then
                        -- disable 1000Mbps mode
                        data16 := datout ;
                        data16(MPHY_1000BT_CONTROL_ADV_1000BT_FD) := '0' ;
                        data16(MPHY_1000BT_CONTROL_ADV_1000BT_HD) := '0' ;
                        opcode <= "01" ;
                        phyaddr <= PHY_ADDR ;
                        regaddr <= MPHY_1000BT_CONTROL_REG ;
                        datain <= data16 ;
                        start0 <= '1' ;
                        state <= state + 1 ;                                
					elsif state=5 then
                        -- read control register
                        opcode <= "10" ;
                        phyaddr <= PHY_ADDR ;
                        regaddr <= MPHY_CONTROL_REG ;
                        start0 <= '1' ;
                        state <= state + 1 ;                        
                    elsif state=6 then
                        -- start negotiate
                        opcode <= "01" ;
                        phyaddr <= PHY_ADDR ;
                        regaddr <= MPHY_CONTROL_REG ;
                        data16 := datout ;
                        data16(MPHY_CONTROL_RSTRT_AUTONEG) := '1' ;
                        datain <= data16 ;
                        start0 <= '1' ;
                        state <= 2 ; -- got to read status                
                    elsif state=7 then
                        -- ok, configuration is done!
                        -- this is final state
                    else
                    end if ;
                else
                end if ;
            end if ;
        end if ;
    end process ;
end architecture ar_ifconfig ;
