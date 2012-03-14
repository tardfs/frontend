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
type frame_type is array (0 to 331) of std_logic_vector(7 downto 0) ;
signal eth_frame: frame_type := (
x"55",x"55",x"55",x"55",x"55",x"55",x"55",x"5d",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"00",x"31",
x"77",x"03",x"89",x"c5",x"80",x"00",x"54",x"00",x"00",x"ac",x"78",x"ef",x"00",x"00",x"08",x"11",
x"61",x"51",x"9a",x"ef",x"84",x"31",x"9a",x"ef",x"ff",x"ff",x"00",x"a8",x"00",x"a8",x"00",x"6b",
x"2e",x"30",x"11",x"20",x"18",x"12",x"9a",x"ef",x"84",x"31",x"00",x"a8",x"00",x"0a",x"00",x"00",
x"02",x"64",x"44",x"54",x"24",x"54",x"e4",x"64",x"44",x"64",x"64",x"54",x"f4",x"54",x"84",x"64",
x"34",x"44",x"54",x"44",x"14",x"34",x"14",x"34",x"14",x"34",x"14",x"34",x"14",x"34",x"14",x"14",
x"14",x"00",x"02",x"54",x"e4",x"64",x"44",x"54",x"94",x"54",x"05",x"54",x"e4",x"54",x"64",x"34",
x"14",x"34",x"14",x"34",x"14",x"34",x"14",x"34",x"14",x"34",x"14",x"34",x"14",x"34",x"14",x"34",
x"14",x"24",x"e4",x"00",x"ff",x"35",x"d4",x"24",x"52",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"00",x"11",x"00",x"00",x"60",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
x"00",x"8e",x"30",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"60",x"00",x"65",x"00",x"30",
x"00",x"10",x"00",x"10",x"00",x"20",x"00",x"71",x"00",x"c5",x"d4",x"14",x"94",x"c4",x"35",x"c4",
x"f4",x"45",x"c5",x"24",x"25",x"f4",x"75",x"35",x"54",x"00",x"90",x"40",x"30",x"00",x"00",x"00",
x"4a",x"09",x"f6",x"fb",x"55",x"55",x"55",x"55",x"55",x"55",x"55",x"5d",x"ff",x"ff",x"ff",x"ff",
x"ff",x"ff",x"00",x"31",x"77",x"03",x"89",x"c5",x"80",x"00",x"54",x"00",x"00",x"e4",x"78",x"ff",
x"00",x"00",x"08",x"11",x"61",x"09",x"9a",x"ef",x"84",x"31",x"9a",x"ef",x"ff",x"ff",x"00",x"98",
x"00",x"98",x"00",x"a3",x"76",x"2c",x"18",x"32",x"10",x"01",x"00",x"10",x"00",x"00",x"00",x"00",
x"00",x"00",x"02",x"54",x"e4",x"64",x"44",x"54",x"94",x"54",x"05",x"54",x"e4",x"54",x"64",x"34",
x"14",x"34",x"14",x"34",x"14",x"34",x"14",x"34",x"14",x"34",x"14",x"34",x"14",x"34",x"14",x"34",
x"14",x"24",x"c4",x"00",x"00",x"02",x"00",x"10",x"04",x"42",x"1e",x"16"
) ;
signal address: integer range 0 to 2047 := 0 ;
signal start: std_logic := '0' ;
signal eth_reset: std_logic := '0' ;
type state_type is (StateIdle,StateFirstNibble,StateSecondNibble) ;
signal state: state_type := StateIdle ;
constant btn_pressed: std_logic:= '0' ;

signal timer_count:std_logic_vector(25 downto 0) ;
signal reset_timer:std_logic := '0' ;
signal timer_expired:std_logic := '0' ;
begin

enet0_mdio <= '0' ;
enet0_mdc <= '0' ;
ledr(0) <= timer_expired ;

enet0_rst_n <= eth_reset ;
eth_rst:process(clock_50)
begin
	if rising_edge(clock_50) then
		eth_reset <= key(0) ;
	end if ;
end process ;

timer_expired <= timer_count(timer_count'high) ;
timer:process(enet0_tx_clk)
begin
   if falling_edge(enet0_tx_clk) then
	   if timer_count(timer_count'high)='0' then
    	   timer_count <= timer_count+1 ;
	   elsif reset_timer='1' then 
		   timer_count <= ext("0",timer_count'length) ;
		end if ;
	end if ;
end process ;

state_machine:process(enet0_tx_clk)
variable tmp_byte: std_logic_vector(7 downto 0) ;
begin
	if falling_edge(enet0_tx_clk) then
			if key(3)=btn_pressed then
				-- syn reset
					enet0_tx_en <= '0' ;
					enet0_tx_data <= "0000" ;
					enet0_gtx_clk <= '0' ;
			end if ;
        case state is
            when StateIdle =>
				if (key(1)=btn_pressed and timer_expired='1') then
				   reset_timer <= '1' ;
					state <= StateFirstNibble ;
					address <= 0 ;
					enet0_tx_er <= '0' ;
				end if ;
			when StateFirstNibble =>
			   reset_timer <= '0' ;
				if address<(eth_frame'length) then
				   enet0_tx_en <= '1' ;
				   tmp_byte := eth_frame(address) ;
				   enet0_tx_data <= tmp_byte(7 downto 4) ;				
				   state <= StateSecondNibble ;
				else
				   enet0_tx_en <= '0' ;
               state <= StateIdle ;
			   end if ;	
			when StateSecondNibble =>
				tmp_byte := eth_frame(address) ;
				enet0_tx_data <= tmp_byte(3 downto 0) ;				
            address <= address + 1 ;
            state <= StateFirstNibble ;
		end case ;
	end if ;
end process ;
end architecture ar_txd ;