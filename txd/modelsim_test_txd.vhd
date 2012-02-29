library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity test_txd is
end ;

architecture test_ar_txd of test_txd is

component txd is
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
end component txd ;

signal t_key           : std_logic_vector(3 downto 0) := b"0000" ;
signal t_enet0_rst_n   : std_logic := '0' ;
signal t_enet0_tx_clk  : std_logic := '0' ;
signal t_enet0_tx_data : std_logic_vector(3 downto 0) ;
signal t_enet0_tx_en   : std_logic ;
        
begin
  dut:
  txd
  port map (
    key           => t_key,
    enet0_rst_n   => t_enet0_rst_n,
    enet0_tx_clk  => t_enet0_tx_clk,
    enet0_tx_data => t_enet0_tx_data,
    enet0_tx_en   => t_enet0_tx_en
    ) ;
    
    clock25:process
    begin
      wait for 50 ns ; enet0_tx_clk <= not enet0_tx_clk ;
    end process ;
    
    stimulus: process
    begin
      t_key <= b"0000" ;
      wait for 100 ns ;
      t_key(1) <= '1' ;
      wait for 100 ns ;
      t_key(1) <= '0' ;
      wait ;
    end process ;
    
end architecture ;