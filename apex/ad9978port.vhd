library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity ad9978port is
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
end ad9978port ;

architecture arc_ad9978port of ad9978port is
  constant CLKX: integer := 4 ;
  type state_type is (ST_Idle,ST_Addr,ST_Data,ST_ChannelId) ;
  signal state: state_type:= ST_Idle ;
  signal addr : std_logic_vector(7 downto 0) ;
  signal data : std_logic_vector(11 downto 0) ;
  signal channel_id  : std_logic_vector(1 downto 0) ;
  signal counter: integer range 0 to 11 ;
  signal sck_clk: std_logic := '1' ;
  signal count4: integer range 0 to 4 := 0 ;
begin
  SCK <= '1' when state=ST_Idle else sck_clk ;
  process (clk50)
    begin
      if rising_edge(clk50) then
        count4 <= count4 + 1 ;
        if count4=1 then
          sck_clk <= not sck_clk ;
          count4 <= 0 ;
        end if ;
      end if ;
  end process ;
  
  process (clk50)
  begin
    if rising_edge(clk50) then
      if state=ST_Idle then
        SL <= '1' ;
        SDATA <= '0' ;
        if wr='1' then
          addr <= p_addr ;
          data <= p_data ;
          channel_id <= p_channel_id ;
          state <= ST_Addr ;
          counter <= 0 ;
          SL <= '0' ;
          SDATA <= p_addr(0) ;
        end if ;
      elsif state=ST_Addr then
        if counter<7 then
          SDATA <= addr(counter+1) ;
          counter <= counter + 1 ;
        else
          SDATA <= data(0) ;
          counter <= 0 ;
          state <= ST_Data ;
        end if ;
      elsif state=ST_Data then
        if counter<11 then
          SDATA <= data(counter+1) ;
          counter <= counter + 1 ;
        else
          SDATA <= channel_id(0) ;
          counter <= 0 ;
          state <= ST_ChannelId ;
        end if ;
      elsif state=ST_ChannelId then
        if counter<3 then
          SDATA <= channel_id(counter+1) ;
          counter <= counter + 1 ;
        else
          SDATA <= '0' ;
          counter <= 0 ;
          state <= ST_Idle ;
          SL <= '1' ;
        end if ;
      end if ;
    end if ;
  end process ;
end architecture ;
