library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity ethertest is
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
end ethertest ;

architecture ar_ethertest of ethertest is
signal eth_status: std_logic_vector(3 downto 0) ;
component ifconfig is
  port (
        
        reset   : in std_logic ;
        clk50   : in std_logic ;
        
        eth_status  : out std_logic_vector(7 downto 0) ;
        eth_debug   : out std_logic_vector(15 downto 0) ;
        
        mdc     : out std_logic ;
        mdio    : inout std_logic 
        
		) ;
end component ifconfig ;
component etherlink is
  port (
        reset   : in std_logic ;
        
        tx_data : out std_logic_vector(3 downto 0) ;
        gtx_clk : out std_logic ; -- GMII Transmit Clock 1 (is not used for 100Mbit)
        tx_clk  : in std_logic ;  -- MII transmit clock 1
        tx_en   : out std_logic ; -- GMII and MII transmit enable 1
        tx_er   : out std_logic ; -- GMII and MII transmit error 1
        rst     : out std_logic ;
        
        start_packet:   in std_logic 
        
        --rx_data : in std_logic_vector(3 downto 0) ;
        --rx_clk  : in std_logic ;
        --rx_dv   : in std_logic ;
        --rx_er   : in std_logic ;
        --rx_crs  : in std_logic ;
        --rx_col  : in std_logic ;
        
		) ;
end component etherlink ;
begin
ledg(7 downto 0) <= eth_status ;
ledr(15 downto 0) <= eth_debug ;
ifconf: ifconfig 
    port map (
        reset => key(0),
        clk50 => clock_50,
        status => eth_status,       
        mdc => enet0_mdc,
        mdio => enet0_mdio
        ) ;
link: etherlink
    port map (
        reset => key(0),
        tx_data => enet0_tx_data,
        gtx_clk => enet0_gtx_clk,
        tx_clk => enet0_tx_clk,
        tx_en => enet0_tx_en,
        tx_er => enet0_tx_er,
        rst => enet0_rst_n,
        start_packet => key(1)
    ) ;
end architecture ar_ethertest ;