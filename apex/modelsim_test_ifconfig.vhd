library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity test_ifconfig is
end ;

architecture test_ar_ifconfig of test_ifconfig is

component ifconfig
  port (
    
        reset   : in std_logic ;
        clk50   : in std_logic ;
        
        mdc     : out std_logic ;
        mdio    : inout std_logic
		 
		 ) ;
end component ;

signal t_reset        : std_logic ;
signal t_clk50        : std_logic := '0' ;
   
signal t_mdc      : std_logic ;
signal t_mdio     : std_logic ;

begin
  dut:
  ifconfig
  port map (
    
    reset => t_reset,
    clk50 => t_clk50,
    mdc => t_mdc,
    mdio => t_mdio
    
    ) ;
    
    clock50:process 
    begin
      wait for 10 ns ; t_clk50 <= not t_clk50 ;
    end process ;
    
    stimulus: process
    begin
      wait for 10 ns ;
      t_reset <= '1' ;
      wait for 100 ns ;
      t_reset <= '0' ;
      wait ;
    end process ;
    
end architecture ;