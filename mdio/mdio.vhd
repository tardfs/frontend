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
  port (
        
        clk     : in std_logic ; -- clock
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
begin
end architecture ar_mdio ;