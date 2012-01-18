library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_arith.all ;

entity test_mdioport is
end ;

architecture test_ar_mdioport of test_mdioport is

component mdioport
  port (
        clk50   : in std_logic ; -- system clock
        reset   : in std_logic ; -- system reset
		
        op_en   : in std_logic ; -- enable operation
        
		-- data in/out
        opcode  : in std_logic_vector(1 downto 0) ;
        phyaddr : in std_logic_vector(4 downto 0) ;
        regaddr : in std_logic_vector(4 downto 0) ;
        datain  : in std_logic_vector(15 downto 0) ;
        datout  : out std_logic_vector(15 downto 0) ;
        ready   : out std_logic ;
        
		-- mdio control interface
        mdc     : out std_logic ;
        mdio    : inout std_logic
		) ;
end component ;

signal t_clk50 : std_logic := '0' ;
signal t_reset : std_logic := '0' ;
signal t_op_en : std_logic := '0' ;
signal t_opcode  : std_logic_vector(1 downto 0) ;
signal t_phyaddr : std_logic_vector(4 downto 0) ;
signal t_regaddr : std_logic_vector(4 downto 0) ;
signal t_datain  : std_logic_vector(15 downto 0) ;
signal t_datout  : std_logic_vector(15 downto 0) ;
signal t_ready   : std_logic ;
signal t_mdc     : std_logic ;
signal t_mdio    : std_logic ;

begin
dut:
	mdioport
	port map(
		clk50 => t_clk50,
		reset => t_reset,
		op_en => t_op_en,
		opcode => t_opcode,
		phyaddr => t_phyaddr,
		regaddr => t_regaddr,
		datain => t_datain,
		datout => t_datout,
		ready => t_ready,
		mdc => t_mdc,
		mdio => t_mdio
	) ;

    clock50:process 
    begin
		wait for 10 ns ; t_clk50 <= not t_clk50 ;
    end process ;

    stimulus: process
    begin
      t_mdio <= 'Z' ;
      t_reset <= '0' ;
	   t_op_en <= '0' ;
	   t_opcode <= "01" ;
	   t_phyaddr <= "10000" ;
	  t_regaddr <= "00000" ;
	  t_datain <= b"0110_1001_0101_1010" ;
      wait for 20 ns ;
      t_reset <= '1' ;
      wait for 20 ns ;     
      t_reset <= '0' ;
      wait for 20 ns ;     
	    t_op_en <= '0' ;
      wait for 100 ns ;     
	    t_op_en <= '1' ;
	    wait for 20 ns ;
	    t_op_en <= '0' ;
	    
	    wait for 9370 ns ;
	    t_mdio <= '0' ;
	    wait for 200 ns ;
	    t_mdio <= '1' ;
	    wait for 200 ns ;
	    t_mdio <= '0' ;
	    wait for 200 ns ;
	    t_mdio <= '1' ;
	    wait for 200 ns ;
	    t_mdio <= '0' ;
	    wait for 200 ns ;
	    t_mdio <= '1' ;
	    wait for 200 ns ;
	    t_mdio <= '0' ;
	    wait for 200 ns ;
	    t_mdio <= '1' ;
	    wait for 200 ns ;
	    t_mdio <= '0' ;
	    wait for 200 ns ;
	    t_mdio <= '1' ;
	    wait for 200 ns ;
	    t_mdio <= '0' ;
	    wait for 200 ns ;
	    t_mdio <= '1' ;
	    
      wait ;
    end process ;
    
  end architecture ;

