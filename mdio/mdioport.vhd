-- see 22.2.4 Management functions 
-- of http://standards.ieee.org/getieee802/download/802.3-2008_section2.pdf
-- http://www.xilinx.com/support/documentation/application_notes/xapp1042.pdf
-- http://iosifk.narod.ru/el_info_fast_ethernet_mii.pdf
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity mdioport is
  generic (
        phyaddr : std_logic_vector(4 downto 0) := "10000" 
        ) ;
  port (
        
        clk     : in std_logic ; -- system clock
        reset   : in std_logic ; -- system reset
        op_en   : in std_logic ; -- enable operation
        
        ifread  : in std_logic ;
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
signal mdo    : std_logic := '1' ;
signal ena_mdo: std_logic := '0' ; -- mdo enable
signal databuf: std_logic_vector(31 downto 0) ;
signal mdioreg: std_logic_vector(31 downto 0) ;
signal rdreg: std_logic_vector(15 downto 0) ;
signal counter: std_logic_vector(5 downto 0) ;
type state_type is (StateIdle,StatePreamble,StateData) ;
signal local_mdc: std_logic:='0' ;
signal local_ifread: std_logic := '0' ;
signal state: state_type := StateIdle ;
begin
    mdc <= local_mdc ;
    mdo <= mdioreg(31) when state=StateData else '1' ;
    mdio <= mdo when ena_mdo='1' else 'Z' ;
    process(clk)
	begin
        if rising_edge(clk) then
            local_mdc <= not local_mdc ;
        end if ;
    end process ;
    process (reset,clk)
	variable rdvar: std_logic_vector(15 downto 0) ;
	begin
        if reset='1' then
            ena_mdo <= '1' ;
            mdioreg <= b"01_10_10000_00010_10_0000000000000000" ;
            state <= StateIdle ;
            ready <= '1' ;
        elsif rising_edge(clk) then
            case state is
                when StateIdle =>
                    if op_en='1' then
                        ena_mdo <= '1' ;
                        counter <= b"000001" ;
                        state <= StatePreamble ;
                        local_ifread <= ifread ;
                        ready <= '0' ;
                        
                        --mdioreg(31) <= "01" & ifread & not ifread & phyaddr & regaddr & "10" & datain ;
                        --mdioreg(31 downto 28) <= "01" & ifread & not ifread ;

                        -- databuf(31 downto 30) <= b"01" ;
                        -- databuf(29) <= ifread ;
                        -- databuf(28) <= not ifread ;
                        -- databuf(27 downto 23) <= phyaddr ;
                        -- mdioreg(22 downto 18) <= regaddr ;                        
                        -- mdioreg(17 downto 16) <= b"10" ;
                        -- databuf(15 downto 0) <= datain ;                                               
                    end if ;
                when StatePreamble =>
                    if local_mdc='1' then
                        if counter(5)='0' then
                            counter <= counter + 1 ;
                        else
                            state <= StateData ;
                            counter <= b"000001" ;
                        end if ;
                    end if ;
                when StateData =>
					if counter(5)='0' then
						-- drive mdo
						if local_mdc='1' then
							mdioreg(31 downto 1) <= mdioreg(30 downto 0) ;
						end if ;
						if local_ifread='1' then
							if counter="01110" then
								ena_mdo <= '0' ;
							end if ;
							if ena_mdo='0' then
                                rdreg <= rdreg(14 downto 0) & mdio ;
							end if ;
						end if ;
						counter <= counter + 1 ;
					else
						state <= StateIdle ;
						datout <= rdreg ;
                        ready <= '1' ;
					end if ;
            end case ;
        end if ;
    end process ;               
end architecture ar_mdioport ;
