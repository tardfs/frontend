library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity test_etherlink is
end ;

architecture test_ar_etherlink of test_etherlink is

component etherlink is
  port (
        reset   : in std_logic ;
        
        tx_data : out std_logic_vector(3 downto 0) ;
        gtx_clk : out std_logic ; -- GMII Transmit Clock 1 (is not used for 100Mbit)
        tx_clk  : in std_logic ;  -- MII transmit clock 1
        tx_en   : out std_logic ; -- GMII and MII transmit enable 1
        tx_er   : out std_logic ; -- GMII and MII transmit error 1
        rst   : out std_logic ;
        
        start_packet:   in std_logic
        
        --rx_data : in std_logic_vector(3 downto 0) ;
        --rx_clk  : in std_logic ;
        --rx_dv   : in std_logic ;
        --rx_er   : in std_logic ;
        --rx_crs  : in std_logic ;
        --rx_col  : in std_logic ;
        
		) ;
end component etherlink ;

signal t_reset   : std_logic ;
signal t_tx_data : std_logic_vector(3 downto 0) ;
signal t_gtx_clk : std_logic ;
signal t_tx_clk  : std_logic := '0' ;
signal t_tx_en   : std_logic ;
signal t_tx_er   : std_logic ;
signal t_rst     : std_logic ;
signal t_start_packet: std_logic ;
        
begin
  dut:
  etherlink
  port map (
    reset => t_reset,
    tx_data => t_tx_data,
    gtx_clk => t_gtx_clk,
    tx_clk => t_tx_clk,
    tx_en => t_tx_en,
    tx_er => t_tx_er,
    rst => t_rst,
    start_packet => t_start_packet
    ) ;
    
    clock25:process
    begin
      wait for 20 ns ; t_tx_clk <= not t_tx_clk ;
    end process ;
    
    stimulus: process
    begin
      t_start_packet <= '0' ;
      t_reset <= '0' ;
      wait for 10 ns ;
      t_reset <= '1' ;
      wait for 100 ns ;
      t_reset <= '0' ;
      wait for 100 ns ;
      t_start_packet <= '1' ;
      wait for 40 ns ;
      t_start_packet <= '0' ;
      wait ;
    end process ;
    
end architecture ;