library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity test_hvsync is
end ;

architecture ar_test_hvsync of test_hvsync is

component hvsync is
  port (
        clk        : in std_logic ;
        reset      : in std_logic ;
        ul_reset   : out std_logic ;
        ul_int     : out std_logic ;
        ad_hd      : out std_logic ;
        ad_vd      : out std_logic 
		 ) ;
end component hvsync ;

signal t_clk : std_logic:= '0' ;
signal t_reset : std_logic:= '0' ;
signal t_ul_reset : std_logic:= '0' ;
signal t_ul_int : std_logic:= '0' ;
signal t_ad_hd : std_logic:= '0' ;
signal t_ad_vd : std_logic:= '0' ;

begin
  dut:
  hvsync
  port map (
    clk => t_clk,
    reset => t_reset,
    ul_reset => t_ul_reset,
    ul_int => t_ul_int,
    ad_hd => t_ad_hd,
    ad_vd => t_ad_vd
    ) ;
    
  t_clk <= not t_clk after 40 ns ;
    
  process
    begin
      t_reset <= '1' ;
      wait for 80 ns ;
      t_reset <= '0' ;
      wait for 80 ns ;     
      t_reset <= '0' ;
      wait ;
    end process ;
    
  end architecture ;
