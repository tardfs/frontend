-- Copyright (C) 2011 AGOURA AVIATION
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity etherlink is
  port (
        reset   : in std_logic ;
        
        tx_data : out std_logic_vector(3 downto 0) ;
        gtx_clk : out std_logic ; -- GMII Transmit Clock 1 (is not used for 100Mbit)
        tx_clk  : in std_logic ;  -- MII transmit clock 1
        tx_en   : out std_logic ; -- GMII and MII transmit enable 1
        tx_er   : out std_logic ; -- GMII and MII transmit error 1
        rst   : out std_logic ;
        
        start_packet:   in std_logic 
        
        --rx_data : in std_logic_vector(3 downto 0) ;
        --rx_clk  : in std_logic ;
        --rx_dv   : in std_logic ;
        --rx_er   : in std_logic ;
        --rx_crs  : in std_logic ;
        --rx_col  : in std_logic ;
        
		) ;
end etherlink ;

architecture ar_etherlink of etherlink is
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
signal byte_counter: integer range 0 to 2047 := 0 ;
signal nibler: std_logic := '0' ;
type state_type is (EthReset,EthIdle,EthTr) ;
signal state  : state_type := EthIdle ;
begin
process(tx_clk)
  variable byte_value: std_logic_vector(7 downto 0) ;
begin
    if falling_edge(tx_clk) then
        if reset='1' then
            state <= EthReset ;
            tx_en <= '0' ;
            tx_er <= '0' ;
            tx_data <= b"0000" ;
            nibler <= '0' ;
            rst <= '1' ;
        else
            if state=EthReset then
                state <= EthIdle ;
                rst <= '0' ;
            elsif state=EthIdle then
                if start_packet='1' then
                    state <= EthTr ;
                    tx_en <= '1' ;
                    tx_er <= '0' ;
                    nibler <= '1' ;
                    byte_counter <= 0 ;
                    byte_value := eth_frame(0) ;
                    tx_data <= byte_value(3 downto 0) ;
                end if ;
            elsif state=EthTr then
                if byte_counter<=eth_frame'high then
                    byte_value := eth_frame(byte_counter) ;
                    if nibler='0' then
                        tx_data <= byte_value(3 downto 0) ;
                    else
                        tx_data <= byte_value(7 downto 4) ;
                        byte_counter <= byte_counter + 1 ;
                    end if ;
                    nibler <= not nibler ;
                else
                    tx_en <= '0' ;
                    state <= EthIdle ;
                    tx_data <= b"0000" ;
                end if ;
            end if ;
        end if ;
    end if ;
end process ;
end architecture ar_etherlink ;
