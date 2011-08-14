library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity test_ad9978port is
end ;

architecture test_ar_ad9978port of test_ad9978port is

component ad9978port
  port (
    
	   clk50        : in std_logic ;  --  50 MHz clock 
	   p_addr       : in std_logic_vector(7 downto 0) ;
	   p_data       : in std_logic_vector(11 downto 0) ;
	   p_channel_id : in std_logic_vector(1 downto 0) ;
	   wr           : in std_logic ;
	   
		 SL      : out std_logic ; -- SL signal
		 SDATA   : out std_logic ; -- SDATA signal
		 SCK     : out std_logic   -- SCK signal
		 
		 ) ;
end component ;

signal t_clk50        : std_logic := '0' ;  --  50 MHz clock 
signal	t_p_addr       : std_logic_vector(7 downto 0) ;
signal t_p_data       : std_logic_vector(11 downto 0) ;
signal t_p_channel_id : std_logic_vector(1 downto 0) ;
signal t_wr           : std_logic ;
	   
signal t_SL      : std_logic ; -- SL signal
signal t_SDATA   : std_logic ; -- SDATA signal
signal t_SCK     : std_logic ; -- SCK signal

begin
  dut:
  ad9978port
  port map (
    
    clk50 => t_clk50,
    p_addr => t_p_addr,
    p_data => t_p_data,
    p_channel_id => t_p_channel_id,
    wr => t_wr,
    
    SL => t_SL,
    SDATA => t_SDATA,
    SCK => t_SCK
    
    ) ;
    
    clock50:process 
    begin
      wait for 10 ns ; t_clk50 <= not t_clk50 ;
    end process ;
    
    stimulus: process
    begin
      wait for 10 ns ;
      t_wr <= '0' ;
      t_p_addr <= b"1001_1001" ;
      t_p_data <= b"1010_1001_1010" ;
      t_p_channel_id <= b"00" ;
      wait for 10 ns ;
      t_wr <= '1' ;
      wait for 20 ns ;
      t_wr <= '0' ;
      wait ;
    end process ;
    
end architecture ;