/*--------------------------------------------------------------------------------------------------------------------------------------------------------------
Author      : Jean-Louis FLOQUET
Title       : ALTERA Memory Block
File        : memory_altera.vhd
Application : RTL & Simulation
Created     : 2004, March 8th
Last update : 2015/03/12 14:33
Version     : 4.03.02
Dependency  : pkg_std
----------------------------------------------------------------------------------------------------------------------------------------------------------------
 Description : ALTERA memory block (choose the good one depending of the device and others parameters)
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  Rev.   |    Date    | Description
 4.03.01 | 2015/03/11 | 1) New : Support for Arria 10 devices
         | 2015/03/12 | 2) New : Support for MAX 10 devices
 4.02.01 | 2014/07/23 | 1) New : Support for Cyclone V devices
 4.01.08 | 2013/09/23 | 1) Enh : Low-level configuration for DUAL_PORT vs BIDIR_DUAL_PORT
         | 2013/09/25 | 2) Enh : Low-level configuration for ROM
         |            | 3) Chg : VHDL-2008 required
         | 2013/11/14 | 4) Chg : (Minor) component declaration
         | 2014/01/28 | 5) Fix : Undriven output signals for some configurations
         | 2014/01/30 | 6) Chg : Removed unnecessary generic/port for "simple" dual port
         | 2014/03/18 | 7) Chg : Record 'domain'
         | 2014/04/01 | 8) Fix : 4.01.06 had removed READ_DURING_WRITE_MODE_MIXED_PORTS
 4.00.02 | 2012/08/14 | 1) New : Support for ECC
         |            | 2) Fix : READ_DURING_WRITE_MODE_MIXED_PORTS
 3.02.01 | 2012/02/27 | 1) New : Support for Arria, Arria II GX/GZ, Cyclone III (all) /IV (all), Hardcopy II/III/IV, Stratix GX/II GX/V
 3.01.01 | 2012/02/03 | 1) Fix : READ_DURING_WRITE_MODE_MIXED_PORTS changed to "DONT_CARE"
 3.00.01 | 2012/01/08 | 1) New : Asynchronous reset for each side
 2.06.01 | 2011/12/16 | 1) New : Add read enable commands
 2.05.01 | 2011/03/07 | 1) Fix : RD_LAT only support 1 and 2 value (0 is not allowed)
 2.04.01 | 2009/09/01 | 1) New : Support for Stratix IV devices
 2.03.01 | 2009/02/12 | 1) Fix : A dummy crazy bug using BPS instead of DPS
 2.02.04 | 2008/11/19 | 2) Fix : memory_altera for different RAM_BLOCK_TYPE versus DEVICE
         |            | 3) Fix : VERBOSE generic hidden for synthesis
         | 2008/12/17 | 4) Enh : Option for extra register on read data path. See [Note 3]. Several bug fixed 2009/01/10
 2.01.02 | 2008/06/09 | 1) Fix : AltSyncRam read port are connected only if required (avoid fitter error)
 2.00.01 | 2008/01/30 | 1) Chg : Solved a big headache when Altera's or Xilinx's part not compiled
         |            |          memory_altera and memory_xilinx files don't contain anymore entity that moved to this file.
 1.06.03 | 2007/10/11 | 1) New : Clock enable
         |            | 2) New : Support for "Stratix III" and "Cyclone III" devices
         |            | 3) Fix : Memory instanciation with clock enable
 1.05.03 | 2007/01/25 | 1) New : ByteEnable for datapath support
         |            | 2) Fix : A=ReadOnly and B=WriteOnly is not possible for AltSyncRam
         |            | 3) New : Support for Cyclone & Stratix II devices
 1.04.01 | 2006/07/04 | 1) New : Support for same clock on both sides (CLOCK_MODE)
 1.03.04 | 2006/03/08 | 1) New : Cyclone II device family support
         |            | 2) Fix : Error condition for different data path on APEX/ACEX family
         |            | 3) Enh : use only A_DPS for APEX/ACEX family
         |            | 4) Chg : DEVICE values changed to "official" from ALTERA
 1.02.02 | 2006/02/22 | 1) Fix : Error message for different DPS on Apex & Acex technologies
         | 2006/02/24 | 2) New : Bidirectionnal buffer. "Wr" & "Rd" renamed to "A" and "B".
 1.01.03 | 2005/05/20 | 1) New : Support for Stratix family
         | 2005/09/15 | 2) New : Support unregistered memory on Stratix
         | 2005/10/06 | 3) New : Different APS & DPS for both sides
 1.00.00 | 2004/03/08 | Initial release
         |            |
----------------------------------------------------------------------------------------------------------------------------------------------------------------
¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
                                                                             Notes
¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
[Note 1] : Official documentation
    +-----
    | http://www.altera.com/literature/ug/ug_ram_rom.pdf
    +-----

[Note 2] : ALTERA M4K memory block
    +-----
    | Memory block is optimized in order to minimize the number of physical M4K required.
    | This block supports M4K with 16bits wide for write operation and 32bits wide for read operations. This special is only possible with Single Dual
    | Port memory block, as it is done with ALTERA MegaWizard.
    +-----

[Note 3] : ALTERA Stratix IV TriMatrix Embedded Memory blocks
    +-----
    | Feature                           MLABs                        M9K Blocks                       M144K Blocks
    | Maximum performance               600 MHz                      600 MHz                          600 MHz
    | Total RAM bits                    640                          9216                             147.456
    |    (including parity bits)
    | Configurations                    64×8                         8K×1                             16K×8
    |    (depth × width)                64×9                         4K×2                             16K×9
    |                                   64×10                        2K×4                             8K×16
    |                                   32×16                        1K×8                             8K×18
    |                                   32×18                        1K×9                             4K×32
    |                                   32×20                        512×16                           4K×36
    |                                                                512×18                           2K×64
    |                                                                256×32                           2K×72
    |                                                                256×36
    | Parity bits                       v                            v                                v
    | Byte enable                       v                            v                                v
    | Packed mode                       -                            v                                v
    | Address clock enable              v                            v                                v
    | Single-port memory                v                            v                                v
    | Simple dual-port memory           v                            v                                v
    | True dual-port memory             -                            v                                v
    | Embedded shift register           v                            v                                v
    | ROM                               v                            v                                v
    | FIFO buffer                       v                            v                                v
    | Simple dual-port mixed            -                            v                                v
    |  width support
    | True dual-port mixed              -                            v                                v
    |  width support
    | Memory Initialization File        v                            v                                v
    | Mixed-clock mode                  v                            v                                v
    | Power-up condition                Outputs cleared if           Outputs cleared                  Outputs cleared
    |                                   registered, otherwise
    |                                   reads memory contents
    | Register clears                   Output registers             Output registers                 Output registers
    | Write/Read operation triggering   Write: Falling clock edges   Write/Read: Rising clock edges   Write/Read: Rising clock edges
    |                                   Read: Rising clock edges
    | Same-port read-during-write       Outputs set to don’t care    Outputs set to old               Outputs set to old
    |                                                                data or new data.                data or new data
    | Mixed-port read-during-write      Outputs set to old           Outputs set to old               Outputs set to old
    |                                   data or don’t care           data or don’t care               data or don’t care
    | ECC Support                       Soft IP support              Soft IP support                  Built-in support in ×64 wide SDP mode or
    |                                   using Quartus II             using Quartus II                 soft IP support using Quartus II software
    +-----

    +-----
    | Device              MLABs        M9K        M144K Blocks   Total Dedicated RAM Bits         Total RAM Bits
    |                                  Blocks     Blocks         (dedicated memory blocks only)   (including MLABs)
    | EP4SE110             2.112         660       16              8.244 Kb                         9.564 Kb
    | EP4SE230             4.560       1.235       22             14.283 Kb                        17.133 Kb
    | EP4SE290             5.824         936       36             13.608 Kb                        17.248 Kb
    | EP4SE360             7.072       1.248       48             18.144 Kb                        22.564 Kb
    | EP4SE530            10.624       1.280       64             20.736 Kb                        27.376 Kb
    | EP4SE680            13.622       1.529       64             22.977 Kb                        31.491 Kb
    | EP4SGX70             1.452         462       16              6.462 Kb                         7.370 Kb
    | EP4SGX110            2.112         660       16              8.244 Kb                         9.564 Kb
    | EP4SGX180            3.515         950       20             11.430 Kb                        13.627 Kb
    | EP4SGX230            4.560       1.235       22             14.283 Kb                        17.133 Kb
    | EP4SGX290            5.824         936       36             13.608 Kb                        17.248 Kb
    | EP4SGX360            7.072       1.248       48             18.144 Kb                        22.564 Kb
    | EP4SGX530           10.624       1.280       64             20.736 Kb                        27.376 Kb
    +-----
--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- Turn off superfluous VHDL processor warnings
-- xxx_altera message_level xxx_Level1
-- altera message_off 10036
--
-- List of masked warnings
-- 10036 : Verilog HDL or VHDL warning at <location>: object "name" assigned a value but never read
----------------------------------------------------------------------------------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;

library altera_mf;
use     altera_mf.altera_mf_components.all;

library work;
use     work.pkg_std.all;
/*
entity memory_altera is generic
	( A_APS                      : natural range 0 to integer'high        :=  8            -- Address Path Size
	; A_BPS                      : natural range 0 to integer'high        :=  1            -- BE      Path Size
	; A_DPS                      : natural range 0 to integer'high        := 16            -- Data    Path Size
	; A_MODE                     : string                                 := "WO"          -- WO / RO / RW (Write Only / Read Only / Read & Write)
	; A_RD_LAT                   : natural range 1 to 2                   :=  2            -- Read Latency between A_Rd and A_RdData
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
	; ENABLE_ECC                 : string                                 := "FALSE"       --
	; WIDTH_ECCSTATUS            : integer                                :=  3            --
	; ECC_PIPELINE_STAGE_ENABLED : string                                 := "FALSE"       --
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
*/
architecture rtl of memory_altera is
	--*********************************************************************************************
	-- Function creating generic values for ALTDPRAM
	--*********************************************************************************************
	function OutDataReg(latency : integer) return string is
	begin
		if latency=2 then return "OUTCLOCK";
		else              return "UNREGISTERED"; end if;
	end function OutDataReg;
	--*********************************************************************************************
	-- Functions creating generic values for ALTSYNCRAM
	--*********************************************************************************************
	-- Auto configure memory block depending on A/B usage. (Because M512 doesn't support
	-- "BIDIR_DUAL_PORT", memory block cannot always be configured with this value).
	function OperationMode(mode_a, mode_b : string) return string is
	begin
		   if mode_a="RW" and mode_b="RW"   then return "BIDIR_DUAL_PORT";         -- True Dual Port
		elsif mode_a="RO" and mode_b="OPEN" then return             "ROM";         --            ROM
		else                                     return       "DUAL_PORT"; end if; --      Dual Port
	end function OperationMode;

	-- Registered/Unregistered read data port
	function OutDataRegA(latency : integer) return string is begin if latency=2 then return "CLOCK0"; else return "UNREGISTERED"; end if; end function OutDataRegA;
	function OutDataRegB(latency : integer) return string is begin if latency=2 then return "CLOCK1"; else return "UNREGISTERED"; end if; end function OutDataRegB;

	-- Return Memory data path value, according to user data path and ByteEnable (used or unused)
	function DPSandBE(dps:natural;be:boolean) return natural is
	begin
		if be then return dps*9/8;         -- add ByteEnables inside data path
		else       return dps    ; end if; -- only user's data path
	end function DPSandBE;
	--*********************************************************************************************
	-- RAM Block Type management
	--*********************************************************************************************
	-- Depending of the selected target device, some RAM block may not be available.
	function RamBlockType return string is
		variable illegal_choice : boolean := false; -- Detect an illegal/incompatible choice
	begin
		   if DEVICE="Arria GX"       then    if RAM_BLOCK_TYPE="M512"  then return "M512" ;
		                                   elsif RAM_BLOCK_TYPE="M4K"   then return "M4K"  ;
		                                   elsif RAM_BLOCK_TYPE="M-RAM" then return "M-RAM";
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="Arria II GX"    then    if RAM_BLOCK_TYPE="MLAB"  then return "MLAB" ;
		                                   elsif RAM_BLOCK_TYPE="M9K"   then return "M9K"  ;
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="Arria II GZ"    then    if RAM_BLOCK_TYPE="MLAB"  then return "MLAB" ;
		                                   elsif RAM_BLOCK_TYPE="M9K"   then return "M9K"  ;
		                                   elsif RAM_BLOCK_TYPE="M144K" then return "M144K";
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="Arria 10"       then    if RAM_BLOCK_TYPE="MLAB"  then return "MLAB" ;
		                                   elsif RAM_BLOCK_TYPE="M20K"  then return "M20K" ;
		                                   elsif RAM_BLOCK_TYPE="M144K" then return "M144K";
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="Cyclone"        then    if RAM_BLOCK_TYPE="M4K"   then return "M4K"  ;
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="Cyclone II"     then    if RAM_BLOCK_TYPE="M4K"   then return "M4K"  ;
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="Cyclone III"    then    if RAM_BLOCK_TYPE="M9K"   then return "M9K"  ;
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="Cyclone III LS" then    if RAM_BLOCK_TYPE="M9K"   then return "M9K"  ;
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="Cyclone IV E"   then    if RAM_BLOCK_TYPE="M9K"   then return "M9K"  ;
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="Cyclone IV GX"  then    if RAM_BLOCK_TYPE="M9K"   then return "M9K"  ;
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="Cyclone V"      then    if RAM_BLOCK_TYPE="M10K"  then return "M10K" ;
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="HardCopy II"    then    if RAM_BLOCK_TYPE="M4K"   then return "M4K"  ;
		                                   elsif RAM_BLOCK_TYPE="M-RAM" then return "M-RAM";
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="HardCopy III"   then    if RAM_BLOCK_TYPE="MLAB"  then return "MLAB" ;
		                                   elsif RAM_BLOCK_TYPE="M9K"   then return "M9K"  ;
		                                   elsif RAM_BLOCK_TYPE="M144K" then return "M144K";
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="HardCopy IV"    then    if RAM_BLOCK_TYPE="MLAB"  then return "MLAB" ;
		                                   elsif RAM_BLOCK_TYPE="M9K"   then return "M9K"  ;
		                                   elsif RAM_BLOCK_TYPE="M144K" then return "M144K";
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="MAX 10"         then    if RAM_BLOCK_TYPE="M9K"   then return "M9K"  ;
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="Stratix"        then    if RAM_BLOCK_TYPE="M512"  then return "M512" ;
		                                   elsif RAM_BLOCK_TYPE="M4K"   then return "M4K"  ;
		                                   elsif RAM_BLOCK_TYPE="M-RAM" then return "M-RAM";
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="Stratix GX"     then    if RAM_BLOCK_TYPE="M512"  then return "M512" ;
		                                   elsif RAM_BLOCK_TYPE="M4K"   then return "M4K"  ;
		                                   elsif RAM_BLOCK_TYPE="M-RAM" then return "M-RAM";
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="Stratix II"     then    if RAM_BLOCK_TYPE="M512"  then return "M512" ;
		                                   elsif RAM_BLOCK_TYPE="M4K"   then return "M4K"  ;
		                                   elsif RAM_BLOCK_TYPE="M-RAM" then return "M-RAM";
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="Stratix II GX"  then    if RAM_BLOCK_TYPE="M512"  then return "M512" ;
		                                   elsif RAM_BLOCK_TYPE="M4K"   then return "M4K"  ;
		                                   elsif RAM_BLOCK_TYPE="M-RAM" then return "M-RAM";
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="Stratix III"    then    if RAM_BLOCK_TYPE="MLAB"  then return "MLAB" ;
		                                   elsif RAM_BLOCK_TYPE="M9K"   then return "M9K"  ;
		                                   elsif RAM_BLOCK_TYPE="M144K" then return "M144K";
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="Stratix IV"     then    if RAM_BLOCK_TYPE="MLAB"  then return "MLAB" ;
		                                   elsif RAM_BLOCK_TYPE="M9K"   then return "M9K"  ;
		                                   elsif RAM_BLOCK_TYPE="M144K" then return "M144K";
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;

		elsif DEVICE="Stratix V"      then    if RAM_BLOCK_TYPE="MLAB"  then return "MLAB" ;
		                                   elsif RAM_BLOCK_TYPE="M20K"  then return "M20K" ;
		                                   elsif RAM_BLOCK_TYPE="AUTO"  then return "AUTO" ;
		                                   else illegal_choice := true;                      end if;
		end if;

		assert not(illegal_choice)
			report "[memory_altera] : Unsupported RAM_BLOCK_TYPE=" & RAM_BLOCK_TYPE & " for device='" & DEVICE & "'"
			severity failure;

		return "AUTO";
	end function RamBlockType;
	--*********************************************************************************************
	-- Read During Write Mode Mixed Ports
	function ReadDuringWriteModeMixedPorts return string is
	begin
		   if DEVICE="Arria GX"       then return "OLD_DATA" ;
		elsif DEVICE="Arria II GX"    then return "OLD_DATA" ;
		elsif DEVICE="Arria II GZ"    then return "OLD_DATA" ;
		elsif DEVICE="Arria 10"       then return "DONT_CARE";
		elsif DEVICE="Cyclone"        then return "OLD_DATA" ;
		elsif DEVICE="Cyclone II"     then return "OLD_DATA" ;
		elsif DEVICE="Cyclone III"    then return "OLD_DATA" ;
		elsif DEVICE="Cyclone III LS" then return "OLD_DATA" ;
		elsif DEVICE="Cyclone IV E"   then return "DONT_CARE";
		elsif DEVICE="Cyclone IV GX"  then return "DONT_CARE";
		elsif DEVICE="Cyclone V"      then return "DONT_CARE";
		elsif DEVICE="HardCopy II"    then return "OLD_DATA" ;
		elsif DEVICE="HardCopy III"   then return "OLD_DATA" ;
		elsif DEVICE="HardCopy IV"    then return "OLD_DATA" ;
		elsif DEVICE="MAX 10"         then return "DONT_CARE";
		elsif DEVICE="Stratix"        then return "DONT_CARE"; -- M-RAM doesn't support "OLD_DATA"
		elsif DEVICE="Stratix GX"     then return "OLD_DATA" ;
		elsif DEVICE="Stratix II"     then return "DONT_CARE"; -- M-RAM doesn't support "OLD_DATA"
		elsif DEVICE="Stratix II GX"  then return "OLD_DATA" ;
		elsif DEVICE="Stratix III"    then return "DONT_CARE"; -- MLAB doesn't fully support "OLD_DATA"
		elsif DEVICE="Stratix IV"     then return "DONT_CARE"; -- MLAB doesn't fully support "OLD_DATA"
		elsif DEVICE="Stratix V"      then return "DONT_CARE"; -- MLAB doesn't fully support "OLD_DATA"
		end if;
	end function ReadDuringWriteModeMixedPorts;
	--*********************************************************************************************
	--*********************************************************************************************
	-- Constants & signals
	--*********************************************************************************************
	constant        OPERATION_MODE                     : string  := OperationMode(A_MODE,B_MODE) ; -- Control ports usage
	constant        OUTDATA_REG                        : string  := OutDataReg (B_RD_LAT)        ; -- Control register on output data
	constant        OUTDATA_REG_A                      : string  := OutDataRegA(A_RD_LAT)        ; -- Control register on output data A
	constant        OUTDATA_REG_B                      : string  := OutDataRegB(B_RD_LAT)        ; -- Control register on output data B
	constant        CLOCK_ENABLE_INPUT_A               : string  := "NORMAL"                     ; -- "BYPASS" / "NORMAL"
	constant        CLOCK_ENABLE_INPUT_B               : string  := "NORMAL"                     ; -- "BYPASS" / "NORMAL"
	constant        CLOCK_ENABLE_OUTPUT_A              : string  := "NORMAL"                     ; -- "BYPASS" / "NORMAL"
	constant        CLOCK_ENABLE_OUTPUT_B              : string  := "NORMAL"                     ; -- "BYPASS" / "NORMAL"
	constant        RAM_BLOCK_TYPE_FIXED               : string  := RamBlockType                 ; -- Specify which type of RAM block should be used
	constant        READ_DURING_WRITE_MODE_MIXED_PORTS : string  := ReadDuringWriteModeMixedPorts; -- Read behavior during a write at the same address
	constant        A_DPS_BE                           : natural := DPSandBE(A_DPS,USE_BE)       ; -- DPS + BE(if exists)
	constant        B_DPS_BE                           : natural := DPSandBE(B_DPS,USE_BE)       ; -- DPS + BE(if exists)
	signal          A_WrDataBE                         : slv(A_DPS_BE-1 downto 0)                ; -- A / Write Data + ByteEnable
	signal          B_WrDataBE                         : slv(B_DPS_BE-1 downto 0)                ; -- B / Write Data + ByteEnable
	signal          A_RdData_ram                       : slv(A_DPS_BE-1 downto 0)                ; -- A / Read  Data + ByteEnable, from RAM block
	signal          A_RdData_ram_r                     : slv(A_DPS_BE-1 downto 0)                ; -- A / Read  Data + ByteEnable, from RAM block, 1 clock register (for internal multiplexor)
	signal          A_RdDataBE                         : slv(A_DPS_BE-1 downto 0)                ; -- A / Read  Data + ByteEnable
	signal          B_RdData_ram                       : slv(B_DPS_BE-1 downto 0)                ; -- B / Read  Data + ByteEnable, from RAM block
	signal          B_RdData_ram_r                     : slv(B_DPS_BE-1 downto 0)                ; -- B / Read  Data + ByteEnable, from RAM block, 1 clock register (for internal multiplexor)
	signal          B_RdDataBE                         : slv(B_DPS_BE-1 downto 0)                ; -- B / Read  Data + ByteEnable
	--synthesis translate_off
	signal          A_Rd_s                             : slv3                                    ; -- A_Rd delay line
	signal          A_RdDataValid                      : sl                                      ; -- A_RdData is valid
	signal          B_Rd_s                             : slv3                                    ; -- B_Rd delay line
	signal          B_RdDataValid                      : sl                                      ; -- B_RdData is valid
	--synthesis translate_on
begin
--**********************************************************************************************************************
-- Data path management (merge & extract data with ByteEnable)
--**********************************************************************************************************************
data_mgt_a : process(A_Dmn)
begin
if A_Dmn.rst='1' then
	A_RdData_ram_r  <= (others=>'0');
elsif rising_edge(A_Dmn.clk) then
	A_RdData_ram_r <= A_RdData_ram;
end if;
end process data_mgt_a;

data_mgt_b : process(B_Dmn)
begin
if B_Dmn.rst='1' then
	B_RdData_ram_r <= (others=>'0');
elsif rising_edge(B_Dmn.clk) then
	B_RdData_ram_r <= B_RdData_ram;
end if;
end process data_mgt_b;

----------------------------------------------------------------------------------------------------
--synthesis translate_off
rd_delay_a : process(A_Dmn)
begin
if A_Dmn.rst='1' then
	A_Rd_s <= (others=>'0');
elsif rising_edge(A_Dmn.clk) then
	A_Rd_s <= ExcludeMSB(A_Rd_s) & A_Rd;
end if;
end process rd_delay_a;
A_RdDataValid <= A_Rd_s(A_RD_LAT-1+1) when A_RD_XTRA_REG else
                 A_Rd_s(A_RD_LAT-1  );

A_RdData      <= (others=>'X') when A_RdDataValid='0' else (others=>'Z');

rd_delay_b : process(B_Dmn)
begin
if B_Dmn.rst='1' then
	B_Rd_s <= (others=>'0');
elsif rising_edge(B_Dmn.clk) then
	B_Rd_s <= ExcludeMSB(B_Rd_s) & B_Rd;
end if;
end process rd_delay_b;
B_RdDataValid <= B_Rd_s(B_RD_LAT-1+1) when B_RD_XTRA_REG else
                 B_Rd_s(B_RD_LAT-1  );

B_RdData      <= (others=>'X') when B_RdDataValid='0' else (others=>'Z');
--synthesis translate_on
----------------------------------------------------------------------------------------------------

A_RdDataBE <= A_RdData_ram_r when A_RD_XTRA_REG else
              A_RdData_ram;

B_RdDataBE <= B_RdData_ram_r when B_RD_XTRA_REG else
              B_RdData_ram;

--Merge data with associated ByteEnable. Pattern is [BE + 8data]
A_WrDataBE <= MergeDataBE(A_WrData,A_WrBE) when USE_BE else A_WrData;
B_WrDataBE <= MergeDataBE(B_WrData,B_WrBE) when USE_BE else B_WrData;

--Extract data from 9bits pattern. Data is 8LSB
A_RdData   <= (others=>'-') when A_MODE="WO" else ExtractData(A_RdDataBE) when USE_BE else A_RdDataBE;
B_RdData   <= (others=>'-') when B_MODE="WO" else ExtractData(B_RdDataBE) when USE_BE else B_RdDataBE;

--Extract ByteEnable from 9bits pattern. ByteEnable is MSB
A_RdBE     <= (others=>'-') when A_MODE="WO" else ExtractBE  (A_RdDataBE) when USE_BE else (others=>'1');
B_RdBE     <= (others=>'-') when B_MODE="WO" else ExtractBE  (B_RdDataBE) when USE_BE else (others=>'1');
--**********************************************************************************************************************
-- Memory block for APEX & ACEX devices. This section instantiates ALTDPRAM primitive
--**********************************************************************************************************************
-- For ALTDPRAM primitive, data path shall have the same size on both sides
mem_altdpram : if (DEVICE="ACEX" or DEVICE="APEX20KE") and A_DPS=B_DPS generate
	component altdpram
		generic(INTENDED_DEVICE_FAMILY:string;WIDTH:natural;WIDTHAD:natural;INDATA_REG:string;WRADDRESS_REG:string;WRCONTROL_REG:string
		       ;RDADDRESS_REG:string;RDCONTROL_REG:string;OUTDATA_REG:string;INDATA_ACLR:string;WRADDRESS_ACLR:string;WRCONTROL_ACLR:string
		       ;RDADDRESS_ACLR:string;RDCONTROL_ACLR:string;OUTDATA_ACLR:string;LPM_TYPE:string;USE_EAB:string);
		port   (inclock :in sl;wraddress:in slv(WIDTHAD-1 downto 0);wren:in sl;data:in  slv(WIDTH-1 downto 0)
		       ;outclock:in sl;rdaddress:in slv(WIDTHAD-1 downto 0)           ;q   :out slv(WIDTH-1 downto 0));
	end component altdpram;

begin

	l : altdpram generic map
		(INTENDED_DEVICE_FAMILY => DEVICE
		,WIDTH                  => A_DPS
		,WIDTHAD                => A_APS
		,INDATA_REG             => "INCLOCK"
		,WRADDRESS_REG          => "INCLOCK"
		,WRCONTROL_REG          => "INCLOCK"
		,RDADDRESS_REG          => "OUTCLOCK"
		,RDCONTROL_REG          => "UNREGISTERED"
		,OUTDATA_REG            => OUTDATA_REG
		,INDATA_ACLR            => "OFF"
		,WRADDRESS_ACLR         => "OFF"
		,WRCONTROL_ACLR         => "OFF"
		,RDADDRESS_ACLR         => "OFF"
		,RDCONTROL_ACLR         => "OFF"
		,OUTDATA_ACLR           => "OFF"
		,LPM_TYPE               => "altdpram"
		,USE_EAB                => "ON"
		) port map
		(inclock =>A_Dmn.clk,wraddress=>A_Addr(A_APS-1 downto 0),wren=>A_Wr,data=>A_WrDataBE
		,outclock=>B_Dmn.clk,rdaddress=>B_Addr(B_APS-1 downto 0)           ,q   =>B_RdData_ram);

	assert B_RD_LAT=2 report "Unsupported Latency value for APEX/ACEX family" severity failure;
end generate mem_altdpram;
--**********************************************************************************************************************
-- Memory block for Stratix & Cyclone devices. This section instantiates ALTSYNCRAM primitive
--**********************************************************************************************************************
--=============================================================
-- Regular dual port :
--     * A port is configured as WRITE ONLY
--     * B port is configured as READ  ONLY
--=============================================================
mem_altsyncram_dual_port : if StrEq(OPERATION_MODE,"DUAL_PORT") and
                              (DEVICE="Arria GX"     or
                               DEVICE="Arria II GX"  or DEVICE="Arria II GZ"    or
                               DEVICE="Arria 10"     or
                               DEVICE="Cyclone"      or
                               DEVICE="Cyclone II"   or
                               DEVICE="Cyclone III"  or DEVICE="Cyclone III LS" or
                               DEVICE="Cyclone IV E" or DEVICE="Cyclone IV GX"  or
                               DEVICE="Cyclone V"    or
                               DEVICE="HardCopy II"  or
                               DEVICE="HardCopy III" or
                               DEVICE="HardCopy IV"  or
                               DEVICE="MAX 10"       or
                               DEVICE="Stratix"      or DEVICE="Stratix GX"     or
                               DEVICE="Stratix II"   or DEVICE="Stratix II GX"  or
                               DEVICE="Stratix III"  or
                               DEVICE="Stratix IV"   or
                               DEVICE="Stratix V"    ) generate
	component altsyncram
		generic(INTENDED_DEVICE_FAMILY:string;RAM_BLOCK_TYPE:string;LPM_TYPE:string;OPERATION_MODE:string;POWER_UP_UNINITIALIZED:string
		       ;READ_DURING_WRITE_MODE_MIXED_PORTS:string
		       ;READ_DURING_WRITE_MODE_PORT_B:string
		       ;INIT_FILE:string;INIT_FILE_LAYOUT:string
		       ;CLOCK_ENABLE_INPUT_A:string
		       ;CLOCK_ENABLE_INPUT_B:string;CLOCK_ENABLE_OUTPUT_B:string
		       ;WIDTH_A:natural;WIDTHAD_A:natural;WIDTH_BYTEENA_A:natural;NUMWORDS_A:natural;ADDRESS_ACLR_A:string
		       ;WIDTH_B:natural;WIDTHAD_B:natural;                        NUMWORDS_B:natural;ADDRESS_ACLR_B:string;ADDRESS_REG_B:string;OUTDATA_REG_B:string;OUTDATA_ACLR_B:string
		       ;ENABLE_ECC:string;WIDTH_ECCSTATUS:integer;ECC_PIPELINE_STAGE_ENABLED:string);
		port   (clock0:in sl;clocken0:in sl;address_a:in slv(WIDTHAD_A-1 downto 0);wren_a:in sl;data_a:in  slv(WIDTH_A-1 downto 0)
		       ;clock1:in sl;clocken1:in sl;address_b:in slv(WIDTHAD_B-1 downto 0);                                                rden_b:in sl;q_b:out slv(WIDTH_B-1 downto 0));
	end component altsyncram;

begin

	l : altsyncram generic map
		( INTENDED_DEVICE_FAMILY             => DEVICE
		, LPM_TYPE                           => "altsyncram"
		, OPERATION_MODE                     => "DUAL_PORT"
		, POWER_UP_UNINITIALIZED             => "TRUE"
		, RAM_BLOCK_TYPE                     => RAM_BLOCK_TYPE_FIXED
		, READ_DURING_WRITE_MODE_MIXED_PORTS => READ_DURING_WRITE_MODE_MIXED_PORTS
		                                                                 , READ_DURING_WRITE_MODE_PORT_B => "NEW_DATA_NO_NBE_READ"
		, INIT_FILE                          => INIT_FILE
		, INIT_FILE_LAYOUT                   => INIT_FILE_LAYOUT
		, CLOCK_ENABLE_INPUT_A               => CLOCK_ENABLE_INPUT_A     , CLOCK_ENABLE_INPUT_B          => CLOCK_ENABLE_INPUT_B
		                                                                 , CLOCK_ENABLE_OUTPUT_B         => CLOCK_ENABLE_OUTPUT_B
		, WIDTH_A                            => A_DPS_BE                 , WIDTH_B                       => B_DPS_BE
		, WIDTHAD_A                          => A_APS                    , WIDTHAD_B                     => B_APS
		, NUMWORDS_A                         => 2**A_APS                 , NUMWORDS_B                    => 2**B_APS
		, ADDRESS_ACLR_A                     => "NONE"                   , ADDRESS_ACLR_B                => "NONE"
		, WIDTH_BYTEENA_A                    => 1
		                                                                 , OUTDATA_REG_B                 => OUTDATA_REG_B
		                                                                 , OUTDATA_ACLR_B                => "NONE"
		                                                                 , ADDRESS_REG_B                 => "CLOCK1"
		  -- ECC Status Parameters
		, ENABLE_ECC                         => ENABLE_ECC
		, WIDTH_ECCSTATUS                    => WIDTH_ECCSTATUS
		, ECC_PIPELINE_STAGE_ENABLED         => ECC_PIPELINE_STAGE_ENABLED
		) port map
		( clock0                             => A_Dmn.clk                , clock1                        => B_Dmn.clk
		, clocken0                           => A_dmn.ena                , clocken1                      => B_Dmn.ena
		, address_a                          => A_Addr(A_APS-1 downto 0) , address_b                     => B_Addr(B_APS-1 downto 0)
		, wren_a                             => A_Wr
		, data_a                             => A_WrDataBE
		                                                                 , rden_b                        => B_Rd
		                                                                 , q_b                           => B_RdData_ram
		);

	A_RdData_ram <= (others=>'X');

	-- Check static directionality
	assert not(A_MODE="RO" and B_MODE="RO") report "[memory] : There is no Write port !!"                                                   severity failure;
	assert not(A_MODE="WO" and B_MODE="WO") report "[memory] : There is no Read port !!"                                                    severity failure;
	assert not(A_MODE="RW" and B_MODE="RO") report "[memory] : A cannot be bidirectionnal and B only for Read !!"                           severity failure;
	assert not(A_MODE="RW" and B_MODE="WO") report "[memory] : A cannot be bidirectionnal and B only for Write !!"                          severity failure;
	assert not(A_MODE="WO" and B_MODE="RW") report "[memory] : B cannot be bidirectionnal and A only for Write !!"                          severity failure;
	assert not(A_MODE="RO" and B_MODE="RW") report "[memory] : B cannot be bidirectionnal and A only for Read !!"                           severity failure;
	assert not(A_MODE="RO" and B_MODE="WO") report "[memory] : Altsyncram cannot transmit data in 'Simple dual port' from B port to A port" severity failure;

	assert not(DEVICE="Stratix"     and RAM_BLOCK_TYPE="M512" and A_MODE="RW" and B_MODE="RW") report "[memory_altera] : M512 block doesn't support bidir dual mode" severity failure;
	assert not(DEVICE="Stratix II"  and RAM_BLOCK_TYPE="M512" and A_MODE="RW" and B_MODE="RW") report "[memory_altera] : M512 block doesn't support bidir dual mode" severity failure;
	assert not(DEVICE="Stratix III" and RAM_BLOCK_TYPE="MLAB" and A_MODE="RW" and B_MODE="RW") report "[memory_altera] : MLAB block doesn't support bidir dual mode" severity failure;
	assert not(DEVICE="Stratix IV"  and RAM_BLOCK_TYPE="MLAB" and A_MODE="RW" and B_MODE="RW") report "[memory_altera] : MLAB block doesn't support bidir dual mode" severity failure;
	assert not(DEVICE="Stratix V"   and RAM_BLOCK_TYPE="MLAB" and A_MODE="RW" and B_MODE="RW") report "[memory_altera] : MLAB block doesn't support bidir dual mode" severity failure;

end generate mem_altsyncram_dual_port;

--=============================================================
-- Bidir dual port : both ports have read/write capabilities
--=============================================================
mem_altsyncram_bidir : if StrEq(OPERATION_MODE,"BIDIR_DUAL_PORT") and
                         (DEVICE="Arria GX"     or
                          DEVICE="Arria II GX"  or DEVICE="Arria II GZ"    or
                          DEVICE="Arria 10"     or
                          DEVICE="Cyclone"      or
                          DEVICE="Cyclone II"   or
                          DEVICE="Cyclone III"  or DEVICE="Cyclone III LS" or
                          DEVICE="Cyclone IV E" or DEVICE="Cyclone IV GX"  or
                          DEVICE="Cyclone V"    or
                          DEVICE="HardCopy II"  or
                          DEVICE="HardCopy III" or
                          DEVICE="HardCopy IV"  or
                          DEVICE="MAX 10"       or
                          DEVICE="Stratix"      or DEVICE="Stratix GX"     or
                          DEVICE="Stratix II"   or DEVICE="Stratix II GX"  or
                          DEVICE="Stratix III"  or
                          DEVICE="Stratix IV"   or
                          DEVICE="Stratix V"    ) generate
	component altsyncram
		generic(INTENDED_DEVICE_FAMILY:string;RAM_BLOCK_TYPE:string;LPM_TYPE:string;OPERATION_MODE:string;POWER_UP_UNINITIALIZED:string;INDATA_REG_B:string
		       ;READ_DURING_WRITE_MODE_MIXED_PORTS:string
		       ;READ_DURING_WRITE_MODE_PORT_A:string;READ_DURING_WRITE_MODE_PORT_B:string
		       ;INIT_FILE:string;INIT_FILE_LAYOUT:string
		       ;CLOCK_ENABLE_INPUT_A:string;CLOCK_ENABLE_OUTPUT_A:string
		       ;CLOCK_ENABLE_INPUT_B:string;CLOCK_ENABLE_OUTPUT_B:string
		       ;WIDTH_A:natural;WIDTHAD_A:natural;WIDTH_BYTEENA_A:natural;NUMWORDS_A:natural;ADDRESS_ACLR_A:string;INDATA_ACLR_A:string;WRCONTROL_ACLR_A:string;                     OUTDATA_REG_A:string;OUTDATA_ACLR_A:string
		       ;WIDTH_B:natural;WIDTHAD_B:natural;WIDTH_BYTEENA_B:natural;NUMWORDS_B:natural;ADDRESS_ACLR_B:string;INDATA_ACLR_B:string;WRCONTROL_ACLR_B:string;ADDRESS_REG_B:string;OUTDATA_REG_B:string;OUTDATA_ACLR_B:string;WRCONTROL_WRADDRESS_REG_B:string
		       ;ENABLE_ECC:string;WIDTH_ECCSTATUS:integer;ECC_PIPELINE_STAGE_ENABLED:string);
		port   (clock0:in sl;clocken0:in sl;address_a:in slv(WIDTHAD_A-1 downto 0);wren_a:in sl;data_a:in  slv(WIDTH_A-1 downto 0);rden_a:in sl;q_a:out slv(WIDTH_A-1 downto 0)
		       ;clock1:in sl;clocken1:in sl;address_b:in slv(WIDTHAD_B-1 downto 0);wren_b:in sl;data_b:in  slv(WIDTH_B-1 downto 0);rden_b:in sl;q_b:out slv(WIDTH_B-1 downto 0));
	end component altsyncram;

begin

--	READ_DURING_WRITE_MODE_MIXED_PORTS = "DONT_CARE"
--	READ_DURING_WRITE_MODE_MIXED_PORTS = "OLD_DATA"
--	READ_DURING_WRITE_MODE_PORT_A      = "NEW_DATA_NO_NBE_READ"
--	READ_DURING_WRITE_MODE_PORT_A      = "OLD_DATA"

	l : altsyncram generic map
		( INTENDED_DEVICE_FAMILY             => DEVICE
		, LPM_TYPE                           => "altsyncram"
		, OPERATION_MODE                     => "BIDIR_DUAL_PORT"
		, POWER_UP_UNINITIALIZED             => "TRUE"
		, RAM_BLOCK_TYPE                     => RAM_BLOCK_TYPE_FIXED
		, READ_DURING_WRITE_MODE_MIXED_PORTS => READ_DURING_WRITE_MODE_MIXED_PORTS
		, READ_DURING_WRITE_MODE_PORT_A      => "NEW_DATA_NO_NBE_READ"   , READ_DURING_WRITE_MODE_PORT_B => "NEW_DATA_NO_NBE_READ"
		, INIT_FILE                          => INIT_FILE
		, INIT_FILE_LAYOUT                   => INIT_FILE_LAYOUT
		, CLOCK_ENABLE_INPUT_A               => CLOCK_ENABLE_INPUT_A     , CLOCK_ENABLE_INPUT_B          => CLOCK_ENABLE_INPUT_B
		, CLOCK_ENABLE_OUTPUT_A              => CLOCK_ENABLE_OUTPUT_A    , CLOCK_ENABLE_OUTPUT_B         => CLOCK_ENABLE_OUTPUT_B
		, WIDTH_A                            => A_DPS_BE                 , WIDTH_B                       => B_DPS_BE
		, WIDTHAD_A                          => A_APS                    , WIDTHAD_B                     => B_APS
		, NUMWORDS_A                         => 2**A_APS                 , NUMWORDS_B                    => 2**B_APS
		, ADDRESS_ACLR_A                     => "NONE"                   , ADDRESS_ACLR_B                => "NONE"
		, WIDTH_BYTEENA_A                    => 1                        , WIDTH_BYTEENA_B               => 1
		, INDATA_ACLR_A                      => "NONE"                   , INDATA_ACLR_B                 => "NONE"
		, WRCONTROL_ACLR_A                   => "NONE"                   , WRCONTROL_ACLR_B              => "NONE"
		, OUTDATA_REG_A                      => OUTDATA_REG_A            , OUTDATA_REG_B                 => OUTDATA_REG_B
		, OUTDATA_ACLR_A                     => "NONE"                   , OUTDATA_ACLR_B                => "NONE"
		                                                                 , ADDRESS_REG_B                 => "CLOCK1"
		                                                                 , INDATA_REG_B                  => "CLOCK1"
		                                                                 , WRCONTROL_WRADDRESS_REG_B     => "CLOCK1"
		  -- ECC Status Parameters
		, ENABLE_ECC                         => ENABLE_ECC
		, WIDTH_ECCSTATUS                    => WIDTH_ECCSTATUS
		, ECC_PIPELINE_STAGE_ENABLED         => ECC_PIPELINE_STAGE_ENABLED
		) port map
		( clock0                             => A_Dmn.clk                , clock1                        => B_Dmn.clk
		, clocken0                           => A_Dmn.ena                , clocken1                      => B_Dmn.ena
		, address_a                          => A_Addr(A_APS-1 downto 0) , address_b                     => B_Addr(B_APS-1 downto 0)
		, wren_a                             => A_Wr                     , wren_b                        => B_Wr
		, data_a                             => A_WrDataBE               , data_b                        => B_WrDataBE
		, rden_a                             => A_Rd                     , rden_b                        => B_Rd
		, q_a                                => A_RdData_ram             , q_b                           => B_RdData_ram
		);

	-- Check static directionality
	assert not(A_MODE="RO" and B_MODE="RO") report "[memory] : There is no Write port !!"                                                   severity failure;
	assert not(A_MODE="WO" and B_MODE="WO") report "[memory] : There is no Read port !!"                                                    severity failure;
	assert not(A_MODE="RW" and B_MODE="RO") report "[memory] : A cannot be bidirectionnal and B only for Read !!"                           severity failure;
	assert not(A_MODE="RW" and B_MODE="WO") report "[memory] : A cannot be bidirectionnal and B only for Write !!"                          severity failure;
	assert not(A_MODE="WO" and B_MODE="RW") report "[memory] : B cannot be bidirectionnal and A only for Write !!"                          severity failure;
	assert not(A_MODE="RO" and B_MODE="RW") report "[memory] : B cannot be bidirectionnal and A only for Read !!"                           severity failure;
	assert not(A_MODE="RO" and B_MODE="WO") report "[memory] : Altsyncram cannot transmit data in 'Simple dual port' from B port to A port" severity failure;

	assert not(DEVICE="Stratix"     and RAM_BLOCK_TYPE="M512" and A_MODE="RW" and B_MODE="RW") report "[memory_altera] : M512 block doesn't support bidir dual mode" severity failure;
	assert not(DEVICE="Stratix II"  and RAM_BLOCK_TYPE="M512" and A_MODE="RW" and B_MODE="RW") report "[memory_altera] : M512 block doesn't support bidir dual mode" severity failure;
	assert not(DEVICE="Stratix III" and RAM_BLOCK_TYPE="MLAB" and A_MODE="RW" and B_MODE="RW") report "[memory_altera] : MLAB block doesn't support bidir dual mode" severity failure;
	assert not(DEVICE="Stratix IV"  and RAM_BLOCK_TYPE="MLAB" and A_MODE="RW" and B_MODE="RW") report "[memory_altera] : MLAB block doesn't support bidir dual mode" severity failure;
	assert not(DEVICE="Stratix V"   and RAM_BLOCK_TYPE="MLAB" and A_MODE="RW" and B_MODE="RW") report "[memory_altera] : MLAB block doesn't support bidir dual mode" severity failure;

end generate mem_altsyncram_bidir;

--=============================================================
-- ROM : Only port A is connected
--=============================================================
mem_altsyncram_rom : if StrEq(OPERATION_MODE,"ROM") and
                       (DEVICE="Arria GX"     or
                        DEVICE="Arria II GX"  or DEVICE="Arria II GZ"    or
                        DEVICE="Arria 10"     or
                        DEVICE="Cyclone"      or
                        DEVICE="Cyclone II"   or
                        DEVICE="Cyclone III"  or DEVICE="Cyclone III LS" or
                        DEVICE="Cyclone IV E" or DEVICE="Cyclone IV GX"  or
                        DEVICE="Cyclone V"    or
                        DEVICE="HardCopy II"  or
                        DEVICE="HardCopy III" or
                        DEVICE="HardCopy IV"  or
                        DEVICE="MAX 10"       or
                        DEVICE="Stratix"      or DEVICE="Stratix GX"     or
                        DEVICE="Stratix II"   or DEVICE="Stratix II GX"  or
                        DEVICE="Stratix III"  or
                        DEVICE="Stratix IV"   or
                        DEVICE="Stratix V"    ) generate
	component altsyncram
		generic(INTENDED_DEVICE_FAMILY:string;RAM_BLOCK_TYPE:string;LPM_TYPE:string;OPERATION_MODE:string;POWER_UP_UNINITIALIZED:string
		       ;INIT_FILE:string;INIT_FILE_LAYOUT:string
		       ;CLOCK_ENABLE_INPUT_A:string;CLOCK_ENABLE_OUTPUT_A:string
		       ;WIDTH_A:natural;WIDTHAD_A:natural;WIDTH_BYTEENA_A:natural;NUMWORDS_A:natural;ADDRESS_ACLR_A:string;OUTDATA_REG_A:string;OUTDATA_ACLR_A:string
		       ;ENABLE_ECC:string;WIDTH_ECCSTATUS:integer;ECC_PIPELINE_STAGE_ENABLED:string);
		port   (clock0:in sl;clocken0:in sl;address_a:in slv(WIDTHAD_A-1 downto 0);                                                rden_a:in sl;q_a:out slv(WIDTH_A-1 downto 0));
	end component altsyncram;

begin
	l : altsyncram generic map
		( INTENDED_DEVICE_FAMILY             => DEVICE
		, LPM_TYPE                           => "altsyncram"
		, OPERATION_MODE                     => "ROM"
		, POWER_UP_UNINITIALIZED             => "TRUE"
		, RAM_BLOCK_TYPE                     => RAM_BLOCK_TYPE_FIXED
		, INIT_FILE                          => INIT_FILE
		, INIT_FILE_LAYOUT                   => INIT_FILE_LAYOUT
		, CLOCK_ENABLE_INPUT_A               => CLOCK_ENABLE_INPUT_A
		, CLOCK_ENABLE_OUTPUT_A              => CLOCK_ENABLE_OUTPUT_A
		, WIDTH_A                            => A_DPS_BE
		, WIDTHAD_A                          => A_APS
		, NUMWORDS_A                         => 2**A_APS
		, ADDRESS_ACLR_A                     => "NONE"
		, WIDTH_BYTEENA_A                    => 1
		, OUTDATA_REG_A                      => OUTDATA_REG_A
		, OUTDATA_ACLR_A                     => "NONE"
		  -- ECC Status Parameters
		, ENABLE_ECC                         => ENABLE_ECC
		, WIDTH_ECCSTATUS                    => WIDTH_ECCSTATUS
		, ECC_PIPELINE_STAGE_ENABLED         => ECC_PIPELINE_STAGE_ENABLED
		) port map
		( clock0                             => A_Dmn.clk
		, clocken0                           => A_dmn.ena
		, address_a                          => A_Addr(A_APS-1 downto 0)
		, rden_a                             => A_Rd
		, q_a                                => A_RdData_ram
		);

	-- Check static directionality
	assert not(A_MODE="RO" and B_MODE="RO") report "[memory] : There is no Write port !!"                                                   severity failure;
	assert not(A_MODE="WO" and B_MODE="WO") report "[memory] : There is no Read port !!"                                                    severity failure;
	assert not(A_MODE="RW" and B_MODE="RO") report "[memory] : A cannot be bidirectionnal and B only for Read !!"                           severity failure;
	assert not(A_MODE="RW" and B_MODE="WO") report "[memory] : A cannot be bidirectionnal and B only for Write !!"                          severity failure;
	assert not(A_MODE="WO" and B_MODE="RW") report "[memory] : B cannot be bidirectionnal and A only for Write !!"                          severity failure;
	assert not(A_MODE="RO" and B_MODE="RW") report "[memory] : B cannot be bidirectionnal and A only for Read !!"                           severity failure;
	assert not(A_MODE="RO" and B_MODE="WO") report "[memory] : Altsyncram cannot transmit data in 'Simple dual port' from B port to A port" severity failure;

	assert not(DEVICE="Stratix"     and RAM_BLOCK_TYPE="M512" and A_MODE="RW" and B_MODE="RW") report "[memory_altera] : M512 block doesn't support bidir dual mode" severity failure;
	assert not(DEVICE="Stratix II"  and RAM_BLOCK_TYPE="M512" and A_MODE="RW" and B_MODE="RW") report "[memory_altera] : M512 block doesn't support bidir dual mode" severity failure;
	assert not(DEVICE="Stratix III" and RAM_BLOCK_TYPE="MLAB" and A_MODE="RW" and B_MODE="RW") report "[memory_altera] : MLAB block doesn't support bidir dual mode" severity failure;
	assert not(DEVICE="Stratix IV"  and RAM_BLOCK_TYPE="MLAB" and A_MODE="RW" and B_MODE="RW") report "[memory_altera] : MLAB block doesn't support bidir dual mode" severity failure;
	assert not(DEVICE="Stratix V"   and RAM_BLOCK_TYPE="MLAB" and A_MODE="RW" and B_MODE="RW") report "[memory_altera] : MLAB block doesn't support bidir dual mode" severity failure;

	B_RdData_ram   <= (others=>'0');
	B_RdData_ram_r <= (others=>'0');
	B_RdDataBE     <= (others=>'0');
end generate mem_altsyncram_rom;

--**********************************************************************************************************************
-- Check request device is supported (and will be mapped with one of the previous generate sections)
--**********************************************************************************************************************
assert DEVICE="ACEX"           or
       DEVICE="APEX20KE"       or
       DEVICE="Arria GX"       or
       DEVICE="Arria II GX"    or
       DEVICE="Arria II GZ"    or
       DEVICE="Arria 10"       or
       DEVICE="Cyclone"        or
       DEVICE="Cyclone II"     or
       DEVICE="Cyclone III"    or
       DEVICE="Cyclone III LS" or
       DEVICE="Cyclone IV E"   or
       DEVICE="Cyclone IV GX"  or
       DEVICE="Cyclone V"      or
       DEVICE="HardCopy II"    or
       DEVICE="HardCopy III"   or
       DEVICE="HardCopy IV"    or
       DEVICE="MAX 10"         or
       DEVICE="Stratix"        or
       DEVICE="Stratix GX"     or
       DEVICE="Stratix II"     or
       DEVICE="Stratix II GX"  or
       DEVICE="Stratix III"    or
       DEVICE="Stratix IV"     or
       DEVICE="Stratix V"
	report "Illegal DEVICE value : " & DEVICE & " !!"
	severity failure;

end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
