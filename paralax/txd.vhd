library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;
use ieee.std_logic_arith.all ;

entity txd is
  port (
   clk    : in std_logic ;
    
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
   enetclk_25      : in std_logic  ;
    
   sram_addr  : out std_logic_vector(19 downto 0) ;
   sram_data  : in std_logic_vector(15 downto 0) ;
   sram_clk   : out std_logic ;
    
    st : in std_logic ;
    oe : in std_logic
    
    ) ;
end txd ;

architecture ar_txd of txd is
begin
end architecture ar_txd ;