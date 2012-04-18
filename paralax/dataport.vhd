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
begin
process(clk)
begin
   if rising_edge(clk) then
      
   end if ;
end process ;
end architecture a_dataport ;