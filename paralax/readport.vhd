library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity readport is
  port (
		  reset      : in std_logic ;
        clk        : in std_logic ;
        clkx4      : in std_logic ;
        oe         : in std_logic ;

        addr       : in std_logic_vector(19 downto 0) ;
        data       : out std_logic_vector(31 downto 0) ;
        
        sram_dq    : inout std_logic_vector(15 downto 0) ;
        sram_ub_n  : out std_logic ;
        sram_lb_n  : out std_logic ;
        sram_ce_n  : out std_logic ;
        sram_oe_n  : out std_logic ;
        sram_we_n  : out std_logic ;
        sram_addr  : out std_logic_vector(19 downto 0) 
        
		) ;
end readport ;

architecture a_readport of readport is
signal clkx2: std_logic := '0' ;
signal data_buf: std_logic_vector(31 downto 0) ;
signal mux_out: std_logic_vector(15 downto 0) ;
signal iclkx4: std_logic ;
signal iclkx2: std_logic := '0' ;
begin
mux_out <= data_buf(31 downto 16) when (clkx2='0') else data_buf(15 downto 0) ;
sram_addr <= addr when oe='1' else "ZZZZZZZZZZZZZZZZZZZZ" ;
sram_dq <= mux_out when (clk='0' and oe='1') else "ZZZZZZZZZZZZZZZZ" ;
iclkx4 <= not clkx4 ;
sram_we_n <= iclkx2 when oe='1' else 'Z' ;
sram_ub_n <= iclkx2 when oe='1' else 'Z' ;
sram_lb_n <= iclkx2 when oe='1' else 'Z' ;
-- internal 32 bit buffer
process(clk)
begin
   if rising_edge(clk) then
      data <= data_buf ;
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
end architecture a_readport ;