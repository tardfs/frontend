library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity test_ul0525ctl is
end ;

architecture test_ar_ul0525ctl of test_ul0525ctl is

component ul0525ctl
  port (
	    clk50      : in std_logic ;    --  50 MHz clock
	    reset_in   : in std_logic ;    -- input reset circuit
	    reset_out  : out std_logic ;   -- start of frame
		  int        : out std_logic     -- integration signal
		 ) ;
end component ;

signal t_clk50 : std_logic:= '0' ;
signal t_reset_in : std_logic:= '0' ;
signal t_reset_out : std_logic:= '0' ;
signal t_int : std_logic:= '0' ;

begin
  dut:
  ul0525ctl
  port map (
    clk50 => t_clk50,
    reset_in => t_reset_in,
    reset_out => t_reset_out,
    int => t_int 
    ) ;
    
    clock50:process 
    begin
      wait for 10 ns ; t_clk50 <= not t_clk50 ;
    end process ;
    
    stimulus: process
    begin
      t_reset_in <= '0' ;
      wait for 20 ns ;
      t_reset_in <= '1' ;
      wait for 40 ns ;     
      t_reset_in <= '0' ;
      wait ;
    end process ;
    
  end architecture ;
