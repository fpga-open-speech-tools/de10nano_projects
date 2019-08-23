/*--------------------------------------------------------------------------------------------------------------------------------------------------------------
Copyright (c) ReFLEX CES 1998-2016
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Project     : I²C Interface
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Top level   : i2c_wrapper_slave.vhd
File        : i2c_wrapper_slave.vhd
Author      : Jean-Louis FLOQUET
Organization: ReFLEX CES   http://www.reflexces.com
Created     : 2003/03/25
Last update : 2016/02/16 10:26
Version     : 2.00
Dependency  :
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Description : Connect a Nios I²C Interface in Slave configuration
--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;
use     work.i2c_pkg.all;

entity i2c_wrapper_slave is generic
	( DEVICE            : string                              -- Target device
	); port                                                   --
	( dmn               : in    domain                        -- Reset/clock
	  -- Avalon                                               --
	; avl_address       : in    slv11                         -- CPU address
	; avl_chipselect    : in    sl                            -- CPU chip select
	; avl_irq           : out   sl                            -- CPU Interrupt Request line
	; avl_readdata      : out   slv8                          -- CPU Read data
	; avl_write         : in    sl                            -- CPU write request
	; avl_writedata     : in    slv8                          -- CPU write data
	  ----------------------------------------------------------
	  -- I²C                                                  --
	  ----------------------------------------------------------
	; scl               : inout sl                            -- SCL ('0' or 'Z', never drive to '1')
	; sda               : inout sl                            -- SDA ('0' or 'Z', never drive to '1')
	);
end entity i2c_wrapper_slave;

architecture rtl of i2c_wrapper_slave is

begin

i2c_avalon_slave : entity work.i2c_avalon generic map
	( AGENT            => "SLAVE"         -- "MASTER" "SLAVE"
	, CLOCK_PERIOD     => 10 ns           -- Clock period
	, DEVICE           => DEVICE          -- Target device
	, I2C_MODE         => "STANDARD"      -- "STANDARD" "FAST" (SCL @ 100KHz or 400KHz)
	, MEM_MODE         => "CACHE"         -- "BUFFER" "CACHE" (memory behavior)
	, NB_BLOCK         => 2               -- 1 <= n <= 4 (Master), 2 (Slave)
	, NB_REG           => 8               -- 1 <= n <= 8 --> 2**REG
	, RAM_TYPE         => "AUTO"          -- "AUTO" "M512", "M4K", "LCELLS"
	, S_ADDRESS        => 16#30#          -- I²C component address (must be legal for I²C compliance)
	) port map
	( dmn              => dmn             -- Reset/clock
	  -- Avalon                           --
	, avl_address      => avl_address     -- CPU address
	, avl_chipselect   => avl_chipselect  -- CPU chip select
	, avl_irq          => avl_irq         -- CPU Interrupt Request line
	, avl_readdata     => avl_readdata    -- CPU read data
	, avl_write        => avl_write       -- CPU write request
	, avl_writedata    => avl_writedata   -- CPU write data
	  -- I²C                              --
	, scl              => scl             -- SCL
	, sda              => sda             -- SDA
	);
end architecture rtl;
--##################################################################################################
--##################################################################################################
--##################################################################################################
--##################################################################################################
--##################################################################################################
