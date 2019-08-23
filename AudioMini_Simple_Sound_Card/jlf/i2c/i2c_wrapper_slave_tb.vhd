/*--------------------------------------------------------------------------------------------------------------------------------------------------------------
Copyright (c) ReFLEX CES 1998-2016
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Project     : I²C Interface
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Top level   : i2c_avalon_tb.vhd
File        : i2c_wrapper_slave_tb.vhd
Author      : Jean-Louis FLOQUET
Organization: ReFLEX CES   http://www.reflexces.com
Created     : 2003/03/25
Last update : 2016/02/16 10:26
Version     : 2.00
Dependency  :
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Description : Connect a Nios I²C Interface in Slave configuration
--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
--synthesis translate_off
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;
use     work.i2c_pkg.all;

entity i2c_wrapper_slave_tb is port
	( scl : inout sl := 'H'
	; sda : inout sl := 'H'
	);
end entity i2c_wrapper_slave_tb;

architecture testbench of i2c_wrapper_slave_tb is
	constant CLOCK_PERIOD     : time  :=         10 ns;
	signal   core_sm          : core_type             ;
	signal   core_sm_data_end : sl                    ;
	---------------------------------------------------
	-- Avalon
	signal   avl_dmn          : domain := DOMAIN_OPEN  ; -- Reset/clock
	signal   avl_clk          : sl     :=          '0' ; -- Main clock system
	signal   avl_address      : slv11  := (others=>'0'); -- CPU address
	signal   avl_chipselect   : sl     :=          '0' ; -- CPU chip select
	signal   avl_irq          : sl                     ; -- CPU Interrupt Request line
	signal   avl_readdata     : slv8                   ; -- CPU read data
	signal   avl_write        : sl     :=          '0' ; -- CPU write request
	signal   avl_writedata    : slv8   := (others=>'0'); -- CPU write data
	---------------------------------------------------

begin

i2c_avalon_slave : entity work.i2c_avalon generic map
	( AGENT          => "SLAVE"         -- "MASTER", "SLAVE"
	, CLOCK_PERIOD   => CLOCK_PERIOD    -- Main clock period in picoseconds
	, DEVICE         => "Stratix"       -- Target device
	, I2C_MODE       => "STANDARD"      -- "STANDARD", "FAST" (SCL @ 100KHz or 400KHz)
	, MEM_MODE       => "CACHE"         -- "BUFFER", "CACHE" (memory behavior)
	, NB_BLOCK       => 2               -- 1 <= n <= 4 (Master), 2 (Slave)
	, NB_REG         => 8               -- 1 <= n <= 8 --> 2**REG
	, RAM_TYPE       => "AUTO"          -- "AUTO", "M512", "M4K", "LCELLS"
	, S_ADDRESS      => 16#28#          -- I²C component address (must be legal for I²C compliance)
	) port map
	( dmn            => avl_dmn         -- Reset/clock
	  -- Avalon                         --
	, avl_address    => avl_address     -- CPU address
	, avl_chipselect => avl_chipselect  -- CPU chip select
	, avl_irq        => avl_irq         -- CPU Interrupt Request line
	, avl_readdata   => avl_readdata    -- CPU read data
	, avl_write      => avl_write       -- CPU write request
	, avl_writedata  => avl_writedata   -- CPU write data
	  -- I²C                            --
	, scl            => scl             -- SCL
	, sda            => sda             -- SDA
	);


avl_dmn.clk <= not(avl_dmn.clk) after CLOCK_PERIOD/2;
avl_dmn.rst <= '0'              after 9 ns;

---------------------------------------------------------------------------
-- Processor activity
---------------------------------------------------------------------------
nios : process
	procedure write_i2c(addr : slv12;
	                    data : slv8) is
	begin
		avl_address    <= addr(10 downto 0);
		avl_chipselect <= '1';
		avl_write      <= '1';
		avl_writedata  <= data;
		wait until rising_edge(avl_clk);
		avl_chipselect <= '0';
		avl_write      <= '0';
	end procedure;

begin

	wait for 1 us;
	wait until rising_edge(avl_clk);

--	-----------------------------------------------------
--	-- I²C Read (External device --> I²C --> Interface)
--	-----------------------------------------------------
--	write_i2c(x"002",x"3F");                                    -- Component address
--	write_i2c(x"003",x"AB");                                    -- Sub-address
--	write_i2c(x"004",x"04");                                    -- Number of data
--	write_i2c(x"000","00" & '1' & '0' & '0' & '1' & '1' & '1'); -- SAE, IEOT, Read, Start
--	wait until irq='1';
--	wait until rising_edge(avl_clk);
--	write_i2c(x"000",x"08");                                    -- Clear IRQ
--	wait for 200 us;
--	wait until rising_edge(avl_clk);
--	-----------------------------------------------------
--	-- I²C Write (Interface --> I²C --> External device)
--	-----------------------------------------------------
--	-- Check a full page transfer (Virtual Target PAGE_SIZE set to <8)
--	write_i2c(x"004",x"08");                                    -- number of byte to be transferred
--	write_i2c(x"003",x"10");                                    -- start address
--	write_i2c(x"000","00" & '1' & '0' & '0' & '1' & '0' & '1'); -- SAE, IEOT, Write, Start
--	wait until irq='1';
--	wait until rising_edge(avl_clk);
--	write_i2c(x"000",x"08");                                    -- Clear IRQ
--	wait for 200 us;
--	wait until rising_edge(avl_clk);
--	-----------------------------------------------------
--	-- I²C Read @ unknown component
--	-----------------------------------------------------
--	write_i2c(x"004",x"02");                                    -- Number of data
--	write_i2c(x"002",x"3E");                                    -- Component address (not connected on the I²C bus)
--	write_i2c(x"000","00" & '1' & '0' & '0' & '1' & '0' & '1'); -- SAE, IEOT, Write, Start
--	wait until irq='1';
--	wait until rising_edge(avl_clk);
--	write_i2c(x"000",x"08");                                    -- Clear IRQ
--	wait for 50 us;
--	wait until rising_edge(avl_clk);
--	-----------------------------------------------------
--	-- I²C Read @ unknown component & illegal address
--	-----------------------------------------------------
--	report "Using an illegal component address, should report an error";
--	write_i2c(x"004",x"02");                                    -- Number of data
--	write_i2c(x"002",x"78");                                    -- Component address (not connected on the I²C bus & illegal address)
--	write_i2c(x"000","00" & '1' & '0' & '0' & '1' & '0' & '1'); -- SAE, IEOT, Write, Start
--	wait until irq='1';
--	wait until rising_edge(avl_clk);
--	write_i2c(x"000",x"08");                                    -- Clear IRQ
--	wait for 20 us;
--	wait until rising_edge(avl_clk);

	wait;

end process;
end architecture testbench;
--synthesis translate_on
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
