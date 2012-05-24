library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity dataport is
  port (
		  reset      : in std_logic ;
        data       : in std_logic_vector(31 downto 0) ;
        clk        : in std_logic ;
        sram_addr  : out   std_logic_vector(19 downto 0) ;
        sram_dq    : inout std_logic_vector(15 downto 0) ;
        sram_ub_n  : out std_logic ;
        sram_lb_n  : out std_logic ;
        sram_ce_n  : out std_logic ;
        sram_oe_n  : out std_logic ;
        sram_we_n  : out std_logic ;
        clkx4      : in std_logic
		) ;
end dataport ;

architecture a_dataport of dataport is
signal cnt2: std_logic_vector(1 downto 0) := "00" ;
signal addr: std_logic_vector(19 downto 0) := b"0000_0000_0000_0000_0000" ;
begin
process(clk)
begin
   if rising_edge(clk) then
      cnt2 <= cnt2 + 1 ;
   end if ;
end process ;
process(cnt2(0))
begin
   if rising_edge(cnt2(0)) then
      addr <= addr + 1 ;
   end if ;
end process ;
end architecture a_dataport ;