library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;
use ieee.std_logic_arith.all ;
entity txd is
  port (
    clock_50    : in std_logic ;
    clock2_50   : in std_logic ;
    clock3_50   : in std_logic ;
		
    key             : in std_logic_vector(3 downto 0) ;
    ledr            : out std_logic_vector(17 downto 0) ;
    ledg            : out std_logic_vector(8 downto 0) ;
	
    enet0_gtx_clk   : out std_logic ;
    enet0_int_n     : in std_logic ;
    enet0_link100   : in std_logic ;
    enet0_mdc       : out std_logic ;
    enet0_mdio      : inout std_logic ;
    enet0_rst_n     : out std_logic ; 
    
    enet0_rx_clk    : in std_logic ;
    enet0_rx_col    : in std_logic ;
    enet0_rx_crs    : in std_logic ;
    enet0_rx_data   : in std_logic_vector(3 downto 0) ;
    enet0_rx_dv     : in std_logic ;
    enet0_rx_er     : in std_logic ;
    
    enet0_tx_clk    : in std_logic ;
    enet0_tx_data   : out std_logic_vector(3 downto 0) ;
    enet0_tx_en     : out std_logic ;
    enet0_tx_er     : out std_logic ;
    enetclk_25      : in std_logic  
		 ) ;
end txd ;
architecture ar_txd of txd is
type frame_type is array (0 to 71) of std_logic_vector(7 downto 0) ;
signal eth_frame: frame_type := (
x"55",x"55",x"55",x"55",x"55",x"55",x"55",
x"d5",
x"00",x"10",x"a4",x"7b",x"ea",x"80",
x"00",x"12",x"34",x"56",x"78",x"90",
x"08",x"00",
x"45",x"00",x"00",x"2e",x"b3",x"fe",x"00",x"00",
x"80",x"11",x"05",x"40",x"c0",x"a8",x"00",x"2c",
x"c0",x"a8",x"00",x"04",x"04",x"00",x"04",x"00",
x"00",x"1a",x"2d",x"e8",x"00",x"01",x"02",x"03",
x"04",x"05",x"06",x"07",x"08",x"09",x"0a",x"0b",
x"0c",x"0d",x"0e",x"0f",x"10",x"11",
x"e6",x"c5",x"3d",x"b2") ;
signal address: integer range 0 to 2047 := 0 ;
signal start: std_logic := '0' ;
signal eth_reset: std_logic := '0' ;
type state_type is (StateIdle,StateHighNibble,StateLowNibble) ;
signal state: state_type := StateIdle ;
begin

enet0_mdio <= '0' ;
enet0_mdc <= '0' ;

enet0_rst_n <= eth_reset ;
eth_rst:process(clock_50)
begin
	if rising_edge(clock_50) then
		eth_reset <= key(0) ;
	end if ;
end process ;
state_machine:process(enet0_tx_clk)
variable tmp_byte: std_logic_vector(7 downto 0) ;
begin
	if falling_edge(enet0_tx_clk) then
			if key(3)='1' then
				-- syn reset
					enet0_tx_en <= '0' ;
					enet0_tx_data <= "0000" ;
					enet0_gtx_clk <= '0' ;
			end if ;
        case state is
            when StateIdle =>
				if key(1)='1' then
					state <= StateHighNibble ;
					address <= 0 ;
					enet0_tx_en <= '1' ;
				end if ;
			when StateHighNibble =>
				tmp_byte := eth_frame(address) ;
				enet0_tx_data <= tmp_byte(7 downto 4) ;
				state <= StateLowNibble ;
			when StateLowNibble =>
				tmp_byte := eth_frame(address) ;
				enet0_tx_data <= tmp_byte(3 downto 0) ;
				if address<=eth_frame'length then
                    address <= address + 1 ;
                    state <= StateHighNibble ;
                else
					enet0_tx_en <= '0' ;
                    state <= StateIdle ;
                end if ;
		end case ;
	end if ;
end process ;
end architecture ar_txd ;