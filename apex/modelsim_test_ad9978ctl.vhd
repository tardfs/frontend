library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity test_ad9978ctl is
end ;

architecture test_ar_ad9978ctl of test_ad9978ctl is
component ad9978ctl is
  port (
		clk50   : in std_logic ; --  50 MHz clock 
		reset   : in std_logic ; --  async reset
		SL      : out std_logic ; -- SL signal
		SDATA   : out std_logic ; -- SDATA signal
		SCK     : out std_logic ; -- SCK signal
		HD      : out std_logic ; -- HD signal
		VD      : out std_logic   -- VD signal
		) ;
end component ;
signal t_clk50   : std_logic := '0' ; --  50 MHz clock 
signal t_reset   : std_logic := '0' ; --  async reset
signal t_SL      : std_logic := '0' ; -- SL signal
signal t_SDATA   : std_logic := '0' ; -- SDATA signal
signal t_SCK     : std_logic := '0' ; -- SCK signal
signal t_HD      : std_logic := '0' ; -- HD signal
signal t_VD      : std_logic := '0' ;  -- VD signal
begin
  dut:
  ad9978ctl
  port map (
    clk50 => t_clk50,
	reset => t_reset,
    SL    => t_SL,
	SDATA => t_SDATA,
	SCK   => t_SCK,
	HD    => t_HD,
	VD    => t_VD    
  ) ;
  
  process
  begin
    wait for 10 ns ; t_clk50 <= not t_clk50 ;
  end process ;
  
  process
  begin
    t_reset <= '0' ;
    wait for 40 ns ;
    t_reset <= '1' ;
    wait for 40 ns ;
    t_reset <= '0' ;
    wait ;    
  end process ;
  
end architecture ;