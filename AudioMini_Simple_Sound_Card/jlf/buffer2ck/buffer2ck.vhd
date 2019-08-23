/*--------------------------------------------------------------------------------------------------------------------------------------------------------------
Author      : Jean-Louis FLOQUET
Title       : Dual Clock Buffer
File        : buffer2ck.vhd
Application : RTL
Created     : 2004/03/08
Last update : 2014/09/05 17:45
Version     : 7.03.01
Dependency  : memory.vhd for ALTERA/XILINX devices
----------------------------------------------------------------------------------------------------------------------------------------------------------------
¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
Description : Memory buffer with 2 clocks (any relationship & phase are supported)
¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
This buffer contains two identical ports A and B. Each port has :
	* Dedicated asynchronous reset circuitry
	* Dedicated clock enable circuitry
	* Dedicated synchronous reset circuitry (sent to other port)
	* Read latency programmable : 0 (Show-Ahead), 1 (unregistered output) or 2 (registered output)
	* Circular mode (not available for Dual clock)
	* Partial Write & Partial Read operations (see [Note 2], [Note 3], [Note 4])
	* Dynamically reversible buffer
	* Number of words and number of bytes
	* OverFlow & UnderFlow flags (sent to other port)
	* Write command & data signals (with byte enable storage)
	* Read  command & data signals (with byte enable restore)

Useless output ports should remain unconnected with the rest of the design in order that synthesizer can remove unused logic

                                                              \
                                                      A_Clk   /   B_Clk
                                                              \
                                         +-----------------+  /  +-----------------+
   control                               |                 |  \  |                 |                               control
  -------------------------------------> |                 |  /  |                 | <-------------------------------------
                 +---------+    |\       |          +------+  \  +------+          |
                 | Partial |____| \      |          |         /         |          |
             |¯¯ |  Write  |    |  |     |          |  +-------------+  |          |                                Write
             |   +---------+    |  |---> |          |  |             |  |          | <-------------------------------------
   Write     |                  |  |     |  Half-A  |  |     RAM     |  |  Half-B  |        +---------+    |\
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯| /      |          |  |             |  |          |        | Partial |____| \
                                |/       |          |  +-------------+  |          |     |¯¯|  Read   |    |  |      Read
                                         |          |         \         |          |     |  +---------+    |  | ---------->
    Read                                 |          +------+  /  +------+          |     |                 |  |
  <------------------------------------- |                 |  \  |                 |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯| /
                                         |                 |  /  |                 |                       |/
                                         +-----------------+  \  +-----------------+
                                                              /
                                                              \

¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
                                                                         Release notes
¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
  Rev.   |    Date    | Description
 7.03.01 | 2014/09/05 | 1) Fix : Write data management (occurs only on "slow" write clock / "fast" read clock)
         |            |
 7.02.12 | 2014/02/21 | 1) New : RdSkipBit/RdSkipWord allowed in dual clock mode. Read important [Note 8]
         | 2014/03/13 | 2) Enh : Reduce register usage for bit/word counters when RAW_DPS=false
         |            | 3) Enh : Ready flag moved to dedicated sub-module
         |            | 4) Enh : Optimize RTL Viewer for received flags
         |            | 5) Chg : OverFlow/UnderFlow flags moved to dedicated sub-module
         |            | 6) Chg : Removed 'wr_nop' sub-module and drive directly constants
         | 2014/03/14 | 7) Enh : Local Address Bit/Word moved to dedicated sub-modules
         | 2014/03/17 | 8) Enh : B_Empty/B_Full/B_OverFlow/B_UnderFlow/B_Ready on single clock mode
         |            | 9) Enh : User Address Bit moved to dedicated sub-module
         | 2014/03/18 |10) Chg : Record 'domain'
         | 2014/03/19 |11) Chg : Removed default value for CLOCK_MODE (force user to choose explicitely)
         | 2014/04/08 |12) Fix : Mode RAW_DPS & Show-Ahead mode & single clock
         |            |
 7.01.05 | 2013/11/21 | 1) Chg : Some block/generate moved to entity to increase RTL view (rd_lat_0_*, UsedBit, UsedWord, wr_full, wr_nop, wr_partial)
         |            | 2) Chg : B_UsedByte & B_UsedBit driven to 'X' when RAW_DPS=true
         | 2014/02/10 | 3) Chg : Merged mapping for regular & partial access half-sub-entities
         |            | 4) New : Some coherency tests for partial access
         | 2014/02/20 | 5) Fix : Number of bits stored on B-side with PW_ENABLE and PR_ENABLE enabled
         |            |
 7.00.13 | 2013/03/27 | 1) Chg : VHDL-2008 required
         |            | 2) New : Circular mode
         |            | 3) Chg : All internal counters/pointers based on 'bit' rather than 'word'
         |            | 4) New : Partial access (see [Note 2])
         |            | 5) Enh : Lots of minor improvements
         |            | 6) New : A_LAT_RD_ADDR/B_LAT_RD_ADDR generics to reduce overall read-latency on regular speed systems
         |            | 7) Chg : A_RD_LAT/B_RD_LAT renamed to A_LAT_RD_DATA/B_LAT_RD_DATA for coherency with 7.00.06
         | 2013/06/07 | 8) Fix : B_RdSkipBit synchronisation mechanism for both sides
         |            | 9) New : Data alignment (Left or Right) for partial read operations
         | 2013/06/14 |10) Fix : Circular mode with partial write
         |            |11) New : Data alignment (Left or Right) for partial write operations
         | 2013/07/22 |12) Chg : Update with pkg_sim 4.00.00
         | 2013/09/25 |13) Fix : A_RdDestroyWord/B_RdDestroyWord were not driven
---------+------------+-----------------------------------------------------------------------------------------------------------------------------------------
 6.02.01 | 2012/10/22 | 1) Fix : I_UsedB range used for BYTE_MODE=9
 6.01.01 | 2012/10/13 | 1) New : User full level can be set as 2**APS-LVL_FULL. In this case LVL_FULL shall be a negative integer
 6.00.01 | 2012/01/08 | 1) New : Asynchronous reset for each side
---------+------------+-----------------------------------------------------------------------------------------------------------------------------------------
 5.04.10 | 2010/04/09 | 1) Fix : ByteEnable width (entity and some internal signals) and B_RdBe connection (was commented)
         |            | 2) Enh : Add conflict on ByteEnable lines when bus is not valid
         |            | 3) Fix : Check that (BYTE_MODE=9 and USE_BE=true) never happends
         | 2010/04/16 | 4) Chg : "ID" to "ID_I" and "ID_U" for easier usage
         | 2010/11/30 | 5) Enh : Check illegal value on asynchronous reset
         | 2011/01/07 | 6) Enh : Rename internal signals that are directly connected to memory block
         |            | 7) Enh : Memory write command moved to buffer2ck_half. Also better handling during synchronous reset/clear
         | 2011/02/15 | 8) Enh : Allow user to set severity level for overflow/underflow report message
         | 2011/03/25 | 9) Fix : Removed a unwanted test having side effects
         | 2011/03/25 |10) Fix : Wrong 'U' memory address pointer for Show-Ahead
 5.03.08 | 2008/11/12 | 1) Fix : buffer2ck_xilinx for DPS/=2^n.
         | 2008/11/19 | 2) Fix : buffer2ck_altera for different RAM_BLOCK_TYPE versus DEVICE
         | 2008/11/24 | 3) Fix : (Major) Internal configuration for buffer2ck_xilinx
         | 2008/12/03 | 4) Fix : buffer2ck_xilinx was not able to provide A_RdData
         |            | 5) Fix : VERBOSE generic hidden for synthesis
         | 2008/12/08 | 6) Fix : Function 'FixDataBusOrder' in buffer2ck_xilinx
         | 2008/12/17 | 7) Enh : Option for extra register on read data path. See [Note 1]. Several bug fixed 2009/01/10
         | 2009/02/24 | 8) Chg : Updated from pkg_std 1.03.26
 5.02.02 | 2008/06/09 | 1) Fix : AltSyncRam read port are connected only if required (avoid fitter error)
         |            | 2) Fix : Remove warning about string comparaison (different lengths) for Xilinx ISE
 5.01.04 | 2008/01/30 | 1) Chg : Solved a big headache when Altera's or Xilinx's part not compiled
         |            |          buffer2ck_altera and buffer2ck_xilinx files don't contain anymore entity that moved to this file.
         |            | 2) Chg : Code cleaned
         |            | 3) Enh : All illegal values on RdReq & WrReq (instead of only 'U')
         |            | 4) Enh : Some news debug message
 5.00.14 | 2007/10/11 | 1) New : (Major) Each side is now exactly on the same basis to guarantee strict coherency. Simulation
         |            |          patterns have also been drastically enhanced to stress this module
         |            | 2) New : Possibility to skip any amount of data when reading (Single clock mode ONLY. Futur : both clocks)
         |            | 3) New : Add clock enable
         |            | 4) Enh : Use a true gray counter. Reduce latency of 1 clock cycle in Dual clock mode
         |            | 5) Chg : (Major) Elementary memory block is not anymore contained in this file. Requested for ALTERA & XILINX compatibility
         |            | 6) Fix : OverFlow checker (simulation only)
         |            | 7) New : Add support for "Stratix III" and "Cyclone III" devices
         |            | 8) Enh : Error messages
         |            | 9) Fix : Interface between both half sides
         |            |10) Fix : ALTERA Memory instanciation with clock enable
         |            |11) Enh : UsedWord equations
         |            |12) Enh : Allow data path of 1, 2, and 4. Byte Enable shall not be used in this mode (not available in memory block)
         |            |13) Fix : Internal pointers resizing for words counters
         |            |14) Enh : Change failure messages priority on UsedW
---------+------------+-----------------------------------------------------------------------------------------------------------------------------------------
 4.04.04 | 2007/01/25 | 1) Fix : Several problems in show-ahead mode, and word counter has been drastically simplifyed
         |            | 2) Enh : Full level detection customizable independantly on each side
         |            | 3) Chg : Some new datapath ratio added & fixed (no bug, just refused some ones)
         |            | 4) Enh : Reduce latency in Single clock mode
 4.03.11 | 2006/11/28 | 1) Fix : Reset when both sides are on the same clock
         |            | 2) Chg : pkg_std is now mandatory for Log2 function in entity port
         |            | 3) Chg : FLAG_FULL renamed to SEND_FLAG
         |            | 4) Fix : Read Data simulation conflict for non Show-Ahead modes
         |            | 5) New : Add ByteEnable for datapath support
         |            | 6) Fix : A=ReadOnly and B=WriteOnly is not possible for AltSyncRam
         |            | 7) Enh : Handle datapath ratio up to 16x
         |            | 8) Fix : Empty flag when reading last word
         |            | 9) Fix : Component declaration for synthesis
         |            |10) Chg : Shared variable to signal          (object for simulation only)
         |            |11) New : Add support for Cyclone & Stratix II devices
 4.02.01 | 2006/07/04 | 1) New : Add support for same clock on both sides (CLOCK_MODE)
 4.01.01 | 2006/06/30 | 1) Fix : Synchronous reset values for A_eAddr and B_eAddr
 4.00.00 | 2006/05/02 | 1) Enh : Drastically reduced combinational paths and LCells usage
---------+------------+-----------------------------------------------------------------------------------------------------------------------------------------
 3.01.06 | 2006/03/08 | 1) New : Add show-ahead support
         |            | 2) New : Add Cyclone II device family support
         |            | 3) Fix : Error condition for different data path on APEX/ACEX family
         |            | 4) Enh : Use only A_DPS for APEX/ACEX family
         |            | 5) Enh : Reduced time requiered for reset operation
         |            | 6) Chg : DEVICE values changed to "official" from ALTERA
 3.00.01 | 2006/02/24 | 1) New : Bidirectionnal buffer. "Wr" & "Rd" renamed to "A" and "B".
---------+------------+-----------------------------------------------------------------------------------------------------------------------------------------
 2.05.01 | 2006/02/22 | 1) Fix : Error message for different DPS on Apex & Acex technologies
 2.04.01 | 2006/01/06 | 1) New : LVL_FULL automatic position when set to 0
 2.03.01 | 2005/12/11 | 1) New : Ready flag for both side. It's illegal to write/read before
 2.02.01 | 2005/12/04 | 1) New : OverFlow flag for both sides
 2.01.01 | 2005/11/16 | 1) Fix : Bug in A_UsedW depending on B_DPS/A_DPS ratio
 2.00.02 | 2005/10/06 | 1) New : Add different APS & DPS for both sides
         |            | 2) Fix : Long pulse reset (keep cleared all registers)
---------+------------+-----------------------------------------------------------------------------------------------------------------------------------------
 1.03.01 | 2005/09/15 | 1) New : Add support unregistered memory on Stratix
 1.02.01 | 2005/05/20 | 1) New : Add support for Stratix family
 1.01.03 | 2005/03/30 | 1) New : Synchronous reset for both sides
         | 2005/03/30 | 2) Enh : Latency reduced for number of words
         | 2005/03/30 | 3) New : WriteFull & ReadEmpty flags
 1.00.00 | 2004/03/08 | Initial release
         |            |
----------------------------------------------------------------------------------------------------------------------------------------------------------------
¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
                                                                            Generics
¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
	* PORT_MODE
		* WO : Write Only. It's the port "Wr" from version 2.x.x and previous
		* RO : Read  Only. It's the port "Rd" from version 2.x.x and previous
		* RW : Read/Write. in this case, both ports must be configured with this setting
		       Furthermore, each port can act only in one way. User can change directionality of this buffer only when asserting reset.

	* DEVICE : see memory.vhd for supported devices

	* RD_LAT
		* 0  : FIFO is configured in show-ahead mode and always provide RdAck='0'
		* 1  : Memory block is used without register on read data path
		* 2  : Memory block is used with    register on read data path

	* LVL_FULL
		* <0 : this is the number of empty    words before claiming the FIFO full
		* >0 : this is the number of existing words before claiming the FIFO full
		* =0 : FIFO is claimed full when there is exactly 2**APS words. This is why the number of words goes from 0 to 2**N, so requires N+1 bits to encode

	* CIRCULAR
		* in this mode, write operations over a full buffer are handled (oldest data is overwritten). Because such write operation also cause the read address
		  pointer to be increased, both shall be on the same clock

	* PR_AUTO_START
		* usefull only for Partial Read operations
		* set to true  => the very first RdSkip should be done by backend (with a non null value)
		* set to false => the very first RdSkip is done automatically (with a null value)

¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
                                                                            Signals
¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
* RdAck is stucked to '0' when RD_LAT=0 to avoid dummy designer using this signal          to drive RdAck (this will create combinational loop...)

* OverFlow is set when a write operation is done on a full buffer.
	 * CIRCULAR = false => this flag is cleared only with reset (asynchronous or synchronous)
	 * CIRCULAR = true  => this flag is activated for each cycle where the oldest data is lost

¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
                                                                             Notes
¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
[Note 1] : Extra register on read data path
	+-----
	| When several memory blocks are required to create requested depth, an output multiplexor is added to choose the appropriate memory block. This
	| option allows to add extra register after memory block. It is not available for entire fifo but only for sub-elements (buffer2ck_altera and
	| buffer2ck_xilinx) because memory block may be directly used without FIFO logic (when designer manages all operations). In this case, it may be very
	| important to provide a registered read data if another combinational block follows this memory block.
	+-----

[Note 2] : Partial access
	+-----
	| Partial Write operations can only be performed on A-side
	| Partial Read  operations can only be performed on B-side
	| Number of bits inside "partial" modules is reported through a dedicated output vector
	| When a partial access module is connected, this removed the ability to reverse data flow (A is stuck to write access, B is stuck to read access)
	| See [Note 6] & [Note 7] => DPS shall be equal to 2^n (RAW_DPS is not supported)
	+-----

[Note 3] : Partial Write
	+-----
	| All write operations are done exclusively with A_WrQnt input. A_WrReq shall not be used
	| See [Note 6] & [Note 7] => DPS shall be equal to 2^n (RAW_DPS is not supported)
	|
	| As detailled in "Typical ressources usage" section, this module requires huge amount of LUTs to create all multiplexors.
	| It's very important to set the highest possible (with design constraints) value on PW_ALIGN to reduce multiplexors quantity
	|
	| +-----+----------+---------------+------------+---------------------+------+---------------------+------+
	| | DPS | PW_ALIGN | PW_ALIGN_SIDE |   Target   | Combinational ALUTs | ALMs | Dedicated Registers | Fmax*|
	| +-----+----------+---------------+------------+---------------------+------+---------------------+------+
	| | 128 |    8     |     left      | Strativ IV |        1138         | 761  |         253         | 287  |
	| |     |          |               |            |                     |      |                     |      |
	| +-----+----------+---------------+------------+---------------------+------+---------------------+------+
	|
	|  * Fmax (MHz) in providen by "Slow 900mV 85C Model" (worst case)
	+-----

[Note 4] : Partial Read
	+-----
	| All read operations are done exclusively with B_RdSkipBit input. B_RdReq shall not be used
	| See [Note 6] & [Note 7] => DPS shall be equal to 2^n (RAW_DPS is not supported)
	|
	| 1) external read latency is NOT configurable (show-ahead mode is mandatory and automatically set by internal logic)
	| 2) all read operations shall be done through RdSkip (RdReq shall NOT be used)
	| 3) RdSkip values
	|    a) shall be coherent / aligned with PR_ALIGN
	|    b) the very first value may be greater than a word (usefull to skip several words) *** warning ***
	|    c) subsequent values shall be from 0 up to a single word, never more
	| 4) operation "3b" will :
	|    a) start read memory sequence
	|    b) load the first word to partial read module (with correct alignment)
	|    c) set the ready flag
	|
	| Following ports are not supported in this mode :
	|    * Clock Enable
	|    * Byte Enable
	|
	| *** warning *** : PR_AUTO_START should be set to false here. If PR_AUTO_START is set to true, the (3b) is automatically set with a null value
	+-----

[Note 5] : Number of bits/bytes/words and Read Latency (Show-Ahead and regular modes)
	+-----
	| Show-Ahead mode
	|    * For Write-side, number of bits is without extra delay
	|    * For Read-side, write pointer is delayed of two clock cycles, in order to ensure control is not "faster" than internal memory
	|    * B_UsedBit and derived are used
	|
	| Regular modes (non Show-Ahead) with Single clock mode
	|    * A_UsedBit is used instead of B_UsedBit, in order to reduce physical ressources usage
	+-----

[Note 6] : Number of bits/words that are destroyed by circular mode
	+-----                                            ¯¯¯¯¯¯¯¯¯¯¯¯¯
	| It's very important to keep in mind that circular mode is only supported in SINGLE clock mode
	| If datapath is standard (that is DPS=2^n), user and internal logic can manage at bit granularity because it's possible to have 1 word = (2^i) * (2^j) bits
	| But if datapath is in raw mode (DPS/=2^n), we can't have anymore 1 word = (2^i)*(2^j) bits. For example, consider the following configuration :
	|    RAW_DPS = true, A_DPS=B_DPS=151 (both sides shall have the same size). But 151 is a prime number. It's clear that such word cannot be splitted in
	| smaller atoms. So, in circular mode with RAW_DPS=true, only 0 or 1 word can be destroyed, and only one bit is required to transmit this command.
	+-----

[Note 7] : RdSkip of bits/words and RAW_DPS
	+-----
	| Please carefully read [Note 6] considerations
	| As with the number of bits/words destroyed, the RdSkip command cannot be in BIT with DPS/=2^n. So :
	|    * x_RdSkipBit  is only taken into account when RAW_DPS = false
	|    * x_RdSkipWord is only taken into account when RAW_DPS = true
	+-----

[Note 8] : RdSkip of bits/words and Dual clock
	+-----
	| Since 7.02.01, RdSkipBit & RdSkipWord are allowed in dual clock mode. Because some coherency tests cannot be done for RTL, it's HIGHLY recommended to :
	|    * determine L_CLOCK = the worst possible clock ratio, round up to next integer. If A_Clk=150MHz & B_Clk=49MHz, L_CLOCK = 4
	|    * take into account Partial Write Configuration (L_PARTIAL_WRITE = 3 if enabled, else 0)
	|    * take into account Partial Read  Configuration (L_PARTIAL_READ  = 5 if enabled, else 0)
	|    * always stay at least at (2*L_CLOCK + L_PARTIAL_WRITE + L_PARTIAL_READ + 1) full words from empty/full internal memory
	|
	| Outside this limit, please keep in mind that nothing can be guaranteed.
	+-----                                         ¯¯¯¯¯¯¯        ¯¯¯¯¯¯¯¯¯¯

Idées !!!!

1) Pour l'extraction multiple (x_RdSkip) sur deux domaines d'horloge, inhiber l'acquisition du compteur de Gray durant cette période. Actuellement,
	l'acquisition du code de Gray se fait sur chaque cycle d'horloge.
	a) L'inhibition permettrait de masquer les multiples commutations de bits du code de Gray ==> se raporter à deux flags
		* le premier toggle de "STOP"
		* le second  toggle de "START"
	b) Un seul toggle ne suffit pas car si l'horloge de destination est beaucoup plus lente que la source, le toggle aurait éventuellement le temps de revenir
	    à sa position d'origine.
	c) La source ne met à jour le code de Gray que si la destination n'est pas en "BUSY" (entre le STOP et le START); toujours pour palier un ratio important
	   entre les deux horloges ainsi qu'un second RdSkip de l'horloge rapide avant que le premier n'ait été totalement traité par la source...

¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
                                                                    Typical ressources usage
¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

Only changes are reported
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                 Partial Read  / Align = 32 -------------------------\
                 Partial Read  / Align =  8 -----------------\       |
                 Partial Write / Align = 32 ---------\       |       |
                 Partial Write / Align =  8 --\      |       |       |
                 B_LAT_RD_ADDR=0 -------\     |      |       |       |
                                        |     |      |       |       |
                                        |     |      |       |       |
                   Regular     Dual     V     V      V       V       V
+---------------+------------+------+------+------+------+-------+-------+
|A_APS          |   7        |      |      |      |      |       |       |
|A_DPS          | 128        |      |      |      |      |       |       |
|A_LAT_RD_ADDR  |   1        |      |      |      |      |       |       |
|A_LAT_RD_DATA  |   2        |      |      |      |      |       |       |
|A_LVL_FULL     |   0        |      |      |      |      |       |       |
|A_MODE         |  WO        |      |      |      |      |       |       |
|B_APS          |   7        |      |      |      |      |       |       |
|B_DPS          | 128        |      |      |      |      |       |       |
|B_LAT_RD_ADDR  |   1        |      |   0  |      |      |       |       |
|B_LAT_RD_DATA  |   2        |      |      |      |      |   0   |   0   |
|B_LVL_FULL     |   0        |      |      |      |      |       |       |
|B_MODE         |  RO        |      |      |      |      |       |       |
|BYTE_MODE      |   8        |      |      |      |      |       |       |
|CLOCK_MODE     | Single     | Dual |      |  S	  |  S   |   S   |   S   |
|DEVICE         | Stratix IV |      |      |      |      |       |       |
|PR_ALIGN       |   1        |      |      |      |      |   8   |   32  |
|PR_AUTO_START  | false      |      |      |      |      | false | false |
|PR_ENABLE      | false      |      |      |      |      | true  | true  |
|PW_ALIGN       | N/A        |      |      |   8  |  32  |       |       |
|PW_ENABLE      | false      |      |      | true | true |       |       |
|RAM_BLOCK_TYPE | AUTO       |      |      |      |      |       |       |
|RAW_DPS        | false      |      |      |      |      |       |       |
|SEND_FLAG      | false      |      |      |      |      |       |       |
|USE_BE         | false      |      |      |      |      |       |       |
|               |            |      |      |      |      |       |       |
|LUTs           |  132       |  149 |  155 | 1291 |  271 |  446  |  314  |
|Regs           |   72       |  146 |   72 |  317 |  291 |  395  |  387  |
|RAM            | 2 M9K      |      |      |      |      |       |       |
+---------------+------------+------+------+------+------+-------+-------+

Partial Read module is written in such way that P&R can merge a data wide register with memory. Registers usage is the final value (AFTER P&R)
All Fmax are 300MHz ± 20 MHz and based to slow model at high temperature (worst case)

--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- Turn off superfluous VHDL processor warnings
-- xxx_altera message_level xxx_Level1
-- altera message_off 10036
--
-- List of masked warnings
-- 10036 : Verilog HDL or VHDL warning at <location>: object "name" assigned a value but never read
----------------------------------------------------------------------------------------------------------------------------------------------------------------

--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--**************************************************************************************************
-- Local Address Bit
--**************************************************************************************************
library ieee;
use     ieee.std_logic_1164.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

entity buffer2ck_LclAddrBit is generic
	( CIRCULAR          : boolean                                         := false       -- Circular mode for write operations
	; I_APS             : natural                                         :=  8          -- Address Path Size
	; I_DPS             : natural                                         := 16          -- Data    Path Size
	; I_LAT_RD_ADDR     : integer range 0 to 1                            :=  1          -- 0 : memory read address bus is combinational / 1 : memory read address bus is registered
	; U_DPS             : natural                                         := 32          -- Data    Path Size
	); port                                                                              --
	( I_Dmn             : in  domain                                                     -- Reset/clock/clock enable
	; I_sRst            : in  sl                                                         -- Synchronous reset
	; I_LclAddrBit      : out slv(I_APS+Log2(I_DPS)             downto 0)                -- "True" memory pointer address, BIT  pointer (comb/reg according to I_LAT_RD_ADDR)
	; I_LclAddrBit_c    : out slv(I_APS+Log2(I_DPS)             downto 0)                -- "True" memory pointer address, BIT  pointer (combinational value)
	; I_LclAddrBit_r    : out slv(I_APS+Log2(I_DPS)             downto 0)                -- "True" memory pointer address, BIT  pointer (registered    value)
	; I_ModeRead        : in  sl                                                         -- This side is in Read     Mode
	; I_ModeWrite       : in  sl                                                         -- This side is in Write    Mode
	; I_RdSkipBit       : in  slv(I_APS+Log2(I_DPS)             downto 0)                -- Number of BIT  to read-skip
	; I_WrReq           : in  sl                                                         -- Write Request                   . Available only when PW_ENABLE = false
	; I_iRdReq          : in  sl                                                         -- Internal Read Request (special handling for Show-Ahead mode)
	; U_RdDestroyBit    : in  slv(Log2(U_DPS)                   downto 0)                -- Number of BIT  to destroy (circular mode, DPS =2^n                                         )
	; pw_WrReq          : in  sl                                                         -- Partial Write / Memory write request (full data)
	);
end entity buffer2ck_LclAddrBit;

architecture rtl of buffer2ck_LclAddrBit is
	signal          c_AddrBit_CircularNO  : slv(I_APS+Log2(I_DPS) downto 0);
	signal          c_AddrBit_CircularYES : slv(I_APS+Log2(I_DPS) downto 0);
	signal          AddrBit_r             : slv(I_LclAddrBit_r'range      ); -- "True" memory pointer address, BIT  pointer (registered    value)
	signal          AddrBit_c             : slv(I_LclAddrBit_c'range      ); -- "True" memory pointer address, BIT  pointer (combinational value)
begin

assert 2**Log2(I_DPS)=I_DPS
	report "[buffer2ck] : I_DPS is not a power of 2 !!"
	severity failure;

p0 : process(all)
	variable v_AddrBit : slv(I_LclAddrBit_r'range); -- "True" memory pointer address, BIT  pointer (combinational value)
begin
	-- Start from registered value
	v_AddrBit := AddrBit_r;

	-- Add Number of BIT  to read-skip
	v_AddrBit := v_AddrBit + I_RdSkipBit;

	-- Read or Write request
	if CIRCULAR then v_AddrBit := v_AddrBit + c_AddrBit_CircularYES;
	else             v_AddrBit := v_AddrBit + c_AddrBit_CircularNO ; end if;

	-- Synchronous reset
	if I_sRst='1' then v_AddrBit := (others=>'0'); end if;

	AddrBit_c <= v_AddrBit;
end process p0;

p1 : process(I_Dmn)
begin
if I_Dmn.rst='1' then
	AddrBit_r <= (others=>'0');
elsif I_Dmn.ena='0' then null;
elsif rising_edge(I_Dmn.clk) then
	AddrBit_r <= AddrBit_c;
end if;
end process p1;

-- WARNING !!!!
--          This is NOT I_RdReq !!! This signal takes into account show-ahead specific combinational logic  ----------\
--                  ¯¯¯                                                                                               |
--                                                                                                                    v
-- WARNING !!!!
c_AddrBit_CircularYES <= conv_slv(Maxi(I_DPS,U_RdDestroyBit),c_AddrBit_CircularYES'length) when (I_ModeRead='1' and I_iRdReq='1') or (I_ModeWrite='1' and I_WrReq='1') or pw_WrReq='1' else Extend0L(U_RdDestroyBit,c_AddrBit_CircularYES'length);
c_AddrBit_CircularNO  <= conv_slv(     I_DPS                ,c_AddrBit_CircularNO 'length) when (I_ModeRead='1' and I_iRdReq='1') or (I_ModeWrite='1' and I_WrReq='1') or pw_WrReq='1' else (others=>'0');

-- Choose between combinational and registered versions
I_LclAddrBit   <= AddrBit_c when I_LAT_RD_ADDR=0 and I_ModeRead='1' else
                  AddrBit_r;

-- Drive outputs
I_LclAddrBit_r <= AddrBit_r;
I_LclAddrBit_c <= AddrBit_c;

end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--**************************************************************************************************
-- Local Address Word
--**************************************************************************************************
library ieee;
use     ieee.std_logic_1164.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

entity buffer2ck_LclAddrWord is generic
	( CIRCULAR          : boolean                                         := false       -- Circular mode for write operations
	; I_APS             : natural                                         :=  8          -- Address Path Size
	); port
	( I_Dmn             : in  domain                                                     -- Reset/clock/clock enable
	; I_sRst            : in  sl                                                         -- Synchronous reset
	; I_LclAddrWord_c   : out slv(I_APS                         downto 0)                -- "True" memory pointer address, WORD pointer (combinational value)
	; I_LclAddrWord_r   : out slv(I_APS                         downto 0)                -- "True" memory pointer address, WORD pointer (registered    value)
	; I_ModeRead        : in  sl                                                         -- This side is in Read     Mode
	; I_ModeWrite       : in  sl                                                         -- This side is in Write    Mode
	; I_RdSkipWord      : in  slv(I_APS                         downto 0)                -- Number of WORD to read-skip
	; I_WrReq           : in  sl                                                         -- Write Request                   . Available only when PW_ENABLE = false
	; I_iRdReq          : in  sl                                                         -- Internal Read Request (special handling for Show-Ahead mode)
	; U_RdDestroyWord   : in  sl                                                         -- Number of WORD to destroy (circular mode, DPS/=2^n -> can only destroy 1 word, see [Note 6])
	; pw_WrReq          : in  sl                                                         -- Partial Write / Memory write request (full data)
	);
end entity buffer2ck_LclAddrWord;

architecture rtl of buffer2ck_LclAddrWord is
	signal          c_AddrWord_CircularNO  : sl;
	signal          c_AddrWord_CircularYES : sl;
	signal          AddrWord_c             : slv(I_LclAddrWord_c'range);
	signal          AddrWord_r             : slv(I_LclAddrWord_r'range);
begin

p0 : process(all)
	variable v_AddrWord : slv(I_LclAddrWord_r'range); -- "True" memory pointer address, WORD pointer (combinational value)
begin
	-- Start from registered value
	v_AddrWord := AddrWord_r;

	-- Add number of Words to read-skip
	v_AddrWord := v_AddrWord + I_RdSkipWord;

	-- Read or Write request
	if CIRCULAR then v_AddrWord := v_AddrWord + c_AddrWord_CircularYES;
	else             v_AddrWord := v_AddrWord + c_AddrWord_CircularNO ; end if;

	-- Synchronous reset
	if I_sRst='1' then v_AddrWord := (others=>'0'); end if;

	AddrWord_c <= v_AddrWord;
end process p0;

p1 : process(I_Dmn)
begin
if I_Dmn.rst='1' then
	AddrWord_r <= (others=>'0');
elsif I_Dmn.ena='0' then null;
elsif rising_edge(I_Dmn.clk) then
	AddrWord_r <= AddrWord_c;
end if;
end process p1;

-- WARNING !!!!
--                                                         /--------- This is NOT I_RdReq !!! This signal takes into account show-ahead specific combinational logic
--                                                         |                  ¯¯¯
--                                                         v
c_AddrWord_CircularYES <= '1' when (I_ModeRead='1' and I_iRdReq='1') or (I_ModeWrite='1' and I_WrReq='1') or pw_WrReq='1' else U_RdDestroyWord;
c_AddrWord_CircularNO  <= '1' when (I_ModeRead='1' and I_iRdReq='1') or (I_ModeWrite='1' and I_WrReq='1') or pw_WrReq='1' else '0';

-- Drive outputs
I_LclAddrWord_r <= AddrWord_r;
I_LclAddrWord_c <= AddrWord_c;

end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--**************************************************************************************************
-- Overflow
--**************************************************************************************************
library ieee;
use     ieee.std_logic_1164.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

entity buffer2ck_overflow is generic
	( CIRCULAR          : boolean                                                        -- Circular mode for write operations
	; I_DPS             : natural                                                        -- Data    Path Size
	; U_DPS             : natural                                                        -- Data    Path Size
	); port                                                                              --
	( I_Dmn             : in  domain                                                     -- Reset/clock/clock enable
	; I_sRst            : in  sl                                                         -- Synchronous reset
	; I_iFull	        : in  sl                                                         -- Full
	; I_WrReq           : in  sl                                                         -- Write Request                   . Available only when PW_ENABLE = false
	; U_iOverFlow_r	    : in  sl                                                         -- Overflow, on U side
	; U_RdReq           : in  sl                                                         -- Read Request
	; I_OverFlow        : out sl                                                         -- Buffer has encountered an OverFlow  since last synchronous reset
	);
end entity buffer2ck_overflow;

architecture rtl of buffer2ck_overflow is
begin

main : process(I_Dmn)
begin
if I_Dmn.rst='1' then
	I_OverFlow <= '0';
elsif I_Dmn.ena='0' then null;
elsif rising_edge(I_Dmn.clk) then
	if not(CIRCULAR) then
		if I_sRst='1'                                                                                 then I_OverFlow <= '0';
		elsif (I_iFull='1' and I_WrReq='1') or U_iOverFlow_r='1'                                      then I_OverFlow <= '1'; end if;
	else
		if I_sRst='1'                                                                                 then I_OverFlow <= '0';
		elsif (I_iFull='1' and I_WrReq='1' and not(I_DPS=U_DPS and U_RdReq='1')) or U_iOverFlow_r='1' then I_OverFlow <= '1';
		else                                                                                               I_OverFlow <= '0'; end if;
	end if;
end if;
end process main;

end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--**************************************************************************************************
-- Underflow
--**************************************************************************************************
library ieee;
use     ieee.std_logic_1164.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

entity buffer2ck_underflow is generic
	( CLOCK_MODE      : string                                                         -- "Single" / "Dual"
	); port                                                                            --
	( I_Dmn           : in  domain                                                     -- Reset/clock/clock enable
	; I_sRst          : in  sl                                                         -- Synchronous reset
	; I_iEmpty        : in  sl                                                         -- Empty
	; I_RdReq         : in  sl                                                         -- Read Request from THIS  side
	; U_RdReq         : in  sl                                                         -- Read Request from OTHER side
	; U_iUnderFlow_r  : in  sl                                                         -- UnderFlow from OTHER side, already resynchronized
	; I_UnderFlow     : out sl                                                         -- Buffer has encountered an UnderFlow since last synchronous reset
	);
end entity buffer2ck_underflow;

architecture rtl of buffer2ck_underflow is
begin

main : process(I_Dmn)
begin
if I_Dmn.rst='1' then
	I_UnderFlow <= '0';
elsif I_Dmn.ena='0' then null;
elsif rising_edge(I_Dmn.clk) then
	if I_sRst='1' then
		I_UnderFlow <= '0';
	elsif U_iUnderFlow_r='1'                                           -- UnderFlow from other side
	or   (I_iEmpty='1' and I_RdReq='1'                               ) -- Read request from THIS  side with an empty buffer
	or   (I_iEmpty='1' and U_RdReq='1' and StrEq(CLOCK_MODE,"Single")) -- Read request from OTHER side with an empty buffer (only available on signel clock mode)
	then
		I_UnderFlow <= '1';
	end if;
end if;
end process main;

end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--**************************************************************************************************
-- Read / Show-Ahead / Full wide data access
--**************************************************************************************************
library ieee;
use     ieee.std_logic_1164.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

entity buffer2ck_rd_lat_0_full is generic
	( I_APS             : natural                                          :=  8         -- Address Path Size
	; I_DPS             : natural                                          := 16         -- Data    Path Size
	; USE_BE            : boolean                                          := false      -- Save ByteEnable inside fifo
	); port                                                                              --
	( I_Dmn             : in  domain                                                     -- Reset/clock/clock enable
	; c_UsedWord        : in  slv(I_APS                       downto 0)                  -- Number of words
	; I_iRdReq          : out sl                                                         -- Internal Read Request (special handling for Show-Ahead mode)
	; I_MemRdBE         : in  slv(Maxi(I_DPS/8        -1,0)   downto 0)                  -- Physical Memory / Read Byte Enable
	; I_MemRdData       : in  slv(I_DPS   -1                  downto 0)                  -- Physical Memory / Read Data
	; I_ModeRead        : in  sl                                                         -- This side is in Read     Mode
	; I_RdAck           : out sl                                                         -- Read Acknowledge
	; I_RdBe            : out slv(Maxi(I_DPS/8        -1,0)   downto 0)                  -- Read ByteEnable
	; I_RdData          : out slv(     I_DPS          -1      downto 0)                  -- Read Data
	; I_RdReq           : in  sl                                                         -- Read Request
	; I_sRst            : in  sl                                                         -- Synchronous reset
	);
end entity buffer2ck_rd_lat_0_full;

architecture rtl of buffer2ck_rd_lat_0_full is
	signal          I_MemRdData_r    : slv(     I_DPS  -1    downto 0); -- ReadData from memory, one clock cycle delayed
	signal          I_MemRdBE_r      : slv(Maxi(I_DPS/8-1,0) downto 0); -- ReadBE   from memory, one clock cycle delayed
	signal          I_MemRdVal       : sl                             ; -- ReadData from memory is valid
	signal          I_MemRdVal_r     : sl                             ; -- ReadData from memory is valid (one clock cycle delayed)
	signal          I_iRdReq_i       : sl                             ; -- Internal Read Request (special handling for Show-Ahead mode)
begin

process(all)
begin
	-- Auto-start extracting data from memory
	if I_ModeRead='1'                             then
		if c_UsedWord=0                           then I_iRdReq_i <= '0';             -- Fifo is empty. Do not extract (Version 5.04.10)
		elsif I_MemRdVal='0' and I_MemRdVal_r='0' then I_iRdReq_i <= '1';             -- Fifo contains at least one word and external register is empty --> get data from memory
		else                                           I_iRdReq_i <= I_RdReq; end if; -- Transmit Read Request
	else                                               I_iRdReq_i <= '0';             -- Not configured for read operations
	end if;

	if I_MemRdVal_r='1' then I_RdData <= I_MemRdData_r; I_RdBe <= I_MemRdBE_r;
	else                     I_RdData <= I_MemRdData  ; I_RdBe <= I_MemRdBE  ; end if;

	-- Force ByteEnable to active when not using them
	if not(USE_BE) then
		I_RdBe <= (others=>'1');
	end if;
end process;

I_iRdReq <= I_iRdReq_i;
I_RdAck  <= '0';

process(I_Dmn)
begin
if I_Dmn.rst='1' then
	I_MemRdVal    <=          '0' ;
	I_MemRdVal_r  <=          '0' ;
	I_MemRdData_r <= (others=>'0');
	I_MemRdBE_r   <= (others=>'0');
elsif rising_edge(I_Dmn.clk) then
	if I_MemRdVal='1' then
		-- Transfer Level1 to Level2
		I_MemRdData_r <= I_MemRdData;
		I_MemRdBE_r   <= I_MemRdBE  ;
	end if;

	-- Data management
	if I_sRst='1' then
		                                          I_MemRdVal   <=        '0';
		                                          I_MemRdVal_r <=        '0';
	else
		                                          I_MemRdVal   <= I_iRdReq_i;
		   if I_MemRdVal='1' and I_RdReq='0' then I_MemRdVal_r <=        '1';         -- Level1 will be copied to Level2 (no data request)
		elsif I_MemRdVal='0' and I_RdReq='1' then I_MemRdVal_r <=        '0'; end if; -- Level1 is empty and Level2 is extracted --> Level2 will be empty
	end if;

end if;
end process;

end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--**************************************************************************************************
-- Read / Show-Ahead / Partial read data access
--**************************************************************************************************
library ieee;
use     ieee.std_logic_1164.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

entity buffer2ck_rd_lat_0_partial_start0 is generic
	( I_APS             : natural                                          :=  8         -- Address Path Size
	; I_DPS             : natural                                          := 16         -- Data    Path Size
	; PR_ALIGN          : int                                              :=  8         -- Partial Read  / Granularity for number of bits to read
	; PR_ALIGN_SIDE     : string                                           := "right"    -- Partial Read  / Data ouput is right aligned
	); port
	( I_Dmn             : in  domain                                                     -- Reset/clock/clock enable
	; I_iMemAddr        : in  slv(I_APS                       downto 0)                  -- Physical Memory / Address
	; I_iRdReq          : out sl                                                         -- Internal Read Request (special handling for Show-Ahead mode)
	; I_LclAddrBit      : in  slv(I_APS+Log2(I_DPS)           downto 0)                  -- "True" memory pointer address, BIT  pointer (comb/reg according to I_LAT_RD_ADDR)
	; I_MemRdData       : in  slv(I_DPS   -1                  downto 0)                  -- Physical Memory / Read Data
	; I_RdAck           : out sl                                                         -- Read Acknowledge
	; I_RdBe            : out slv(Maxi(I_DPS/8        -1,0)   downto 0)                  -- Read ByteEnable
	; I_RdData          : out slv(     I_DPS          -1      downto 0)                  -- Read Data
	; I_RdSkipBit       : in  slv(I_APS+Log2(I_DPS)           downto 0)                  -- Number of BIT  to read-skip
	);
end entity buffer2ck_rd_lat_0_partial_start0;

architecture rtl of buffer2ck_rd_lat_0_partial_start0 is
/*
Partial-Read operations are only supported on B-side for regular buffer2ck (Write on A, Read on B)

Number of bits stored is this stage is providen through the value of internal aligner. It's the backend responsability to determine how many bits are really available
Before doing the very first access, the two-level stack is empty
After having done the first access, the two-level stack is full and there are 2*I_DPS - PR_ALIGN * pos_mux bits available

                                   stack0     stack1                 B_RdData
                                    +---+      +---+      |\          +---+
                                    |bbb|      |   |      | \         |aaa|
                                    |bbb|      |   |  . . |  \        |aaa|
                                    |bbb|      |   |      |   |       |aaa|
                                    +---+      +---+  . . |   |       +---+
                                    |ccc|      |   |      |   |       |bbb|
                     +-------+      |ccc|      |   |  . . |   |       |bbb|
        Write        |       |      |ccc|      |   |      |   |       |bbb|
     ------------->  |  RAM  | ---> +---+ ---> +---+  . . |   | --->  +---+         Example :
                     |       |      |ddd|      |   |      |   |       |ccc|            * PR_ALIGN = B_DPS/4
                     +-------+      |ddd|      |   |  . . |   |       |ccc|            * internal aligner = 3
                                    |ddd|      |   |      |   |       |ccc|
                                    +---+      +---+  . . |   |       +---+
                                    |   |      |aaa|      |   |       |ddd|
                                    |   |      |aaa|  . . |  /        |ddd|
                                    |   |      |aaa|      | /         |ddd|
                                    +---+      +---+      |/          +---+
*/
	type StackType is record
		Data     : slv128;
		AddrWord : slv(I_APS downto 0); -- Help for simulation
	end record StackType;

	constant        STACKTYPE_RST      : StackType                            := StackType'(Data=>(others=>'0'),AddrWord=>(others=>'0'));

	signal          stack_0            : StackType                                                                                      ;
	signal          stack_1            : StackType                                                                                      ;
	signal          data_shift         : slv(2*I_DPS             -1 downto 0)                                                           ;
	signal          addr_align         : slv(Log2(I_DPS/PR_ALIGN)-1 downto 0)                                                           ;
	signal          addr_align_r1      : slv(Log2(I_DPS/PR_ALIGN)-1 downto 0)                                                           ;
	signal          addr_align_r2      : slv(Log2(I_DPS/PR_ALIGN)-1 downto 0)                                                           ;
	signal          addr_align_r3      : slv(Log2(I_DPS/PR_ALIGN)-1 downto 0)                                                           ;
	signal          addr_align_r4      : slv(Log2(I_DPS/PR_ALIGN)-1 downto 0)                                                           ;
	signal          I_MemAddr_r        : slv(I_APS                  downto 0)                                                           ;
	signal          chgd_addr          : sl                                                                                             ;
	signal          I_RdSkipBit_neq0_s : slv5                                                                                           ;
begin

	process(I_Dmn)
	begin
	if I_Dmn.rst='1' then
		addr_align_r1       <= (others=>'0');
		addr_align_r2       <= (others=>'0');
		addr_align_r3       <= (others=>'0');
		addr_align_r4       <= (others=>'0');
		chgd_addr           <=          '0' ;
		I_MemAddr_r         <= (others=>'0');
		I_RdAck             <=          '0' ;
		I_RdData            <= (others=>'0');
		I_RdSkipBit_neq0_s  <= (others=>'0');
		stack_0             <= STACKTYPE_RST;
		stack_1             <= STACKTYPE_RST;
	elsif rising_edge(I_Dmn.clk) then
		-- Misc delay lines
		I_MemAddr_r   <= I_iMemAddr   ;
		addr_align_r1 <= addr_align   ;
		addr_align_r2 <= addr_align_r1;
		addr_align_r3 <= addr_align_r2;
		addr_align_r4 <= addr_align_r3;

		-- Detect address changes in order to update stack
		chgd_addr <= conv_sl(I_iMemAddr/=I_MemAddr_r);

		-- Update stack on each new data
		if chgd_addr='1' then
			stack_0.Data     <= I_MemRdData;
			stack_0.AddrWord <= I_MemAddr_r;
			stack_1          <= stack_0;
		end if;

		/*
		OK, let's have a small explaination about this extreme top notch high level equation...
		The traditional method should be to describe all 'addr_align_r4' values with a case and to replace each of them with its own numerical value.
		This is the best way : hard, low level, clean, no escape for synthesis tool !
		Just for the fun, I tryed to describe these equations with the '*' operation. And what's the hell, I got exactly the same LUTs / Regs / RTL view !!! :)
		This wonderfull thing has been done with QuartusII 64-Bit 12.1 Build 243 01/31/2013 SJ Full Version with Service Pack Installed : 1.dp4
		I can NOT guarantee that it is OK with previous version or others synthesis tools...
		*/
		if StrEq(PR_ALIGN_SIDE,"right") then I_RdData <= data_shift(  I_DPS+conv_int(addr_align_r4)*PR_ALIGN-1 downto     0+conv_int(addr_align_r4)*PR_ALIGN);         -- Data output is RIGHT aligned
		else                                 I_RdData <= data_shift(2*I_DPS-conv_int(addr_align_r4)*PR_ALIGN-1 downto I_DPS-conv_int(addr_align_r4)*PR_ALIGN); end if; -- Data output is LEFT  aligned

		-- Create read latency / acknowledge
		I_RdSkipBit_neq0_s <= ExcludeMSB(I_RdSkipBit_neq0_s) & conv_sl(I_RdSkipBit/=0);
		I_RdAck            <= I_RdSkipBit_neq0_s(3);
	end if;
	end process;

	addr_align <= I_LclAddrBit(Log2(I_DPS)-1 downto Log2(PR_ALIGN));

	data_shift <= stack_0.Data & stack_1.Data when StrEq(PR_ALIGN_SIDE,"right") else -- Data output is RIGHT aligned
	              stack_1.Data & stack_0.Data;                                       -- Data output is LEFT  aligned

	I_iRdReq   <= '0';
	I_RdBe     <= (others=>'1');
end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--**************************************************************************************************
-- Ready
--**************************************************************************************************
library ieee;
use     ieee.std_logic_1164.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

entity buffer2ck_Ready is generic
	( ID_I              : string                                                         -- "A" / "B"
	; ID_U              : string                                                         -- "A" / "B"
	; I_APS             : natural                                                        -- Address Path Size
	; I_DPS             : natural                                                        -- Data    Path Size
	; U_APS             : natural                                                        -- Address Path Size
	; U_DPS             : natural                                                        -- Data    Path Size
	; PW_ENABLE         : boolean                                                        -- Partial Write / Enable this kind of operations
	; PR_ENABLE         : boolean                                       := false         -- Partial Read  / Enable this kind of operations
	); port                                                                              --
	( I_Dmn             : in  domain                                                     -- Reset/clock/clock enable
	; I_sRst            : in  sl                                                         -- Synchronous reset
	; I_LclAddrBit      : in  slv(I_APS+Log2(I_DPS)        downto 0)                     -- "True" memory pointer address, BIT  pointer (comb/reg according to I_LAT_RD_ADDR)
	; U_UsrAddrBit      : in  slv(U_APS+Log2(U_DPS)        downto 0)                     -- User   BIT  address pointer, binary for Single clock, gray for Dual clock
	; I_Ready           : out sl                                                         -- Buffer is ready to operate (cleared on reset)
	);
end entity buffer2ck_Ready;

architecture rtl of buffer2ck_Ready is
	signal          I_ok : sl;
	signal          U_ok : sl;
begin

I_ok <= '1' when msb(I_LclAddrBit,I_APS+1)=0 and ID_I="A" and not(PW_ENABLE) else -- This side is A and "Partial Write"=OFF => check only 'word' part
        '1' when msb(I_LclAddrBit,I_APS+1)=0 and ID_I="B" and not(PR_ENABLE) else -- This side is B and "Partial Read" =OFF => check only 'word' part
        '1' when     I_LclAddrBit         =0;                                     -- Partial access enabled

U_ok <= '1' when msb(U_UsrAddrBit,U_APS+1)=0 and ID_U="A" and not(PW_ENABLE) else -- This side is A and "Partial Write"=OFF => check only 'word' part
        '1' when msb(U_UsrAddrBit,U_APS+1)=0 and ID_U="B" and not(PR_ENABLE) else -- This side is B and "Partial Read" =OFF => check only 'word' part
        '1' when     U_UsrAddrBit         =0;                                     -- Partial access enabled

main : process(I_Dmn)
begin
if I_Dmn.rst='1' then
	I_Ready <= '0';
elsif I_Dmn.ena='0' then null;
elsif rising_edge(I_Dmn.clk) then
	   if I_sRst='1'                        then I_Ready <= '0';
	elsif I_LclAddrBit=0 and U_UsrAddrBit=0 then I_Ready <= '1'; end if;
end if;
end process main;

end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--**************************************************************************************************
-- User Address Bit management
--**************************************************************************************************
library ieee;
use     ieee.std_logic_1164.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

entity buffer2ck_UserAddrBit is generic
	( CLOCK_MODE        : string                                                         -- "Single" / "Dual"
	; I_APS             : natural                                       :=  8            -- Address Path Size
	; I_DPS             : natural                                       := 16            -- Data    Path Size
	; PR_ENABLE         : boolean                                       := false         -- Partial Read  / Enable this kind of operations
	; PW_ENABLE         : boolean                                                        -- Partial Write / Enable this kind of operations
	); port
	( I_Dmn             : in  domain                                                     -- Reset/clock/clock enable
	; I_sRst            : in  sl                                                         -- Synchronous reset
	; I_WrReq           : in  sl                                                         -- Write Request                   . Available only when PW_ENABLE = false
	; I_RdReq           : in  sl                                                         -- Read Request
	; I_iMemAddr        : in  slv(I_APS                       downto 0)                  -- Physical Memory / Address
	; I_UsrAddrBit      : out slv(I_APS+Log2(I_DPS)           downto 0)                  -- User   BIT  address pointer, binary for Single clock, gray for Dual clock
	; c_UsrAddrBitNext  : out slv(I_APS+Log2(I_DPS)           downto 0)                  -- User   address / next value
	);
end entity buffer2ck_UserAddrBit;

architecture rtl of buffer2ck_UserAddrBit is
	signal          I_iUsrAddrBit      : slv(I_APS+Log2(I_DPS)           downto 0); -- "User" memory pointer address. May be different that "memory" pointer
	signal          c_UsrAddrBitNext_i : slv(I_APS+Log2(I_DPS)           downto 0); -- User   address / next value
begin

access_full : if not(PR_ENABLE) and not(PW_ENABLE) generate
begin
	p0 : process(all)
		variable incr : slv(c_UsrAddrBitNext'range); -- User   address / next value
	begin
		if I_RdReq='1' or I_WrReq='1' then incr := conv_slv(I_DPS,incr'length);
		else                               incr := (others=>'0'); end if;

		-- Manage "user" pointer (number of read data).
		   if I_sRst='1' then c_UsrAddrBitNext_i <= (others=>'0');                 -- Reset
		else                  c_UsrAddrBitNext_i <= I_iUsrAddrBit + incr; end if;  -- Take into account Read or Write request
	end process p0;
end generate access_full;

access_partial : if PR_ENABLE or PW_ENABLE generate
begin
	c_UsrAddrBitNext_i <= Extend0R(I_iMemAddr,c_UsrAddrBitNext_i'length);
end generate access_partial;

c_UsrAddrBitNext <= c_UsrAddrBitNext_i;

p1 : process(I_Dmn)
begin
if I_Dmn.rst='1' then
	I_iUsrAddrBit <= (others=>'0');
elsif I_Dmn.ena='0' then null;
elsif rising_edge(I_Dmn.clk) then
	I_iUsrAddrBit <= c_UsrAddrBitNext_i;
end if;
end process p1;

I_UsrAddrBit_bin : if StrEq(CLOCK_MODE,"Single") generate
begin
	I_UsrAddrBit <= c_UsrAddrBitNext_i;
end generate I_UsrAddrBit_bin;

I_UsrAddrBit_gray : if StrEq(CLOCK_MODE,"Dual") generate
	signal          gray : slv(I_UsrAddrBit'range);
begin
	p0 : process(I_Dmn)
	begin
	if I_Dmn.rst='1' then
		gray <= (others=>'0');
	elsif I_Dmn.ena='0' then null;
	elsif rising_edge(I_Dmn.clk) then
		gray <= Bin2Gray(c_UsrAddrBitNext_i);
	end if;
	end process p0;

	I_UsrAddrBit <= gray;
end generate I_UsrAddrBit_gray;

end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--**************************************************************************************************
-- Number of used bits management
--**************************************************************************************************
library ieee;
use     ieee.std_logic_1164.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

entity buffer2ck_UsedBit is generic
	( CIRCULAR          : boolean                                          := false      -- Circular mode for write operations
	; CLOCK_MODE        : string                                                         -- "Single" / "Dual"
	; I_APS             : natural                                          :=  8         -- Address Path Size
	; I_DPS             : natural                                          := 16         -- Data    Path Size
	; I_LAT_RD_DATA     : natural range 0 to 2                             :=  2         -- Physical memory read latency (between its address and data)
	; PW_ALIGN          : positive                                                       -- Partial Write / Granularity for number of bits to write
	; PW_ENABLE         : boolean                                                        -- Partial Write / Enable this kind of operations
	; U_APS             : natural                                          :=  7         -- Address Path Size
	; U_DPS             : natural                                          := 32         -- Data    Path Size
	); port                                                                              --
	( I_Dmn             : in  domain                                                     -- Reset/clock/clock enable
	; c_UsedBit         : out slv(I_APS+Log2(I_DPS)           downto 0)                  -- Number of bits
	; c_UsedWord        : out slv(I_APS                       downto 0)                  -- Number of words
	; c_UsrAddrBitNext  : in  slv(I_APS+Log2(I_DPS)           downto 0)                  -- User   address / next value
	; I_LclAddrBit_c    : in  slv(I_APS+Log2(I_DPS)           downto 0)                  -- "True" memory pointer address, BIT  pointer (combinational value)
	; I_ModeRead        : in  sl                                                         -- This side is in Read     Mode
	; I_ModeWrite       : in  sl                                                         -- This side is in Write    Mode
	; I_sRst            : in  sl                                                         -- Synchronous reset
	; I_UsedBit_PW      : out slv(      Log2(I_DPS)           downto 0)                  -- Number of BIT  in partial-write module
	; pw_pos_mux        : in  slv(Log2(2*I_DPS/PW_ALIGN)-2    downto 0)                  -- Mux position for partial write (equivalent to number of bits * PW_ALIGN)
	; U_RdSkipBit       : in  slv(U_APS+Log2(U_DPS)           downto 0)                  -- Number of BIT  to read-skip
	; U_UsrAddrBit_ok   : in  slv(U_APS+Log2(U_DPS)           downto 0)                  -- User   pointer address, always good version (resynchronization or delay or direct, according to configuration)
	; I_iEmpty          : out sl                                                         -- Empty
	);
end entity buffer2ck_UsedBit;

architecture rtl of buffer2ck_UsedBit is
	signal c_UsedWord_i : slv(c_UsedWord'range);
begin

main : process(all)
	variable v_UsedBit : slv(c_UsedBit'range); -- Number of bits
	-- It's a VERY BAD idea to describe v_UsedBit with sequential equations like "if test then v_UsedBit := v_UsedBit + Delta; end if;" because this will create lots of unwanted logic (mux + add + mux)
begin
	-- Avoid inferring latch
	v_UsedBit := (others=>'0');

	-- These 3 equations already take into account following mechanisms :
	--     * resynchronization for dual clock systems
	--     * extra latency for single clock systems having a null Read Latency (this latency emulates the write-readable delay)
	--     * direct connection for single clock systems having a non-null Read Latency
	if I_ModeWrite='1'                      then v_UsedBit := I_LclAddrBit_c  - U_UsrAddrBit_ok ; end if; -- This side is in write mode
	if I_ModeRead ='1' and I_LAT_RD_DATA/=0 then v_UsedBit := U_UsrAddrBit_ok - I_LclAddrBit_c  ; end if; -- This side is in read  mode with RD_LAT/=0
	if I_ModeRead ='1' and I_LAT_RD_DATA =0 then v_UsedBit := U_UsrAddrBit_ok - c_UsrAddrBitNext; end if; -- This side is in read  mode with RD_LAT =0

	-- Take into account number of bits to ReadSkip on other side
	if StrEq(CLOCK_MODE,"Single") then
		v_UsedBit := v_UsedBit - U_RdSkipBit;
	end if;

	if I_sRst='1' then
		v_UsedBit := (others=>'0');
	end if;

	--Avoid number of bits to be greater than FIFO capacity
	if CIRCULAR and msb(v_UsedBit)='1' then
		v_UsedBit(v_UsedBit'high-1 downto 0) := (others=>'0');
	end if;

	c_UsedBit    <=     v_UsedBit;
	c_UsedWord_i <= msb(v_UsedBit,c_UsedWord'length);
end process main;

process(I_Dmn)
begin
if I_Dmn.rst='1' then
	I_iEmpty <= '1';
elsif I_Dmn.ena='0' then null;
elsif rising_edge(I_Dmn.clk) then
	if c_UsedWord=0 then I_iEmpty <= '1';         -- version 4.3.8
	else                 I_iEmpty <= '0'; end if;
end if;
end process;

c_UsedWord   <= c_UsedWord_i;
I_UsedBit_PW <= conv_slv(conv_int(pw_pos_mux)*PW_ALIGN,I_UsedBit_PW'length) when PW_ENABLE else (others=>'0');

end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--**************************************************************************************************
-- Number of used words management
--**************************************************************************************************
library ieee;
use     ieee.std_logic_1164.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

entity buffer2ck_UsedWord is generic
	( CIRCULAR          : boolean                                          := false      -- Circular mode for write operations
	; I_APS             : natural                                          :=  8         -- Address Path Size
	; I_DPS             : natural                                          := 16         -- Data    Path Size
	; I_LAT_RD_DATA     : natural range 0 to 2                             :=  2         -- Physical memory read latency (between its address and data)
	; PW_ENABLE         : boolean                                                        -- Partial Write / Enable this kind of operations
	; U_APS             : natural                                          :=  7         -- Address Path Size
	); port                                                                              --
	( I_Dmn             : in  domain                                                     -- Reset/clock/clock enable
	; c_UsedWord        : out slv(I_APS                       downto 0)                  -- Number of words
	; c_UsrAddrWordNext : in  slv(I_APS                       downto 0)                  -- User   address / next value
	; I_LclAddrWord_c   : in  slv(I_APS                       downto 0)                  -- "True" memory pointer address, WORD pointer (combinational value)
	; I_ModeRead        : in  sl                                                         -- This side is in Read     Mode
	; I_ModeWrite       : in  sl                                                         -- This side is in Write    Mode
	; I_sRst            : in  sl                                                         -- Synchronous reset
	; U_UsrAddrWord_ok  : in  slv(U_APS                       downto 0)                  -- User   pointer address, always good version (resynchronization or delay or direct, according to configuration)
	; I_iEmpty          : out sl                                                         -- Empty
	);
end entity buffer2ck_UsedWord;

architecture rtl of buffer2ck_UsedWord is
	signal c_UsedWord_i : slv(c_UsedWord'range);
begin

main : process(all)
	variable v_UsedWord : slv(c_UsedWord'range); -- Number of words
	-- It's a VERY BAD idea to describe v_UsedWord with sequential equations like "if test then v_UsedWord := v_UsedWord + Delta; end if;" because this will create lots of unwanted logic (mux + add + mux)
begin
	v_UsedWord := (others=>'0'); -- Avoid inferring latch

	-- These 3 equations already take into account following mechanisms :
	--     * resynchronization for dual clock systems
	--     * extra latency for single clock systems having a null Read Latency (this latency emulates the write-readable delay)
	--     * direct connection for single clock systems having a non-null Read Latency
	if I_ModeWrite='1'                      then v_UsedWord := I_LclAddrWord_c  - U_UsrAddrWord_ok ; end if; --    This side is in write mode
	if I_ModeRead ='1' and I_LAT_RD_DATA/=0 then v_UsedWord := U_UsrAddrWord_ok - I_LclAddrWord_c  ; end if; --    This side is in read  mode with RD_LAT/=0
	if I_ModeRead ='1' and I_LAT_RD_DATA =0 then v_UsedWord := U_UsrAddrWord_ok - c_UsrAddrWordNext; end if; --    This side is in read  mode with RD_LAT =0

	if I_sRst='1' then
		v_UsedWord := (others=>'0');
	end if;

	--Avoid number of Words to be greater than FIFO capacity
	if CIRCULAR and msb(v_UsedWord)='1' then
		v_UsedWord(v_UsedWord'high-1 downto 0) := (others=>'0');
	end if;

	c_UsedWord_i <= v_UsedWord;
end process main;

process(I_Dmn)
begin
if I_Dmn.rst='1' then
	I_iEmpty <= '1';
elsif I_Dmn.ena='0' then null;
elsif rising_edge(I_Dmn.clk) then
	if c_UsedWord_i=0 then I_iEmpty <= '1';         -- version 4.3.8
	else                   I_iEmpty <= '0'; end if;
end if;
end process;

c_UsedWord <= c_UsedWord_i;

assert not(PW_ENABLE)
	report "[buffer2ck] : PW_ENABLE cannot be set to true with RAW_DPS !!"
	severity failure;

end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
/*************************************************************************************************
Write Data / Partial Write

Receive and store external data (from backend) to an internal shift-register.
Provide full I_DPS data to internal storage (memory).

 * Registers : shift-register of 2*I_DPS-PW_ALIGN bits (represent almost all register ressources)
 * LUTs      : increase with ratio I_DPS/PW_ALIGN (may be so much... like 1170 LUTs for 128/8 !!)

*************************************************************************************************/
library ieee;
use     ieee.std_logic_1164.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;
--synthesis translate_off
use     work.pkg_simu.all;
--synthesis translate_on

entity buffer2ck_wr_partial is generic
	( I_DPS             : natural                                          := 16         -- Data    Path Size
	; PW_ALIGN          : positive                                                       -- Partial Write / Granularity for number of bits to write
	; PW_ALIGN_SIDE     : string                                           := "right"    -- Partial Write / Data input is right aligned
	); port                                                                              --
	( I_Dmn             : in  domain                                                     -- Reset/clock/clock enable
	; I_iMemWr          : out sl                                                         -- Physical Memory / Memory write command
	; I_iMemWrData      : out slv(I_DPS   -1                  downto 0)                  -- Physical Memory / Write Data
	; I_WrData          : in  slv(     I_DPS          -1      downto 0)                  -- Write Data
	; I_WrQnt           : in  slv(Log2(I_DPS)                 downto 0)                  -- Write Request Quantity (in bits). Available only when PW_ENABLE = true
	; pw_pos_mux        : out slv(Log2(2*I_DPS/PW_ALIGN)-2    downto 0)                  -- Mux position for partial write (equivalent to number of bits * PW_ALIGN)
	; pw_WrReq          : out sl                                                         -- Partial Write / Memory write request (full data)
	);
end entity buffer2ck_wr_partial;

architecture rtl of buffer2ck_wr_partial is
	signal          data_shift   : slv(     2*I_DPS-PW_ALIGN -1 downto 0);
	signal          nb_full      : slv(Log2(2*I_DPS/PW_ALIGN)-1 downto 0);
	signal          I_WrQntAlign : slv(Log2(  I_DPS/PW_ALIGN)   downto 0);
	signal          pw_pos_mux_i : slv(pw_pos_mux'range                 );
	signal          pw_WrReq_i   : sl                                    ;
begin
/*
Consider the following configuration : I_DPS=128 / PW_ALIGN=32
Each boxe represents a PW_ALIGN group (32 bits here)

(a) : I_DPS group (128 bits here) to be written to memory
(b) : partial I_DPS
(c) : partial data (b) is moved to (c) to prepare next operation
(b) is always moved to (c)

      LEFT alignment                                         RIGHT alignment

  <------(a)------>                                                   <-------(a)----->
  +---+---+---+---+---+---+---+                           +---+---+---+---+---+---+---+
  | 0 | 1 | 2 | 3 | 4 | 5 | 6 |                           | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
  +---+---+---+---+---+---+---+                           +---+---+---+---+---+---+---+

  <----(c)---->   <----(b)---->                           <----(b)---->   <----(c)---->
*/
I_WrQntAlign <= I_WrQnt(I_WrQnt'high downto Log2(PW_ALIGN));

main : process(I_Dmn)
begin
if I_Dmn.rst='1' then
	data_shift  <= (others=>'0');
	nb_full     <= (others=>'0');
elsif rising_edge(I_Dmn.clk) then
	nb_full    <= ('0' & nb_full(nb_full'high-1 downto 0)) + I_WrQntAlign;

	---------------------------------------------------------------------------------------------------------
	-- Data are RIGHT aligned
	---------------------------------------------------------------------------------------------------------
	if StrEq(PW_ALIGN_SIDE,"right") then
		-- I_DPS bits transferred to memory => shift register
		if msb(nb_full)='1' then
			data_shift(I_DPS-PW_ALIGN-1 downto 0) <= data_shift(2*I_DPS-PW_ALIGN-1 downto I_DPS);
		end if;

		--Load providen bits
		data_shift(I_DPS+conv_int(pw_pos_mux_i)*PW_ALIGN-1 downto conv_int(pw_pos_mux_i)*PW_ALIGN) <= I_WrData;
	---------------------------------------------------------------------------------------------------------
	-- Data are LEFT aligned
	---------------------------------------------------------------------------------------------------------
	else
		-- I_DPS bits transferred to memory => shift register
		if msb(nb_full)='1' then
			data_shift(2*I_DPS-PW_ALIGN-1 downto I_DPS) <= data_shift(I_DPS-PW_ALIGN-1 downto 0);
		end if;

		--Load providen bits
		data_shift(2*I_DPS-PW_ALIGN-conv_int(pw_pos_mux_i)*PW_ALIGN-1 downto
		             I_DPS-PW_ALIGN-conv_int(pw_pos_mux_i)*PW_ALIGN         ) <= I_WrData;
	end if;

	--synthesis translate_off
	if (I_WrQnt mod PW_ALIGN)/=0 then
		printf(failure,"[buffer2ck] : Illegal A_WrQnt value according to PW_ALIGN !!");
	end if;

	if I_iMemWr='1' and Is_X(I_iMemWrData) then
		printf(failure,"[buffer2ck] : Attempting to write undefined data (%X) to memory !!",I_iMemWrData);
	end if;
	--synthesis translate_on
end if;
end process main;

pw_WrReq_i   <= msb(nb_full);
pw_WrReq     <= pw_WrReq_i;

pw_pos_mux_i <= ExcludeMSB(nb_full);
pw_pos_mux   <= pw_pos_mux_i;

-- Write to memory
I_iMemWrData <= lsb(data_shift,I_DPS) when StrEq(PW_ALIGN_SIDE,"right") else
                msb(data_shift,I_DPS);

I_iMemWr     <= pw_WrReq_i;

end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--**************************************************************************************************
-- Write Data / Full Write data
--**************************************************************************************************
library ieee;
use     ieee.std_logic_1164.all;

library work;
use     work.pkg_std.all;

entity buffer2ck_wr_full is generic
	( I_DPS                  : natural                                          := 16         -- Data    Path Size
	; PW_ALIGN               : positive                                                       -- Partial Write / Granularity for number of bits to write
	); port                                                                                   --
	( I_Dmn                  : in  domain                                                     -- Reset/clock/clock enable
	; I_iMemWr               : out sl                                                         -- Physical Memory / Memory write command
	; I_iMemWrData           : out slv(I_DPS   -1                  downto 0)                  -- Physical Memory / Write Data
	; I_sRst                 : in  sl                                                         -- Synchronous reset
	; I_WrData               : in  slv(     I_DPS          -1      downto 0)                  -- Write Data
	; I_WrReq                : in  sl                                                         -- Write Request                   . Available only when PW_ENABLE = false
	; pw_pos_mux             : out slv(Log2(2*I_DPS/PW_ALIGN)-2    downto 0)                  -- Mux position for partial write (equivalent to number of bits * PW_ALIGN)
	; pw_WrReq               : out sl                                                         -- Partial Write / Memory write request (full data)
	);
end entity buffer2ck_wr_full;

architecture rtl of buffer2ck_wr_full is
begin
	pw_pos_mux     <= (others=>'0');
	pw_WrReq       <=          '0' ;
	I_iMemWr       <= I_WrReq and I_Dmn.ena and not(I_sRst); -- Version 5.04.07
	I_iMemWrData   <= I_WrData;
end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;
--synthesis translate_off
use     work.pkg_simu.all;
--synthesis translate_on

entity buffer2ck_half is generic
	( ID_I              : string                                                         -- "A" / "B"
	; ID_U              : string                                                         -- "A" / "B"
	; CLOCK_MODE        : string                                                         -- "Single" / "Dual"
	; BYTE_MODE         : natural range 8 to 9                          :=  8            -- Size for one "byte". If 9, use extra-bit from Memory block
	; CREATE_OWN        : boolean                                                        -- Create its own full dedicated logic (counters & flags)
	                                                                                     --
	; I_APS             : natural                                       :=  8            -- Address Path Size
	; I_DPS             : natural                                       := 16            -- Data    Path Size
	; I_MODE            : string                                        := "RW"          -- WO / RO / RW (Write Only / Read Only / Read & Write)
	; I_LAT_RD_ADDR     : integer range 0 to 1                          :=  1            -- 0 : memory read address bus is combinational / 1 : memory read address bus is registered
	; I_LAT_RD_DATA     : natural range 0 to 2                          :=  2            -- Physical memory read latency (between its address and data)
	; I_LVL_FULL        : integer                                       :=  0            -- Level to report buffer as full
	                                                                                     --
	; U_APS             : natural                                       :=  7            -- Address Path Size
	; U_DPS             : natural                                       := 32            -- Data    Path Size
	; U_LAT_RD_DATA     : natural range 0 to 2                                           -- Physical memory read latency (between its address and data)
	                                                                                     --
	; CIRCULAR          : boolean                                       := false         -- Circular mode for write operations
	; RAW_DPS           : boolean                                                        -- Enable all datapath size (but in this case, both sides shall have the same size)
	; SEND_FLAG         : boolean                                       := false         -- Does an Overflow/Underflow is sent to other side ?
	; USE_BE            : boolean                                       := false         -- Save ByteEnable inside fifo
	                                                                                     --
	; PR_ENABLE         : boolean                                       := false         -- Partial Read  / Enable this kind of operations
	; PR_ALIGN          : int                                           :=  8            -- Partial Read  / Granularity for number of bits to read
	; PR_ALIGN_SIDE     : string                                        := "right"       -- Partial Read  / Data ouput is right aligned
	; PR_AUTO_START     : boolean                                       := true          -- Partial Read  / Very first RdSkip is done automatically with a null value
	                                                                                     --
	; PW_ENABLE         : boolean                                                        -- Partial Write / Enable this kind of operations
	; PW_ALIGN          : positive                                                       -- Partial Write / Granularity for number of bits to write
	; PW_ALIGN_SIDE     : string                                        := "right"       -- Partial Write / Data input is right aligned
	  --synthesis translate_off                                                          --
	; MAKE_X            : boolean                                       := true          -- Make conflict when data are not valid
	; SEV_LVL_EMPTY     : severity_level                                := failure       -- Severity level for empty fifo
	; SEV_LVL_FULL      : severity_level                                := failure       -- Severity level for full  fifo
	  --synthesis translate_on                                                           --
	); port                                                                              --
	( -- Port I (say "I", "Me")                                                          --
	  I_Dmn             : in  domain                                                     -- Reset/clock/clock enable
	; I_Clr             : in  sl                                                         -- Clear buffer
	; I_Ready           : out sl                                                         -- Buffer is ready to operate (cleared on reset)
	; I_UsedBit         : out slv(I_APS+Log2(I_DPS)           downto 0)                  -- Number of BIT  for this side
	; I_UsedBit_PW      : out slv(      Log2(I_DPS)           downto 0)                  -- Number of BIT  in partial-write module
	; I_UsedWord        : out slv(I_APS                       downto 0)                  -- Number of WORD for this side
	; I_Empty           : out sl                                                         -- Buffer is empty
	; I_Full            : out sl                                                         -- Buffer is full
	; I_OverFlow        : out sl                                                         -- Buffer has encountered an OverFlow  since last synchronous reset
	; I_UnderFlow       : out sl                                                         -- Buffer has encountered an UnderFlow since last synchronous reset
	; I_RWn             : in  sl                                                         -- Direction (default is Write)
	                                                                                     --
	; I_WrReq           : in  sl                                                         -- Write Request                   . Available only when PW_ENABLE = false
	; I_WrQnt           : in  slv(Log2(I_DPS)                 downto 0)                  -- Write Request Quantity (in bits). Available only when PW_ENABLE = true
	; I_WrData          : in  slv(     I_DPS          -1      downto 0)                  -- Write Data
	; I_RdReq           : in  sl                                                         -- Read Request
	; I_RdAck           : out sl                                                         -- Read Acknowledge
	; I_RdData          : out slv(     I_DPS          -1      downto 0)                  -- Read Data
	; I_RdBe            : out slv(Maxi(I_DPS/8        -1,0)   downto 0)                  -- Read ByteEnable
	; I_RdSkipBit       : in  slv(I_APS+Log2(I_DPS)           downto 0)                  -- Number of BIT  to read-skip
	; I_RdSkipWord      : in  slv(I_APS                       downto 0)                  -- Number of WORD to read-skip
	  -- Port U (say "U", "You")                                                         --
	; U_Clr             : in  sl                                                         -- Clear buffer
	; U_RWn             : in  sl                                                         -- Direction (default is Read)
	; U_WrReq           : in  sl                                                         -- Write Request
	; U_RdReq           : in  sl                                                         -- Read Request
	; U_RdSkipBit       : in  slv(U_APS+Log2(U_DPS)           downto 0)                  -- Number of BIT  to read-skip
	; U_RdSkipWord      : in  slv(U_APS                       downto 0)                  -- Number of WORD to read-skip
	  -- Internal signals                                                                --
	; I_Clr_t           : out sl                                                         -- Clear toggle
	; I_UsrAddrBit      : out slv(I_APS+Log2(I_DPS)           downto 0)                  -- User   BIT  address pointer, binary for Single clock, gray for Dual clock
	; I_UsrAddrWord     : out slv(I_APS                       downto 0)                  -- User   WORD address pointer, binary for Single clock, gray for Dual clock
	; I_AddrBit         : out slv(I_APS+Log2(I_DPS)           downto 0)                  -- Memory address pointer, binary for Single clock, gray for Dual clock
	; I_MemAddr         : out slv(I_APS                       downto 0)                  -- Physical Memory / Address
	; I_MemRdBE         : in  slv(Maxi(I_DPS/8        -1,0)   downto 0)                  -- Physical Memory / Read Byte Enable
	; I_MemRdData       : in  slv(I_DPS   -1                  downto 0)                  -- Physical Memory / Read Data
	; I_MemWr           : out sl                                                         -- Physical Memory / Memory write command
	; I_MemWrData       : out slv(I_DPS   -1                  downto 0)                  -- Physical Memory / Write Data
	; I_RdDestroyBit    : out slv(Log2(I_DPS)                 downto 0)                  -- Number of BIT  to destroy (circular mode)
	; I_RdDestroyWord   : out sl                                                         -- Number of WORD to destroy (circular mode, DPS/=2^n -> can only destroy 1 word, see [Note 6])
	                                                                                     --
	; U_Clr_t           : in  sl                                                         -- Clear, toggle
	; U_UsrAddrBit      : in  slv(U_APS+Log2(U_DPS)           downto 0)                  -- User   BIT  address pointer, binary for Single clock, gray for Dual clock
	; U_UsrAddrWord     : in  slv(U_APS                       downto 0)                  -- User   WORD address pointer, binary for Single clock, gray for Dual clock
	; U_AddrBit         : in  slv(U_APS+Log2(U_DPS)           downto 0)                  -- Memory address pointer, binary for Single clock, gray for Dual clock
	; U_iOverFlow       : in  sl                                                         -- Overflow
	; U_iUnderFlow      : in  sl                                                         -- Underflow
	; U_RdDestroyBit    : in  slv(Log2(U_DPS)                 downto 0)                  -- Number of BIT  to destroy (circular mode, DPS =2^n                                         )
	; U_RdDestroyWord   : in  sl                                                         -- Number of WORD to destroy (circular mode, DPS/=2^n -> can only destroy 1 word, see [Note 6])
	);
end entity buffer2ck_half;

architecture rtl of buffer2ck_half is
	constant        GEN_USED_BIT       : boolean := CREATE_OWN and not(RAW_DPS); -- Create counters/flags with bit  resolution
	constant        GEN_USED_WORD      : boolean := CREATE_OWN and     RAW_DPS ; -- Create counters/flags with word resolution
	signal          IClr_t             : sl                                    ; -- Clear toggle
	signal          I_FullAutoLvl      : sl                                    ; -- Full flag with custom level detection (from I_LVL_FULL value)
	signal          I_ModeCirc         : sl                                    ; -- This side is in Circular Mode
	signal          I_ModeRead         : sl                                    ; -- This side is in Read     Mode
	signal          I_ModeWrite        : sl                                    ; -- This side is in Write    Mode
	signal          I_WrReq_r          : sl                                    ; -- Internal Write Request (one clock cycle  after original)
	signal          I_RdReq_r          : sl                                    ; -- Internal Read  Request (one clock cycle  after original)
	signal          I_RdReq_rr         : sl                                    ; -- Internal Read  Request (two clock cycles after original)
	signal          I_iEmpty           : sl                                    ; -- Empty
	signal          I_iFull            : sl                                    ; -- Full
	signal          I_iRdReq           : sl                                    ; -- Internal Read Request (special handling for Show-Ahead mode)
	signal          I_sRst             : sl                                    ; -- Synchronous reset
	signal          I_iMemAddr         : slv(I_APS                    downto 0); -- Physical Memory / Address
	signal          I_iMemWr           : sl                                    ; -- Physical Memory / Memory write command
	signal          I_iMemWrData       : slv(I_DPS   -1               downto 0); -- Physical Memory / Write Data
	signal          U_AddrBit_ok       : slv(U_APS+Log2(U_DPS)        downto 0); -- Memory pointer address, always good version (resynchronization or delay or direct, according to configuration)
	signal          U_Clr_s            : slv4                                  ; -- Clear, resynchronization delay line
	signal          U_iOverFlow_r      : sl                                    ; -- Overflow, on U side
	signal          U_iUnderFlow_r     : sl                                    ; -- Underflow, on U side

	signal          c_UsedBit          : slv(I_APS+Log2(I_DPS)        downto 0); -- Number of bits
	signal          c_UsrAddrBitNext   : slv(I_APS+Log2(I_DPS)        downto 0); -- User   address / next value
	signal          I_LclAddrBit_r     : slv(I_APS+Log2(I_DPS)        downto 0); -- "True" memory pointer address, BIT  pointer (registered    value)
	signal          I_LclAddrBit_c     : slv(I_APS+Log2(I_DPS)        downto 0); -- "True" memory pointer address, BIT  pointer (combinational value)
	signal          I_LclAddrBit       : slv(I_APS+Log2(I_DPS)        downto 0); -- "True" memory pointer address, BIT  pointer (comb/reg according to I_LAT_RD_ADDR)
	signal          U_UsrAddrBit_ok    : slv(U_APS+Log2(U_DPS)        downto 0); -- User   pointer address, always good version (resynchronization or delay or direct, according to configuration)
	signal          I_iUsedBit         : slv(I_APS+Log2(I_DPS)        downto 0); -- Number of bits

	signal          c_UsedWord         : slv(I_APS                    downto 0); -- Number of words
	signal          c_UsrAddrWordNext  : slv(I_APS                    downto 0); -- User   address / next value
	signal          I_LclAddrWord_r    : slv(I_APS                    downto 0); -- "True" memory pointer address, WORD pointer (registered    value)
	signal          I_LclAddrWord_c    : slv(I_APS                    downto 0); -- "True" memory pointer address, WORD pointer (combinational value)
	signal          I_LclAddrWord      : slv(I_APS                    downto 0); -- "True" memory pointer address
	signal          U_UsrAddrWord_ok   : slv(U_APS                    downto 0); -- User   pointer address, always good version (resynchronization or delay or direct, according to configuration)
	signal          I_iUsedWord        : slv(I_APS                    downto 0); -- Number of words
	signal          I_iUsrAddrWord     : slv(I_APS                    downto 0); -- "User" memory pointer address. May be different that "memory" pointer

	signal          pw_pos_mux         : slv(Log2(2*I_DPS/PW_ALIGN)-2 downto 0); -- Mux position for partial write (equivalent to number of bits * PW_ALIGN)
	signal          pw_WrReq           : sl                                    ; -- Partial Write / Memory write request (full data)
begin

--**************************************************************************************************
-- Synchronous part
--**************************************************************************************************
sync : process(I_Dmn)
begin
if I_Dmn.rst='1' then
	IClr_t         <=          '0' ; U_Clr_s        <= (others=>'0');
	I_RdReq_r      <=          '0' ; I_WrReq_r      <=          '0' ;
	I_RdReq_rr     <=          '0' ;
	I_FullAutoLvl  <=          '0' ;
elsif I_Dmn.ena='0' then null;
elsif rising_edge(I_Dmn.clk) then
	-- Reset
	IClr_t <= IClr_t xor I_Clr   ; -- toggle each cycle where I_Clr is asserted

	-- B side reset
	--    bits 0 - 1 : toggle resynchronization, usefull for "short" pulse on B_Clr
	--    bit      2 : direct resynchronization for B_Clr (usefull for "long" pulse)
	--    bit      3 : reset generation
	U_Clr_s(0) <= U_Clr_t   ;
	U_Clr_s(1) <= U_Clr_s(0);
	U_Clr_s(2) <= U_Clr     ;
	U_Clr_s(3) <= U_Clr_s(2) or (U_Clr_s(0) xor U_Clr_s(1));
	----------------------------------------------------------------
	-- Register combinational logic
	----------------------------------------------------------------

	--synthesis translate_off
	assert not(Is_X(I_RdReq   ))  report "[buffer2ck] : Wrong value on " & ID_I & "_RdReq"  severity failure;
	assert not(Is_X(U_RdReq   ))  report "[buffer2ck] : Wrong value on " & ID_U & "_RdReq"  severity failure;

	assert not(Is_X(I_WrReq   ))  report "[buffer2ck] : Wrong value on " & ID_I & "_WrReq"  severity failure;
	assert not(Is_X(U_WrReq   ))  report "[buffer2ck] : Wrong value on " & ID_U & "_WrReq"  severity failure;

	assert not(Is_X(I_Clr     ))  report "[buffer2ck] : Wrong value on " & ID_I & "_Clr"    severity failure;
	assert not(Is_X(c_UsedWord))  report "[buffer2ck] : Wrong value on c_UsedWord"          severity failure;
	if U_DPS/I_DPS>256       then report "[buffer2ck] : Unsupported B_DPS/A_DPS ratio !!"   severity failure; end if;

	assert not(Is_X(I_RdSkipBit)) report "[buffer2ck] : Wrong value on I_RdSkipBit"         severity failure;
	assert not(Is_X(I_WrQnt    )) report "[buffer2ck] : Wrong value on I_WrQnt"             severity failure;

--	assert I_RdSkipBit =0 or CLOCK_MODE="Single" report "[buffer2ck] : Illegal ReadSkip operation in Dual clock mode !!" severity failure; -- Since 7.02.01
--	assert I_RdSkipWord=0 or CLOCK_MODE="Single" report "[buffer2ck] : Illegal ReadSkip operation in Dual clock mode !!" severity failure; -- Since 7.02.01
	--synthesis translate_on
	----------------------------------------------------------------
	-- Flags
	----------------------------------------------------------------
	-- Full
	-- Case where I_LVL_FULL=0 is handled later, directly with I_iUsedWord to create I_Full
	if (I_LVL_FULL<0 and c_UsedWord>=2**I_APS+I_LVL_FULL)                                    -- I_LVL_FULL ~ number of empty    words before claiming FIFO full
	or (I_LVL_FULL>0 and c_UsedWord>=         I_LVL_FULL) then I_FullAutoLvl <= '1';         -- I_LVL_FULL = number of existing words before claiming FIFO full
	else                                                       I_FullAutoLvl <= '0'; end if; --
	----------------------------------------------------------------
	-- Internal commands (delayed)
	----------------------------------------------------------------
	I_RdReq_r  <= I_iRdReq ;
	I_RdReq_rr <= I_RdReq_r;
	I_WrReq_r  <= I_WrReq  ;
	--synthesis translate_off
	-- Check dynamic directionality
	if U_Clr='0' and I_RWn=U_RWn then report "[buffer2ck] : I_RWn cannot be equal to U_RWn" severity failure; end if;
	--synthesis translate_on
end if;
end process sync;

I_sRst         <= I_Clr or U_Clr when StrEq(CLOCK_MODE,"Single") else I_Clr or U_Clr_s(3);
I_Clr_t        <= IClr_t;
I_Empty        <= I_iEmpty;
I_iFull        <= msb(I_iUsedWord);
I_Full         <= msb(I_iUsedWord) when I_LVL_FULL=0 else I_FullAutoLvl;
I_ModeCirc     <= '1' when (I_MODE="WO" or (I_MODE="RW" and I_RWn='0')) and CIRCULAR else '0';
I_ModeRead     <= '1' when  I_MODE="RO" or (I_MODE="RW" and I_RWn='1')               else '0';
I_ModeWrite    <= '1' when  I_MODE="WO" or (I_MODE="RW" and I_RWn='0')               else '0';
I_UsedBit      <= I_iUsedBit ;
I_UsedWord     <= I_iUsedWord;
--**************************************************************************************************
-- From I to U
--**************************************************************************************************
--Write Request while buffer is full
--    => oldest data shall be destroyed
--    => increase read pointer on other memory side
-- No RdSkip on B side        ----------------------------------------------------------------------------------------------+
-- Write to memory            -----------------------------------------------------------------------------+                |
-- Fifo is full               ----------------------------------------------------------+                  |                |
-- Circular mode              --------------------------+                               |                  |                |
-- @ = @ + 1 Word             -----\                    |                               |                  |                |
--                                 V                    V                               V                  V                V
I_RdDestroyBit  <= conv_slv(I_DPS,Log2(I_DPS)+1) when CIRCULAR and             msb(I_iUsedWord)='1' and I_iMemWr='1' and U_RdSkipBit =0 else (others=>'0');
I_RdDestroyWord <= '1'                           when CIRCULAR and RAW_DPS and msb(I_iUsedWord)='1' and I_iMemWr='1' and U_RdSkipWord=0 else          '0' ;
--**************************************************************************************************
-- Physical memory address bit pointer management (for I-side)
--**************************************************************************************************
I_AddrBit_bin : block is
begin
	------------------------------------------------------------------------------------------------
	-- I_DPS = 2^n => bit counter
	------------------------------------------------------------------------------------------------
	dps_2pn : if not(RAW_DPS) generate
	begin
		LclAddrBit : entity work.buffer2ck_LclAddrBit generic map
			( CIRCULAR        => CIRCULAR        --boolean                                       := false         -- Circular mode for write operations
			, I_APS           => I_APS           --natural                                       :=  8            -- Address Path Size
			, I_DPS           => I_DPS           --natural                                       := 16            -- Data    Path Size
			, I_LAT_RD_ADDR   => I_LAT_RD_ADDR   --integer range 0 to 1                          :=  1            -- 0 : memory read address bus is combinational / 1 : memory read address bus is registered
			, U_DPS           => U_DPS           --natural                                       := 32            -- Data    Path Size
			) port map                           --                                                               --
			( I_Dmn           => I_Dmn           --in  domain                                                     -- Reset/clock/clock enable
			, I_sRst          => I_sRst          --in  sl                                                         -- Synchronous reset
			, I_LclAddrBit    => I_LclAddrBit    --out slv(I_APS+Log2(I_DPS)           downto 0)                  -- "True" memory pointer address, BIT  pointer (comb/reg according to I_LAT_RD_ADDR)
			, I_LclAddrBit_c  => I_LclAddrBit_c  --out slv(I_APS+Log2(I_DPS)           downto 0)                  -- "True" memory pointer address, BIT  pointer (combinational value)
			, I_LclAddrBit_r  => I_LclAddrBit_r  --out slv(I_APS+Log2(I_DPS)           downto 0)                  -- "True" memory pointer address, BIT  pointer (registered    value)
			, I_ModeRead      => I_ModeRead      --in  sl                                                         -- This side is in Read     Mode
			, I_ModeWrite     => I_ModeWrite     --in  sl                                                         -- This side is in Write    Mode
			, I_RdSkipBit     => I_RdSkipBit     --in  slv(I_APS+Log2(I_DPS)           downto 0)                  -- Number of BIT  to read-skip
			, I_WrReq         => I_WrReq         --in  sl                                                         -- Write Request                   . Available only when PW_ENABLE = false
			, I_iRdReq        => I_iRdReq        --in  sl                                                         -- Internal Read Request (special handling for Show-Ahead mode)
			, U_RdDestroyBit  => U_RdDestroyBit  --in  slv(Log2(U_DPS)                 downto 0)                  -- Number of BIT  to destroy (circular mode, DPS =2^n                                         )
			, pw_WrReq        => pw_WrReq        --in  sl                                                         -- Partial Write / Memory write request (full data)
			);
	end generate dps_2pn;
	------------------------------------------------------------------------------------------------
	-- I_DPS /= 2^n => word counter
	------------------------------------------------------------------------------------------------
	dps_raw : if RAW_DPS generate
	begin
		LclAddrWord : entity work.buffer2ck_LclAddrWord generic map
			( CIRCULAR        => CIRCULAR        --boolean                                       := false         -- Circular mode for write operations
			, I_APS           => I_APS           --natural                                       :=  8            -- Address Path Size
			) port map                           --                                                               --
			( I_Dmn           => I_Dmn           --in  domain                                                     -- Reset/clock/clock enable
			, I_sRst          => I_sRst          --in  sl                                                         -- Synchronous reset
			, I_LclAddrWord_c => I_LclAddrWord_c --out slv(I_APS                       downto 0)                  -- "True" memory pointer address, WORD pointer (combinational value)
			, I_LclAddrWord_r => I_LclAddrWord_r --out slv(I_APS                       downto 0)                  -- "True" memory pointer address, WORD pointer (registered    value)
			, I_ModeRead      => I_ModeRead      --in  sl                                                         -- This side is in Read     Mode
			, I_ModeWrite     => I_ModeWrite     --in  sl                                                         -- This side is in Write    Mode
			, I_RdSkipWord    => I_RdSkipWord    --in  slv(I_APS                       downto 0)                  -- Number of WORD to read-skip
			, I_WrReq         => I_WrReq         --in  sl                                                         -- Write Request                   . Available only when PW_ENABLE = false
			, I_iRdReq        => I_iRdReq        --in  sl                                                         -- Internal Read Request (special handling for Show-Ahead mode)
			, U_RdDestroyWord => U_RdDestroyWord --in  sl                                                         -- Number of WORD to destroy (circular mode, DPS/=2^n -> can only destroy 1 word, see [Note 6])
			, pw_WrReq        => pw_WrReq        --in  sl                                                         -- Partial Write / Memory write request (full data)
			);

		--Drive unused signals
		I_LclAddrBit_c <= (others=>'0');
		I_LclAddrBit_r <= (others=>'0');
		I_LclAddrBit   <= (others=>'0');
	end generate dps_raw;
	------------------------------------------------------------------------------------------------
	--
	------------------------------------------------------------------------------------------------
	mem_addr_pr_no : if not(PR_ENABLE) generate
	begin
		I_LclAddrWord  <= ExcludeLSB(I_LclAddrBit,Log2(I_DPS)) when RAW_DPS=false else
		                             I_LclAddrWord_r;
		I_iMemAddr     <= I_LclAddrWord;
	end generate mem_addr_pr_no;

	mem_addr_pr_yes : if PR_ENABLE generate
		signal          sub : sl;
	begin
		I_LclAddrWord <= ExcludeLSB(I_LclAddrBit,Log2(I_DPS));

		process(I_Dmn)
		begin
		if I_Dmn.rst='1' then
			I_LclAddrWord_r <= (others=>'0');
			I_iMemAddr      <= (others=>'0');
			sub             <=          '0' ;
		elsif rising_edge(I_Dmn.clk) then
			I_LclAddrWord_r <= I_LclAddrWord;

			if I_RdSkipBit/=0 then sub <= '1'; end if;

			if sub='0' or I_LclAddrWord/=I_LclAddrWord_r then I_iMemAddr <= I_LclAddrWord;
			else                                              I_iMemAddr <= I_LclAddrWord + 1; end if;
		end if;
		end process;
	end generate mem_addr_pr_yes;
	------------------------------------------------------------------------------------------------
	-- Manage unassigned objects
	------------------------------------------------------------------------------------------------
	unassigned_0 : if not(RAW_DPS) and not(PR_ENABLE) generate
	begin
		I_LclAddrWord_r <= (others=>'0');
	end generate unassigned_0;

	I_MemAddr <= I_iMemAddr;
end block I_AddrBit_bin;

I_AddrBit_single : if StrEq(CLOCK_MODE,"Single") generate
begin
	I_AddrBit <= I_LclAddrBit;
end generate I_AddrBit_single;

I_AddrBit_dual : if StrEq(CLOCK_MODE,"Dual") generate
begin
	process(I_Dmn)
	begin
	if I_Dmn.rst='1' then
		I_AddrBit <= (others=>'0');
	elsif I_Dmn.ena='0' then null;
	elsif rising_edge(I_Dmn.clk) then
		I_AddrBit <= Bin2Gray(I_LclAddrBit);
	end if;
	end process;
end generate I_AddrBit_dual;
--**************************************************************************************************
-- Physical memory address bit pointer management (for U-side)
--**************************************************************************************************
U_AddrBit_mgt : block is
begin
	bin_dual : if StrEq(CLOCK_MODE,"Dual") generate
		signal          U_AddrBit_r   : slv(U_AddrBit'range);
		signal          U_AddrBit_bin : slv(U_AddrBit'range);
	begin
		p0 : process(I_Dmn)
		begin
		if I_Dmn.rst='1' then
			U_AddrBit_r   <= (others=>'0');
			U_AddrBit_bin <= (others=>'0');
		elsif I_Dmn.ena='0' then null;
		elsif rising_edge(I_Dmn.clk) then
			U_AddrBit_r   <= U_AddrBit;             -- Resynchronize bray value
			U_AddrBit_bin <= Gray2Bin(U_AddrBit_r); -- Convert to binary
		end if;
		end process p0;

		U_AddrBit_ok <= U_AddrBit_bin;
	end generate bin_dual;

	bin_single : if StrEq(CLOCK_MODE,"Single") generate
		signal          U_AddrBit_r1 : slv(U_AddrBit'range);
		signal          U_AddrBit_r2 : slv(U_AddrBit'range);
	begin
		p0 : process(I_Dmn)
		begin
		if I_Dmn.rst='1' then
			U_AddrBit_r1 <= (others=>'0');
			U_AddrBit_r2 <= (others=>'0');
		elsif I_Dmn.ena='0' then null;
		elsif rising_edge(I_Dmn.clk) then
			U_AddrBit_r1 <= U_AddrBit   ;
			U_AddrBit_r2 <= U_AddrBit_r1;
		end if;
		end process p0;

		U_AddrBit_ok <= U_AddrBit_r2 when I_LAT_RD_DATA=0 else
		                U_AddrBit;
	end generate bin_single;
end block U_AddrBit_mgt;
--**************************************************************************************************
-- User address BIT pointer management (for I-side)
--**************************************************************************************************
UserAddrBit : entity work.buffer2ck_UserAddrBit generic map
	( CLOCK_MODE        => CLOCK_MODE                        --string                                                         -- "Single" / "Dual"
	, I_APS             => I_APS                             --natural                                       :=  8            -- Address Path Size
	, I_DPS             => I_DPS                             --natural                                       := 16            -- Data    Path Size
	, PR_ENABLE         => PR_ENABLE                         --boolean                                       := false         -- Partial Read  / Enable this kind of operations
	, PW_ENABLE         => PW_ENABLE                         --boolean                                                        -- Partial Write / Enable this kind of operations
	) port map                                               --                                                               --
	( I_Dmn             => I_Dmn                             --in  domain                                                     -- Reset/clock/clock enable
	, I_sRst            => I_sRst                            --in  sl                                                         -- Synchronous reset
	, I_WrReq           => I_WrReq_r                         --in  sl                                                         -- Write Request                   . Available only when PW_ENABLE = false
	, I_RdReq           => I_RdReq                           --in  sl                                                         -- Read Request
	, I_iMemAddr        => I_iMemAddr                        --in  slv(I_APS                       downto 0)                  -- Physical Memory / Address
	, I_UsrAddrBit      => I_UsrAddrBit                      --out slv(I_APS+Log2(I_DPS)           downto 0)                  -- User   BIT  address pointer, binary for Single clock, gray for Dual clock
	, c_UsrAddrBitNext  => c_UsrAddrBitNext                  --out slv(I_APS+Log2(I_DPS)           downto 0)                  -- User   address / next value
	);

--**************************************************************************************************
-- User address WORD pointer management (for I-side)
--**************************************************************************************************
-- This block is only usefull when RAW_DPS=true, this induces that partial acces are not allowed
I_UsrWord : if RAW_DPS generate
begin
	p0 : process(all)
	begin
		if not(PR_ENABLE) then
			-- Manage "user" pointer (number of read data).
			   if I_sRst='1' then c_UsrAddrWordNext <= (others=>'0');                                    -- Reset
			else                  c_UsrAddrWordNext <= I_iUsrAddrWord + (I_RdReq or I_WrReq_r); end if;  -- Take into account Read or Write request
		else
			c_UsrAddrWordNext <= (others=>'0');
			report "[buffer2ck] : Partial access are not supported with RAW_DPS" severity failure;
		end if;
	end process p0;

	p1 : process(I_Dmn)
	begin
	if I_Dmn.rst='1' then
		I_iUsrAddrWord <= (others=>'0');
	elsif I_Dmn.ena='0' then null;
	elsif rising_edge(I_Dmn.clk) then
		I_iUsrAddrWord <= c_UsrAddrWordNext;
	end if;
	end process p1;


	I_UsrAddrWord_bin : if StrEq(CLOCK_MODE,"Single") generate
	begin
		I_UsrAddrWord <= c_UsrAddrWordNext;
	end generate I_UsrAddrWord_bin;

	I_UsrAddrWord_gray : if StrEq(CLOCK_MODE,"Dual") generate
		signal          gray : slv(I_UsrAddrWord'range);
	begin
		p0 : process(I_Dmn)
		begin
		if I_Dmn.rst='1' then
			gray <= (others=>'0');
		elsif I_Dmn.ena='0' then null;
		elsif rising_edge(I_Dmn.clk) then
			gray <= Bin2Gray(c_UsrAddrWordNext);
		end if;
		end process p0;

		I_UsrAddrWord <= gray;
	end generate I_UsrAddrWord_gray;
end generate I_UsrWord;

I_UsrWord_noinst : if not(RAW_DPS) generate
begin
	c_UsrAddrWordNext <= (others=>'0');
	I_iUsrAddrWord    <= (others=>'0');
	I_UsrAddrWord     <= (others=>'0');
end generate I_UsrWord_noinst;
--**************************************************************************************************
-- User address BIT pointer management (for U-side)
--**************************************************************************************************
U_UsrBit : block is
begin
	bin_dual : if StrEq(CLOCK_MODE,"Dual") generate
		signal          U_UsrAddrBit_r   : slv(U_UsrAddrBit'range);
		signal          U_UsrAddrBit_bin : slv(U_UsrAddrBit'range);
	begin
		p0 : process(I_Dmn)
		begin
		if I_Dmn.rst='1' then
			U_UsrAddrBit_r   <= (others=>'0');
			U_UsrAddrBit_bin <= (others=>'0');
		elsif I_Dmn.ena='0' then null;
		elsif rising_edge(I_Dmn.clk) then
			U_UsrAddrBit_r   <= U_UsrAddrBit;             -- Resynchronize bray value
			U_UsrAddrBit_bin <= Gray2Bin(U_UsrAddrBit_r); -- Convert to binary
		end if;
		end process p0;

		U_UsrAddrBit_ok <= U_UsrAddrBit_bin;
	end generate bin_dual;

	bin_single : if StrEq(CLOCK_MODE,"Single") generate
		signal          U_UsrAddrBit_r1 : slv(U_UsrAddrBit'range);
		signal          U_UsrAddrBit_r2 : slv(U_UsrAddrBit'range);
	begin
		p0 : process(I_Dmn)
		begin
		if I_Dmn.rst='1' then
			U_UsrAddrBit_r1 <= (others=>'0');
			U_UsrAddrBit_r2 <= (others=>'0');
		elsif I_Dmn.ena='0' then null;
		elsif rising_edge(I_Dmn.clk) then
			U_UsrAddrBit_r1 <= U_UsrAddrBit   ;
			U_UsrAddrBit_r2 <= U_UsrAddrBit_r1;
		end if;
		end process p0;

		U_UsrAddrBit_ok <= U_UsrAddrBit_r2 when I_LAT_RD_DATA=0 and I_ModeRead='1' else -- In show-ahead mode, for read-side, add two clock cycles to see write pointer (see [Note 5])
		                   U_UsrAddrBit;
	end generate bin_single;
end block U_UsrBit;
--**************************************************************************************************
-- User address WORD pointer management (for U-side)
--**************************************************************************************************
U_UsrWord : block is
begin
	bin_dual : if StrEq(CLOCK_MODE,"Dual") generate
		signal          U_UsrAddrWord_r   : slv(U_UsrAddrWord'range);
		signal          U_UsrAddrWord_bin : slv(U_UsrAddrWord'range);
	begin
		p0 : process(I_Dmn)
		begin
		if I_Dmn.rst='1' then
			U_UsrAddrWord_r   <= (others=>'0');
			U_UsrAddrWord_bin <= (others=>'0');
		elsif I_Dmn.ena='0' then null;
		elsif rising_edge(I_Dmn.clk) then
			U_UsrAddrWord_r   <= U_UsrAddrWord;             -- Resynchronize bray value
			U_UsrAddrWord_bin <= Gray2Bin(U_UsrAddrWord_r); -- Convert to binary
		end if;
		end process p0;

		U_UsrAddrWord_ok <= U_UsrAddrWord_bin;
	end generate bin_dual;

	bin_single : if StrEq(CLOCK_MODE,"Single") generate
		signal          U_UsrAddrWord_r1 : slv(U_UsrAddrWord'range);
		signal          U_UsrAddrWord_r2 : slv(U_UsrAddrWord'range);
	begin
		p0 : process(I_Dmn)
		begin
		if I_Dmn.rst='1' then
			U_UsrAddrWord_r1 <= (others=>'0');
			U_UsrAddrWord_r2 <= (others=>'0');
		elsif I_Dmn.ena='0' then null;
		elsif rising_edge(I_Dmn.clk) then
			U_UsrAddrWord_r1 <= U_UsrAddrWord   ;
			U_UsrAddrWord_r2 <= U_UsrAddrWord_r1;
		end if;
		end process p0;

		U_UsrAddrWord_ok <= U_UsrAddrWord_r2 when I_LAT_RD_DATA=0 and I_ModeRead='1' else -- In show-ahead mode, for read-side, add two clock cycles to see write pointer (see [Note 5])
		                    U_UsrAddrWord;
	end generate bin_single;
end block U_UsrWord;
--**************************************************************************************************
-- Number of used bits management (DPS = 2^n)
--**************************************************************************************************
UsedBit : if GEN_USED_BIT generate
begin
	l : entity work.buffer2ck_UsedBit generic map
		( CIRCULAR               => CIRCULAR                        --boolean                                          := false      -- Circular mode for write operations
		, CLOCK_MODE             => CLOCK_MODE                      --string                                                         -- "Single" / "Dual"
		, I_APS                  => I_APS                           --natural                                          :=  8         -- Address Path Size
		, I_DPS                  => I_DPS                           --natural                                          := 16         -- Data    Path Size
		, I_LAT_RD_DATA          => I_LAT_RD_DATA                   --natural range 0 to 2                             :=  2         -- Physical memory read latency (between its address and data)
		, PW_ALIGN               => PW_ALIGN                        --positive                                                       -- Partial Write / Granularity for number of bits to write
		, PW_ENABLE              => PW_ENABLE                       --boolean                                                        -- Partial Write / Enable this kind of operations
		, U_APS                  => U_APS                           --natural                                          :=  7         -- Address Path Size
		, U_DPS                  => U_DPS                           --natural                                          := 32         -- Data    Path Size
		) port map                                                  --                                                               --
		( I_Dmn                  => I_Dmn                           --in  domain                                                     -- Reset/clock/clock enable
		, c_UsedBit              => c_UsedBit                       --out slv(I_APS+Log2(I_DPS)           downto 0)                  -- Number of bits
		, c_UsedWord             => c_UsedWord                      --out slv(I_APS                       downto 0)                  -- Number of words
		, c_UsrAddrBitNext       => c_UsrAddrBitNext                --in  slv(I_APS+Log2(I_DPS)           downto 0)                  -- User   address / next value
		, I_LclAddrBit_c         => I_LclAddrBit_c                  --in  slv(I_APS+Log2(I_DPS)           downto 0)                  -- "True" memory pointer address, BIT  pointer (combinational value)
		, I_ModeRead             => I_ModeRead                      --in  sl                                                         -- This side is in Read     Mode
		, I_ModeWrite            => I_ModeWrite                     --in  sl                                                         -- This side is in Write    Mode
		, I_sRst                 => I_sRst                          --in  sl                                                         -- Synchronous reset
		, I_UsedBit_PW           => I_UsedBit_PW                    --out slv(      Log2(I_DPS)           downto 0)                  -- Number of BIT  in partial-write module
		, pw_pos_mux             => pw_pos_mux                      --in  slv(Log2(2*I_DPS/PW_ALIGN)-2    downto 0)                  -- Mux position for partial write (equivalent to number of bits * PW_ALIGN)
		, U_RdSkipBit            => U_RdSkipBit                     --in  slv(U_APS+Log2(U_DPS)           downto 0)                  -- Number of BIT  to read-skip
		, U_UsrAddrBit_ok        => U_UsrAddrBit_ok                 --in  slv(U_APS+Log2(U_DPS)           downto 0)                  -- User   pointer address, always good version (resynchronization or delay or direct, according to configuration)
		, I_iEmpty               => I_iEmpty                        --out sl                                                         -- Empty
		);

	main : process(I_Dmn)
	begin
	if I_Dmn.rst='1' then
		I_iUsedBit <= (others=>'0');
	elsif I_Dmn.ena='0' then null;
	elsif rising_edge(I_Dmn.clk) then
		I_iUsedBit <= c_UsedBit;
	end if;
	end process main;

	-- Reduce register count by using MSB of bit counter
	I_iUsedWord  <= msb(I_iUsedBit,I_iUsedWord'length);
end generate UsedBit;

UsedBit_noinst : if not(GEN_USED_BIT) generate
begin
	I_UsedBit_PW <= (others=>'0');
	I_iUsedBit   <= (others=>'0');
	c_UsedBit    <= (others=>'0');
end generate UsedBit_noinst;
--**************************************************************************************************
-- Number of used words management (DPS /= 2^n)
--**************************************************************************************************
UsedWord : if GEN_USED_WORD generate
begin
	l : entity work.buffer2ck_UsedWord generic map
		( CIRCULAR               => CIRCULAR                        --boolean                                          := false      -- Circular mode for write operations
		, I_APS                  => I_APS                           --natural                                          :=  8         -- Address Path Size
		, I_DPS                  => I_DPS                           --natural                                          := 16         -- Data    Path Size
		, I_LAT_RD_DATA          => I_LAT_RD_DATA                   --natural range 0 to 2                             :=  2         -- Physical memory read latency (between its address and data)
		, PW_ENABLE              => PW_ENABLE                       --boolean                                                        -- Partial Write / Enable this kind of operations
		, U_APS                  => U_APS                           --natural                                          :=  7         -- Address Path Size
		) port map                                                  --                                                               --
		( I_Dmn                  => I_Dmn                           --in  domain                                                     -- Reset/clock/clock enable
		, c_UsedWord             => c_UsedWord                      --out slv(I_APS                       downto 0)                  -- Number of words
		, c_UsrAddrWordNext      => c_UsrAddrWordNext               --in  slv(I_APS                       downto 0)                  -- User   address / next value
		, I_LclAddrWord_c        => I_LclAddrWord_c                 --in  slv(I_APS                       downto 0)                  -- "True" memory pointer address, WORD pointer (combinational value)
		, I_ModeRead             => I_ModeRead                      --in  sl                                                         -- This side is in Read     Mode
		, I_ModeWrite            => I_ModeWrite                     --in  sl                                                         -- This side is in Write    Mode
		, I_sRst                 => I_sRst                          --in  sl                                                         -- Synchronous reset
		, U_UsrAddrWord_ok       => U_UsrAddrWord_ok                --in  slv(U_APS                       downto 0)                  -- User   pointer address, always good version (resynchronization or delay or direct, according to configuration)
		, I_iEmpty               => I_iEmpty                        --out sl                                                         -- Empty
		);

	main : process(I_Dmn)
	begin
	if I_Dmn.rst='1' then
		I_iUsedWord <= (others=>'0');
	elsif I_Dmn.ena='0' then null;
	elsif rising_edge(I_Dmn.clk) then
		I_iUsedWord  <= c_UsedWord;
	end if;
	end process main;
end generate UsedWord;

UsedWord_noinst : if not(GEN_USED_BIT) and not(GEN_USED_WORD) generate
begin
	I_iEmpty    <=          '0' ;
	I_iUsedWord <= (others=>'0');
	c_UsedWord  <= (others=>'0');
end generate UsedWord_noinst;
--**************************************************************************************************
-- Ready
--**************************************************************************************************
Ready : entity work.buffer2ck_Ready generic map
	( ID_I                   => ID_I                    --string                                                         -- "A" / "B"
	, ID_U                   => ID_U                    --string                                                         -- "A" / "B"
	, I_APS                  => I_APS                   --natural                                                        -- Address Path Size
	, I_DPS                  => I_DPS                   --natural                                                        -- Data    Path Size
	, U_APS                  => U_APS                   --natural                                                        -- Address Path Size
	, U_DPS                  => U_DPS                   --natural                                                        -- Data    Path Size
	, PW_ENABLE              => PW_ENABLE               --boolean                                                        -- Partial Write / Enable this kind of operations
	, PR_ENABLE              => PR_ENABLE               --boolean                                       := false         -- Partial Read  / Enable this kind of operations
	) port map                                          --                                                               --
	( I_Dmn                  => I_Dmn                   --in  domain                                                     -- Reset/clock/clock enable
	, I_sRst                 => I_sRst                  --in  sl                                                         -- Synchronous reset
	, I_LclAddrBit           => I_LclAddrBit            --in  slv(I_APS+Log2(I_DPS)        downto 0)                     -- "True" memory pointer address, BIT  pointer (comb/reg according to I_LAT_RD_ADDR)
	, U_UsrAddrBit           => U_UsrAddrBit            --in  slv(U_APS+Log2(U_DPS)        downto 0)                     -- User   BIT  address pointer, binary for Single clock, gray for Dual clock
	, I_Ready                => I_Ready                 --out sl                                                         -- Buffer is ready to operate (cleared on reset)
	);
--**************************************************************************************************
-- Overflow
--**************************************************************************************************
overflow : if CREATE_OWN generate
begin
	l : entity work.buffer2ck_overflow generic map
		( CIRCULAR               => CIRCULAR                --boolean                                                        -- Circular mode for write operations
		, I_DPS                  => I_DPS                   --natural                                                        -- Data    Path Size
		, U_DPS                  => U_DPS                   --natural                                                        -- Data    Path Size
		) port map                                          --
		( I_Dmn                  => I_Dmn                   --in  domain                                                     -- Reset/clock/clock enable
		, I_sRst                 => I_sRst                  --in  sl                                                         -- Synchronous reset
		, I_iFull	             => I_iFull	                --in  sl                                                         -- Full
		, I_WrReq                => I_WrReq                 --in  sl                                                         -- Write Request                   . Available only when PW_ENABLE = false
		, U_iOverFlow_r	         => U_iOverFlow_r           --in  sl                                                         -- Overflow, on U side
		, U_RdReq                => U_RdReq                 --in  sl                                                         -- Read Request
		, I_OverFlow             => I_OverFlow              --out sl                                                         -- Buffer has encountered an OverFlow  since last synchronous reset
		);
end generate overflow;

overflow_noinst : if not(CREATE_OWN) generate
begin
	I_OverFlow <= '0';
end generate overflow_noinst;
--**************************************************************************************************
-- UnderFlow
--**************************************************************************************************
underflow : if CREATE_OWN generate
begin
	l : entity work.buffer2ck_underflow generic map
		( CLOCK_MODE             => CLOCK_MODE              --string                                                         -- "Single" / "Dual"
		) port map                                          --
		( I_Dmn                  => I_Dmn                   --in  domain                                                     -- Reset/clock/clock enable
		, I_sRst                 => I_sRst                  --in  sl                                                         -- Synchronous reset
		, I_iEmpty               => I_iEmpty                --in  sl                                                         -- Empty
		, I_RdReq                => I_RdReq                 --in  sl                                                         -- Read Request from THIS  side
		, U_RdReq                => U_RdReq                 --in  sl                                                         -- Read Request from OTHER side
		, U_iUnderFlow_r         => U_iUnderFlow_r          --in  sl                                                         -- UnderFlow from OTHER side, already resynchronized
		, I_UnderFlow            => I_UnderFlow             --out sl                                                         -- Buffer has encountered an UnderFlow since last synchronous reset
		);
end generate underflow;

underflow_noinst : if not(CREATE_OWN) generate
begin
	I_UnderFlow <= '0';
end generate underflow_noinst;
--**************************************************************************************************
-- Flags received from OTHER side
--**************************************************************************************************
flags_rx : if SEND_FLAG generate
begin
	main : process(I_Dmn)
	begin
	if I_Dmn.rst='1' then
		U_iOverFlow_r  <= '0';
		U_iUnderFlow_r <= '0';
	elsif I_Dmn.ena='0' then null;
	elsif rising_edge(I_Dmn.clk) then
		U_iOverFlow_r  <= U_iOverFlow ;
		U_iUnderFlow_r <= U_iUnderFlow;
	end if;
	end process main;
end generate flags_rx;

flags_rx_noinst : if not(SEND_FLAG) generate
begin
	U_iOverFlow_r  <= '0';
	U_iUnderFlow_r <= '0';
end generate flags_rx_noinst;
--**************************************************************************************************
-- Write Data
--**************************************************************************************************
wr_noinst : if StrEq(I_MODE,"RO") generate
begin
	pw_pos_mux   <= (others=>'0');
	pw_WrReq     <=          '0' ;
	I_iMemWr     <=          '0' ;
	I_iMemWrData <= (others=>'0');
end generate wr_noinst;

wr_full : if (StrEq(I_MODE,"WO") or StrEq(I_MODE,"RW")) and not(PW_ENABLE) generate
begin
	l : entity work.buffer2ck_wr_full generic map
		( I_DPS                  => I_DPS                           --natural                                          := 16         -- Data    Path Size
		, PW_ALIGN               => PW_ALIGN                        --positive                                                       -- Partial Write / Granularity for number of bits to write
		) port map                                                  --                                                               --
		( I_Dmn                  => I_Dmn                           --in  domain                                                     -- Reset/clock/clock enable
		, I_iMemWr               => I_iMemWr                        --out sl                                                         -- Physical Memory / Memory write command
		, I_iMemWrData           => I_iMemWrData                    --out slv(I_DPS   -1                  downto 0)                  -- Physical Memory / Write Data
		, I_sRst                 => I_sRst                          --in  sl                                                         -- Synchronous reset
		, I_WrData               => I_WrData                        --in  slv(     I_DPS          -1      downto 0)                  -- Write Data
		, I_WrReq                => I_WrReq                         --in  sl                                                         -- Write Request                   . Available only when PW_ENABLE = false
		, pw_pos_mux             => pw_pos_mux                      --out slv(Log2(2*I_DPS/PW_ALIGN)-2    downto 0)                  -- Mux position for partial write (equivalent to number of bits * PW_ALIGN)
		, pw_WrReq               => pw_WrReq                        --out sl                                                         -- Partial Write / Memory write request (full data)
		);
end generate wr_full;

wr_partial : if StrEq(I_MODE,"WO") and PW_ENABLE generate
begin
	l : entity work.buffer2ck_wr_partial generic map
		( I_DPS                  => I_DPS                           --natural                                          := 16         -- Data    Path Size
		, PW_ALIGN               => PW_ALIGN                        --positive                                                       -- Partial Write / Granularity for number of bits to write
		, PW_ALIGN_SIDE          => PW_ALIGN_SIDE                   --string                                           := "right"    -- Partial Write / Data input is right aligned
		) port map                                                  --                                                               --
		( I_Dmn                  => I_Dmn                           --in  domain                                                     -- Reset/clock/clock enable
		, I_iMemWr               => I_iMemWr                        --out sl                                                         -- Physical Memory / Memory write command
		, I_iMemWrData           => I_iMemWrData                    --out slv(I_DPS   -1                  downto 0)                  -- Physical Memory / Write Data
		, I_WrData               => I_WrData                        --in  slv(     I_DPS          -1      downto 0)                  -- Write Data
		, I_WrQnt                => I_WrQnt                         --in  slv(Log2(I_DPS)                 downto 0)                  -- Write Request Quantity (in bits). Available only when PW_ENABLE = true
		, pw_pos_mux             => pw_pos_mux                      --out slv(Log2(2*I_DPS/PW_ALIGN)-2    downto 0)                  -- Mux position for partial write (equivalent to number of bits * PW_ALIGN)
		, pw_WrReq               => pw_WrReq                        --out sl                                                         -- Partial Write / Memory write request (full data)
		);
end generate wr_partial;

I_MemWr     <= I_iMemWr    ;
I_MemWrData <= I_iMemWrData;
--**************************************************************************************************
-- Read Request and Read Data
--**************************************************************************************************
rd_lat_0_full : if I_LAT_RD_DATA=0 and not(PR_ENABLE) generate
begin
	l : entity work.buffer2ck_rd_lat_0_full generic map
		( I_APS                  => I_APS                           --natural                                          :=  8         -- Address Path Size
		, I_DPS                  => I_DPS                           --natural                                          := 16         -- Data    Path Size
		, USE_BE                 => USE_BE                          --boolean                                          := false      -- Save ByteEnable inside fifo
		) port map                                                  --                                                               --
		( I_Dmn                  => I_Dmn                           --in  domain                                                     -- Reset/clock/clock enable
		, c_UsedWord             => c_UsedWord                      --in  slv(I_APS                       downto 0)                  -- Number of words
		, I_iRdReq               => I_iRdReq                        --out sl                                                         -- Internal Read Request (special handling for Show-Ahead mode)
		, I_MemRdBE              => I_MemRdBE                       --in  slv(Maxi(I_DPS/8        -1,0)   downto 0)                  -- Physical Memory / Read Byte Enable
		, I_MemRdData            => I_MemRdData                     --in  slv(I_DPS   -1                  downto 0)                  -- Physical Memory / Read Data
		, I_ModeRead             => I_ModeRead                      --in  sl                                                         -- This side is in Read     Mode
		, I_RdAck                => I_RdAck                         --out sl                                                         -- Read Acknowledge
		, I_RdBe                 => I_RdBe                          --out slv(Maxi(I_DPS/8        -1,0)   downto 0)                  -- Read ByteEnable
		, I_RdData               => I_RdData                        --out slv(     I_DPS          -1      downto 0)                  -- Read Data
		, I_RdReq                => I_RdReq                         --in  sl                                                         -- Read Request
		, I_sRst                 => I_sRst                          --in  sl                                                         -- Synchronous reset
		);
end generate rd_lat_0_full;

rd_lat_0_partial_start0 : if I_LAT_RD_DATA=0 and PR_ENABLE and not(PR_AUTO_START) generate
begin
	l : entity work.buffer2ck_rd_lat_0_partial_start0 generic map
		( I_APS                  => I_APS                           --natural                                          :=  8         -- Address Path Size
		, I_DPS                  => I_DPS                           --natural                                          := 16         -- Data    Path Size
		, PR_ALIGN               => PR_ALIGN                        --int                                              :=  8         -- Partial Read  / Granularity for number of bits to read
		, PR_ALIGN_SIDE          => PR_ALIGN_SIDE                   --string                                           := "right"    -- Partial Read  / Data ouput is right aligned
		) port map                                                  --                                                               --
		( I_Dmn                  => I_Dmn                           --in  domain                                                     -- Reset/clock/clock enable
		, I_iMemAddr             => I_iMemAddr                      --in  slv(I_APS                       downto 0)                  -- Physical Memory / Address
		, I_iRdReq               => I_iRdReq                        --out sl                                                         -- Internal Read Request (special handling for Show-Ahead mode)
		, I_LclAddrBit           => I_LclAddrBit                    --in  slv(I_APS+Log2(I_DPS)           downto 0)                  -- "True" memory pointer address, BIT  pointer (comb/reg according to I_LAT_RD_ADDR)
		, I_MemRdData            => I_MemRdData                     --in  slv(I_DPS   -1                  downto 0)                  -- Physical Memory / Read Data
		, I_RdAck                => I_RdAck                         --out sl                                                         -- Read Acknowledge
		, I_RdBe                 => I_RdBe                          --out slv(Maxi(I_DPS/8        -1,0)   downto 0)                  -- Read ByteEnable
		, I_RdData               => I_RdData                        --out slv(     I_DPS          -1      downto 0)                  -- Read Data
		, I_RdSkipBit            => I_RdSkipBit                     --in  slv(I_APS+Log2(I_DPS)           downto 0)                  -- Number of BIT  to read-skip
		);
end generate rd_lat_0_partial_start0;

rd_lat_1_partial_start1 : if I_LAT_RD_DATA=0 and PR_ENABLE and PR_AUTO_START generate
begin
	assert false report "[buffer2ck] : Unsupported configuration !!" severity failure;
end generate rd_lat_1_partial_start1;

rd_lat_1 : if I_LAT_RD_DATA=1 and (I_MODE="RW" or I_MODE="RO") generate
	I_iRdReq <= I_RdReq    ; -- Transmit Read Request
	I_RdData <= I_MemRdData;
	I_RdBe   <= I_MemRdBE when USE_BE else (others=>'1'); -- Force ByteEnable to active when not using them
	I_RdAck  <= I_RdReq_r;
end generate rd_lat_1;

rd_lat_2 : if I_LAT_RD_DATA=2 and (I_MODE="RW" or I_MODE="RO") generate
	I_iRdReq <= I_RdReq    ; -- Transmit Read Request
	I_RdData <= I_MemRdData;
	I_RdBe   <= I_MemRdBE when USE_BE else (others=>'1'); -- Force ByteEnable to active when not using them
	I_RdAck  <= I_RdReq_rr;
end generate rd_lat_2;

rd_lat_null : if I_MODE="WO" generate
	I_iRdReq <=          '0' ;
	I_RdData <= (others=>'0');
	I_RdBe   <= (others=>'0');
	I_RdAck  <=          '0' ;
end generate rd_lat_null;
--**************************************************************************************************
--
--**************************************************************************************************
--synthesis translate_off
-- I_RdData and I_RdBe are driven to 'X' when buses are not valid (only for I_LAT_RD_DATA=1 or I_LAT_RD_DATA=2)
I_RdData <= (others=>'Z') when not(MAKE_X)
       else (others=>'X') when (I_LAT_RD_DATA=1 and I_RdReq_r='0') or (I_LAT_RD_DATA=2 and I_RdReq_rr='0')
       else (others=>'Z');

I_RdBe   <= (others=>'Z') when not(MAKE_X)
       else (others=>'X') when (I_LAT_RD_DATA=1 and I_RdReq_r='0') or (I_LAT_RD_DATA=2 and I_RdReq_rr='0')
       else (others=>'Z');
--synthesis translate_on

--synthesis translate_off
simu : if CREATE_OWN generate
	signal          I_UnderResetting : boolean := false; -- I side is in reset operation
begin
	-- Version 5.04.05
	process(I_Dmn)
	begin
	if rising_edge(I_Dmn.clk) then
		assert I_Dmn.rst='0' or I_Dmn.rst='1' report "[buffer2ck] : Illegal 'I_Dmn.rst' value !!" severity failure;
	end if;
	end process;

	process(I_Dmn)
	begin
	if I_Dmn.ena='0' then null;
	elsif rising_edge(I_Dmn.clk) then
		if I_iUsedWord>2**I_APS and not(I_UnderResetting) then
			report "[buffer2ck] : Illegal Write operation to a full buffer (Overflow on " & ID_I & " side) !!" severity SEV_LVL_FULL;
		end if;

		if I_iUsedWord=0 and (I_RdReq='1' or (StrEq(CLOCK_MODE,"Single") and U_RdReq='1')) then
			report "[buffer2ck] : Illegal Read opearation from an empty buffer (Underflow on " & ID_I & " side) !!" severity SEV_LVL_EMPTY;
		end if;
	end if;
	end process;

	process(I_Clr)
	begin
	if falling_edge(I_Clr) then
		assert I_LclAddrBit_r=0 report "[buffer2ck] : port '" & ID_I & "' is not correctly reset (I_LclAddrBit_r is non-null) !!" severity failure;
	end if;
	end process;

	p_I_UnderReseting : process(all)
	begin
		   if rising_edge(I_Dmn.clk) and I_LclAddrBit_r=0 then I_UnderResetting <= false;         -- End       of the reset
		elsif rising_edge(I_Clr)                      then I_UnderResetting <= true ; end if; -- Beginning of the reset

		if I_UnderResetting and (I_RdReq='1' or I_WrReq='1' or I_RdSkipBit/=0) then
			report "[buffer2ck] : The " & ID_I & "-side is not correctly reset (" & ID_I & "_Addr is non-null) !!" severity failure;
		end if;
	end process p_I_UnderReseting;
end generate simu;
--synthesis translate_on

end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;
--synthesis translate_off
use     work.pkg_simu.all;
--synthesis translate_on

entity buffer2ck is generic
	( CLOCK_MODE      : string                                                         -- "Single" / "Dual"
	; DEVICE          : string                                        := "Stratix"     -- Target Device
	; RAM_BLOCK_TYPE  : string                                        := "AUTO"        -- "M512", "M4K", "M-RAM", "AUTO"
	; BYTE_MODE       : natural range 8 to 9                          := 8             -- Size for one "byte". If 9, use extra-bit from Memory block
	; RAW_DPS         : boolean                                       := false         -- Enable all datapath size (but in this case, both sides shall have the same size)
	                                                                                   --
	; A_APS           : natural                                       :=  8            -- Address Path Size
	; A_DPS           : natural                                       := 16            -- Data    Path Size
	; A_MODE          : string                                        := "WO"          -- WO / RO / RW (Write Only / Read Only / Read & Write)
	; A_LAT_RD_DATA   : natural range 0 to 2                          :=  2            -- Physical memory read latency (between its address and data)
	; A_LVL_FULL      : integer                                       :=  0            -- Level to report buffer as full
	                                                                                   --
	; B_APS           : natural                                       :=  7            -- Address Path Size
	; B_DPS           : natural                                       := 32            -- Data    Path Size
	; B_MODE          : string                                        := "RO"          -- WO / RO / RW (Write Only / Read Only / Read & Write)
	; B_LVL_FULL      : integer                                       :=  0            -- Level to report buffer as full
	; B_LAT_RD_ADDR   : integer range 0 to 1                          :=  1            -- 0 : memory read address bus is combinational / 1 : memory read address bus is registered
	; B_LAT_RD_DATA   : natural range 0 to 2                          :=  2            -- Physical memory read latency (between its address and data)
	                                                                                   --
	; CIRCULAR        : boolean                                       := false         -- Circular mode for write operations
	; SEND_FLAG       : boolean                                       := false         -- Does an Overflow/Underflow is sent to other side ?
	; USE_BE          : boolean                                       := false         -- Save ByteEnable inside fifo
	                                                                                   --
	; PR_ENABLE       : boolean                                       := false         -- Partial Read  / Enable this kind of operations
	; PR_ALIGN        : int                                           :=  8            -- Partial Read  / Granularity for number of bits to read
	; PR_ALIGN_SIDE   : string                                        := "right"       -- Partial Read  / Data ouput is right aligned
	; PR_AUTO_START   : boolean                                       := false         -- Partial Read  / Very first RdSkip is done automatically with a null value
	                                                                                   --
	; PW_ENABLE       : boolean                                       := false         -- Partial Write / Enable this kind of operations
	; PW_ALIGN        : int                                           :=  8            -- Partial Write / Granularity for number of bits to write
	; PW_ALIGN_SIDE   : string                                        := "right"       -- Partial Write / Data input is right aligned
	  --synthesis translate_off                                                        --
	; MAKE_X          : boolean                                       := true          -- Make conflict when data are not valid
	; SEV_LVL_EMPTY   : severity_level                                := failure       -- Severity level for empty fifo
	; SEV_LVL_FULL    : severity_level                                := failure       -- Severity level for full  fifo
	; VERBOSE         : boolean                                       := false         -- Display debug messages
	  --synthesis translate_on                                                         --
	); port                                                                            --
	( -- port A                                                                        --
	  A_Dmn           : in  domain                                    := DOMAIN_OPEN   -- Reset/clock/clock enable
	; A_Clr           : in  sl                                        :=          '0'  -- Clear buffer
	; A_Ready         : out sl                                                         -- Buffer is ready to operate (cleared on reset)
	; A_UsedWord      : out slv(A_APS                       downto 0)                  -- Number of words for this side (msb <=> full)
	; A_UsedByte      : out slv(A_APS+Log2(A_DPS/BYTE_MODE) downto 0)                  -- Number of bytes for this side (msb <=> full)
	; A_UsedBit       : out slv(A_APS+Log2(A_DPS          ) downto 0)                  -- Number of bits  for this side (msb <=> full)
	; A_UsedByte_PW   : out slv(      Log2(A_DPS/BYTE_MODE) downto 0)                  -- Number of bytes in partial-write module
	; A_UsedBit_PW    : out slv(      Log2(A_DPS)           downto 0)                  -- Number of bits  in partial-write module
	; A_Empty         : out sl                                                         -- Buffer is empty
	; A_Full          : out sl                                                         -- Buffer is full
	; A_OverFlow      : out sl                                                         -- Buffer has encountered an OverFlow  since last synchronous reset
	; A_UnderFlow     : out sl                                                         -- Buffer has encountered an UnderFlow since last synchronous reset
	; A_RWn           : in  sl                                        :=          '0'  -- Direction (default is Write)
	                                                                                   --
	; A_WrReq         : in  sl                                        :=          '0'  -- Write Request                   . Available only when PW_ENABLE = false
	; A_WrQnt         : in  slv(Log2(A_DPS)                 downto 0) := (others=>'0') -- Write Request Quantity (in bits). Available only when PW_ENABLE = true
	; A_WrData        : in  slv(     A_DPS          -1      downto 0) := (others=>'0') -- Write Data
	; A_WrBE          : in  slv(Maxi(A_DPS/8        -1,0)   downto 0) := (others=>'0') -- Write ByteEnable (useless if BYTE_MODE=9)
	; A_RdReq         : in  sl                                        :=          '0'  -- Read Request
	; A_RdAck         : out sl                                                         -- Read Acknowledge
	; A_RdData        : out slv(     A_DPS          -1      downto 0)                  -- Read Data
	; A_RdBE          : out slv(Maxi(A_DPS/8        -1,0)   downto 0)                  -- Read ByteEnable (useless if BYTE_MODE=9)
	; A_RdSKipBit     : in  slv(A_APS+Log2(A_DPS)           downto 0) := (others=>'0') -- Number of BIT  to read-skip
	; A_RdSkipWord    : in  slv(A_APS                       downto 0) := (others=>'0') -- Number of WORD to read-skip
	  -- port B                                                                        --
	; B_Dmn           : in  domain                                    := DOMAIN_OPEN   -- Asynchronous reset
	; B_Clr           : in  sl                                        :=          '0'  -- Clear buffer
	; B_Ready         : out sl                                                         -- Buffer is ready to operate (cleared on reset)
	; B_UsedWord      : out slv(B_APS                       downto 0)                  -- Number of words for this side (msb <=> full). See [Note 5]
	; B_UsedByte      : out slv(B_APS+Log2(B_DPS/BYTE_MODE) downto 0)                  -- Number of bytes for this side (msb <=> full). See [Note 5]
	; B_UsedBit       : out slv(B_APS+Log2(B_DPS          ) downto 0)                  -- Number of bits  for this side (msb <=> full). See [Note 5]
	; B_Empty         : out sl                                                         -- Buffer is empty
	; B_Full          : out sl                                                         -- Buffer is full
	; B_OverFlow      : out sl                                                         -- Buffer has encountered an OverFlow  since last synchronous reset
	; B_UnderFlow     : out sl                                                         -- Buffer has encountered an UnderFlow since last synchronous reset
	; B_RWn           : in  sl                                        :=          '1'  -- Direction (default is Read)
	                                                                                   --
	; B_WrReq         : in  sl                                        :=          '0'  -- Write Request
	; B_WrData        : in  slv(     B_DPS          -1      downto 0) := (others=>'0') -- Write Data
	; B_WrBE          : in  slv(Maxi(B_DPS/8        -1,0)   downto 0) := (others=>'0') -- Write ByteEnable (useless if BYTE_MODE=9)
	; B_RdReq         : in  sl                                        :=          '0'  -- Read Request
	; B_RdAck         : out sl                                                         -- Read Acknowledge
	; B_RdData        : out slv(     B_DPS          -1      downto 0)                  -- Read Data
	; B_RdBE          : out slv(Maxi(B_DPS/8        -1,0)   downto 0)                  -- Read ByteEnable (useless if BYTE_MODE=9)
	; B_RdSkipBit     : in  slv(B_APS+Log2(B_DPS)           downto 0) := (others=>'0') -- Number of BIT  to read-skip
	; B_RdSkipWord    : in  slv(B_APS                       downto 0) := (others=>'0') -- Number of WORD to read-skip
	);
end entity buffer2ck;

architecture rtl of buffer2ck is
	function BCreateOwn return boolean is
	begin
		if B_LAT_RD_DATA=0          then return true; end if;
		if StrEq(CLOCK_MODE,"Dual") then return true; end if;
		return false;
	end function BCreateOwn;

	-- Port A
	constant        A_CREATE_OWN    : boolean                         := true      ; -- Create its own full dedicated logic (counters & flags)
	signal          A_AddrBit       : slv(A_APS+Log2(A_DPS) downto 0)              ; -- Memory address pointer, binary for Single clock, gray for Dual clock
	signal          A_Clr_t         : sl                                           ; -- Clear toggle
	signal          A_iOverFlow     : sl                                           ; -- Overflow
	signal          A_iUnderFlow    : sl                                           ; -- Underflow
	signal          A_iUsedBit      : slv(A_APS+Log2(A_DPS) downto 0)              ; -- Number of BIT  for this side
	signal          A_iUsedBit_PW   : slv(Log2(A_DPS)       downto 0)              ; -- Number of BIT  in partial-write module
	signal          A_iUsedWord     : slv(A_APS             downto 0)              ; -- Number of WORD for this side
	signal          A_iEmpty        : sl                                           ; -- Buffer is empty
	signal          A_iFull         : sl                                           ; -- Buffer is full
	signal          A_iReady        : sl                                           ; -- Buffer is ready to operate (cleared on reset)
	signal          A_MemAddr       : slv(A_APS             downto 0)              ; -- Memory pointer address
	signal          A_MemRdBE       : slv(Maxi(A_DPS/8-1,0) downto 0)              ; -- Memory block read BE
	signal          A_MemRdData     : slv(A_DPS  -1         downto 0)              ; -- Memory block read data
	signal          A_MemWr         : sl                                           ; -- Memory write command
	signal          A_MemWrBE       : slv(Maxi(A_DPS/8-1,0) downto 0)              ; -- Memory block write BE
	signal          A_MemWrData     : slv(A_DPS  -1         downto 0)              ; -- Memory block write data
	signal          A_RdDestroyBit  : slv(Log2(A_DPS)       downto 0)              ; -- Number of BIT  to destroy (circular mode)
	signal          A_RdDestroyWord : sl                                           ; -- Number of WORD to destroy (circular mode, DPS/=2^n -> can only destroy 1 word, see [Note 6])
	signal          A_UsrAddrBit    : slv(A_APS+Log2(A_DPS) downto 0)              ; -- User   BIT  address pointer, binary for Single clock, gray for Dual clock
	signal          A_UsrAddrWord   : slv(A_APS             downto 0)              ; -- User   WORD address pointer, binary for Single clock, gray for Dual clock
	signal          A_WrReqEna      : sl                                           ; -- Write request masked with clock enable
	-- Port B
	constant        B_CREATE_OWN    : boolean                         := BCreateOwn; -- Create its own full dedicated logic (counters & flags)
	signal          B_AddrBit       : slv(B_APS+Log2(B_DPS) downto 0)              ; -- Memory address pointer, binary for Single clock, gray for Dual clock
	signal          B_Clr_t         : sl                                           ; -- Clear toggle
	signal          B_iOverFlow     : sl                                           ; -- Overflow
	signal          B_iUnderFlow    : sl                                           ; -- Underflow
	signal          B_iUsedBit      : slv(B_APS+Log2(B_DPS) downto 0)              ; -- Number of BIT  for this side
	signal          B_iUsedWord     : slv(B_APS             downto 0)              ; -- Number of WORD for this side
	signal          B_iEmpty        : sl                                           ; -- Buffer is empty
	signal          B_iFull         : sl                                           ; -- Buffer is full
	signal          B_iReady        : sl                                           ; -- Buffer is ready to operate (cleared on reset)
	signal          B_MemAddr       : slv(B_APS             downto 0)              ; -- Memory pointer address
	signal          B_MemRdBE       : slv(Maxi(B_DPS/8-1,0) downto 0)              ; -- Memory block read BE
	signal          B_MemRdData     : slv(B_DPS  -1         downto 0)              ; -- Memory block read data
	signal          B_MemWr         : sl                                           ; -- Memory write command
	signal          B_MemWrBE       : slv(Maxi(B_DPS/8-1,0) downto 0)              ; -- Memory block write BE
	signal          B_MemWrData     : slv(B_DPS  -1         downto 0)              ; -- Memory block write data
	signal          B_RdDestroyBit  : slv(Log2(B_DPS)       downto 0)              ; -- Number of BIT  to destroy (circular mode)
	signal          B_RdDestroyWord : sl                                           ; -- Number of WORD to destroy (circular mode, DPS/=2^n -> can only destroy 1 word, see [Note 6])
	signal          B_UsrAddrBit    : slv(B_APS+Log2(B_DPS) downto 0)              ; -- User   BIT  address pointer, binary for Single clock, gray for Dual clock
	signal          B_UsrAddrWord   : slv(B_APS             downto 0)              ; -- User   WORD address pointer, binary for Single clock, gray for Dual clock
	signal          B_WrReqEna      : sl                                           ; -- Write request masked with clock enable
begin

--**************************************************************************************************
-- A-side
--**************************************************************************************************
a : entity work.buffer2ck_half generic map
	( ID_I            => "A"             --string                                                         -- "A" / "B"
	, ID_U            => "B"             --string                                                         -- "A" / "B"
	, CLOCK_MODE      => CLOCK_MODE      --string                                        := "Dual"        -- "Single" / "Dual"
	, BYTE_MODE       => BYTE_MODE       --natural range 8 to 9                          :=  8            -- Size for one "byte". if 9, use extra-bit from Memory block
	, CREATE_OWN      => A_CREATE_OWN    --boolean                                                        -- Create its own full dedicated logic (counters & flags)
	, I_APS           => A_APS           --natural                                       :=  8            -- Address Path Size
	, I_DPS           => A_DPS           --natural                                       := 16            -- DataPath
	, I_MODE          => A_MODE          --string                                        := "RW"          -- WO / RO / RW (Write Only / Read Only / Read & Write)
	, I_LAT_RD_DATA   => A_LAT_RD_DATA   --natural range 0 to 2                          :=  2            -- Physical memory read latency (between its address and data)
	, I_LVL_FULL      => A_LVL_FULL      --integer                                       :=  0            -- Level to report buffer as full
	, U_APS           => B_APS           --natural                                       :=  7            -- Address Path Size
	, U_DPS           => B_DPS           --natural                                       := 32            -- Data    Path Size
	, U_LAT_RD_DATA   => B_LAT_RD_DATA   --natural range 0 to 2                                           -- Physical memory read latency (between its address and data)
	, CIRCULAR        => CIRCULAR        --boolean                                       := false         -- Circular mode for write operations
	, RAW_DPS         => RAW_DPS         --boolean                                                        -- Enable all datapath size (but in this case, both sides shall have the same size)
	, SEND_FLAG       => SEND_FLAG       --boolean                                       := false         -- Does an Overflow/Underflow is sent to other side ?
	, USE_BE          => USE_BE          --boolean                                       := false         -- Save ByteEnable inside fifo
	, PR_ENABLE       => false           --boolean                                       := false         -- Partial Read  / Enable this kind of operations
	, PR_ALIGN        => 0               --int                                           :=  8            -- Partial Read  / Granularity for number of bits to read
	, PR_ALIGN_SIDE   => "."             --string                                        := "right"       -- Partial Read  / Data ouput is right aligned
	, PR_AUTO_START   => false           --boolean                                       := true          -- Partial Read  / Very first RdSkip is done automatically with a null value
	, PW_ENABLE       => PW_ENABLE       --boolean                                                        -- Partial Write / Enable this kind of operations
	, PW_ALIGN        => PW_ALIGN        --positive                                                       -- Partial Write / Granularity for number of bits to write
	, PW_ALIGN_SIDE   => PW_ALIGN_SIDE   --string                                        := "right"       -- Partial Write / Data input is right aligned
	  --synthesis translate_off                                                                           --
	, MAKE_X          => MAKE_X          --boolean                                       := true          -- Make conflict when data are not valid
	, SEV_LVL_EMPTY   => SEV_LVL_EMPTY   --severity_level                                := failure       -- Severity level for empty fifo
	, SEV_LVL_FULL    => SEV_LVL_FULL    --severity_level                                := failure       -- Severity level for full  fifo
	  --synthesis translate_on                                                                            --
	) port map                                                                                            --
	( -- Port A                                                                                           --
	  I_Dmn           => A_Dmn           --in  domain                                                     -- Reset/clock/clock enable
	, I_Clr           => A_Clr           --in  sl                                                         -- Clear buffer
	, I_Ready         => A_iReady        --out sl                                                         -- Buffer is ready to operate (cleared on reset)
	, I_UsedBit       => A_iUsedBit      --out slv(I_APS+Log2(I_DPS)           downto 0)                  -- Number of BIT  for this side
	, I_UsedBit_PW    => A_iUsedBit_PW   --out slv(      Log2(I_DPS)           downto 0)                  -- Number of BIT  in partial-write module
	, I_UsedWord      => A_iUsedWord     --out slv(I_APS                       downto 0)                  -- Number of WORD for this side
	, I_Empty         => A_iEmpty        --out sl                                                         -- Buffer is empty
	, I_Full          => A_iFull         --out sl                                                         -- Buffer is full
	, I_OverFlow      => A_iOverFlow     --out sl                                                         -- Buffer has encountered an OverFlow  since last synchronous reset
	, I_UnderFlow     => A_iUnderFlow    --out sl                                                         -- Buffer has encountered an UnderFlow since last synchronous reset
	, I_RWn           => A_RWn           --in  sl                                                         -- Direction (default is Write)
	                                                                                                      --
	, I_WrReq         => A_WrReq         --in  sl                                                         -- Write Request                   . Available only when PW_ENABLE = false
	, I_WrQnt         => A_WrQnt         --in  slv(Log2(I_DPS)                 downto 0)                  -- Write Request Quantity (in bits). Available only when PW_ENABLE = true
	, I_WrData        => A_WrData        --in  slv(     I_DPS          -1      downto 0)                  -- Write Data
	, I_RdReq         => A_RdReq         --in  sl                                                         -- Read Request
	, I_RdAck         => A_RdAck         --out sl                                                         -- Read Acknowledge
	, I_RdData        => A_RdData        --out slv(I_DPS  -1                   downto 0)                  -- Read Data
	, I_RdBe          => A_RdBE          --out slv(I_DPS/8-1                   downto 0)                  -- Read ByteEnable
	, I_RdSkipBit     => A_RdSKipBit     --in  slv(I_APS+Log2(I_DPS)           downto 0)                  -- Number of BIT  to read-skip
	, I_RdSkipWord    => A_RdSkipWord    --in  slv(I_APS                       downto 0)                  -- Number of WORD to read-skip
	  -- Port B                                                                                           --
	, U_Clr           => B_Clr           --in  sl                                                         -- Clear buffer
	, U_RWn           => B_RWn           --in  sl                                                         -- Direction (default is Read)
	, U_WrReq         => B_WrReq         --in  sl                                                         -- Write Request
	, U_RdReq         => B_RdReq         --in  sl                                                         -- Read Request
	, U_RdSkipBit     => B_RdSkipBit     --in  slv(U_APS+Log2(U_DPS)           downto 0)                  -- Number of BIT  to read-skip
	, U_RdSkipWord    => B_RdSkipWord    --in  slv(U_APS                       downto 0)                  -- Number of WORD to read-skip
	  -- Internal signals                                                                                 --
	, I_Clr_t         => A_Clr_t         --out sl                                                         -- Clear toggle
	, I_UsrAddrBit    => A_UsrAddrBit    --out slv(I_APS+Log2(I_DPS)           downto 0)                  -- User   BIT  address pointer, binary for Single clock, gray for Dual clock
	, I_UsrAddrWord   => A_UsrAddrWord   --out slv(I_APS                       downto 0)                  -- User   WORD address pointer, binary for Single clock, gray for Dual clock
	, I_AddrBit       => A_AddrBit       --out slv(I_APS+Log2(I_DPS)           downto 0)                  -- Memory address pointer, binary for Single clock, gray for Dual clock
	, I_MemAddr       => A_MemAddr       --out slv(I_APS                       downto 0)                  -- Memory pointer address
	, I_MemRdBE       => A_MemRdBE       --in  slv(Maxi(I_DPS/BYTE_MODE-1,0)   downto 0)                  -- Read Byte Enable
	, I_MemRdData     => A_MemRdData     --in  slv(I_DPS   -1                  downto 0)                  -- Read Data
	, I_MemWr         => A_MemWr         --out sl                                                         -- Memory write command
	, I_MemWrData     => A_MemWrData     --out slv(I_DPS   -1                  downto 0)                  -- Write Data
	, I_RdDestroyBit  => A_RdDestroyBit  --out slv(Log2(U_DPS)                 downto 0)                  -- Number of BIT  to destroy (circular mode)
	, I_RdDestroyWord => A_RdDestroyWord --out sl                                                         -- Number of WORD to destroy (circular mode, DPS/=2^n -> can only destroy 1 word, see [Note 6])
	                                     --                                                               --
	, U_Clr_t         => B_Clr_t         --in  sl                                                         -- Clear, toggle
	, U_UsrAddrBit    => B_UsrAddrBit    --in  slv(U_APS+Log2(U_DPS)           downto 0)                  -- User   BIT  address pointer, binary for Single clock, gray for Dual clock
	, U_UsrAddrWord   => B_UsrAddrWord   --in  slv(U_APS                       downto 0)                  -- User   WORD address pointer, binary for Single clock, gray for Dual clock
	, U_AddrBit       => B_AddrBit       --in  slv(U_APS+Log2(U_DPS)           downto 0)                  -- Memory address pointer, binary for Single clock, gray for Dual clock
	, U_iOverFlow     => B_iOverFlow     --in  sl                                                         -- Overflow
	, U_iUnderFlow    => B_iUnderFlow    --in  sl                                                         -- Underflow
	, U_RdDestroyBit  => B_RdDestroyBit  --in  slv(Log2(I_DPS)                 downto 0)                  -- Number of BIT  to destroy (circular mode)
	, U_RdDestroyWord => B_RdDestroyWord --in  sl                                                         -- Number of WORD to destroy (circular mode, DPS/=2^n -> can only destroy 1 word, see [Note 6])
	);

-- Drive outputs
A_OverFlow     <= A_iOverFlow ;
A_UnderFlow    <= A_iUnderFlow;
A_UsedWord     <= A_iUsedWord;
A_UsedByte     <= msb(A_iUsedBit,A_UsedByte'length);
A_UsedBit      <= A_iUsedBit;
A_Empty        <= A_iEmpty  ;
A_Full         <= A_iFull   ;
A_Ready        <= A_iReady  ;

A_MemWrBE      <= A_WrBE  ;
A_UsedBit_PW   <=            A_iUsedBit_PW    when PW_ENABLE else (others=>'0');
A_UsedByte_PW  <= ExcludeLSB(A_iUsedBit_PW,3) when PW_ENABLE else (others=>'0');
--**************************************************************************************************
-- B-side
--**************************************************************************************************
b : entity work.buffer2ck_half generic map
	( ID_I            => "B"             --string                                                         -- "A" / "B"
	, ID_U            => "A"             --string                                                         -- "A" / "B"
	, CLOCK_MODE      => CLOCK_MODE      --string                                        := "Dual"        -- "Single" / "Dual"
	, BYTE_MODE       => BYTE_MODE       --natural range 8 to 9                          :=  8            -- Size for one "byte". if 9, use extra-bit from Memory block
	, CREATE_OWN      => B_CREATE_OWN    --boolean                                                        -- Create its own full dedicated logic (counters & flags)
	, I_APS           => B_APS           --natural                                       :=  8            -- Address Path Size
	, I_DPS           => B_DPS           --natural                                       := 16            -- DataPath
	, I_MODE          => B_MODE          --string                                        := "RW"          -- WO / RO / RW (Write Only / Read Only / Read & Write)
	, I_LAT_RD_ADDR   => B_LAT_RD_ADDR   --integer range 0 to 1                          :=  1            -- 0 : memory read address bus is combinational / 1 : memory read address bus is registered
	, I_LAT_RD_DATA   => B_LAT_RD_DATA   --natural range 0 to 2                          :=  2            -- Physical memory read latency (between its address and data)
	, I_LVL_FULL      => B_LVL_FULL      --integer                                       :=  0            -- Level to report buffer as full
	, U_APS           => A_APS           --natural                                       :=  7            -- Address Path Size
	, U_DPS           => A_DPS           --natural                                       := 32            -- DataPath
	, U_LAT_RD_DATA   => A_LAT_RD_DATA   --natural range 0 to 2                                           -- Physical memory read latency (between its address and data)
	, CIRCULAR        => CIRCULAR        --boolean                                       := false         -- Circular mode for write operations
	, RAW_DPS         => RAW_DPS         --boolean                                                        -- Enable all datapath size (but in this case, both sides shall have the same size)
	, SEND_FLAG       => SEND_FLAG       --boolean                                       := false         -- Does an Overflow/Underflow is sent to other side ?
	, USE_BE          => USE_BE          --boolean                                       := false         -- Save ByteEnable inside fifo
	, PR_ENABLE       => PR_ENABLE                                                                        --
	, PR_ALIGN        => PR_ALIGN                                                                         --
	, PR_ALIGN_SIDE   => PR_ALIGN_SIDE   --string                                        := "right"       -- Partial Read  / Data ouput is right aligned
	, PR_AUTO_START   => PR_AUTO_START                                                                    --
	, PW_ENABLE       => false           --boolean                                                        -- Partial Write / Enable this kind of operations
	, PW_ALIGN        => 1               --positive                                                       -- Partial Write / Granularity for number of bits to write
	, PW_ALIGN_SIDE   => "."             --string                                        := "right"       -- Partial Write / Data input is right aligned
	  --synthesis translate_off                                                                           --
	, MAKE_X          => MAKE_X          --boolean                                       := true          -- Make conflict when data are not valid
	, SEV_LVL_EMPTY   => SEV_LVL_EMPTY   --severity_level                                := failure       -- Severity level for empty fifo
	, SEV_LVL_FULL    => SEV_LVL_FULL    --severity_level                                := failure       -- Severity level for full  fifo
	  --synthesis translate_on                                                                            --
	) port map                                                                                            --
	( -- Port B                                                                                           --
	  I_Dmn           => B_Dmn           --in  domain                                                     -- Reset/clock/clock enable
	, I_Clr           => B_Clr           --in  sl                                                         -- Clear buffer
	, I_Ready         => B_iReady        --out sl                                                         -- Buffer is ready to operate (cleared on reset)
	, I_UsedBit       => B_iUsedBit      --out slv(I_APS+Log2(I_DPS)           downto 0)                  -- Number of BIT  for this side
	, I_UsedWord      => B_iUsedWord     --out slv(I_APS                       downto 0)                  -- Number of WORD for this side
	, I_Empty         => B_iEmpty        --out sl                                                         -- Buffer is empty
	, I_Full          => B_iFull         --out sl                                                         -- Buffer is full
	, I_OverFlow      => B_iOverFlow     --out sl                                                         -- Buffer has encountered an OverFlow  since last synchronous reset
	, I_UnderFlow     => B_iUnderFlow    --out sl                                                         -- Buffer has encountered an UnderFlow since last synchronous reset
	, I_RWn           => B_RWn           --in  sl                                                         -- Direction (default is Write)
	                                                                                                      --
	, I_WrReq         => B_WrReq         --in  sl                                                         -- Write Request                   . Available only when PW_ENABLE = false
	, I_WrQnt         => (others=>'0')   --in  slv(Log2(I_DPS)                 downto 0)                  -- Write Request Quantity (in bits). Available only when PW_ENABLE = true
	, I_WrData        => B_WrData        --in  slv(     I_DPS          -1      downto 0)                  -- Write Data
	, I_RdReq         => B_RdReq         --in  sl                                                         -- Read Request
	, I_RdAck         => B_RdAck         --out sl                                                         -- Read Acknowledge
	, I_RdData        => B_RdData        --out slv(I_DPS  -1                   downto 0)                  -- Read Data
	, I_RdBe          => B_RdBE          --out slv(I_DPS/BYTE_MODE-1           downto 0)                  -- Read ByteEnable
	, I_RdSkipBit     => B_RdSkipBit     --in  slv(I_APS+Log2(I_DPS)           downto 0)                  -- Number of BIT  to read-skip
	, I_RdSkipWord    => B_RdSkipWord    --in  slv(I_APS                       downto 0)                  -- Number of WORD to read-skip
	  -- Port A                                                                                           --
	, U_Clr           => A_Clr           --in  sl                                                         -- Clear buffer
	, U_RWn           => A_RWn           --in  sl                                                         -- Direction (default is Read)
	, U_WrReq         => A_WrReq         --in  sl                                                         -- Write Request
	, U_RdReq         => A_RdReq         --in  sl                                                         -- Read Request
	, U_RdSkipBit     => A_RdSKipBit     --in  slv(U_APS+Log2(U_DPS)           downto 0)                  -- Number of BIT  to read-skip
	, U_RdSkipWord    => A_RdSkipWord    --in  slv(U_APS                       downto 0)                  -- Number of WORD to read-skip
	  -- Internal signals                                                                                 --
	, I_Clr_t         => B_Clr_t         --out sl                                                         -- Clear toggle
	, I_UsrAddrBit    => B_UsrAddrBit    --out slv(I_APS+Log2(I_DPS)           downto 0)                  -- User   BIT  address pointer, binary for Single clock, gray for Dual clock
	, I_UsrAddrWord   => B_UsrAddrWord   --out slv(I_APS                       downto 0)                  -- User   WORD address pointer, binary for Single clock, gray for Dual clock
	, I_AddrBit       => B_AddrBit       --out slv(I_APS+Log2(I_DPS)           downto 0)                  -- Memory address pointer, binary for Single clock, gray for Dual clock
	, I_MemAddr       => B_MemAddr       --out slv(I_APS                       downto 0)                  -- Memory pointer address
	, I_MemRdBE       => B_MemRdBE       --in  slv(I_DPS/8 -1                  downto 0)                  -- Read ByteEnable
	, I_MemRdData     => B_MemRdData     --in  slv(I_DPS   -1                  downto 0)                  -- Read Data
	, I_MemWr         => B_MemWr         --out sl                                                         -- Memory write command
	, I_MemWrData     => B_MemWrData     --out slv(I_DPS   -1                  downto 0)                  -- Write Data
	, I_RdDestroyBit  => B_RdDestroyBit  --out slv(Log2(U_DPS)                 downto 0)                  -- Number of BIT  to destroy (circular mode)
	, I_RdDestroyWord => B_RdDestroyWord --out sl                                                         -- Number of WORD to destroy (circular mode, DPS/=2^n -> can only destroy 1 word, see [Note 6])
	                                     --                                                               --
	, U_Clr_t         => A_Clr_t         --in  sl                                                         -- Clear, toggle
	, U_UsrAddrBit    => A_UsrAddrBit    --in  slv(U_APS+Log2(U_DPS)           downto 0)                  -- User   BIT  address pointer, binary for Single clock, gray for Dual clock
	, U_UsrAddrWord   => A_UsrAddrWord   --in  slv(U_APS                       downto 0)                  -- User   WORD address pointer, binary for Single clock, gray for Dual clock
	, U_AddrBit       => A_AddrBit       --in  slv(U_APS+Log2(U_DPS)           downto 0)                  -- Memory address pointer, binary for Single clock, gray for Dual clock
	, U_iOverFlow     => A_iOverFlow     --in  sl                                                         -- Overflow
	, U_iUnderFlow    => A_iUnderFlow    --in  sl                                                         -- Underflow
	, U_RdDestroyBit  => A_RdDestroyBit  --in  slv(Log2(I_DPS)                 downto 0)                  -- Number of BIT  to destroy (circular mode)
	, U_RdDestroyWord => A_RdDestroyWord --in  sl                                                         -- Number of WORD to destroy (circular mode, DPS/=2^n -> can only destroy 1 word, see [Note 6])
	);

B_UsedWord  <=     B_iUsedWord                    when     RAW_DPS  and     B_CREATE_OWN  else
                   A_iUsedWord                    when     RAW_DPS  and not(B_CREATE_OWN) else
               msb(B_iUsedBit ,B_UsedWord'length) when not(RAW_DPS) and     B_CREATE_OWN  else
               msb(A_iUsedBit ,B_UsedWord'length);

B_UsedByte  <= (others=>'X')                      when RAW_DPS      else
               msb(B_iUsedBit ,B_UsedByte'length) when B_CREATE_OWN else
               msb(A_iUsedBit ,B_UsedByte'length);

B_UsedBit   <= (others=>'X')                      when RAW_DPS      else
                   B_iUsedBit                     when B_CREATE_OWN else
                   A_iUsedBit                    ;

B_Empty     <= A_iEmpty     when StrEq(CLOCK_MODE,"Single") and B_LAT_RD_DATA/=0 else B_iEmpty    ;
B_Full      <= A_iFull      when StrEq(CLOCK_MODE,"Single") and B_LAT_RD_DATA/=0 else B_iFull     ;
B_OverFlow  <= A_iOverFlow  when StrEq(CLOCK_MODE,"Single") and B_LAT_RD_DATA/=0 else B_iOverFlow ;
B_UnderFlow <= A_iUnderFlow when StrEq(CLOCK_MODE,"Single") and B_LAT_RD_DATA/=0 else B_iUnderFlow;
B_Ready     <= A_iReady     when StrEq(CLOCK_MODE,"Single") and B_LAT_RD_DATA/=0 else B_iReady    ;

B_MemWrBE   <= B_WrBE  ;
--**************************************************************************************************
-- Memory
--**************************************************************************************************
-- Yeah, it's another piece of cake... Let's go using the dedicated module
memory : block is
	function Calc_A_LAT_RD_DATA return int is
	begin
		if PW_ENABLE then return 1;
		else              return Maxi(1,A_LAT_RD_DATA); end if;
	end function Calc_A_LAT_RD_DATA;

	function Calc_A_MODE return string is
	begin
		if PW_ENABLE then return "WO";
		else              return A_MODE; end if;
	end function Calc_A_MODE;

	function Calc_B_LAT_RD_DATA return int is
	begin
		if PR_ENABLE then return 1;
		else              return Maxi(1,B_LAT_RD_DATA); end if;
	end function Calc_B_LAT_RD_DATA;

	function Calc_B_MODE return string is
	begin
		if PR_ENABLE then return "RO";
		else              return B_MODE; end if;
	end function Calc_B_MODE;
begin
	l : entity work.memory generic map
		( A_APS          => A_APS                        --natural range 0 to integer'high        :=  8            -- Address Path Size
		, A_BPS          => Maxi(1,A_DPS/8)              --natural range 0 to integer'high        :=  1            -- BE      Path Size
		, A_DPS          => A_DPS                        --natural range 0 to integer'high        := 16            -- Data    Path Size
		, A_MODE         => Calc_A_MODE                  --string                                 := "WO"          -- WO / RO / RW (Write Only / Read Only / Read & Write)
		, A_RD_LAT       => Calc_A_LAT_RD_DATA           --natural range 1 to 2                   :=  2            -- Read Latency between A_RdReq and A_RdData
		, A_RD_XTRA_REG  => false                        --boolean                                := false         -- Add extra register on read bus from memory block. This increases effective A_LAT_RD_DATA value
		, B_APS          => B_APS                        --natural range 0 to integer'high        :=  8            -- Address Path Size
		, B_BPS          => Maxi(1,B_DPS/8)              --natural range 0 to integer'high        :=  1            -- BE      Path Size
		, B_DPS          => B_DPS                        --natural range 0 to integer'high        := 16            -- Data    Path Size
		, B_MODE         => Calc_B_MODE                  --string                                 := "RO"          -- WO / RO / RW (Write Only / Read Only / Read & Write)
		, B_RD_LAT       => Calc_B_LAT_RD_DATA           --natural range 1 to 2                   :=  2            -- Read Latency between B_RdReq and B_RdData
		, B_RD_XTRA_REG  => false                        --boolean                                := false         -- Add extra register on read bus from memory block. This increases effective B_LAT_RD_DATA value
		, DEVICE         => DEVICE                       --string                                                  -- Target Device
		, RAM_BLOCK_TYPE => RAM_BLOCK_TYPE               --string                                                  -- "M512" / "M4K" / "M-RAM" / "AUTO"
		, USE_BE         => USE_BE                       --boolean                                                 -- use ByteEnable
		, BYTE_MODE      => BYTE_MODE                    --natural range 8 to 9                   := 8             -- Size for one "byte". if 9, use extra-bit from Memory block
		  --synthesis translate_off                      --                                                        --
		, VERBOSE        => VERBOSE                      --boolean                                := false         -- Display debug messages
		  --synthesis translate_on                       --                                                        --
		) port map                                       --                                                        --
		( A_Dmn          => A_Dmn                        --in  domain                                              -- Reset/clock/clock enable
		, A_Addr         => A_MemAddr(A_APS-1 downto 0)  --in  slv(A_APS-1 downto 0)              := (others=>'0') -- Address
		, A_Wr           => A_MemWr                      --in  sl                                 :=          '0'  -- Write Request
		, A_WrData       => A_MemWrData                  --in  slv(A_DPS-1 downto 0)              := (others=>'0') -- Write Data
		, A_WrBE         => A_MemWrBE                    --in  slv(A_BPS-1 downto 0)              := (others=>'1') -- Write ByteEnable
		, A_RdData       => A_MemRdData                  --out slv(A_DPS-1 downto 0)                               -- Read Data
		, A_RdBE         => A_MemRdBE                    --out slv(A_BPS-1 downto 0)                               -- Read ByteEnable
		, B_Dmn          => B_Dmn                        --in  domain                                              -- Reset/clock/clock enable
		, B_Addr         => B_MemAddr(B_APS-1 downto 0)  --in  slv(B_APS-1 downto 0)              := (others=>'0') -- Address
		, B_Wr           => B_MemWr                      --in  sl                                 :=          '0'  -- Write Request
		, B_WrData       => B_MemWrData                  --in  slv(B_DPS-1 downto 0)              := (others=>'0') -- Write Data
		, B_WrBE         => B_MemWrBE                    --in  slv(B_BPS-1 downto 0)              := (others=>'1') -- Write ByteEnable
		, B_RdData       => B_MemRdData                  --out slv(B_DPS-1 downto 0)                               -- Read Data
		, B_RdBE         => B_MemRdBE                    --out slv(B_BPS-1 downto 0)                               -- Read ByteEnable
		);
end block memory;
--**************************************************************************************************
-- Coherency controls
--**************************************************************************************************
checker : block is
begin
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Synthesis & Simulation                                                                                                                                          --
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Check that "Data Path Size" is supported                                                                                                                        --
	assert A_DPS=1 or A_DPS=2 or A_DPS=4 or A_DPS=8 or A_DPS=16 or A_DPS=32 or A_DPS=64 or A_DPS=128 or A_DPS=256                                                      --
	                                     or A_DPS=9 or A_DPS=18 or A_DPS=36 or A_DPS=72 or A_DPS=144 or A_DPS=288                                                      --
	    or RAW_DPS                                                                                                                                                     --
		report "[buffer2ck] : Unsupported data path on A-side : " &  to_Str(A_DPS)                                                                                     --
		severity failure;                                                                                                                                              --
	assert B_DPS=1 or B_DPS=2 or B_DPS=4 or B_DPS=8 or B_DPS=16 or B_DPS=32 or B_DPS=64 or B_DPS=128 or B_DPS=256                                                      --
	                                     or B_DPS=9 or B_DPS=18 or B_DPS=36 or B_DPS=72 or B_DPS=144 or B_DPS=288                                                      --
	    or RAW_DPS                                                                                                                                                     --
		report "[buffer2ck] : Unsupported data path on B-side : " &  to_Str(B_DPS)                                                                                     --
		severity failure;                                                                                                                                              --
	                                                                                                                                                                   --
	assert not(BYTE_MODE=9 and USE_BE=true)                                                                                                                            -- Version 5.04.03
		report "[buffer2ck] : ByteEnable cannot be used when BYTE_MODE=9 !!"                                                                                           --
		severity failure;                                                                                                                                              --
	                                                                                                                                                                   --
	assert not(CIRCULAR and StrEq(CLOCK_MODE,"Dual"))                                                                                                                  --
		report "[buffer2ck] : Dual clock is not compatible with circular mode !!"                                                                                      --
		severity failure;                                                                                                                                              --
	                                                                                                                                                                   --
	assert StrEq(PW_ALIGN_SIDE,"right") or StrEq(PW_ALIGN_SIDE,"left")                                                                                                 --
		report "[buffer2ck] : PW_ALIGN_SIDE illegal value : " & PW_ALIGN_SIDE                                                                                          --
		severity failure;                                                                                                                                              --
		                                                                                                                                                               --
	assert StrEq(PR_ALIGN_SIDE,"right") or StrEq(PR_ALIGN_SIDE,"left")                                                                                                 --
		report "[buffer2ck] : PR_ALIGN_SIDE illegal value : " & PR_ALIGN_SIDE                                                                                          --
		severity failure;                                                                                                                                              --
		                                                                                                                                                               --
	partial_access : if PR_ENABLE or PW_ENABLE generate                                                                                                                --
	-- Only A(Write) and B(Read) are allowed                                                                                                                           --
	begin                                                                                                                                                              --
		assert not(RAW_DPS)                                                                                                                                            --
			report "[buffer2ck] : DPS/=2^n is not supported with partiel access"                                                                                       --
			severity failure;                                                                                                                                          --
		                                                                                                                                                               --
		assert A_MODE       ="WO" report "[buffer2ck] : A_MODE shall be WO in Partial Access configuration !!"                       severity failure;                 --
		assert A_RWn        ='0'  report "[buffer2ck] : A_RWn shall be '0' in Partial Access configuration !!"                       severity failure;                 --
		assert A_RdReq      ='0'  report "[buffer2ck] : A_RdReq shall be '0' in Partial Access configuration !!"                     severity failure;                 --
		assert A_RdSKipBit  = 0   report "[buffer2ck] : A_RdSKipBit shall be 0 in Partial Access configuration !!"                   severity failure;                 --
		assert A_RdSKipWord = 0   report "[buffer2ck] : A_RdSKipWord shall be 0 in Partial Access configuration !!"                  severity failure;                 --
		assert A_LAT_RD_DATA= 2   report "[buffer2ck] : A_LAT_RD_DATA shall be 2 in Partial Access confgiuration !!"                 severity failure;                 --
		                                                                                                                                                               --
		assert B_MODE       ="RO" report "[buffer2ck] : B_MODE shall be RO in Partial Access configuration !!"                       severity failure;                 --
		assert B_RWn        ='1'  report "[buffer2ck] : B_RWn shall be '1' in Partial Access configuration !!"                       severity failure;                 --
		assert B_WrReq      ='0'  report "[buffer2ck] : B_WrReq shall be '0' in Partial Access configuration !!"                     severity failure;                 --
		assert B_RdSKipWord = 0   report "[buffer2ck] : In Partial Access configuration, use B_RdSkipBit instead of B_RdSKipWord !!" severity failure;                 --
	end generate partial_access;                                                                                                                                       --
	                                                                                                                                                                   --
	read_full_access : if not(PR_ENABLE) generate                                                                                                                      --
	begin                                                                                                                                                              --
		assert B_RdSkipBit  = 0   report "[buffer2ck] : B_RdSkipBit shall be 0 during NON Partial Read configuration !!"             severity failure;                 --
	end generate read_full_access;                                                                                                                                     --
	                                                                                                                                                                   --
	read_partial_access : if PR_ENABLE generate                                                                                                                        --
	begin                                                                                                                                                              --
		assert B_LAT_RD_ADDR= 0   report "[buffer2ck] : B_LAT_RD_ADDR shall be 0 in Partial Read configuration !!"                   severity failure;                 --
		assert B_LAT_RD_DATA= 0   report "[buffer2ck] : B_LAT_RD_DATA shall be 0 in Partial Read configuration !!"                   severity failure;                 --
	end generate read_partial_access;                                                                                                                                  --
	                                                                                                                                                                   --
	write_full_access : if not(PW_ENABLE) generate                                                                                                                     --
	begin                                                                                                                                                              --
		assert A_WrQnt=0          report "[buffer2ck] : A_WrQnt shall be 0 during NON Partial Write configuration !!"                severity failure;                 --
	end generate write_full_access;                                                                                                                                    --
	                                                                                                                                                                   --
	write_partial_access : if PW_ENABLE generate                                                                                                                       --
	begin                                                                                                                                                              --
		assert A_WrReq      ='0'  report "[buffer2ck] : A_WrReq shall be '0' in Partial Write configuration !!"                      severity failure;                 --
	end generate write_partial_access;                                                                                                                                 --
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Simulation only                                                                                                                                                 --
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--synthesis translate_off                                                                                                                                          --
	-- Check port A accesses coherency                                                                                                                                 --
	assert not(A_MODE="RO" and A_RWn='0' ) report "[buffer2ck] : Port A cannot operate in Write mode !!"                                       severity failure;       --
	assert not(A_MODE="WO" and A_RWn='1' ) report "[buffer2ck] : Port A cannot operate in Read mode !!"                                        severity failure;       --
	assert not(A_WrReq='1' and A_RWn='1' ) report "[buffer2ck] : Port A has issued a WriteRequest while in Read Mode !!"                       severity failure;       --
	assert not(A_RdReq='1' and A_RWn='0' ) report "[buffer2ck] : Port A has issued a ReadRequest while in Write Mode !!"                       severity failure;       --
                                                                                                                                                                       --
	process(A_Dmn)                                                                                                                                                     --
	begin                                                                                                                                                              --
	if rising_edge(A_Dmn.clk) then                                                                                                                                     --
		if PW_ENABLE=false and A_WrQnt/=0 then                                                                                                                         --
			printf(failure,"[buffer2ck] : Illegal partial write while PW_ENABLE=false !!");                                                                            --
		end if;                                                                                                                                                        --
	end if;                                                                                                                                                            --
	end process;                                                                                                                                                       --
                                                                                                                                                                       --
	-- Check port B accesses coherency                                                                                                                                 --
	assert not(B_MODE="RO" and B_RWn='0' ) report "[buffer2ck] : Port B cannot operate in Write mode !!"                                       severity failure;       --
	assert not(B_MODE="WO" and B_RWn='1' ) report "[buffer2ck] : Port B cannot operate in Read mode !!"                                        severity failure;       --
	assert not(B_WrReq='1' and B_RWn='1' ) report "[buffer2ck] : Port B has issued a WriteRequest while in Read Mode !!"                       severity failure;       --
	assert not(B_RdReq='1' and B_RWn='0' ) report "[buffer2ck] : Port B has issued a ReadRequest while in Write Mode !!"                       severity failure;       --
                                                                                                                                                                       --
	-- Check clocks                                                                                                                                                    --
	assert not(CLOCK_MODE="Single" and A_Dmn.clk/=B_Dmn.clk) report "[buffer2ck] : A_Clk and B_Clk shall be identical if CLOCK_MODE set to 'Single'" severity failure; --
	--synthesis translate_on
end block checker;
end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
