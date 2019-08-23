/*--------------------------------------------------------------------------------------------------------------------------------------------------------------
Copyright (c) ReFLEX CES 1998-2016
-------------------------------------------------------------------------------
Project     : I²C Interface
-------------------------------------------------------------------------------
Top level   : i2c_avalon_tb.vhd
File        : i2c_wrapper_master_tb.vhd
Author      : Jean-Louis FLOQUET
Organization: ReFLEX CES   http://www.reflexces.com
Created     : 2003/03/25
Last update : 2016/02/16 10:26
Version     : 2.00
Dependency  :
-------------------------------------------------------------------------------
Description : Connect a Nios I²C Interface (Master configuration) and emulate processor accesses.
--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
--synthesis translate_off
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;
use     work.i2c_pkg.all;

entity i2c_wrapper_master_tb is port
	( scl : inout sl := 'H'
	; sda : inout sl := 'H'
	);
end entity i2c_wrapper_master_tb;

architecture testbench of i2c_wrapper_master_tb is
	constant CLOCK_PERIOD     : time  :=         10 ns;
	signal   core_sm          : core_type             ;
	signal   core_sm_data_end : sl                    ;
	-- Avalon
	signal   avl_dmn          : domain  := DOMAIN_OPEN  ; -- Asynchronous reset
	signal   avl_clk          : sl      :=          '0' ; -- Main clock system
	signal   avl_address      : slv11   := (others=>'0'); -- CPU address
	signal   avl_chipselect   : sl      :=          '0' ; -- CPU chip select
	signal   avl_irq          : sl                      ; -- CPU Interrupt Request line
	signal   avl_readdata     : slv8                    ; -- CPU read data
	signal   avl_write        : sl      :=          '0' ; -- CPU write request
	signal   avl_writedata    : slv8    := (others=>'0'); -- CPU write data
	---------------------------------------------------

begin

i2c_avalon_master : entity work.i2c_avalon generic map
	( AGENT          => "MASTER"        -- "MASTER", "SLAVE"
	, CLOCK_PERIOD   => CLOCK_PERIOD    -- Clock period
	, DEVICE         => "Stratix"       -- Target device
	, I2C_MODE       => "STANDARD"      -- "STANDARD", "FAST" (SCL @ 100KHz or 400KHz)
	, MEM_MODE       => "CACHE"         -- "BUFFER", "CACHE" (memory behavior)
	, NB_BLOCK       => 1               -- 1 <= n <= 4 (Master), 2 (Slave)
	, NB_REG         => 8               -- 1 <= n <= 8 --> 2**REG
	, RAM_TYPE       => "AUTO"          -- "AUTO", "M512", "M4K", "LCELLS"
	) port map                          --
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
	-- Emulate a standard write processor operation
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

	-- Write a rampe (with the coef.) in the specified memory block
	procedure write_i2c_rampe(block_nb : integer range 0 to 3;
	                          coef     : integer) is
	begin
		for i in 0 to 255 loop
			write_i2c(conv_slv(1024+block_nb*256+i,12),conv_slv(i*coef,8));
		end loop;
	end procedure;

	-- Clear the specified memory block
	procedure write_i2c_clear(block_nb : integer range 0 to 3) is
	begin
		for i in 0 to 255 loop
			write_i2c(conv_slv(1024+block_nb*256+i,12),x"00");
		end loop;
	end procedure;

begin

	wait for 1 us;
	wait until rising_edge(avl_clk);
	-- Initialize the #0 memory block with a Rampe5
	write_i2c_rampe(0,5);
	wait for 1 us;
	wait until rising_edge(avl_clk);

	-- I²C Write (Master ==> I²C ==> Slave)
	write_i2c(x"002",x"12");                                    -- Component address
	write_i2c(x"003",x"02");                                    -- Sub-address
	write_i2c(x"004",x"08");                                    -- Number of byte to be transferred
--	write_i2c(x"000","00" & '1' & '0' & '0' & '1' & '0' & '1'); -- SAE, IEOT, Write, Start
	write_i2c(x"000","00" & '1' & '0' & '0' & '1' & '1' & '1'); -- SAE, IEOT, Read , Start
	wait until avl_irq='1';
	wait until rising_edge(avl_clk);
	write_i2c(x"000",x"08");                                    -- Clear IRQ
	wait for 200 us;
	wait until rising_edge(avl_clk);

	end_simulation(true);
	wait;
end process;

end architecture testbench;
--synthesis translate_on
--##################################################################################################
--##################################################################################################
--##################################################################################################
--##################################################################################################
--##################################################################################################
