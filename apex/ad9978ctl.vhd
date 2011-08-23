library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity ad9978ctl is
  port (
		clk50   : in std_logic ; --  50 MHz clock 
		reset   : in std_logic ; --  sync reset
		SL      : out std_logic ; -- SL signal
		SDATA   : out std_logic ; -- SDATA signal
		SCK     : out std_logic ; -- SCK signal
		HD      : out std_logic ; -- HD signal
		VD      : out std_logic   -- VD signal
		) ;
end ad9978ctl ;

architecture arc_ad9978ctl of ad9978ctl is
component ad9978port
  port (
    
	   clk50        : in std_logic ;  --  50 MHz clock 
	   p_addr       : in std_logic_vector(7 downto 0) ;
	   p_data       : in std_logic_vector(11 downto 0) ;
	   p_channel_id : in std_logic_vector(3 downto 0) ;
	   wr           : in std_logic ;

	   SL      : out std_logic ; -- SL signal
	   SDATA   : out std_logic ; -- SDATA signal
	   SCK     : out std_logic   -- SCK signal
   
		 ) ;
end component ;

type config_data_type is array (0 to 8) of std_logic_vector(23 downto 0) ;
signal config_data: config_data_type := 
(
  b"01010000_000000000001_1111", -- write 1 to 0x50 (software reset)
  b"01000001_000100000000_1111", -- write 0x80 to 0x41
  b"01001110_010000000000_1111", -- write 0x40 to bits 11:4 of 0x4E
  b"01001111_010000000000_1111", -- write 0x80 to bits 11:3 of 0x4F
  b"11101001_000001100000_1111", -- write 0x60 to 0xE9
  b"01000001_000100000010_1111", -- write 0x82 to 0x41
  b"00000000_000000000000_1111",
  b"00000000_000000000000_1111",
  b"00000000_000000000000_1111"
) ;
type config_timings_type is array (0 to 8) of integer range 0 to 2048 ;
signal config_timings: config_timings_type :=  -- x20ns
(
10, 150, 100, 100, 100, 100, 100, 100, 100
) ;
constant SET_CLKS : integer := 2 ;
constant WRITE_CLKS: integer := 2 ;
signal addr       : std_logic_vector(7 downto 0) ;
signal data       : std_logic_vector(11 downto 0) ;
signal channel_id : std_logic_vector(3 downto 0) ;
signal wr         : std_logic := '0' ;
signal reg_count  : integer range 0 to 15 ;
signal clk_count  : integer range 0 to 2048 ;
type state_type is (ST_Set,ST_Write,ST_Wait) ;
signal state      : state_type := ST_Wait ;
begin
  conf_port:
  ad9978port
  port map (
    
    clk50 => clk50,
    p_addr => addr,
    p_data => data,
    p_channel_id => channel_id,
    wr => wr,
    
    SL => SL,
    SDATA => SDATA,
    SCK => SCK
    
    ) ;
  
  process (clk50)
  begin
  if rising_edge(clk50) then
	if reset='1' then
		-- reset circuit
		HD <= '1' ;
		VD <= '1' ;
		reg_count <= 0 ;
		clk_count <= 0 ;
		state <= ST_Wait ;
	else
	  if reg_count<config_data'high then
	    if state=ST_Wait then
		  if clk_count<config_timings(reg_count) then
		    clk_count <= clk_count + 1 ;
		  else
            clk_count <= 0 ;
            reg_count <= reg_count + 1 ;
            addr <= config_data(reg_count)(21 downto 14) ;
            data <= config_data(reg_count)(13 downto 2) ;
            channel_id <= config_data(reg_count)(3 downto 0) ;
		    state <= ST_Set ;
		  end if ;
		elsif state=ST_Set then
		  if clk_count<SET_CLKS then
		    clk_count <= clk_count + 1 ;
		  else
            wr <= '1' ;
            clk_count <= 0 ;
		    state <= ST_Write ;
          end if ;
		elsif state=ST_Write then
		  if clk_count<WRITE_CLKS then
		    clk_count <= clk_count + 1 ;
		  else
            wr <= '0' ;
            clk_count <= 0 ;
		    state <= ST_Wait ;
          end if ;
		end if ;
      else
		HD <= '0' ;
		VD <= '0' ;       
	  end if ;
	end if ;
  end if ;
  end process ;
end architecture arc_ad9978ctl ;