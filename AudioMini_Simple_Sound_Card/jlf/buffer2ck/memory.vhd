/*--------------------------------------------------------------------------------------------------------------------------------------------------------------
Author      : Jean-Louis FLOQUET
Title       : Generic Memory Block
File        : memory.vhd
Application : RTL & Simulation
Created     : 2004/03/08
Last update : 2015/03/12 14:33
Version     : 3.06.03
Dependency  : memory_altera.vhd for ALTERA devices (shall be compiled AFTER this entity)
              memory_xilinx.vhd for XILINX devices (shall be compiled AFTER this entity)
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Description : Memory with 2 clocks. Instanciate appropriate funder version (ALTERA or XILINX)
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  Rev.   |    Date    | Description
 3.06.03 | 2015/02/25 | 1) Enh : Check inputs validity during write and/or read operations
         | 2015/03/11 | 2) New : Support for Arria 10 devices
         | 2015/03/12 | 3) New : Support for MAX 10 devices
         |            |
 3.05.01 | 2014/07/23 | 1) New : Support for Cyclone V devices
 3.04.03 | 2014/02/05 | 1) New : Check inputs validity during write and/or read operations (see CHECK_WRITE and CHECK_READ)
         | 2014/02/19 | 2) Enh : Drive dangling output ports when unappropriate architecture is compiled. Avoid 'vsim-8683' warning
         | 2014/03/18 | 3) Chg : Record 'domain'
 3.03.02 | 2013/09/25 | 1) Enh : Low-level configuration for ROM
         |            | 2) Chg : VHDL-2008 required
 3.02.01 | 2013/07/17 | 1) Fix : x_RD_LAT range was [0:2] instead of [1:2]
 3.01.02 | 2012/05/09 | 1) New : Support for Spartan6 devices
         | 2012/06/19 | 2) New : Support for Virtex7 devices
 3.00.01 | 2012/01/08 | 1) New : Asynchronous reset for each side
 2.06.02 | 2011/12/15 | 1) Chg : rst is now optional. User shall ensures there is no side effect
         | 2011/12/16 | 2) New : Read enable commands
 2.05.03 | 2010/12/21 | 1) New : Support for 'EMPTY' memory ressource (no physical memory block, debug only)
         | 2011/01/17 | 2) Enh : Add support for '_' instead of space in DEVICE value
         | 2011/03/05 | 3) Fix : BPS value when BE are not used and DPS/=8
 2.04.01 | 2009/09/01 | 1) New : Support for Stratix IV devices
 2.03.01 | 2009/02/12 | 1) Fix : A dummy crazy bug using BPS instead of DPS
 2.02.07 | 2008/11/12 | 1) Fix : memory_xilinx for DPS/=2^n.
         | 2008/11/19 | 2) Fix : memory_altera for different RAM_BLOCK_TYPE versus DEVICE
         | 2008/11/24 | 3) Fix : (Major) Internal configuration for memory_xilinx
         | 2008/12/03 | 4) Fix : memory_xilinx was not able to provide A_RdData
         |            | 5) Fix : VERBOSE generic hidden for synthesis
         | 2008/12/08 | 6) Fix : Function 'FixDataBusOrder' in memory_xilinx
         | 2008/12/17 | 7) Enh : Option for extra register on read data path. See [Note 2]. Several bug fixed 2009/01/10
 2.01.02 | 2008/06/09 | 1) Fix : AltSyncRam read port are connected only if required (avoid fitter error)
         |            | 2) Fix : Remove warning about string comparaison (different lengths) for Xilinx ISE
 2.00.01 | 2008/01/30 | 1) Chg : Solved a big headache when Altera's or Xilinx's part not compiled
         |            |          memory_altera and memory_xilinx files don't contain anymore entity that moved to this file.
 1.06.03 | 2007/10/11 | 1) New : Clock enable
         |            | 2) New : Support for "Stratix III" and "Cyclone III" devices
         |            | 3) Fix : ALTERA Memory instanciation with clock enable
 1.05.03 | 2007/01/25 | 1) New : ByteEnable for datapath support
         |            | 2) Fix : A=ReadOnly and B=WriteOnly is not possible for AltSyncRam
         |            | 3) New : Support for Cyclone & Stratix II devices
 1.04.01 | 2006/07/04 | 1) New : Support for same clock on both sides (CLOCK_MODE)
 1.03.04 | 2006/03/08 | 1) New : Cyclone II device family support
         |            | 2) Fix : Error condition for different data path on APEX/ACEX family
         |            | 3) Enh : Use only A_DPS for APEX/ACEX family
         |            | 4) Chg : DEVICE values changed to "official" from ALTERA
 1.02.02 | 2006/02/22 | 1) Fix : Error message for different DPS on Apex & Acex technologies
         | 2006/02/24 | 2) New : Bidirectionnal buffer. "Wr" & "Rd" renamed to "A" and "B".
 1.01.03 | 2005/05/20 | 1) New : Support for Stratix family
         | 2005/09/15 | 2) New : Support unregistered memory on Stratix
         | 2005/10/06 | 3) New : Different APS & DPS for both sides
 1.00.00 | 2004/03/08 | Initial release
         |            |
----------------------------------------------------------------------------------------------------------------------------------------------------------------
¤¤¤¤¤¤¤¤¤¤¤¤
¤ Generics ¤
¤¤¤¤¤¤¤¤¤¤¤¤
* DEVICE
    * "EMPTY"          : Doesn't implement any memory ressource. Used for debug purposes only
    * "ACEX"           : ALTERA Acex 1K
    * "APEX20KE"       : ALTERA Apex 20KE
    * "Arria GX"       : ALTERA Arria GX
    * "Arria II GX"    : ALTERA Arria II GX
    * "Arria II GZ"    : ALTERA Arria II GZ
    * "Arria 10"       : ALTERA Arria 10
    * "Cyclone"        : ALTERA Cyclone
    * "Cyclone II"     : ALTERA Cyclone II
    * "Cyclone III"    : ALTERA Cyclone III
    * "Cyclone III LS" : ALTERA Cyclone III LS
    * "Cyclone IV E"   : ALTERA Cyclone IV E
    * "Cyclone IV GX"  : ALTERA Cyclone IV GX
    * "MAX 10"         : ALTERA MAX 10
    * "HardCopy II"    : ALTERA HardCopy II
    * "HardCopy III"   : ALTERA HardCopy III
    * "HardCopy IV"    : ALTERA HardCopy IV
    * "Stratix"        : ALTERA Stratix
    * "Stratix GX"     : ALTERA Stratix GX
    * "Stratix II"     : ALTERA Stratix II
    * "Stratix II GX"  : ALTERA Stratix II GX
    * "Stratix III"    : ALTERA Stratix III
    * "Stratix IV"     : ALTERA Stratix IV
    * "Stratix V"      : ALTERA Stratix V
    * "Virtex 4"       : XILINX Virtex 4
    * "Virtex 5"       : XILINX Virtex 5
--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
library ieee;
use     ieee.std_logic_1164.all;

library work;
use     work.pkg_std.all;

entity memory_altera is generic
	( A_APS                      : natural range 0 to integer'high        :=  8            -- Address Path Size
	; A_BPS                      : natural range 0 to integer'high        :=  1            -- BE      Path Size
	; A_DPS                      : natural range 0 to integer'high        := 16            -- Data    Path Size
	; A_MODE                     : string                                 := "WO"          -- WO / RO / RW (Write Only / Read Only / Read & Write)
	; A_RD_LAT                   : natural range 1 to 2                   :=  2            -- Read Latency between A_RdReq and A_RdData
	; A_RD_XTRA_REG              : boolean                                := false         -- Add extra register on read bus from memory block. This increases effective A_RD_LAT value
	; B_APS                      : natural range 0 to integer'high        :=  7            -- Address Path Size
	; B_BPS                      : natural range 0 to integer'high        :=  1            -- BE      Path Size
	; B_DPS                      : natural range 0 to integer'high        := 32            -- Data    Path Size
	; B_MODE                     : string                                 := "RO"          -- WO / RO / RW / OPEN (Write Only / Read Only / Read & Write / OPEN)
	; B_RD_LAT                   : natural range 1 to 2                   :=  2            -- Read Latency between B_Rd and B_RdData
	; B_RD_XTRA_REG              : boolean                                := false         -- Add extra register on read bus from memory block. This increases effective B_RD_LAT value
	; USE_BE                     : boolean                                := false         -- Use ByteEnable
	; DEVICE                     : string                                                  -- Target Device
	; RAM_BLOCK_TYPE             : string                                 := "AUTO"        -- M512 / M4K / M9K / M10K / M20K / M144K / MLAB / M-RAM / MEGARAM / LUTRAM / AUTO
	; BYTE_MODE                  : natural range 8 to 9                   :=  8            -- Size for one "byte". If 9, use extra-bit from Memory block
	  --synthesis translate_off                                                            --
	; VERBOSE                    : boolean                                := false         -- Display debug messages
	  --synthesis translate_on                                                             --
	; INIT_FILE                  : string                                 := "UNUSED"      -- "UNUSED" or filename
	; INIT_FILE_LAYOUT           : string                                 := "UNUSED"      -- Initial content file conforms to port's dimensions A or B ("UNUSED" / "PORT_A" / "PORT_B")
	  -- ECC Status Parameters                                                             --
	; ENABLE_ECC                 : string                                 := "FALSE"       -- ECC / Activate
	; WIDTH_ECCSTATUS            : integer                                :=  3            -- ECC / Status width
	; ECC_PIPELINE_STAGE_ENABLED : string                                 := "FALSE"       -- ECC / Pipelined operations
	); port                                                                                --
	( A_Dmn                      : in  domain                             := DOMAIN_OPEN   -- Clock/reset/clock enable
	; A_Addr                     : in  std_logic_vector(A_APS-1 downto 0) := (others=>'0') -- Address
	; A_Wr                       : in  std_logic                          :=          '0'  -- Write Request
	; A_WrData                   : in  std_logic_vector(A_DPS-1 downto 0) := (others=>'0') -- Write Data
	; A_WrBE                     : in  std_logic_vector(A_BPS-1 downto 0) := (others=>'1') -- Write ByteEnable
	; A_Rd                       : in  std_logic                          :=          '1'  -- Read Request
	; A_RdData                   : out std_logic_vector(A_DPS-1 downto 0)                  -- Read Data
	; A_RdBE                     : out std_logic_vector(A_BPS-1 downto 0)                  -- Read ByteEnable
	; B_Dmn                      : in  domain                             := DOMAIN_OPEN   -- Clock/reset/clock enable
	; B_Addr                     : in  std_logic_vector(B_APS-1 downto 0) := (others=>'0') -- Address
	; B_Wr                       : in  std_logic                          :=          '0'  -- Write Request
	; B_WrData                   : in  std_logic_vector(B_DPS-1 downto 0) := (others=>'0') -- Write Data
	; B_WrBE                     : in  std_logic_vector(B_BPS-1 downto 0) := (others=>'1') -- Write ByteEnable
	; B_Rd                       : in  std_logic                          :=          '1'  -- Read Request
	; B_RdData                   : out std_logic_vector(B_DPS-1 downto 0)                  -- Read Data
	; B_RdBE                     : out std_logic_vector(B_BPS-1 downto 0)                  -- Read ByteEnable
	);
end entity memory_altera;
/*
OK, let's have some explaination about this curious architecture: VHDL is a beautifull language, but sometimes
it's really a headache to create a fully customizable design. This design is intended to be compiled and simulated
in the following conditions:
   * user doesn't have neither ALTERA neither XILINX libraries (hehe, maybe we should wake up this user !)
   * user has only ALTERA libraries. Obviously, the XILINX part cannot be compiled. ModelSim returns error
     "Error: (vopt-11) Could not find work.buffer2ck_memory(rtl)." And it's where VHDL language become a very bad
     guy : this entity is instanciated inside a non-generated "GENERATE" loop !!! When this test is false, kick this
     part, shut up, go away, and don't harass me. As a famous DJ would have said, it's "the non existant nothing"...
   * user has only XILINX libraries. You read the previous section switching ALTERA and XILINX. Easy, isn't it ?
   * user has both ALTERA and XILINX libraries. Welcome to wonderland !! But go back to Earth.

The easiest way I found to not get any error message is to create a very small architecture for each part (Altera
and Xilinx). VHDL and ModelSim are happy, they don't return nothing. Shut, hear the silent :)

Once you gone back to earth, another problem arrives : synthesis tools don't appreciate to have twice the same
architecture (this little one and the true one, in dedicated file corresponding to founder). So, let's go solving
this : add directives to mask this so tiny architecture from synthesis tools.
*/
--synthesis translate_off
architecture rtl of memory_altera is
begin
	assert false
		report "[memory] : memory_altera architecture has not been compiled. This message comes from the dummy architecture and won't do anything else !"
		severity failure;

	-- Just to avoid 'vsim-8683' warning in case of this architecture was compiled (instead of the good one)
	-- These warnings appear BEFORE the 'assert' execution and will pollute display
	A_RdData <= (others=>'X');
	A_RdBE   <= (others=>'X');
	B_RdData <= (others=>'X');
	B_RdBE   <= (others=>'X');
end architecture rtl;
--synthesis translate_on
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
library ieee;
use     ieee.std_logic_1164.all;

library work;
use     work.pkg_std.all;

entity memory_xilinx is generic
	( A_APS                      : natural range 0 to integer'high        :=  8            -- Address Path Size
	; A_BPS                      : natural range 0 to integer'high        :=  1            -- BE      Path Size
	; A_DPS                      : natural range 0 to integer'high        := 16            -- Data    Path Size
	; A_MODE                     : string                                 := "WO"          -- WO / RO / RW (Write Only / Read Only / Read & Write)
	; A_RD_LAT                   : natural range 1 to 2                   :=  2            -- Read Latency between A_RdReq and A_RdData
	; A_RD_XTRA_REG              : boolean                                := false         -- Add extra register on read bus from memory block. This increases effective A_RD_LAT value
	; B_APS                      : natural range 0 to integer'high        :=  7            -- Address Path Size
	; B_BPS                      : natural range 0 to integer'high        :=  1            -- BE      Path Size
	; B_DPS                      : natural range 0 to integer'high        := 32            -- Data    Path Size
	; B_MODE                     : string                                 := "RO"          -- WO / RO / RW / OPEN (Write Only / Read Only / Read & Write / OPEN)
	; B_RD_LAT                   : natural range 1 to 2                   :=  2            -- Read Latency between B_Rd and B_RdData
	; B_RD_XTRA_REG              : boolean                                := false         -- Add extra register on read bus from memory block. This increases effective B_RD_LAT value
	; USE_BE                     : boolean                                := false         -- Use ByteEnable
	; DEVICE                     : string                                                  -- Target Device
	; RAM_BLOCK_TYPE             : string                                 := "AUTO"        -- Specify which RAM block type should be used
	; BYTE_MODE                  : natural range 8 to 9                   :=  8            -- Size for one "byte". If 9, use extra-bit from Memory block
	  --synthesis translate_off                                                            --
	; VERBOSE                    : boolean                                := false         -- Display debug messages
	  --synthesis translate_on                                                             --
	; INIT_FILE                  : string                                 := "UNUSED"      -- "UNUSED" or filename
	; INIT_FILE_LAYOUT           : string                                 := "UNUSED"      -- Initial content file conforms to port's dimensions A or B ("UNUSED" / "PORT_A" / "PORT_B")
	); port                                                                                --
	( A_Dmn                      : in  domain                             := DOMAIN_OPEN   -- Clock/reset/clock enable
	; A_Addr                     : in  std_logic_vector(A_APS-1 downto 0) := (others=>'0') -- Address
	; A_Wr                       : in  std_logic                          :=          '0'  -- Write Request
	; A_WrData                   : in  std_logic_vector(A_DPS-1 downto 0) := (others=>'0') -- Write Data
	; A_WrBE                     : in  std_logic_vector(A_BPS-1 downto 0) := (others=>'1') -- Write ByteEnable
	; A_Rd                       : in  std_logic                          :=          '1'  -- Read Request
	; A_RdData                   : out std_logic_vector(A_DPS-1 downto 0)                  -- Read Data
	; A_RdBE                     : out std_logic_vector(A_BPS-1 downto 0)                  -- Read ByteEnable
	; B_Dmn                      : in  domain                             := DOMAIN_OPEN   -- Clock/reset/clock enable
	; B_Addr                     : in  std_logic_vector(B_APS-1 downto 0) := (others=>'0') -- Address
	; B_Wr                       : in  std_logic                          :=          '0'  -- Write Request
	; B_WrData                   : in  std_logic_vector(B_DPS-1 downto 0) := (others=>'0') -- Write Data
	; B_WrBE                     : in  std_logic_vector(B_BPS-1 downto 0) := (others=>'1') -- Write ByteEnable
	; B_Rd                       : in  std_logic                          :=          '1'  -- Read Request
	; B_RdData                   : out std_logic_vector(B_DPS-1 downto 0)                  -- Read Data
	; B_RdBE                     : out std_logic_vector(B_BPS-1 downto 0)                  -- Read ByteEnable
	);
end entity memory_xilinx;

-- See note just before memory_xilinx's architecture
--synthesis translate_off
architecture rtl of memory_xilinx is
begin
	assert false
		report "[memory] : memory_xilinx architecture has not been compiled. This message comes from the dummy architecture and won't do anything else !"
		severity failure;

	-- Just to avoid 'vsim-8683' warning in case of this architecture was compiled (instead of the good one)
	-- These warnings appear BEFORE the 'assert' execution and will pollute display
	A_RdData <= (others=>'X');
	A_RdBE   <= (others=>'X');
	B_RdData <= (others=>'X');
	B_RdBE   <= (others=>'X');
end architecture rtl;
--synthesis translate_on
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
library ieee;
use     ieee.std_logic_1164.all;

library work;
use     work.pkg_std.all;
--synthesis translate_off
use     work.pkg_simu.all;
--synthesis translate_on

entity memory is generic
	( A_APS                      : natural range 0 to integer'high        :=  8            -- Address Path Size
	; A_BPS                      : natural range 0 to integer'high        :=  1            -- BE      Path Size
	; A_DPS                      : natural range 0 to integer'high        := 16            -- Data    Path Size
	; A_MODE                     : string                                 := "WO"          -- WO / RO / RW (Write Only / Read Only / Read & Write)
	; A_RD_LAT                   : natural range 1 to 2                   :=  2            -- Read Latency between A_RdReq and A_RdData
	; A_RD_XTRA_REG              : boolean                                := false         -- Add extra register on read bus from memory block. This increases effective A_RD_LAT value
	; B_APS                      : natural range 0 to integer'high        :=  7            -- Address Path Size
	; B_BPS                      : natural range 0 to integer'high        :=  1            -- BE      Path Size
	; B_DPS                      : natural range 0 to integer'high        := 32            -- Data    Path Size
	; B_MODE                     : string                                 := "RO"          -- WO / RO / RW / OPEN (Write Only / Read Only / Read & Write / OPEN)
	; B_RD_LAT                   : natural range 1 to 2                   :=  2            -- Read Latency between B_Rd and B_RdData
	; B_RD_XTRA_REG              : boolean                                := false         -- Add extra register on read bus from memory block. This increases effective B_RD_LAT value
	; USE_BE                     : boolean                                := false         -- Use ByteEnable
	; DEVICE                     : string                                                  -- Target Device
	; RAM_BLOCK_TYPE             : string                                 := "AUTO"        -- M512 / M4K / M9K / M10K / M20K / M144K / MLAB / M-RAM / MEGARAM / LUTRAM / AUTO
	; BYTE_MODE                  : natural range 8 to 9                   :=  8            -- Size for one "byte". If 9, use extra-bit from Memory block
	  --synthesis translate_off                                                            --
	; CHECK_READ                 : boolean                                := true          -- Check read  operations
	; CHECK_WRITE                : boolean                                := true          -- Check write operations
	; MAKE_X                     : boolean                                := false         -- Make conflict when data are not valid
	; VERBOSE                    : boolean                                := false         -- Display debug messages
	  --synthesis translate_on                                                             --
	; INIT_FILE                  : string                                 := "UNUSED"      -- "UNUSED" or filename
	; INIT_FILE_LAYOUT           : string                                 := "UNUSED"      -- Initial content file conforms to port's dimensions A or B ("UNUSED" / "PORT_A" / "PORT_B")
	  -- ECC Status Parameters                                                             --
	; ENABLE_ECC                 : string                                 := "FALSE"       -- ECC / Activate
	; WIDTH_ECCSTATUS            : integer                                :=  3            -- ECC / Status width
	; ECC_PIPELINE_STAGE_ENABLED : string                                 := "FALSE"       -- ECC / Pipelined operations
	); port                                                                                --
	( A_Dmn                      : in  domain                             := DOMAIN_OPEN   -- Clock/reset/clock enable
	; A_Addr                     : in  std_logic_vector(A_APS-1 downto 0) := (others=>'0') -- Address
	; A_Wr                       : in  std_logic                          :=          '0'  -- Write Request
	; A_WrData                   : in  std_logic_vector(A_DPS-1 downto 0) := (others=>'0') -- Write Data
	; A_WrBE                     : in  std_logic_vector(A_BPS-1 downto 0) := (others=>'1') -- Write ByteEnable
	; A_Rd                       : in  std_logic                          :=          '1'  -- Read Request
	; A_RdData                   : out std_logic_vector(A_DPS-1 downto 0)                  -- Read Data
	; A_RdBE                     : out std_logic_vector(A_BPS-1 downto 0)                  -- Read ByteEnable
	; B_Dmn                      : in  domain                             := DOMAIN_OPEN   -- Clock/reset/clock enable
	; B_Addr                     : in  std_logic_vector(B_APS-1 downto 0) := (others=>'0') -- Address
	; B_Wr                       : in  std_logic                          :=          '0'  -- Write Request
	; B_WrData                   : in  std_logic_vector(B_DPS-1 downto 0) := (others=>'0') -- Write Data
	; B_WrBE                     : in  std_logic_vector(B_BPS-1 downto 0) := (others=>'1') -- Write ByteEnable
	; B_Rd                       : in  std_logic                          :=          '1'  -- Read Request
	; B_RdData                   : out std_logic_vector(B_DPS-1 downto 0)                  -- Read Data
	; B_RdBE                     : out std_logic_vector(B_BPS-1 downto 0)                  -- Read ByteEnable
	);
end entity memory;

architecture rtl of memory is
	function Fix_BPS (aps,dps : natural) return natural is
	begin
		if not(USE_BE) then return aps;
		elsif dps/8<1  then return   1;
		else                return dps/8; end if;
	end function Fix_BPS;

	constant        A_BPS_FIXED  : natural                     := Fix_BPS(A_BPS,A_DPS)      ; -- Fix A_BPS (avoid value less than 1)
	constant        B_BPS_FIXED  : natural                     := Fix_BPS(B_BPS,B_DPS)      ; -- Fix B_BPS (avoid value less than 1)
	signal          A_WrBE_fixed : slv(A_BPS_FIXED-1 downto 0)                              ; -- Byte Enable for A side
	signal          B_WrBE_fixed : slv(B_BPS_FIXED-1 downto 0)                              ; -- Byte Enable for B side
	constant        DEVICE_FIXED : string                      := string'(StrUS2Spc(DEVICE)); -- Replace '_' to ' '
begin

A_WrBE_fixed <= Extend0L(A_WrBE,A_WrBE_fixed'length);
B_WrBE_fixed <= Extend0L(B_WrBE,B_WrBE_fixed'length);

mem_empty : if StrEq(DEVICE_FIXED,"EMPTY") generate
begin
	A_RdData <= A_WrData    ;
	A_RdBE   <= A_WrBE_fixed;
	B_RdData <= B_WrData    ;
	B_RdBE   <= B_WrBE_fixed;
end generate mem_empty;

mem_altera : if StrEq(DEVICE_FIXED,"ACEX"        ) or StrEq(DEVICE_FIXED,"APEX20KE"      )
             or StrEq(DEVICE_FIXED,"Arria GX"    )
             or StrEq(DEVICE_FIXED,"Arria II GX" ) or StrEq(DEVICE_FIXED,"Arria II GZ"   )
             or StrEq(DEVICE_FIXED,"Arria 10"    )
             or StrEq(DEVICE_FIXED,"Cyclone"     )
             or StrEq(DEVICE_FIXED,"Cyclone II"  )
             or StrEq(DEVICE_FIXED,"Cyclone III" ) or StrEq(DEVICE_FIXED,"Cyclone III LS")
             or StrEq(DEVICE_FIXED,"Cyclone IV E") or StrEq(DEVICE_FIXED,"Cyclone IV GX" )
             or StrEq(DEVICE_FIXED,"Cyclone V"   )
             or StrEq(DEVICE_FIXED,"HardCopy II" )
             or StrEq(DEVICE_FIXED,"HardCopy III")
             or StrEq(DEVICE_FIXED,"HardCopy IV" )
             or StrEq(DEVICE_FIXED,"MAX 10"      )
             or StrEq(DEVICE_FIXED,"Stratix"     ) or StrEq(DEVICE_FIXED,"Stratix GX"    )
             or StrEq(DEVICE_FIXED,"Stratix II"  ) or StrEq(DEVICE_FIXED,"Stratix II GX" )
             or StrEq(DEVICE_FIXED,"Stratix III" )
             or StrEq(DEVICE_FIXED,"Stratix IV"  )
             or StrEq(DEVICE_FIXED,"Stratix V"   )
             generate
begin
	l : entity work.memory_altera generic map
		( A_APS                      => A_APS                        --natural range 0 to integer'high        :=  8            -- Address Path Size
		, A_BPS                      => A_BPS_FIXED                  --natural range 0 to integer'high        :=  1            -- BE      Path Size
		, A_DPS                      => A_DPS                        --natural range 0 to integer'high        := 16            -- Data    Path Size
		, A_MODE                     => A_MODE                       --string                                 := "WO"          -- WO / RO / RW (Write Only / Read Only / Read & Write)
		, A_RD_LAT                   => A_RD_LAT                     --natural range 1 to 2                   :=  2            -- Read Latency between A_Rd and A_RdData
		, A_RD_XTRA_REG              => false                        --boolean                                := false         -- Add extra register on read bus from memory block. This increases effective A_RD_LAT value
		, B_APS                      => B_APS                        --natural range 0 to integer'high        :=  8            -- Address Path Size
		, B_BPS                      => B_BPS_FIXED                  --natural range 0 to integer'high        :=  1            -- BE      Path Size
		, B_DPS                      => B_DPS                        --natural range 0 to integer'high        := 16            -- Data    Path Size
		, B_MODE                     => B_MODE                       --string                                 := "RO"          -- WO / RO / RW / OPEN (Write Only / Read Only / Read & Write / OPEN)
		, B_RD_LAT                   => B_RD_LAT                     --natural range 1 to 2                   :=  2            -- Read Latency between B_Rd and B_RdData
		, B_RD_XTRA_REG              => false                        --boolean                                := false         -- Add extra register on read bus from memory block. This increases effective B_RD_LAT value
		, DEVICE                     => DEVICE_FIXED                 --string                                                  -- Target Device
		, RAM_BLOCK_TYPE             => RAM_BLOCK_TYPE               --string                                                  -- M512 / M4K / M9K / M10K / M20K / M144K / MLAB / M-RAM / MEGARAM / LUTRAM / AUTO
		, USE_BE                     => USE_BE                       --boolean                                                 -- Use ByteEnable
		, BYTE_MODE                  => BYTE_MODE                    --natural range 8 to 9                   := 8             -- Size for one "byte". If 9, use extra-bit from Memory block
		  --synthesis translate_off                                  --                                                        --
		, VERBOSE                    => VERBOSE                      --boolean                                := false         -- Display debug messages
		  --synthesis translate_on                                   --                                                        --
		, INIT_FILE                  => INIT_FILE                    --string                                 := "UNUSED"      -- "UNUSED" or filename
		, INIT_FILE_LAYOUT           => INIT_FILE_LAYOUT             --string                                 := "UNUSED"      -- Initial content file conforms to port's dimensions A or B ("UNUSED" / "PORT_A" / "PORT_B")
		  -- ECC Status Parameters                                   --                                                        --
		, ENABLE_ECC                 => ENABLE_ECC                   --string                                 := "FALSE"       -- ECC / Activate
		, WIDTH_ECCSTATUS            => WIDTH_ECCSTATUS              --integer                                :=  3            -- ECC / Status width
		, ECC_PIPELINE_STAGE_ENABLED => ECC_PIPELINE_STAGE_ENABLED   --string                                 := "FALSE"       -- ECC / Pipelined operations
		) port map                                                   --                                                        --
		( A_Dmn                      => A_Dmn                        --in  domain                             := DOMAIN_OPEN   -- Clock/reset/clock enable
		, A_Addr                     => A_Addr                       --in  slv(A_APS-1 downto 0)              := (others=>'0') -- Address
		, A_Wr                       => A_Wr                         --in  sl                                 :=          '0'  -- Write Request
		, A_WrData                   => A_WrData                     --in  slv(A_DPS-1 downto 0)              := (others=>'0') -- Write Data
		, A_WrBE                     => A_WrBE_fixed                 --in  slv(A_BPS-1 downto 0)              := (others=>'1') -- Write ByteEnable
		, A_Rd                       => A_Rd                         --in  sl                                 :=          '1'  -- Read Request
		, A_RdData                   => A_RdData                     --out slv(A_DPS-1 downto 0)                               -- Read Data
		, A_RdBE                     => A_RdBE                       --out slv(A_BPS-1 downto 0)                               -- Read ByteEnable
		, B_Dmn                      => B_Dmn                        --in  domain                             := DOMAIN_OPEN   -- Clock/reset/clock enable
		, B_Addr                     => B_Addr                       --in  slv(B_APS-1 downto 0)              := (others=>'0') -- Address
		, B_Wr                       => B_Wr                         --in  sl                                 :=          '0'  -- Write Request
		, B_WrData                   => B_WrData                     --in  slv(B_DPS-1 downto 0)              := (others=>'0') -- Write Data
		, B_WrBE                     => B_WrBE_fixed                 --in  slv(B_BPS-1 downto 0)              := (others=>'1') -- Write ByteEnable
		, B_Rd                       => B_Rd                         --in  sl                                 :=          '1'  -- Read Request
		, B_RdData                   => B_RdData                     --out slv(B_DPS-1 downto 0)                               -- Read Data
		, B_RdBE                     => B_RdBE                       --out slv(B_BPS-1 downto 0)                               -- Read ByteEnable
		);
end generate mem_altera;

mem_xilinx : if StrEq(DEVICE_FIXED,"Spartan 6") or
                StrEq(DEVICE_FIXED,"Virtex 4" ) or
                StrEq(DEVICE_FIXED,"Virtex 5" ) or
                StrEq(DEVICE_FIXED,"Virtex 7" ) generate
begin
	l : entity work.memory_xilinx generic map
		( A_APS            => A_APS                        --natural range 0 to integer'high        :=  8            -- Address Path Size
		, A_BPS            => A_BPS_FIXED                  --natural range 0 to integer'high        :=  1            -- BE      Path Size
		, A_DPS            => A_DPS                        --natural range 0 to integer'high        := 16            -- Data    Path Size
		, A_MODE           => A_MODE                       --string                                 := "WO"          -- WO / RO / RW (Write Only / Read Only / Read & Write)
		, A_RD_LAT         => A_RD_LAT                     --natural range 1 to 2                   :=  2            -- Read Latency between A_Rd and A_RdData
		, A_RD_XTRA_REG    => false                        --boolean                                := false         -- Add extra register on read bus from memory block. This increases effective A_RD_LAT value
		, B_APS            => B_APS                        --natural range 0 to integer'high        :=  8            -- Address Path Size
		, B_BPS            => B_BPS_FIXED                  --natural range 0 to integer'high        :=  1            -- BE      Path Size
		, B_DPS            => B_DPS                        --natural range 0 to integer'high        := 16            -- Data    Path Size
		, B_MODE           => B_MODE                       --string                                 := "RO"          -- WO / RO / RW / OPEN (Write Only / Read Only / Read & Write / OPEN)
		, B_RD_LAT         => B_RD_LAT                     --natural range 1 to 2                   :=  2            -- Read Latency between B_Rd and B_RdData
		, B_RD_XTRA_REG    => false                        --boolean                                := false         -- Add extra register on read bus from memory block. This increases effective B_RD_LAT value
		, DEVICE           => DEVICE_FIXED                 --string                                                  -- Target Device
		, RAM_BLOCK_TYPE   => RAM_BLOCK_TYPE               --string                                                  -- Specify which RAM block type should be used
		, USE_BE           => USE_BE                       --boolean                                                 -- Use ByteEnable
		, BYTE_MODE        => BYTE_MODE                    --natural range 8 to 9                   :=  8            -- Size for one "byte". If 9, use extra-bit from Memory block
		  --synthesis translate_off                        --                                                        --
		, VERBOSE          => VERBOSE                      --boolean                                := false         -- Display debug messages
		  --synthesis translate_on                         --                                                        --
		, INIT_FILE        => INIT_FILE                    --string                                 := "UNUSED"      -- "UNUSED" or filename
		, INIT_FILE_LAYOUT => INIT_FILE_LAYOUT             --string                                 := "UNUSED"      -- Initial content file conforms to port's dimensions A or B ("UNUSED" / "PORT_A" / "PORT_B")
		) port map                                         --                                                        --
		( A_Dmn            => A_Dmn                        --in  domain                             := DOMAIN_OPEN   -- Clock/reset/clock enable
		, A_Addr           => A_Addr                       --in  slv(A_APS  -1 downto 0)            := (others=>'0') -- Address
		, A_Wr             => A_Wr                         --in  sl                                 :=          '0'  -- Write Request
		, A_WrData         => A_WrData                     --in  slv(A_DPS  -1 downto 0)            := (others=>'0') -- Write Data
		, A_WrBE           => A_WrBE_fixed                 --in  slv(A_BPS-1 downto 0)              := (others=>'1') -- Write ByteEnable
		, A_RdData         => A_RdData                     --out slv(A_DPS  -1 downto 0)                             -- Read Data
		, A_RdBE           => A_RdBE                       --out slv(A_DPS/8-1 downto 0)                             -- Read ByteEnable
		, B_Dmn            => B_Dmn                        --in  domain                             := DOMAIN_OPEN   -- Clock/reset/clock enable
		, B_Addr           => B_Addr                       --in  slv(B_APS  -1 downto 0)            := (others=>'0') -- Address
		, B_Wr             => B_Wr                         --in  sl                                 :=          '0'  -- Write Request
		, B_WrData         => B_WrData                     --in  slv(B_DPS  -1 downto 0)            := (others=>'0') -- Write Data
		, B_WrBE           => B_WrBE_fixed                 --in  slv(B_DPS/8-1 downto 0)            := (others=>'1') -- Write ByteEnable
		, B_RdData         => B_RdData                     --out slv(B_DPS  -1 downto 0)                             -- Read Data
		, B_RdBE           => B_RdBE                       --out slv(B_DPS/8-1 downto 0)                             -- Read ByteEnable
		);
end generate mem_xilinx;

checker : block is
	--synthesis translate_off
	signal          A_Rd_s : slv3; -- Delay line for read request on A port
	signal          B_Rd_s : slv3; -- Delay line for read request on B port
	--synthesis translate_on
begin
	--synthesis translate_off
	proc_a : process(A_Dmn)
	begin
	if A_Dmn.rst='1' then
		A_Rd_s <= (others=>'0');
	elsif rising_edge(A_Dmn.clk) then
		A_Rd_s <= ExcludeLSB(A_Rd_s) & A_Rd;
	end if;
	end process proc_a;

	proc_b : process(B_Dmn)
	begin
	if B_Dmn.rst='1' then
		B_Rd_s <= (others=>'0');
	elsif rising_edge(B_Dmn.clk) then
		B_Rd_s <= ExcludeLSB(B_Rd_s) & B_Rd;
	end if;
	end process proc_b;

	A_RdData <= (others=>'Z') when not(MAKE_X)                                           else
	            (others=>'X') when (A_RD_LAT=1 and not(A_RD_XTRA_REG) and A_Rd_s(0)='0') or
	                               (A_RD_LAT=1 and     A_RD_XTRA_REG  and A_Rd_s(1)='0') or
	                               (A_RD_LAT=2 and not(A_RD_XTRA_REG) and A_Rd_s(1)='0') or
	                               (A_RD_LAT=2 and     A_RD_XTRA_REG  and A_Rd_s(2)='0') else
	            (others=>'Z');

	B_RdData <= (others=>'Z') when not(MAKE_X)                                           else
	            (others=>'X') when (B_RD_LAT=1 and not(B_RD_XTRA_REG) and B_Rd_s(0)='0') or
	                               (B_RD_LAT=1 and     B_RD_XTRA_REG  and B_Rd_s(1)='0') or
	                               (B_RD_LAT=2 and not(B_RD_XTRA_REG) and B_Rd_s(1)='0') or
	                               (B_RD_LAT=2 and     B_RD_XTRA_REG  and B_Rd_s(2)='0') else
	            (others=>'Z');
	--synthesis translate_on

	--------------------------------------------------------------------------------------------------------------------
	-- Synthesis & Simulation
	--------------------------------------------------------------------------------------------------------------------
	-- Check that requested device is supported
	assert StrEq(DEVICE_FIXED,"EMPTY"       )
	    or StrEq(DEVICE_FIXED,"ACEX"        ) or StrEq(DEVICE_FIXED,"APEX20KE"      )
	    or StrEq(DEVICE_FIXED,"Arria GX"    )
	    or StrEq(DEVICE_FIXED,"Arria II GX" ) or StrEq(DEVICE_FIXED,"Arria II GZ"   )
	    or StrEq(DEVICE_FIXED,"Arria 10"    )
	    or StrEq(DEVICE_FIXED,"Cyclone"     )
	    or StrEq(DEVICE_FIXED,"Cyclone II"  )
	    or StrEq(DEVICE_FIXED,"Cyclone III" ) or StrEq(DEVICE_FIXED,"Cyclone III LS")
	    or StrEq(DEVICE_FIXED,"Cyclone IV E") or StrEq(DEVICE_FIXED,"Cyclone IV GX" )
	    or StrEq(DEVICE_FIXED,"Cyclone V"   )
	    or StrEq(DEVICE_FIXED,"HardCopy II" )
	    or StrEq(DEVICE_FIXED,"HardCopy III")
	    or StrEq(DEVICE_FIXED,"HardCopy IV" )
	    or StrEq(DEVICE_FIXED,"MAX 10"      )
	    or StrEq(DEVICE_FIXED,"Stratix"     ) or StrEq(DEVICE_FIXED,"Stratix GX"    )
	    or StrEq(DEVICE_FIXED,"Stratix II"  ) or StrEq(DEVICE_FIXED,"Stratix II GX" )
	    or StrEq(DEVICE_FIXED,"Stratix III" )
	    or StrEq(DEVICE_FIXED,"Stratix IV"  )
	    or StrEq(DEVICE_FIXED,"Stratix V"   )
	    or StrEq(DEVICE_FIXED,"Spartan 6"   )
	    or StrEq(DEVICE_FIXED,"Virtex 4"    )
	    or StrEq(DEVICE_FIXED,"Virtex 5"    )
	    or StrEq(DEVICE_FIXED,"Virtex 7"    )
	    report "[memory] : DEVICE '" & DEVICE_FIXED & "' not handled !! List of supported devices is ACEX / APEX20KE / Arria GX / Arria II GX / Arria II GZ / Cyclone / Cyclone II / Cyclone III / Cyclone III LS / Cyclone IV E / Cyclone IV GX / HardCopy II / HardCopy III / HardCopy IV / Spartan 6 / Stratix / Stratix GX / Stratix II / Stratix II GX / Stratix III / Stratix IV / Stratix V / Virtex 4 / Virtex 5"
	    severity failure;

	-- Check memory block type
	--                                           -- +-+---+---+---+---+---+---+-+---+---+---+---+---+---+---+-+---+-+---+---+---+-+---+---+---+---+---+---+---+-+---+-+---+
	--                                           -- |*| A | A | A | A | A | A |*| C | C | C | C | C | C | C |*| M |*| H | H | H |*| S | S | S | S | S | S | S |*| S |*| V |
	--                                           -- |*| r | r | r | r | r | r |*| y | y | y | y | y | y | y |*| A |*| a | a | a |*| t | t | t | t | t | t | t |*| p |*| i |
	--                                           -- |*| r | r | r | r | r | r |*| c | c | c | c | c | c | c |*| X |*| r | r | r |*| r | r | r | r | r | r | r |*| a |*| r |
	--                                           -- |*| i | i | i | i | i | i |*| l | l | l | l | l | l | l |*|   |*| d | d | d |*| a | a | a | a | a | a | a |*| r |*| t |
	--                                           -- |*| a | a | a | a | a | a |*| o | o | o | o | o | o | o |*| 1 |*| C | C | C |*| t | t | t | t | t | t | t |*| t |*| e |
	--                                           -- |*|   |   |   |   |   |   |*| n | n | n | n | n | n | n |*| 0 |*| o | o | o |*| i | i | i | i | i | i | i |*| a |*| x |
	--                                           -- |*| G | I | I | V | V | 1 |*| e | e | e | e | e | e | e |*|   |*| p | p | p |*| x | x | x | x | x | x | x |*| n |*|   |
	--                                           -- |*| X | I | I |   |   | 0 |*|   |   |   |   |   |   |   |*|   |*| y | y | y |*|   |   |   |   |   |   |   |*|   |*| 7 |
	--                                           -- |*|   |   |   |   | G |   |*|   | I | I | I | I | I | V |*|   |*|   |   |   |*|   | G | I | I | I | I | V |*| 6 |*|   |
	--                                           -- |*|   | G | G |   | Z |   |*|   | I | I | I | V | V |   |*|   |*| I | I | I |*|   | X | I | I | I | V |   |*|   |*|   |
	--                                           -- |*|   | X | Z |   |   |   |*|   |   | I | I |   |   |   |*|   |*| I | I | V |*|   |   |   |   | I |   |   |*|   |*|   |
	--                                           -- |*|   |   |   |   |   |   |*|   |   |   |   | E | G |   |*|   |*|   | I |   |*|   |   |   | G |   |   |   |*|   |*|   |
	--                                           -- |*|   |   |   |   |   |   |*|   |   |   | L |   | X |   |*|   |*|   |   |   |*|   |   |   | X |   |   |   |*|   |*|   |
	--                                           -- |*|   |   |   |   |   |   |*|   |   |   | S |   |   |   |*|   |*|   |   |   |*|   |   |   |   |   |   |   |*|   |*|   |
	--                                           -- +-+---+---+---+---+---+---+-+---+---+---+---+---+---+---+-+---+-+---+---+---+-+---+---+---+---+---+---+---+-+---+-+---+
	assert StrEq(RAM_BLOCK_TYPE,"LUTRAM"    ) or -- |*|   |   |   |   |   |   |*|   |   |   |   |   |   |   |*|   |*|   |   |   |*|   |   |   |   |   |   |   |*|   |*|   |
	       StrEq(RAM_BLOCK_TYPE,"MLAB"      ) or -- |*|   | X | X | X | X | X |*|   |   |   |   |   |   | X |*|   |*|   |   |   |*|   |   |   |   |   | X | X |*|   |*|   |
	       StrEq(RAM_BLOCK_TYPE,"M512"      ) or -- |*|   |   |   |   |   |   |*|   |   |   |   |   |   |   |*|   |*|   |   |   |*|   |   |   |   |   |   |   |*|   |*|   |
	       StrEq(RAM_BLOCK_TYPE,"M4K"       ) or -- |*|   |   |   |   |   |   |*|   |   |   |   |   |   |   |*|   |*|   |   |   |*|   |   |   |   |   |   |   |*|   |*|   |
	       StrEq(RAM_BLOCK_TYPE,"M9K"       ) or -- |*|   | X | X |   |   |   |*|   |   |   |   | X | X |   |*| X |*|   |   |   |*|   |   |   |   |   | X |   |*|   |*|   |
	       StrEq(RAM_BLOCK_TYPE,"M10K"      ) or -- |*|   |   |   | X |   |   |*|   |   |   |   |   |   | X |*|   |*|   |   |   |*|   |   |   |   |   |   |   |*|   |*|   |
	       StrEq(RAM_BLOCK_TYPE,"M20K"      ) or -- |*|   |   |   |   | X | X |*|   |   |   |   |   |   |   |*|   |*|   |   |   |*|   |   |   |   |   |   | X |*|   |*|   |
	       StrEq(RAM_BLOCK_TYPE,"M144K"     ) or -- |*|   |   | X |   |   |   |*|   |   |   |   |   |   |   |*|   |*|   |   |   |*|   |   |   |   |   | X |   |*|   |*|   |
	       StrEq(RAM_BLOCK_TYPE,"M-RAM"     ) or -- |*|   |   |   |   |   |   |*|   |   |   |   |   |   |   |*|   |*|   |   |   |*|   |   |   |   |   |   |   |*|   |*|   |
	       StrEq(RAM_BLOCK_TYPE,"MEGARAM"   ) or -- |*|   |   |   |   |   |   |*|   |   |   |   |   |   |   |*|   |*|   |   |   |*|   |   |   |   |   |   |   |*|   |*|   |
	       StrEq(RAM_BLOCK_TYPE,"RAMB8BWER" ) or -- |*|   |   |   |   |   |   |*|   |   |   |   |   |   |   |*|   |*|   |   |   |*|   |   |   |   |   |   |   |*| X |*|   |
	       StrEq(RAM_BLOCK_TYPE,"RAMB16BWER") or -- |*|   |   |   |   |   |   |*|   |   |   |   |   |   |   |*|   |*|   |   |   |*|   |   |   |   |   |   |   |*| X |*|   |
	       StrEq(RAM_BLOCK_TYPE,"RAMB18E1"  ) or -- |*|   |   |   |   |   |   |*|   |   |   |   |   |   |   |*|   |*|   |   |   |*|   |   |   |   |   |   |   |*|   |*| X |
	       StrEq(RAM_BLOCK_TYPE,"RAMB36E1"  ) or -- |*|   |   |   |   |   |   |*|   |   |   |   |   |   |   |*|   |*|   |   |   |*|   |   |   |   |   |   |   |*|   |*| X |
	       StrEq(RAM_BLOCK_TYPE,"AUTO" )         -- +-+---+---+---+---+---+---+-+---+---+---+---+---+---+---+-+---+-+---+---+---+-+---+---+---+---+---+---+---+-+---+-+---+
		report "[memory] : RAM_BLOCK_TYPE not supported !!"
		severity failure;

	-- Check memory block exists for required target
	assert not(StrEq(DEVICE_FIXED,"Cyclone"   )) or StrEq(RAM_BLOCK_TYPE,"M4K" ) or StrEq(RAM_BLOCK_TYPE,"AUTO")                                                                  report "[memory] : Cyclone"    & " family supports only M4K"             & " memory blocks !!" severity failure;
	assert not(StrEq(DEVICE_FIXED,"Cyclone II")) or StrEq(RAM_BLOCK_TYPE,"M4K" ) or StrEq(RAM_BLOCK_TYPE,"AUTO")                                                                  report "[memory] : Cyclone II" & " family supports only M4K"             & " memory blocks !!" severity failure;
	assert not(StrEq(DEVICE_FIXED,"Arria 10"  )) or StrEq(RAM_BLOCK_TYPE,"MLAB") or StrEq(RAM_BLOCK_TYPE,"M20K") or StrEq(RAM_BLOCK_TYPE,"M144K") or StrEq(RAM_BLOCK_TYPE,"AUTO") report "[memory] : Arria 10"   & " family supports only MLAB/M20K/M144K" & " memory blocks !!" severity failure;

	-- Check device compatibility with port resizing
	assert not(A_DPS/=B_DPS and (StrEq(DEVICE_FIXED,"APEX20KE") or StrEq(DEVICE_FIXED,"ACEX")))
		report "[memory] : APEX device doesn't support different data path sizes !!"
		severity failure;

	-- Check ByteEnable size // DataPath size coherency
	assert not(USE_BE and A_DPS>=8 and A_BPS/=A_DPS/8) report "[memory] : Please check A_BPS versus A_DPS !!"                               severity failure;
	assert not(USE_BE and B_DPS>=8 and B_BPS/=B_DPS/8) report "[memory] : Please check B_BPS versus B_DPS !!"                               severity failure;

	-- Check static directionality
	assert not(A_MODE="RO" and B_MODE="RO") report "[memory] : There is no Write port !!"                                                   severity failure;
	assert not(A_MODE="WO" and B_MODE="WO") report "[memory] : There is no Read port !!"                                                    severity failure;
	assert not(A_MODE="RW" and B_MODE="RO") report "[memory] : A cannot be bidirectionnal and B only for Read !!"                           severity failure;
	assert not(A_MODE="RW" and B_MODE="WO") report "[memory] : A cannot be bidirectionnal and B only for Write !!"                          severity failure;
	assert not(A_MODE="WO" and B_MODE="RW") report "[memory] : B cannot be bidirectionnal and A only for Write !!"                          severity failure;
	assert not(A_MODE="RO" and B_MODE="RW") report "[memory] : B cannot be bidirectionnal and A only for Read !!"                           severity failure;
	assert not(A_MODE="RO" and B_MODE="WO") report "[memory] : Altsyncram cannot transmit data in 'Simple dual port' from B port to A port" severity failure;

	-- ECC Is available only for some ALTERA devices
	assert StrEq(ENABLE_ECC  ,"FALSE"    )
	    or StrEq(DEVICE_FIXED,"Stratix V")
	    or StrEq(DEVICE_FIXED,"Arria 10" )
		report "[memory] : 'ENABLE_ECC' is not available for '" & DEVICE_FIXED & "' device"
		severity failure;

	assert StrEq(ECC_PIPELINE_STAGE_ENABLED,"FALSE"    )
	    or StrEq(DEVICE_FIXED              ,"Stratix V")
	    or StrEq(DEVICE_FIXED              ,"Arria 10" )
		report "[memory] : 'ECC_PIPELINE_STAGE_ENABLED' is not available for '" & DEVICE_FIXED & "' device"
		severity failure;

end block checker;

--synthesis translate_off
check_read_validity : if CHECK_READ generate
begin
	process(A_Dmn)
	begin
	if A_Dmn.rst='1' or A_Dmn.ena='0' then
	elsif rising_edge(A_Dmn.clk) then
		if A_Rd='1' and Is_X(A_Addr) then printf(failure,"[memory] : Illegal A_Addr " & "during read operation !!"); end if;
		if not(Is_01(A_Rd))          then printf(failure,"[memory] : Illegal A_Rd "   & "state !!"                ); end if;
	end if;
	end process;

	process(B_Dmn)
	begin
	if B_Dmn.rst='1' or B_Dmn.ena='0' then
	elsif rising_edge(B_Dmn.clk) then
		if B_Rd='1' and Is_X(B_Addr) then printf(failure,"[memory] : Illegal B_Addr " & "during read operation !!"); end if;
		if not(Is_01(B_Rd))          then printf(failure,"[memory] : Illegal B_Rd "   & "state !!"                ); end if;
	end if;
	end process;
end generate check_read_validity;
--synthesis translate_on

--synthesis translate_off
check_write_validity : if CHECK_WRITE generate
begin
	process(A_Dmn)
	begin
	if A_Dmn.rst='1' or A_Dmn.ena='0' then
	elsif rising_edge(A_Dmn.clk) then
		if A_Wr='1' and Is_X(A_Addr  ) then printf(failure,"[memory] : Illegal A_Addr "   & "during write operation !!"); end if;
		if A_Wr='1' and Is_X(A_WrData) then printf(failure,"[memory] : Illegal A_WrData " & "during write operation !!"); end if;
		if A_Wr='1' and Is_X(A_WrBE  ) then printf(failure,"[memory] : Illegal A_WrBE "   & "during write operation !!"); end if;
		if not(Is_01(A_Wr))            then printf(failure,"[memory] : Illegal A_Wr "     & "state !!"                 ); end if;
	end if;
	end process;

	process(B_Dmn)
	begin
	if B_Dmn.rst='1' or B_Dmn.ena='0' then
	elsif rising_edge(B_Dmn.clk) then
		if B_Wr='1' and Is_X(B_Addr  ) then printf(failure,"[memory] : Illegal B_Addr "   & "during write operation !!"); end if;
		if B_Wr='1' and Is_X(B_WrData) then printf(failure,"[memory] : Illegal B_WrData " & "during write operation !!"); end if;
		if B_Wr='1' and Is_X(B_WrBE  ) then printf(failure,"[memory] : Illegal B_WrBE "   & "during write operation !!"); end if;
		if not(Is_01(B_Wr))            then printf(failure,"[memory] : Illegal B_Wr "     & "state !!"                 ); end if;
	end if;
	end process;
end generate check_write_validity;
--synthesis translate_on

end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
