/*--------------------------------------------------------------------------------------------------------------------------------------------------------------
Copyright (c) ReFLEX CES 1998-2016
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Project     : I²C Interface
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Top level   : i2c_avalon.vhd
File        : i2c_avalon.vhd
Author      : Jean-Louis FLOQUET
Organization: ReFLEX CES   http://www.reflexces.com
Created     : 2003/03/25
Last update : 2016/03/14 10:57
Version     : 3.02.04
Dependency  :
-------------------------------------------------------------------------------------------------------------------------------------------------------------
Description : Connect sub-entities and realize some basic operations
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  Rev.   |    Date    | Description
 3.02.04 | 2015/04/16 | 1) Fix : Read-back AS & USA bits
         | 2015/04/20 | 2) Fix : Merged NSA with ERROR bit
         | 2016/03/14 | 3) Fix : Read-back OUT_CTRL
         | 2016/03/23 | 4) Enh : Split avl_readdata into two generate sections (Xilinx Vivado performs wrong analysis/synthesis)
 3.01.01 | 2014/03/20 | 1) Chg : Record 'domain'
 3.00.03 | 2012/06/25 | 1) Chg : Mapping for i2c_memory.vhd due to Xilinx compatibility
         |            | 2) New : Avalon interface can be set to 32bits wide
         | 2012/06/27 | 3) Enh : Capability to transfer 256bytes with a single start
 2.02.03 | 2009/03/30 | 1) Chg : std_logic_* replaced with numeric_std. Add pkg_std & pkg_std_unsigned
         | 2009/03/30 | 2) Chg : Asynchronous reset not anymore cleaned by internal logic
         | 2009/04/22 | 3) Chg : CLOCK (integer type) replaced by CLOCK_PERIOD (time type)
 2.01.01 | 2005/11/13 | 1) Enh : Configuration registers in a single signal
         |            | 2) New : Up to 8 I²C bus.
 2.00.00 | 2003/05/29 | Separation between the "core" and the "avalon" part
 1.00.00 | 2003/03/25 | Initial release
         |            |
--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;
use     work.i2c_pkg.all;

entity i2c_avalon is generic
	( AGENT             : string                := "MASTER"   -- "MASTER", "SLAVE"
	; AVL_DPS           : integer range 8 to 32 :=  8         -- Avalon / Data    Path Size
	; CLOCK_PERIOD      : time                  := 10 ns      -- Clock period
	; DEVICE            : string                              -- Target device
	; I2C_MODE          : string                := "STANDARD" -- "STANDARD", "FAST" (SCL @ 100KHz or 400KHz)
	; MEM_MODE          : string                := "BUFFER"   -- "BUFFER" (registers), "CACHE" (memory)
	; NB_BLOCK          : integer range 1 to 4  := 1          -- 1 <= n <= 4 (Master), 2 (Slave)
	; NB_REG            : integer range 1 to 8  := 3          -- 1 <= n <= 8 --> 2**REG
	; RAM_TYPE          : string                := "LCELLS"   -- "AUTO", "M4K", "LCELLS"
	; S_ADDRESS         : integer               := 16#30#     -- I²C component address 7bits (!!!) (must be legal for I²C compliance)
	); port                                                   --
	( dmn               : in    domain                        -- Reset/clock
	  ----------------------------------------------------------
	  -- Avalon                                               --
	  ----------------------------------------------------------
	; avl_address       : in    slv11                         -- CPU address
	; avl_chipselect    : in    sl                            -- CPU chip select
	; avl_irq           : out   sl                            -- CPU Interrupt Request line
	; avl_readdata      : out   slv(AVL_DPS-1 downto 0)       -- CPU Read data
	; avl_write         : in    sl                            -- CPU write request
	; avl_writedata     : in    slv(AVL_DPS-1 downto 0)       -- CPU write data
	  ----------------------------------------------------------
	  -- I²C                                                  --
	  ----------------------------------------------------------
	; scl               : inout sl                            -- SCL, main bus ('0' or 'Z', never drive to '1')
	; sda               : inout sl                            -- SDA, main bus ('0' or 'Z', never drive to '1')
	; scl1              : inout sl                            -- SCL, bus #1   ('0' or 'Z', never drive to '1')
	; sda1              : inout sl                            -- SDA, bus #1   ('0' or 'Z', never drive to '1')
	; scl2              : inout sl                            -- SCL, bus #2   ('0' or 'Z', never drive to '1')
	; sda2              : inout sl                            -- SDA, bus #2   ('0' or 'Z', never drive to '1')
	; scl3              : inout sl                            -- SCL, bus #3   ('0' or 'Z', never drive to '1')
	; sda3              : inout sl                            -- SDA, bus #3   ('0' or 'Z', never drive to '1')
	; scl4              : inout sl                            -- SCL, bus #4   ('0' or 'Z', never drive to '1')
	; sda4              : inout sl                            -- SDA, bus #4   ('0' or 'Z', never drive to '1')
	; scl5              : inout sl                            -- SCL, bus #5   ('0' or 'Z', never drive to '1')
	; sda5              : inout sl                            -- SDA, bus #5   ('0' or 'Z', never drive to '1')
	; scl6              : inout sl                            -- SCL, bus #6   ('0' or 'Z', never drive to '1')
	; sda6              : inout sl                            -- SDA, bus #6   ('0' or 'Z', never drive to '1')
	; scl7              : inout sl                            -- SCL, bus #7   ('0' or 'Z', never drive to '1')
	; sda7              : inout sl                            -- SDA, bus #7   ('0' or 'Z', never drive to '1')
	);
end entity i2c_avalon;

architecture rtl of i2c_avalon is
	------------------------------------------------------
	-- Core state machine and associated signals        --
	------------------------------------------------------
	signal sm_core           : core_type              ; -- Main core state machine
	signal sm_core_r         : core_type              ; -- Main core state machine (1 clock later)
	signal sda_shift         : slv8                   ; -- SDA Shift register (data to send or received)
	signal sda_nd            : sl                     ; -- SDA shift register condition
	------------------------------------------------------
	-- Configuration registers                          --
	------------------------------------------------------
	signal ConfReg           : Conf_Registers         ; --
	signal sm_reference      : reference_type         ; -- State Machine for saving bytes reference
	------------------------------------------------------
	-- Memory control signals                           --
	------------------------------------------------------
	signal avl_mem_readdata  : slv(AVL_DPS-1 downto 0); --
	signal avl_address_r     : slv11                  ;
	signal i2c_readdata      : slv8                   ; --

begin
---------------------------------------------------------------------------
-- IRQ Manager
---------------------------------------------------------------------------
process(dmn)
begin
if dmn.rst='1' then
	avl_irq <= '0';
elsif rising_edge(dmn.clk) then
	if AGENT="MASTER" then
		if ConfReg.cirq='1'                                       then avl_irq <= '0';          -- Clear IRQ
		elsif ConfReg.ieot='1' and sm_core_r=stop and sm_core=eot then avl_irq <= '1'; end if;  -- generate IRQ
	end if;

	if AGENT="SLAVE" then
		if ConfReg.cirq='1'                                        then avl_irq <= '0';         -- Clear IRQ
		elsif ConfReg.ieot='1' and sm_core_r=data and sm_core=idle then avl_irq <= '1'; end if; -- generate IRQ
	end if;
end if;
end process;
---------------------------------------------------------------------------
-- Read Data Manager
---------------------------------------------------------------------------
process(dmn)
begin
if dmn.rst='1' then
	avl_address_r <= (others=>'0');
elsif rising_edge(dmn.clk) then
	avl_address_r <= avl_address;
end if;
end process;

avl_readdata_8 : if AVL_DPS=8 generate
begin
	p_main : process(all)
	begin
		case conv_int(avl_address_r) is
			when 0      => if AGENT="MASTER" then avl_readdata(BYTE_0) <= ConfReg.blk & ConfReg.as & ConfReg.usa & ConfReg.cirq & ConfReg.ieot  & ConfReg.rwn  & ConfReg.start;
			               else                   avl_readdata(BYTE_0) <= "00"        & '0'        &   '0'       & ConfReg.cirq & ConfReg.ieot  & ConfReg.rwn  & ConfReg.start; end if;
			when 1      =>                        avl_readdata(BYTE_0) <= "00"        & '0'        & ConfReg.sbl & '0'          & ConfReg.error & ConfReg.busy & ConfReg.stop ;
			when 2      =>                        avl_readdata(BYTE_0) <= '0'         & ConfReg.addr;
			when 3      =>                        avl_readdata(BYTE_0) <= ConfReg.sub_addr;
			when 4      =>                        avl_readdata(BYTE_0) <= ConfReg.ndbt;
			when 5      => if AGENT="MASTER" then avl_readdata(BYTE_0) <= (others=>'1');
			               else                   avl_readdata(BYTE_0) <= ConfReg.last_ref; end if;
			when 6      =>                        avl_readdata(BYTE_0) <= ConfReg.out_ctrl;
			when others =>                        avl_readdata(BYTE_0) <= avl_mem_readdata;
		end case;
	end process p_main;
end generate avl_readdata_8;

avl_readdata_32 : if AVL_DPS=32 generate
begin
	p_main : process(all)
	begin
		case conv_int(avl_address_r) is
			when 0      => if AGENT="MASTER" then avl_readdata(BYTE_0) <= ConfReg.blk & ConfReg.as & ConfReg.usa & ConfReg.cirq & ConfReg.ieot  & ConfReg.rwn  & ConfReg.start;
			               else                   avl_readdata(BYTE_0) <= "00"        & '0'        &   '0'       & ConfReg.cirq & ConfReg.ieot  & ConfReg.rwn  & ConfReg.start; end if;
			                                      avl_readdata(BYTE_1) <= "00"        & '0'        & ConfReg.sbl & '0'          & ConfReg.error & ConfReg.busy & ConfReg.stop ;
			                                      avl_readdata(BYTE_2) <= '0'         & ConfReg.addr;
			                                      avl_readdata(BYTE_3) <= ConfReg.sub_addr;
			when 4      =>                        avl_readdata(BYTE_0) <= ConfReg.ndbt;
			               if AGENT="MASTER" then avl_readdata(BYTE_1) <= (others=>'1');
			               else                   avl_readdata(BYTE_1) <= ConfReg.last_ref; end if;
			                                      avl_readdata(BYTE_2) <= ConfReg.out_ctrl;
			                                      avl_readdata(BYTE_3) <= (others=>'0');
			when others =>                        avl_readdata         <= avl_mem_readdata;
		end case;
	end process p_main;
end generate avl_readdata_32;
----------------------------------------------------------------
-- I2C Core                                                   --
----------------------------------------------------------------
i2c_core : entity work.i2c_core generic map                   --
	( AGENT            => AGENT                               -- "MASTER", "SLAVE"
	, CLOCK_PERIOD     => CLOCK_PERIOD                        -- Clock period
	, I2C_MODE         => I2C_MODE                            -- "STANDARD", "FAST" (SCL @ 100KHz or 400KHz)
	) port map                                                --
	( dmn              => dmn                                 -- Reset/clock
	  ----------------------------------------------------------
	  -- Backend signals                                      --
	  ----------------------------------------------------------
	, i2c_addr         => ConfReg.addr                        -- component address
	, i2c_data_to      => i2c_readdata                        --
	, i2c_sub_addr     => ConfReg.sub_addr                    -- Sub Address
	, i2c_start        => ConfReg.start                       -- Start Transaction (Master specific)
	, i2c_rwn          => ConfReg.rwn                         -- Read/Write
	, i2c_sbl          => ConfReg.sbl                         -- Slave Boundary Limit (Master specific)
	, i2c_ndbt         => ConfReg.ndbt                        -- Number of Data to Be Transferred
	, i2c_select       => ConfReg.out_ctrl                    -- Select I²C bus
	, i2c_usa          => ConfReg.usa                         -- use Sub-Address
	  ----------------------------------------------------------
	  -- I2C Avalon Core Specific Signals                     --
	  ----------------------------------------------------------
	, h_sm_core        => sm_core                             -- Main core state machine
	, h_sm_core_r      => sm_core_r                           -- Main core state machine (1 clock later)
	, h_sda_shift      => sda_shift                           -- SDA Shift register (data to send or received)
	  ----------------------------------------------------------
	  -- I²C                                                  --
	  ----------------------------------------------------------
	, scl              => scl                                 -- SCL ('0' or 'Z', never drive to '1')
	, sda              => sda                                 -- SDA ('0' or 'Z', never drive to '1')
	, scl1             => scl1                                -- SCL, bus #1   ('0' or 'Z', never drive to '1')
	, sda1             => sda1                                -- SDA, bus #1   ('0' or 'Z', never drive to '1')
	, scl2             => scl2                                -- SCL, bus #2   ('0' or 'Z', never drive to '1')
	, sda2             => sda2                                -- SDA, bus #2   ('0' or 'Z', never drive to '1')
	, scl3             => scl3                                -- SCL, bus #3   ('0' or 'Z', never drive to '1')
	, sda3             => sda3                                -- SDA, bus #3   ('0' or 'Z', never drive to '1')
	, scl4             => scl4                                -- SCL, bus #4   ('0' or 'Z', never drive to '1')
	, sda4             => sda4                                -- SDA, bus #4   ('0' or 'Z', never drive to '1')
	, scl5             => scl5                                -- SCL, bus #5   ('0' or 'Z', never drive to '1')
	, sda5             => sda5                                -- SDA, bus #5   ('0' or 'Z', never drive to '1')
	, scl6             => scl6                                -- SCL, bus #6   ('0' or 'Z', never drive to '1')
	, sda6             => sda6                                -- SDA, bus #6   ('0' or 'Z', never drive to '1')
	, scl7             => scl7                                -- SCL, bus #7   ('0' or 'Z', never drive to '1')
	, sda7             => sda7                                -- SDA, bus #7   ('0' or 'Z', never drive to '1')
	);                                                        --
----------------------------------------------------------------
-- Configuration registers                                    --
----------------------------------------------------------------
i2c_conf_reg : entity work.i2c_conf_reg generic map           --
	( AGENT            => AGENT                               -- "MASTER", "SLAVE"
	, AVL_DPS          => AVL_DPS                             --integer range 8 to 32       -- Avalon / Data    Path Size
	, MEM_MODE         => MEM_MODE                            -- "BUFFER" (registers), "CACHE" (memory)
	, S_ADDRESS        => S_ADDRESS                           -- I²C component address 7bits (!!!) (must be legal for I²C compliance)
	) port map                                                --
	( dmn              => dmn                                 -- Reset/clock
	, sm_core          => sm_core                             -- Main Core State Machine
	, sm_core_r        => sm_core_r                           -- Main Core State Machine (last state)
	, sm_reference     => sm_reference                        -- Address reference byte (Slave specific)
	, sda_shift        => sda_shift                           --
	  ----------------------------------------------------------
	  -- Avalon                                               --
	, avl_address      => avl_address                         -- CPU address
	, avl_chipselect   => avl_chipselect                      -- CPU chip select
	, avl_write        => avl_write                           -- CPU write request
	, avl_writedata    => avl_writedata                       -- CPU write data
	  ------------------------------------------------------------
	  -- Configuration registers                              --
	, ConfReg          => ConfReg                             --
	);                                                        --
----------------------------------------------------------------
-- Internal Memory                                            --
----------------------------------------------------------------
i2c_memory : entity work.i2c_memory generic map               --
	( AGENT            => AGENT                               -- "MASTER", "SLAVE"
	, AVL_DPS          => AVL_DPS                             -- Avalon / Data    Path Size
	, DEVICE           => DEVICE                              -- Target device
	, MEM_MODE         => MEM_MODE                            -- "BUFFER" (registers), "CACHE" (memory)
	, NB_BLOCK         => NB_BLOCK                            -- 1 <= n <= 4 (Master), 2 (Slave)
	, NB_REG           => NB_REG                              -- 1 <= n <= 8 --> 2**REG
	, RAM_TYPE         => RAM_TYPE                            -- "AUTO", "M4K", "LCELLS"
	) port map                                                --
	( dmn              => dmn                                 -- Reset/clock
	, sm_core          => sm_core                             -- Main core state machine
	, sm_reference     => sm_reference                        -- Address reference byte (Slave specific)
	  ----------------------------------------------------------
	  -- Avalon                                               --
	, avl_address      => avl_address                         -- CPU Address
	, avl_chipselect   => avl_chipselect                      -- CPU chip select
	, avl_write        => avl_write                           -- CPU write request
	, avl_writedata    => avl_writedata                       -- CPU write data
	, avl_mem_readdata => avl_mem_readdata                    -- Internal Memory Read port (avalon side)
	  ----------------------------------------------------------
	, ConfReg          => ConfReg                             -- Configuration registers
	, i2c_readdata     => i2c_readdata                        -- Internal Memory Read  port (I²C side)
	, i2c_writedata    => sda_shift                           -- Internal Memory Write port (I²C side)
	);
---------------------------------------------------------------------------
-- Check some parameters
---------------------------------------------------------------------------
assert not(AGENT="SLAVE" and RAM_TYPE="LCELLS")
	report "[i2c_avalon] : RAM_TYPE cannot be set to LCELLS in Slave configuration."
	severity failure;

assert AGENT="MASTER" or AGENT="SLAVE"
	report "[i2c_avalon] : AGENT must be set to MASTER or SLAVE."
	severity failure;

assert I2C_MODE="STANDARD" or I2C_MODE="FAST"
	report "[i2c_avalon] : I2C_MODE allowed value : STANDARD, FAST"
	severity failure;

assert MEM_MODE="BUFFER" or MEM_MODE="CACHE"
	report "[i2c_avalon] : MEM_MODE allowed value : BUFFER, CACHE"
	severity failure;

assert not(AGENT="MASTER" and NB_BLOCK<1)
	report "[i2c_avalon] : NB_BLOCK invalid value"
	severity failure;

assert not(AGENT="MASTER" and NB_BLOCK>4)
	report "[i2c_avalon] : NB_BLOCK must not exceed 4"
	severity failure;

assert not(AGENT="SLAVE" and NB_BLOCK/=2)
	report "[i2c_avalon] : NB_BLOCK must be set to 2 in SLAVE mode"
	severity failure;

assert not(AGENT="SLAVE" and MEM_MODE="BUFFER")
	report "[i2c_avalon] : MEM_MODE cannot be set to BUFFER in Slave configuration."
	severity failure;

assert not(AGENT="SLAVE" and NB_BLOCK/=2)
	report "[i2c_avalon] : NB_BLOCK must be set to 2 in SLAVE mode."
	severity failure;

assert NB_REG>=1 and NB_REG<=8
	report "[i2c_avalon] : NB_REG must be set in range [1..8]"
	severity failure;

assert AVL_DPS=8 or AVL_DPS=32
	report "[i2c_avalon] : Unsupported AVL_DPS value !!"
	severity failure;

end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
