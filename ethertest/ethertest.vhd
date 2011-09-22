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
	
    enet0_gtx_clk   : out std_logic ;
    enet0_int_n     : in std_logic ;
    enet0_link100   : in std_logic ;
    enet0_mdc       : in std_logic ;
    enet0_mdio      : in std_logic ;
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
component ifconfig is
  port (
        
        reset   : in std_logic ;
        clk50   : in std_logic ;
        
        mdc     : out std_logic ;
        mdio    : inout std_logic 
        
		) ;
end ifconfig ;
component etherlink is
  port (
        reset   : in std_logic ;
        
        tx_data : out std_logic_vector(3 downto 0) ;
        gtx_clk : out std_logic ; -- GMII Transmit Clock 1 (is not used for 100Mbit)
        tx_clk  : in std_logic ;  -- MII transmit clock 1
        tx_en   : out std_logic ; -- GMII and MII transmit enable 1
        tx_er   : out std_logic ; -- GMII and MII transmit error 1
        rst   : out std_logic
        
        start_packet:   in std_logic ;
        
        --rx_data : in std_logic_vector(3 downto 0) ;
        --rx_clk  : in std_logic ;
        --rx_dv   : in std_logic ;
        --rx_er   : in std_logic ;
        --rx_crs  : in std_logic ;
        --rx_col  : in std_logic ;
        
		) ;
end etherlink ;
begin
ifconf: ifconfig 
    port map (
        key(0) => reset,
        clock_50 => clk50,
        enet0_mdc => mdc,
        enet0_mdio => mdio
        ) ;
link: etherlink
    port map (
        key(0) => reset,
        enet0_tx_data => tx_data,
        enet0_gtx_clk => gtx_clk,
        enet0_tx_clk => tx_clk,
        enet0_tx_en => tx_en,
        enet0_tx_er => tx_er,
        enet0_rst_n => rst,
        key(1) => start_packet
    ) ;
end architecture ar_ethertest ;