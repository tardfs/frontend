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
        rst   : out std_logic
        
        start_packet:   in std_logic ;
        
        --rx_data : in std_logic_vector(3 downto 0) ;
        --rx_clk  : in std_logic ;
        --rx_dv   : in std_logic ;
        --rx_er   : in std_logic ;
        --rx_crs  : in std_logic ;
        --rx_col  : in std_logic ;
        
		) ;
end etherlink ;

architecture ar_etherlink of etherlink is
type frame_type is array (0 to 8) of std_logic_vector(7 downto 0) ;
signal eth_frame: frame_type := ( x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00" ) ;
signal byte_counter: integer range 0 to 2047 := 0 ;
signal nibler: std_logic := '0' ;
type state_type is (EthIdle,EthTr) ;
signal state  : state_type := EthIdle ;
begin
process(tx_clk)
begin
    if falling_edge(tx_clk) then
        if reset='1' then
            state <= EthIdle ;
            tx_en <= '0' ;
            tx_er <= '0' ;
            tx_data <= b"0000" ;
            nibler <= '0' ;
        else
            if state=EthIdle then
                if start_packet='1' then
                    state <= EthTr ;
                    tx_en <= '1' ;
                    tx_er <= '0' ;
                    nibler <= '0' ;
                end if ;
            elsif stata=EthTr then
                if byte_counter<=eth_frame'high then
                    nibler <= not nibler ;
                    if nibler='0' then
                        tx_data <= eth_frame(byte_counter,7 downto 4) ;
                    else
                        tx_data <= eth_frame(byte_counter,3 downto 0) ;
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
    end ;
end process ;
end architecture ar_etherlink ;
