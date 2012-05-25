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
signal clkx2: std_logic := '0' ;
signal addr: std_logic_vector(19 downto 0) := b"0000_0000_0000_0000_0000" ;
signal data_buf: std_logic_vector(31 downto 0) ;
signal mux_out: std_logic_vector(15 downto 0) ;
signal iclkx4: std_logic ;
signal iclkx2: std_logic := '0' ;
begin
mux_out <= data_buf(31 downto 16) when (clkx2='0') else data_buf(15 downto 0) ;
sram_dq <= mux_out when (clk='0') else "ZZZZZZZZZZZZZZZZ" ;
iclkx4 <= not clkx4 ;
sram_we_n <= iclkx2 ;
sram_ub_n <= iclkx2 ;
sram_lb_n <= iclkx2 ;
-- internal 32 bit buffer
process(clk)
begin
   if rising_edge(clk) then
      data_buf <= data ;
   end if ;
end process ;
process(clkx4)
begin
   if rising_edge(clkx4) then
      clkx2 <= not clkx2 ;
   end if ;
end process ;
process(iclkx4)
begin
   if rising_edge(iclkx4) then
      iclkx2 <= not iclkx2 ;
   end if ;
end process ;
process(clkx2)
begin
   if rising_edge(clkx2) then
      addr <= addr + 1 ;
   end if ;
end process ;
end architecture a_dataport ;