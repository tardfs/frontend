library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity ad9978ctl is
  port (
		clk50   : in std_logic ; --  50 MHz clock 
		reset   : in std_logic ; --  async reset
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
	   p_channel_id : in std_logic_vector(1 downto 0) ;
	   wr           : in std_logic ;

	   SL      : out std_logic ; -- SL signal
	   SDATA   : out std_logic ; -- SDATA signal
	   SCK     : out std_logic   -- SCK signal
   
		 ) ;
end component ;

type config_data_type is array (0 to 8) of std_logic_vector(21 downto 0) ;
signal config_data: config_data_type := 
(
  b"00000000_000000000000_00",
  b"00000000_000000000000_00",
  b"00000000_000000000000_00",
  b"00000000_000000000000_00",
  b"00000000_000000000000_00",
  b"00000000_000000000000_00",
  b"00000000_000000000000_00",
  b"00000000_000000000000_00",
  b"00000000_000000000000_00"
) ;
type config_timings_type is array (0 to 8) of integer range 0 to 2048 ;
signal config_timings: config_timings := 
(
10, 10, 10, 10, 10, 10, 10, 10, 10
) ;
signal addr       : std_logic_vector(7 downto 0) ;
signal data       : std_logic_vector(11 downto 0) ;
signal channel_id : std_logic_vector(1 downto 0) ;
signal wr         : std_logic = '0' ;
signal reg_count  : integer range 0 to 15 ;
signal clk_count  : integer range 0 to 2048 ;
type state_type is (ST_Idle,ST_Wait,ST_Write) ;
signal state      : state_type := ST_Idle ;
begin
  conf_port:
  ad9978port
  port map (
    
    clk50 => clk50,
    p_addr => addr,
    p_data => data,
    p_channel_id => channel_id,
    wr => t_wr,
    
    SL => SL,
    SDATA => SDATA,
    SCK => SCK
    
    ) ;
  
  process (clk)
  begin
  if rising_edge(clk) then
	if reset='1' then
		-- reset circuit
		HD <= '1' ;
		VD <= '1' ;
		reg_count <= 0 ;
		clk_count <= 0 ;
	else
	  if reg_count<config_data'high then
	    if clk_count<config_timings(reg_count)
		  clk_count <= clk_count + 1 ;
	    else
	      addr <= config_data(reg_count)(21 downto 14) ;
	      data <= config_data(reg_count)(13 downto 2) ;
	      config_id <= config_data(reg_count)(1 downto 0) ;
	      reg_count <= reg_count + 1 ;
	      clk_count <= 0 ;
	    end if ;
	  end if ;
	end if ;
  end if ;
  end process ;
end architecture arc_ad9978ctl ;