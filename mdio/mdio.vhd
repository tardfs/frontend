library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;
entity mdio is
  port (
        
    clock_50    : in std_logic ;
    clock2_50   : in std_logic ;
    clock3_50   : in std_logic ;
		
    key             : in std_logic_vector(3 downto 0) ;
    ledr            : out std_logic_vector(17 downto 0) ;
    ledg            : out std_logic_vector(8 downto 0) ;
	
    enet0_gtx_clk   : out std_logic ;
    enet0_int_n     : in std_logic ;
    enet0_link100   : in std_logic ;
    enet0_mdc       : out std_logic ;
    enet0_mdio      : inout std_logic ;
    enet0_rst_n     : out std_logic ; 
    
    enet0_rx_clk    : in std_logic ;
    enet0_rx_col    : in std_logic ;
    enet0_rx_crs    : in std_logic ;
    enet0_rx_data   : in std_logic_vector(3 downto 0) ;
    enet0_rx_dv     : in std_logic ;
    enet0_rx_er     : in std_logic ;
    
    enet0_tx_clk    : in std_logic ;
    enet0_tx_data   : out std_logic_vector(3 downto 0) ;
    enet0_tx_en     : out std_logic ;
    enet0_tx_er     : out std_logic ;
    enetclk_25      : in std_logic  
		 ) ;
end mdio ;
architecture ar_mdio of mdio is
component mdioport is
  generic (
        phyaddr : std_logic_vector(4 downto 0) := "10000" 
        ) ;
  port (
        
        clk     : in std_logic ; -- clock
        reset   : in std_logic ; -- system reset
        
        op_en   : in std_logic ; -- enable operation
        
        -- data in/out
        ifread  : in std_logic ;
        regaddr : in std_logic_vector(4 downto 0) ;
        datain  : in std_logic_vector(15 downto 0) ;
        datout  : out std_logic_vector(15 downto 0) ;
        ready   : out std_logic ;
        
        -- mdio control interface
        mdc     : out std_logic ;
        mdio    : inout std_logic
        
        ) ;
end component ;
signal reset: std_logic := '0' ; 
signal eth_reset: std_logic := '0' ;
signal counter: std_logic_vector(5 downto 0) := b"000000" ;
signal mdio_clock: std_logic := '0' ;
signal op_en : std_logic := '0' ;
signal ifread : std_logic := '1' ;
signal regaddr : std_logic_vector(4 downto 0) := b"00010" ;
signal datain : std_logic_vector(15 downto 0) := b"0000_0000_0000_0000" ;
signal datout : std_logic_vector(15 downto 0) := b"0000_0000_0000_0000" ;
begin
--port0:
--mdioport
--    port map (
--        clk => mdio_clock,
--        reset => reset,
--        op_en => op_en,
--        ifread => ifread,
--        regaddr => regaddr,
--        datain => datain,
--        datout => datout,
--        ready => ledg(0),
--        mdc => enet0_mdc,
--        mdio => enet0_mdio        
--    ) ;
	
mdio_clock <= counter(5) ;
ledr(15 downto 0) <= datout ;
enet0_rst_n <= eth_reset ;

ledg(1) <= reset ;
ledg(2) <= op_en ;

make_control:process(clock_50)
begin
	if rising_edge(clock_50) then
		reset <= not key(0) ;
		op_en <= not key(1) ;
		eth_reset <= key(2) ;
	end if ;
end process ;

make_clock:process(clock_50)
begin
	if rising_edge(clock_50) then
		counter <= counter + 1 ;
	end if ;
end process ;

end architecture ar_mdio ;