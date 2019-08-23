/*--------------------------------------------------------------------------------------------------------------------------------------------------------------
Copyright (c) ReFLEX CES 1998-2016
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Project     : I²C Interface
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Title       : I²C Embedded Memory
File        : i2c_memory.vhd
Author      : Jean-Louis FLOQUET
Organization: ReFLEX CES   http://www.reflexces.com
Created     : 2003/03/25
Last update : 2016/03/16 12:29
Version     : 3.02.01
Dependency  :
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Description : Implement an internal memory block
                 * Master mode : acts as a cache for external components
                 * Slave mode  : main memory (256bytes)
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  Rev.   |    Date    | Description
 3.02.01 | 2016/02/16 | 1) Fix : avl_mem_readdata when AVL_DPS is not set to 8
 3.01.01 | 2014/03/20 | 1) Chg : Record 'domain'
 3.00.01 | 2012/06/25 | 1) New : Xilinx compatibility
 2.02.01 | 2011/06/26 | 1) Chg : Replaced direct Altera memory with universal one's
 2.01.01 | 2009/03/30 | 1) Chg : std_logic_* replaced with numeric_std. Add pkg_std & pkg_std_unsigned
 2.00.01 | 2003/05/29 | 1) Enh : Capability to use without Nios
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

entity i2c_memory is generic
	( AGENT             : string                              -- "MASTER", "SLAVE"
	; AVL_DPS           : integer range 8 to 32               -- Avalon / Data    Path Size
	; DEVICE            : string                              -- Target device
	; MEM_MODE          : string                              -- "BUFFER" (registers), "CACHE" (memory)
	; NB_BLOCK          : integer                             -- 1 <= n <= 4 (Master), 2 (Slave)
	; NB_REG            : integer                             -- 1 <= n <= 8 --> 2**REG
	; RAM_TYPE          : string                              -- "AUTO", "M4K", "LCELLS"
	); port                                                   --
	( dmn               : in    domain                        -- Reset/clock
	; sm_core           : in    core_type                     -- Main core state machine
	; sm_reference      : in    reference_type                -- Address reference byte (Slave specific)
	  ----------------------------------------------------------
	  -- Avalon                                               --
	; avl_address       : in    slv11                         -- CPU Address
	; avl_chipselect    : in    sl                            -- CPU chip select
	; avl_write         : in    sl                            -- CPU write request
	; avl_writedata     : in    slv(AVL_DPS-1 downto 0)       -- CPU write data
	; avl_mem_readdata  : out   slv(AVL_DPS-1 downto 0)       -- Internal Memory Read port (avalon side)
	  ----------------------------------------------------------
	; ConfReg           : in    Conf_Registers                -- Configuration registers
	; i2c_readdata      : out   slv8                          -- Internal Memory Read  port (I²C side)
	; i2c_writedata     : in    slv8                          -- Internal Memory Write port (I²C side)
	);
end entity i2c_memory;

architecture rtl of i2c_memory is
	type mem_reg_type is array (0 to 2**NB_REG-1) of slv8;

	function Compute_APS(dps: int) return int is
		variable result : int;
	begin
		if dps=8 then
			case NB_BLOCK is
				when 1      => result :=  8; --  256 x 8
				when 2      => result :=  9; --  512 x 8
				when 3      => result := 10; --  768 x 8 --> 1K x 8
				when 4      => result := 10; --   1K x 8
				when others => result :=  0;
			end case;
		elsif dps=32 then
			case NB_BLOCK is
				when 1      => result :=  6; --  256 x 8 --> 256 x 8 -->  64 x 32
				when 2      => result :=  7; --  512 x 8 --> 512 x 8 --> 128 x 32
				when 3      => result :=  8; --  768 x 8 -->  1K x 8 --> 256 x 32
				when 4      => result :=  8; --   1K x 8 -->  1K x 8 --> 256 x 32
				when others => result :=  0;
			end case;
		end if;
		return result;
	end function Compute_APS;

	constant A_APS          : integer := Compute_APS(AVL_DPS); -- Avalon interface
	constant I2C_APS        : integer := Compute_APS(      8); -- I²C path is always 8bits wide
	signal   avl_mem_write  : sl                             ; -- Avalon write to internal memory
	signal   buffer_reg     : mem_reg_type                   ; -- Buffer memory in logic cells
	signal   cache_reg      : mem_reg_type                   ; -- Cache  memory in logic cells
	signal   i2c_address    : slv10                          ; -- I²C address for internal memory
	signal   i2c_write      : sl                             ; -- I²C write condition for internal memory
	signal   i2c_write_data : slv8                           ; -- Internal Memory Write port (I²C side)
begin
---------------------------------------------------------------------------
-- Create internal memory
---------------------------------------------------------------------------
ram_type_memory : if RAM_TYPE/="LCELLS" generate
	signal avl_mem_address : slv(A_APS-1 downto 0);
begin

	avl_mem_address <= avl_address(9 downto 0) when AVL_DPS= 8 else
	                   avl_address(7 downto 2) when AVL_DPS=32 and NB_BLOCK =1 else
	                   avl_address(8 downto 2) when AVL_DPS=32 and NB_BLOCK =2 else
	                   avl_address(9 downto 2) when AVL_DPS=32 and NB_BLOCK>=3 else
	                   (others=>'X');

	assert not(avl_address(10 downto 8)="110" and NB_BLOCK<3) report "[i2c_memory] : Trying to access an unimplemented memory block !!" severity failure;
	assert not(avl_address(10 downto 8)="111" and NB_BLOCK<3) report "[i2c_memory] : Trying to access an unimplemented memory block !!" severity failure;
	assert not(avl_address(10 downto 8)="111" and NB_BLOCK<4) report "[i2c_memory] : Trying to access an unimplemented memory block !!" severity failure;

	memory : entity work.memory generic map
		( A_APS            => A_APS                                 --natural range 0 to integer'high        :=  8            -- Address Path Size
		, A_BPS            => AVL_DPS/8                             --natural range 0 to integer'high        :=  1            -- BE      Path Size
		, A_DPS            => AVL_DPS                               --natural range 0 to integer'high        := 16            -- Data    Path Size
		, A_MODE           => "RW"                                  --string                                 := "WO"          -- WO / RO / RW (Write Only / Read Only / Read & Write)
		, A_RD_LAT         =>   1                                   --natural range 1 to 2                   :=  2            -- Read Latency between A_RdReq and A_RdData
		, A_RD_XTRA_REG    => false                                 --boolean                                := false         -- Add extra register on read bus from memory block. This increases effective A_RD_LAT value
		, B_APS            => I2C_APS                               --natural range 0 to integer'high        :=  7            -- Address Path Size
		, B_BPS            =>   1                                   --natural range 0 to integer'high        :=  1            -- BE      Path Size
		, B_DPS            =>   8                                   --natural range 0 to integer'high        := 32            -- Data    Path Size
		, B_MODE           => "RW"                                  --string                                 := "RO"          -- WO / RO / RW (Write Only / Read Only / Read & Write)
		, B_RD_LAT         =>   2                                   --natural range 0 to 2                   :=  2            -- Read Latency between B_RdReq and B_RdData
		, B_RD_XTRA_REG    => false                                 --boolean                                := false         -- Add extra register on read bus from memory block. This increases effective B_RD_LAT value
		, USE_BE           => false                                 --boolean                                := false         -- Use ByteEnable
		, DEVICE           => DEVICE                                --string                                                  -- Target Device
		, RAM_BLOCK_TYPE   => "AUTO"                                --string                                 := "AUTO"        -- "M512" / "M4K" / "M9K" / "M-RAM" / "AUTO"
		, BYTE_MODE        =>   8                                   --natural range 8 to 9                   :=  8            -- Size for one "byte". If 9, use extra-bit from Memory block
		  --synthesis translate_off                                 --                                                        --
		, VERBOSE          =>  true                                 --boolean                                := false         -- Display debug messages
		  --synthesis translate_on                                  --                                                        --
		, INIT_FILE        => "UNUSED"                              --string                                 := "UNUSED"      -- "UNUSED" or filename
		, INIT_FILE_LAYOUT => "UNUSED"                              --string                                 := "UNUSED"      -- Initial content file conforms to port's dimensions A or B ("UNUSED" / "PORT_A" / "PORT_B")
		) port map                                                  --                                                        --
		( A_Dmn            => dmn                                   --in  domain                                              -- Reset/clock
		, A_Addr           => avl_mem_address                       --in  std_logic_vector(A_APS-1 downto 0) := (others=>'0') -- Address
		, A_Wr             => avl_mem_write                         --in  std_logic                          :=          '0'  -- Write Request
		, A_WrData         => avl_writedata                         --in  std_logic_vector(A_DPS-1 downto 0) := (others=>'0') -- Write Data
		, A_RdData         => avl_mem_readdata                      --out std_logic_vector(A_DPS-1 downto 0)                  -- Read Data
                                                                                                                              --
		, B_Dmn            => dmn                                   --in  domain                                              -- Reset/clock
		, B_Addr           => i2c_address(I2C_APS-1 downto 0)       --in  std_logic_vector(B_APS-1 downto 0) := (others=>'0') -- Address
		, B_Wr             => i2c_write                             --in  std_logic                          :=          '0'  -- Write Request
		, B_WrData         => i2c_write_data                        --in  std_logic_vector(B_DPS-1 downto 0) := (others=>'0') -- Write Data
		, B_RdData         => i2c_readdata                          --out std_logic_vector(B_DPS-1 downto 0)                  -- Read Data
		);
end generate ram_type_memory;
---------------------------------------------------------------------------
-- Master interface
---------------------------------------------------------------------------
master_ram : if AGENT="MASTER" and RAM_TYPE/="LCELLS" generate
	i2c_address <= "00"        & ConfReg.buf_addr when MEM_MODE="BUFFER" else
	               ConfReg.blk & ConfReg.sub_addr when MEM_MODE="CACHE"  else
	               (others=>'X');

	avl_mem_write <= '1' when avl_chipselect='1' and avl_write='1' and avl_address(10)='1' else '0'; -- A block is selected
	i2c_write     <= '1' when ConfReg.rwn   ='1' and sm_core=data_end                      else '0'; -- Read I²C ==> Write into memory
end generate master_ram;

master_lcells_buffer : if AGENT="MASTER" and RAM_TYPE="LCELLS" and MEM_MODE="BUFFER" generate
	process(dmn)
	begin
	if dmn.rst='1' then
		buffer_reg <= (others=>(others=>'0'));
	elsif rising_edge(dmn.clk) then
		-- Nios operation (8bits)
		if AVL_DPS=8 then
			for i in 0 to 2**NB_REG-1 loop
				if avl_chipselect='1' and avl_write='1' and avl_address(10)='1' and avl_address(NB_REG-1 downto 0)=(AVL_DPS/8)*i then
					buffer_reg(i) <= avl_writedata;
				end if;
			end loop;
		end if;

		-- Nios operation (32bits)
		if AVL_DPS=32 then
			for i in 0 to (2**NB_REG)/4-1 loop
				if avl_chipselect='1' and avl_write='1' and avl_address(10)='1' and avl_address(NB_REG-1 downto 0)=4*i then
					buffer_reg(4*i+0) <= avl_writedata(BYTE_0);
					buffer_reg(4*i+1) <= avl_writedata(BYTE_1);
					buffer_reg(4*i+2) <= avl_writedata(BYTE_2);
					buffer_reg(4*i+3) <= avl_writedata(BYTE_3);
				end if;
			end loop;
		end if;

		-- I²C operation
		for i in 0 to 2**NB_REG-1 loop
			if sm_core=data_end and ConfReg.buf_addr=i and ConfReg.rwn='1' then
				buffer_reg(i) <= i2c_writedata;
			end if;
		end loop;
	end if;
	end process;

	-- Avalon read buffer
	avl_mem_readdata <= buffer_reg(conv_int(avl_address(NB_REG-1 downto 0))  ) when AVL_DPS=8 else
	                    buffer_reg(conv_int(avl_address(NB_REG-1 downto 0))+3)
                      & buffer_reg(conv_int(avl_address(NB_REG-1 downto 0))+2)
                      & buffer_reg(conv_int(avl_address(NB_REG-1 downto 0))+1)
                      & buffer_reg(conv_int(avl_address(NB_REG-1 downto 0))+0) when AVL_DPS=32 else
                      (others=>'0');

	i2c_readdata     <=          buffer_reg(conv_int(ConfReg.buf_addr(NB_REG-1 downto 0)))                         ; -- I²C read buffer

	-- Dummy part
	avl_mem_write <= '0';
	i2c_write     <= '0';
	cache_reg     <= (others=>(others=>'0'));
end generate master_lcells_buffer;

master_lcells_cache : if AGENT="MASTER" and RAM_TYPE="LCELLS" and MEM_MODE="CACHE" generate
	cache_sub_reg : for i in 0 to 2**NB_REG-1 generate
		process(dmn)
		begin
		if dmn.rst='1' then
			cache_reg(i) <= (others=>'0');
		elsif rising_edge(dmn.clk) then
			if sm_core=data_end and ConfReg.sub_addr=i and ConfReg.rwn='1'                                          then cache_reg(i) <= i2c_writedata; -- I²C operation
			elsif avl_chipselect='1' and avl_write='1' and avl_address(10)='1' and avl_address(NB_REG-1 downto 0)=i then cache_reg(i) <= avl_writedata; -- Nios operation
			end if;
		end if;
		end process;
	end generate cache_sub_reg;
	avl_mem_readdata <= cache_reg(0); -- Avalon read buffer
	i2c_readdata     <= cache_reg(0); -- I²C read buffer

	-- Dummy part
	avl_mem_write <= '0';
	i2c_write     <= '0';
	buffer_reg    <= (others=>(others=>'0'));
end generate master_lcells_cache;

i2c_write_data_master : if AGENT="MASTER" generate
	i2c_write_data <= i2c_writedata;
end generate i2c_write_data_master;
---------------------------------------------------------------------------
-- Slave interface
---------------------------------------------------------------------------
slave : if AGENT="SLAVE" generate
	avl_mem_write  <= '1' when avl_chipselect='1' and avl_write='1' and avl_address(10)='1' and avl_address(9 downto 8)=0 else -- Avalon writes into internal memory (0x400...0x7FF)
	                  '0';

	i2c_address    <= "01" & ConfReg.last_ref when (sm_reference=write_first or sm_reference=write_second) else -- Last reference writing
	                  "00" & ConfReg.sub_addr;                                                                  -- Sub-address

	i2c_write_data <= ConfReg.sub_addr when (sm_reference=write_first or sm_reference=write_second) else -- Last reference writing
	                  i2c_writedata;                                                                     -- Sub-address data

	i2c_write      <= '1' when (sm_reference=write_first or sm_reference=write_second) or (ConfReg.rwn='0' and sm_core=data_end) else -- Last reference of I²C write condition
	                  '0';
end generate slave;

end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
