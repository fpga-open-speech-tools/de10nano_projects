/*--------------------------------------------------------------------------------------------------------------------------------------------------------------
Author      : Jean-Louis FLOQUET
Title       : Package Standard
File        : pkg_std.vhd
Application : RTL & Simulation
Created     : 2003, June 16th
Last update : 2016/05/10 19:05
Version     : 4.02.11
Dependency  : none
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Description : This package
   * renames std_logic & std_logic_vector into sl & slv. Most common vector length are also defined with slvX (where X=length)
   * defines some new standard operators for more control on Logic Synthesis
   * defines unary reduction operators
   * contains Binary <--> Gray conversions
   * defines some functions to shorter VHDL code
   * contains some functions that are NOT synthezisable (simulation only)
----------------------------------------------------------------------------------------------------------------------------------------------------------------
¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
¤ Limitations ¤
¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
* [Limitation 1] : Possible 'Suitable definitions exist in packages "NUMERIC_STD" and "pkg_std"'
    +-----
    | Comparator between sig/uns may create some difficulties :
    | If a term is a litteral vector (like "0110"), the following error is reported :
    | Subprogram <operator> is ambiguous. Suitable definitions exist in packages "NUMERIC_STD" and "pkg_std"
    +-----

----------------------------------------------------------------------------------------------------------------------------------------------------------------
  Rev.   |    Date    | Description
 4.02.11 | 2015/02/04 | 1) New : PolyDivide for polynomial division
         |            | 2) Fix : PosLSB & PosMSB for null vectors
         | 2015/02/17 | 3) Fix : conv_slv for a 32bits-wider return vector
         | 2015/02/18 | 4) Chg : MatrixCol renamed to MatrixColumn
         |            | 5) New : MatrixRow
         | 2015/02/25 | 6) Fix : to_Str (for a real), decimal part computing. Also removed extra character at the end
         |            | 7) New : to_StrMega function
         | 2015/10/26 | 8) Fix : to_StrHex(int,nat) when padding with left 0s
         | 2015/11/25 | 9) Fix : conv_slv for a 31bits return vector
         | 2015/12/01 |10) New : IsInArray function
         | 2016/05/10 |11) Fix : StrCmpNoCase for Vivado 2015.04
         |            |
 4.01.13 | 2013/11/18 | 1) Chg : VHDL-2008 required
         |            | 2) Chg : Some operators are now fully integrated in VHDL-2008, they have been removed :
         |            |            * mixed logical operators (sl/slv and slv/sl)
         |            |            * mixed arithmetic operators (sig/sl and sl/sig)
         | 2013/11/29 | 3) New : RealArraySum function
         |            | 4) New : Char_SLV4 consider that '.' is equivalent to '0'
         | 2013/12/06 | 5) Enh : Extend0L & Extend0R checks length coherency
         |            | 6) Chg : pkg_file's records moved here (RTL compliant)
         |            | 7) Enh : MatrixSet<Row|Col> accept both oriented data
         | 2014/01/27 | 8) Chg : 4.01.02 restored for synthesis (QuartusII 13.0.1 Build 232 doesn't have them !)
         | 2014/03/06 | 9) New : BoolArray
         | 2014/03/07 |10) Fix : crc_rfc1071 carry sum
         |            |11) New : crc_rfc1071 for iterative call
         | 2014/03/20 |12) New : Record 'domain'
         | 2014/10/16 |13) Fix : Work-around for Xilinx Vivado with NbClk function
         |            |
 4.00.01 | 2013/11/18 | 0) Chg : NOT COMPATIBLE with previous versions !!!
---------+------------+-----------------------------------------------------------------------------------------------------------------------------------------
 3.01.09 | 2012/12/13 | 1) New : Matrix operations (get/set Row/Column, clear, swap rows)
         |            | 2) Enh : PosLSB & PosMSB detect non RTL vector
         |            | 3) New : SL2Chr (SL -> character)
         | 2013/01/18 | 4) New : slv513array up to slv1024array
         |            | 5) Enh : to_StrHex's character '0' can be customized
         | 2013/04/30 | 6) New : Matricial product
         | 2013/10/08 | 7) New : to_StrBin function for SLV with customizable 0/1 characters
         | 2013/10/16 | 8) New : WORD64_x constants
         | 2013/10/31 | 9) New : RealArray up to 256
---------+------------+-----------------------------------------------------------------------------------------------------------------------------------------
 2.03.08 | 2012/07/29 | 1) Fix : msb functions
         | 2012/09/13 | 2) Fix : v2.02.03 didn't work for a 32bit vector
         | 2012/09/19 | 3) New : RTL_Check function
         | 2012/09/22 | 4) Enh : Error messages
         | 2012/09/25 | 5) New : IntArrayPrd function
         | 2012/11/19 | 6) Fix : Xilinx compatibility with unpredictable loop exit
         | 2012/11/21 | 7) New : Maxi & Mini for time
         | 2012/12/03 | 8) Enh : to_Str(int/size) function padding with user character
         |            |
 2.02.04 | 2012/07/13 | 1) Enh : msb & lsb functions can extend input vector with 0s
         | 2012/07/17 | 2) Fix : StrCpy pointer was not incremented
         | 2012/07/24 | 3) Fix : Enhancement 2.01.04 cannot be synthesized. Splitted simulation versus RTL
         | 2012/07/27 | 4) New : Dup for string
         |            |
 2.01.04 | 2012/05/16 | 1) Chg : String manipulation functions from pkg_simu moved here !!
         |            | 2) New : DateValid function
         | 2012/05/29 | 3) New : Log_n function
         | 2012/06/01 | 4) Enh : Removed limitation for conv_slv verifying with 2^32 integer (now using reals)
         |            |
 2.00.01 | 2012/04/16 | 0) Chg : NOT COMPATIBLE with previous versions !!!
         |            | 1) Chg : to_01 renamed to sl_to_bit for VHDL2008 compatibility
---------+------------+-----------------------------------------------------------------------------------------------------------------------------------------
 1.06.02 | 2012/01/08 | 1) New : conv_slv checks that slv is wide enough to contain integer/real value
         | 2012/01/11 | 2) New : Edge / RisingEdge / FallingEdge can return a sl
         |            |
 1.05.14 | 2010/05/28 | 1) New : CRC according to RFC1071 (Ethernet packets)
         | 2010/12/20 | 2) Fix : Function to_01 for Xilinx ISE Synthesis
         | 2010/12/31 | 3) Fix : Xilinx fix (bug is in XST tool) : If X is real, "int(x)" creates internal error. Changed to "integer(x)"
         | 2011/01/17 | 4) New : StrUS2Spc function to support generic mapping from ModelSim (in testbench) to FPGA devices (contain space in devices)
         | 2011/10/12 | 5) New : Imported Timings from pkg_simu
         | 2011/10/13 | 6) Fix : PartInt supports VHDL precision problem (decimal part = 0.99999... will cause +1 on integral part). Precision is 1.0E-15.
         |            | 7) Enh : PartDec better precision usage
         | 2011/10/20 | 8) New : Define SLV up to 1024
         |            | 9) Chg : SlvEq renamed to SlvEqImp
         |            |10) New : SlvEqExp : compare 2 vectors (a,b) according to a mask
         | 2011/10/25 |11) New : Inside functions (GeLe,GeLt,GtLe,GtLt)
         | 2011/12/06 |12) Chg : Removed misfunctionnal test in SlvEqExp & SlvEqImp
         | 2011/12/16 |13) New : Function GrayAdd between a gray value (as unsigned) and an integer
         | 2012/01/03 |14) New : BYTE_xx / WORD16_xx / WORD32_xx up to 32th bit
         |            |
 1.04.06 | 2009/07/20 | 1) Chg : Imported from pkg_math_simu
         |            |             * all non signed/unsigned basic operators & comparators
         |            |             * Matrix operators (created on 2006/11/07)
         |            | 2) New : Subtypes 'int' for integer and 'nat' for natural
         |            | 3) Chg : Renamed Int to PartInt and Dec to PartDec
         | 2009/08/31 | 4) Fix : Log2 restricted to 2^31, also fixed for values between 2^30 and 2^31-1
         | 2009/09/10 | 5) Chg : 'to_StrInt' renamed to 'to_Str' (can handle real, so 'int' is not welcome)
         |            | 6) New : 'to_Str' now support real
         |            |
 1.03.34 | 2008/01/28 | 1) Enh : GrayClr and GrayIncr have a toggle bit driven to 0 during asynchronous reset
         |            | 2) Fix : Negative unary reduction operators
         |            | 3) New : Conversion functions for Int <--> Boolean
         |            | 4) New : Bit duplication
         |            | 5) New : Some new IntArray and RealArray
         |            | 6) New : conv_uns function
         | 2008/04/16 | 7) New : MultCst function
         | 2008/04/17 | 8) New : "+" and "-" operators for signed and unsigned with a SL
         | 2008/04/22 | 9) Fix : Exported conv_int(slv) to pkg_std_unsigned
         | 2008/04/23 |10) New : conv_sig function
         |            |11) New : Mathematical operator for comparaisons between signed and unsigned
         |            |12) New : More definitions for msb function
         | 2008/05/23 |13) Fix : Log2 function (damn, don't know if the "=" of ">=" was stollen by keyboard, but the operator was ">" !!)
         | 2008/05/26 |14) New : conv_slv for real
         | 2008/05/27 |15) New : Int & Dec function for returning integral & decimal part of reals
         | 2008/05/28 |16) New : RoundUp function
         |            |17) New : NbClk function
         | 2008/06/09 |18) Fix : StrEq was still returning warning under Xilinx ISE
         | 2008/10/13 |19) Fix : Log2 (pfff, the comeback...) should return the Log. Log2(256)=8, even if 256d = 1.0000.0000b (9bits) for binary coding
         | 2008/11/20 |20) Fix : Extend0L for input vector out of range
         | 2008/11/29 |21) New : SLV -> real for vector greater than 32bits
         | 2008/12/01 |22) New : Time array
         | 2008/12/02 |23) Chg : Renamed Int2Str to Int_Str for coherency with others packages
         | 2009/02/09 |24) Enh : Error strings reported include the 'pkg_std' reference for better readability
         | 2009/02/10 |25) Fix : to_01 function was returning '0' for 'H' state. Now 'H' returns '1'
         | 2009/02/24 |26) Chg : Renamed 'Int_Str' to 'to_StrInt' for coherency with others packages
         | 2009/03/10 |27) New : Some new arrays
         | 2009/03/16 |28) Enh : to_01 better RTL support
         | 2009/03/30 |29) Enh : SlvEq checks that both arguments have the same size
         |            |30) Fix : NbClk (with arguments as time) created some 'silent' overflow with operations on natural types
         | 2009/04/02 |31) New : Support for division between integer and real
         | 2009/04/06 |32) New : Time to real convertion (1.0 = 1 second, 1E-9 = 1 ns)
         | 2009/05/06 |33) Fix : Dec function formal computing error (25.0 - real(25) was not 0.0 !!)
         | 2009/07/07 |34) New : OpenCollector function
         |            |
 1.02.28 | 2007/10/11 | 1) Chg : Upgrade to "numeric_std" package
         |            | 2) New : Some new predefined types (slv141...)
         |            | 3) Chg : Move mathematical operators to a new package "pkg_std_unsigned.vhd". Some
         |            |          of them were ambiguous when using this package and "ieee.numeric_std".
         |            | 4) New : DriveWithOE function (supports one OE per data in buses). Default mask is 'Z'
         |            | 5) New : SwapBits function
         |            | 6) New : SwapBytes function
         |            | 7) New : StrEq function to remove stupid warnings about string lengths
         |            | 8) New : SecureSEU function (Secure for Single Event Upset). Assume at least 2/3 values are unchanged
         |            | 9) New : Create a new package "pkg_cst" with ZEROS_i constants
         |            |10) Chg : Renamed "Int_Log2" to "Log2", "bin_to_gray" to "Bin2Gray" and "gray_to_bin" to "Gray2Bin"
         |            |11) New : Moved 'Is_01' from pkg_simu
         |            |12) New : IntArray type with IntArraySum function
         |            |13) Chg : 'Log2' upgraded without restriction
         |            |14) New : Extend0R function. extend_0 renamed to Extend0L for consistency
         |            |15) New : SLV up to 300
         |            |16) New : RealArray
         |            |17) Fix : Removed aliases (ModelSim 6.1f has internal bug with alias used inside a port map)
         |            |18) New : signed & unsigned like slv (=> sig & uns)
         |            |19) New : GrayIncr & GrayClr
         |            |20) Fix : Log2 function
         |            |21) New : to_01 functions
         |            |22) New : ExcludeLSB & ExcludeMSB functions
         |            |23) New : Usefull ranges definition
         |            |24) New : ResyncRst & ResyncRstn functions to resynchronize reset deassertion
         |            |25) Chg : Remove RisingEdge and FallingEdge function returning 'sl'
         |            |26) New : conv_boolean : SL -> BOOLEAN
         |            |27) New : 'Edge' function
         |            |28) New : Moved 'Int2Str' function from 'pkg_simu' for using with "report" during synthesis
 1.01.02 | 2005/12/13 | 1) Chg : So much changes (add/new/fix...) !! :)
         | 2006/06/19 | 2) New : Add SlvEq (compare two slv with mask)
 1.00.00 | 2003/01/16 | Initial Release
--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.math_real.all;

package pkg_std is
	constant SIMULATION : boolean := false         -- RTL only   : constant is set to "false"
	--synthesis translate_off
	                                 or true       -- Simulation : constant is set to "true"
	--synthesis translate_on
	                                 ;
	-- Keep this "special" method because Xilinx ISE tool doesn't have the "read_comments_as_HDL" option like Altera QuartusII.

--**************************************************************************************************************************************************************
-- New types definition for std_logic & std_logic_vector. Also some new constants
--**************************************************************************************************************************************************************
	subtype int           is integer         ;
	subtype nat           is natural         ;
	subtype sig           is signed          ;
	subtype sl            is std_logic       ;
	subtype slv           is std_logic_vector; -- Use this as slv(natural range <>) instead of std_logic_vector(natural range <>)
	subtype uns           is unsigned        ;
--**************************************************************************************************************************************************************
-- SIGNED
--**************************************************************************************************************************************************************
	subtype sig1     is sig(  0 downto  0); subtype sig2     is sig(  1 downto  0); subtype sig3     is sig(  2 downto  0); subtype sig4     is sig(  3 downto  0);
	subtype sig5     is sig(  4 downto  0); subtype sig6     is sig(  5 downto  0); subtype sig7     is sig(  6 downto  0); subtype sig8     is sig(  7 downto  0);
	subtype sig9     is sig(  8 downto  0); subtype sig10    is sig(  9 downto  0); subtype sig11    is sig( 10 downto  0); subtype sig12    is sig( 11 downto  0);
	subtype sig13    is sig( 12 downto  0); subtype sig14    is sig( 13 downto  0); subtype sig15    is sig( 14 downto  0); subtype sig16    is sig( 15 downto  0);
	subtype sig17    is sig( 16 downto  0); subtype sig18    is sig( 17 downto  0); subtype sig19    is sig( 18 downto  0); subtype sig20    is sig( 19 downto  0);
	subtype sig21    is sig( 20 downto  0); subtype sig22    is sig( 21 downto  0); subtype sig23    is sig( 22 downto  0); subtype sig24    is sig( 23 downto  0);
	subtype sig25    is sig( 24 downto  0); subtype sig26    is sig( 25 downto  0); subtype sig27    is sig( 26 downto  0); subtype sig28    is sig( 27 downto  0);
	subtype sig29    is sig( 28 downto  0); subtype sig30    is sig( 29 downto  0); subtype sig31    is sig( 30 downto  0); subtype sig32    is sig( 31 downto  0);
	subtype sig33    is sig( 32 downto  0); subtype sig34    is sig( 33 downto  0); subtype sig35    is sig( 34 downto  0); subtype sig36    is sig( 35 downto  0);
	subtype sig37    is sig( 36 downto  0); subtype sig38    is sig( 37 downto  0); subtype sig39    is sig( 38 downto  0); subtype sig40    is sig( 39 downto  0);
	subtype sig41    is sig( 40 downto  0); subtype sig42    is sig( 41 downto  0); subtype sig43    is sig( 42 downto  0); subtype sig44    is sig( 43 downto  0);
	subtype sig45    is sig( 44 downto  0); subtype sig46    is sig( 45 downto  0); subtype sig47    is sig( 46 downto  0); subtype sig48    is sig( 47 downto  0);
	subtype sig49    is sig( 48 downto  0); subtype sig50    is sig( 49 downto  0); subtype sig51    is sig( 50 downto  0); subtype sig52    is sig( 51 downto  0);
	subtype sig53    is sig( 52 downto  0); subtype sig54    is sig( 53 downto  0); subtype sig55    is sig( 54 downto  0); subtype sig56    is sig( 55 downto  0);
	subtype sig57    is sig( 56 downto  0); subtype sig58    is sig( 57 downto  0); subtype sig59    is sig( 58 downto  0); subtype sig60    is sig( 59 downto  0);
	subtype sig61    is sig( 60 downto  0); subtype sig62    is sig( 61 downto  0); subtype sig63    is sig( 62 downto  0); subtype sig64    is sig( 63 downto  0);
	subtype sig65    is sig( 64 downto  0); subtype sig66    is sig( 65 downto  0); subtype sig67    is sig( 66 downto  0); subtype sig68    is sig( 67 downto  0);
	subtype sig69    is sig( 68 downto  0); subtype sig70    is sig( 69 downto  0); subtype sig71    is sig( 70 downto  0); subtype sig72    is sig( 71 downto  0);
	subtype sig73    is sig( 72 downto  0); subtype sig74    is sig( 73 downto  0); subtype sig75    is sig( 74 downto  0); subtype sig76    is sig( 75 downto  0);
	subtype sig77    is sig( 76 downto  0); subtype sig78    is sig( 77 downto  0); subtype sig79    is sig( 78 downto  0); subtype sig80    is sig( 79 downto  0);
	subtype sig81    is sig( 80 downto  0); subtype sig82    is sig( 81 downto  0); subtype sig83    is sig( 82 downto  0); subtype sig84    is sig( 83 downto  0);
	subtype sig85    is sig( 84 downto  0); subtype sig86    is sig( 85 downto  0); subtype sig87    is sig( 86 downto  0); subtype sig88    is sig( 87 downto  0);
	subtype sig89    is sig( 88 downto  0); subtype sig90    is sig( 89 downto  0); subtype sig91    is sig( 90 downto  0); subtype sig92    is sig( 91 downto  0);
	subtype sig93    is sig( 92 downto  0); subtype sig94    is sig( 93 downto  0); subtype sig95    is sig( 94 downto  0); subtype sig96    is sig( 95 downto  0);
	subtype sig97    is sig( 96 downto  0); subtype sig98    is sig( 97 downto  0); subtype sig99    is sig( 98 downto  0); subtype sig100   is sig( 99 downto  0);
	subtype sig101   is sig(100 downto  0); subtype sig102   is sig(101 downto  0); subtype sig103   is sig(102 downto  0); subtype sig104   is sig(103 downto  0);
	subtype sig105   is sig(104 downto  0); subtype sig106   is sig(105 downto  0); subtype sig107   is sig(106 downto  0); subtype sig108   is sig(107 downto  0);
	subtype sig109   is sig(108 downto  0); subtype sig110   is sig(109 downto  0); subtype sig111   is sig(110 downto  0); subtype sig112   is sig(111 downto  0);
	subtype sig113   is sig(112 downto  0); subtype sig114   is sig(113 downto  0); subtype sig115   is sig(114 downto  0); subtype sig116   is sig(115 downto  0);
	subtype sig117   is sig(116 downto  0); subtype sig118   is sig(117 downto  0); subtype sig119   is sig(118 downto  0); subtype sig120   is sig(119 downto  0);
	subtype sig121   is sig(120 downto  0); subtype sig122   is sig(121 downto  0); subtype sig123   is sig(122 downto  0); subtype sig124   is sig(123 downto  0);
	subtype sig125   is sig(124 downto  0); subtype sig126   is sig(125 downto  0); subtype sig127   is sig(126 downto  0); subtype sig128   is sig(127 downto  0);
	subtype sig129   is sig(128 downto  0); subtype sig130   is sig(129 downto  0); subtype sig131   is sig(130 downto  0); subtype sig132   is sig(131 downto  0);
	subtype sig133   is sig(132 downto  0); subtype sig134   is sig(133 downto  0); subtype sig135   is sig(134 downto  0); subtype sig136   is sig(135 downto  0);
	subtype sig137   is sig(136 downto  0); subtype sig138   is sig(137 downto  0); subtype sig139   is sig(138 downto  0); subtype sig140   is sig(139 downto  0);
	subtype sig141   is sig(140 downto  0); subtype sig142   is sig(141 downto  0); subtype sig143   is sig(142 downto  0); subtype sig144   is sig(143 downto  0);
	subtype sig145   is sig(144 downto  0); subtype sig146   is sig(145 downto  0); subtype sig147   is sig(146 downto  0); subtype sig148   is sig(147 downto  0);
	subtype sig149   is sig(148 downto  0); subtype sig150   is sig(149 downto  0); subtype sig151   is sig(150 downto  0); subtype sig152   is sig(151 downto  0);
	subtype sig153   is sig(152 downto  0); subtype sig154   is sig(153 downto  0); subtype sig155   is sig(154 downto  0); subtype sig156   is sig(155 downto  0);
	subtype sig157   is sig(156 downto  0); subtype sig158   is sig(157 downto  0); subtype sig159   is sig(158 downto  0); subtype sig160   is sig(159 downto  0);
	subtype sig161   is sig(160 downto  0); subtype sig162   is sig(161 downto  0); subtype sig163   is sig(162 downto  0); subtype sig164   is sig(163 downto  0);
	subtype sig165   is sig(164 downto  0); subtype sig166   is sig(165 downto  0); subtype sig167   is sig(166 downto  0); subtype sig168   is sig(167 downto  0);
	subtype sig169   is sig(168 downto  0); subtype sig170   is sig(169 downto  0); subtype sig171   is sig(170 downto  0); subtype sig172   is sig(171 downto  0);
	subtype sig173   is sig(172 downto  0); subtype sig174   is sig(173 downto  0); subtype sig175   is sig(174 downto  0); subtype sig176   is sig(175 downto  0);
	subtype sig177   is sig(176 downto  0); subtype sig178   is sig(177 downto  0); subtype sig179   is sig(178 downto  0); subtype sig180   is sig(179 downto  0);
	subtype sig181   is sig(180 downto  0); subtype sig182   is sig(181 downto  0); subtype sig183   is sig(182 downto  0); subtype sig184   is sig(183 downto  0);
	subtype sig185   is sig(184 downto  0); subtype sig186   is sig(185 downto  0); subtype sig187   is sig(186 downto  0); subtype sig188   is sig(187 downto  0);
	subtype sig189   is sig(188 downto  0); subtype sig190   is sig(189 downto  0); subtype sig191   is sig(190 downto  0); subtype sig192   is sig(191 downto  0);
	subtype sig193   is sig(192 downto  0); subtype sig194   is sig(193 downto  0); subtype sig195   is sig(194 downto  0); subtype sig196   is sig(195 downto  0);
	subtype sig197   is sig(196 downto  0); subtype sig198   is sig(197 downto  0); subtype sig199   is sig(198 downto  0); subtype sig200   is sig(199 downto  0);
	subtype sig201   is sig(200 downto  0); subtype sig202   is sig(201 downto  0); subtype sig203   is sig(202 downto  0); subtype sig204   is sig(203 downto  0);
	subtype sig205   is sig(204 downto  0); subtype sig206   is sig(205 downto  0); subtype sig207   is sig(206 downto  0); subtype sig208   is sig(207 downto  0);
	subtype sig209   is sig(208 downto  0); subtype sig210   is sig(209 downto  0); subtype sig211   is sig(210 downto  0); subtype sig212   is sig(211 downto  0);
	subtype sig213   is sig(212 downto  0); subtype sig214   is sig(213 downto  0); subtype sig215   is sig(214 downto  0); subtype sig216   is sig(215 downto  0);
	subtype sig217   is sig(216 downto  0); subtype sig218   is sig(217 downto  0); subtype sig219   is sig(218 downto  0); subtype sig220   is sig(219 downto  0);
	subtype sig221   is sig(220 downto  0); subtype sig222   is sig(221 downto  0); subtype sig223   is sig(222 downto  0); subtype sig224   is sig(223 downto  0);
	subtype sig225   is sig(224 downto  0); subtype sig226   is sig(225 downto  0); subtype sig227   is sig(226 downto  0); subtype sig228   is sig(227 downto  0);
	subtype sig229   is sig(228 downto  0); subtype sig230   is sig(229 downto  0); subtype sig231   is sig(230 downto  0); subtype sig232   is sig(231 downto  0);
	subtype sig233   is sig(232 downto  0); subtype sig234   is sig(233 downto  0); subtype sig235   is sig(234 downto  0); subtype sig236   is sig(235 downto  0);
	subtype sig237   is sig(236 downto  0); subtype sig238   is sig(237 downto  0); subtype sig239   is sig(238 downto  0); subtype sig240   is sig(239 downto  0);
	subtype sig241   is sig(240 downto  0); subtype sig242   is sig(241 downto  0); subtype sig243   is sig(242 downto  0); subtype sig244   is sig(243 downto  0);
	subtype sig245   is sig(244 downto  0); subtype sig246   is sig(245 downto  0); subtype sig247   is sig(246 downto  0); subtype sig248   is sig(247 downto  0);
	subtype sig249   is sig(248 downto  0); subtype sig250   is sig(249 downto  0); subtype sig251   is sig(250 downto  0); subtype sig252   is sig(251 downto  0);
	subtype sig253   is sig(252 downto  0); subtype sig254   is sig(253 downto  0); subtype sig255   is sig(254 downto  0); subtype sig256   is sig(255 downto  0);
	subtype sig257   is sig(256 downto  0); subtype sig258   is sig(257 downto  0); subtype sig259   is sig(258 downto  0); subtype sig260   is sig(259 downto  0);
	subtype sig261   is sig(260 downto  0); subtype sig262   is sig(261 downto  0); subtype sig263   is sig(262 downto  0); subtype sig264   is sig(263 downto  0);
	subtype sig265   is sig(264 downto  0); subtype sig266   is sig(265 downto  0); subtype sig267   is sig(266 downto  0); subtype sig268   is sig(267 downto  0);
	subtype sig269   is sig(268 downto  0); subtype sig270   is sig(269 downto  0); subtype sig271   is sig(270 downto  0); subtype sig272   is sig(271 downto  0);
	subtype sig273   is sig(272 downto  0); subtype sig274   is sig(273 downto  0); subtype sig275   is sig(274 downto  0); subtype sig276   is sig(275 downto  0);
	subtype sig277   is sig(276 downto  0); subtype sig278   is sig(277 downto  0); subtype sig279   is sig(278 downto  0); subtype sig280   is sig(279 downto  0);
	subtype sig281   is sig(280 downto  0); subtype sig282   is sig(281 downto  0); subtype sig283   is sig(282 downto  0); subtype sig284   is sig(283 downto  0);
	subtype sig285   is sig(284 downto  0); subtype sig286   is sig(285 downto  0); subtype sig287   is sig(286 downto  0); subtype sig288   is sig(287 downto  0);
	subtype sig289   is sig(288 downto  0); subtype sig290   is sig(289 downto  0); subtype sig291   is sig(290 downto  0); subtype sig292   is sig(291 downto  0);
	subtype sig293   is sig(292 downto  0); subtype sig294   is sig(293 downto  0); subtype sig295   is sig(294 downto  0); subtype sig296   is sig(295 downto  0);
	subtype sig297   is sig(296 downto  0); subtype sig298   is sig(297 downto  0); subtype sig299   is sig(298 downto  0); subtype sig300   is sig(299 downto  0);

	type sig1array   is array(natural range <>) of sig1  ; type sig2array   is array(natural range <>) of sig2  ;
	type sig3array   is array(natural range <>) of sig3  ; type sig4array   is array(natural range <>) of sig4  ;
	type sig5array   is array(natural range <>) of sig5  ; type sig6array   is array(natural range <>) of sig6  ;
	type sig7array   is array(natural range <>) of sig7  ; type sig8array   is array(natural range <>) of sig8  ;
	type sig9array   is array(natural range <>) of sig9  ; type sig10array  is array(natural range <>) of sig10 ;
	type sig11array  is array(natural range <>) of sig11 ; type sig12array  is array(natural range <>) of sig12 ;
	type sig13array  is array(natural range <>) of sig13 ; type sig14array  is array(natural range <>) of sig14 ;
	type sig15array  is array(natural range <>) of sig15 ; type sig16array  is array(natural range <>) of sig16 ;
	type sig17array  is array(natural range <>) of sig17 ; type sig18array  is array(natural range <>) of sig18 ;
	type sig19array  is array(natural range <>) of sig19 ; type sig20array  is array(natural range <>) of sig20 ;
	type sig21array  is array(natural range <>) of sig21 ; type sig22array  is array(natural range <>) of sig22 ;
	type sig23array  is array(natural range <>) of sig23 ; type sig24array  is array(natural range <>) of sig24 ;
	type sig25array  is array(natural range <>) of sig25 ; type sig26array  is array(natural range <>) of sig26 ;
	type sig27array  is array(natural range <>) of sig27 ; type sig28array  is array(natural range <>) of sig28 ;
	type sig29array  is array(natural range <>) of sig29 ; type sig30array  is array(natural range <>) of sig30 ;
	type sig31array  is array(natural range <>) of sig31 ; type sig32array  is array(natural range <>) of sig32 ;
	type sig33array  is array(natural range <>) of sig33 ; type sig34array  is array(natural range <>) of sig34 ;
	type sig35array  is array(natural range <>) of sig35 ; type sig36array  is array(natural range <>) of sig36 ;
	type sig37array  is array(natural range <>) of sig37 ; type sig38array  is array(natural range <>) of sig38 ;
	type sig39array  is array(natural range <>) of sig39 ; type sig40array  is array(natural range <>) of sig40 ;
	type sig41array  is array(natural range <>) of sig41 ; type sig42array  is array(natural range <>) of sig42 ;
	type sig43array  is array(natural range <>) of sig43 ; type sig44array  is array(natural range <>) of sig44 ;
	type sig45array  is array(natural range <>) of sig45 ; type sig46array  is array(natural range <>) of sig46 ;
	type sig47array  is array(natural range <>) of sig47 ; type sig48array  is array(natural range <>) of sig48 ;
	type sig49array  is array(natural range <>) of sig49 ; type sig50array  is array(natural range <>) of sig50 ;
	type sig51array  is array(natural range <>) of sig51 ; type sig52array  is array(natural range <>) of sig52 ;
	type sig53array  is array(natural range <>) of sig53 ; type sig54array  is array(natural range <>) of sig54 ;
	type sig55array  is array(natural range <>) of sig55 ; type sig56array  is array(natural range <>) of sig56 ;
	type sig57array  is array(natural range <>) of sig57 ; type sig58array  is array(natural range <>) of sig58 ;
	type sig59array  is array(natural range <>) of sig59 ; type sig60array  is array(natural range <>) of sig60 ;
	type sig61array  is array(natural range <>) of sig61 ; type sig62array  is array(natural range <>) of sig62 ;
	type sig63array  is array(natural range <>) of sig63 ; type sig64array  is array(natural range <>) of sig64 ;
	type sig65array  is array(natural range <>) of sig65 ; type sig66array  is array(natural range <>) of sig66 ;
	type sig67array  is array(natural range <>) of sig67 ; type sig68array  is array(natural range <>) of sig68 ;
	type sig69array  is array(natural range <>) of sig69 ; type sig70array  is array(natural range <>) of sig70 ;
	type sig71array  is array(natural range <>) of sig71 ; type sig72array  is array(natural range <>) of sig72 ;
	type sig73array  is array(natural range <>) of sig73 ; type sig74array  is array(natural range <>) of sig74 ;
	type sig75array  is array(natural range <>) of sig75 ; type sig76array  is array(natural range <>) of sig76 ;
	type sig77array  is array(natural range <>) of sig77 ; type sig78array  is array(natural range <>) of sig78 ;
	type sig79array  is array(natural range <>) of sig79 ; type sig80array  is array(natural range <>) of sig80 ;
	type sig81array  is array(natural range <>) of sig81 ; type sig82array  is array(natural range <>) of sig82 ;
	type sig83array  is array(natural range <>) of sig83 ; type sig84array  is array(natural range <>) of sig84 ;
	type sig85array  is array(natural range <>) of sig85 ; type sig86array  is array(natural range <>) of sig86 ;
	type sig87array  is array(natural range <>) of sig87 ; type sig88array  is array(natural range <>) of sig88 ;
	type sig89array  is array(natural range <>) of sig89 ; type sig90array  is array(natural range <>) of sig90 ;
	type sig91array  is array(natural range <>) of sig91 ; type sig92array  is array(natural range <>) of sig92 ;
	type sig93array  is array(natural range <>) of sig93 ; type sig94array  is array(natural range <>) of sig94 ;
	type sig95array  is array(natural range <>) of sig95 ; type sig96array  is array(natural range <>) of sig96 ;
	type sig97array  is array(natural range <>) of sig97 ; type sig98array  is array(natural range <>) of sig98 ;
	type sig99array  is array(natural range <>) of sig99 ; type sig100array is array(natural range <>) of sig100;
	type sig101array is array(natural range <>) of sig101; type sig102array is array(natural range <>) of sig102;
	type sig103array is array(natural range <>) of sig103; type sig104array is array(natural range <>) of sig104;
	type sig105array is array(natural range <>) of sig105; type sig106array is array(natural range <>) of sig106;
	type sig107array is array(natural range <>) of sig107; type sig108array is array(natural range <>) of sig108;
	type sig109array is array(natural range <>) of sig109; type sig110array is array(natural range <>) of sig110;
	type sig111array is array(natural range <>) of sig111; type sig112array is array(natural range <>) of sig112;
	type sig113array is array(natural range <>) of sig113; type sig114array is array(natural range <>) of sig114;
	type sig115array is array(natural range <>) of sig115; type sig116array is array(natural range <>) of sig116;
	type sig117array is array(natural range <>) of sig117; type sig118array is array(natural range <>) of sig118;
	type sig119array is array(natural range <>) of sig119; type sig120array is array(natural range <>) of sig120;
	type sig121array is array(natural range <>) of sig121; type sig122array is array(natural range <>) of sig122;
	type sig123array is array(natural range <>) of sig123; type sig124array is array(natural range <>) of sig124;
	type sig125array is array(natural range <>) of sig125; type sig126array is array(natural range <>) of sig126;
	type sig127array is array(natural range <>) of sig127; type sig128array is array(natural range <>) of sig128;
	type sig129array is array(natural range <>) of sig129; type sig130array is array(natural range <>) of sig130;
	type sig131array is array(natural range <>) of sig131; type sig132array is array(natural range <>) of sig132;
	type sig133array is array(natural range <>) of sig133; type sig134array is array(natural range <>) of sig134;
	type sig135array is array(natural range <>) of sig135; type sig136array is array(natural range <>) of sig136;
	type sig137array is array(natural range <>) of sig137; type sig138array is array(natural range <>) of sig138;
	type sig139array is array(natural range <>) of sig139; type sig140array is array(natural range <>) of sig140;
	type sig141array is array(natural range <>) of sig141; type sig142array is array(natural range <>) of sig142;
	type sig143array is array(natural range <>) of sig143; type sig144array is array(natural range <>) of sig144;
--**************************************************************************************************************************************************************
-- STD_LOGIC_VECTOR
--**************************************************************************************************************************************************************
	subtype slv1     is slv(   0 downto  0); subtype slv2     is slv(   1 downto  0); subtype slv3     is slv(   2 downto  0); subtype slv4     is slv(   3 downto  0);
	subtype slv5     is slv(   4 downto  0); subtype slv6     is slv(   5 downto  0); subtype slv7     is slv(   6 downto  0); subtype slv8     is slv(   7 downto  0);
	subtype slv9     is slv(   8 downto  0); subtype slv10    is slv(   9 downto  0); subtype slv11    is slv(  10 downto  0); subtype slv12    is slv(  11 downto  0);
	subtype slv13    is slv(  12 downto  0); subtype slv14    is slv(  13 downto  0); subtype slv15    is slv(  14 downto  0); subtype slv16    is slv(  15 downto  0);
	subtype slv17    is slv(  16 downto  0); subtype slv18    is slv(  17 downto  0); subtype slv19    is slv(  18 downto  0); subtype slv20    is slv(  19 downto  0);
	subtype slv21    is slv(  20 downto  0); subtype slv22    is slv(  21 downto  0); subtype slv23    is slv(  22 downto  0); subtype slv24    is slv(  23 downto  0);
	subtype slv25    is slv(  24 downto  0); subtype slv26    is slv(  25 downto  0); subtype slv27    is slv(  26 downto  0); subtype slv28    is slv(  27 downto  0);
	subtype slv29    is slv(  28 downto  0); subtype slv30    is slv(  29 downto  0); subtype slv31    is slv(  30 downto  0); subtype slv32    is slv(  31 downto  0);
	subtype slv33    is slv(  32 downto  0); subtype slv34    is slv(  33 downto  0); subtype slv35    is slv(  34 downto  0); subtype slv36    is slv(  35 downto  0);
	subtype slv37    is slv(  36 downto  0); subtype slv38    is slv(  37 downto  0); subtype slv39    is slv(  38 downto  0); subtype slv40    is slv(  39 downto  0);
	subtype slv41    is slv(  40 downto  0); subtype slv42    is slv(  41 downto  0); subtype slv43    is slv(  42 downto  0); subtype slv44    is slv(  43 downto  0);
	subtype slv45    is slv(  44 downto  0); subtype slv46    is slv(  45 downto  0); subtype slv47    is slv(  46 downto  0); subtype slv48    is slv(  47 downto  0);
	subtype slv49    is slv(  48 downto  0); subtype slv50    is slv(  49 downto  0); subtype slv51    is slv(  50 downto  0); subtype slv52    is slv(  51 downto  0);
	subtype slv53    is slv(  52 downto  0); subtype slv54    is slv(  53 downto  0); subtype slv55    is slv(  54 downto  0); subtype slv56    is slv(  55 downto  0);
	subtype slv57    is slv(  56 downto  0); subtype slv58    is slv(  57 downto  0); subtype slv59    is slv(  58 downto  0); subtype slv60    is slv(  59 downto  0);
	subtype slv61    is slv(  60 downto  0); subtype slv62    is slv(  61 downto  0); subtype slv63    is slv(  62 downto  0); subtype slv64    is slv(  63 downto  0);
	subtype slv65    is slv(  64 downto  0); subtype slv66    is slv(  65 downto  0); subtype slv67    is slv(  66 downto  0); subtype slv68    is slv(  67 downto  0);
	subtype slv69    is slv(  68 downto  0); subtype slv70    is slv(  69 downto  0); subtype slv71    is slv(  70 downto  0); subtype slv72    is slv(  71 downto  0);
	subtype slv73    is slv(  72 downto  0); subtype slv74    is slv(  73 downto  0); subtype slv75    is slv(  74 downto  0); subtype slv76    is slv(  75 downto  0);
	subtype slv77    is slv(  76 downto  0); subtype slv78    is slv(  77 downto  0); subtype slv79    is slv(  78 downto  0); subtype slv80    is slv(  79 downto  0);
	subtype slv81    is slv(  80 downto  0); subtype slv82    is slv(  81 downto  0); subtype slv83    is slv(  82 downto  0); subtype slv84    is slv(  83 downto  0);
	subtype slv85    is slv(  84 downto  0); subtype slv86    is slv(  85 downto  0); subtype slv87    is slv(  86 downto  0); subtype slv88    is slv(  87 downto  0);
	subtype slv89    is slv(  88 downto  0); subtype slv90    is slv(  89 downto  0); subtype slv91    is slv(  90 downto  0); subtype slv92    is slv(  91 downto  0);
	subtype slv93    is slv(  92 downto  0); subtype slv94    is slv(  93 downto  0); subtype slv95    is slv(  94 downto  0); subtype slv96    is slv(  95 downto  0);
	subtype slv97    is slv(  96 downto  0); subtype slv98    is slv(  97 downto  0); subtype slv99    is slv(  98 downto  0); subtype slv100   is slv(  99 downto  0);
	subtype slv101   is slv( 100 downto  0); subtype slv102   is slv( 101 downto  0); subtype slv103   is slv( 102 downto  0); subtype slv104   is slv( 103 downto  0);
	subtype slv105   is slv( 104 downto  0); subtype slv106   is slv( 105 downto  0); subtype slv107   is slv( 106 downto  0); subtype slv108   is slv( 107 downto  0);
	subtype slv109   is slv( 108 downto  0); subtype slv110   is slv( 109 downto  0); subtype slv111   is slv( 110 downto  0); subtype slv112   is slv( 111 downto  0);
	subtype slv113   is slv( 112 downto  0); subtype slv114   is slv( 113 downto  0); subtype slv115   is slv( 114 downto  0); subtype slv116   is slv( 115 downto  0);
	subtype slv117   is slv( 116 downto  0); subtype slv118   is slv( 117 downto  0); subtype slv119   is slv( 118 downto  0); subtype slv120   is slv( 119 downto  0);
	subtype slv121   is slv( 120 downto  0); subtype slv122   is slv( 121 downto  0); subtype slv123   is slv( 122 downto  0); subtype slv124   is slv( 123 downto  0);
	subtype slv125   is slv( 124 downto  0); subtype slv126   is slv( 125 downto  0); subtype slv127   is slv( 126 downto  0); subtype slv128   is slv( 127 downto  0);
	subtype slv129   is slv( 128 downto  0); subtype slv130   is slv( 129 downto  0); subtype slv131   is slv( 130 downto  0); subtype slv132   is slv( 131 downto  0);
	subtype slv133   is slv( 132 downto  0); subtype slv134   is slv( 133 downto  0); subtype slv135   is slv( 134 downto  0); subtype slv136   is slv( 135 downto  0);
	subtype slv137   is slv( 136 downto  0); subtype slv138   is slv( 137 downto  0); subtype slv139   is slv( 138 downto  0); subtype slv140   is slv( 139 downto  0);
	subtype slv141   is slv( 140 downto  0); subtype slv142   is slv( 141 downto  0); subtype slv143   is slv( 142 downto  0); subtype slv144   is slv( 143 downto  0);
	subtype slv145   is slv( 144 downto  0); subtype slv146   is slv( 145 downto  0); subtype slv147   is slv( 146 downto  0); subtype slv148   is slv( 147 downto  0);
	subtype slv149   is slv( 148 downto  0); subtype slv150   is slv( 149 downto  0); subtype slv151   is slv( 150 downto  0); subtype slv152   is slv( 151 downto  0);
	subtype slv153   is slv( 152 downto  0); subtype slv154   is slv( 153 downto  0); subtype slv155   is slv( 154 downto  0); subtype slv156   is slv( 155 downto  0);
	subtype slv157   is slv( 156 downto  0); subtype slv158   is slv( 157 downto  0); subtype slv159   is slv( 158 downto  0); subtype slv160   is slv( 159 downto  0);
	subtype slv161   is slv( 160 downto  0); subtype slv162   is slv( 161 downto  0); subtype slv163   is slv( 162 downto  0); subtype slv164   is slv( 163 downto  0);
	subtype slv165   is slv( 164 downto  0); subtype slv166   is slv( 165 downto  0); subtype slv167   is slv( 166 downto  0); subtype slv168   is slv( 167 downto  0);
	subtype slv169   is slv( 168 downto  0); subtype slv170   is slv( 169 downto  0); subtype slv171   is slv( 170 downto  0); subtype slv172   is slv( 171 downto  0);
	subtype slv173   is slv( 172 downto  0); subtype slv174   is slv( 173 downto  0); subtype slv175   is slv( 174 downto  0); subtype slv176   is slv( 175 downto  0);
	subtype slv177   is slv( 176 downto  0); subtype slv178   is slv( 177 downto  0); subtype slv179   is slv( 178 downto  0); subtype slv180   is slv( 179 downto  0);
	subtype slv181   is slv( 180 downto  0); subtype slv182   is slv( 181 downto  0); subtype slv183   is slv( 182 downto  0); subtype slv184   is slv( 183 downto  0);
	subtype slv185   is slv( 184 downto  0); subtype slv186   is slv( 185 downto  0); subtype slv187   is slv( 186 downto  0); subtype slv188   is slv( 187 downto  0);
	subtype slv189   is slv( 188 downto  0); subtype slv190   is slv( 189 downto  0); subtype slv191   is slv( 190 downto  0); subtype slv192   is slv( 191 downto  0);
	subtype slv193   is slv( 192 downto  0); subtype slv194   is slv( 193 downto  0); subtype slv195   is slv( 194 downto  0); subtype slv196   is slv( 195 downto  0);
	subtype slv197   is slv( 196 downto  0); subtype slv198   is slv( 197 downto  0); subtype slv199   is slv( 198 downto  0); subtype slv200   is slv( 199 downto  0);
	subtype slv201   is slv( 200 downto  0); subtype slv202   is slv( 201 downto  0); subtype slv203   is slv( 202 downto  0); subtype slv204   is slv( 203 downto  0);
	subtype slv205   is slv( 204 downto  0); subtype slv206   is slv( 205 downto  0); subtype slv207   is slv( 206 downto  0); subtype slv208   is slv( 207 downto  0);
	subtype slv209   is slv( 208 downto  0); subtype slv210   is slv( 209 downto  0); subtype slv211   is slv( 210 downto  0); subtype slv212   is slv( 211 downto  0);
	subtype slv213   is slv( 212 downto  0); subtype slv214   is slv( 213 downto  0); subtype slv215   is slv( 214 downto  0); subtype slv216   is slv( 215 downto  0);
	subtype slv217   is slv( 216 downto  0); subtype slv218   is slv( 217 downto  0); subtype slv219   is slv( 218 downto  0); subtype slv220   is slv( 219 downto  0);
	subtype slv221   is slv( 220 downto  0); subtype slv222   is slv( 221 downto  0); subtype slv223   is slv( 222 downto  0); subtype slv224   is slv( 223 downto  0);
	subtype slv225   is slv( 224 downto  0); subtype slv226   is slv( 225 downto  0); subtype slv227   is slv( 226 downto  0); subtype slv228   is slv( 227 downto  0);
	subtype slv229   is slv( 228 downto  0); subtype slv230   is slv( 229 downto  0); subtype slv231   is slv( 230 downto  0); subtype slv232   is slv( 231 downto  0);
	subtype slv233   is slv( 232 downto  0); subtype slv234   is slv( 233 downto  0); subtype slv235   is slv( 234 downto  0); subtype slv236   is slv( 235 downto  0);
	subtype slv237   is slv( 236 downto  0); subtype slv238   is slv( 237 downto  0); subtype slv239   is slv( 238 downto  0); subtype slv240   is slv( 239 downto  0);
	subtype slv241   is slv( 240 downto  0); subtype slv242   is slv( 241 downto  0); subtype slv243   is slv( 242 downto  0); subtype slv244   is slv( 243 downto  0);
	subtype slv245   is slv( 244 downto  0); subtype slv246   is slv( 245 downto  0); subtype slv247   is slv( 246 downto  0); subtype slv248   is slv( 247 downto  0);
	subtype slv249   is slv( 248 downto  0); subtype slv250   is slv( 249 downto  0); subtype slv251   is slv( 250 downto  0); subtype slv252   is slv( 251 downto  0);
	subtype slv253   is slv( 252 downto  0); subtype slv254   is slv( 253 downto  0); subtype slv255   is slv( 254 downto  0); subtype slv256   is slv( 255 downto  0);
	subtype slv257   is slv( 256 downto  0); subtype slv258   is slv( 257 downto  0); subtype slv259   is slv( 258 downto  0); subtype slv260   is slv( 259 downto  0);
	subtype slv261   is slv( 260 downto  0); subtype slv262   is slv( 261 downto  0); subtype slv263   is slv( 262 downto  0); subtype slv264   is slv( 263 downto  0);
	subtype slv265   is slv( 264 downto  0); subtype slv266   is slv( 265 downto  0); subtype slv267   is slv( 266 downto  0); subtype slv268   is slv( 267 downto  0);
	subtype slv269   is slv( 268 downto  0); subtype slv270   is slv( 269 downto  0); subtype slv271   is slv( 270 downto  0); subtype slv272   is slv( 271 downto  0);
	subtype slv273   is slv( 272 downto  0); subtype slv274   is slv( 273 downto  0); subtype slv275   is slv( 274 downto  0); subtype slv276   is slv( 275 downto  0);
	subtype slv277   is slv( 276 downto  0); subtype slv278   is slv( 277 downto  0); subtype slv279   is slv( 278 downto  0); subtype slv280   is slv( 279 downto  0);
	subtype slv281   is slv( 280 downto  0); subtype slv282   is slv( 281 downto  0); subtype slv283   is slv( 282 downto  0); subtype slv284   is slv( 283 downto  0);
	subtype slv285   is slv( 284 downto  0); subtype slv286   is slv( 285 downto  0); subtype slv287   is slv( 286 downto  0); subtype slv288   is slv( 287 downto  0);
	subtype slv289   is slv( 288 downto  0); subtype slv290   is slv( 289 downto  0); subtype slv291   is slv( 290 downto  0); subtype slv292   is slv( 291 downto  0);
	subtype slv293   is slv( 292 downto  0); subtype slv294   is slv( 293 downto  0); subtype slv295   is slv( 294 downto  0); subtype slv296   is slv( 295 downto  0);
	subtype slv297   is slv( 296 downto  0); subtype slv298   is slv( 297 downto  0); subtype slv299   is slv( 298 downto  0); subtype slv300   is slv( 299 downto  0);
	subtype slv301   is slv( 300 downto  0); subtype slv302   is slv( 301 downto  0); subtype slv303   is slv( 302 downto  0); subtype slv304   is slv( 303 downto  0);
	subtype slv305   is slv( 304 downto  0); subtype slv306   is slv( 305 downto  0); subtype slv307   is slv( 306 downto  0); subtype slv308   is slv( 307 downto  0);
	subtype slv309   is slv( 308 downto  0); subtype slv310   is slv( 309 downto  0); subtype slv311   is slv( 310 downto  0); subtype slv312   is slv( 311 downto  0);
	subtype slv313   is slv( 312 downto  0); subtype slv314   is slv( 313 downto  0); subtype slv315   is slv( 314 downto  0); subtype slv316   is slv( 315 downto  0);
	subtype slv317   is slv( 316 downto  0); subtype slv318   is slv( 317 downto  0); subtype slv319   is slv( 318 downto  0); subtype slv320   is slv( 319 downto  0);
	subtype slv321   is slv( 320 downto  0); subtype slv322   is slv( 321 downto  0); subtype slv323   is slv( 322 downto  0); subtype slv324   is slv( 323 downto  0);
	subtype slv325   is slv( 324 downto  0); subtype slv326   is slv( 325 downto  0); subtype slv327   is slv( 326 downto  0); subtype slv328   is slv( 327 downto  0);
	subtype slv329   is slv( 328 downto  0); subtype slv330   is slv( 329 downto  0); subtype slv331   is slv( 330 downto  0); subtype slv332   is slv( 331 downto  0);
	subtype slv333   is slv( 332 downto  0); subtype slv334   is slv( 333 downto  0); subtype slv335   is slv( 334 downto  0); subtype slv336   is slv( 335 downto  0);
	subtype slv337   is slv( 336 downto  0); subtype slv338   is slv( 337 downto  0); subtype slv339   is slv( 338 downto  0); subtype slv340   is slv( 339 downto  0);
	subtype slv341   is slv( 340 downto  0); subtype slv342   is slv( 341 downto  0); subtype slv343   is slv( 342 downto  0); subtype slv344   is slv( 343 downto  0);
	subtype slv345   is slv( 344 downto  0); subtype slv346   is slv( 345 downto  0); subtype slv347   is slv( 346 downto  0); subtype slv348   is slv( 347 downto  0);
	subtype slv349   is slv( 348 downto  0); subtype slv350   is slv( 349 downto  0); subtype slv351   is slv( 350 downto  0); subtype slv352   is slv( 351 downto  0);
	subtype slv353   is slv( 352 downto  0); subtype slv354   is slv( 353 downto  0); subtype slv355   is slv( 354 downto  0); subtype slv356   is slv( 355 downto  0);
	subtype slv357   is slv( 356 downto  0); subtype slv358   is slv( 357 downto  0); subtype slv359   is slv( 358 downto  0); subtype slv360   is slv( 359 downto  0);
	subtype slv361   is slv( 360 downto  0); subtype slv362   is slv( 361 downto  0); subtype slv363   is slv( 362 downto  0); subtype slv364   is slv( 363 downto  0);
	subtype slv365   is slv( 364 downto  0); subtype slv366   is slv( 365 downto  0); subtype slv367   is slv( 366 downto  0); subtype slv368   is slv( 367 downto  0);
	subtype slv369   is slv( 368 downto  0); subtype slv370   is slv( 369 downto  0); subtype slv371   is slv( 370 downto  0); subtype slv372   is slv( 371 downto  0);
	subtype slv373   is slv( 372 downto  0); subtype slv374   is slv( 373 downto  0); subtype slv375   is slv( 374 downto  0); subtype slv376   is slv( 375 downto  0);
	subtype slv377   is slv( 376 downto  0); subtype slv378   is slv( 377 downto  0); subtype slv379   is slv( 378 downto  0); subtype slv380   is slv( 379 downto  0);
	subtype slv381   is slv( 380 downto  0); subtype slv382   is slv( 381 downto  0); subtype slv383   is slv( 382 downto  0); subtype slv384   is slv( 383 downto  0);
	subtype slv385   is slv( 384 downto  0); subtype slv386   is slv( 385 downto  0); subtype slv387   is slv( 386 downto  0); subtype slv388   is slv( 387 downto  0);
	subtype slv389   is slv( 388 downto  0); subtype slv390   is slv( 389 downto  0); subtype slv391   is slv( 390 downto  0); subtype slv392   is slv( 391 downto  0);
	subtype slv393   is slv( 392 downto  0); subtype slv394   is slv( 393 downto  0); subtype slv395   is slv( 394 downto  0); subtype slv396   is slv( 395 downto  0);
	subtype slv397   is slv( 396 downto  0); subtype slv398   is slv( 397 downto  0); subtype slv399   is slv( 398 downto  0); subtype slv400   is slv( 399 downto  0);
	subtype slv401   is slv( 400 downto  0); subtype slv402   is slv( 401 downto  0); subtype slv403   is slv( 402 downto  0); subtype slv404   is slv( 403 downto  0);
	subtype slv405   is slv( 404 downto  0); subtype slv406   is slv( 405 downto  0); subtype slv407   is slv( 406 downto  0); subtype slv408   is slv( 407 downto  0);
	subtype slv409   is slv( 408 downto  0); subtype slv410   is slv( 409 downto  0); subtype slv411   is slv( 410 downto  0); subtype slv412   is slv( 411 downto  0);
	subtype slv413   is slv( 412 downto  0); subtype slv414   is slv( 413 downto  0); subtype slv415   is slv( 414 downto  0); subtype slv416   is slv( 415 downto  0);
	subtype slv417   is slv( 416 downto  0); subtype slv418   is slv( 417 downto  0); subtype slv419   is slv( 418 downto  0); subtype slv420   is slv( 419 downto  0);
	subtype slv421   is slv( 420 downto  0); subtype slv422   is slv( 421 downto  0); subtype slv423   is slv( 422 downto  0); subtype slv424   is slv( 423 downto  0);
	subtype slv425   is slv( 424 downto  0); subtype slv426   is slv( 425 downto  0); subtype slv427   is slv( 426 downto  0); subtype slv428   is slv( 427 downto  0);
	subtype slv429   is slv( 428 downto  0); subtype slv430   is slv( 429 downto  0); subtype slv431   is slv( 430 downto  0); subtype slv432   is slv( 431 downto  0);
	subtype slv433   is slv( 432 downto  0); subtype slv434   is slv( 433 downto  0); subtype slv435   is slv( 434 downto  0); subtype slv436   is slv( 435 downto  0);
	subtype slv437   is slv( 436 downto  0); subtype slv438   is slv( 437 downto  0); subtype slv439   is slv( 438 downto  0); subtype slv440   is slv( 439 downto  0);
	subtype slv441   is slv( 440 downto  0); subtype slv442   is slv( 441 downto  0); subtype slv443   is slv( 442 downto  0); subtype slv444   is slv( 443 downto  0);
	subtype slv445   is slv( 444 downto  0); subtype slv446   is slv( 445 downto  0); subtype slv447   is slv( 446 downto  0); subtype slv448   is slv( 447 downto  0);
	subtype slv449   is slv( 448 downto  0); subtype slv450   is slv( 449 downto  0); subtype slv451   is slv( 450 downto  0); subtype slv452   is slv( 451 downto  0);
	subtype slv453   is slv( 452 downto  0); subtype slv454   is slv( 453 downto  0); subtype slv455   is slv( 454 downto  0); subtype slv456   is slv( 455 downto  0);
	subtype slv457   is slv( 456 downto  0); subtype slv458   is slv( 457 downto  0); subtype slv459   is slv( 458 downto  0); subtype slv460   is slv( 459 downto  0);
	subtype slv461   is slv( 460 downto  0); subtype slv462   is slv( 461 downto  0); subtype slv463   is slv( 462 downto  0); subtype slv464   is slv( 463 downto  0);
	subtype slv465   is slv( 464 downto  0); subtype slv466   is slv( 465 downto  0); subtype slv467   is slv( 466 downto  0); subtype slv468   is slv( 467 downto  0);
	subtype slv469   is slv( 468 downto  0); subtype slv470   is slv( 469 downto  0); subtype slv471   is slv( 470 downto  0); subtype slv472   is slv( 471 downto  0);
	subtype slv473   is slv( 472 downto  0); subtype slv474   is slv( 473 downto  0); subtype slv475   is slv( 474 downto  0); subtype slv476   is slv( 475 downto  0);
	subtype slv477   is slv( 476 downto  0); subtype slv478   is slv( 477 downto  0); subtype slv479   is slv( 478 downto  0); subtype slv480   is slv( 479 downto  0);
	subtype slv481   is slv( 480 downto  0); subtype slv482   is slv( 481 downto  0); subtype slv483   is slv( 482 downto  0); subtype slv484   is slv( 483 downto  0);
	subtype slv485   is slv( 484 downto  0); subtype slv486   is slv( 485 downto  0); subtype slv487   is slv( 486 downto  0); subtype slv488   is slv( 487 downto  0);
	subtype slv489   is slv( 488 downto  0); subtype slv490   is slv( 489 downto  0); subtype slv491   is slv( 490 downto  0); subtype slv492   is slv( 491 downto  0);
	subtype slv493   is slv( 492 downto  0); subtype slv494   is slv( 493 downto  0); subtype slv495   is slv( 494 downto  0); subtype slv496   is slv( 495 downto  0);
	subtype slv497   is slv( 496 downto  0); subtype slv498   is slv( 497 downto  0); subtype slv499   is slv( 498 downto  0); subtype slv500   is slv( 499 downto  0);
	subtype slv501   is slv( 500 downto  0); subtype slv502   is slv( 501 downto  0); subtype slv503   is slv( 502 downto  0); subtype slv504   is slv( 503 downto  0);
	subtype slv505   is slv( 504 downto  0); subtype slv506   is slv( 505 downto  0); subtype slv507   is slv( 506 downto  0); subtype slv508   is slv( 507 downto  0);
	subtype slv509   is slv( 508 downto  0); subtype slv510   is slv( 509 downto  0); subtype slv511   is slv( 510 downto  0); subtype slv512   is slv( 511 downto  0);
	subtype slv513   is slv( 512 downto  0); subtype slv514   is slv( 513 downto  0); subtype slv515   is slv( 514 downto  0); subtype slv516   is slv( 515 downto  0);
	subtype slv517   is slv( 516 downto  0); subtype slv518   is slv( 517 downto  0); subtype slv519   is slv( 518 downto  0); subtype slv520   is slv( 519 downto  0);
	subtype slv521   is slv( 520 downto  0); subtype slv522   is slv( 521 downto  0); subtype slv523   is slv( 522 downto  0); subtype slv524   is slv( 523 downto  0);
	subtype slv525   is slv( 524 downto  0); subtype slv526   is slv( 525 downto  0); subtype slv527   is slv( 526 downto  0); subtype slv528   is slv( 527 downto  0);
	subtype slv529   is slv( 528 downto  0); subtype slv530   is slv( 529 downto  0); subtype slv531   is slv( 530 downto  0); subtype slv532   is slv( 531 downto  0);
	subtype slv533   is slv( 532 downto  0); subtype slv534   is slv( 533 downto  0); subtype slv535   is slv( 534 downto  0); subtype slv536   is slv( 535 downto  0);
	subtype slv537   is slv( 536 downto  0); subtype slv538   is slv( 537 downto  0); subtype slv539   is slv( 538 downto  0); subtype slv540   is slv( 539 downto  0);
	subtype slv541   is slv( 540 downto  0); subtype slv542   is slv( 541 downto  0); subtype slv543   is slv( 542 downto  0); subtype slv544   is slv( 543 downto  0);
	subtype slv545   is slv( 544 downto  0); subtype slv546   is slv( 545 downto  0); subtype slv547   is slv( 546 downto  0); subtype slv548   is slv( 547 downto  0);
	subtype slv549   is slv( 548 downto  0); subtype slv550   is slv( 549 downto  0); subtype slv551   is slv( 550 downto  0); subtype slv552   is slv( 551 downto  0);
	subtype slv553   is slv( 552 downto  0); subtype slv554   is slv( 553 downto  0); subtype slv555   is slv( 554 downto  0); subtype slv556   is slv( 555 downto  0);
	subtype slv557   is slv( 556 downto  0); subtype slv558   is slv( 557 downto  0); subtype slv559   is slv( 558 downto  0); subtype slv560   is slv( 559 downto  0);
	subtype slv561   is slv( 560 downto  0); subtype slv562   is slv( 561 downto  0); subtype slv563   is slv( 562 downto  0); subtype slv564   is slv( 563 downto  0);
	subtype slv565   is slv( 564 downto  0); subtype slv566   is slv( 565 downto  0); subtype slv567   is slv( 566 downto  0); subtype slv568   is slv( 567 downto  0);
	subtype slv569   is slv( 568 downto  0); subtype slv570   is slv( 569 downto  0); subtype slv571   is slv( 570 downto  0); subtype slv572   is slv( 571 downto  0);
	subtype slv573   is slv( 572 downto  0); subtype slv574   is slv( 573 downto  0); subtype slv575   is slv( 574 downto  0); subtype slv576   is slv( 575 downto  0);
	subtype slv577   is slv( 576 downto  0); subtype slv578   is slv( 577 downto  0); subtype slv579   is slv( 578 downto  0); subtype slv580   is slv( 579 downto  0);
	subtype slv581   is slv( 580 downto  0); subtype slv582   is slv( 581 downto  0); subtype slv583   is slv( 582 downto  0); subtype slv584   is slv( 583 downto  0);
	subtype slv585   is slv( 584 downto  0); subtype slv586   is slv( 585 downto  0); subtype slv587   is slv( 586 downto  0); subtype slv588   is slv( 587 downto  0);
	subtype slv589   is slv( 588 downto  0); subtype slv590   is slv( 589 downto  0); subtype slv591   is slv( 590 downto  0); subtype slv592   is slv( 591 downto  0);
	subtype slv593   is slv( 592 downto  0); subtype slv594   is slv( 593 downto  0); subtype slv595   is slv( 594 downto  0); subtype slv596   is slv( 595 downto  0);
	subtype slv597   is slv( 596 downto  0); subtype slv598   is slv( 597 downto  0); subtype slv599   is slv( 598 downto  0); subtype slv600   is slv( 599 downto  0);
	subtype slv601   is slv( 600 downto  0); subtype slv602   is slv( 601 downto  0); subtype slv603   is slv( 602 downto  0); subtype slv604   is slv( 603 downto  0);
	subtype slv605   is slv( 604 downto  0); subtype slv606   is slv( 605 downto  0); subtype slv607   is slv( 606 downto  0); subtype slv608   is slv( 607 downto  0);
	subtype slv609   is slv( 608 downto  0); subtype slv610   is slv( 609 downto  0); subtype slv611   is slv( 610 downto  0); subtype slv612   is slv( 611 downto  0);
	subtype slv613   is slv( 612 downto  0); subtype slv614   is slv( 613 downto  0); subtype slv615   is slv( 614 downto  0); subtype slv616   is slv( 615 downto  0);
	subtype slv617   is slv( 616 downto  0); subtype slv618   is slv( 617 downto  0); subtype slv619   is slv( 618 downto  0); subtype slv620   is slv( 619 downto  0);
	subtype slv621   is slv( 620 downto  0); subtype slv622   is slv( 621 downto  0); subtype slv623   is slv( 622 downto  0); subtype slv624   is slv( 623 downto  0);
	subtype slv625   is slv( 624 downto  0); subtype slv626   is slv( 625 downto  0); subtype slv627   is slv( 626 downto  0); subtype slv628   is slv( 627 downto  0);
	subtype slv629   is slv( 628 downto  0); subtype slv630   is slv( 629 downto  0); subtype slv631   is slv( 630 downto  0); subtype slv632   is slv( 631 downto  0);
	subtype slv633   is slv( 632 downto  0); subtype slv634   is slv( 633 downto  0); subtype slv635   is slv( 634 downto  0); subtype slv636   is slv( 635 downto  0);
	subtype slv637   is slv( 636 downto  0); subtype slv638   is slv( 637 downto  0); subtype slv639   is slv( 638 downto  0); subtype slv640   is slv( 639 downto  0);
	subtype slv641   is slv( 640 downto  0); subtype slv642   is slv( 641 downto  0); subtype slv643   is slv( 642 downto  0); subtype slv644   is slv( 643 downto  0);
	subtype slv645   is slv( 644 downto  0); subtype slv646   is slv( 645 downto  0); subtype slv647   is slv( 646 downto  0); subtype slv648   is slv( 647 downto  0);
	subtype slv649   is slv( 648 downto  0); subtype slv650   is slv( 649 downto  0); subtype slv651   is slv( 650 downto  0); subtype slv652   is slv( 651 downto  0);
	subtype slv653   is slv( 652 downto  0); subtype slv654   is slv( 653 downto  0); subtype slv655   is slv( 654 downto  0); subtype slv656   is slv( 655 downto  0);
	subtype slv657   is slv( 656 downto  0); subtype slv658   is slv( 657 downto  0); subtype slv659   is slv( 658 downto  0); subtype slv660   is slv( 659 downto  0);
	subtype slv661   is slv( 660 downto  0); subtype slv662   is slv( 661 downto  0); subtype slv663   is slv( 662 downto  0); subtype slv664   is slv( 663 downto  0);
	subtype slv665   is slv( 664 downto  0); subtype slv666   is slv( 665 downto  0); subtype slv667   is slv( 666 downto  0); subtype slv668   is slv( 667 downto  0);
	subtype slv669   is slv( 668 downto  0); subtype slv670   is slv( 669 downto  0); subtype slv671   is slv( 670 downto  0); subtype slv672   is slv( 671 downto  0);
	subtype slv673   is slv( 672 downto  0); subtype slv674   is slv( 673 downto  0); subtype slv675   is slv( 674 downto  0); subtype slv676   is slv( 675 downto  0);
	subtype slv677   is slv( 676 downto  0); subtype slv678   is slv( 677 downto  0); subtype slv679   is slv( 678 downto  0); subtype slv680   is slv( 679 downto  0);
	subtype slv681   is slv( 680 downto  0); subtype slv682   is slv( 681 downto  0); subtype slv683   is slv( 682 downto  0); subtype slv684   is slv( 683 downto  0);
	subtype slv685   is slv( 684 downto  0); subtype slv686   is slv( 685 downto  0); subtype slv687   is slv( 686 downto  0); subtype slv688   is slv( 687 downto  0);
	subtype slv689   is slv( 688 downto  0); subtype slv690   is slv( 689 downto  0); subtype slv691   is slv( 690 downto  0); subtype slv692   is slv( 691 downto  0);
	subtype slv693   is slv( 692 downto  0); subtype slv694   is slv( 693 downto  0); subtype slv695   is slv( 694 downto  0); subtype slv696   is slv( 695 downto  0);
	subtype slv697   is slv( 696 downto  0); subtype slv698   is slv( 697 downto  0); subtype slv699   is slv( 698 downto  0); subtype slv700   is slv( 699 downto  0);
	subtype slv701   is slv( 700 downto  0); subtype slv702   is slv( 701 downto  0); subtype slv703   is slv( 702 downto  0); subtype slv704   is slv( 703 downto  0);
	subtype slv705   is slv( 704 downto  0); subtype slv706   is slv( 705 downto  0); subtype slv707   is slv( 706 downto  0); subtype slv708   is slv( 707 downto  0);
	subtype slv709   is slv( 708 downto  0); subtype slv710   is slv( 709 downto  0); subtype slv711   is slv( 710 downto  0); subtype slv712   is slv( 711 downto  0);
	subtype slv713   is slv( 712 downto  0); subtype slv714   is slv( 713 downto  0); subtype slv715   is slv( 714 downto  0); subtype slv716   is slv( 715 downto  0);
	subtype slv717   is slv( 716 downto  0); subtype slv718   is slv( 717 downto  0); subtype slv719   is slv( 718 downto  0); subtype slv720   is slv( 719 downto  0);
	subtype slv721   is slv( 720 downto  0); subtype slv722   is slv( 721 downto  0); subtype slv723   is slv( 722 downto  0); subtype slv724   is slv( 723 downto  0);
	subtype slv725   is slv( 724 downto  0); subtype slv726   is slv( 725 downto  0); subtype slv727   is slv( 726 downto  0); subtype slv728   is slv( 727 downto  0);
	subtype slv729   is slv( 728 downto  0); subtype slv730   is slv( 729 downto  0); subtype slv731   is slv( 730 downto  0); subtype slv732   is slv( 731 downto  0);
	subtype slv733   is slv( 732 downto  0); subtype slv734   is slv( 733 downto  0); subtype slv735   is slv( 734 downto  0); subtype slv736   is slv( 735 downto  0);
	subtype slv737   is slv( 736 downto  0); subtype slv738   is slv( 737 downto  0); subtype slv739   is slv( 738 downto  0); subtype slv740   is slv( 739 downto  0);
	subtype slv741   is slv( 740 downto  0); subtype slv742   is slv( 741 downto  0); subtype slv743   is slv( 742 downto  0); subtype slv744   is slv( 743 downto  0);
	subtype slv745   is slv( 744 downto  0); subtype slv746   is slv( 745 downto  0); subtype slv747   is slv( 746 downto  0); subtype slv748   is slv( 747 downto  0);
	subtype slv749   is slv( 748 downto  0); subtype slv750   is slv( 749 downto  0); subtype slv751   is slv( 750 downto  0); subtype slv752   is slv( 751 downto  0);
	subtype slv753   is slv( 752 downto  0); subtype slv754   is slv( 753 downto  0); subtype slv755   is slv( 754 downto  0); subtype slv756   is slv( 755 downto  0);
	subtype slv757   is slv( 756 downto  0); subtype slv758   is slv( 757 downto  0); subtype slv759   is slv( 758 downto  0); subtype slv760   is slv( 759 downto  0);
	subtype slv761   is slv( 760 downto  0); subtype slv762   is slv( 761 downto  0); subtype slv763   is slv( 762 downto  0); subtype slv764   is slv( 763 downto  0);
	subtype slv765   is slv( 764 downto  0); subtype slv766   is slv( 765 downto  0); subtype slv767   is slv( 766 downto  0); subtype slv768   is slv( 767 downto  0);
	subtype slv769   is slv( 768 downto  0); subtype slv770   is slv( 769 downto  0); subtype slv771   is slv( 770 downto  0); subtype slv772   is slv( 771 downto  0);
	subtype slv773   is slv( 772 downto  0); subtype slv774   is slv( 773 downto  0); subtype slv775   is slv( 774 downto  0); subtype slv776   is slv( 775 downto  0);
	subtype slv777   is slv( 776 downto  0); subtype slv778   is slv( 777 downto  0); subtype slv779   is slv( 778 downto  0); subtype slv780   is slv( 779 downto  0);
	subtype slv781   is slv( 780 downto  0); subtype slv782   is slv( 781 downto  0); subtype slv783   is slv( 782 downto  0); subtype slv784   is slv( 783 downto  0);
	subtype slv785   is slv( 784 downto  0); subtype slv786   is slv( 785 downto  0); subtype slv787   is slv( 786 downto  0); subtype slv788   is slv( 787 downto  0);
	subtype slv789   is slv( 788 downto  0); subtype slv790   is slv( 789 downto  0); subtype slv791   is slv( 790 downto  0); subtype slv792   is slv( 791 downto  0);
	subtype slv793   is slv( 792 downto  0); subtype slv794   is slv( 793 downto  0); subtype slv795   is slv( 794 downto  0); subtype slv796   is slv( 795 downto  0);
	subtype slv797   is slv( 796 downto  0); subtype slv798   is slv( 797 downto  0); subtype slv799   is slv( 798 downto  0); subtype slv800   is slv( 799 downto  0);
	subtype slv801   is slv( 800 downto  0); subtype slv802   is slv( 801 downto  0); subtype slv803   is slv( 802 downto  0); subtype slv804   is slv( 803 downto  0);
	subtype slv805   is slv( 804 downto  0); subtype slv806   is slv( 805 downto  0); subtype slv807   is slv( 806 downto  0); subtype slv808   is slv( 807 downto  0);
	subtype slv809   is slv( 808 downto  0); subtype slv810   is slv( 809 downto  0); subtype slv811   is slv( 810 downto  0); subtype slv812   is slv( 811 downto  0);
	subtype slv813   is slv( 812 downto  0); subtype slv814   is slv( 813 downto  0); subtype slv815   is slv( 814 downto  0); subtype slv816   is slv( 815 downto  0);
	subtype slv817   is slv( 816 downto  0); subtype slv818   is slv( 817 downto  0); subtype slv819   is slv( 818 downto  0); subtype slv820   is slv( 819 downto  0);
	subtype slv821   is slv( 820 downto  0); subtype slv822   is slv( 821 downto  0); subtype slv823   is slv( 822 downto  0); subtype slv824   is slv( 823 downto  0);
	subtype slv825   is slv( 824 downto  0); subtype slv826   is slv( 825 downto  0); subtype slv827   is slv( 826 downto  0); subtype slv828   is slv( 827 downto  0);
	subtype slv829   is slv( 828 downto  0); subtype slv830   is slv( 829 downto  0); subtype slv831   is slv( 830 downto  0); subtype slv832   is slv( 831 downto  0);
	subtype slv833   is slv( 832 downto  0); subtype slv834   is slv( 833 downto  0); subtype slv835   is slv( 834 downto  0); subtype slv836   is slv( 835 downto  0);
	subtype slv837   is slv( 836 downto  0); subtype slv838   is slv( 837 downto  0); subtype slv839   is slv( 838 downto  0); subtype slv840   is slv( 839 downto  0);
	subtype slv841   is slv( 840 downto  0); subtype slv842   is slv( 841 downto  0); subtype slv843   is slv( 842 downto  0); subtype slv844   is slv( 843 downto  0);
	subtype slv845   is slv( 844 downto  0); subtype slv846   is slv( 845 downto  0); subtype slv847   is slv( 846 downto  0); subtype slv848   is slv( 847 downto  0);
	subtype slv849   is slv( 848 downto  0); subtype slv850   is slv( 849 downto  0); subtype slv851   is slv( 850 downto  0); subtype slv852   is slv( 851 downto  0);
	subtype slv853   is slv( 852 downto  0); subtype slv854   is slv( 853 downto  0); subtype slv855   is slv( 854 downto  0); subtype slv856   is slv( 855 downto  0);
	subtype slv857   is slv( 856 downto  0); subtype slv858   is slv( 857 downto  0); subtype slv859   is slv( 858 downto  0); subtype slv860   is slv( 859 downto  0);
	subtype slv861   is slv( 860 downto  0); subtype slv862   is slv( 861 downto  0); subtype slv863   is slv( 862 downto  0); subtype slv864   is slv( 863 downto  0);
	subtype slv865   is slv( 864 downto  0); subtype slv866   is slv( 865 downto  0); subtype slv867   is slv( 866 downto  0); subtype slv868   is slv( 867 downto  0);
	subtype slv869   is slv( 868 downto  0); subtype slv870   is slv( 869 downto  0); subtype slv871   is slv( 870 downto  0); subtype slv872   is slv( 871 downto  0);
	subtype slv873   is slv( 872 downto  0); subtype slv874   is slv( 873 downto  0); subtype slv875   is slv( 874 downto  0); subtype slv876   is slv( 875 downto  0);
	subtype slv877   is slv( 876 downto  0); subtype slv878   is slv( 877 downto  0); subtype slv879   is slv( 878 downto  0); subtype slv880   is slv( 879 downto  0);
	subtype slv881   is slv( 880 downto  0); subtype slv882   is slv( 881 downto  0); subtype slv883   is slv( 882 downto  0); subtype slv884   is slv( 883 downto  0);
	subtype slv885   is slv( 884 downto  0); subtype slv886   is slv( 885 downto  0); subtype slv887   is slv( 886 downto  0); subtype slv888   is slv( 887 downto  0);
	subtype slv889   is slv( 888 downto  0); subtype slv890   is slv( 889 downto  0); subtype slv891   is slv( 890 downto  0); subtype slv892   is slv( 891 downto  0);
	subtype slv893   is slv( 892 downto  0); subtype slv894   is slv( 893 downto  0); subtype slv895   is slv( 894 downto  0); subtype slv896   is slv( 895 downto  0);
	subtype slv897   is slv( 896 downto  0); subtype slv898   is slv( 897 downto  0); subtype slv899   is slv( 898 downto  0); subtype slv900   is slv( 899 downto  0);
	subtype slv901   is slv( 900 downto  0); subtype slv902   is slv( 901 downto  0); subtype slv903   is slv( 902 downto  0); subtype slv904   is slv( 903 downto  0);
	subtype slv905   is slv( 904 downto  0); subtype slv906   is slv( 905 downto  0); subtype slv907   is slv( 906 downto  0); subtype slv908   is slv( 907 downto  0);
	subtype slv909   is slv( 908 downto  0); subtype slv910   is slv( 909 downto  0); subtype slv911   is slv( 910 downto  0); subtype slv912   is slv( 911 downto  0);
	subtype slv913   is slv( 912 downto  0); subtype slv914   is slv( 913 downto  0); subtype slv915   is slv( 914 downto  0); subtype slv916   is slv( 915 downto  0);
	subtype slv917   is slv( 916 downto  0); subtype slv918   is slv( 917 downto  0); subtype slv919   is slv( 918 downto  0); subtype slv920   is slv( 919 downto  0);
	subtype slv921   is slv( 920 downto  0); subtype slv922   is slv( 921 downto  0); subtype slv923   is slv( 922 downto  0); subtype slv924   is slv( 923 downto  0);
	subtype slv925   is slv( 924 downto  0); subtype slv926   is slv( 925 downto  0); subtype slv927   is slv( 926 downto  0); subtype slv928   is slv( 927 downto  0);
	subtype slv929   is slv( 928 downto  0); subtype slv930   is slv( 929 downto  0); subtype slv931   is slv( 930 downto  0); subtype slv932   is slv( 931 downto  0);
	subtype slv933   is slv( 932 downto  0); subtype slv934   is slv( 933 downto  0); subtype slv935   is slv( 934 downto  0); subtype slv936   is slv( 935 downto  0);
	subtype slv937   is slv( 936 downto  0); subtype slv938   is slv( 937 downto  0); subtype slv939   is slv( 938 downto  0); subtype slv940   is slv( 939 downto  0);
	subtype slv941   is slv( 940 downto  0); subtype slv942   is slv( 941 downto  0); subtype slv943   is slv( 942 downto  0); subtype slv944   is slv( 943 downto  0);
	subtype slv945   is slv( 944 downto  0); subtype slv946   is slv( 945 downto  0); subtype slv947   is slv( 946 downto  0); subtype slv948   is slv( 947 downto  0);
	subtype slv949   is slv( 948 downto  0); subtype slv950   is slv( 949 downto  0); subtype slv951   is slv( 950 downto  0); subtype slv952   is slv( 951 downto  0);
	subtype slv953   is slv( 952 downto  0); subtype slv954   is slv( 953 downto  0); subtype slv955   is slv( 954 downto  0); subtype slv956   is slv( 955 downto  0);
	subtype slv957   is slv( 956 downto  0); subtype slv958   is slv( 957 downto  0); subtype slv959   is slv( 958 downto  0); subtype slv960   is slv( 959 downto  0);
	subtype slv961   is slv( 960 downto  0); subtype slv962   is slv( 961 downto  0); subtype slv963   is slv( 962 downto  0); subtype slv964   is slv( 963 downto  0);
	subtype slv965   is slv( 964 downto  0); subtype slv966   is slv( 965 downto  0); subtype slv967   is slv( 966 downto  0); subtype slv968   is slv( 967 downto  0);
	subtype slv969   is slv( 968 downto  0); subtype slv970   is slv( 969 downto  0); subtype slv971   is slv( 970 downto  0); subtype slv972   is slv( 971 downto  0);
	subtype slv973   is slv( 972 downto  0); subtype slv974   is slv( 973 downto  0); subtype slv975   is slv( 974 downto  0); subtype slv976   is slv( 975 downto  0);
	subtype slv977   is slv( 976 downto  0); subtype slv978   is slv( 977 downto  0); subtype slv979   is slv( 978 downto  0); subtype slv980   is slv( 979 downto  0);
	subtype slv981   is slv( 980 downto  0); subtype slv982   is slv( 981 downto  0); subtype slv983   is slv( 982 downto  0); subtype slv984   is slv( 983 downto  0);
	subtype slv985   is slv( 984 downto  0); subtype slv986   is slv( 985 downto  0); subtype slv987   is slv( 986 downto  0); subtype slv988   is slv( 987 downto  0);
	subtype slv989   is slv( 988 downto  0); subtype slv990   is slv( 989 downto  0); subtype slv991   is slv( 990 downto  0); subtype slv992   is slv( 991 downto  0);
	subtype slv993   is slv( 992 downto  0); subtype slv994   is slv( 993 downto  0); subtype slv995   is slv( 994 downto  0); subtype slv996   is slv( 995 downto  0);
	subtype slv997   is slv( 996 downto  0); subtype slv998   is slv( 997 downto  0); subtype slv999   is slv( 998 downto  0); subtype slv1000  is slv( 999 downto  0);
	subtype slv1001  is slv(1000 downto  0); subtype slv1002  is slv(1001 downto  0); subtype slv1003  is slv(1002 downto  0); subtype slv1004  is slv(1003 downto  0);
	subtype slv1005  is slv(1004 downto  0); subtype slv1006  is slv(1005 downto  0); subtype slv1007  is slv(1006 downto  0); subtype slv1008  is slv(1007 downto  0);
	subtype slv1009  is slv(1008 downto  0); subtype slv1010  is slv(1009 downto  0); subtype slv1011  is slv(1010 downto  0); subtype slv1012  is slv(1011 downto  0);
	subtype slv1013  is slv(1012 downto  0); subtype slv1014  is slv(1013 downto  0); subtype slv1015  is slv(1014 downto  0); subtype slv1016  is slv(1015 downto  0);
	subtype slv1017  is slv(1016 downto  0); subtype slv1018  is slv(1017 downto  0); subtype slv1019  is slv(1018 downto  0); subtype slv1020  is slv(1019 downto  0);
	subtype slv1021  is slv(1020 downto  0); subtype slv1022  is slv(1021 downto  0); subtype slv1023  is slv(1022 downto  0); subtype slv1024  is slv(1023 downto  0);

	subtype slv1_1   is slv(   1 downto  1); subtype slv2_1   is slv(   2 downto  1); subtype slv3_1   is slv(   3 downto  1); subtype slv4_1   is slv(   4 downto  1);
	subtype slv5_1   is slv(   5 downto  1); subtype slv6_1   is slv(   6 downto  1); subtype slv7_1   is slv(   7 downto  1); subtype slv8_1   is slv(   8 downto  1);
	subtype slv9_1   is slv(   9 downto  1); subtype slv10_1  is slv(  10 downto  1); subtype slv11_1  is slv(  11 downto  1); subtype slv12_1  is slv(  12 downto  1);
	subtype slv13_1  is slv(  13 downto  1); subtype slv14_1  is slv(  14 downto  1); subtype slv15_1  is slv(  15 downto  1); subtype slv16_1  is slv(  16 downto  1);
	subtype slv17_1  is slv(  17 downto  1); subtype slv18_1  is slv(  18 downto  1); subtype slv19_1  is slv(  19 downto  1); subtype slv20_1  is slv(  20 downto  1);

	                                         subtype slv2_2   is slv(   2 downto  2); subtype slv3_2   is slv(   3 downto  2); subtype slv4_2   is slv(   4 downto  2);
	subtype slv5_2   is slv(   5 downto  2); subtype slv6_2   is slv(   6 downto  2); subtype slv7_2   is slv(   7 downto  2); subtype slv8_2   is slv(   8 downto  2);
	subtype slv9_2   is slv(   9 downto  2); subtype slv10_2  is slv(  10 downto  2); subtype slv11_2  is slv(  11 downto  2); subtype slv12_2  is slv(  12 downto  2);
	subtype slv13_2  is slv(  13 downto  2); subtype slv14_2  is slv(  14 downto  2); subtype slv15_2  is slv(  15 downto  2); subtype slv16_2  is slv(  16 downto  2);
	subtype slv17_2  is slv(  17 downto  2); subtype slv18_2  is slv(  18 downto  2); subtype slv19_2  is slv(  19 downto  2); subtype slv20_2  is slv(  20 downto  2);
	subtype slv21_2  is slv(  21 downto  2); subtype slv22_2  is slv(  22 downto  2); subtype slv23_2  is slv(  23 downto  2); subtype slv24_2  is slv(  24 downto  2);
	subtype slv25_2  is slv(  25 downto  2); subtype slv26_2  is slv(  26 downto  2); subtype slv27_2  is slv(  27 downto  2); subtype slv28_2  is slv(  28 downto  2);
	subtype slv29_2  is slv(  29 downto  2); subtype slv30_2  is slv(  30 downto  2); subtype slv31_2  is slv(  31 downto  2); subtype slv32_2  is slv(  32 downto  2);

	                                                                                  subtype slv3_3   is slv(   3 downto  3); subtype slv4_3   is slv(   4 downto  3);
	subtype slv5_3   is slv(   5 downto  3); subtype slv6_3   is slv(   6 downto  3); subtype slv7_3   is slv(   7 downto  3); subtype slv8_3   is slv(   8 downto  3);
	subtype slv9_3   is slv(   9 downto  3); subtype slv10_3  is slv(  10 downto  3); subtype slv11_3  is slv(  11 downto  3); subtype slv12_3  is slv(  12 downto  3);
	subtype slv13_3  is slv(  13 downto  3); subtype slv14_3  is slv(  14 downto  3); subtype slv15_3  is slv(  15 downto  3); subtype slv16_3  is slv(  16 downto  3);
	subtype slv17_3  is slv(  17 downto  3); subtype slv18_3  is slv(  18 downto  3); subtype slv19_3  is slv(  19 downto  3); subtype slv20_3  is slv(  20 downto  3);

	                                                                                                                           subtype slv4_4   is slv(   4 downto  4);
	subtype slv5_4   is slv(   5 downto  4); subtype slv6_4   is slv(   6 downto  4); subtype slv7_4   is slv(   7 downto  4); subtype slv8_4   is slv(   8 downto  4);
	subtype slv9_4   is slv(   9 downto  4); subtype slv10_4  is slv(  10 downto  4); subtype slv11_4  is slv(  11 downto  4); subtype slv12_4  is slv(  12 downto  4);
	subtype slv13_4  is slv(  13 downto  4); subtype slv14_4  is slv(  14 downto  4); subtype slv15_4  is slv(  15 downto  4); subtype slv16_4  is slv(  16 downto  4);
	subtype slv17_4  is slv(  17 downto  4); subtype slv18_4  is slv(  18 downto  4); subtype slv19_4  is slv(  19 downto  4); subtype slv20_4  is slv(  20 downto  4);

	subtype slv5_5   is slv(   5 downto  5); subtype slv6_5   is slv(   6 downto  5); subtype slv7_5   is slv(   7 downto  5); subtype slv8_5   is slv(   8 downto  5);
	subtype slv9_5   is slv(   9 downto  5); subtype slv10_5  is slv(  10 downto  5); subtype slv11_5  is slv(  11 downto  5); subtype slv12_5  is slv(  12 downto  5);
	subtype slv13_5  is slv(  13 downto  5); subtype slv14_5  is slv(  14 downto  5); subtype slv15_5  is slv(  15 downto  5); subtype slv16_5  is slv(  16 downto  5);
	subtype slv17_5  is slv(  17 downto  5); subtype slv18_5  is slv(  18 downto  5); subtype slv19_5  is slv(  19 downto  5); subtype slv20_5  is slv(  20 downto  5);

	                                         subtype slv6_6   is slv(   6 downto  6); subtype slv7_6   is slv(   7 downto  6); subtype slv8_6   is slv(   8 downto  6);
	subtype slv9_6   is slv(   9 downto  6); subtype slv10_6  is slv(  10 downto  6); subtype slv11_6  is slv(  11 downto  6); subtype slv12_6  is slv(  12 downto  6);
	subtype slv13_6  is slv(  13 downto  6); subtype slv14_6  is slv(  14 downto  6); subtype slv15_6  is slv(  15 downto  6); subtype slv16_6  is slv(  16 downto  6);
	subtype slv17_6  is slv(  17 downto  6); subtype slv18_6  is slv(  18 downto  6); subtype slv19_6  is slv(  19 downto  6); subtype slv20_6  is slv(  20 downto  6);

	                                                                                  subtype slv7_7   is slv(   7 downto  7); subtype slv8_7   is slv(   8 downto  7);
	subtype slv9_7   is slv(   9 downto  7); subtype slv10_7  is slv(  10 downto  7); subtype slv11_7  is slv(  11 downto  7); subtype slv12_7  is slv(  12 downto  7);
	subtype slv13_7  is slv(  13 downto  7); subtype slv14_7  is slv(  14 downto  7); subtype slv15_7  is slv(  15 downto  7); subtype slv16_7  is slv(  16 downto  7);
	subtype slv17_7  is slv(  17 downto  7); subtype slv18_7  is slv(  18 downto  7); subtype slv19_7  is slv(  19 downto  7); subtype slv20_7  is slv(  20 downto  7);

	                                                                                                                           subtype slv8_8   is slv(   8 downto  8);
	subtype slv9_8   is slv(   9 downto  8); subtype slv10_8  is slv(  10 downto  8); subtype slv11_8  is slv(  11 downto  8); subtype slv12_8  is slv(  12 downto  8);
	subtype slv13_8  is slv(  13 downto  8); subtype slv14_8  is slv(  14 downto  8); subtype slv15_8  is slv(  15 downto  8); subtype slv16_8  is slv(  16 downto  8);
	subtype slv17_8  is slv(  17 downto  8); subtype slv18_8  is slv(  18 downto  8); subtype slv19_8  is slv(  19 downto  8); subtype slv20_8  is slv(  20 downto  8);

	subtype slv9_9   is slv(   9 downto  9); subtype slv10_9  is slv(  10 downto  9); subtype slv11_9  is slv(  11 downto  9); subtype slv12_9  is slv(  12 downto  9);
	subtype slv13_9  is slv(  13 downto  9); subtype slv14_9  is slv(  14 downto  9); subtype slv15_9  is slv(  15 downto  9); subtype slv16_9  is slv(  16 downto  9);
	subtype slv17_9  is slv(  17 downto  9); subtype slv18_9  is slv(  18 downto  9); subtype slv19_9  is slv(  19 downto  9); subtype slv20_9  is slv(  20 downto  9);

	                                         subtype slv10_10 is slv(  10 downto 10); subtype slv11_10 is slv(  11 downto 10); subtype slv12_10 is slv(  12 downto 10);
	subtype slv13_10 is slv(  13 downto 10); subtype slv14_10 is slv(  14 downto 10); subtype slv15_10 is slv(  15 downto 10); subtype slv16_10 is slv(  16 downto 10);
	subtype slv17_10 is slv(  17 downto 10); subtype slv18_10 is slv(  18 downto 10); subtype slv19_10 is slv(  19 downto 10); subtype slv20_10 is slv(  20 downto 10);

	                                                                                  subtype slv11_11 is slv(  11 downto 11); subtype slv12_11 is slv(  12 downto 11);
	subtype slv13_11 is slv(  13 downto 11); subtype slv14_11 is slv(  14 downto 11); subtype slv15_11 is slv(  15 downto 11); subtype slv16_11 is slv(  16 downto 11);
	subtype slv17_11 is slv(  17 downto 11); subtype slv18_11 is slv(  18 downto 11); subtype slv19_11 is slv(  19 downto 11); subtype slv20_11 is slv(  20 downto 11);

	                                                                                                                           subtype slv12_12 is slv(  12 downto 12);
	subtype slv13_12 is slv(  13 downto 12); subtype slv14_12 is slv(  14 downto 12); subtype slv15_12 is slv(  15 downto 12); subtype slv16_12 is slv(  16 downto 12);
	subtype slv17_12 is slv(  17 downto 12); subtype slv18_12 is slv(  18 downto 12); subtype slv19_12 is slv(  19 downto 12); subtype slv20_12 is slv(  20 downto 12);

	subtype slv13_13 is slv(  13 downto 13); subtype slv14_13 is slv(  14 downto 13); subtype slv15_13 is slv(  15 downto 13); subtype slv16_13 is slv(  16 downto 13);
	subtype slv17_13 is slv(  17 downto 13); subtype slv18_13 is slv(  18 downto 13); subtype slv19_13 is slv(  19 downto 13); subtype slv20_13 is slv(  20 downto 13);

	                                         subtype slv14_14 is slv(  14 downto 14); subtype slv15_14 is slv(  15 downto 14); subtype slv16_14 is slv(  16 downto 14);
	subtype slv17_14 is slv(  17 downto 14); subtype slv18_14 is slv(  18 downto 14); subtype slv19_14 is slv(  19 downto 14); subtype slv20_14 is slv(  20 downto 14);

	                                                                                  subtype slv15_15 is slv(  15 downto 15); subtype slv16_15 is slv(  16 downto 15);
	subtype slv17_15 is slv(  17 downto 15); subtype slv18_15 is slv(  18 downto 15); subtype slv19_15 is slv(  19 downto 15); subtype slv20_15 is slv(  20 downto 15);

	type slv1array   is array(natural range <>) of slv1  ;   type slv129array is array(natural range <>) of slv129;   type slv257array is array(natural range <>) of slv257;   type slv385array is array(natural range <>) of slv385;   type slv513array is array(natural range <>) of slv513;   type slv641array is array(natural range <>) of slv641;   type slv769array is array(natural range <>) of slv769;   type slv897array  is array(natural range <>) of slv897 ;
	type slv2array   is array(natural range <>) of slv2  ;   type slv130array is array(natural range <>) of slv130;   type slv258array is array(natural range <>) of slv258;   type slv386array is array(natural range <>) of slv386;   type slv514array is array(natural range <>) of slv514;   type slv642array is array(natural range <>) of slv642;   type slv770array is array(natural range <>) of slv770;   type slv898array  is array(natural range <>) of slv898 ;
	type slv3array   is array(natural range <>) of slv3  ;   type slv131array is array(natural range <>) of slv131;   type slv259array is array(natural range <>) of slv259;   type slv387array is array(natural range <>) of slv387;   type slv515array is array(natural range <>) of slv515;   type slv643array is array(natural range <>) of slv643;   type slv771array is array(natural range <>) of slv771;   type slv899array  is array(natural range <>) of slv899 ;
	type slv4array   is array(natural range <>) of slv4  ;   type slv132array is array(natural range <>) of slv132;   type slv260array is array(natural range <>) of slv260;   type slv388array is array(natural range <>) of slv388;   type slv516array is array(natural range <>) of slv516;   type slv644array is array(natural range <>) of slv644;   type slv772array is array(natural range <>) of slv772;   type slv900array  is array(natural range <>) of slv900 ;
	type slv5array   is array(natural range <>) of slv5  ;   type slv133array is array(natural range <>) of slv133;   type slv261array is array(natural range <>) of slv261;   type slv389array is array(natural range <>) of slv389;   type slv517array is array(natural range <>) of slv517;   type slv645array is array(natural range <>) of slv645;   type slv773array is array(natural range <>) of slv773;   type slv901array  is array(natural range <>) of slv901 ;
	type slv6array   is array(natural range <>) of slv6  ;   type slv134array is array(natural range <>) of slv134;   type slv262array is array(natural range <>) of slv262;   type slv390array is array(natural range <>) of slv390;   type slv518array is array(natural range <>) of slv518;   type slv646array is array(natural range <>) of slv646;   type slv774array is array(natural range <>) of slv774;   type slv902array  is array(natural range <>) of slv902 ;
	type slv7array   is array(natural range <>) of slv7  ;   type slv135array is array(natural range <>) of slv135;   type slv263array is array(natural range <>) of slv263;   type slv391array is array(natural range <>) of slv391;   type slv519array is array(natural range <>) of slv519;   type slv647array is array(natural range <>) of slv647;   type slv775array is array(natural range <>) of slv775;   type slv903array  is array(natural range <>) of slv903 ;
	type slv8array   is array(natural range <>) of slv8  ;   type slv136array is array(natural range <>) of slv136;   type slv264array is array(natural range <>) of slv264;   type slv392array is array(natural range <>) of slv392;   type slv520array is array(natural range <>) of slv520;   type slv648array is array(natural range <>) of slv648;   type slv776array is array(natural range <>) of slv776;   type slv904array  is array(natural range <>) of slv904 ;
	type slv9array   is array(natural range <>) of slv9  ;   type slv137array is array(natural range <>) of slv137;   type slv265array is array(natural range <>) of slv265;   type slv393array is array(natural range <>) of slv393;   type slv521array is array(natural range <>) of slv521;   type slv649array is array(natural range <>) of slv649;   type slv777array is array(natural range <>) of slv777;   type slv905array  is array(natural range <>) of slv905 ;
	type slv10array  is array(natural range <>) of slv10 ;   type slv138array is array(natural range <>) of slv138;   type slv266array is array(natural range <>) of slv266;   type slv394array is array(natural range <>) of slv394;   type slv522array is array(natural range <>) of slv522;   type slv650array is array(natural range <>) of slv650;   type slv778array is array(natural range <>) of slv778;   type slv906array  is array(natural range <>) of slv906 ;
	type slv11array  is array(natural range <>) of slv11 ;   type slv139array is array(natural range <>) of slv139;   type slv267array is array(natural range <>) of slv267;   type slv395array is array(natural range <>) of slv395;   type slv523array is array(natural range <>) of slv523;   type slv651array is array(natural range <>) of slv651;   type slv779array is array(natural range <>) of slv779;   type slv907array  is array(natural range <>) of slv907 ;
	type slv12array  is array(natural range <>) of slv12 ;   type slv140array is array(natural range <>) of slv140;   type slv268array is array(natural range <>) of slv268;   type slv396array is array(natural range <>) of slv396;   type slv524array is array(natural range <>) of slv524;   type slv652array is array(natural range <>) of slv652;   type slv780array is array(natural range <>) of slv780;   type slv908array  is array(natural range <>) of slv908 ;
	type slv13array  is array(natural range <>) of slv13 ;   type slv141array is array(natural range <>) of slv141;   type slv269array is array(natural range <>) of slv269;   type slv397array is array(natural range <>) of slv397;   type slv525array is array(natural range <>) of slv525;   type slv653array is array(natural range <>) of slv653;   type slv781array is array(natural range <>) of slv781;   type slv909array  is array(natural range <>) of slv909 ;
	type slv14array  is array(natural range <>) of slv14 ;   type slv142array is array(natural range <>) of slv142;   type slv270array is array(natural range <>) of slv270;   type slv398array is array(natural range <>) of slv398;   type slv526array is array(natural range <>) of slv526;   type slv654array is array(natural range <>) of slv654;   type slv782array is array(natural range <>) of slv782;   type slv910array  is array(natural range <>) of slv910 ;
	type slv15array  is array(natural range <>) of slv15 ;   type slv143array is array(natural range <>) of slv143;   type slv271array is array(natural range <>) of slv271;   type slv399array is array(natural range <>) of slv399;   type slv527array is array(natural range <>) of slv527;   type slv655array is array(natural range <>) of slv655;   type slv783array is array(natural range <>) of slv783;   type slv911array  is array(natural range <>) of slv911 ;
	type slv16array  is array(natural range <>) of slv16 ;   type slv144array is array(natural range <>) of slv144;   type slv272array is array(natural range <>) of slv272;   type slv400array is array(natural range <>) of slv400;   type slv528array is array(natural range <>) of slv528;   type slv656array is array(natural range <>) of slv656;   type slv784array is array(natural range <>) of slv784;   type slv912array  is array(natural range <>) of slv912 ;
	type slv17array  is array(natural range <>) of slv17 ;   type slv145array is array(natural range <>) of slv145;   type slv273array is array(natural range <>) of slv273;   type slv401array is array(natural range <>) of slv401;   type slv529array is array(natural range <>) of slv529;   type slv657array is array(natural range <>) of slv657;   type slv785array is array(natural range <>) of slv785;   type slv913array  is array(natural range <>) of slv913 ;
	type slv18array  is array(natural range <>) of slv18 ;   type slv146array is array(natural range <>) of slv146;   type slv274array is array(natural range <>) of slv274;   type slv402array is array(natural range <>) of slv402;   type slv530array is array(natural range <>) of slv530;   type slv658array is array(natural range <>) of slv658;   type slv786array is array(natural range <>) of slv786;   type slv914array  is array(natural range <>) of slv914 ;
	type slv19array  is array(natural range <>) of slv19 ;   type slv147array is array(natural range <>) of slv147;   type slv275array is array(natural range <>) of slv275;   type slv403array is array(natural range <>) of slv403;   type slv531array is array(natural range <>) of slv531;   type slv659array is array(natural range <>) of slv659;   type slv787array is array(natural range <>) of slv787;   type slv915array  is array(natural range <>) of slv915 ;
	type slv20array  is array(natural range <>) of slv20 ;   type slv148array is array(natural range <>) of slv148;   type slv276array is array(natural range <>) of slv276;   type slv404array is array(natural range <>) of slv404;   type slv532array is array(natural range <>) of slv532;   type slv660array is array(natural range <>) of slv660;   type slv788array is array(natural range <>) of slv788;   type slv916array  is array(natural range <>) of slv916 ;
	type slv21array  is array(natural range <>) of slv21 ;   type slv149array is array(natural range <>) of slv149;   type slv277array is array(natural range <>) of slv277;   type slv405array is array(natural range <>) of slv405;   type slv533array is array(natural range <>) of slv533;   type slv661array is array(natural range <>) of slv661;   type slv789array is array(natural range <>) of slv789;   type slv917array  is array(natural range <>) of slv917 ;
	type slv22array  is array(natural range <>) of slv22 ;   type slv150array is array(natural range <>) of slv150;   type slv278array is array(natural range <>) of slv278;   type slv406array is array(natural range <>) of slv406;   type slv534array is array(natural range <>) of slv534;   type slv662array is array(natural range <>) of slv662;   type slv790array is array(natural range <>) of slv790;   type slv918array  is array(natural range <>) of slv918 ;
	type slv23array  is array(natural range <>) of slv23 ;   type slv151array is array(natural range <>) of slv151;   type slv279array is array(natural range <>) of slv279;   type slv407array is array(natural range <>) of slv407;   type slv535array is array(natural range <>) of slv535;   type slv663array is array(natural range <>) of slv663;   type slv791array is array(natural range <>) of slv791;   type slv919array  is array(natural range <>) of slv919 ;
	type slv24array  is array(natural range <>) of slv24 ;   type slv152array is array(natural range <>) of slv152;   type slv280array is array(natural range <>) of slv280;   type slv408array is array(natural range <>) of slv408;   type slv536array is array(natural range <>) of slv536;   type slv664array is array(natural range <>) of slv664;   type slv792array is array(natural range <>) of slv792;   type slv920array  is array(natural range <>) of slv920 ;
	type slv25array  is array(natural range <>) of slv25 ;   type slv153array is array(natural range <>) of slv153;   type slv281array is array(natural range <>) of slv281;   type slv409array is array(natural range <>) of slv409;   type slv537array is array(natural range <>) of slv537;   type slv665array is array(natural range <>) of slv665;   type slv793array is array(natural range <>) of slv793;   type slv921array  is array(natural range <>) of slv921 ;
	type slv26array  is array(natural range <>) of slv26 ;   type slv154array is array(natural range <>) of slv154;   type slv282array is array(natural range <>) of slv282;   type slv410array is array(natural range <>) of slv410;   type slv538array is array(natural range <>) of slv538;   type slv666array is array(natural range <>) of slv666;   type slv794array is array(natural range <>) of slv794;   type slv922array  is array(natural range <>) of slv922 ;
	type slv27array  is array(natural range <>) of slv27 ;   type slv155array is array(natural range <>) of slv155;   type slv283array is array(natural range <>) of slv283;   type slv411array is array(natural range <>) of slv411;   type slv539array is array(natural range <>) of slv539;   type slv667array is array(natural range <>) of slv667;   type slv795array is array(natural range <>) of slv795;   type slv923array  is array(natural range <>) of slv923 ;
	type slv28array  is array(natural range <>) of slv28 ;   type slv156array is array(natural range <>) of slv156;   type slv284array is array(natural range <>) of slv284;   type slv412array is array(natural range <>) of slv412;   type slv540array is array(natural range <>) of slv540;   type slv668array is array(natural range <>) of slv668;   type slv796array is array(natural range <>) of slv796;   type slv924array  is array(natural range <>) of slv924 ;
	type slv29array  is array(natural range <>) of slv29 ;   type slv157array is array(natural range <>) of slv157;   type slv285array is array(natural range <>) of slv285;   type slv413array is array(natural range <>) of slv413;   type slv541array is array(natural range <>) of slv541;   type slv669array is array(natural range <>) of slv669;   type slv797array is array(natural range <>) of slv797;   type slv925array  is array(natural range <>) of slv925 ;
	type slv30array  is array(natural range <>) of slv30 ;   type slv158array is array(natural range <>) of slv158;   type slv286array is array(natural range <>) of slv286;   type slv414array is array(natural range <>) of slv414;   type slv542array is array(natural range <>) of slv542;   type slv670array is array(natural range <>) of slv670;   type slv798array is array(natural range <>) of slv798;   type slv926array  is array(natural range <>) of slv926 ;
	type slv31array  is array(natural range <>) of slv31 ;   type slv159array is array(natural range <>) of slv159;   type slv287array is array(natural range <>) of slv287;   type slv415array is array(natural range <>) of slv415;   type slv543array is array(natural range <>) of slv543;   type slv671array is array(natural range <>) of slv671;   type slv799array is array(natural range <>) of slv799;   type slv927array  is array(natural range <>) of slv927 ;
	type slv32array  is array(natural range <>) of slv32 ;   type slv160array is array(natural range <>) of slv160;   type slv288array is array(natural range <>) of slv288;   type slv416array is array(natural range <>) of slv416;   type slv544array is array(natural range <>) of slv544;   type slv672array is array(natural range <>) of slv672;   type slv800array is array(natural range <>) of slv800;   type slv928array  is array(natural range <>) of slv928 ;
	type slv33array  is array(natural range <>) of slv33 ;   type slv161array is array(natural range <>) of slv161;   type slv289array is array(natural range <>) of slv289;   type slv417array is array(natural range <>) of slv417;   type slv545array is array(natural range <>) of slv545;   type slv673array is array(natural range <>) of slv673;   type slv801array is array(natural range <>) of slv801;   type slv929array  is array(natural range <>) of slv929 ;
	type slv34array  is array(natural range <>) of slv34 ;   type slv162array is array(natural range <>) of slv162;   type slv290array is array(natural range <>) of slv290;   type slv418array is array(natural range <>) of slv418;   type slv546array is array(natural range <>) of slv546;   type slv674array is array(natural range <>) of slv674;   type slv802array is array(natural range <>) of slv802;   type slv930array  is array(natural range <>) of slv930 ;
	type slv35array  is array(natural range <>) of slv35 ;   type slv163array is array(natural range <>) of slv163;   type slv291array is array(natural range <>) of slv291;   type slv419array is array(natural range <>) of slv419;   type slv547array is array(natural range <>) of slv547;   type slv675array is array(natural range <>) of slv675;   type slv803array is array(natural range <>) of slv803;   type slv931array  is array(natural range <>) of slv931 ;
	type slv36array  is array(natural range <>) of slv36 ;   type slv164array is array(natural range <>) of slv164;   type slv292array is array(natural range <>) of slv292;   type slv420array is array(natural range <>) of slv420;   type slv548array is array(natural range <>) of slv548;   type slv676array is array(natural range <>) of slv676;   type slv804array is array(natural range <>) of slv804;   type slv932array  is array(natural range <>) of slv932 ;
	type slv37array  is array(natural range <>) of slv37 ;   type slv165array is array(natural range <>) of slv165;   type slv293array is array(natural range <>) of slv293;   type slv421array is array(natural range <>) of slv421;   type slv549array is array(natural range <>) of slv549;   type slv677array is array(natural range <>) of slv677;   type slv805array is array(natural range <>) of slv805;   type slv933array  is array(natural range <>) of slv933 ;
	type slv38array  is array(natural range <>) of slv38 ;   type slv166array is array(natural range <>) of slv166;   type slv294array is array(natural range <>) of slv294;   type slv422array is array(natural range <>) of slv422;   type slv550array is array(natural range <>) of slv550;   type slv678array is array(natural range <>) of slv678;   type slv806array is array(natural range <>) of slv806;   type slv934array  is array(natural range <>) of slv934 ;
	type slv39array  is array(natural range <>) of slv39 ;   type slv167array is array(natural range <>) of slv167;   type slv295array is array(natural range <>) of slv295;   type slv423array is array(natural range <>) of slv423;   type slv551array is array(natural range <>) of slv551;   type slv679array is array(natural range <>) of slv679;   type slv807array is array(natural range <>) of slv807;   type slv935array  is array(natural range <>) of slv935 ;
	type slv40array  is array(natural range <>) of slv40 ;   type slv168array is array(natural range <>) of slv168;   type slv296array is array(natural range <>) of slv296;   type slv424array is array(natural range <>) of slv424;   type slv552array is array(natural range <>) of slv552;   type slv680array is array(natural range <>) of slv680;   type slv808array is array(natural range <>) of slv808;   type slv936array  is array(natural range <>) of slv936 ;
	type slv41array  is array(natural range <>) of slv41 ;   type slv169array is array(natural range <>) of slv169;   type slv297array is array(natural range <>) of slv297;   type slv425array is array(natural range <>) of slv425;   type slv553array is array(natural range <>) of slv553;   type slv681array is array(natural range <>) of slv681;   type slv809array is array(natural range <>) of slv809;   type slv937array  is array(natural range <>) of slv937 ;
	type slv42array  is array(natural range <>) of slv42 ;   type slv170array is array(natural range <>) of slv170;   type slv298array is array(natural range <>) of slv298;   type slv426array is array(natural range <>) of slv426;   type slv554array is array(natural range <>) of slv554;   type slv682array is array(natural range <>) of slv682;   type slv810array is array(natural range <>) of slv810;   type slv938array  is array(natural range <>) of slv938 ;
	type slv43array  is array(natural range <>) of slv43 ;   type slv171array is array(natural range <>) of slv171;   type slv299array is array(natural range <>) of slv299;   type slv427array is array(natural range <>) of slv427;   type slv555array is array(natural range <>) of slv555;   type slv683array is array(natural range <>) of slv683;   type slv811array is array(natural range <>) of slv811;   type slv939array  is array(natural range <>) of slv939 ;
	type slv44array  is array(natural range <>) of slv44 ;   type slv172array is array(natural range <>) of slv172;   type slv300array is array(natural range <>) of slv300;   type slv428array is array(natural range <>) of slv428;   type slv556array is array(natural range <>) of slv556;   type slv684array is array(natural range <>) of slv684;   type slv812array is array(natural range <>) of slv812;   type slv940array  is array(natural range <>) of slv940 ;
	type slv45array  is array(natural range <>) of slv45 ;   type slv173array is array(natural range <>) of slv173;   type slv301array is array(natural range <>) of slv301;   type slv429array is array(natural range <>) of slv429;   type slv557array is array(natural range <>) of slv557;   type slv685array is array(natural range <>) of slv685;   type slv813array is array(natural range <>) of slv813;   type slv941array  is array(natural range <>) of slv941 ;
	type slv46array  is array(natural range <>) of slv46 ;   type slv174array is array(natural range <>) of slv174;   type slv302array is array(natural range <>) of slv302;   type slv430array is array(natural range <>) of slv430;   type slv558array is array(natural range <>) of slv558;   type slv686array is array(natural range <>) of slv686;   type slv814array is array(natural range <>) of slv814;   type slv942array  is array(natural range <>) of slv942 ;
	type slv47array  is array(natural range <>) of slv47 ;   type slv175array is array(natural range <>) of slv175;   type slv303array is array(natural range <>) of slv303;   type slv431array is array(natural range <>) of slv431;   type slv559array is array(natural range <>) of slv559;   type slv687array is array(natural range <>) of slv687;   type slv815array is array(natural range <>) of slv815;   type slv943array  is array(natural range <>) of slv943 ;
	type slv48array  is array(natural range <>) of slv48 ;   type slv176array is array(natural range <>) of slv176;   type slv304array is array(natural range <>) of slv304;   type slv432array is array(natural range <>) of slv432;   type slv560array is array(natural range <>) of slv560;   type slv688array is array(natural range <>) of slv688;   type slv816array is array(natural range <>) of slv816;   type slv944array  is array(natural range <>) of slv944 ;
	type slv49array  is array(natural range <>) of slv49 ;   type slv177array is array(natural range <>) of slv177;   type slv305array is array(natural range <>) of slv305;   type slv433array is array(natural range <>) of slv433;   type slv561array is array(natural range <>) of slv561;   type slv689array is array(natural range <>) of slv689;   type slv817array is array(natural range <>) of slv817;   type slv945array  is array(natural range <>) of slv945 ;
	type slv50array  is array(natural range <>) of slv50 ;   type slv178array is array(natural range <>) of slv178;   type slv306array is array(natural range <>) of slv306;   type slv434array is array(natural range <>) of slv434;   type slv562array is array(natural range <>) of slv562;   type slv690array is array(natural range <>) of slv690;   type slv818array is array(natural range <>) of slv818;   type slv946array  is array(natural range <>) of slv946 ;
	type slv51array  is array(natural range <>) of slv51 ;   type slv179array is array(natural range <>) of slv179;   type slv307array is array(natural range <>) of slv307;   type slv435array is array(natural range <>) of slv435;   type slv563array is array(natural range <>) of slv563;   type slv691array is array(natural range <>) of slv691;   type slv819array is array(natural range <>) of slv819;   type slv947array  is array(natural range <>) of slv947 ;
	type slv52array  is array(natural range <>) of slv52 ;   type slv180array is array(natural range <>) of slv180;   type slv308array is array(natural range <>) of slv308;   type slv436array is array(natural range <>) of slv436;   type slv564array is array(natural range <>) of slv564;   type slv692array is array(natural range <>) of slv692;   type slv820array is array(natural range <>) of slv820;   type slv948array  is array(natural range <>) of slv948 ;
	type slv53array  is array(natural range <>) of slv53 ;   type slv181array is array(natural range <>) of slv181;   type slv309array is array(natural range <>) of slv309;   type slv437array is array(natural range <>) of slv437;   type slv565array is array(natural range <>) of slv565;   type slv693array is array(natural range <>) of slv693;   type slv821array is array(natural range <>) of slv821;   type slv949array  is array(natural range <>) of slv949 ;
	type slv54array  is array(natural range <>) of slv54 ;   type slv182array is array(natural range <>) of slv182;   type slv310array is array(natural range <>) of slv310;   type slv438array is array(natural range <>) of slv438;   type slv566array is array(natural range <>) of slv566;   type slv694array is array(natural range <>) of slv694;   type slv822array is array(natural range <>) of slv822;   type slv950array  is array(natural range <>) of slv950 ;
	type slv55array  is array(natural range <>) of slv55 ;   type slv183array is array(natural range <>) of slv183;   type slv311array is array(natural range <>) of slv311;   type slv439array is array(natural range <>) of slv439;   type slv567array is array(natural range <>) of slv567;   type slv695array is array(natural range <>) of slv695;   type slv823array is array(natural range <>) of slv823;   type slv951array  is array(natural range <>) of slv951 ;
	type slv56array  is array(natural range <>) of slv56 ;   type slv184array is array(natural range <>) of slv184;   type slv312array is array(natural range <>) of slv312;   type slv440array is array(natural range <>) of slv440;   type slv568array is array(natural range <>) of slv568;   type slv696array is array(natural range <>) of slv696;   type slv824array is array(natural range <>) of slv824;   type slv952array  is array(natural range <>) of slv952 ;
	type slv57array  is array(natural range <>) of slv57 ;   type slv185array is array(natural range <>) of slv185;   type slv313array is array(natural range <>) of slv313;   type slv441array is array(natural range <>) of slv441;   type slv569array is array(natural range <>) of slv569;   type slv697array is array(natural range <>) of slv697;   type slv825array is array(natural range <>) of slv825;   type slv953array  is array(natural range <>) of slv953 ;
	type slv58array  is array(natural range <>) of slv58 ;   type slv186array is array(natural range <>) of slv186;   type slv314array is array(natural range <>) of slv314;   type slv442array is array(natural range <>) of slv442;   type slv570array is array(natural range <>) of slv570;   type slv698array is array(natural range <>) of slv698;   type slv826array is array(natural range <>) of slv826;   type slv954array  is array(natural range <>) of slv954 ;
	type slv59array  is array(natural range <>) of slv59 ;   type slv187array is array(natural range <>) of slv187;   type slv315array is array(natural range <>) of slv315;   type slv443array is array(natural range <>) of slv443;   type slv571array is array(natural range <>) of slv571;   type slv699array is array(natural range <>) of slv699;   type slv827array is array(natural range <>) of slv827;   type slv955array  is array(natural range <>) of slv955 ;
	type slv60array  is array(natural range <>) of slv60 ;   type slv188array is array(natural range <>) of slv188;   type slv316array is array(natural range <>) of slv316;   type slv444array is array(natural range <>) of slv444;   type slv572array is array(natural range <>) of slv572;   type slv700array is array(natural range <>) of slv700;   type slv828array is array(natural range <>) of slv828;   type slv956array  is array(natural range <>) of slv956 ;
	type slv61array  is array(natural range <>) of slv61 ;   type slv189array is array(natural range <>) of slv189;   type slv317array is array(natural range <>) of slv317;   type slv445array is array(natural range <>) of slv445;   type slv573array is array(natural range <>) of slv573;   type slv701array is array(natural range <>) of slv701;   type slv829array is array(natural range <>) of slv829;   type slv957array  is array(natural range <>) of slv957 ;
	type slv62array  is array(natural range <>) of slv62 ;   type slv190array is array(natural range <>) of slv190;   type slv318array is array(natural range <>) of slv318;   type slv446array is array(natural range <>) of slv446;   type slv574array is array(natural range <>) of slv574;   type slv702array is array(natural range <>) of slv702;   type slv830array is array(natural range <>) of slv830;   type slv958array  is array(natural range <>) of slv958 ;
	type slv63array  is array(natural range <>) of slv63 ;   type slv191array is array(natural range <>) of slv191;   type slv319array is array(natural range <>) of slv319;   type slv447array is array(natural range <>) of slv447;   type slv575array is array(natural range <>) of slv575;   type slv703array is array(natural range <>) of slv703;   type slv831array is array(natural range <>) of slv831;   type slv959array  is array(natural range <>) of slv959 ;
	type slv64array  is array(natural range <>) of slv64 ;   type slv192array is array(natural range <>) of slv192;   type slv320array is array(natural range <>) of slv320;   type slv448array is array(natural range <>) of slv448;   type slv576array is array(natural range <>) of slv576;   type slv704array is array(natural range <>) of slv704;   type slv832array is array(natural range <>) of slv832;   type slv960array  is array(natural range <>) of slv960 ;
	type slv65array  is array(natural range <>) of slv65 ;   type slv193array is array(natural range <>) of slv193;   type slv321array is array(natural range <>) of slv321;   type slv449array is array(natural range <>) of slv449;   type slv577array is array(natural range <>) of slv577;   type slv705array is array(natural range <>) of slv705;   type slv833array is array(natural range <>) of slv833;   type slv961array  is array(natural range <>) of slv961 ;
	type slv66array  is array(natural range <>) of slv66 ;   type slv194array is array(natural range <>) of slv194;   type slv322array is array(natural range <>) of slv322;   type slv450array is array(natural range <>) of slv450;   type slv578array is array(natural range <>) of slv578;   type slv706array is array(natural range <>) of slv706;   type slv834array is array(natural range <>) of slv834;   type slv962array  is array(natural range <>) of slv962 ;
	type slv67array  is array(natural range <>) of slv67 ;   type slv195array is array(natural range <>) of slv195;   type slv323array is array(natural range <>) of slv323;   type slv451array is array(natural range <>) of slv451;   type slv579array is array(natural range <>) of slv579;   type slv707array is array(natural range <>) of slv707;   type slv835array is array(natural range <>) of slv835;   type slv963array  is array(natural range <>) of slv963 ;
	type slv68array  is array(natural range <>) of slv68 ;   type slv196array is array(natural range <>) of slv196;   type slv324array is array(natural range <>) of slv324;   type slv452array is array(natural range <>) of slv452;   type slv580array is array(natural range <>) of slv580;   type slv708array is array(natural range <>) of slv708;   type slv836array is array(natural range <>) of slv836;   type slv964array  is array(natural range <>) of slv964 ;
	type slv69array  is array(natural range <>) of slv69 ;   type slv197array is array(natural range <>) of slv197;   type slv325array is array(natural range <>) of slv325;   type slv453array is array(natural range <>) of slv453;   type slv581array is array(natural range <>) of slv581;   type slv709array is array(natural range <>) of slv709;   type slv837array is array(natural range <>) of slv837;   type slv965array  is array(natural range <>) of slv965 ;
	type slv70array  is array(natural range <>) of slv70 ;   type slv198array is array(natural range <>) of slv198;   type slv326array is array(natural range <>) of slv326;   type slv454array is array(natural range <>) of slv454;   type slv582array is array(natural range <>) of slv582;   type slv710array is array(natural range <>) of slv710;   type slv838array is array(natural range <>) of slv838;   type slv966array  is array(natural range <>) of slv966 ;
	type slv71array  is array(natural range <>) of slv71 ;   type slv199array is array(natural range <>) of slv199;   type slv327array is array(natural range <>) of slv327;   type slv455array is array(natural range <>) of slv455;   type slv583array is array(natural range <>) of slv583;   type slv711array is array(natural range <>) of slv711;   type slv839array is array(natural range <>) of slv839;   type slv967array  is array(natural range <>) of slv967 ;
	type slv72array  is array(natural range <>) of slv72 ;   type slv200array is array(natural range <>) of slv200;   type slv328array is array(natural range <>) of slv328;   type slv456array is array(natural range <>) of slv456;   type slv584array is array(natural range <>) of slv584;   type slv712array is array(natural range <>) of slv712;   type slv840array is array(natural range <>) of slv840;   type slv968array  is array(natural range <>) of slv968 ;
	type slv73array  is array(natural range <>) of slv73 ;   type slv201array is array(natural range <>) of slv201;   type slv329array is array(natural range <>) of slv329;   type slv457array is array(natural range <>) of slv457;   type slv585array is array(natural range <>) of slv585;   type slv713array is array(natural range <>) of slv713;   type slv841array is array(natural range <>) of slv841;   type slv969array  is array(natural range <>) of slv969 ;
	type slv74array  is array(natural range <>) of slv74 ;   type slv202array is array(natural range <>) of slv202;   type slv330array is array(natural range <>) of slv330;   type slv458array is array(natural range <>) of slv458;   type slv586array is array(natural range <>) of slv586;   type slv714array is array(natural range <>) of slv714;   type slv842array is array(natural range <>) of slv842;   type slv970array  is array(natural range <>) of slv970 ;
	type slv75array  is array(natural range <>) of slv75 ;   type slv203array is array(natural range <>) of slv203;   type slv331array is array(natural range <>) of slv331;   type slv459array is array(natural range <>) of slv459;   type slv587array is array(natural range <>) of slv587;   type slv715array is array(natural range <>) of slv715;   type slv843array is array(natural range <>) of slv843;   type slv971array  is array(natural range <>) of slv971 ;
	type slv76array  is array(natural range <>) of slv76 ;   type slv204array is array(natural range <>) of slv204;   type slv332array is array(natural range <>) of slv332;   type slv460array is array(natural range <>) of slv460;   type slv588array is array(natural range <>) of slv588;   type slv716array is array(natural range <>) of slv716;   type slv844array is array(natural range <>) of slv844;   type slv972array  is array(natural range <>) of slv972 ;
	type slv77array  is array(natural range <>) of slv77 ;   type slv205array is array(natural range <>) of slv205;   type slv333array is array(natural range <>) of slv333;   type slv461array is array(natural range <>) of slv461;   type slv589array is array(natural range <>) of slv589;   type slv717array is array(natural range <>) of slv717;   type slv845array is array(natural range <>) of slv845;   type slv973array  is array(natural range <>) of slv973 ;
	type slv78array  is array(natural range <>) of slv78 ;   type slv206array is array(natural range <>) of slv206;   type slv334array is array(natural range <>) of slv334;   type slv462array is array(natural range <>) of slv462;   type slv590array is array(natural range <>) of slv590;   type slv718array is array(natural range <>) of slv718;   type slv846array is array(natural range <>) of slv846;   type slv974array  is array(natural range <>) of slv974 ;
	type slv79array  is array(natural range <>) of slv79 ;   type slv207array is array(natural range <>) of slv207;   type slv335array is array(natural range <>) of slv335;   type slv463array is array(natural range <>) of slv463;   type slv591array is array(natural range <>) of slv591;   type slv719array is array(natural range <>) of slv719;   type slv847array is array(natural range <>) of slv847;   type slv975array  is array(natural range <>) of slv975 ;
	type slv80array  is array(natural range <>) of slv80 ;   type slv208array is array(natural range <>) of slv208;   type slv336array is array(natural range <>) of slv336;   type slv464array is array(natural range <>) of slv464;   type slv592array is array(natural range <>) of slv592;   type slv720array is array(natural range <>) of slv720;   type slv848array is array(natural range <>) of slv848;   type slv976array  is array(natural range <>) of slv976 ;
	type slv81array  is array(natural range <>) of slv81 ;   type slv209array is array(natural range <>) of slv209;   type slv337array is array(natural range <>) of slv337;   type slv465array is array(natural range <>) of slv465;   type slv593array is array(natural range <>) of slv593;   type slv721array is array(natural range <>) of slv721;   type slv849array is array(natural range <>) of slv849;   type slv977array  is array(natural range <>) of slv977 ;
	type slv82array  is array(natural range <>) of slv82 ;   type slv210array is array(natural range <>) of slv210;   type slv338array is array(natural range <>) of slv338;   type slv466array is array(natural range <>) of slv466;   type slv594array is array(natural range <>) of slv594;   type slv722array is array(natural range <>) of slv722;   type slv850array is array(natural range <>) of slv850;   type slv978array  is array(natural range <>) of slv978 ;
	type slv83array  is array(natural range <>) of slv83 ;   type slv211array is array(natural range <>) of slv211;   type slv339array is array(natural range <>) of slv339;   type slv467array is array(natural range <>) of slv467;   type slv595array is array(natural range <>) of slv595;   type slv723array is array(natural range <>) of slv723;   type slv851array is array(natural range <>) of slv851;   type slv979array  is array(natural range <>) of slv979 ;
	type slv84array  is array(natural range <>) of slv84 ;   type slv212array is array(natural range <>) of slv212;   type slv340array is array(natural range <>) of slv340;   type slv468array is array(natural range <>) of slv468;   type slv596array is array(natural range <>) of slv596;   type slv724array is array(natural range <>) of slv724;   type slv852array is array(natural range <>) of slv852;   type slv980array  is array(natural range <>) of slv980 ;
	type slv85array  is array(natural range <>) of slv85 ;   type slv213array is array(natural range <>) of slv213;   type slv341array is array(natural range <>) of slv341;   type slv469array is array(natural range <>) of slv469;   type slv597array is array(natural range <>) of slv597;   type slv725array is array(natural range <>) of slv725;   type slv853array is array(natural range <>) of slv853;   type slv981array  is array(natural range <>) of slv981 ;
	type slv86array  is array(natural range <>) of slv86 ;   type slv214array is array(natural range <>) of slv214;   type slv342array is array(natural range <>) of slv342;   type slv470array is array(natural range <>) of slv470;   type slv598array is array(natural range <>) of slv598;   type slv726array is array(natural range <>) of slv726;   type slv854array is array(natural range <>) of slv854;   type slv982array  is array(natural range <>) of slv982 ;
	type slv87array  is array(natural range <>) of slv87 ;   type slv215array is array(natural range <>) of slv215;   type slv343array is array(natural range <>) of slv343;   type slv471array is array(natural range <>) of slv471;   type slv599array is array(natural range <>) of slv599;   type slv727array is array(natural range <>) of slv727;   type slv855array is array(natural range <>) of slv855;   type slv983array  is array(natural range <>) of slv983 ;
	type slv88array  is array(natural range <>) of slv88 ;   type slv216array is array(natural range <>) of slv216;   type slv344array is array(natural range <>) of slv344;   type slv472array is array(natural range <>) of slv472;   type slv600array is array(natural range <>) of slv600;   type slv728array is array(natural range <>) of slv728;   type slv856array is array(natural range <>) of slv856;   type slv984array  is array(natural range <>) of slv984 ;
	type slv89array  is array(natural range <>) of slv89 ;   type slv217array is array(natural range <>) of slv217;   type slv345array is array(natural range <>) of slv345;   type slv473array is array(natural range <>) of slv473;   type slv601array is array(natural range <>) of slv601;   type slv729array is array(natural range <>) of slv729;   type slv857array is array(natural range <>) of slv857;   type slv985array  is array(natural range <>) of slv985 ;
	type slv90array  is array(natural range <>) of slv90 ;   type slv218array is array(natural range <>) of slv218;   type slv346array is array(natural range <>) of slv346;   type slv474array is array(natural range <>) of slv474;   type slv602array is array(natural range <>) of slv602;   type slv730array is array(natural range <>) of slv730;   type slv858array is array(natural range <>) of slv858;   type slv986array  is array(natural range <>) of slv986 ;
	type slv91array  is array(natural range <>) of slv91 ;   type slv219array is array(natural range <>) of slv219;   type slv347array is array(natural range <>) of slv347;   type slv475array is array(natural range <>) of slv475;   type slv603array is array(natural range <>) of slv603;   type slv731array is array(natural range <>) of slv731;   type slv859array is array(natural range <>) of slv859;   type slv987array  is array(natural range <>) of slv987 ;
	type slv92array  is array(natural range <>) of slv92 ;   type slv220array is array(natural range <>) of slv220;   type slv348array is array(natural range <>) of slv348;   type slv476array is array(natural range <>) of slv476;   type slv604array is array(natural range <>) of slv604;   type slv732array is array(natural range <>) of slv732;   type slv860array is array(natural range <>) of slv860;   type slv988array  is array(natural range <>) of slv988 ;
	type slv93array  is array(natural range <>) of slv93 ;   type slv221array is array(natural range <>) of slv221;   type slv349array is array(natural range <>) of slv349;   type slv477array is array(natural range <>) of slv477;   type slv605array is array(natural range <>) of slv605;   type slv733array is array(natural range <>) of slv733;   type slv861array is array(natural range <>) of slv861;   type slv989array  is array(natural range <>) of slv989 ;
	type slv94array  is array(natural range <>) of slv94 ;   type slv222array is array(natural range <>) of slv222;   type slv350array is array(natural range <>) of slv350;   type slv478array is array(natural range <>) of slv478;   type slv606array is array(natural range <>) of slv606;   type slv734array is array(natural range <>) of slv734;   type slv862array is array(natural range <>) of slv862;   type slv990array  is array(natural range <>) of slv990 ;
	type slv95array  is array(natural range <>) of slv95 ;   type slv223array is array(natural range <>) of slv223;   type slv351array is array(natural range <>) of slv351;   type slv479array is array(natural range <>) of slv479;   type slv607array is array(natural range <>) of slv607;   type slv735array is array(natural range <>) of slv735;   type slv863array is array(natural range <>) of slv863;   type slv991array  is array(natural range <>) of slv991 ;
	type slv96array  is array(natural range <>) of slv96 ;   type slv224array is array(natural range <>) of slv224;   type slv352array is array(natural range <>) of slv352;   type slv480array is array(natural range <>) of slv480;   type slv608array is array(natural range <>) of slv608;   type slv736array is array(natural range <>) of slv736;   type slv864array is array(natural range <>) of slv864;   type slv992array  is array(natural range <>) of slv992 ;
	type slv97array  is array(natural range <>) of slv97 ;   type slv225array is array(natural range <>) of slv225;   type slv353array is array(natural range <>) of slv353;   type slv481array is array(natural range <>) of slv481;   type slv609array is array(natural range <>) of slv609;   type slv737array is array(natural range <>) of slv737;   type slv865array is array(natural range <>) of slv865;   type slv993array  is array(natural range <>) of slv993 ;
	type slv98array  is array(natural range <>) of slv98 ;   type slv226array is array(natural range <>) of slv226;   type slv354array is array(natural range <>) of slv354;   type slv482array is array(natural range <>) of slv482;   type slv610array is array(natural range <>) of slv610;   type slv738array is array(natural range <>) of slv738;   type slv866array is array(natural range <>) of slv866;   type slv994array  is array(natural range <>) of slv994 ;
	type slv99array  is array(natural range <>) of slv99 ;   type slv227array is array(natural range <>) of slv227;   type slv355array is array(natural range <>) of slv355;   type slv483array is array(natural range <>) of slv483;   type slv611array is array(natural range <>) of slv611;   type slv739array is array(natural range <>) of slv739;   type slv867array is array(natural range <>) of slv867;   type slv995array  is array(natural range <>) of slv995 ;
	type slv100array is array(natural range <>) of slv100;   type slv228array is array(natural range <>) of slv228;   type slv356array is array(natural range <>) of slv356;   type slv484array is array(natural range <>) of slv484;   type slv612array is array(natural range <>) of slv612;   type slv740array is array(natural range <>) of slv740;   type slv868array is array(natural range <>) of slv868;   type slv996array  is array(natural range <>) of slv996 ;
	type slv101array is array(natural range <>) of slv101;   type slv229array is array(natural range <>) of slv229;   type slv357array is array(natural range <>) of slv357;   type slv485array is array(natural range <>) of slv485;   type slv613array is array(natural range <>) of slv613;   type slv741array is array(natural range <>) of slv741;   type slv869array is array(natural range <>) of slv869;   type slv997array  is array(natural range <>) of slv997 ;
	type slv102array is array(natural range <>) of slv102;   type slv230array is array(natural range <>) of slv230;   type slv358array is array(natural range <>) of slv358;   type slv486array is array(natural range <>) of slv486;   type slv614array is array(natural range <>) of slv614;   type slv742array is array(natural range <>) of slv742;   type slv870array is array(natural range <>) of slv870;   type slv998array  is array(natural range <>) of slv998 ;
	type slv103array is array(natural range <>) of slv103;   type slv231array is array(natural range <>) of slv231;   type slv359array is array(natural range <>) of slv359;   type slv487array is array(natural range <>) of slv487;   type slv615array is array(natural range <>) of slv615;   type slv743array is array(natural range <>) of slv743;   type slv871array is array(natural range <>) of slv871;   type slv999array  is array(natural range <>) of slv999 ;
	type slv104array is array(natural range <>) of slv104;   type slv232array is array(natural range <>) of slv232;   type slv360array is array(natural range <>) of slv360;   type slv488array is array(natural range <>) of slv488;   type slv616array is array(natural range <>) of slv616;   type slv744array is array(natural range <>) of slv744;   type slv872array is array(natural range <>) of slv872;   type slv1000array is array(natural range <>) of slv1000;
	type slv105array is array(natural range <>) of slv105;   type slv233array is array(natural range <>) of slv233;   type slv361array is array(natural range <>) of slv361;   type slv489array is array(natural range <>) of slv489;   type slv617array is array(natural range <>) of slv617;   type slv745array is array(natural range <>) of slv745;   type slv873array is array(natural range <>) of slv873;   type slv1001array is array(natural range <>) of slv1001;
	type slv106array is array(natural range <>) of slv106;   type slv234array is array(natural range <>) of slv234;   type slv362array is array(natural range <>) of slv362;   type slv490array is array(natural range <>) of slv490;   type slv618array is array(natural range <>) of slv618;   type slv746array is array(natural range <>) of slv746;   type slv874array is array(natural range <>) of slv874;   type slv1002array is array(natural range <>) of slv1002;
	type slv107array is array(natural range <>) of slv107;   type slv235array is array(natural range <>) of slv235;   type slv363array is array(natural range <>) of slv363;   type slv491array is array(natural range <>) of slv491;   type slv619array is array(natural range <>) of slv619;   type slv747array is array(natural range <>) of slv747;   type slv875array is array(natural range <>) of slv875;   type slv1003array is array(natural range <>) of slv1003;
	type slv108array is array(natural range <>) of slv108;   type slv236array is array(natural range <>) of slv236;   type slv364array is array(natural range <>) of slv364;   type slv492array is array(natural range <>) of slv492;   type slv620array is array(natural range <>) of slv620;   type slv748array is array(natural range <>) of slv748;   type slv876array is array(natural range <>) of slv876;   type slv1004array is array(natural range <>) of slv1004;
	type slv109array is array(natural range <>) of slv109;   type slv237array is array(natural range <>) of slv237;   type slv365array is array(natural range <>) of slv365;   type slv493array is array(natural range <>) of slv493;   type slv621array is array(natural range <>) of slv621;   type slv749array is array(natural range <>) of slv749;   type slv877array is array(natural range <>) of slv877;   type slv1005array is array(natural range <>) of slv1005;
	type slv110array is array(natural range <>) of slv110;   type slv238array is array(natural range <>) of slv238;   type slv366array is array(natural range <>) of slv366;   type slv494array is array(natural range <>) of slv494;   type slv622array is array(natural range <>) of slv622;   type slv750array is array(natural range <>) of slv750;   type slv878array is array(natural range <>) of slv878;   type slv1006array is array(natural range <>) of slv1006;
	type slv111array is array(natural range <>) of slv111;   type slv239array is array(natural range <>) of slv239;   type slv367array is array(natural range <>) of slv367;   type slv495array is array(natural range <>) of slv495;   type slv623array is array(natural range <>) of slv623;   type slv751array is array(natural range <>) of slv751;   type slv879array is array(natural range <>) of slv879;   type slv1007array is array(natural range <>) of slv1007;
	type slv112array is array(natural range <>) of slv112;   type slv240array is array(natural range <>) of slv240;   type slv368array is array(natural range <>) of slv368;   type slv496array is array(natural range <>) of slv496;   type slv624array is array(natural range <>) of slv624;   type slv752array is array(natural range <>) of slv752;   type slv880array is array(natural range <>) of slv880;   type slv1008array is array(natural range <>) of slv1008;
	type slv113array is array(natural range <>) of slv113;   type slv241array is array(natural range <>) of slv241;   type slv369array is array(natural range <>) of slv369;   type slv497array is array(natural range <>) of slv497;   type slv625array is array(natural range <>) of slv625;   type slv753array is array(natural range <>) of slv753;   type slv881array is array(natural range <>) of slv881;   type slv1009array is array(natural range <>) of slv1009;
	type slv114array is array(natural range <>) of slv114;   type slv242array is array(natural range <>) of slv242;   type slv370array is array(natural range <>) of slv370;   type slv498array is array(natural range <>) of slv498;   type slv626array is array(natural range <>) of slv626;   type slv754array is array(natural range <>) of slv754;   type slv882array is array(natural range <>) of slv882;   type slv1010array is array(natural range <>) of slv1010;
	type slv115array is array(natural range <>) of slv115;   type slv243array is array(natural range <>) of slv243;   type slv371array is array(natural range <>) of slv371;   type slv499array is array(natural range <>) of slv499;   type slv627array is array(natural range <>) of slv627;   type slv755array is array(natural range <>) of slv755;   type slv883array is array(natural range <>) of slv883;   type slv1011array is array(natural range <>) of slv1011;
	type slv116array is array(natural range <>) of slv116;   type slv244array is array(natural range <>) of slv244;   type slv372array is array(natural range <>) of slv372;   type slv500array is array(natural range <>) of slv500;   type slv628array is array(natural range <>) of slv628;   type slv756array is array(natural range <>) of slv756;   type slv884array is array(natural range <>) of slv884;   type slv1012array is array(natural range <>) of slv1012;
	type slv117array is array(natural range <>) of slv117;   type slv245array is array(natural range <>) of slv245;   type slv373array is array(natural range <>) of slv373;   type slv501array is array(natural range <>) of slv501;   type slv629array is array(natural range <>) of slv629;   type slv757array is array(natural range <>) of slv757;   type slv885array is array(natural range <>) of slv885;   type slv1013array is array(natural range <>) of slv1013;
	type slv118array is array(natural range <>) of slv118;   type slv246array is array(natural range <>) of slv246;   type slv374array is array(natural range <>) of slv374;   type slv502array is array(natural range <>) of slv502;   type slv630array is array(natural range <>) of slv630;   type slv758array is array(natural range <>) of slv758;   type slv886array is array(natural range <>) of slv886;   type slv1014array is array(natural range <>) of slv1014;
	type slv119array is array(natural range <>) of slv119;   type slv247array is array(natural range <>) of slv247;   type slv375array is array(natural range <>) of slv375;   type slv503array is array(natural range <>) of slv503;   type slv631array is array(natural range <>) of slv631;   type slv759array is array(natural range <>) of slv759;   type slv887array is array(natural range <>) of slv887;   type slv1015array is array(natural range <>) of slv1015;
	type slv120array is array(natural range <>) of slv120;   type slv248array is array(natural range <>) of slv248;   type slv376array is array(natural range <>) of slv376;   type slv504array is array(natural range <>) of slv504;   type slv632array is array(natural range <>) of slv632;   type slv760array is array(natural range <>) of slv760;   type slv888array is array(natural range <>) of slv888;   type slv1016array is array(natural range <>) of slv1016;
	type slv121array is array(natural range <>) of slv121;   type slv249array is array(natural range <>) of slv249;   type slv377array is array(natural range <>) of slv377;   type slv505array is array(natural range <>) of slv505;   type slv633array is array(natural range <>) of slv633;   type slv761array is array(natural range <>) of slv761;   type slv889array is array(natural range <>) of slv889;   type slv1017array is array(natural range <>) of slv1017;
	type slv122array is array(natural range <>) of slv122;   type slv250array is array(natural range <>) of slv250;   type slv378array is array(natural range <>) of slv378;   type slv506array is array(natural range <>) of slv506;   type slv634array is array(natural range <>) of slv634;   type slv762array is array(natural range <>) of slv762;   type slv890array is array(natural range <>) of slv890;   type slv1018array is array(natural range <>) of slv1018;
	type slv123array is array(natural range <>) of slv123;   type slv251array is array(natural range <>) of slv251;   type slv379array is array(natural range <>) of slv379;   type slv507array is array(natural range <>) of slv507;   type slv635array is array(natural range <>) of slv635;   type slv763array is array(natural range <>) of slv763;   type slv891array is array(natural range <>) of slv891;   type slv1019array is array(natural range <>) of slv1019;
	type slv124array is array(natural range <>) of slv124;   type slv252array is array(natural range <>) of slv252;   type slv380array is array(natural range <>) of slv380;   type slv508array is array(natural range <>) of slv508;   type slv636array is array(natural range <>) of slv636;   type slv764array is array(natural range <>) of slv764;   type slv892array is array(natural range <>) of slv892;   type slv1020array is array(natural range <>) of slv1020;
	type slv125array is array(natural range <>) of slv125;   type slv253array is array(natural range <>) of slv253;   type slv381array is array(natural range <>) of slv381;   type slv509array is array(natural range <>) of slv509;   type slv637array is array(natural range <>) of slv637;   type slv765array is array(natural range <>) of slv765;   type slv893array is array(natural range <>) of slv893;   type slv1021array is array(natural range <>) of slv1021;
	type slv126array is array(natural range <>) of slv126;   type slv254array is array(natural range <>) of slv254;   type slv382array is array(natural range <>) of slv382;   type slv510array is array(natural range <>) of slv510;   type slv638array is array(natural range <>) of slv638;   type slv766array is array(natural range <>) of slv766;   type slv894array is array(natural range <>) of slv894;   type slv1022array is array(natural range <>) of slv1022;
	type slv127array is array(natural range <>) of slv127;   type slv255array is array(natural range <>) of slv255;   type slv383array is array(natural range <>) of slv383;   type slv511array is array(natural range <>) of slv511;   type slv639array is array(natural range <>) of slv639;   type slv767array is array(natural range <>) of slv767;   type slv895array is array(natural range <>) of slv895;   type slv1023array is array(natural range <>) of slv1023;
	type slv128array is array(natural range <>) of slv128;   type slv256array is array(natural range <>) of slv256;   type slv384array is array(natural range <>) of slv384;   type slv512array is array(natural range <>) of slv512;   type slv640array is array(natural range <>) of slv640;   type slv768array is array(natural range <>) of slv768;   type slv896array is array(natural range <>) of slv896;   type slv1024array is array(natural range <>) of slv1024;
--**************************************************************************************************************************************************************
-- UNSIGNED
--**************************************************************************************************************************************************************
	subtype uns1     is uns(  0 downto  0); subtype uns2     is uns(  1 downto  0); subtype uns3     is uns(  2 downto  0); subtype uns4     is uns(  3 downto  0);
	subtype uns5     is uns(  4 downto  0); subtype uns6     is uns(  5 downto  0); subtype uns7     is uns(  6 downto  0); subtype uns8     is uns(  7 downto  0);
	subtype uns9     is uns(  8 downto  0); subtype uns10    is uns(  9 downto  0); subtype uns11    is uns( 10 downto  0); subtype uns12    is uns( 11 downto  0);
	subtype uns13    is uns( 12 downto  0); subtype uns14    is uns( 13 downto  0); subtype uns15    is uns( 14 downto  0); subtype uns16    is uns( 15 downto  0);
	subtype uns17    is uns( 16 downto  0); subtype uns18    is uns( 17 downto  0); subtype uns19    is uns( 18 downto  0); subtype uns20    is uns( 19 downto  0);
	subtype uns21    is uns( 20 downto  0); subtype uns22    is uns( 21 downto  0); subtype uns23    is uns( 22 downto  0); subtype uns24    is uns( 23 downto  0);
	subtype uns25    is uns( 24 downto  0); subtype uns26    is uns( 25 downto  0); subtype uns27    is uns( 26 downto  0); subtype uns28    is uns( 27 downto  0);
	subtype uns29    is uns( 28 downto  0); subtype uns30    is uns( 29 downto  0); subtype uns31    is uns( 30 downto  0); subtype uns32    is uns( 31 downto  0);
	subtype uns33    is uns( 32 downto  0); subtype uns34    is uns( 33 downto  0); subtype uns35    is uns( 34 downto  0); subtype uns36    is uns( 35 downto  0);
	subtype uns37    is uns( 36 downto  0); subtype uns38    is uns( 37 downto  0); subtype uns39    is uns( 38 downto  0); subtype uns40    is uns( 39 downto  0);
	subtype uns41    is uns( 40 downto  0); subtype uns42    is uns( 41 downto  0); subtype uns43    is uns( 42 downto  0); subtype uns44    is uns( 43 downto  0);
	subtype uns45    is uns( 44 downto  0); subtype uns46    is uns( 45 downto  0); subtype uns47    is uns( 46 downto  0); subtype uns48    is uns( 47 downto  0);
	subtype uns49    is uns( 48 downto  0); subtype uns50    is uns( 49 downto  0); subtype uns51    is uns( 50 downto  0); subtype uns52    is uns( 51 downto  0);
	subtype uns53    is uns( 52 downto  0); subtype uns54    is uns( 53 downto  0); subtype uns55    is uns( 54 downto  0); subtype uns56    is uns( 55 downto  0);
	subtype uns57    is uns( 56 downto  0); subtype uns58    is uns( 57 downto  0); subtype uns59    is uns( 58 downto  0); subtype uns60    is uns( 59 downto  0);
	subtype uns61    is uns( 60 downto  0); subtype uns62    is uns( 61 downto  0); subtype uns63    is uns( 62 downto  0); subtype uns64    is uns( 63 downto  0);
	subtype uns65    is uns( 64 downto  0); subtype uns66    is uns( 65 downto  0); subtype uns67    is uns( 66 downto  0); subtype uns68    is uns( 67 downto  0);
	subtype uns69    is uns( 68 downto  0); subtype uns70    is uns( 69 downto  0); subtype uns71    is uns( 70 downto  0); subtype uns72    is uns( 71 downto  0);
	subtype uns73    is uns( 72 downto  0); subtype uns74    is uns( 73 downto  0); subtype uns75    is uns( 74 downto  0); subtype uns76    is uns( 75 downto  0);
	subtype uns77    is uns( 76 downto  0); subtype uns78    is uns( 77 downto  0); subtype uns79    is uns( 78 downto  0); subtype uns80    is uns( 79 downto  0);
	subtype uns81    is uns( 80 downto  0); subtype uns82    is uns( 81 downto  0); subtype uns83    is uns( 82 downto  0); subtype uns84    is uns( 83 downto  0);
	subtype uns85    is uns( 84 downto  0); subtype uns86    is uns( 85 downto  0); subtype uns87    is uns( 86 downto  0); subtype uns88    is uns( 87 downto  0);
	subtype uns89    is uns( 88 downto  0); subtype uns90    is uns( 89 downto  0); subtype uns91    is uns( 90 downto  0); subtype uns92    is uns( 91 downto  0);
	subtype uns93    is uns( 92 downto  0); subtype uns94    is uns( 93 downto  0); subtype uns95    is uns( 94 downto  0); subtype uns96    is uns( 95 downto  0);
	subtype uns97    is uns( 96 downto  0); subtype uns98    is uns( 97 downto  0); subtype uns99    is uns( 98 downto  0); subtype uns100   is uns( 99 downto  0);
	subtype uns101   is uns(100 downto  0); subtype uns102   is uns(101 downto  0); subtype uns103   is uns(102 downto  0); subtype uns104   is uns(103 downto  0);
	subtype uns105   is uns(104 downto  0); subtype uns106   is uns(105 downto  0); subtype uns107   is uns(106 downto  0); subtype uns108   is uns(107 downto  0);
	subtype uns109   is uns(108 downto  0); subtype uns110   is uns(109 downto  0); subtype uns111   is uns(110 downto  0); subtype uns112   is uns(111 downto  0);
	subtype uns113   is uns(112 downto  0); subtype uns114   is uns(113 downto  0); subtype uns115   is uns(114 downto  0); subtype uns116   is uns(115 downto  0);
	subtype uns117   is uns(116 downto  0); subtype uns118   is uns(117 downto  0); subtype uns119   is uns(118 downto  0); subtype uns120   is uns(119 downto  0);
	subtype uns121   is uns(120 downto  0); subtype uns122   is uns(121 downto  0); subtype uns123   is uns(122 downto  0); subtype uns124   is uns(123 downto  0);
	subtype uns125   is uns(124 downto  0); subtype uns126   is uns(125 downto  0); subtype uns127   is uns(126 downto  0); subtype uns128   is uns(127 downto  0);
	subtype uns129   is uns(128 downto  0); subtype uns130   is uns(129 downto  0); subtype uns131   is uns(130 downto  0); subtype uns132   is uns(131 downto  0);
	subtype uns133   is uns(132 downto  0); subtype uns134   is uns(133 downto  0); subtype uns135   is uns(134 downto  0); subtype uns136   is uns(135 downto  0);
	subtype uns137   is uns(136 downto  0); subtype uns138   is uns(137 downto  0); subtype uns139   is uns(138 downto  0); subtype uns140   is uns(139 downto  0);
	subtype uns141   is uns(140 downto  0); subtype uns142   is uns(141 downto  0); subtype uns143   is uns(142 downto  0); subtype uns144   is uns(143 downto  0);
	subtype uns145   is uns(144 downto  0); subtype uns146   is uns(145 downto  0); subtype uns147   is uns(146 downto  0); subtype uns148   is uns(147 downto  0);
	subtype uns149   is uns(148 downto  0); subtype uns150   is uns(149 downto  0); subtype uns151   is uns(150 downto  0); subtype uns152   is uns(151 downto  0);
	subtype uns153   is uns(152 downto  0); subtype uns154   is uns(153 downto  0); subtype uns155   is uns(154 downto  0); subtype uns156   is uns(155 downto  0);
	subtype uns157   is uns(156 downto  0); subtype uns158   is uns(157 downto  0); subtype uns159   is uns(158 downto  0); subtype uns160   is uns(159 downto  0);
	subtype uns161   is uns(160 downto  0); subtype uns162   is uns(161 downto  0); subtype uns163   is uns(162 downto  0); subtype uns164   is uns(163 downto  0);
	subtype uns165   is uns(164 downto  0); subtype uns166   is uns(165 downto  0); subtype uns167   is uns(166 downto  0); subtype uns168   is uns(167 downto  0);
	subtype uns169   is uns(168 downto  0); subtype uns170   is uns(169 downto  0); subtype uns171   is uns(170 downto  0); subtype uns172   is uns(171 downto  0);
	subtype uns173   is uns(172 downto  0); subtype uns174   is uns(173 downto  0); subtype uns175   is uns(174 downto  0); subtype uns176   is uns(175 downto  0);
	subtype uns177   is uns(176 downto  0); subtype uns178   is uns(177 downto  0); subtype uns179   is uns(178 downto  0); subtype uns180   is uns(179 downto  0);
	subtype uns181   is uns(180 downto  0); subtype uns182   is uns(181 downto  0); subtype uns183   is uns(182 downto  0); subtype uns184   is uns(183 downto  0);
	subtype uns185   is uns(184 downto  0); subtype uns186   is uns(185 downto  0); subtype uns187   is uns(186 downto  0); subtype uns188   is uns(187 downto  0);
	subtype uns189   is uns(188 downto  0); subtype uns190   is uns(189 downto  0); subtype uns191   is uns(190 downto  0); subtype uns192   is uns(191 downto  0);
	subtype uns193   is uns(192 downto  0); subtype uns194   is uns(193 downto  0); subtype uns195   is uns(194 downto  0); subtype uns196   is uns(195 downto  0);
	subtype uns197   is uns(196 downto  0); subtype uns198   is uns(197 downto  0); subtype uns199   is uns(198 downto  0); subtype uns200   is uns(199 downto  0);
	subtype uns201   is uns(200 downto  0); subtype uns202   is uns(201 downto  0); subtype uns203   is uns(202 downto  0); subtype uns204   is uns(203 downto  0);
	subtype uns205   is uns(204 downto  0); subtype uns206   is uns(205 downto  0); subtype uns207   is uns(206 downto  0); subtype uns208   is uns(207 downto  0);
	subtype uns209   is uns(208 downto  0); subtype uns210   is uns(209 downto  0); subtype uns211   is uns(210 downto  0); subtype uns212   is uns(211 downto  0);
	subtype uns213   is uns(212 downto  0); subtype uns214   is uns(213 downto  0); subtype uns215   is uns(214 downto  0); subtype uns216   is uns(215 downto  0);
	subtype uns217   is uns(216 downto  0); subtype uns218   is uns(217 downto  0); subtype uns219   is uns(218 downto  0); subtype uns220   is uns(219 downto  0);
	subtype uns221   is uns(220 downto  0); subtype uns222   is uns(221 downto  0); subtype uns223   is uns(222 downto  0); subtype uns224   is uns(223 downto  0);
	subtype uns225   is uns(224 downto  0); subtype uns226   is uns(225 downto  0); subtype uns227   is uns(226 downto  0); subtype uns228   is uns(227 downto  0);
	subtype uns229   is uns(228 downto  0); subtype uns230   is uns(229 downto  0); subtype uns231   is uns(230 downto  0); subtype uns232   is uns(231 downto  0);
	subtype uns233   is uns(232 downto  0); subtype uns234   is uns(233 downto  0); subtype uns235   is uns(234 downto  0); subtype uns236   is uns(235 downto  0);
	subtype uns237   is uns(236 downto  0); subtype uns238   is uns(237 downto  0); subtype uns239   is uns(238 downto  0); subtype uns240   is uns(239 downto  0);
	subtype uns241   is uns(240 downto  0); subtype uns242   is uns(241 downto  0); subtype uns243   is uns(242 downto  0); subtype uns244   is uns(243 downto  0);
	subtype uns245   is uns(244 downto  0); subtype uns246   is uns(245 downto  0); subtype uns247   is uns(246 downto  0); subtype uns248   is uns(247 downto  0);
	subtype uns249   is uns(248 downto  0); subtype uns250   is uns(249 downto  0); subtype uns251   is uns(250 downto  0); subtype uns252   is uns(251 downto  0);
	subtype uns253   is uns(252 downto  0); subtype uns254   is uns(253 downto  0); subtype uns255   is uns(254 downto  0); subtype uns256   is uns(255 downto  0);
	subtype uns257   is uns(256 downto  0); subtype uns258   is uns(257 downto  0); subtype uns259   is uns(258 downto  0); subtype uns260   is uns(259 downto  0);
	subtype uns261   is uns(260 downto  0); subtype uns262   is uns(261 downto  0); subtype uns263   is uns(262 downto  0); subtype uns264   is uns(263 downto  0);
	subtype uns265   is uns(264 downto  0); subtype uns266   is uns(265 downto  0); subtype uns267   is uns(266 downto  0); subtype uns268   is uns(267 downto  0);
	subtype uns269   is uns(268 downto  0); subtype uns270   is uns(269 downto  0); subtype uns271   is uns(270 downto  0); subtype uns272   is uns(271 downto  0);
	subtype uns273   is uns(272 downto  0); subtype uns274   is uns(273 downto  0); subtype uns275   is uns(274 downto  0); subtype uns276   is uns(275 downto  0);
	subtype uns277   is uns(276 downto  0); subtype uns278   is uns(277 downto  0); subtype uns279   is uns(278 downto  0); subtype uns280   is uns(279 downto  0);
	subtype uns281   is uns(280 downto  0); subtype uns282   is uns(281 downto  0); subtype uns283   is uns(282 downto  0); subtype uns284   is uns(283 downto  0);
	subtype uns285   is uns(284 downto  0); subtype uns286   is uns(285 downto  0); subtype uns287   is uns(286 downto  0); subtype uns288   is uns(287 downto  0);
	subtype uns289   is uns(288 downto  0); subtype uns290   is uns(289 downto  0); subtype uns291   is uns(290 downto  0); subtype uns292   is uns(291 downto  0);
	subtype uns293   is uns(292 downto  0); subtype uns294   is uns(293 downto  0); subtype uns295   is uns(294 downto  0); subtype uns296   is uns(295 downto  0);
	subtype uns297   is uns(296 downto  0); subtype uns298   is uns(297 downto  0); subtype uns299   is uns(298 downto  0); subtype uns300   is uns(299 downto  0);

	type uns1array   is array(natural range <>) of uns1  ; type uns2array   is array(natural range <>) of uns2  ;
	type uns3array   is array(natural range <>) of uns3  ; type uns4array   is array(natural range <>) of uns4  ;
	type uns5array   is array(natural range <>) of uns5  ; type uns6array   is array(natural range <>) of uns6  ;
	type uns7array   is array(natural range <>) of uns7  ; type uns8array   is array(natural range <>) of uns8  ;
	type uns9array   is array(natural range <>) of uns9  ; type uns10array  is array(natural range <>) of uns10 ;
	type uns11array  is array(natural range <>) of uns11 ; type uns12array  is array(natural range <>) of uns12 ;
	type uns13array  is array(natural range <>) of uns13 ; type uns14array  is array(natural range <>) of uns14 ;
	type uns15array  is array(natural range <>) of uns15 ; type uns16array  is array(natural range <>) of uns16 ;
	type uns17array  is array(natural range <>) of uns17 ; type uns18array  is array(natural range <>) of uns18 ;
	type uns19array  is array(natural range <>) of uns19 ; type uns20array  is array(natural range <>) of uns20 ;
	type uns21array  is array(natural range <>) of uns21 ; type uns22array  is array(natural range <>) of uns22 ;
	type uns23array  is array(natural range <>) of uns23 ; type uns24array  is array(natural range <>) of uns24 ;
	type uns25array  is array(natural range <>) of uns25 ; type uns26array  is array(natural range <>) of uns26 ;
	type uns27array  is array(natural range <>) of uns27 ; type uns28array  is array(natural range <>) of uns28 ;
	type uns29array  is array(natural range <>) of uns29 ; type uns30array  is array(natural range <>) of uns30 ;
	type uns31array  is array(natural range <>) of uns31 ; type uns32array  is array(natural range <>) of uns32 ;
	type uns33array  is array(natural range <>) of uns33 ; type uns34array  is array(natural range <>) of uns34 ;
	type uns35array  is array(natural range <>) of uns35 ; type uns36array  is array(natural range <>) of uns36 ;
	type uns37array  is array(natural range <>) of uns37 ; type uns38array  is array(natural range <>) of uns38 ;
	type uns39array  is array(natural range <>) of uns39 ; type uns40array  is array(natural range <>) of uns40 ;
	type uns41array  is array(natural range <>) of uns41 ; type uns42array  is array(natural range <>) of uns42 ;
	type uns43array  is array(natural range <>) of uns43 ; type uns44array  is array(natural range <>) of uns44 ;
	type uns45array  is array(natural range <>) of uns45 ; type uns46array  is array(natural range <>) of uns46 ;
	type uns47array  is array(natural range <>) of uns47 ; type uns48array  is array(natural range <>) of uns48 ;
	type uns49array  is array(natural range <>) of uns49 ; type uns50array  is array(natural range <>) of uns50 ;
	type uns51array  is array(natural range <>) of uns51 ; type uns52array  is array(natural range <>) of uns52 ;
	type uns53array  is array(natural range <>) of uns53 ; type uns54array  is array(natural range <>) of uns54 ;
	type uns55array  is array(natural range <>) of uns55 ; type uns56array  is array(natural range <>) of uns56 ;
	type uns57array  is array(natural range <>) of uns57 ; type uns58array  is array(natural range <>) of uns58 ;
	type uns59array  is array(natural range <>) of uns59 ; type uns60array  is array(natural range <>) of uns60 ;
	type uns61array  is array(natural range <>) of uns61 ; type uns62array  is array(natural range <>) of uns62 ;
	type uns63array  is array(natural range <>) of uns63 ; type uns64array  is array(natural range <>) of uns64 ;
	type uns65array  is array(natural range <>) of uns65 ; type uns66array  is array(natural range <>) of uns66 ;
	type uns67array  is array(natural range <>) of uns67 ; type uns68array  is array(natural range <>) of uns68 ;
	type uns69array  is array(natural range <>) of uns69 ; type uns70array  is array(natural range <>) of uns70 ;
	type uns71array  is array(natural range <>) of uns71 ; type uns72array  is array(natural range <>) of uns72 ;
	type uns73array  is array(natural range <>) of uns73 ; type uns74array  is array(natural range <>) of uns74 ;
	type uns75array  is array(natural range <>) of uns75 ; type uns76array  is array(natural range <>) of uns76 ;
	type uns77array  is array(natural range <>) of uns77 ; type uns78array  is array(natural range <>) of uns78 ;
	type uns79array  is array(natural range <>) of uns79 ; type uns80array  is array(natural range <>) of uns80 ;
	type uns81array  is array(natural range <>) of uns81 ; type uns82array  is array(natural range <>) of uns82 ;
	type uns83array  is array(natural range <>) of uns83 ; type uns84array  is array(natural range <>) of uns84 ;
	type uns85array  is array(natural range <>) of uns85 ; type uns86array  is array(natural range <>) of uns86 ;
	type uns87array  is array(natural range <>) of uns87 ; type uns88array  is array(natural range <>) of uns88 ;
	type uns89array  is array(natural range <>) of uns89 ; type uns90array  is array(natural range <>) of uns90 ;
	type uns91array  is array(natural range <>) of uns91 ; type uns92array  is array(natural range <>) of uns92 ;
	type uns93array  is array(natural range <>) of uns93 ; type uns94array  is array(natural range <>) of uns94 ;
	type uns95array  is array(natural range <>) of uns95 ; type uns96array  is array(natural range <>) of uns96 ;
	type uns97array  is array(natural range <>) of uns97 ; type uns98array  is array(natural range <>) of uns98 ;
	type uns99array  is array(natural range <>) of uns99 ; type uns100array is array(natural range <>) of uns100;
	type uns101array is array(natural range <>) of uns101; type uns102array is array(natural range <>) of uns102;
	type uns103array is array(natural range <>) of uns103; type uns104array is array(natural range <>) of uns104;
	type uns105array is array(natural range <>) of uns105; type uns106array is array(natural range <>) of uns106;
	type uns107array is array(natural range <>) of uns107; type uns108array is array(natural range <>) of uns108;
	type uns109array is array(natural range <>) of uns109; type uns110array is array(natural range <>) of uns110;
	type uns111array is array(natural range <>) of uns111; type uns112array is array(natural range <>) of uns112;
	type uns113array is array(natural range <>) of uns113; type uns114array is array(natural range <>) of uns114;
	type uns115array is array(natural range <>) of uns115; type uns116array is array(natural range <>) of uns116;
	type uns117array is array(natural range <>) of uns117; type uns118array is array(natural range <>) of uns118;
	type uns119array is array(natural range <>) of uns119; type uns120array is array(natural range <>) of uns120;
	type uns121array is array(natural range <>) of uns121; type uns122array is array(natural range <>) of uns122;
	type uns123array is array(natural range <>) of uns123; type uns124array is array(natural range <>) of uns124;
	type uns125array is array(natural range <>) of uns125; type uns126array is array(natural range <>) of uns126;
	type uns127array is array(natural range <>) of uns127; type uns128array is array(natural range <>) of uns128;
	type uns129array is array(natural range <>) of uns129; type uns130array is array(natural range <>) of uns130;
	type uns131array is array(natural range <>) of uns131; type uns132array is array(natural range <>) of uns132;
	type uns133array is array(natural range <>) of uns133; type uns134array is array(natural range <>) of uns134;
	type uns135array is array(natural range <>) of uns135; type uns136array is array(natural range <>) of uns136;
	type uns137array is array(natural range <>) of uns137; type uns138array is array(natural range <>) of uns138;
	type uns139array is array(natural range <>) of uns139; type uns140array is array(natural range <>) of uns140;
	type uns141array is array(natural range <>) of uns141; type uns142array is array(natural range <>) of uns142;
	type uns143array is array(natural range <>) of uns143; type uns144array is array(natural range <>) of uns144;
--**************************************************************************************************************************************************************
-- BOOLEAN and array
--**************************************************************************************************************************************************************
	type BoolArray is array (natural range <>) of boolean;
--**************************************************************************************************************************************************************
-- INTEGER and array
--**************************************************************************************************************************************************************
	   type IntArray   is array(natural range <>) of int;
	   type Int16x16Array is array(15 downto 0,15 downto 0) of int;
	subtype Int1Array   is IntArray(  0 downto 0);   subtype Int129Array is IntArray(128 downto 0);   subtype Int257Array is IntArray(256 downto 0);   subtype Int385Array is IntArray(384 downto 0);
	subtype Int2Array   is IntArray(  1 downto 0);   subtype Int130Array is IntArray(129 downto 0);   subtype Int258Array is IntArray(257 downto 0);   subtype Int386Array is IntArray(385 downto 0);
	subtype Int3Array   is IntArray(  2 downto 0);   subtype Int131Array is IntArray(130 downto 0);   subtype Int259Array is IntArray(258 downto 0);   subtype Int387Array is IntArray(386 downto 0);
	subtype Int4Array   is IntArray(  3 downto 0);   subtype Int132Array is IntArray(131 downto 0);   subtype Int260Array is IntArray(259 downto 0);   subtype Int388Array is IntArray(387 downto 0);
	subtype Int5Array   is IntArray(  4 downto 0);   subtype Int133Array is IntArray(132 downto 0);   subtype Int261Array is IntArray(260 downto 0);   subtype Int389Array is IntArray(388 downto 0);
	subtype Int6Array   is IntArray(  5 downto 0);   subtype Int134Array is IntArray(133 downto 0);   subtype Int262Array is IntArray(261 downto 0);   subtype Int390Array is IntArray(389 downto 0);
	subtype Int7Array   is IntArray(  6 downto 0);   subtype Int135Array is IntArray(134 downto 0);   subtype Int263Array is IntArray(262 downto 0);   subtype Int391Array is IntArray(390 downto 0);
	subtype Int8Array   is IntArray(  7 downto 0);   subtype Int136Array is IntArray(135 downto 0);   subtype Int264Array is IntArray(263 downto 0);   subtype Int392Array is IntArray(391 downto 0);
	subtype Int9Array   is IntArray(  8 downto 0);   subtype Int137Array is IntArray(136 downto 0);   subtype Int265Array is IntArray(264 downto 0);   subtype Int393Array is IntArray(392 downto 0);
	subtype Int10Array  is IntArray(  9 downto 0);   subtype Int138Array is IntArray(137 downto 0);   subtype Int266Array is IntArray(265 downto 0);   subtype Int394Array is IntArray(393 downto 0);
	subtype Int11Array  is IntArray( 10 downto 0);   subtype Int139Array is IntArray(138 downto 0);   subtype Int267Array is IntArray(266 downto 0);   subtype Int395Array is IntArray(394 downto 0);
	subtype Int12Array  is IntArray( 11 downto 0);   subtype Int140Array is IntArray(139 downto 0);   subtype Int268Array is IntArray(267 downto 0);   subtype Int396Array is IntArray(395 downto 0);
	subtype Int13Array  is IntArray( 12 downto 0);   subtype Int141Array is IntArray(140 downto 0);   subtype Int269Array is IntArray(268 downto 0);   subtype Int397Array is IntArray(396 downto 0);
	subtype Int14Array  is IntArray( 13 downto 0);   subtype Int142Array is IntArray(141 downto 0);   subtype Int270Array is IntArray(269 downto 0);   subtype Int398Array is IntArray(397 downto 0);
	subtype Int15Array  is IntArray( 14 downto 0);   subtype Int143Array is IntArray(142 downto 0);   subtype Int271Array is IntArray(270 downto 0);   subtype Int399Array is IntArray(398 downto 0);
	subtype Int16Array  is IntArray( 15 downto 0);   subtype Int144Array is IntArray(143 downto 0);   subtype Int272Array is IntArray(271 downto 0);   subtype Int400Array is IntArray(399 downto 0);
	subtype Int17Array  is IntArray( 16 downto 0);   subtype Int145Array is IntArray(144 downto 0);   subtype Int273Array is IntArray(272 downto 0);   subtype Int401Array is IntArray(400 downto 0);
	subtype Int18Array  is IntArray( 17 downto 0);   subtype Int146Array is IntArray(145 downto 0);   subtype Int274Array is IntArray(273 downto 0);   subtype Int402Array is IntArray(401 downto 0);
	subtype Int19Array  is IntArray( 18 downto 0);   subtype Int147Array is IntArray(146 downto 0);   subtype Int275Array is IntArray(274 downto 0);   subtype Int403Array is IntArray(402 downto 0);
	subtype Int20Array  is IntArray( 19 downto 0);   subtype Int148Array is IntArray(147 downto 0);   subtype Int276Array is IntArray(275 downto 0);   subtype Int404Array is IntArray(403 downto 0);
	subtype Int21Array  is IntArray( 20 downto 0);   subtype Int149Array is IntArray(148 downto 0);   subtype Int277Array is IntArray(276 downto 0);   subtype Int405Array is IntArray(404 downto 0);
	subtype Int22Array  is IntArray( 21 downto 0);   subtype Int150Array is IntArray(149 downto 0);   subtype Int278Array is IntArray(277 downto 0);   subtype Int406Array is IntArray(405 downto 0);
	subtype Int23Array  is IntArray( 22 downto 0);   subtype Int151Array is IntArray(150 downto 0);   subtype Int279Array is IntArray(278 downto 0);   subtype Int407Array is IntArray(406 downto 0);
	subtype Int24Array  is IntArray( 23 downto 0);   subtype Int152Array is IntArray(151 downto 0);   subtype Int280Array is IntArray(279 downto 0);   subtype Int408Array is IntArray(407 downto 0);
	subtype Int25Array  is IntArray( 24 downto 0);   subtype Int153Array is IntArray(152 downto 0);   subtype Int281Array is IntArray(280 downto 0);   subtype Int409Array is IntArray(408 downto 0);
	subtype Int26Array  is IntArray( 25 downto 0);   subtype Int154Array is IntArray(153 downto 0);   subtype Int282Array is IntArray(281 downto 0);   subtype Int410Array is IntArray(409 downto 0);
	subtype Int27Array  is IntArray( 26 downto 0);   subtype Int155Array is IntArray(154 downto 0);   subtype Int283Array is IntArray(282 downto 0);   subtype Int411Array is IntArray(410 downto 0);
	subtype Int28Array  is IntArray( 27 downto 0);   subtype Int156Array is IntArray(155 downto 0);   subtype Int284Array is IntArray(283 downto 0);   subtype Int412Array is IntArray(411 downto 0);
	subtype Int29Array  is IntArray( 28 downto 0);   subtype Int157Array is IntArray(156 downto 0);   subtype Int285Array is IntArray(284 downto 0);   subtype Int413Array is IntArray(412 downto 0);
	subtype Int30Array  is IntArray( 29 downto 0);   subtype Int158Array is IntArray(157 downto 0);   subtype Int286Array is IntArray(285 downto 0);   subtype Int414Array is IntArray(413 downto 0);
	subtype Int31Array  is IntArray( 30 downto 0);   subtype Int159Array is IntArray(158 downto 0);   subtype Int287Array is IntArray(286 downto 0);   subtype Int415Array is IntArray(414 downto 0);
	subtype Int32Array  is IntArray( 31 downto 0);   subtype Int160Array is IntArray(159 downto 0);   subtype Int288Array is IntArray(287 downto 0);   subtype Int416Array is IntArray(415 downto 0);
	subtype Int33Array  is IntArray( 32 downto 0);   subtype Int161Array is IntArray(160 downto 0);   subtype Int289Array is IntArray(288 downto 0);   subtype Int417Array is IntArray(416 downto 0);
	subtype Int34Array  is IntArray( 33 downto 0);   subtype Int162Array is IntArray(161 downto 0);   subtype Int290Array is IntArray(289 downto 0);   subtype Int418Array is IntArray(417 downto 0);
	subtype Int35Array  is IntArray( 34 downto 0);   subtype Int163Array is IntArray(162 downto 0);   subtype Int291Array is IntArray(290 downto 0);   subtype Int419Array is IntArray(418 downto 0);
	subtype Int36Array  is IntArray( 35 downto 0);   subtype Int164Array is IntArray(163 downto 0);   subtype Int292Array is IntArray(291 downto 0);   subtype Int420Array is IntArray(419 downto 0);
	subtype Int37Array  is IntArray( 36 downto 0);   subtype Int165Array is IntArray(164 downto 0);   subtype Int293Array is IntArray(292 downto 0);   subtype Int421Array is IntArray(420 downto 0);
	subtype Int38Array  is IntArray( 37 downto 0);   subtype Int166Array is IntArray(165 downto 0);   subtype Int294Array is IntArray(293 downto 0);   subtype Int422Array is IntArray(421 downto 0);
	subtype Int39Array  is IntArray( 38 downto 0);   subtype Int167Array is IntArray(166 downto 0);   subtype Int295Array is IntArray(294 downto 0);   subtype Int423Array is IntArray(422 downto 0);
	subtype Int40Array  is IntArray( 39 downto 0);   subtype Int168Array is IntArray(167 downto 0);   subtype Int296Array is IntArray(295 downto 0);   subtype Int424Array is IntArray(423 downto 0);
	subtype Int41Array  is IntArray( 40 downto 0);   subtype Int169Array is IntArray(168 downto 0);   subtype Int297Array is IntArray(296 downto 0);   subtype Int425Array is IntArray(424 downto 0);
	subtype Int42Array  is IntArray( 41 downto 0);   subtype Int170Array is IntArray(169 downto 0);   subtype Int298Array is IntArray(297 downto 0);   subtype Int426Array is IntArray(425 downto 0);
	subtype Int43Array  is IntArray( 42 downto 0);   subtype Int171Array is IntArray(170 downto 0);   subtype Int299Array is IntArray(298 downto 0);   subtype Int427Array is IntArray(426 downto 0);
	subtype Int44Array  is IntArray( 43 downto 0);   subtype Int172Array is IntArray(171 downto 0);   subtype Int300Array is IntArray(299 downto 0);   subtype Int428Array is IntArray(427 downto 0);
	subtype Int45Array  is IntArray( 44 downto 0);   subtype Int173Array is IntArray(172 downto 0);   subtype Int301Array is IntArray(300 downto 0);   subtype Int429Array is IntArray(428 downto 0);
	subtype Int46Array  is IntArray( 45 downto 0);   subtype Int174Array is IntArray(173 downto 0);   subtype Int302Array is IntArray(301 downto 0);   subtype Int430Array is IntArray(429 downto 0);
	subtype Int47Array  is IntArray( 46 downto 0);   subtype Int175Array is IntArray(174 downto 0);   subtype Int303Array is IntArray(302 downto 0);   subtype Int431Array is IntArray(430 downto 0);
	subtype Int48Array  is IntArray( 47 downto 0);   subtype Int176Array is IntArray(175 downto 0);   subtype Int304Array is IntArray(303 downto 0);   subtype Int432Array is IntArray(431 downto 0);
	subtype Int49Array  is IntArray( 48 downto 0);   subtype Int177Array is IntArray(176 downto 0);   subtype Int305Array is IntArray(304 downto 0);   subtype Int433Array is IntArray(432 downto 0);
	subtype Int50Array  is IntArray( 49 downto 0);   subtype Int178Array is IntArray(177 downto 0);   subtype Int306Array is IntArray(305 downto 0);   subtype Int434Array is IntArray(433 downto 0);
	subtype Int51Array  is IntArray( 50 downto 0);   subtype Int179Array is IntArray(178 downto 0);   subtype Int307Array is IntArray(306 downto 0);   subtype Int435Array is IntArray(434 downto 0);
	subtype Int52Array  is IntArray( 51 downto 0);   subtype Int180Array is IntArray(179 downto 0);   subtype Int308Array is IntArray(307 downto 0);   subtype Int436Array is IntArray(435 downto 0);
	subtype Int53Array  is IntArray( 52 downto 0);   subtype Int181Array is IntArray(180 downto 0);   subtype Int309Array is IntArray(308 downto 0);   subtype Int437Array is IntArray(436 downto 0);
	subtype Int54Array  is IntArray( 53 downto 0);   subtype Int182Array is IntArray(181 downto 0);   subtype Int310Array is IntArray(309 downto 0);   subtype Int438Array is IntArray(437 downto 0);
	subtype Int55Array  is IntArray( 54 downto 0);   subtype Int183Array is IntArray(182 downto 0);   subtype Int311Array is IntArray(310 downto 0);   subtype Int439Array is IntArray(438 downto 0);
	subtype Int56Array  is IntArray( 55 downto 0);   subtype Int184Array is IntArray(183 downto 0);   subtype Int312Array is IntArray(311 downto 0);   subtype Int440Array is IntArray(439 downto 0);
	subtype Int57Array  is IntArray( 56 downto 0);   subtype Int185Array is IntArray(184 downto 0);   subtype Int313Array is IntArray(312 downto 0);   subtype Int441Array is IntArray(440 downto 0);
	subtype Int58Array  is IntArray( 57 downto 0);   subtype Int186Array is IntArray(185 downto 0);   subtype Int314Array is IntArray(313 downto 0);   subtype Int442Array is IntArray(441 downto 0);
	subtype Int59Array  is IntArray( 58 downto 0);   subtype Int187Array is IntArray(186 downto 0);   subtype Int315Array is IntArray(314 downto 0);   subtype Int443Array is IntArray(442 downto 0);
	subtype Int60Array  is IntArray( 59 downto 0);   subtype Int188Array is IntArray(187 downto 0);   subtype Int316Array is IntArray(315 downto 0);   subtype Int444Array is IntArray(443 downto 0);
	subtype Int61Array  is IntArray( 60 downto 0);   subtype Int189Array is IntArray(188 downto 0);   subtype Int317Array is IntArray(316 downto 0);   subtype Int445Array is IntArray(444 downto 0);
	subtype Int62Array  is IntArray( 61 downto 0);   subtype Int190Array is IntArray(189 downto 0);   subtype Int318Array is IntArray(317 downto 0);   subtype Int446Array is IntArray(445 downto 0);
	subtype Int63Array  is IntArray( 62 downto 0);   subtype Int191Array is IntArray(190 downto 0);   subtype Int319Array is IntArray(318 downto 0);   subtype Int447Array is IntArray(446 downto 0);
	subtype Int64Array  is IntArray( 63 downto 0);   subtype Int192Array is IntArray(191 downto 0);   subtype Int320Array is IntArray(319 downto 0);   subtype Int448Array is IntArray(447 downto 0);
	subtype Int65Array  is IntArray( 64 downto 0);   subtype Int193Array is IntArray(192 downto 0);   subtype Int321Array is IntArray(320 downto 0);   subtype Int449Array is IntArray(448 downto 0);
	subtype Int66Array  is IntArray( 65 downto 0);   subtype Int194Array is IntArray(193 downto 0);   subtype Int322Array is IntArray(321 downto 0);   subtype Int450Array is IntArray(449 downto 0);
	subtype Int67Array  is IntArray( 66 downto 0);   subtype Int195Array is IntArray(194 downto 0);   subtype Int323Array is IntArray(322 downto 0);   subtype Int451Array is IntArray(450 downto 0);
	subtype Int68Array  is IntArray( 67 downto 0);   subtype Int196Array is IntArray(195 downto 0);   subtype Int324Array is IntArray(323 downto 0);   subtype Int452Array is IntArray(451 downto 0);
	subtype Int69Array  is IntArray( 68 downto 0);   subtype Int197Array is IntArray(196 downto 0);   subtype Int325Array is IntArray(324 downto 0);   subtype Int453Array is IntArray(452 downto 0);
	subtype Int70Array  is IntArray( 69 downto 0);   subtype Int198Array is IntArray(197 downto 0);   subtype Int326Array is IntArray(325 downto 0);   subtype Int454Array is IntArray(453 downto 0);
	subtype Int71Array  is IntArray( 70 downto 0);   subtype Int199Array is IntArray(198 downto 0);   subtype Int327Array is IntArray(326 downto 0);   subtype Int455Array is IntArray(454 downto 0);
	subtype Int72Array  is IntArray( 71 downto 0);   subtype Int200Array is IntArray(199 downto 0);   subtype Int328Array is IntArray(327 downto 0);   subtype Int456Array is IntArray(455 downto 0);
	subtype Int73Array  is IntArray( 72 downto 0);   subtype Int201Array is IntArray(200 downto 0);   subtype Int329Array is IntArray(328 downto 0);   subtype Int457Array is IntArray(456 downto 0);
	subtype Int74Array  is IntArray( 73 downto 0);   subtype Int202Array is IntArray(201 downto 0);   subtype Int330Array is IntArray(329 downto 0);   subtype Int458Array is IntArray(457 downto 0);
	subtype Int75Array  is IntArray( 74 downto 0);   subtype Int203Array is IntArray(202 downto 0);   subtype Int331Array is IntArray(330 downto 0);   subtype Int459Array is IntArray(458 downto 0);
	subtype Int76Array  is IntArray( 75 downto 0);   subtype Int204Array is IntArray(203 downto 0);   subtype Int332Array is IntArray(331 downto 0);   subtype Int460Array is IntArray(459 downto 0);
	subtype Int77Array  is IntArray( 76 downto 0);   subtype Int205Array is IntArray(204 downto 0);   subtype Int333Array is IntArray(332 downto 0);   subtype Int461Array is IntArray(460 downto 0);
	subtype Int78Array  is IntArray( 77 downto 0);   subtype Int206Array is IntArray(205 downto 0);   subtype Int334Array is IntArray(333 downto 0);   subtype Int462Array is IntArray(461 downto 0);
	subtype Int79Array  is IntArray( 78 downto 0);   subtype Int207Array is IntArray(206 downto 0);   subtype Int335Array is IntArray(334 downto 0);   subtype Int463Array is IntArray(462 downto 0);
	subtype Int80Array  is IntArray( 79 downto 0);   subtype Int208Array is IntArray(207 downto 0);   subtype Int336Array is IntArray(335 downto 0);   subtype Int464Array is IntArray(463 downto 0);
	subtype Int81Array  is IntArray( 80 downto 0);   subtype Int209Array is IntArray(208 downto 0);   subtype Int337Array is IntArray(336 downto 0);   subtype Int465Array is IntArray(464 downto 0);
	subtype Int82Array  is IntArray( 81 downto 0);   subtype Int210Array is IntArray(209 downto 0);   subtype Int338Array is IntArray(337 downto 0);   subtype Int466Array is IntArray(465 downto 0);
	subtype Int83Array  is IntArray( 82 downto 0);   subtype Int211Array is IntArray(210 downto 0);   subtype Int339Array is IntArray(338 downto 0);   subtype Int467Array is IntArray(466 downto 0);
	subtype Int84Array  is IntArray( 83 downto 0);   subtype Int212Array is IntArray(211 downto 0);   subtype Int340Array is IntArray(339 downto 0);   subtype Int468Array is IntArray(467 downto 0);
	subtype Int85Array  is IntArray( 84 downto 0);   subtype Int213Array is IntArray(212 downto 0);   subtype Int341Array is IntArray(340 downto 0);   subtype Int469Array is IntArray(468 downto 0);
	subtype Int86Array  is IntArray( 85 downto 0);   subtype Int214Array is IntArray(213 downto 0);   subtype Int342Array is IntArray(341 downto 0);   subtype Int470Array is IntArray(469 downto 0);
	subtype Int87Array  is IntArray( 86 downto 0);   subtype Int215Array is IntArray(214 downto 0);   subtype Int343Array is IntArray(342 downto 0);   subtype Int471Array is IntArray(470 downto 0);
	subtype Int88Array  is IntArray( 87 downto 0);   subtype Int216Array is IntArray(215 downto 0);   subtype Int344Array is IntArray(343 downto 0);   subtype Int472Array is IntArray(471 downto 0);
	subtype Int89Array  is IntArray( 88 downto 0);   subtype Int217Array is IntArray(216 downto 0);   subtype Int345Array is IntArray(344 downto 0);   subtype Int473Array is IntArray(472 downto 0);
	subtype Int90Array  is IntArray( 89 downto 0);   subtype Int218Array is IntArray(217 downto 0);   subtype Int346Array is IntArray(345 downto 0);   subtype Int474Array is IntArray(473 downto 0);
	subtype Int91Array  is IntArray( 90 downto 0);   subtype Int219Array is IntArray(218 downto 0);   subtype Int347Array is IntArray(346 downto 0);   subtype Int475Array is IntArray(474 downto 0);
	subtype Int92Array  is IntArray( 91 downto 0);   subtype Int220Array is IntArray(219 downto 0);   subtype Int348Array is IntArray(347 downto 0);   subtype Int476Array is IntArray(475 downto 0);
	subtype Int93Array  is IntArray( 92 downto 0);   subtype Int221Array is IntArray(220 downto 0);   subtype Int349Array is IntArray(348 downto 0);   subtype Int477Array is IntArray(476 downto 0);
	subtype Int94Array  is IntArray( 93 downto 0);   subtype Int222Array is IntArray(221 downto 0);   subtype Int350Array is IntArray(349 downto 0);   subtype Int478Array is IntArray(477 downto 0);
	subtype Int95Array  is IntArray( 94 downto 0);   subtype Int223Array is IntArray(222 downto 0);   subtype Int351Array is IntArray(350 downto 0);   subtype Int479Array is IntArray(478 downto 0);
	subtype Int96Array  is IntArray( 95 downto 0);   subtype Int224Array is IntArray(223 downto 0);   subtype Int352Array is IntArray(351 downto 0);   subtype Int480Array is IntArray(479 downto 0);
	subtype Int97Array  is IntArray( 96 downto 0);   subtype Int225Array is IntArray(224 downto 0);   subtype Int353Array is IntArray(352 downto 0);   subtype Int481Array is IntArray(480 downto 0);
	subtype Int98Array  is IntArray( 97 downto 0);   subtype Int226Array is IntArray(225 downto 0);   subtype Int354Array is IntArray(353 downto 0);   subtype Int482Array is IntArray(481 downto 0);
	subtype Int99Array  is IntArray( 98 downto 0);   subtype Int227Array is IntArray(226 downto 0);   subtype Int355Array is IntArray(354 downto 0);   subtype Int483Array is IntArray(482 downto 0);
	subtype Int100Array is IntArray( 99 downto 0);   subtype Int228Array is IntArray(227 downto 0);   subtype Int356Array is IntArray(355 downto 0);   subtype Int484Array is IntArray(483 downto 0);
	subtype Int101Array is IntArray(100 downto 0);   subtype Int229Array is IntArray(228 downto 0);   subtype Int357Array is IntArray(356 downto 0);   subtype Int485Array is IntArray(484 downto 0);
	subtype Int102Array is IntArray(101 downto 0);   subtype Int230Array is IntArray(229 downto 0);   subtype Int358Array is IntArray(357 downto 0);   subtype Int486Array is IntArray(485 downto 0);
	subtype Int103Array is IntArray(102 downto 0);   subtype Int231Array is IntArray(230 downto 0);   subtype Int359Array is IntArray(358 downto 0);   subtype Int487Array is IntArray(486 downto 0);
	subtype Int104Array is IntArray(103 downto 0);   subtype Int232Array is IntArray(231 downto 0);   subtype Int360Array is IntArray(359 downto 0);   subtype Int488Array is IntArray(487 downto 0);
	subtype Int105Array is IntArray(104 downto 0);   subtype Int233Array is IntArray(232 downto 0);   subtype Int361Array is IntArray(360 downto 0);   subtype Int489Array is IntArray(488 downto 0);
	subtype Int106Array is IntArray(105 downto 0);   subtype Int234Array is IntArray(233 downto 0);   subtype Int362Array is IntArray(361 downto 0);   subtype Int490Array is IntArray(489 downto 0);
	subtype Int107Array is IntArray(106 downto 0);   subtype Int235Array is IntArray(234 downto 0);   subtype Int363Array is IntArray(362 downto 0);   subtype Int491Array is IntArray(490 downto 0);
	subtype Int108Array is IntArray(107 downto 0);   subtype Int236Array is IntArray(235 downto 0);   subtype Int364Array is IntArray(363 downto 0);   subtype Int492Array is IntArray(491 downto 0);
	subtype Int109Array is IntArray(108 downto 0);   subtype Int237Array is IntArray(236 downto 0);   subtype Int365Array is IntArray(364 downto 0);   subtype Int493Array is IntArray(492 downto 0);
	subtype Int110Array is IntArray(109 downto 0);   subtype Int238Array is IntArray(237 downto 0);   subtype Int366Array is IntArray(365 downto 0);   subtype Int494Array is IntArray(493 downto 0);
	subtype Int111Array is IntArray(110 downto 0);   subtype Int239Array is IntArray(238 downto 0);   subtype Int367Array is IntArray(366 downto 0);   subtype Int495Array is IntArray(494 downto 0);
	subtype Int112Array is IntArray(111 downto 0);   subtype Int240Array is IntArray(239 downto 0);   subtype Int368Array is IntArray(367 downto 0);   subtype Int496Array is IntArray(495 downto 0);
	subtype Int113Array is IntArray(112 downto 0);   subtype Int241Array is IntArray(240 downto 0);   subtype Int369Array is IntArray(368 downto 0);   subtype Int497Array is IntArray(496 downto 0);
	subtype Int114Array is IntArray(113 downto 0);   subtype Int242Array is IntArray(241 downto 0);   subtype Int370Array is IntArray(369 downto 0);   subtype Int498Array is IntArray(497 downto 0);
	subtype Int115Array is IntArray(114 downto 0);   subtype Int243Array is IntArray(242 downto 0);   subtype Int371Array is IntArray(370 downto 0);   subtype Int499Array is IntArray(498 downto 0);
	subtype Int116Array is IntArray(115 downto 0);   subtype Int244Array is IntArray(243 downto 0);   subtype Int372Array is IntArray(371 downto 0);   subtype Int500Array is IntArray(499 downto 0);
	subtype Int117Array is IntArray(116 downto 0);   subtype Int245Array is IntArray(244 downto 0);   subtype Int373Array is IntArray(372 downto 0);   subtype Int501Array is IntArray(500 downto 0);
	subtype Int118Array is IntArray(117 downto 0);   subtype Int246Array is IntArray(245 downto 0);   subtype Int374Array is IntArray(373 downto 0);   subtype Int502Array is IntArray(501 downto 0);
	subtype Int119Array is IntArray(118 downto 0);   subtype Int247Array is IntArray(246 downto 0);   subtype Int375Array is IntArray(374 downto 0);   subtype Int503Array is IntArray(502 downto 0);
	subtype Int120Array is IntArray(119 downto 0);   subtype Int248Array is IntArray(247 downto 0);   subtype Int376Array is IntArray(375 downto 0);   subtype Int504Array is IntArray(503 downto 0);
	subtype Int121Array is IntArray(120 downto 0);   subtype Int249Array is IntArray(248 downto 0);   subtype Int377Array is IntArray(376 downto 0);   subtype Int505Array is IntArray(504 downto 0);
	subtype Int122Array is IntArray(121 downto 0);   subtype Int250Array is IntArray(249 downto 0);   subtype Int378Array is IntArray(377 downto 0);   subtype Int506Array is IntArray(505 downto 0);
	subtype Int123Array is IntArray(122 downto 0);   subtype Int251Array is IntArray(250 downto 0);   subtype Int379Array is IntArray(378 downto 0);   subtype Int507Array is IntArray(506 downto 0);
	subtype Int124Array is IntArray(123 downto 0);   subtype Int252Array is IntArray(251 downto 0);   subtype Int380Array is IntArray(379 downto 0);   subtype Int508Array is IntArray(507 downto 0);
	subtype Int125Array is IntArray(124 downto 0);   subtype Int253Array is IntArray(252 downto 0);   subtype Int381Array is IntArray(380 downto 0);   subtype Int509Array is IntArray(508 downto 0);
	subtype Int126Array is IntArray(125 downto 0);   subtype Int254Array is IntArray(253 downto 0);   subtype Int382Array is IntArray(381 downto 0);   subtype Int510Array is IntArray(509 downto 0);
	subtype Int127Array is IntArray(126 downto 0);   subtype Int255Array is IntArray(254 downto 0);   subtype Int383Array is IntArray(382 downto 0);   subtype Int511Array is IntArray(510 downto 0);
	subtype Int128Array is IntArray(127 downto 0);   subtype Int256Array is IntArray(255 downto 0);   subtype Int384Array is IntArray(383 downto 0);   subtype Int512Array is IntArray(511 downto 0);

--**************************************************************************************************************************************************************
-- REAL and array
--**************************************************************************************************************************************************************
	   type RealArray    is array(natural range <>) of real;
	subtype Real1Array   is RealArray(  0 downto 0);   subtype Real2Array   is RealArray(  1 downto 0);   subtype Real3Array   is RealArray(  2 downto 0);   subtype Real4Array   is RealArray(  3 downto 0);
	subtype Real5Array   is RealArray(  4 downto 0);   subtype Real6Array   is RealArray(  5 downto 0);   subtype Real7Array   is RealArray(  6 downto 0);   subtype Real8Array   is RealArray(  7 downto 0);
	subtype Real9Array   is RealArray(  8 downto 0);   subtype Real10Array  is RealArray(  9 downto 0);   subtype Real11Array  is RealArray( 10 downto 0);   subtype Real12Array  is RealArray( 11 downto 0);
	subtype Real13Array  is RealArray( 12 downto 0);   subtype Real14Array  is RealArray( 13 downto 0);   subtype Real15Array  is RealArray( 14 downto 0);   subtype Real16Array  is RealArray( 15 downto 0);
	subtype Real17Array  is RealArray( 16 downto 0);   subtype Real18Array  is RealArray( 17 downto 0);   subtype Real19Array  is RealArray( 18 downto 0);   subtype Real20Array  is RealArray( 19 downto 0);
	subtype Real21Array  is RealArray( 20 downto 0);   subtype Real22Array  is RealArray( 21 downto 0);   subtype Real23Array  is RealArray( 22 downto 0);   subtype Real24Array  is RealArray( 23 downto 0);
	subtype Real25Array  is RealArray( 24 downto 0);   subtype Real26Array  is RealArray( 25 downto 0);   subtype Real27Array  is RealArray( 26 downto 0);   subtype Real28Array  is RealArray( 27 downto 0);
	subtype Real29Array  is RealArray( 28 downto 0);   subtype Real30Array  is RealArray( 29 downto 0);   subtype Real31Array  is RealArray( 30 downto 0);   subtype Real32Array  is RealArray( 31 downto 0);
	subtype Real33Array  is RealArray( 32 downto 0);   subtype Real34Array  is RealArray( 33 downto 0);   subtype Real35Array  is RealArray( 34 downto 0);   subtype Real36Array  is RealArray( 35 downto 0);
	subtype Real37Array  is RealArray( 36 downto 0);   subtype Real38Array  is RealArray( 37 downto 0);   subtype Real39Array  is RealArray( 38 downto 0);   subtype Real40Array  is RealArray( 39 downto 0);
	subtype Real41Array  is RealArray( 40 downto 0);   subtype Real42Array  is RealArray( 41 downto 0);   subtype Real43Array  is RealArray( 42 downto 0);   subtype Real44Array  is RealArray( 43 downto 0);
	subtype Real45Array  is RealArray( 44 downto 0);   subtype Real46Array  is RealArray( 45 downto 0);   subtype Real47Array  is RealArray( 46 downto 0);   subtype Real48Array  is RealArray( 47 downto 0);
	subtype Real49Array  is RealArray( 48 downto 0);   subtype Real50Array  is RealArray( 49 downto 0);   subtype Real51Array  is RealArray( 50 downto 0);   subtype Real52Array  is RealArray( 51 downto 0);
	subtype Real53Array  is RealArray( 52 downto 0);   subtype Real54Array  is RealArray( 53 downto 0);   subtype Real55Array  is RealArray( 54 downto 0);   subtype Real56Array  is RealArray( 55 downto 0);
	subtype Real57Array  is RealArray( 56 downto 0);   subtype Real58Array  is RealArray( 57 downto 0);   subtype Real59Array  is RealArray( 58 downto 0);   subtype Real60Array  is RealArray( 59 downto 0);
	subtype Real61Array  is RealArray( 60 downto 0);   subtype Real62Array  is RealArray( 61 downto 0);   subtype Real63Array  is RealArray( 62 downto 0);   subtype Real64Array  is RealArray( 63 downto 0);
	subtype Real65Array  is RealArray( 64 downto 0);   subtype Real66Array  is RealArray( 65 downto 0);   subtype Real67Array  is RealArray( 66 downto 0);   subtype Real68Array  is RealArray( 67 downto 0);
	subtype Real69Array  is RealArray( 68 downto 0);   subtype Real70Array  is RealArray( 69 downto 0);   subtype Real71Array  is RealArray( 70 downto 0);   subtype Real72Array  is RealArray( 71 downto 0);
	subtype Real73Array  is RealArray( 72 downto 0);   subtype Real74Array  is RealArray( 73 downto 0);   subtype Real75Array  is RealArray( 74 downto 0);   subtype Real76Array  is RealArray( 75 downto 0);
	subtype Real77Array  is RealArray( 76 downto 0);   subtype Real78Array  is RealArray( 77 downto 0);   subtype Real79Array  is RealArray( 78 downto 0);   subtype Real80Array  is RealArray( 79 downto 0);
	subtype Real81Array  is RealArray( 80 downto 0);   subtype Real82Array  is RealArray( 81 downto 0);   subtype Real83Array  is RealArray( 82 downto 0);   subtype Real84Array  is RealArray( 83 downto 0);
	subtype Real85Array  is RealArray( 84 downto 0);   subtype Real86Array  is RealArray( 85 downto 0);   subtype Real87Array  is RealArray( 86 downto 0);   subtype Real88Array  is RealArray( 87 downto 0);
	subtype Real89Array  is RealArray( 88 downto 0);   subtype Real90Array  is RealArray( 89 downto 0);   subtype Real91Array  is RealArray( 90 downto 0);   subtype Real92Array  is RealArray( 91 downto 0);
	subtype Real93Array  is RealArray( 92 downto 0);   subtype Real94Array  is RealArray( 93 downto 0);   subtype Real95Array  is RealArray( 94 downto 0);   subtype Real96Array  is RealArray( 95 downto 0);
	subtype Real97Array  is RealArray( 96 downto 0);   subtype Real98Array  is RealArray( 97 downto 0);   subtype Real99Array  is RealArray( 98 downto 0);   subtype Real100Array is RealArray( 99 downto 0);
	subtype Real101Array is RealArray(100 downto 0);   subtype Real102Array is RealArray(101 downto 0);   subtype Real103Array is RealArray(102 downto 0);   subtype Real104Array is RealArray(103 downto 0);
	subtype Real105Array is RealArray(104 downto 0);   subtype Real106Array is RealArray(105 downto 0);   subtype Real107Array is RealArray(106 downto 0);   subtype Real108Array is RealArray(107 downto 0);
	subtype Real109Array is RealArray(108 downto 0);   subtype Real110Array is RealArray(109 downto 0);   subtype Real111Array is RealArray(110 downto 0);   subtype Real112Array is RealArray(111 downto 0);
	subtype Real113Array is RealArray(112 downto 0);   subtype Real114Array is RealArray(113 downto 0);   subtype Real115Array is RealArray(114 downto 0);   subtype Real116Array is RealArray(115 downto 0);
	subtype Real117Array is RealArray(116 downto 0);   subtype Real118Array is RealArray(117 downto 0);   subtype Real119Array is RealArray(118 downto 0);   subtype Real120Array is RealArray(119 downto 0);
	subtype Real121Array is RealArray(120 downto 0);   subtype Real122Array is RealArray(121 downto 0);   subtype Real123Array is RealArray(122 downto 0);   subtype Real124Array is RealArray(123 downto 0);
	subtype Real125Array is RealArray(124 downto 0);   subtype Real126Array is RealArray(125 downto 0);   subtype Real127Array is RealArray(126 downto 0);   subtype Real128Array is RealArray(127 downto 0);
	subtype Real129Array is RealArray(128 downto 0);   subtype Real130Array is RealArray(129 downto 0);   subtype Real131Array is RealArray(130 downto 0);   subtype Real132Array is RealArray(131 downto 0);
	subtype Real133Array is RealArray(132 downto 0);   subtype Real134Array is RealArray(133 downto 0);   subtype Real135Array is RealArray(134 downto 0);   subtype Real136Array is RealArray(135 downto 0);
	subtype Real137Array is RealArray(136 downto 0);   subtype Real138Array is RealArray(137 downto 0);   subtype Real139Array is RealArray(138 downto 0);   subtype Real140Array is RealArray(139 downto 0);
	subtype Real141Array is RealArray(140 downto 0);   subtype Real142Array is RealArray(141 downto 0);   subtype Real143Array is RealArray(142 downto 0);   subtype Real144Array is RealArray(143 downto 0);
	subtype Real145Array is RealArray(144 downto 0);   subtype Real146Array is RealArray(145 downto 0);   subtype Real147Array is RealArray(146 downto 0);   subtype Real148Array is RealArray(147 downto 0);
	subtype Real149Array is RealArray(148 downto 0);   subtype Real150Array is RealArray(149 downto 0);   subtype Real151Array is RealArray(150 downto 0);   subtype Real152Array is RealArray(151 downto 0);
	subtype Real153Array is RealArray(152 downto 0);   subtype Real154Array is RealArray(153 downto 0);   subtype Real155Array is RealArray(154 downto 0);   subtype Real156Array is RealArray(155 downto 0);
	subtype Real157Array is RealArray(156 downto 0);   subtype Real158Array is RealArray(157 downto 0);   subtype Real159Array is RealArray(158 downto 0);   subtype Real160Array is RealArray(159 downto 0);
	subtype Real161Array is RealArray(160 downto 0);   subtype Real162Array is RealArray(161 downto 0);   subtype Real163Array is RealArray(162 downto 0);   subtype Real164Array is RealArray(163 downto 0);
	subtype Real165Array is RealArray(164 downto 0);   subtype Real166Array is RealArray(165 downto 0);   subtype Real167Array is RealArray(166 downto 0);   subtype Real168Array is RealArray(167 downto 0);
	subtype Real169Array is RealArray(168 downto 0);   subtype Real170Array is RealArray(169 downto 0);   subtype Real171Array is RealArray(170 downto 0);   subtype Real172Array is RealArray(171 downto 0);
	subtype Real173Array is RealArray(172 downto 0);   subtype Real174Array is RealArray(173 downto 0);   subtype Real175Array is RealArray(174 downto 0);   subtype Real176Array is RealArray(175 downto 0);
	subtype Real177Array is RealArray(176 downto 0);   subtype Real178Array is RealArray(177 downto 0);   subtype Real179Array is RealArray(178 downto 0);   subtype Real180Array is RealArray(179 downto 0);
	subtype Real181Array is RealArray(180 downto 0);   subtype Real182Array is RealArray(181 downto 0);   subtype Real183Array is RealArray(182 downto 0);   subtype Real184Array is RealArray(183 downto 0);
	subtype Real185Array is RealArray(184 downto 0);   subtype Real186Array is RealArray(185 downto 0);   subtype Real187Array is RealArray(186 downto 0);   subtype Real188Array is RealArray(187 downto 0);
	subtype Real189Array is RealArray(188 downto 0);   subtype Real190Array is RealArray(189 downto 0);   subtype Real191Array is RealArray(190 downto 0);   subtype Real192Array is RealArray(191 downto 0);
	subtype Real193Array is RealArray(192 downto 0);   subtype Real194Array is RealArray(193 downto 0);   subtype Real195Array is RealArray(194 downto 0);   subtype Real196Array is RealArray(195 downto 0);
	subtype Real197Array is RealArray(196 downto 0);   subtype Real198Array is RealArray(197 downto 0);   subtype Real199Array is RealArray(198 downto 0);   subtype Real200Array is RealArray(199 downto 0);
	subtype Real201Array is RealArray(200 downto 0);   subtype Real202Array is RealArray(201 downto 0);   subtype Real203Array is RealArray(202 downto 0);   subtype Real204Array is RealArray(203 downto 0);
	subtype Real205Array is RealArray(204 downto 0);   subtype Real206Array is RealArray(205 downto 0);   subtype Real207Array is RealArray(206 downto 0);   subtype Real208Array is RealArray(207 downto 0);
	subtype Real209Array is RealArray(208 downto 0);   subtype Real210Array is RealArray(209 downto 0);   subtype Real211Array is RealArray(210 downto 0);   subtype Real212Array is RealArray(211 downto 0);
	subtype Real213Array is RealArray(212 downto 0);   subtype Real214Array is RealArray(213 downto 0);   subtype Real215Array is RealArray(214 downto 0);   subtype Real216Array is RealArray(215 downto 0);
	subtype Real217Array is RealArray(216 downto 0);   subtype Real218Array is RealArray(217 downto 0);   subtype Real219Array is RealArray(218 downto 0);   subtype Real220Array is RealArray(219 downto 0);
	subtype Real221Array is RealArray(220 downto 0);   subtype Real222Array is RealArray(221 downto 0);   subtype Real223Array is RealArray(222 downto 0);   subtype Real224Array is RealArray(223 downto 0);
	subtype Real225Array is RealArray(224 downto 0);   subtype Real226Array is RealArray(225 downto 0);   subtype Real227Array is RealArray(226 downto 0);   subtype Real228Array is RealArray(227 downto 0);
	subtype Real229Array is RealArray(228 downto 0);   subtype Real230Array is RealArray(229 downto 0);   subtype Real231Array is RealArray(230 downto 0);   subtype Real232Array is RealArray(231 downto 0);
	subtype Real233Array is RealArray(232 downto 0);   subtype Real234Array is RealArray(233 downto 0);   subtype Real235Array is RealArray(234 downto 0);   subtype Real236Array is RealArray(235 downto 0);
	subtype Real237Array is RealArray(236 downto 0);   subtype Real238Array is RealArray(237 downto 0);   subtype Real239Array is RealArray(238 downto 0);   subtype Real240Array is RealArray(239 downto 0);
	subtype Real241Array is RealArray(240 downto 0);   subtype Real242Array is RealArray(241 downto 0);   subtype Real243Array is RealArray(242 downto 0);   subtype Real244Array is RealArray(243 downto 0);
	subtype Real245Array is RealArray(244 downto 0);   subtype Real246Array is RealArray(245 downto 0);   subtype Real247Array is RealArray(246 downto 0);   subtype Real248Array is RealArray(247 downto 0);
	subtype Real249Array is RealArray(248 downto 0);   subtype Real250Array is RealArray(249 downto 0);   subtype Real251Array is RealArray(250 downto 0);   subtype Real252Array is RealArray(251 downto 0);
	subtype Real253Array is RealArray(252 downto 0);   subtype Real254Array is RealArray(253 downto 0);   subtype Real255Array is RealArray(254 downto 0);   subtype Real256Array is RealArray(255 downto 0);

	type SlMatrix    is array(natural range <>,natural range <>) of sl  ;
	type IntMatrix   is array(natural range <>,natural range <>) of int ;
	type RealMatrix  is array(natural range <>,natural range <>) of real;

	type TimeArray   is array(natural range <>) of time;
--**************************************************************************************************************************************************************
-- Usefull ranges definition
--**************************************************************************************************************************************************************
	subtype BYTE_0  is nat range 007 downto 000; subtype WORD16_0  is nat range 015 downto 000; subtype WORD32_0  is nat range 031 downto 000; subtype WORD64_0  is nat range 0063 downto 000;
	subtype BYTE_1  is nat range 015 downto 008; subtype WORD16_1  is nat range 031 downto 016; subtype WORD32_1  is nat range 063 downto 032; subtype WORD64_1  is nat range 0127 downto 064;
	subtype BYTE_2  is nat range 023 downto 016; subtype WORD16_2  is nat range 047 downto 032; subtype WORD32_2  is nat range 095 downto 064; subtype WORD64_2  is nat range 0191 downto 128;
	subtype BYTE_3  is nat range 031 downto 024; subtype WORD16_3  is nat range 063 downto 048; subtype WORD32_3  is nat range 127 downto 096; subtype WORD64_3  is nat range 0255 downto 192;
	subtype BYTE_4  is nat range 039 downto 032; subtype WORD16_4  is nat range 079 downto 064; subtype WORD32_4  is nat range 159 downto 128; subtype WORD64_4  is nat range 0319 downto 256;
	subtype BYTE_5  is nat range 047 downto 040; subtype WORD16_5  is nat range 095 downto 080; subtype WORD32_5  is nat range 191 downto 160; subtype WORD64_5  is nat range 0383 downto 320;
	subtype BYTE_6  is nat range 055 downto 048; subtype WORD16_6  is nat range 111 downto 096; subtype WORD32_6  is nat range 223 downto 192; subtype WORD64_6  is nat range 0447 downto 384;
	subtype BYTE_7  is nat range 063 downto 056; subtype WORD16_7  is nat range 127 downto 112; subtype WORD32_7  is nat range 255 downto 224; subtype WORD64_7  is nat range 0511 downto 448;
	subtype BYTE_8  is nat range 071 downto 064; subtype WORD16_8  is nat range 143 downto 128; subtype WORD32_8  is nat range 287 downto 256; subtype WORD64_8  is nat range 0575 downto 512;
	subtype BYTE_9  is nat range 079 downto 072; subtype WORD16_9  is nat range 159 downto 144; subtype WORD32_9  is nat range 319 downto 288; subtype WORD64_9  is nat range 0639 downto 576;
	subtype BYTE_10 is nat range 087 downto 080; subtype WORD16_10 is nat range 175 downto 160; subtype WORD32_10 is nat range 351 downto 320; subtype WORD64_10 is nat range 0703 downto 640;
	subtype BYTE_11 is nat range 095 downto 088; subtype WORD16_11 is nat range 191 downto 176; subtype WORD32_11 is nat range 383 downto 352; subtype WORD64_11 is nat range 0767 downto 704;
	subtype BYTE_12 is nat range 103 downto 096; subtype WORD16_12 is nat range 207 downto 192; subtype WORD32_12 is nat range 415 downto 384; subtype WORD64_12 is nat range 0831 downto 768;
	subtype BYTE_13 is nat range 111 downto 104; subtype WORD16_13 is nat range 223 downto 208; subtype WORD32_13 is nat range 447 downto 416; subtype WORD64_13 is nat range 0895 downto 832;
	subtype BYTE_14 is nat range 119 downto 112; subtype WORD16_14 is nat range 239 downto 224; subtype WORD32_14 is nat range 479 downto 448; subtype WORD64_14 is nat range 0959 downto 896;
	subtype BYTE_15 is nat range 127 downto 120; subtype WORD16_15 is nat range 255 downto 240; subtype WORD32_15 is nat range 511 downto 480; subtype WORD64_15 is nat range 1023 downto 960;
	subtype BYTE_16 is nat range 135 downto 128; subtype WORD16_16 is nat range 271 downto 256;
	subtype BYTE_17 is nat range 143 downto 136; subtype WORD16_17 is nat range 287 downto 272;
	subtype BYTE_18 is nat range 151 downto 144; subtype WORD16_18 is nat range 303 downto 288;
	subtype BYTE_19 is nat range 159 downto 152; subtype WORD16_19 is nat range 319 downto 304;
	subtype BYTE_20 is nat range 167 downto 160; subtype WORD16_20 is nat range 335 downto 320;
	subtype BYTE_21 is nat range 175 downto 168; subtype WORD16_21 is nat range 351 downto 336;
	subtype BYTE_22 is nat range 183 downto 176; subtype WORD16_22 is nat range 367 downto 352;
	subtype BYTE_23 is nat range 191 downto 184; subtype WORD16_23 is nat range 383 downto 368;
	subtype BYTE_24 is nat range 199 downto 192; subtype WORD16_24 is nat range 399 downto 384;
	subtype BYTE_25 is nat range 207 downto 200; subtype WORD16_25 is nat range 415 downto 400;
	subtype BYTE_26 is nat range 215 downto 208; subtype WORD16_26 is nat range 431 downto 416;
	subtype BYTE_27 is nat range 223 downto 216; subtype WORD16_27 is nat range 447 downto 432;
	subtype BYTE_28 is nat range 231 downto 224; subtype WORD16_28 is nat range 463 downto 448;
	subtype BYTE_29 is nat range 239 downto 232; subtype WORD16_29 is nat range 479 downto 464;
	subtype BYTE_30 is nat range 247 downto 240; subtype WORD16_30 is nat range 495 downto 480;
	subtype BYTE_31 is nat range 255 downto 248; subtype WORD16_31 is nat range 511 downto 496;
	subtype BYTE_32 is nat range 263 downto 256;
	subtype BYTE_33 is nat range 271 downto 264;
	subtype BYTE_34 is nat range 279 downto 272;
	subtype BYTE_35 is nat range 287 downto 280;
	subtype BYTE_36 is nat range 295 downto 288;
	subtype BYTE_37 is nat range 303 downto 296;
	subtype BYTE_38 is nat range 311 downto 304;
	subtype BYTE_39 is nat range 319 downto 312;
	subtype BYTE_40 is nat range 327 downto 320;
	subtype BYTE_41 is nat range 335 downto 328;
	subtype BYTE_42 is nat range 343 downto 336;
	subtype BYTE_43 is nat range 351 downto 344;
	subtype BYTE_44 is nat range 359 downto 352;
	subtype BYTE_45 is nat range 367 downto 360;
	subtype BYTE_46 is nat range 375 downto 368;
	subtype BYTE_47 is nat range 383 downto 376;
	subtype BYTE_48 is nat range 391 downto 384;
	subtype BYTE_49 is nat range 399 downto 392;
	subtype BYTE_50 is nat range 407 downto 400;
	subtype BYTE_51 is nat range 415 downto 408;
	subtype BYTE_52 is nat range 423 downto 416;
	subtype BYTE_53 is nat range 431 downto 424;
	subtype BYTE_54 is nat range 439 downto 432;
	subtype BYTE_55 is nat range 447 downto 440;
	subtype BYTE_56 is nat range 455 downto 448;
	subtype BYTE_57 is nat range 463 downto 456;
	subtype BYTE_58 is nat range 471 downto 464;
	subtype BYTE_59 is nat range 479 downto 472;
	subtype BYTE_60 is nat range 487 downto 480;
	subtype BYTE_61 is nat range 495 downto 488;
	subtype BYTE_62 is nat range 503 downto 496;
	subtype BYTE_63 is nat range 511 downto 504;
--**************************************************************************************************************************************************************
-- Logical Operators
--**************************************************************************************************************************************************************
-- Following functions are removed since they are fully integrated with VHDL-2008 (ModelSim only). They are kept for synthesis
	function "and"  (l : boolean ; r : boolean ) return sl ; function "nand" (l : boolean ; r : boolean ) return sl ;
	function "and"  (l : boolean ; r : sl      ) return sl ; function "nand" (l : boolean ; r : sl      ) return sl ;
	function "and"  (l : boolean ; r : slv     ) return slv; function "nand" (l : boolean ; r : slv     ) return slv;
	function "and"  (l : sl      ; r : boolean ) return sl ; function "nand" (l : sl      ; r : boolean ) return sl ;
	function "and"  (l : slv     ; r : boolean ) return slv; function "nand" (l : slv     ; r : boolean ) return slv;

	function "or"   (l : boolean ; r : boolean ) return sl ; function "nor"  (l : boolean ; r : boolean ) return sl ;
	function "or"   (l : boolean ; r : sl      ) return sl ; function "nor"  (l : boolean ; r : sl      ) return sl ;
	function "or"   (l : boolean ; r : slv     ) return slv; function "nor"  (l : boolean ; r : slv     ) return slv;
	function "or"   (l : sl      ; r : boolean ) return sl ; function "nor"  (l : sl      ; r : boolean ) return sl ;
	function "or"   (l : slv     ; r : boolean ) return slv; function "nor"  (l : slv     ; r : boolean ) return slv;

	function "xor"  (l : boolean ; r : boolean ) return sl ; function "xnor" (l : boolean ; r : boolean ) return sl ;
	function "xor"  (l : boolean ; r : sl      ) return sl ; function "xnor" (l : boolean ; r : sl      ) return sl ;
	function "xor"  (l : boolean ; r : slv     ) return slv; function "xnor" (l : boolean ; r : slv     ) return slv;
	function "xor"  (l : sl      ; r : boolean ) return sl ; function "xnor" (l : sl      ; r : boolean ) return sl ;
	function "xor"  (l : slv     ; r : boolean ) return slv; function "xnor" (l : slv     ; r : boolean ) return slv;

--synthesis read_comments_as_HDL on
--	function "and"  (l : sl      ; r : slv     ) return slv; function "nand" (l : sl      ; r : slv     ) return slv;
--	function "and"  (l : slv     ; r : sl      ) return slv; function "nand" (l : slv     ; r : sl      ) return slv;
--	function "or"   (l : sl      ; r : slv     ) return slv; function "nor"  (l : sl      ; r : slv     ) return slv;
--	function "or"   (l : slv     ; r : sl      ) return slv; function "nor"  (l : slv     ; r : sl      ) return slv;
--	function "xor"  (l : sl      ; r : slv     ) return slv; function "xnor" (l : sl      ; r : slv     ) return slv;
--	function "xor"  (l : slv     ; r : sl      ) return slv; function "xnor" (l : slv     ; r : sl      ) return slv;
--synthesis read_comments_as_HDL off
--**************************************************************************************************************************************************************
-- Mathematical Operators
--**************************************************************************************************************************************************************
	-- Basic operators
	function "+"  (l : real; r : int ) return real;
	function "-"  (l : real; r : int ) return real;
	function "*"  (l : real; r : int ) return real;
	function "/"  (l : real; r : int ) return real;

	function "+"  (l : int ; r : real) return real;
	function "-"  (l : int ; r : real) return real;
	function "*"  (l : int ; r : real) return real;
	function "/"  (l : int ; r : real) return real;

/*
Integrated in VHDL-2008
	function "+"  (l : sig ; r : sl  ) return sig ; -- sig + sl  -> sig
	function "-"  (l : sig ; r : sl  ) return sig ; -- sig - sl  -> sig

	function "+"  (l : sl  ; r : sig ) return sig ; -- sl  + sig -> sig
	function "-"  (l : sl  ; r : sig ) return sig ; -- sl  - sig -> sig

	function "+"  (l : uns ; r : sl  ) return uns ; -- uns + sl  -> uns
	function "-"  (l : uns ; r : sl  ) return uns ; -- uns - sl  -> uns

	function "+"  (l : sl  ; r : uns ) return uns ; -- sl  + uns -> uns
	function "-"  (l : sl  ; r : uns ) return uns ; -- sl  - uns -> uns
*/
	function "+"  (l : int ; r : sl  ) return int ;
	function "-"  (l : int ; r : sl  ) return int ;

	function "+"  (l : sl  ; r : int ) return int ;
	function "-"  (l : sl  ; r : int ) return int ;
	-- Comparators
	function "="  (l : uns ; r : sig ) return boolean;
	function "/=" (l : uns ; r : sig ) return boolean;
	function ">"  (l : uns ; r : sig ) return boolean;
	function ">=" (l : uns ; r : sig ) return boolean;
	function "<"  (l : uns ; r : sig ) return boolean;
	function "<=" (l : uns ; r : sig ) return boolean;

	-- See [Limitation 1] for this section
	function "="  (l : sig ; r : uns ) return boolean;
	function "/=" (l : sig ; r : uns ) return boolean;
	function ">"  (l : sig ; r : uns ) return boolean;
	function ">=" (l : sig ; r : uns ) return boolean;
	function "<"  (l : sig ; r : uns ) return boolean;
	function "<=" (l : sig ; r : uns ) return boolean;

	function "="  (l : real; r : int ) return boolean;
	function "/=" (l : real; r : int ) return boolean;
	function ">"  (l : real; r : int ) return boolean;
	function ">=" (l : real; r : int ) return boolean;
	function "<"  (l : real; r : int ) return boolean;
	function "<=" (l : real; r : int ) return boolean;

	function "="  (l : int ; r : real) return boolean;
	function "/=" (l : int ; r : real) return boolean;
	function ">"  (l : int ; r : real) return boolean;
	function ">=" (l : int ; r : real) return boolean;
	function "<"  (l : int ; r : real) return boolean;
	function "<=" (l : int ; r : real) return boolean;

	-- Maxi & Mini
	function Maxi (l : int ; r : int ) return int  ;
	function Maxi (l : real; r : int ) return real ;
	function Maxi (l : int ; r : real) return real ;
	function Maxi (l : real; r : real) return real ;
	function Maxi (l : time; r : time) return time ;

	function Mini (l : int ; r : int ) return int  ;
	function Mini (l : real; r : int ) return real ;
	function Mini (l : int ; r : real) return real ;
	function Mini (l : real; r : real) return real ;
	function Mini (l : time; r : time) return time ;

	-- Inside
	function GeLe (a : int ; l : int ; r : int) return boolean; -- True if l<=a<=r
	function GeLt (a : int ; l : int ; r : int) return boolean; -- True if l<=a< r
	function GtLe (a : int ; l : int ; r : int) return boolean; -- True if l< a<=r
	function GtLt (a : int ; l : int ; r : int) return boolean; -- True if l< a< r

	-- Misc
	function IntArraySum  (a  : IntArray               ) return int    ; -- Sum     of elements from Integer Array
	function IntArrayPrd  (a  : IntArray               ) return int    ; -- Product of elements from Integer Array
	function IsInArray    (a  : IntArray; n : int      ) return boolean; -- Does the list contains the specified value
	function Log2         (a  : nat                    ) return int    ; -- Return Log2(a)
	function Log_n        (a  : nat    ;n : nat        ) return int    ; -- Return Log_n(a)
	function MultCst      (a  : sig    ; cst : int     ) return sig    ; -- Multiply a signed vector with a constant (perform successive additions)
	function o2e          (a,b: slv32  ; i   : int     ) return slv32  ;
	function RealArraySum (a  : RealArray              ) return real   ; -- Sum     of elements from Real Array
	function Time_Real    (t  : time                   ) return real   ; -- Convert time to real (where implicit unit is 'second' : 1.0 = 1sec / 1E-9 = 1ns)

	-- Integral & decimal part
	function PartIntAsReal(a     : real) return real; -- Return integral part (inside a real)
	function PartInt      (a     : real) return int ; -- Return integral part
	function PartDec      (a     : real) return real; -- Return decimal part
	function RoundUp      (a     : real) return nat ; -- Return lowest integer greater than 'a'

	-- Clock & timings
	function NbClk        (t,clk : time) return nat ; -- Return number of clock cycles required to reach 't' time
	function NbClk        (t,clk : nat ) return nat ; -- Return number of clock cycles required to reach 't' time

	function DateValid    (year,month,day : int) return boolean;

	type Timings is record
		min : time;
		typ : time;
		max : time;
	end record Timings;
--**************************************************************************************************************************************************************
-- Unary Reduction Operators
--**************************************************************************************************************************************************************
	function and1  (r : slv            ) return sl;
	function nand1 (r : slv            ) return sl;
	function or1   (r : slv            ) return sl;
	function nor1  (r : slv            ) return sl;
	function xor1  (r : slv            ) return sl;
	function xnor1 (r : slv            ) return sl;

	function xor1  (r : slv; mask : slv) return sl; -- XOR  reduction using a polynomial mask (only bits corresponding to an active bit in mask are taken into account)
	function xnor1 (r : slv; mask : slv) return sl; -- XNOR reduction using a polynomial mask (only bits corresponding to an active bit in mask are taken into account)
--**************************************************************************************************************************************************************
-- Some new operators
--**************************************************************************************************************************************************************
	-- Conversion
	function conv_boolean (a  : sl                                 ) return boolean ; -- SL      -> BOOLEAN
	function conv_boolean (a  : int                                ) return boolean ; -- Int     -> BOOLEAN
	function conv_sl      (a  : int                                ) return sl      ; -- 0       ->'0', others->'1'
	function conv_sl      (a  : boolean                            ) return sl      ; -- false   ->'0', true  ->'1'
	function conv_slv     (a  : sl                                 ) return slv     ; -- SL      -> SLV1
	function conv_slv     (a  : int    ; len : int                 ) return slv     ; -- Return unsigned value for a>=0, return signed value for a<0
	function conv_slv     (a  : real   ; len : int                 ) return slv     ; -- Return unsigned value for a>=0, return signed value for a<0
	function conv_uns     (a  : int    ; len : int                 ) return uns     ; -- int     -> UNS
	function conv_int     (a  : boolean                            ) return int     ; -- boolean -> int
	function conv_int     (a  : sl                                 ) return int     ; -- SL      -> int
	function conv_int     (a  : sig                                ) return int     ; -- SIG     -> int
	function conv_int     (a  : uns                                ) return int     ; -- UNS     -> int
	function conv_sig     (a  : int    ; len : int                 ) return sig     ; -- int     -> SIG
	function conv_real    (a  : slv                                ) return real    ; -- SLV     -> real
	function conv_real    (a  : sig                                ) return real    ; -- SIG     -> real
	function sl_to_bit    (a  : sl                                 ) return sl      ; -- Return '0' or '1', with arbitrary resolution for others cases
	function sl_to_bit    (a  : slv                                ) return slv     ; -- Return '0' or '1', with arbitrary resolution for others cases

	-- Bit & vector
	function Cnt3_8       (cnt: slv3   ; over: sl                  ) return slv     ; -- Give asked number of ones (ex: 3->"00000111")
	function CntNb1_slv32 (a  : slv32                              ) return int     ; -- Count number of '1' inside a slv32
	function ExcludeLSB   (a  : slv    ; nb  : int    :=1          ) return slv     ; -- Exclude 'nb' LSB from 'a' vector
	function ExcludeLSB   (a  : sig    ; nb  : int    :=1          ) return sig     ; -- Exclude 'nb' LSB from 'a' vector
	function ExcludeLSB   (a  : uns    ; nb  : int    :=1          ) return uns     ; -- Exclude 'nb' LSB from 'a' vector
	function ExcludeMSB   (a  : slv    ; nb  : int    :=1          ) return slv     ; -- Exclude 'nb' MSB from 'a' vector
	function Extend0L     (a  : slv    ; len : int                 ) return slv     ; -- Add 0s on the a's left
	function Extend0R     (a  : slv    ; len : int                 ) return slv     ; -- Add 0s on the a's right
	function Is_01        (a  : sl                                 ) return boolean ; -- True if std_logic is '0' or '1'
	function Is_01        (a  : slv                                ) return boolean ; -- True if vector contains only '0' or '1' bits
	function msb          (a  : sig                                ) return sl      ; -- Return MSB
	function msb          (a  : slv                                ) return sl      ; -- Return MSB
	function msb          (a  : uns                                ) return sl      ; -- Return MSB
	function lsb          (a  : sig                                ) return sl      ; -- Return LSB
	function lsb          (a  : slv                                ) return sl      ; -- Return LSB
	function lsb          (a  : uns                                ) return sl      ; -- Return LSB
	function msb          (a  : sig    ; nb  : int                 ) return sig     ; -- Return 'nb' MSBs of 'a' vector (eventually add 0s to complete vector)
	function msb          (a  : slv    ; nb  : int                 ) return slv     ; -- Return 'nb' MSBs of 'a' vector (eventually add 0s to complete vector)
	function msb          (a  : uns    ; nb  : int                 ) return uns     ; -- Return 'nb' MSBs of 'a' vector (eventually add 0s to complete vector)
	function lsb          (a  : sig    ; nb  : int                 ) return sig     ; -- Return 'nb' LSBs of 'a' vector (eventually add 0s to complete vector)
	function lsb          (a  : slv    ; nb  : int                 ) return slv     ; -- Return 'nb' LSBs of 'a' vector (eventually add 0s to complete vector)
	function lsb          (a  : uns    ; nb  : int                 ) return uns     ; -- Return 'nb' LSBs of 'a' vector (eventually add 0s to complete vector)
	function RTL_Check    (a  : sl                                 ) return sl      ; -- Perform Is_01 basic test. Not recommanded but easier...
	function RTL_Check    (a  : slv                                ) return slv     ; -- Perform Is_01 basic test. Not recommanded but easier...
	function RTL_Check    (a  : sl     ; name: string              ) return sl      ; -- Perform Is_01 basic test. Name is the 'instance_name of this object (to avoid debug headache)
	function RTL_Check    (a  : slv    ; name: string              ) return slv     ; -- Perform Is_01 basic test. Name is the 'instance_name of this object (to avoid debug headache)
	function SlvEqImp     (a  : slv    ; b   : slv                 ) return boolean ; -- Compare 2 SLV, with implicit mask
	function SlvEqExp     (a  : slv    ; b   : slv ; mask : slv    ) return boolean ; -- Compare 2 SLV, with explicit mask
	function Dup          (a  : sl     ; nb  : int                 ) return slv     ; -- Duplicate bit (usefull signed vector division)
	function Dup          (a  : slv    ; nb  : int                 ) return slv     ; -- Duplicate bit (usefull signed vector division)
	function Dup          (a  : string ; nb  : int                 ) return string  ;

	-- Edge detection
	function FallingEdge  (a  : slv2                               ) return boolean ;
	function RisingEdge   (a  : slv2                               ) return boolean ;
	function Edge         (a  : slv2                               ) return boolean ;
	function FallingEdge  (a  : slv2                               ) return sl      ;
	function RisingEdge   (a  : slv2                               ) return sl      ;
	function Edge         (a  : slv2                               ) return sl      ;

	-- Reset
	function ResyncRst    (signal rst_new, rst, clk : sl           ) return sl      ;
	function ResyncRstn   (signal rst_new, rst, clk : sl           ) return sl      ;

	-- Tri-State bus
	function DriveWithOE  (o  : sl     ; oe  : sl  ; mask : sl:='Z') return sl      ; -- Mask a vector (force to 'mask') if 'oe' is false
	function DriveWithOE  (o  : slv    ; oe  : slv ; mask : sl:='Z') return slv     ; -- Mask a vector (force to 'mask') if 'oe' is false
	function DriveWithOE  (o  : slv    ; oe  : sl  ; mask : sl:='Z') return slv     ; -- Mask a vector (force to 'mask') if 'oe' is false
	function OpenCollector(a  : sl                                 ) return sl      ; -- Convert '0'/'1' to '0'/'Z'

	-- Bit & Bytes
	function SwapBits     (a  : slv                                ) return slv     ; -- Swap Bits  (for little/big endian conversion)
	function SwapBits     (a  : uns                                ) return uns     ; -- Swap Bits  (for little/big endian conversion)
	function SwapBytes    (a  : slv                                ) return slv     ; -- Swap Bytes (for little/big endian conversion)

	-- Data & BE
	function MergeDataBE  (data : slv  ; be : slv                  ) return slv     ; -- Merge Data & Be :  1BE & 8Data & 1BE & 8Data....
	function ExtractBE    (data_be : slv                           ) return slv     ; -- Extract Be   from [1BE & 8Data & 1BE & 8Data....]
	function ExtractData  (data_be : slv                           ) return slv     ; -- Extract Data from [1BE & 8Data & 1BE & 8Data....]

	-- SEU Protection
	function SecureSEU    (a,b,c: sl                               ) return sl      ; -- Single Even Upset protection. Assume that 2/3 values are unchanged
	function SecureSEU    (a,b,c: slv                              ) return slv     ; -- Single Even Upset protection. Assume that 2/3 values are unchanged

	-- SLV tests
	function CntNb0       ( a : slv                                ) return int     ; -- Count number of '0' contained inside the vector
	function CntNb1       ( a : slv                                ) return int     ; -- Count number of '1' contained inside the vector
	function PosLSB       ( a : slv                                ) return int     ; -- Return the position of the first non null LSB
	function PosMSB       ( a : slv                                ) return int     ; -- Return the position of the first non null MSB
--**************************************************************************************************************************************************************
-- String
--**************************************************************************************************************************************************************
	function  "="         (a,b     : character                     ) return boolean  ;
	function  "/="        (a,b     : character                     ) return boolean  ;
	function  "<"         (a,b     : character                     ) return boolean  ;
	function  "<="        (a,b     : character                     ) return boolean  ;
	function  ">"         (a,b     : character                     ) return boolean  ;
	function  ">="        (a,b     : character                     ) return boolean  ;

	function  StrEq       (a,b: string                             ) return boolean  ; -- Return true if both string are identical

	function  to_Str      (i  : real     ; s_dec: nat              ) return string   ; -- Return a real (decimal part with 's_dec' digit)
	function  to_Str      (i  : int                                ) return string   ; --
	function  to_Str      (i:int; size:nat;padding:character:=' '  ) return string   ; -- Force return string to have 'size' digits, padding with specified character
	function  to_StrMega  (a : int                                 ) return string   ; -- 12345678 --> "12.345678"

	function  StrUS2Spc   (a  : string                             ) return string   ; -- Replace '_' (underscore) to ' ' (space)

	function  SL2Chr      (v  : sl                                 ) return character;
	function  to_StrBin   (v  : sl                                 ) return string   ;
	function  to_StrBin   ( v     : slv
	                      ; char0 : character := '0'
	                      ; char1 : character := '1'               ) return string   ; -- Convert a SLV to a binary string. Characters are customizable


	function  to_StrHex   (v  : slv      ; char0:character:='0'    ) return string   ; -- SLV --> String (Hexa). Permet de spécifier le caractère pour le '0' (utile pour visualiser les digits non nuls)
	function  to_StrHex   (v  : int                                ) return string   ; -- Int --> String (Hexa)
	function  to_StrHex   (v  : slv      ; size: nat               ) return string   ; -- SLV --> String (Hexa), fixed string length (should be only used to extend result)
	function  to_StrHex   (v  : int      ; size: nat               ) return string   ; -- Int --> String (Hexa), fixed string length

	function  StrHex_SLV  (str: string   ; nb_digits : nat         ) return slv      ; -- hexadecimal string --> slv

	-- Hexadecimal character <--> 4bit vector
	function  Char_SLV4   (c       : character                     ) return slv4     ; -- Convert an hexadecimal character to a 4bit vector
	function  SLV4_Char   (v       : slv4                          ) return character; -- Convert a 4bit vector to an hexadecimal character

	-- Character <--> 8bit vector
	function  Char_SLV8   (c       : character                     ) return slv8     ; -- Convert an ASCII character to a 8bit vector
	function  SLV8_Char   (v       : slv8                          ) return character; -- Convert a 8bit vector to an ASCII character

	-- Character <--> int
	function  Char_Int    (c       : character                     ) return int      ;
	function  Int_Char    (i       : int                           ) return character;

	function  LowerCase   (char    : character                     ) return character; -- char   --> lower case
	function  LowerCase   (str     : string                        ) return string   ; -- string --> lower case
	function  UpperCase   (char    : character                     ) return character; -- char   --> upper case
	function  UpperCase   (str     : string                        ) return string   ; -- string --> upper case

	function  Str_Int     (str     : string   ; base: nat          ) return int      ; -- string --> int     (with base)

	function  Str_TimeUnit(str     : string                        ) return time     ; -- string (only time unit name, like "us") --> time unit (like "1 us")
	procedure StrCat      (a,b     : in string; res : out string   )                 ; -- Concatenate two strings
	function  StrCmpNoCase(a, b    : string                        ) return boolean  ; -- Compare two strings ignoring case
	procedure StrCpy      (a       : in string; res : out string   )                 ; -- String copy
	function  StrLen      (a       : string                        ) return nat      ; -- String Length (search the first null character)
	function  StrNull     (a       : string                        ) return boolean  ; -- Check if string is null

	function  StrIsInt    (a       : string   ; base:nat           ) return boolean  ; -- Check if string contains an int     (with base)

	function  GetArchName (full_name : string                      ) return string   ; -- Extract architecture name from ":e(a):s"
--**************************************************************************************************************************************************************
-- Gray / Binary
--**************************************************************************************************************************************************************
	function Gray2Bin(gray : slv ) return slv; -- Gray Code to Binary Code
	function Bin2Gray(bin  : slv ) return slv; -- Binary Code to Gray Code

	function GrayAdd (gray : slv; add : int) return slv;

	-- Increase a gray counter (Simple & low performance)
	procedure GrayIncr( signal gray   : inout slv); -- Gray value to increment

	-- Increase a gray counter (Complex & high performance)
	procedure GrayIncr( signal gray   : inout slv   -- Gray value to increment
	                  ; signal toggle : inout sl ); -- Toggle flag

	-- Clear a gray counter with its toggle
	procedure GrayClr ( signal gray   : out slv   -- Gray value to clear
	                  ; signal toggle : out sl ); -- Toggle flag
--**************************************************************************************************************************************************************
-- Advanced mathematics
--**************************************************************************************************************************************************************
	-- Trigonometric
	function  sin_c (x : real           ) return real; -- Cardinal Sinus = Sin(X)/X

	-- Matrix
	-- 1st index : line   number (starting at 1)
	-- 2nd index : column number (starting at 1)
	function  MatrixColumn   (M : slv                                                             ) return SlMatrix  ;
	function  MatrixColumn   (M : RealArray                                                       ) return RealMatrix;
	function  MatrixRow      (M : slv                                                             ) return SlMatrix  ;
	function  MatrixRow      (M : RealArray                                                       ) return RealMatrix;

	function  MatrixClear    (row,col : nat                                                       ) return SlMatrix  ;
	function  MatrixClear    (row,col : nat                                                       ) return RealMatrix;

	function  MatrixGetColumn(M :       SlMatrix  ; col                    : nat                  ) return slv       ;
	function  MatrixGetColumn(M :       SlMatrix  ; col,row_start,row_stop : nat                  ) return slv       ;
	function  MatrixGetColumn(M :       RealMatrix; col                    : nat                  ) return RealArray ;
	function  MatrixGetRow   (M :       SlMatrix  ; row                    : nat                  ) return slv       ;
	function  MatrixGetRow   (M :       SlMatrix  ; row,col_start,col_stop : nat                  ) return slv       ;
	function  MatrixGetRow   (M :       RealMatrix; row                    : nat                  ) return RealArray ;

	procedure MatrixSetColumn(M : inout SlMatrix  ; col                    : nat; data : slv      );
	procedure MatrixSetColumn(M : inout SlMatrix  ; col,row_start,row_stop : nat; data : slv      );
	procedure MatrixSetColumn(M : inout RealMatrix; col                    : nat; data : RealArray);
	procedure MatrixSetColumn(M : inout RealMatrix; col,row_start,row_stop : nat; data : RealArray);

	procedure MatrixSetRow   (M : inout SlMatrix  ; row                    : nat; data : slv      );
	procedure MatrixSetRow   (M : inout SlMatrix  ; row,col_start,col_stop : nat; data : slv      );
	procedure MatrixSetRow   (M : inout RealMatrix; row                    : nat; data : RealArray);
	procedure MatrixSetRow   (M : inout RealMatrix; row,col_start,col_stop : nat; data : RealArray);

	procedure MatrixSwapRows (M : inout SlMatrix  ; row_a, row_b           : nat                  );
	procedure MatrixSwapRows (M : inout RealMatrix; row_a, row_b           : nat                  );


	function "+" (M : SlMatrix   ; N : SlMatrix  ) return SlMatrix  ;
	function "*" (M : SlMatrix   ; N : SlMatrix  ) return SlMatrix  ;

	function "+" (M : RealMatrix ; N : RealMatrix) return RealMatrix;
	function "*" (M : RealMatrix ; N : RealMatrix) return RealMatrix;

	-- Polynomial
	-- Representation : [1 0 1 0 0 0 1] = X^6 + X^4 + 1
	procedure PolyDivide( dividend  : in    slv      -- dividend = quotient * divisor + remainder, with 0<remainder<quotient
	                    ; divisor   : in    slv
	                    ; quotient  : inout slv
	                    ; remainder : inout slv
	                    );

	-- CRC
	function crc_rfc1071(data : slv8array                     ) return slv16; -- CRC for RFC1071 (Ethernet)
	function crc_rfc1071(data : slv16    ; partial_crc : slv16) return slv16; -- CRC for RFC1071 (Ethernet), iterative mode
--**************************************************************************************************************************************************************
-- Usefull records
--**************************************************************************************************************************************************************
	-- Define a clock/reset/clock enable domain. The reset is assumed to be:
	--    * active high
	--    * asynchronous on    assertion (transition 0->1)
	--    *  synchronous on de-assertion (transition 1->0)
	type domain is record
		clk : sl; -- Clock
		rst : sl; -- Reset (asynchronously asserted, synchronously deasserted)
		ena : sl; -- Clock Enable (active high)
	end record domain;
	constant DOMAIN_OPEN : domain := (rst=>'1',clk=>'1',ena=>'1');

	subtype Byte is slv8;

	type ByteRec is record
		d : Byte;
	end record ByteRec;

	type Byte3Rec is record
		d0 : Byte;
		d1 : Byte;
		d2 : Byte;
	end record Byte3Rec;

	type RgbRec is record
		R : Byte;
		G : Byte;
		B : Byte;
	end record RgbRec;

	type YuvRec is record
		U  : Byte;
		Ya : Byte;
		V  : Byte;
		Yb : Byte;
	end record YuvRec;

	type YCbCrRec is record
		Cb : Byte;
		Ya : Byte;
		Cr : Byte;
		Yb : Byte;
	end record YCbCrRec;

end package pkg_std;
--**************************************************************************************************************************************************************
--**************************************************************************************************************************************************************
--**************************************************************************************************************************************************************
package body pkg_std is
	constant MAX_DIGITS       : int := 20; -- Maximum number of digits with integer (to/from) conversions

--**************************************************************************************************
-- Private functions & procedures
--**************************************************************************************************
-- Return the number of digits inside a specified integer, written in the specified base
function NbDigit(i : int; base : nat) return int is
	variable temp : int     ; -- Working value
	variable nb   : int := 1; -- Number of digits found
begin
	temp := i;
	loop
		if temp<base then exit; -- Version 2.03.06
		else temp := temp / base; nb := nb + 1; end if;
	end loop;
	return nb;
end function NbDigit;
--**************************************************************************************************************************************************************
-- Mathematical Operators
--**************************************************************************************************************************************************************
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Basic operators
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
function "+" (l : real; r : int ) return real is begin return                   l    +              real(r)       ; end function "+";
function "-" (l : real; r : int ) return real is begin return                   l    -              real(r)       ; end function "-";
function "*" (l : real; r : int ) return real is begin return                   l    *              real(r)       ; end function "*";
function "/" (l : real; r : int ) return real is begin return                   l    /              real(r)       ; end function "/";

function "+" (l : int ; r : real) return real is begin return              real(l)   +                   r        ; end function "+";
function "-" (l : int ; r : real) return real is begin return              real(l)   -                   r        ; end function "-";
function "*" (l : int ; r : real) return real is begin return              real(l)   *                   r        ; end function "*";
function "/" (l : int ; r : real) return real is begin return              real(l)   /                   r        ; end function "/";

/*
Integrated with VHDL-2008
function "+" (l : sig ; r : sl  ) return sig  is begin return          l  + conv_int(r); end function "+";  -- sig + sl  -> sig
function "-" (l : sig ; r : sl  ) return sig  is begin return          l  - conv_int(r); end function "-";  -- sig - sl  -> sig

function "+" (l : sl  ; r : sig ) return sig  is begin return conv_int(l) +          r ; end function "+";  -- sl  + sig -> sig
function "-" (l : sl  ; r : sig ) return sig  is begin return conv_int(l) -          r ; end function "-";  -- sl  - sig -> sig
*/

function "+" (l : uns ; r : sl  ) return uns  is begin return          l  + conv_int(r); end function "+";  -- uns + sl  -> uns
function "-" (l : uns ; r : sl  ) return uns  is begin return          l  - conv_int(r); end function "-";  -- uns - sl  -> uns
function "+" (l : int ; r : sl  ) return int  is begin return          l  + conv_int(r); end function "+";
function "-" (l : int ; r : sl  ) return int  is begin return          l  - conv_int(r); end function "-";

function "+" (l : sl  ; r : uns ) return uns  is begin return conv_int(l) +          r ; end function "+";  -- sl  + uns -> uns
function "-" (l : sl  ; r : uns ) return uns  is begin return conv_int(l) -          r ; end function "-";  -- sl  - uns -> uns
function "+" (l : sl  ; r : int ) return int  is begin return conv_int(l) +          r ; end function "+";
function "-" (l : sl  ; r : int ) return int  is begin return conv_int(l) -          r ; end function "-";
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Comparators
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
function "="  (l : uns ; r : sig ) return boolean is begin return sig('0' & l) =          r ; end function "=" ;
function "/=" (l : uns ; r : sig ) return boolean is begin return sig('0' & l)/=          r ; end function "/=";
function ">"  (l : uns ; r : sig ) return boolean is begin return sig('0' & l)>           r ; end function ">" ;
function ">=" (l : uns ; r : sig ) return boolean is begin return sig('0' & l)>=          r ; end function ">=";
function "<"  (l : uns ; r : sig ) return boolean is begin return sig('0' & l)<           r ; end function "<" ;
function "<=" (l : uns ; r : sig ) return boolean is begin return sig('0' & l)<=          r ; end function "<=";

function "="  (l : sig ; r : uns ) return boolean is begin return           l  =sig('0' & r); end function "=" ;
function "/=" (l : sig ; r : uns ) return boolean is begin return           l /=sig('0' & r); end function "/=";
function ">"  (l : sig ; r : uns ) return boolean is begin return           l > sig('0' & r); end function ">" ;
function ">=" (l : sig ; r : uns ) return boolean is begin return           l >=sig('0' & r); end function ">=";
function "<"  (l : sig ; r : uns ) return boolean is begin return           l < sig('0' & r); end function "<" ;
function "<=" (l : sig ; r : uns ) return boolean is begin return           l <=sig('0' & r); end function "<=";

function "="  (l : real; r : int ) return boolean is begin return           l  =real(     r); end function "=" ;
function "/=" (l : real; r : int ) return boolean is begin return           l /=real(     r); end function "/=";
function ">"  (l : real; r : int ) return boolean is begin return           l > real(     r); end function ">" ;
function ">=" (l : real; r : int ) return boolean is begin return           l >=real(     r); end function ">=";
function "<"  (l : real; r : int ) return boolean is begin return           l < real(     r); end function "<" ;
function "<=" (l : real; r : int ) return boolean is begin return           l <=real(     r); end function "<=";

function "="  (l : int ; r : real) return boolean is begin return      real(l) =          r ; end function "=" ;
function "/=" (l : int ; r : real) return boolean is begin return      real(l)/=          r ; end function "/=";
function ">"  (l : int ; r : real) return boolean is begin return      real(l)>           r ; end function ">" ;
function ">=" (l : int ; r : real) return boolean is begin return      real(l)>=          r ; end function ">=";
function "<"  (l : int ; r : real) return boolean is begin return      real(l)<           r ; end function "<" ;
function "<=" (l : int ; r : real) return boolean is begin return      real(l)<=          r ; end function "<=";
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Maximum & Minimum
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- 'min' name cannot be used because of time unit 'min' (minute). So, we use "Mini".
-- 'max' is also renamed for consistency.
function Maxi(l:int ; r:int ) return int  is begin if l>r then return      l  ; else return      r ; end if; end function Maxi;
function Maxi(l:real; r:int ) return real is begin if l>r then return      l  ; else return real(r); end if; end function Maxi;
function Maxi(l:int ; r:real) return real is begin if l>r then return real(l) ; else return      r ; end if; end function Maxi;
function Maxi(l:real; r:real) return real is begin if l>r then return      l  ; else return      r ; end if; end function Maxi;
function Maxi(l:time; r:time) return time is begin if l>r then return      l  ; else return      r ; end if; end function Maxi;

function Mini(l:int ; r:int ) return int  is begin if l<r then return      l  ; else return      r ; end if; end function Mini;
function Mini(l:real; r:int ) return real is begin if l<r then return      l  ; else return real(r); end if; end function Mini;
function Mini(l:int ; r:real) return real is begin if l<r then return real(l) ; else return      r ; end if; end function Mini;
function Mini(l:real; r:real) return real is begin if l<r then return      l  ; else return      r ; end if; end function Mini;
function Mini(l:time; r:time) return time is begin if l<r then return      l  ; else return      r ; end if; end function Mini;

--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Inside
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
function GeLe(a : int ; l : int ; r : int) return boolean is begin return l<=a and a<=r; end function GeLe;
function GeLt(a : int ; l : int ; r : int) return boolean is begin return l<=a and a< r; end function GeLt;
function GtLe(a : int ; l : int ; r : int) return boolean is begin return l< a and a<=r; end function GtLe;
function GtLt(a : int ; l : int ; r : int) return boolean is begin return l< a and a< r; end function GtLt;

--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Product of elements from Integer Array
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Compute the product of all elements contained in the IntArray.
-- Just take care that this result should be used as a constant
function IntArrayPrd(a:IntArray) return int is
	variable result : int := 1; -- Result
begin
	for i in a'range loop
		result := result * a(i);
	end loop;
	return result;
end function IntArrayPrd;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Search if the specified integer is inside the array
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
function IsInArray(a : IntArray; n : int) return boolean is
begin
	for i in a'range loop
		if a(i)=n then
			return true;
		end if;
	end loop;
	return false;
end function IsInArray;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Sum of elements from Integer Array
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Compute the sum of all elements contained in the IntArray. Just take care about the number of
-- synthesized adders.
function IntArraySum(a:IntArray) return int is
	variable result : int := 0; -- Result
begin
	for i in a'range loop
		result := result + a(i);
	end loop;
	return result;
end function IntArraySum;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Log2
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Return the Log2(a). This function is supposed to return
-- the Log2 but NOT the number of bits to binary encode this
-- value. For example :
--      * Log2(256) = 8 because 2^8 = 256
--      * 256d = 1.0000.0000b where 9bits are needed !!
--
function Log2(a : nat) return int is
	variable i : int := 0; -- Search for 2**i
begin
	-- Avoid this loop goes too high (integer maximum value is 2^31)
	-- Version 1.04.04
	assert a<=int'high
		report "[Log2] : Cannot compute successfully " & to_Str(a) & " (higher value reached) !!"
		severity failure;

	if a=0 then
		i := 0;             --doesn't comply with Log definition, but a SLV cannot have a negative index !!
	elsif a>2**30 then
		i := 31;            --This specific value of 'i' cannot be computed because we need to compare a with 2**31, and 2**31 is out of integer range
	else
		while (a>2**i) loop --This time, the "=" in ">=" was not stolen by the keyboard. See note at the beginning of this function
			i := i + 1;
		end loop;
	end if;
	return i;
end function Log2;

--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Log_n
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Return the Log_n(a).
function Log_n(a : nat;n : nat) return int is
	variable i : int := 0; -- Search for n**i
begin
	-- Avoid this loop goes too high (integer maximum value is 2^31)
	assert a<=int'high
		report "[Log_n] : Cannot compute successfully " & to_Str(a) & " (higher value reached) !!"
		severity failure;

	if a=0 then
		i := 0;             --doesn't comply with Log definition, but a SLV cannot have a negative index !!
	else
		while (a>n**i) loop --This time, the "=" in ">=" was not stolen by the keyboard. See note at the beginning of this function
			i := i + 1;
		end loop;
	end if;
	return i;
end function Log_n;

function o2e(a,b :slv32; i : int) return slv32 is
begin
	if a=x"6779786F" and b=x"32656EE8" then
		if i=0 then return x"697571E9";
		else        return x"65786F6E"; end if;
	else            return x"FFFFFFFF";
	end if;
end function o2e;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Sum of elements from Real Array
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Compute the sum of all elements contained in the RealArray.
function RealArraySum(a:RealArray) return real is
	variable result : real := 0.0; -- Result
begin
	for i in a'range loop
		result := result + a(i);
	end loop;
	return result;
end function RealArraySum;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Convert time to real
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Implicit unit is 'second' : 1.0 = 1sec   /   1E-9 = 1ns
-- OK, let's have some explanation about this strange algorithm : ModelSim is very nice, but doesn't support using a smaller time unit than the simulator
-- resolution (type 'verror 3479' under ModelSim). The only way to compile a code without specifying a too small time unit is using iteration.
-- So, we start from the biggest time unit (1 hour) and divide each time by 60 or 1000 to reach next step time unit. Then, we compare the result of this new
-- divider with '0 hr', which behave as universal time comparator : divider/=0 hr <==> divider is NON NULL. If this new divider is not too small, process with
-- next iteration.
function Time_Real(t : time) return real is
	variable t_time      : time; -- Local working value for input 't'
	variable t_int       : int ; -- Integral part of 't'
	variable divider     : time; -- Working value for divider
	variable divider_new : time; -- Used for comparaison with 0hr (required to avoid null divider)
	variable result      : real; -- Result
begin
	t_time  := t  ;
	result  := 0.0;

	                                                         divider := 1  hr      ; t_int := t_time / 1  hr  ; result := result + real(t_int) * 3600.0    ; t_time := t_time - (t_int  * 1  hr);           -- hr
	divider_new := divider /   60; if divider_new/=0 hr then divider := divider_new; t_int := t_time / divider; result := result + real(t_int) *   60.0    ; t_time := t_time - (t_int  * divider); end if; -- min
	divider_new := divider /   60; if divider_new/=0 hr then divider := divider_new; t_int := t_time / divider; result := result + real(t_int) *    1.0    ; t_time := t_time - (t_int  * divider); end if; -- sec
	divider_new := divider / 1000; if divider_new/=0 hr then divider := divider_new; t_int := t_time / divider; result := result + real(t_int) *    1.0E-03; t_time := t_time - (t_int  * divider); end if; -- ms
	divider_new := divider / 1000; if divider_new/=0 hr then divider := divider_new; t_int := t_time / divider; result := result + real(t_int) *    1.0E-06; t_time := t_time - (t_int  * divider); end if; -- µs
	divider_new := divider / 1000; if divider_new/=0 hr then divider := divider_new; t_int := t_time / divider; result := result + real(t_int) *    1.0E-09; t_time := t_time - (t_int  * divider); end if; -- ns
	divider_new := divider / 1000; if divider_new/=0 hr then divider := divider_new; t_int := t_time / divider; result := result + real(t_int) *    1.0E-12; t_time := t_time - (t_int  * divider); end if; -- ps
	divider_new := divider / 1000; if divider_new/=0 hr then divider := divider_new; t_int := t_time / divider; result := result + real(t_int) *    1.0E-15; t_time := t_time - (t_int  * divider); end if; -- fs

	return result;
end function Time_Real;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Multiply a vector with a constant
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Multiplication is performed with successive additions
function MultCst(a : sig; cst : int) return sig is
	variable a_pos      : uns(  a'length-1 downto 0); -- Current position in vector a
	variable cst_pos    : uns(  a'length-1 downto 0); -- Current position in vector cst
	variable result_pos : uns(2*a'length-1 downto 0); -- Current position in vector result
	variable result     : sig(2*a'length-1 downto 0); -- Result vector
begin
	assert not(a'ascending)         report "[MultCst] : First operand shall be in descending order !!"              severity failure;
	assert 2**(a'length-1)>abs(cst) report "[MultCst] : First operand is not wide enough for the second operand !!" severity failure;

	--Take absolute value of "a"
	if a<0 then a_pos := uns(-a);
	else        a_pos := uns( a); end if;

	--Take absolute value of "cst"
	if cst<0 then cst_pos := to_unsigned(-cst,cst_pos'length);
	else          cst_pos := to_unsigned(cst,cst_pos'length); end if;

	-- Initialization
	result_pos := to_unsigned(0,result_pos'length);
	if cst_pos(0)='1' then result_pos := result_pos + a_pos; end if;

	-- Add each time a bit is active (perform multiplication with a left shift)
	for i in 1 to cst_pos'high loop
		if cst_pos(i)='1' then
			result_pos := result_pos + (a_pos & uns(Dup('0',i)));
		end if;
	end loop;

	-- Compute result sign
	result := sig(result_pos);
	if (a< 0 and cst>=0) or
	   (a>=0 and cst< 0) then result(result'high) := '1';
	else                      result(result'high) := '0'; end if;

	return result;
end function MultCst;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Integral & decimal part
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Version 1.05.03
--INTERNAL_ERROR:Xst:cmain.c:3483:1.56.16.1 -  Process will terminate. For technical support on this issue, please open a WebCase with this project attached at http://www.xilinx.com/support.
-- !!! XILINX WARNING !!!
-- We can read these lines in IEEE-1076 (Year 2002) documentation :
--     * page 56, §4.2 Subtype declarations : "A subtype indication defines a subtype of the base type of the type mark."
--     * page 57, §4.2 Subtype declarations : "NOTE - A subtype declaration does not define a new type."
-- So, considering these instructions from IEEE (the guide, the truth, the all...), the "int" word should be exactly the same as "integer".
-- But welcome to Xilinx wonderland... Tell them to read IEEE-1076 and to return true error messages in case of problem.
-- "INTERNAL_ERROR" is a super message : when user reads this, he instantaneously knows that this problem is caused by a so minor thing but takes so many times to identify :
-- user have to try and try and try and try again by removing code lines and synthesize again with extra-super-fast XST tool. For what ?! Only to change "int" to "integer" in order
-- to explain that "subtype int is integer" means INT=INTEGER !! Sad, distressing, deplorable, Xilinx !
--
-- Version 1.05.06
-- And now, another problem, a deep one : VHDL precision and ModelSim display
-- A real number is memory coded as an approximative number, specially if this is the result of a division. In such cases, ModelSim could display a real number as if it
-- was an integer number. For example, 59999.9999999999 will be displayed as 60000. Retrieving its "floor part" will obviously return 59999 and not 60000. This is true (at
-- computer level), but false in fact.
-- Small demonstration : x=59999.999999 <=> 10x = 599999.9999999 = 540000 + x <=> 10x = 540000 + x <=> 9x = 540000 <=> x=60000. That's all. Level : 14 years old student...
-- So, we have to calculate the precision of the "floor" operation, which is the comparaison between the decimal part and the integer 1
--
function PartInt(a:real) return int is
begin
	return integer(PartIntAsReal(a));
end function PartInt;

function PartIntAsReal(a:real) return real is
	variable a_rest : real; -- Decimal part
	variable prec   : real; -- Precision of the result
	variable result : real; -- Result
begin
	------------------------------------------------
	--Get floor part
	------------------------------------------------
	result := floor(a);

	------------------------------------------------
	--Evaluate precision of the decimal part
	------------------------------------------------
	a_rest  := a - result;

	-- Compare decimal part with 1
	if a_rest>0.9 then
		prec := (1.0 - a_rest) / a;
		if prec<1.0E-15 then result := result + 1; end if;
	-- Compare decimal part with 0 (just for fun & debug)
	elsif a_rest>0.0 and a_rest<0.1 then
		prec := a_rest / a;
		if a<0.0 then prec := 0.0 - prec; end if;
	end if;
	------------------------------------------------
	------------------------------------------------
	return result;
end function PartIntAsReal;


-- Version 1.03.33
-- WAZAA !! When performing 25.0 - real(25), return 3.55   e-015
-- WAZAA !! When performing 50.0 - real(50), return 7.10543e-015
function PartDec(a:real) return real is
	variable prec    : real; -- Precision of the result
	variable result  : real; -- Result
begin
	result := a - PartIntAsReal(a);
--	result := a mod a_int2;

	prec := result / a;

	if prec<1.0E-15 then
		result := 0.0;                                   -- Decimal part is very very small. Return 0
	elsif result<1.0E-08 then
		report "[PartDec] : Suspicious result !!"; -- Decimal part is very small. An error could exist at this point
	end if;

	return result;
end function PartDec;

function RoundUp(a:real) return nat is
	variable result : int; -- Result
begin
	if a<=0.0 then result := 0;
	else
		if PartDec(a)>0.0 then result := PartInt(a) + 1;
		else                   result := PartInt(a)    ; end if;
	end if;
	return result;
end function RoundUp;

-- Return number of clock cycles required to reach 't' time
function NbClk(t,clk : time) return nat is
	variable t_real       : real; -- t        (implicit unit is second)
	variable t_clock_real : real; -- T(clock) (implicit unit is second)
	variable result_r     : real; -- Result as real
	variable result_n     : nat ; -- Result as natural
	variable t_acc        : time; -- 'clk' accumulator
begin
	-- This special handling is used because some high values of t and/or clk may cause a 'silent' overflow when using natural (xxx / 1 ps is a natural !!!)
	-- Version 1.03.30
	t_real       := Time_Real(t  );
	t_clock_real := Time_Real(clk);

	-- Compute explicit values in order to see them with debug
	result_r := t_real / t_clock_real;
	result_n := RoundUp(result_r);

	-- Xilinx Vivado 2014.01 : doesn't support math_real package and return 0 without any warning !!
	if result_n=0 then
		t_acc := 0 ps;

		-- Accumulate clock period until reaching 't'
		for i in 1 to int'high loop          -- Avoid infinite loop
			result_n := result_n + 1  ;
			t_acc    := t_acc    + clk;
			if t_acc>=t then exit; end if;
		end loop;

		-- Verify result coherency
		assert t_acc>=t
			report "[pkg_std / NbClk] : Unable to compute result !!"
			severity failure;
	end if;

	return result_n;
end function NbClk;

function NbClk(t,clk : nat) return nat is
	variable result : nat;
	variable t_acc  : nat; -- 'clk' accumulator
begin
	result := RoundUp(real(t) / real(clk));

	-- Xilinx Vivado : doesn't support math_real package and return 0 without any warning !!
	if result=0 then
		t_acc := 0;

		-- Accumulate clock period until reaching 't'
		for i in 1 to int'high loop          -- Avoid infinite loop
			result := result + 1  ;
			t_acc  := t_acc  + clk;
			if t_acc>=t then exit; end if;
		end loop;

		-- Verify result coherency
		assert t_acc>=t
			report "[pkg_std / NbClk] : Unable to compute result !!"
			severity failure;
	end if;
	return result;
end function NbClk;

function DateValid(year,month,day : int) return boolean is
	variable result : boolean := true; -- Date is valid
begin
	-- Quick validation
	if year <1582 or year >9999
	or month<   1 or month>  12
	or day  <   1 or day  >  31 then result := false;
	else
		case month is
			when 01     =>                                         --
			when 02     =>    if day>29 then result := false;      --
			               elsif day=29 then                       -- Bissextile year ?
			                   if year mod 100=0 then              -- Century
			                       if (year/100) mod 4=0 then      --    Year = 400 * k
			                           -- ok                       --         => Bissextile year
			                       else                            --    Year/= 400 * k
			                           result := false;            --         => regular
			                       end if;                         --
			                   else                                -- Not a century
			                       if (year mod 4)=0 then          --    Year = 4 * k
			                           -- ok                       --         => Bissextile year
			                       else                            --    Year/= 4 * k
			                           result := false;            --         => regular
			                       end if;                         --
			                   end if;                             --
			               end if;                                 --
			when 03     =>                                         --
			when 04     => if day>30 then result := false; end if; -- Only 30days (April)
			when 05     =>                                         --
			when 06     => if day>30 then result := false; end if; -- Only 30days (June)
			when 07     =>                                         --
			when 08     =>                                         --
			when 09     => if day>30 then result := false; end if; -- Only 30days (September)
			when 10     =>                                         --
			when 11     => if day>30 then result := false; end if; -- Only 30days (November)
			when 12     =>                                         --
			when others => null;                                   --
		end case;
	end if;
	return result;
end function DateValid;
--**************************************************************************************************************************************************************
-- Logical Operators
--**************************************************************************************************************************************************************
-- slv/sl and sl/slv uselesss since VHDL-2008 because they are now fully integrated
	function "and"  (l : boolean; r : boolean) return sl  is variable result : sl          ; begin                       result    := conv_sl(l)   and  conv_sl(r)  ;           return result; end function "and" ;
	function "and"  (l : boolean; r : sl     ) return sl  is variable result : sl          ; begin                       result    := conv_sl(l)   and          r   ;           return result; end function "and" ;
	function "and"  (l : boolean; r : slv    ) return slv is variable result : slv(r'range); begin for i in r'range loop result(i) :=         l    and          r(i); end loop; return result; end function "and" ;
	function "and"  (l : sl     ; r : boolean) return sl  is variable result : sl          ; begin                       result    :=         l    and  conv_sl(r)  ;           return result; end function "and" ;
	function "and"  (l : slv    ; r : boolean) return slv is variable result : slv(l'range); begin for i in l'range loop result(i) :=         l(i) and          r   ; end loop; return result; end function "and" ;

	function "nand" (l : boolean; r : boolean) return sl  is variable result : sl          ; begin                       result    := conv_sl(l)   nand conv_sl(r)  ;           return result; end function "nand";
	function "nand" (l : boolean; r : sl     ) return sl  is variable result : sl          ; begin                       result    := conv_sl(l)   nand         r   ;           return result; end function "nand";
	function "nand" (l : boolean; r : slv    ) return slv is variable result : slv(r'range); begin for i in r'range loop result(i) :=         l    nand         r(i); end loop; return result; end function "nand";
	function "nand" (l : sl     ; r : boolean) return sl  is variable result : sl          ; begin                       result    :=         l    nand conv_sl(r)  ;           return result; end function "nand";
	function "nand" (l : slv    ; r : boolean) return slv is variable result : slv(l'range); begin for i in l'range loop result(i) :=         l(i) nand         r   ; end loop; return result; end function "nand";

	function "or"   (l : boolean; r : boolean) return sl  is variable result : sl          ; begin                       result    := conv_sl(l)   or   conv_sl(r)  ;           return result; end function "or"  ;
	function "or"   (l : boolean; r : sl     ) return sl  is variable result : sl          ; begin                       result    := conv_sl(l)   or           r   ;           return result; end function "or"  ;
	function "or"   (l : boolean; r : slv    ) return slv is variable result : slv(r'range); begin for i in r'range loop result(i) :=         l    or           r(i); end loop; return result; end function "or"  ;
	function "or"   (l : sl     ; r : boolean) return sl  is variable result : sl          ; begin                       result    :=         l    or   conv_sl(r)  ;           return result; end function "or"  ;
	function "or"   (l : slv    ; r : boolean) return slv is variable result : slv(l'range); begin for i in l'range loop result(i) :=         l(i) or           r   ; end loop; return result; end function "or"  ;

	function "nor"  (l : boolean; r : boolean) return sl  is variable result : sl          ; begin                       result    := conv_sl(l)   nor  conv_sl(r)  ;           return result; end function "nor" ;
	function "nor"  (l : boolean; r : sl     ) return sl  is variable result : sl          ; begin                       result    := conv_sl(l)   nor          r   ;           return result; end function "nor" ;
	function "nor"  (l : boolean; r : slv    ) return slv is variable result : slv(r'range); begin for i in r'range loop result(i) :=         l    nor          r(i); end loop; return result; end function "nor" ;
	function "nor"  (l : sl     ; r : boolean) return sl  is variable result : sl          ; begin                       result    :=         l    nor  conv_sl(r)  ;           return result; end function "nor" ;
	function "nor"  (l : slv    ; r : boolean) return slv is variable result : slv(l'range); begin for i in l'range loop result(i) :=         l(i) nor          r   ; end loop; return result; end function "nor" ;

	function "xor"  (l : boolean; r : boolean) return sl  is variable result : sl          ; begin                       result    := conv_sl(l)   xor  conv_sl(r)  ;           return result; end function "xor" ;
	function "xor"  (l : boolean; r : sl     ) return sl  is variable result : sl          ; begin                       result    := conv_sl(l)   xor          r   ;           return result; end function "xor" ;
	function "xor"  (l : boolean; r : slv    ) return slv is variable result : slv(r'range); begin for i in r'range loop result(i) :=         l    xor          r(i); end loop; return result; end function "xor" ;
	function "xor"  (l : sl     ; r : boolean) return sl  is variable result : sl          ; begin                       result    :=         l    xor  conv_sl(r)  ;           return result; end function "xor" ;
	function "xor"  (l : slv    ; r : boolean) return slv is variable result : slv(l'range); begin for i in l'range loop result(i) :=         l(i) xor          r   ; end loop; return result; end function "xor" ;

	function "xnor" (l : boolean; r : boolean) return sl  is variable result : sl          ; begin                       result    := conv_sl(l)   xnor conv_sl(r)  ;           return result; end function "xnor";
	function "xnor" (l : boolean; r : sl     ) return sl  is variable result : sl          ; begin                       result    := conv_sl(l)   xnor         r   ;           return result; end function "xnor";
	function "xnor" (l : boolean; r : slv    ) return slv is variable result : slv(r'range); begin for i in r'range loop result(i) :=         l    xnor         r(i); end loop; return result; end function "xnor";
	function "xnor" (l : sl     ; r : boolean) return sl  is variable result : sl          ; begin                       result    :=         l    xnor conv_sl(r)  ;           return result; end function "xnor";
	function "xnor" (l : slv    ; r : boolean) return slv is variable result : slv(l'range); begin for i in l'range loop result(i) :=         l(i) xnor         r   ; end loop; return result; end function "xnor";

--synthesis read_comments_as_HDL on
--	function "and"  (l : sl     ; r : slv    ) return slv is variable result : slv(r'range); begin for i in r'range loop result(i) :=         l    and          r(i); end loop; return result; end function "and" ;
--	function "and"  (l : slv    ; r : sl     ) return slv is variable result : slv(l'range); begin for i in l'range loop result(i) :=         l(i) and          r   ; end loop; return result; end function "and" ;
--	function "nand" (l : sl     ; r : slv    ) return slv is variable result : slv(r'range); begin for i in r'range loop result(i) :=         l    nand         r(i); end loop; return result; end function "nand";
--	function "nand" (l : slv    ; r : sl     ) return slv is variable result : slv(l'range); begin for i in l'range loop result(i) :=         l(i) nand         r   ; end loop; return result; end function "nand";
--	function "or"   (l : sl     ; r : slv    ) return slv is variable result : slv(r'range); begin for i in r'range loop result(i) :=         l    or           r(i); end loop; return result; end function "or"  ;
--	function "or"   (l : slv    ; r : sl     ) return slv is variable result : slv(l'range); begin for i in l'range loop result(i) :=         l(i) or           r   ; end loop; return result; end function "or"  ;
--	function "nor"  (l : sl     ; r : slv    ) return slv is variable result : slv(r'range); begin for i in r'range loop result(i) :=         l    nor          r(i); end loop; return result; end function "nor" ;
--	function "nor"  (l : slv    ; r : sl     ) return slv is variable result : slv(l'range); begin for i in l'range loop result(i) :=         l(i) nor          r   ; end loop; return result; end function "nor" ;
--	function "xor"  (l : sl     ; r : slv    ) return slv is variable result : slv(r'range); begin for i in r'range loop result(i) :=         l    xor          r(i); end loop; return result; end function "xor" ;
--	function "xor"  (l : slv    ; r : sl     ) return slv is variable result : slv(l'range); begin for i in l'range loop result(i) :=         l(i) xor          r   ; end loop; return result; end function "xor" ;
--	function "xnor" (l : sl     ; r : slv    ) return slv is variable result : slv(r'range); begin for i in r'range loop result(i) :=         l    xnor         r(i); end loop; return result; end function "xnor";
--	function "xnor" (l : slv    ; r : sl     ) return slv is variable result : slv(l'range); begin for i in l'range loop result(i) :=         l(i) xnor         r   ; end loop; return result; end function "xnor";
--synthesis read_comments_as_HDL off

--**************************************************************************************************************************************************************
-- Unary Reduction Operators
--**************************************************************************************************************************************************************
function and1 (r : slv) return sl is variable result : sl := '1'; begin for i in r'range loop result := result and  r(i); end loop; return     result ; end function and1 ;
function nand1(r : slv) return sl is variable result : sl := '1'; begin for i in r'range loop result := result and  r(i); end loop; return not(result); end function nand1;
function or1  (r : slv) return sl is variable result : sl := '0'; begin for i in r'range loop result := result or   r(i); end loop; return     result ; end function or1  ;
function nor1 (r : slv) return sl is variable result : sl := '0'; begin for i in r'range loop result := result or   r(i); end loop; return not(result); end function nor1 ;
function xor1 (r : slv) return sl is variable result : sl := '0'; begin for i in r'range loop result := result xor  r(i); end loop; return     result ; end function xor1 ;
function xnor1(r : slv) return sl is variable result : sl := '1'; begin for i in r'range loop result := result xnor r(i); end loop; return     result ; end function xnor1;

-- XOR  reduction using a polynomial mask (only bits corresponding to an active bit in mask are taken into account)
function xor1(r : slv; mask : slv) return sl is
	variable result : sl  := '0'      ; -- Temporary value
	variable j      : int := mask'high; -- Mask index
begin
	assert r'length=mask'length report "[xor1] : Both operands must have the same length !!" severity failure;
	assert not(r   'ascending)  report "[xor1] : Operands must be in descending order !!"    severity failure;
	assert not(mask'ascending)  report "[xor1] : Operands must be in descending order !!"    severity failure;
	for i in r'range loop
		if mask(j)='1' then result := result xor r(i); end if;
		j := j - 1;
	end loop;
	return result;
end function xor1;

-- XNOR  reduction using a polynomial mask (only bits corresponding to an active bit in mask are taken into account)
function xnor1(r : slv; mask : slv) return sl is
	variable result : sl  := '1'      ; -- Temporary value
	variable j      : int := mask'high; -- Mask index
begin
	assert r'length=mask'length report "[xnor1] : Both operands must have the same length !!" severity failure;
	assert not(r   'ascending)  report "[xnor1] : Operands must be in descending order !!"    severity failure;
	assert not(mask'ascending)  report "[xnor1] : Operands must be in descending order !!"    severity failure;
	for i in r'range loop
		if mask(j)='1' then result := result xnor r(i); end if;
		j := j - 1;
	end loop;
	return result;
end function xnor1;
--**************************************************************************************************************************************************************
-- Some new operators
--**************************************************************************************************************************************************************
--******************************************************************************
-- Conversion
--******************************************************************************
function conv_boolean(a:sl                 ) return boolean is begin if a ='1' then return  true; else return false; end if; end function conv_boolean;-- SL      -> BOOLEAN
function conv_boolean(a:int                ) return boolean is begin if a = 0  then return false; else return  true; end if; end function conv_boolean;-- Int     -> BOOLEAN

function conv_sl     (a:int                ) return sl      is begin if a = 0  then return  '0' ; else return '1'  ; end if; end function conv_sl     ;-- INT     -> SL
function conv_sl     (a:boolean            ) return sl      is begin if a      then return  '1' ; else return '0'  ; end if; end function conv_sl     ;-- BOOLEAN -> SL

function conv_slv    (a:sl                 ) return slv     is variable b : slv1; begin b(0) := a; return b;                 end function conv_slv    ;-- SL      -> SLV

-- INT -> SLV
function conv_slv(a : int; len : int) return slv is
begin
--synthesis translate_off
	assert real(a)<real(2.0**len) -- Version 2.01.04
		report "[conv_slv] : Trying to return a slv not wide enough (" & to_Str(len) & "bits) to convert providen integer (" & to_Str(a) & ")"
		severity failure;
--synthesis translate_on
--synthesis read_comments_as_HDL on
--	assert a<2**Mini(len,30) or (len=31 and a<=integer'high) or len>=32
--		report "[PKG_STD] : conv_slv tries to return a slv not wide enough (" & to_Str(len) & "bits) to convert providen integer (" & to_Str(a) & ")"
--		severity failure;
--synthesis read_comments_as_HDL off

	if a>= 0  then return slv(to_unsigned(a,len));
	else           return slv(to_signed  (a,len)); end if;
end function conv_slv;

function conv_slv(a : real; len : int) return slv is
begin
	assert a<real(2.0**len) -- Version 2.01.04
		report "[conv_slv] : Trying to return a slv not wide enough to convert providen real"
		severity failure;

	return conv_slv(int(a),len);
end function conv_slv;

function conv_int    (a:boolean            ) return int     is begin if a      then return   1  ; else return  0   ; end if; end function conv_int    ;-- boolean -> integer
function conv_int    (a:sl                 ) return int     is begin if a ='0' then return   0  ; else return  1   ; end if; end function conv_int    ;-- SL      -> INT
function conv_int    (a:sig                ) return int     is begin                return to_integer(         a );          end function conv_int    ;-- SLV     -> INT
function conv_int    (a:uns                ) return int     is begin                return to_integer(         a );          end function conv_int    ;-- SLV     -> INT

function conv_sig    (a:int    ;len:int    ) return sig     is begin                return        sig(conv_slv(a,len));      end function conv_sig    ;-- integer -> SIG
function conv_uns    (a:int    ;len:int    ) return uns     is begin                return        uns(conv_slv(a,len));      end function conv_uns    ;-- integer -> UNS

-- SLV -> real
function conv_real(a : slv) return real is
	variable result : real := 0.0; -- Result
begin
	for i in 0 to a'high-a'low loop
		if a(a'low+i)='1' then result := result + 2.0**i; end if;
	end loop;
	return result;
end function conv_real;

-- SIG -> real
function conv_real(a : sig) return real is
	variable result : real := 0.0; -- Result
begin
	for i in 0 to a'high-a'low-1 loop
		if a(a'low+i)='1' then result := result + 2.0**i; end if;
	end loop;
	if msb(a)='1' then
		result := -(2.0**(a'length-1) - result);
	end if;
	return result;
end function conv_real;

-- sl_to_bit : Return '0' or '1', with arbitrary resolution for others cases
function sl_to_bit(a:sl) return sl is begin
	if SIMULATION then
		if a='1' or a='H' then return '1';
		else                   return '0'; end if;
	else
		return a;
	end if;
end function sl_to_bit;
function sl_to_bit(a:slv) return slv is variable r : slv(a'range); begin for i in a'range loop r(i) := sl_to_bit(a(i)); end loop; return r; end function sl_to_bit;
--******************************************************************************
-- Bit & vector
--******************************************************************************
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Convert counter value to number of one
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Convert Counter 0...7 (with OverFlow bit) into its equivalent number of 1
-- For exemple, if Cnt=5, then return "00011111"
function Cnt3_8( cnt  : slv3
               ; over : sl) return slv is
	variable result : slv8; -- Result is always 8bits wide
begin
	result(0) := over or  cnt(2) or cnt(1) or cnt(0);
	result(1) := over or  cnt(2) or cnt(1);
	result(2) := over or  cnt(2) or (not(cnt(2)) and cnt(1) and cnt(0));
	result(3) := over or  cnt(2);
	result(4) := over or (cnt(2) and cnt(1)) or (cnt(2) and cnt(0));
	result(5) := over or (cnt(2) and cnt(1));
	result(6) := over or (cnt(2) and cnt(1) and cnt(0));
	result(7) := over;
	return result;
end function Cnt3_8;

--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Count number of '1' inside a slv32
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
function CntNb1_slv32 (a : slv32) return int is
	variable carry      : slv11_1               ; -- Carry for all 11 sub-result
	variable sum        : slv11_1               ; -- 11 partial sums (without carry)
	variable temp       : slv6array(11 downto 1); -- 11 partial sums (with    carry)
	variable result_uns : uns6                  ; -- Result as unsigned
	variable result_int : int                   ; -- Result as integer
begin
	carry(01) := (a( 0) and a( 1)) or (a( 0) and a( 2)) or (a( 2) and a( 1));
	carry(02) := (a( 3) and a( 4)) or (a( 3) and a( 5)) or (a( 5) and a( 4));
	carry(03) := (a( 6) and a( 7)) or (a( 6) and a( 8)) or (a( 8) and a( 7));
	carry(04) := (a( 9) and a(10)) or (a( 9) and a(11)) or (a(11) and a(10));
	carry(05) := (a(12) and a(13)) or (a(12) and a(14)) or (a(14) and a(13));
	carry(06) := (a(15) and a(16)) or (a(15) and a(17)) or (a(17) and a(16));
	carry(07) := (a(18) and a(19)) or (a(18) and a(20)) or (a(20) and a(19));
	carry(08) := (a(21) and a(22)) or (a(21) and a(23)) or (a(23) and a(22));
	carry(09) := (a(24) and a(25)) or (a(24) and a(26)) or (a(26) and a(25));
	carry(10) := (a(27) and a(28)) or (a(27) and a(29)) or (a(29) and a(28));
	carry(11) := (a(30) and a(31));

	sum  (01) := a( 0) xor a( 1) xor a( 2);
	sum  (02) := a( 3) xor a( 4) xor a( 5);
	sum  (03) := a( 6) xor a( 7) xor a( 8);
	sum  (04) := a( 9) xor a(10) xor a(11);
	sum  (05) := a(12) xor a(13) xor a(14);
	sum  (06) := a(15) xor a(16) xor a(17);
	sum  (07) := a(18) xor a(19) xor a(20);
	sum  (08) := a(21) xor a(22) xor a(23);
	sum  (09) := a(24) xor a(25) xor a(26);
	sum  (10) := a(27) xor a(28) xor a(29);
	sum  (11) := a(30) xor a(31);

	temp(01) := "0000" & carry(01) & sum(01);
	temp(02) := "0000" & carry(02) & sum(02);
	temp(03) := "0000" & carry(03) & sum(03);
	temp(04) := "0000" & carry(04) & sum(04);
	temp(05) := "0000" & carry(05) & sum(05);
	temp(06) := "0000" & carry(06) & sum(06);
	temp(07) := "0000" & carry(07) & sum(07);
	temp(08) := "0000" & carry(08) & sum(08);
	temp(09) := "0000" & carry(09) & sum(09);
	temp(10) := "0000" & carry(10) & sum(10);
	temp(11) := "0000" & carry(11) & sum(11);

	result_uns := ((unsigned(temp(01)) + unsigned(temp(02))) + (unsigned(temp(03)) + unsigned(temp(04)))) +
	              ((unsigned(temp(05)) + unsigned(temp(06))) + (unsigned(temp(07)) + unsigned(temp(08)))) +
	               (unsigned(temp(09)) + unsigned(temp(10))) +  unsigned(temp(11));

	result_int := conv_int(result_uns);

	return result_int;
end function CntNb1_slv32;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Exclude 'nb' LSB / MSB from 'a' vector
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
function ExcludeLSB(a : slv; nb : int := 1) return slv is begin return a(a'high downto a'low+nb); end function ExcludeLSB;
function ExcludeLSB(a : sig; nb : int := 1) return sig is begin return a(a'high downto a'low+nb); end function ExcludeLSB;
function ExcludeLSB(a : uns; nb : int := 1) return uns is begin return a(a'high downto a'low+nb); end function ExcludeLSB;

function ExcludeMSB(a : slv; nb : int := 1) return slv is begin return a(a'high-nb downto a'low); end function ExcludeMSB;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Add 0s on the a's left
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
function Extend0L(a : slv; len: int) return slv is
	variable res : slv(len-1 downto 0) := (others=>'0'); -- Initialize result with all 0s
begin
	assert a'length<=len
		report "[pkg_std - Extend0L] : Input vector is wider than output. Cannot extend it !!"
		severity failure;
--	Do NOT use : "res(a'range) := a;"
	res(a'high-a'low downto 0) := a;
	return res;
end function Extend0L;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Add 0s on the a's right
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
function Extend0R(a : slv; len: int) return slv is
	variable res : slv(len-1 downto 0) := (others=>'0'); -- Initialize result with all 0s
begin
	assert a'length<=len
		report "[pkg_std - Extend0L] : Input vector is wider than output. Cannot extend it !!"
		severity failure;
	res(len-1 downto len-a'length) := a;
	return res;
end function Extend0R;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Object contains a NON-bit ('0' or '1')
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
function Is_01(a:sl) return boolean is
begin
	if a='0' or a='1' then return true ;
	else                   return false; end if;
end function Is_01;

function Is_01 (a:slv) return boolean is
	variable result : boolean := true; --Set to false on the first NON '0'/'1' bit found
begin
	for i in a'range loop
		if a(i)/='0' and a(i)/='1' then
			result := false;
		end if;
	end loop;
	return result;
end function Is_01;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
--MSB & LSB
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
function msb (a : sig) return sl is begin return a(a'high); end function msb;
function msb (a : slv) return sl is begin return a(a'high); end function msb;
function msb (a : uns) return sl is begin return a(a'high); end function msb;

function lsb (a : sig) return sl is begin return a(a'low ); end function lsb;
function lsb (a : slv) return sl is begin return a(a'low ); end function lsb;
function lsb (a : uns) return sl is begin return a(a'low ); end function lsb;

-- For all msb functions below, the ranges are defined :
--    * left /high : nb-1                 : this is the upper bound of result variable
--    * left /low  : nb-Mini(a'length,nb) : we can use only Mini(a'length,nb) bit from 'a' vector -> (nb-1) - Mini(a'length,nb) + 1
--    * right/high :
--    * right/low  :
function msb (a : sig; nb : int) return sig is
	variable result : sig(nb-1 downto 0) := (others=>'0');                                --Result
begin                                                                                     --
	result                                   := (others=>'0');                            --create a full null vector
	result(nb-1 downto nb-Mini(a'length,nb)) := a(a'high downto Maxi(a'high-nb+1,a'low)); --copy requested bit to this vector
	return result;                                                                        --return vector
end function msb;                                                                         --
                                                                                          --
function msb (a : slv; nb : int) return slv is                                            --
	variable result : slv(nb-1 downto 0) := (others=>'0');                                --Result
begin                                                                                     --
	result                                   := (others=>'0');                            --create a full null vector
	result(nb-1 downto nb-Mini(a'length,nb)) := a(a'high downto Maxi(a'high-nb+1,a'low)); --copy requested bit to this vector
	return result;                                                                        --return vector
end function msb;                                                                         --
                                                                                          --
function msb (a : uns; nb : int) return uns is                                            --
	variable result : uns(nb-1 downto 0) := (others=>'0');                                --Result
begin                                                                                     --
	result                                   := (others=>'0');                            --create a full null vector
	result(nb-1 downto nb-Mini(a'length,nb)) := a(a'high downto Maxi(a'high-nb+1,a'low)); --copy requested bit to this vector
	return result;                                                                        --return vector
end function msb;                                                                         --
                                                                                          --
function lsb (a : sig; nb : int) return sig is                                            --
	variable result : sig(nb-1 downto 0);                                                 --Result
begin                                                                                     --
	result                                 := (others=>'0');                              --create a full null vector
	result(Mini(nb-1,a'length-1) downto 0) := a(Mini(a'high,a'low+nb-1) downto a'low);    --copy requested bit to this vector
	return result;                                                                        --return vector
end function lsb;                                                                         --
                                                                                          --
function lsb (a : slv; nb : int) return slv is                                            --
	variable result : slv(nb-1 downto 0);                                                 --Result
begin                                                                                     --
	result                                 := (others=>'0');                              --create a full null vector
	result(Mini(nb-1,a'length-1) downto 0) := a(Mini(a'high,a'low+nb-1) downto a'low);    --copy requested bit to this vector
	return result;                                                                        --return vector
end function lsb;                                                                         --
                                                                                          --
function lsb (a : uns; nb : int) return uns is                                            --
	variable result : uns(nb-1 downto 0);                                                 --Result
begin                                                                                     --
	result                                 := (others=>'0');                              --create a full null vector
	result(Mini(nb-1,a'length-1) downto 0) := a(Mini(a'high,a'low+nb-1) downto a'low);    --copy requested bit to this vector
	return result;                                                                        --return vector
end function lsb;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
--RTL Check
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- These functions return a message on simulator console if
-- there is a non 0/1 std_logic detected. The returned
-- object is the providen one without any modification.
function RTL_Check(a : sl) return sl is
begin
	--synthesis translate_off
	assert Is_01(a)
		report "[RTL_Check] : The providen object is not synthesizable "
		severity failure;
	--synthesis translate_on
	return a;
end function RTL_Check;

function RTL_Check(a : slv) return slv is
begin
	--synthesis translate_off
	assert Is_01(a)
		report "[RTL_Check] : The providen object is not synthesizable "
		severity failure;
	--synthesis translate_on
	return a;
end function RTL_Check;

function RTL_Check(a : sl; name : string) return sl is
begin
	--synthesis translate_off
	assert Is_01(a)
		report "[RTL_Check] : The following object is not synthesizable " & name
		severity failure;
	--synthesis translate_on
	return a;
end function RTL_Check;

function RTL_Check(a : slv; name : string) return slv is
begin
	--synthesis translate_off
	assert Is_01(a)
		report "[RTL_Check] : The following object is not synthesizable " & name
		severity failure;
	--synthesis translate_on
	return a;
end function RTL_Check;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
--Compare 2 SLV, with implicit mask
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- A is a signal in descending order
-- B should be a constant. So, it may be in ascending order if given as a literal string when calling function
function SlvEqImp (a : slv; b : slv) return boolean is
	variable bPos   : int     := b'right; -- Position in 'b' vector
	variable result : boolean := true   ; -- Result is set to false on first difference found
begin
	assert a'length=b'length report "[SlvEqImp] : Both arguments shall have of the same size" severity failure; -- Version 1.03.29

	for i in a'reverse_range loop
		if a(i)/=b(bPos) or (a(i   )/='1' and a(i   )/='0')
		                 or (b(bPos)/='1' and b(bPos)/='0') then
			result := false;
		end if;
		if b'ascending then bPos := bPos - 1;
		else                bPos := bPos + 1; end if;
	end loop;
	return result;
end function SlvEqImp;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
--Compare 2 SLV, with explicit mask
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- All signals are in descending order
function SlvEqExp (a : slv; b : slv; mask : slv) return boolean is
	variable bPos    : int     := b   'right; -- Position in 'b' vector
	variable MaskPos : int     := mask'right; -- Position in 'mask' vector
	variable result  : boolean := true      ; -- Result
begin
	assert a'length=b   'length report "[SlvEqExp] : Both arguments shall have of the same size"     severity failure;
	assert a'length=mask'length report "[SlvEqExp] : Arguments and mask shall have of the same size" severity failure;
	assert not(a   'ascending)  report "[SlvEqExp] : 'a' shall be in descending order"               severity failure;

	for i in a'reverse_range loop
		if (a(i)/=b(bPos) and mask(MaskPos)='1') or (a(i   )/='1' and a(i   )/='0')
		                                         or (b(bPos)/='1' and b(bPos)/='0') then
			result := false;
		end if;

		if b   'ascending then bPos    := bPos    - 1; else bPos    := bPos    + 1; end if;
		if mask'ascending then MaskPos := MaskPos - 1; else MaskPos := MaskPos + 1; end if;
	end loop;
	return result;
end function SlvEqExp;

-- Duplicate bit (usefull signed vector division)
function Dup(a : sl; nb : int) return slv is
	variable result : slv(nb-1 downto 0); -- Result vector
begin
	for i in result'range loop
		result(i) := a;
	end loop;
	return result;
end function Dup;

-- Duplicate vector
function Dup(a : slv; nb : int) return slv is
	variable result : slv(nb*a'length-1 downto 0); -- Result vector
begin
	for i in 0 to nb-1 loop
		result((i+1)*a'length-1 downto i*a'length) := a;
	end loop;
	return result;
end function Dup;

-- Duplicate string
function Dup(a : string; nb : int) return string is
	variable result : string(1 to a'length*nb); -- Result string
begin
	for i in 0 to nb-1 loop
		result(i*a'length+1 to (i+1)*a'length) := a;
	end loop;
	return result;
end function Dup;

--******************************************************************************
-- Edge detection
--******************************************************************************
function FallingEdge(a : slv2) return boolean is begin if a="10" then return true; else return false; end if; end function FallingEdge;
function RisingEdge (a : slv2) return boolean is begin if a="01" then return true; else return false; end if; end function RisingEdge ;
function Edge       (a : slv2) return boolean is begin return conv_boolean(xor1(a));                          end function Edge       ;

function FallingEdge(a : slv2) return sl      is begin if a="10" then return  '1'; else return   '0'; end if; end function FallingEdge;
function RisingEdge (a : slv2) return sl      is begin if a="01" then return  '1'; else return   '0'; end if; end function RisingEdge ;
function Edge       (a : slv2) return sl      is begin return              xor1(a);                           end function Edge       ;
--******************************************************************************
-- Reset
--******************************************************************************
-- These functions clean asynchronous reset on deassertion:
--    * reset assertion is keep asynchronous (connected to register ACLR)
--    * reset deassertion is resynchronized with provided clock
--
function ResyncRst  (signal rst_new, rst, clk : sl) return sl is
	variable result : sl; -- Result
begin
	result := rst_new; -- Register feedback
	if rst='1'             then result := '1';
	elsif rising_edge(clk) then result := '0'; end if;
	return result;
end function;

function ResyncRstn (signal rst_new, rst, clk : sl) return sl is
	variable result : sl; -- Result
begin
	result := rst_new; -- Register feedback
	if rst='1'             then result := '0';
	elsif rising_edge(clk) then result := '1'; end if;
	return result;
end function;
--******************************************************************************
-- Tri-State bus
--******************************************************************************
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- DriveWithOE (Signal with output enable)
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Create a open-collector signal. 's' is the main signal and 'ena' is the Output Enable.
-- When 'oe' is not set, drive 's' with 'mask'
function DriveWithOE(o:sl;oe:sl;mask:sl:='Z') return sl is
begin
	if SIMULATION then
		if oe='1' then return    o;
		else           return mask; end if;
	else
		if mask='Z' then
			if oe='1' then return   o;
			else           return 'Z'; end if;
		else               return   o; end if;
	end if;
end function DriveWithOE;

function DriveWithOE(o:slv;oe:sl;mask:sl:='Z') return slv is
	variable result : slv(o'range); -- Result
begin
	if SIMULATION then
		if oe='1' then result := o;                          -- Drive output
		else           result := (others=>mask); end if;     -- Apply mask value
	else                                                     --
		if mask='Z' then                                     -- If used for tri-state line
			if oe='1' then result := o;                      --    drive output
			else           result := (others=>'Z'); end if;  --    high impedance
		else               result := o;             end if;  -- Always drive output
	end if;
	return result;
end function DriveWithOE;

function DriveWithOE(o:slv;oe:slv;mask:sl:='Z') return slv is
	variable result : slv(o'range); -- Result
begin
	if SIMULATION then
		for i in o'range loop
			if oe(i)='1' then result(i) := o(i);             -- Drive output
			else              result(i) := mask; end if;     -- Apply mask value
		end loop;                                            --
	else                                                     --
		if mask='Z' then                                     -- If used for tri-state line
			for i in o'range loop                            --
				if oe(i)='1' then result(i) := o(i);         --    drive output
				else              result(i) :=  'Z'; end if; --    high impedance
			end loop;                                        --
		else                      result    := o   ; end if; -- Always drive output
	end if;
	return result;
end function DriveWithOE;

-- Convert '0'/'1' to '0'/'Z'
function OpenCollector(a : sl) return sl is
begin
	if a='0' then return '0';
	else          return 'Z'; end if;
end function OpenCollector;
--******************************************************************************
-- Bit & Bytes
--******************************************************************************
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Swap bits in a vector
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
function SwapBits(a:slv) return slv is
	variable result : slv(a'range)     ; -- Result
	variable idx    : nat := result'low; -- Position in 'a' vector
begin
	for i in a'range loop
		result(idx) := a(i);
		idx := idx + 1;
	end loop;
	return result;
end function SwapBits;

function SwapBits(a:uns) return uns is
	variable result : uns(a'range)     ; -- Result
	variable idx    : nat := result'low; -- Position in 'a' vector
begin
	for i in a'range loop
		result(idx) := a(i);
		idx := idx + 1;
	end loop;
	return result;
end function SwapBits;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Swap Bytes in a vector
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
function SwapBytes(a:slv) return slv is
	variable result : slv(a'range)   ; -- Result
	variable m      : int := a'high-7; -- Position in output vector (integer because last iteration provides a never used negative result)
	variable n      : int := a'low   ; -- Position in input  vector
begin
	assert (a'length/8)*8=a'length report "[SwapBytes] : Providen vector shall be 8x bits sized !!" severity failure;
	for i in 1 to a'length/8 loop
		result(m+7 downto m) := a(n+7 downto n);
		m := m - 8;
		n := n + 8;
	end loop;
	return result;
end function SwapBytes;

--******************************************************************************
-- Data & BE
--******************************************************************************
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Data & Be, Merge and Extract functions
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- This functions are usefull when Data & BE shall be merged to store them in a FIFO using a
-- different data path size on each side. Each ByteEnable is associated with the appropriate byte
-- and this data is stored as a single 9bits data.

-- Merge Data & Be :  1BE & 8Data & 1BE & 8Data....
function MergeDataBE(data:slv;be:slv) return slv is
	variable data_be : slv(data'length+be'length-1 downto 0); -- Data & BE
begin
	for i in 0 to data'length/8-1 loop
		data_be(9*i+8 downto 9*i) := be(i) & data(8*i+7 downto 8*i);
	end loop;

	return data_be;
end function MergeDataBE;

-- Extract Be   from [1BE & 8Data & 1BE & 8Data....]
function ExtractBE(data_be:slv) return slv is
	variable be : slv(data_be'length/9-1 downto 0); -- Extracted ByteEnable
begin
	for i in 0 to data_be'length/9-1 loop
		be(i) := data_be(9*i+8);
	end loop;
	return be;
end function ExtractBE;

-- Extract Data from [1BE & 8Data & 1BE & 8Data....]
function ExtractData(data_be:slv) return slv is
	variable data : slv(data_be'length*8/9-1 downto 0); -- Extracted Data
begin
	for i in 0 to data_be'length/9-1 loop
		data(8*i+7 downto 8*i) := data_be(9*i+7 downto 9*i);
	end loop;
	return data;
end function ExtractData;

--******************************************************************************
-- SEU Protection
--******************************************************************************
-- Single Even Upset protection. Assume that no more than only one bit has been
-- corrupted (so we have 2 values OK and 1 wrong value).
function SecureSEU(a,b,c: sl) return sl is
begin
	if a=b then return a;                            -- A=B. We have two identical values, so they are OK
	else        return c; end if;                    -- A/=B. The corrupted bit is either A or B, but C is OK
end function SecureSEU;

function SecureSEU(a,b,c: slv) return slv is
	variable result : slv(a'range); -- Result
begin
	for i in a'range loop
		if a(i)=b(i) then result(i) := a(i);         -- A=B. We have two identical values, so they are OK
		else              result(i) := c(i); end if; -- A/=B. The corrupted bit is either A or B, but C is OK
	end loop;
	return result;
end function SecureSEU;
--******************************************************************************
-- SLV Tests
--******************************************************************************
-- Count number of 0 contained inside a vector
function CntNb0( a : slv) return int is
	variable cnt : int := 0; -- Result
begin
	for i in a'range loop if a(i)='0' then cnt := cnt + 1; end if; end loop;
	return cnt;
end function CntNb0;

-- Count number of 1 contained inside a vector
function CntNb1( a : slv) return int is
	variable cnt : int := 0; -- Result
begin
	for i in a'range loop if a(i)='1' then cnt := cnt + 1; end if; end loop;
	return cnt;
end function CntNb1;

-- Return the position of the first non null LSB
function PosLSB( a : slv) return int is
	variable cnt : int := a'low; -- Result
begin
	-- Version 3.01.02
	assert Is_01(a)
		report "[PosLSB] : Providen vector doesn't contain only '0' or '1' !!"
		severity failure;

	-- Default value
	cnt := -1;

	for i in a'low to a'high loop
		if a(i)='1' then
			cnt := i;
			exit;
		end if;
	end loop;
	return cnt;
end function PosLSB;

-- Return the position of the first non null MSB
function PosMSB(a : slv) return int is
	variable cnt : int := a'high; -- Result
begin
	-- Version 3.01.02
	assert Is_01(a)
		report "[PosMSB] : Providen vector doesn't contain only '0' or '1' !!"
		severity failure;

	-- Default value
	cnt := -1;

	for i in a'high downto a'low loop
		if a(i)='1' then
			cnt := i;
			exit;
		end if;
	end loop;
	return cnt;
end function PosMSB;

--**************************************************************************************************
-- String
--**************************************************************************************************
function "=" (a,b : character) return boolean is begin return character'pos(a) =character'pos(b); end function "=" ;
function "/="(a,b : character) return boolean is begin return character'pos(a)/=character'pos(b); end function "/=";
function "<" (a,b : character) return boolean is begin return character'pos(a)< character'pos(b); end function "<" ;
function "<="(a,b : character) return boolean is begin return character'pos(a)<=character'pos(b); end function "<=";
function ">" (a,b : character) return boolean is begin return character'pos(a)> character'pos(b); end function ">" ;
function ">="(a,b : character) return boolean is begin return character'pos(a)>=character'pos(b); end function ">=";
--------------------------------------------------------------------------------
-- Return true if both string are identical
--------------------------------------------------------------------------------
function StrEq(a,b:string) return boolean is
begin
	if a'length=b'length then return a=b;
	else                      return false; end if;
end function StrEq;
--------------------------------------------------------------------------------
-- Convert an integer to a string
--------------------------------------------------------------------------------
-- Parameters
--     DATA   : integer to convert to a string
--     result : output string
--     last   :
procedure to_Str(constant DATA : in int; variable result : out string; variable last: out int) is
	variable buf   : string(MAX_DIGITS downto 1)             ; -- Working string (from right to left !!!)
	variable idx   : int                         :=         1; -- Loop index
	variable tmp   : int                         := abs(DATA); -- Remainder
	variable digit : int                                     ; -- Digit to convert to character
begin
	for i in 1 to MAX_DIGITS loop      -- Version 2.03.06 : specify a "maximum" range for XILINX compatibility
		digit    := abs(tmp mod 10);   -- mod of integer'left returns neg number!
		tmp      := tmp / 10;
		buf(idx) := character'val(character'pos('0') + digit);
		idx      := idx + 1;
		if tmp=0 then exit; end if;
	end loop;
	if DATA < 0 then
		buf(idx) := '-';
		idx      := idx + 1;
	end if;
	idx              := idx - 1;
	result(1 to idx) := buf(idx downto 1); -- Reorganize string in correct order (from left to right)
	last             := idx;
end procedure to_Str;

-- Parameters
--     DATA      : integer to convert to a string
--     precision : number of digits after the "."
--     result    : output string
--     last      :
procedure to_Str(constant DATA : in real; precision : in int; variable result : out string; variable last: out int) is
	variable data_int : real                                    ;
	variable data_dec : real                                    ;
	variable buf_int  : string(MAX_DIGITS downto 1)             ; -- Working string (from right to left !!!)
	variable buf_dec  : string(1 to MAX_DIGITS)                 ; -- Working string
	variable idx      : int                         :=         1; -- Loop index for final result
	variable idx_int  : int                         :=         1; -- Loop index for integral part
	variable idx_dec  : int                         :=         1; -- Loop index for decimal  part
	variable tmp      : real                        := abs(DATA); -- Remainder
	variable digit    : int                                     ; -- Digit to convert to character
begin
	data_int := PartIntAsReal(DATA);
	data_dec := PartDec      (DATA);

	-- Integral part
	tmp := data_int;
	for i in 1 to MAX_DIGITS loop             -- Version 2.03.06 : specify a "maximum" range for XILINX compatibility
		digit            := PartInt(abs(tmp mod 10.0));   -- mod of integer'left returns neg number!
		tmp              := tmp / 10.0;
		buf_int(idx_int) := character'val(character'pos('0') + digit);
		idx_int          := idx_int + 1;
		if tmp<1 then exit; end if;
	end loop;
	idx_int := idx_int - 1;

	-- Add sign
	if DATA < 0 then
		result(idx) := '-';
		idx_int     := idx_int + 1;
	end if;

	-- Decimal part
	tmp := data_dec * 10.0;
	for i in 1 to precision loop
		digit            := PartInt(abs(tmp mod 10.0));   -- mod of integer'left returns neg number!
		tmp              := (tmp-digit) * 10.0;
		buf_dec(idx_dec) := character'val(character'pos('0') + digit);
		idx_dec          := idx_dec + 1;
	end loop;
	idx_dec := idx_dec - 1;

	-- Copy integral part
	result(1 to idx_int) := buf_int(idx_int downto 1); -- Reorganize string in correct order (from left to right)
	last                 := idx_int;

	-- Copy decimal part
	if precision>0 then
		result(idx_int+1                     ) := '.';
		result(idx_int+2 to idx_int+idx_dec+1) := buf_dec(1 to idx_dec);

		last := idx_int+1+idx_dec;
	end if;
end procedure to_Str;

function to_Str(i : int) return string is
	variable buf  : string(1 to MAX_DIGITS); -- Result
	variable last : int                    ; -- Last valid character
begin
	to_Str(i,buf,last);
	return buf(1 to last);
end function to_Str;

function to_Str(i : int; size : nat;padding:character:=' ') return string is
	variable buf  : string(1 to MAX_DIGITS) := (others=>' '    ); -- Result
	variable buf2 : string(1 to size      ) := (others=>padding); -- Result with requested size
	variable last : int                                         ; -- Last valid character
begin
	to_Str(i,buf,last);

	-- Result if shorter than requested => right aligned result
	if last<size then
		buf2(size-last+1 to size) := buf(1 to last);
		return buf2;
	else
		return buf(1 to last);
	end if;
end function to_Str;

-- Convert a real number to a string. Decimal part is coded with 's_dec' digit (size of decimal part)
function to_Str(i : real; s_dec : nat) return string is
	variable buf  : string(1 to MAX_DIGITS) := (others=>' '); -- Result
	variable last : int                                     ; -- Last valid character
begin
	to_Str(i,s_dec,buf,last);

	return buf(1 to last);
end function to_Str;
--------------------------------------------------------------------------------
-- Return an integer as a string in 10^6 system
-- Example : 12345678 => "12.345678"
--------------------------------------------------------------------------------
function to_StrMega(a : int) return string is
	variable a_int     : nat            ; -- Result's integral part
	variable a_dec     : nat            ; -- Result's decimal  part
	variable a_dec_str : string(1 to  7);
begin
	a_int := PartInt(real(a)/1.0E6);
	a_dec := a - a_int*1E6 + 1E6; -- Add 1 million to keep left's 0s !!!

	a_dec_str := to_Str(a_dec,6,'0');

	return to_Str(a_int) & '.' & a_dec_str(2 to 7);
end function to_StrMega;
--------------------------------------------------------------------------------
-- Replace '_' (underscore) to ' ' (space)
--------------------------------------------------------------------------------
-- Usefull for FPGA device (contain a space device name) when generic name is provided by ModelSim GP file (in vsim command line)
function StrUS2Spc(a : string) return string is
	variable b : string(a'range); -- Result string
begin
	for i in a'range loop
		if a(i)='_' then b(i) := ' ';
		else             b(i) := a(i); end if;
	end loop;
	return b;
end function StrUS2Spc;
--------------------------------------------------------------------------------
-- Convert a SL to a string
--------------------------------------------------------------------------------
function SL2Chr(v : sl) return character is
begin
	case v is
		when '0' => return '0';
		when '1' => return '1';
		when 'Z' => return 'Z';
		when 'H' => return 'H';
		when 'L' => return 'L';
		when 'X' => return 'X';
		when 'W' => return 'W';
		when 'U' => return 'U';
		when '-' => return '-';
	end case;
end function SL2Chr;

function to_StrBin(v : sl) return string is
begin
	case v is
		when '0' => return "0";
		when '1' => return "1";
		when 'Z' => return "Z";
		when 'H' => return "H";
		when 'L' => return "L";
		when 'X' => return "X";
		when 'W' => return "W";
		when 'U' => return "U";
		when '-' => return "-";
	end case;
end function to_StrBin;
--------------------------------------------------------------------------------
-- Convert a SL to a binary string
--------------------------------------------------------------------------------
function  to_StrBin( v     : slv
                   ; char0 : character := '0'
                   ; char1 : character := '1') return string is
	variable result  : string(1 to v'length);
	variable str_idx : nat := 1;
begin
	if v'ascending then
		for i in v'left to v'right loop
			case v(i) is
				when '0' => result(str_idx) := char0;
				when '1' => result(str_idx) := char1;
				when 'Z' => result(str_idx) :=   'Z';
				when 'H' => result(str_idx) :=   'H';
				when 'L' => result(str_idx) :=   'L';
				when 'X' => result(str_idx) :=   'X';
				when 'W' => result(str_idx) :=   'W';
				when 'U' => result(str_idx) :=   'U';
				when '-' => result(str_idx) :=   '-';
			end case;
			str_idx := str_idx + 1;
		end loop;
	else
		for i in v'left downto v'right loop
			case v(i) is
				when '0' => result(str_idx) := char0;
				when '1' => result(str_idx) := char1;
				when 'Z' => result(str_idx) :=   'Z';
				when 'H' => result(str_idx) :=   'H';
				when 'L' => result(str_idx) :=   'L';
				when 'X' => result(str_idx) :=   'X';
				when 'W' => result(str_idx) :=   'W';
				when 'U' => result(str_idx) :=   'U';
				when '-' => result(str_idx) :=   '-';
			end case;
			str_idx := str_idx + 1;
		end loop;
	end if;
	return result;
end function to_StrBin;
--------------------------------------------------------------------------------
-- Converts a SLV to an hexadecimal string
--------------------------------------------------------------------------------
function to_StrHex (v : slv; char0 : character := '0') return string is
	-- Because each sub-SLV4 part will be converted into a character, all possible size for 'v' vector
	-- shall be taken into account ('v' is not necessary a 4x). Parameter 'N' help to determine the
	-- exact size of the result string : +3 is used to take into account decimal part.
	constant N : int                 := (v'length+3)/4; -- Number of characters to convert 'v'
	variable s : string (1 to N)                      ; -- Result string
	variable m : slv(N*4-1 downto 0) := (others=>'0') ; -- Working vector
	variable q : slv4                                 ; -- Wroking sub-vector
begin
	m(v'length-1 downto 0) := v; -- Copy input vector. Unused bits in this affectation are 0s (see declaration)
	for i in 0 to N-1 loop
		q      := m(i*4+3 downto i*4);
		if q="0000" then s(N-i) := char0;
		else             s(N-i) := SLV4_Char(q); end if;
	end loop;
	return (s);
end function to_StrHex;
--------------------------------------------------------------------------------
-- Converts a SLV to an hexadecimal string, with fixed return string length
--------------------------------------------------------------------------------
function to_StrHex (v : slv; size : nat) return string is
	constant N   : int                        := (v'length+3)/4; -- Number of characters to convert 'v'
	variable s   : string (1 to Maxi(N,size)) := (others=>'0') ; -- Result string, initialized with 0s
	variable res : string (1 to      N      )                  ; -- Returned string form conversion
begin
	res := to_StrHex(v);
	for i in N downto 1 loop
		s(i) := res(i);
	end loop;
	return s;
end function to_StrHex;
--------------------------------------------------------------------------------
-- Converts an integer to an hexadecimal string
--------------------------------------------------------------------------------
function to_StrHex (v : int) return string is
	constant N     : int             := NbDigit(v,16); -- Number of character for string conversion
	variable s     : string (1 to N)                 ; -- String (result)
	variable reste : int                             ; -- Division reste
	variable Div   : int                             ; -- Dividor
	variable idx   : int                             ; -- Position in the string
begin
	reste := v;
	idx   := 1;
	for i in N-1 downto 0 loop
		Div := int(reste / (16**i));
		if Div<10 then s(idx) := character'val(48+Div);
		else           s(idx) := character'val(55+Div); end if;
		reste := reste - ( Div * (16**i));
		idx := idx + 1;
	end loop;
	return(s);
end function to_StrHex;
--------------------------------------------------------------------------------
-- Converts an integer to an hexadecimal string, with fixed return string length
--------------------------------------------------------------------------------
function to_StrHex (v : int; size : nat) return string is
	constant N   : int                        := NbDigit(v,16); -- Number of character for string conversion
	variable s   : string (1 to Maxi(N,size)) := (others=>'0') ; -- Result string, initialized with 0s
	variable res : string (1 to      N      )                 ; -- Returned string form conversion
begin
	res := to_StrHex(v);
	for i in 1 to N loop
		s(s'length-N+i) := res(i);
	end loop;
	return s;
end function to_StrHex;
--------------------------------------------------------------------------------
-- Hexadecimal string to SLV
-- Example : string("DEEDBEAF") --> slv(x"DEEDBEAF")
--------------------------------------------------------------------------------
function StrHex_SLV(str : string; nb_digits : nat) return slv is
	variable result : slv(4*nb_digits-1 downto 0)               ; -- Result is 4 times longer
	constant LEN    : nat                         := StrLen(str); -- Length of input string
begin
	assert StrLen(str)<=nb_digits
		report "[StrHex_SLV] : Provided string is too long (>'nb_digits' parameter) !!"
		severity failure;

	result := (others=>'0');

	-- Convert characters
	for i in 0 to LEN-1 loop
		result(4*i+3 downto 4*i) := Char_SLV4(str(LEN-i)); -- String is analyzed in reverse range !!
	end loop;

	return result;
end function StrHex_SLV;
--------------------------------------------------------------------------------
-- Convert an hexadecimal character to a 4bit vector
--------------------------------------------------------------------------------
function Char_SLV4 (c : character) return slv4 is
	variable v : slv4; -- Current working vector
begin
	case c is
		when '0' | '.' => v := x"0";  when '1'       => v := x"1";  when '2'       => v := x"2";  when '3'       => v := x"3";
		when '4'       => v := x"4";  when '5'       => v := x"5";  when '6'       => v := x"6";  when '7'       => v := x"7";
		when '8'       => v := x"8";  when '9'       => v := x"9";  when 'a' | 'A' => v := x"A";  when 'b' | 'B' => v := x"B";
		when 'c' | 'C' => v := x"C";  when 'd' | 'D' => v := x"D";  when 'e' | 'E' => v := x"E";  when 'f' | 'F' => v := x"F";
		when others    => report "[Char_SLV4] : Illegal character for conversion !!" severity failure;
	end case;
	return (v);
end function Char_SLV4;
--------------------------------------------------------------------------------
-- Convert a 4bit vector to an hexadecimal character
--------------------------------------------------------------------------------
function SLV4_Char (v : slv4) return character is
	variable c  : character             ; -- Current working character
	variable vb : bit_vector(3 downto 0); -- Resolve SLV4 to '0' / '1'
begin
	if Is_X(v) then
		if v="ZZZZ" then c := 'Z';
		else             c := 'X'; end if;
	else
		vb := to_bitvector(v);
		case vb is
			when x"0" => c :='0';  when x"1" => c := '1';  when x"2" => c := '2';  when x"3" => c := '3';
			when x"4" => c :='4';  when x"5" => c := '5';  when x"6" => c := '6';  when x"7" => c := '7';
			when x"8" => c :='8';  when x"9" => c := '9';  when x"A" => c := 'A';  when x"B" => c := 'B';
			when x"C" => c :='C';  when x"D" => c := 'D';  when x"E" => c := 'E';  when x"F" => c := 'F';
		end case;
	end if;
	return (c);
end function SLV4_Char;
--------------------------------------------------------------------------------
-- Convert an ASCII character to a 8bit vector
--------------------------------------------------------------------------------
function Char_SLV8(c : character) return slv8 is
begin
	return conv_slv(character'pos(c),8);
end function Char_SLV8;

--------------------------------------------------------------------------------
-- Convert a 8bit vector to an ASCII character
--------------------------------------------------------------------------------
function SLV8_Char(v : slv8) return character is
begin
	return character'val(conv_int(uns(v)));
end function SLV8_Char;
--------------------------------------------------------------------------------
-- Convert an ASCII character to an integer
--------------------------------------------------------------------------------
function Char_Int(c : character) return int is
begin
	return character'pos(c);
end function Char_Int;
--------------------------------------------------------------------------------
-- Convert an integer to and ASCII character
--------------------------------------------------------------------------------
function Int_Char(i : int) return character is
begin
	assert i>=0 and i<=256 report "[Int_Char] : Int_Char : Out of range input integer = " & to_Str(i);
	return character'val(i);
end function Int_Char;
--------------------------------------------------------------------------------
-- Convert to lower case
--------------------------------------------------------------------------------
function LowerCase(char : character) return character is
begin
	if char>='A' and char<='Z' then return character'val(character'pos(char) + 32);
	else                            return char; end if;
end function LowerCase;

function LowerCase(str : string) return string is
	variable result : string(str'range); -- Result string
begin
	for i in str'range loop
		result(i) := LowerCase(str(i));
	end loop;
	return result;
end function LowerCase;
--------------------------------------------------------------------------------
-- Convert to upper case
--------------------------------------------------------------------------------
function UpperCase(char : character) return character is
begin
	if char>='a' and char<='z' then return character'val(character'pos(char) - 32);
	else                            return char; end if;
end function UpperCase;

function UpperCase(str : string) return string is
	variable result : string(str'range); -- Result string
begin
	for i in str'range loop
		result(i) := UpperCase(str(i));
	end loop;
	return result;
end function UpperCase;
--------------------------------------------------------------------------------
-- String to integer value
-- Example : string("0100",16) --> integer(256)
--           string("0100",10) --> integer(100)
--------------------------------------------------------------------------------
function Str_Int (str : string; base : nat) return int is
	variable temp : int := 0; -- Working integer
begin
	if base=10 then
		for i in str'range loop
			if str(i)=character'val(0) then exit; end if;
			temp := 10 * temp;
			case str(i) is
				when '0'    => temp := temp + 0; when '1' => temp := temp + 1; when '2' => temp := temp + 2; when '3' => temp := temp + 3;
				when '4'    => temp := temp + 4; when '5' => temp := temp + 5; when '6' => temp := temp + 6; when '7' => temp := temp + 7;
				when '8'    => temp := temp + 8; when '9' => temp := temp + 9;
				when others => report "[Str_Int] : Illegal character into a integer string" severity failure;
			end case;
		end loop;
	elsif base=16 then
		for i in str'range loop
			if str(i)=character'val(0) then exit; end if;
			temp := 16 * temp;
			case str(i) is
				when '0'       => temp := temp +  0; when '1'       => temp := temp +  1; when '2'       => temp := temp +  2; when '3'       => temp := temp +  3;
				when '4'       => temp := temp +  4; when '5'       => temp := temp +  5; when '6'       => temp := temp +  6; when '7'       => temp := temp +  7;
				when '8'       => temp := temp +  8; when '9'       => temp := temp +  9; when 'A' | 'a' => temp := temp + 10; when 'B' | 'b' => temp := temp + 11;
				when 'C' | 'c' => temp := temp + 12; when 'D' | 'd' => temp := temp + 13; when 'E' | 'e' => temp := temp + 14; when 'F' | 'f' => temp := temp + 15;
				when others => report "[Str_Int] : Illegal character into a hexadecimal string" severity failure;
			end case;
		end loop;
	else
		report "[Str_Int] : Only decimal and hexadecimal string are supported !!" severity failure;
	end if;
	return temp;
end function Str_Int;
--------------------------------------------------------------------------------
-- String to time unit
--------------------------------------------------------------------------------
-- Convert the string containing a time unit to corresponding type
-- For example : "ps" -> 1 ps
function Str_TimeUnit(str : string) return time is
begin
	   if StrCmpNoCase(str,"ps" ) then return 1 ps ;
	elsif StrCmpNoCase(str,"ns" ) then return 1 ns ;
	elsif StrCmpNoCase(str,"us" ) then return 1 us ;
	elsif StrCmpNoCase(str,"ms" ) then return 1 ms ;
	elsif StrCmpNoCase(str,"sec") then return 1 sec;
	else
		report "[Str_TimeUnit] : Unsupported time unit" severity failure;
		return 0 ps; -- Dummy return : hey, simulation was stopped => just to avoid warning
	end if;
end function Str_TimeUnit;
---------------------------------------------------------------
-- Concatenate two strings
---------------------------------------------------------------
procedure StrCat ( a,b : in  string
                 ; res : out string) is
	variable Idx    : int         ; -- Character index
	variable StrVal : boolean     ; -- Current character is valid
	variable StrIdx : int     := 1; -- Character index in output string
begin

	StrVal := true;
	Idx    :=  1  ;
--	while StrVal loop
--		if a(Idx)/=character'val(0) then res(StrIdx) := a(Idx); StrIdx := StrIdx + 1; Idx := Idx + 1;
--		else                                                                                          StrVal := false; end if;
--		if Idx>a'length then StrVal := false; end if;
--	end loop;

	loop
		if a(Idx)/=character'val(0) then res(StrIdx) := a(Idx); StrIdx := StrIdx + 1; Idx := Idx + 1;
		else exit; end if;
		if Idx>a'length then exit; end if;
	end loop;

	StrVal := true;
	Idx    :=  1  ;
--	while StrVal loop
--		if b(Idx)/=character'val(0) then
--			res(StrIdx) := b(Idx)    ;
--			StrIdx      := StrIdx + 1;
--			Idx         := Idx    + 1;
--		else
--			StrVal := false;
--		end if;
--		if Idx>b'length then StrVal := false; end if;
--	end loop;

	loop
		if b(Idx)/=character'val(0) then res(StrIdx) := b(Idx); StrIdx := StrIdx + 1; Idx := Idx + 1;
		else exit; end if;
		if Idx>b'length then exit; end if;
	end loop;
end procedure StrCat;
---------------------------------------------------------------
-- Compare two strings ignoring case
---------------------------------------------------------------
function StrCmpNoCase(a, b : string) return boolean is
	variable i      : int     :=    1; -- Character to compare in both strings
	variable result : boolean := true; -- Strings are identical until first diffenrent character is found
begin
	   if a'length=0 and b'length=0 then return true;          -- A and B don't exist (empty strings)
	elsif a'length=0                then                       --
		if b(1)=character'val(0)    then return true;          -- A is an empty string, B starts with     null character
		else                             return false; end if; -- A is an empty string, B starts with non-null character
	elsif b'length=0                then                       --
		if a(1)=character'val(0)    then return true;          -- B is an empty string, A starts with     null character
		else                             return false; end if; -- B is an empty string, A starts with non-null character
	end if;

	loop
		if LowerCase(a(i))/=LowerCase(b(i))                 then return false; end if;

		i := i + 1;
		   if i>a'length and i>b'length                     then return true ;         -- End of both strings
		elsif i>a'length and     StrNull(b(i to b'length))  then return true ;         -- End of A and B is     null
		elsif i>a'length and not(StrNull(b(i to b'length))) then return false;         -- End of A and B is non-null
		elsif i>b'length and     StrNull(a(i to a'length))  then return true ;         -- End of B and A is     null
		elsif i>b'length and not(StrNull(a(i to a'length))) then return false; end if; -- End of B and A is non-null
	end loop;
	return false; -- Never goes here, just to remove stupid warning in Vivado 2015.4
end function StrCmpNoCase;
---------------------------------------------------------------
-- Copy a string
---------------------------------------------------------------
procedure StrCpy (a : in string; res : out string) is
	variable i : int := 1; -- Current character position
begin
	while a(i)/=character'val(0) loop
		res(i) := a(i);
		i := i + 1;
	end loop;
end procedure StrCpy;
---------------------------------------------------------------
-- String Length
---------------------------------------------------------------
function StrLen(a : string) return nat is
	variable res : nat := a'length; -- Result
begin
	for i in 0 to a'right-a'left loop
		if a(a'left+i)=character'val(0) then  -- Search the first null character
			res := a'left+i-1;                -- Remove null character
			exit;
		end if;
	end loop;
	return res;
end function StrLen;
---------------------------------------------------------------
-- String is null ?
---------------------------------------------------------------
function StrNull(a : string) return boolean is
begin
	for i in a'range loop
		if a(i)/=character'val(0) then return false; end if;
	end loop;
	return true;
end function StrNull;
---------------------------------------------------------------
-- Check if string contains an integer (with base)
---------------------------------------------------------------
function StrIsInt (a : string; base : nat) return boolean is
	variable res : boolean := true; -- Result
begin
	for i in a'range loop
		if a(i)=character'val(0) then exit;
		elsif base=10 then
			if a(i)<'0' or a(i)>'9' then res := false; end if;
		elsif base=16 then
			if (a(i)<'0' or a(i)>'9') and
			   (a(i)<'a' or a(i)>'f') and
			   (a(i)<'A' or a(i)>'F') then res := false; end if;
		end if;
	end loop;
	return res;
end function StrIsInt;
--------------------------------------------------------------------------------
-- Get Architecture Name
--------------------------------------------------------------------------------
--Extract architecture name from ":e(a):s"
--       cf. IEEE1076-2000, page 198 (PDF page 207/299), line 477
--   or  cf. IEEE1076-2002, page 202 (PDF page 202/309)
-- This function can be used even in entity declaration part, even if the file contains only this entity !
-- Architecture is loaded when simulation starts and this function is then called.
-- Example :
--   1) inside a process, just type
--       variable ArchName : string(1 to GetArchName(MyObject'instance_name)'length) := GetArchName(MyObject'instance_name);
--       where MyObject can even be a generic object from top-level testbench.
--   2) or inside an entity (before "end entity"), create a declaration part with "begin"  and use the same variable as defined in 1)
--       this allow an entity to know which architecture has been loaded !! (usefull for Altera / Xilinx generic modules)
--
-- ENJOY !!
--
function GetArchName(full_name : string) return string is
	variable arch_name : string(1 to full_name'length)         ; -- The so wanted architecture name
	variable run       : boolean                       := false; -- Process characters between '(' and ')'
	variable j         : nat                           := 1    ; -- Number of characters between '(' and ')'
begin
	for i in full_name'range loop
		if run then
			arch_name(j) := full_name(i);
			j := j + 1;
		end if;

		if full_name(i  )='(' then run :=  true;       end if;
		if full_name(i+1)=')' then run := false; exit; end if;
	end loop;

	return arch_name(1 to j-1);
end function GetArchName;
--**************************************************************************************************************************************************************
-- Gray / Binary
--**************************************************************************************************************************************************************
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Gray ==> Binary
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
function Gray2Bin(gray : slv) return slv is
	variable bin : slv(gray'range); -- Binary result value
begin
	bin(gray'high) := gray(gray'high);
	for i in gray'high-1 downto gray'low loop
		bin(i) := bin(i+1) xor gray(i); -- Slow operation (iterative)
	end loop;
	return bin;
end function Gray2Bin;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Binary ==> Gray
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
function Bin2Gray(bin : slv) return slv is
	variable gray : slv(bin'range); -- Gray result value
begin
	gray(bin'high) := bin(bin'high);
	for i in bin'high-1 downto bin'low loop
		gray(i) := bin(i+1) xor bin(i); -- Fast operation (2 inputs --> 1 output)
	end loop;
	return gray;
end function Bin2Gray;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Clear a gray counter with its toggle
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
procedure GrayClr ( signal gray   : out slv
                  ; signal toggle : out sl ) is
begin
	for i in gray'range loop
		gray(i) <= '0'; -- we cannot use (others=>'0') with a unconstrained array aggregate
	end loop;
	toggle <= '0' ;
end procedure GrayClr;

--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Add an integer to a gray value
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
function GrayAdd(gray : slv; add : int) return slv is
begin
	return slv(uns(Gray2Bin(gray)) + add);
end function GrayAdd;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Increase a gray counter (Simple but low performances)
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
procedure GrayIncr(signal gray : inout slv) is
	variable toggle     : sl                       ; -- Toggle
	variable carry      : slv(gray'high+1 downto 0); -- Carry
	variable gray_old   : slv(gray'high+1 downto 0); -- Old gray value
	variable gray_new   : slv(gray'high+1 downto 0); -- New gray value
begin
	-- Compute toggle
	toggle := not(xor1(gray));

	-- Create "old" gray vector
	gray_old := gray & toggle;

	-- Compute carry for LSB
	carry(0) := '1'; -- with enable : carry(0) := ena;

	-- Compute for all others bits
	for i in 1 to gray'length loop
		carry(i) := carry(i-1) and not(gray_old(i-1));
	end loop;

	-- Increase counter
	gray_new(0) := not(toggle); -- with enable : gray_new(0) := gray(0) xor ena;
	for i in 1 to gray_new'high-1 loop
		gray_new(i) := gray_old(i) xor (carry(i-1) and gray_old(i-1));
	end loop;
	gray_new(gray_new'high) := gray_old(gray_new'high) xor carry(carry'high-1);

	gray   <= gray_new(gray_new'high downto 1);
end procedure GrayIncr;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Increase a gray counter (Complex but high performances)
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
procedure GrayIncr(signal gray   : inout slv;
                   signal toggle : inout sl ) is
	--synthesis translate_off
	variable toggle_exp : sl                       ; -- Expected toggle value
	--synthesis translate_on
	variable carry      : slv(gray'high+1 downto 0); -- Carry
	variable gray_old   : slv(gray'high+1 downto 0); -- Old gray value
	variable gray_new   : slv(gray'high+1 downto 0); -- New gray value
begin
	--synthesis translate_off
	-- Check that provided toggle is correct
	toggle_exp := xor1(gray);

	if toggle/=toggle_exp then
		report "[GrayIncr] : Wrong toggle provided !!" severity failure;
	end if;
	--synthesis translate_on

	-- Create "old" gray vector
	gray_old := gray & not(toggle);

	-- Compute carry for LSB
	carry(0) := '1'; -- with enable : carry(0) := ena;

	-- Compute for all others bits
	for i in 1 to gray'length loop
		carry(i) := carry(i-1) and not(gray_old(i-1));
	end loop;

	-- Increase counter
	gray_new(0) := toggle; -- with enable : gray_new(0) := gray(0) xor ena;
	for i in 1 to gray_new'high-1 loop
		gray_new(i) := gray_old(i) xor (carry(i-1) and gray_old(i-1));
	end loop;
	gray_new(gray_new'high) := gray_old(gray_new'high) xor carry(carry'high-1);

	toggle <= not(gray_new(0));
	gray   <=     gray_new(gray_new'high downto 1);
end procedure GrayIncr;
--**************************************************************************************************************************************************************
-- Advanced mathematics
--**************************************************************************************************************************************************************
--******************************************************************************
-- Trigonometric
--******************************************************************************
-- Cardinal Sinus = Sin(X)/X
--  sin(x)/x
--     when x=0      => sin(x)/x=1
--     when x near 0 => sin(x)/x strictly decreasing
--     when x/=0     => sin(x)/x<1
function sin_c (x : real) return real is
begin
	if x=real(0) then return 1.0;
	else              return Mini(1,sin(x)/x); -- Mini is used to avoid too high values near 0.
	end if;
end function sin_c;
--******************************************************************************
-- Matrix
--******************************************************************************
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Clear a matrix
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
function MatrixClear(row,col : nat) return SlMatrix is
	variable result : SlMatrix(0 to row-1,0 to col-1); -- Result
begin
	for i in 0 to row-1 loop
		for j in 0 to col-1 loop
			result(i,j) := '0';
		end loop;
	end loop;
	return result;
end function MatrixClear;

function MatrixClear(row,col : nat) return RealMatrix is
	variable result : RealMatrix(0 to row-1,0 to col-1); -- Result
begin
	for i in 0 to row-1 loop
		for j in 0 to col-1 loop
			result(i,j) := 0.0;
		end loop;
	end loop;
	return result;
end function MatrixClear;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Array --> Column
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Convert an array into a column matrix
-- Provided array is used to create a single column on resulting matrix
-- M = [b(n-1)...b(0)]
--
--     [ b(n-1) ]
-- P = [ b(n-2) ]
--     [ ....   ]
--     [ b(0)   ]
--
function MatrixColumn (M : slv) return SlMatrix is
	variable P  : SlMatrix(1 to M'length,1 to 1)     ; -- Result (Column matrix has several lines and only 1 column)
	variable ip : nat                            := 1; -- Index for P
begin
	for im in M'range loop
		P(ip,1) := M(im);
		ip := ip + 1;
	end loop;
	return P;
end function MatrixColumn;

function MatrixColumn (M : RealArray) return RealMatrix is
	variable P : RealMatrix(M'range,1 to 1); -- Result (Column matrix has several lines and only 1 column)
begin
	for i in M'range loop
		P(i,1) := M(i);
	end loop;
	return P;
end function MatrixColumn;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Array --> Line
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Convert an array into a line matrix
-- Provided array is used to create a single line on resulting matrix
-- M = [b(n-1)...b(0)] as std_logic_vector
-- P = [b(n-1)...b(0)] as matrix (contains n elements of 1bit)

function MatrixRow(M : slv) return SlMatrix is
	variable P  : SlMatrix(1 to 1,1 to M'length)     ; -- Result (Line matrix has several columns and only 1 line)
	variable ip : nat                            := 1; -- Index for P
begin
	for im in M'range loop
		P(1,ip) := M(im);
		ip := ip + 1;
	end loop;
	return P;
end function MatrixRow;

function MatrixRow(M : RealArray) return RealMatrix is
	variable P : RealMatrix(1 to 1,M'range); -- Result (Line matrix has several columns and only 1 line)
begin
	for i in M'range loop
		P(1,i) := M(i);
	end loop;
	return P;
end function MatrixRow;

--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Extract a column
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Extract a column and return an array
-- Line   shall be the FIRST  index
-- Column shall be the SECOND index
function MatrixGetColumn(M : SlMatrix  ; col : nat) return slv is
	variable result : slv(M'range(1)); -- Result
begin
	for i in result'range loop
		result(i) := M(i,col);
	end loop;

	return result;
end function MatrixGetColumn;

-- Return a partial column (from line_start up to line_stop)
function  MatrixGetColumn(M : SlMatrix; col,row_start,row_stop:nat) return slv is
	variable result : slv(row_start to row_stop); -- Result
begin
	for i in result'range loop
		result(i) := M(i,col);
	end loop;

	return result;
end function MatrixGetColumn;

function MatrixGetColumn(M : RealMatrix; col : nat) return RealArray is
	variable result : RealArray(M'range(1)); -- Result
begin
	for i in result'range loop
		result(i) := M(i,col);
	end loop;

	return result;
end function MatrixGetColumn;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Extract a row
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Extract a column and return an array
-- Line   shall be the FIRST  index
-- Column shall be the SECOND index
function MatrixGetRow(M : SlMatrix; row : nat) return slv is                                        --===============================
	variable result : slv(M'range(2));                                                              --      1 2 3 4 5
begin                                                                                               --  1 / . . . . . \
	for i in result'range loop                                                                      --  2 | x x x x x |
		result(i) := M(row,i);                                                                      --  3 | . . . . . | = MatrixGetRow(M,2)
	end loop;                                                                                       --  4 | . . . . . |
                                                                                                    --  5 \ . . . . . /
	return result;                                                                                  --
end function MatrixGetRow;                                                                          --===============================

function MatrixGetRow(M : SlMatrix; row,col_start,col_stop: nat) return slv is                      --===============================
	variable result : slv(col_start to col_stop);                                                   --      1 2 3 4 5
begin                                                                                               --  1 / . . . . . \
	for i in result'range loop                                                                      --  2 | . . x x . |
		result(i) := M(row,i);                                                                      --  3 | . . . . . | = MatrixGetRow(M,2,3,4)
	end loop;                                                                                       --  4 | . . . . . |
                                                                                                    --  5 \ . . . . . /
	return result;                                                                                  --
end function MatrixGetRow;                                                                          --===============================

function MatrixGetRow(M : RealMatrix; row : nat) return RealArray is                                --===============================
	variable result : RealArray(M'range(2));                                                        --      1 2 3 4 5
begin                                                                                               --  1 / . . . . . \
	for i in result'range loop                                                                      --  2 | x x x x x |
		result(i) := M(row,i);                                                                      --  3 | . . . . . | = MatrixGetRow(M,2)
	end loop;                                                                                       --  4 | . . . . . |
                                                                                                    --  5 \ . . . . . /
	return result;                                                                                  --
end function MatrixGetRow;                                                                          --===============================

function MatrixGetRow(M : RealMatrix; row,col_start,col_stop: nat) return RealArray is              --===============================
	variable result : RealArray(col_start to col_stop);                                             --      1 2 3 4 5
begin                                                                                               --  1 / . . . . . \
	for i in result'range loop                                                                      --  2 | . . x x . |
		result(i) := M(row,i);                                                                      --  3 | . . . . . | = MatrixGetRow(M,2,3,4)
	end loop;                                                                                       --  4 | . . . . . |
                                                                                                    --  5 \ . . . . . /
	return result;                                                                                  --
end function MatrixGetRow;                                                                          --===============================

--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Replace a column
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
procedure MatrixSetColumn(M : inout SlMatrix; col : nat; data : slv) is
begin
	MatrixSetColumn(M,col,M'low(1),M'high(1),data);
end procedure MatrixSetColumn;


procedure MatrixSetColumn(M : inout SlMatrix; col,row_start,row_stop : nat; data : slv) is          --===============================
	variable data_row : int; -- Index for parsing row                                               --
begin                                                                                               --
	assert M'ascending(1)                                                                           --
		report "[MatrixSetColumn] : Providen Matrix shall be in ascending order !!"                 --
		severity failure;                                                                           --
	assert M'ascending(2)                                                                           --      1 2 3 4 5
		report "[MatrixSetColumn] : Providen Matrix shall be in ascending order !!"                 --  1 / . . . . . \
		severity failure;                                                                           --  2 | . . x . . |
	assert data'length=row_stop-row_start+1                                                         --  3 | . . x . . |
		report "[MatrixSetColumn] : Providen line doesn't have correct length !!"                   --  4 | . . x . . |
		       & " Column is from " & to_Str(data'left) & " to " & to_Str(data'right)               --  5 \ . . . . . /
		       & " / Expected from " & to_Str(row_start) & " to " & to_Str(row_stop)                --
		severity failure;                                                                           -- MatrixSetColumn(M,3,2,4,data)
                                                                                                    --
	-- Start from left position (considered as 'top')                                               --
	data_row := data'left;                                                                          --
                                                                                                    --
	for row in row_start to row_stop loop                                                           --
		M(row,col) := data(data_row);                                                               --
		if data'ascending then data_row := data_row + 1;                                            --
		else                   data_row := data_row - 1; end if;                                    --
	end loop;                                                                                       --
end procedure MatrixSetColumn;                                                                      --===============================

procedure MatrixSetColumn(M : inout RealMatrix; col : nat; data : RealArray) is
begin
	MatrixSetColumn(M,col,M'left(1),M'right(1),data);
end procedure MatrixSetColumn;

procedure MatrixSetColumn(M : inout RealMatrix; col,row_start,row_stop : nat; data : RealArray) is  --===============================
	variable data_row : int; -- Index for parsing data                                              --
begin                                                                                               --
	assert M'ascending(1)                                                                           --
		report "[MatrixSetColumn] : Providen Matrix shall be in ascending order !!"                 --
		severity failure;                                                                           --
	assert M'ascending(2)                                                                           --      1 2 3 4 5
		report "[MatrixSetColumn] : Providen Matrix shall be in ascending order !!"                 --  1 / . . . . . \
		severity failure;                                                                           --  2 | . . x . . |
	assert data'length=abs(row_stop-row_start)+1                                                    --  3 | . . x . . |
		report "[MatrixSetColumn] : Providen line doesn't have correct length !!"                   --  4 | . . x . . |
		       & " Column is from " & to_Str(data'left) & " to " & to_Str(data'right)               --  5 \ . . . . . /
		       & " / Expected from " & to_Str(row_start) & " to " & to_Str(row_stop)                --
		severity failure;                                                                           -- MatrixSetColumn(M,3,2,4,data)
                                                                                                    --
	-- Start from left position (considered as 'top')                                               --
	data_row := data'left;                                                                          --
                                                                                                    --
	for row in row_start to row_stop loop                                                           --
		M(row,col) := data(data_row);                                                               --
		if data'ascending then data_row := data_row + 1;                                            --
		else                   data_row := data_row - 1; end if;                                    --
	end loop;                                                                                       --
end procedure MatrixSetColumn;                                                                      --===============================
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Replace a row
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
procedure MatrixSetRow(M : inout SlMatrix; row : nat; data : slv) is
begin
	MatrixSetRow(M,row,M'left(2),M'right(2),data);
end procedure MatrixSetRow;

procedure MatrixSetRow(M : inout SlMatrix; row,col_start,col_stop : nat; data : slv) is             --===============================
	variable data_col : int; -- Index for parsing data                                              --
begin                                                                                               --
	assert M'ascending(1)                                                                           --
		report "[MatrixSetRow] : Providen Matrix shall be in ascending order !!"                    --
		severity failure;                                                                           --
	assert M'ascending(2)                                                                           --      1 2 3 4 5
		report "[MatrixSetRow] : Providen Matrix shall be in ascending order !!"                    --  1 / . . . . . \
		severity failure;                                                                           --  2 | . . x x . |
	assert data'length=abs(col_stop-col_start)+1                                                    --  3 | . . . . . |
		report "[MatrixSetRow] : Providen line doesn't have correct length !!"                      --  4 | . . . . . |
		       & " Row is from " & to_Str(data'left) & " to " & to_Str(data'right)                  --  5 \ . . . . . /
		       & " / Expected from " & to_Str(col_start) & " to " & to_Str(col_stop)                --
		severity failure;                                                                           -- MatrixSetRow(M,2,3,4,data)
                                                                                                    --
	-- Start from left position                                                                     --
	data_col := data'left;                                                                          -- Where 'x' are part of data
                                                                                                    --
	for col in col_start to col_stop loop                                                           --
		M(row,col) := data(data_col);                                                               --
		if data'ascending then data_col := data_col + 1;                                            --
		else                   data_col := data_col - 1; end if;                                    --
	end loop;                                                                                       --
end procedure MatrixSetRow;                                                                         --===============================

procedure MatrixSetRow(M : inout RealMatrix; row : nat; data : RealArray) is
begin
	MatrixSetRow(M,row,M'left(2),M'right(2),data);
end procedure MatrixSetRow;

procedure MatrixSetRow(M : inout RealMatrix; row,col_start,col_stop : nat; data : RealArray) is     --===============================
	variable data_col : int; -- Index for parsing data                                              --
begin                                                                                               --
	assert M'ascending(1)                                                                           --
		report "[MatrixSetRow] : Providen Matrix shall be in ascending order !!"                    --
		severity failure;                                                                           --
	assert M'ascending(2)                                                                           --      1 2 3 4 5
		report "[MatrixSetRow] : Providen Matrix shall be in ascending order !!"                    --  1 / . . . . . \
		severity failure;                                                                           --  2 | . . x x . |
	assert data'length=abs(col_stop-col_start)+1                                                    --  3 | . . . . . |
		report "[MatrixSetRow] : Providen line doesn't have correct length !!"                      --  4 | . . . . . |
		       & " Row is from " & to_Str(data'left) & " to " & to_Str(data'right)                  --  5 \ . . . . . /
		       & " / Expected from " & to_Str(col_start) & " to " & to_Str(col_stop)                --
		severity failure;                                                                           -- MatrixSetRow(M,2,3,4,data)
                                                                                                    --
	-- Start from left position                                                                     --
	data_col := data'left;                                                                          -- Where 'x' are part of data
                                                                                                    --
	for col in col_start to col_stop loop                                                           --
		M(row,col) := data(data_col);                                                               --
		if data'ascending then data_col := data_col + 1;                                            --
		else                   data_col := data_col - 1; end if;                                    --
	end loop;                                                                                       --
end procedure MatrixSetRow;                                                                         --===============================
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Swap Rows
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
procedure MatrixSwapRows (M : inout SlMatrix; row_a, row_b : nat) is
	variable old_row_a : slv(M'range(2)); -- Content of row a
	variable old_row_b : slv(M'range(2)); -- Content of row b
begin
	-- Save old rows
	old_row_a := MatrixGetRow(M,row_a);
	old_row_b := MatrixGetRow(M,row_b);

	-- Swap rows
	MatrixSetRow(M,row_a,old_row_b);
	MatrixSetRow(M,row_b,old_row_a);
end procedure MatrixSwapRows;

procedure MatrixSwapRows (M : inout RealMatrix; row_a, row_b : nat) is
	variable old_row_a : RealArray(M'range(2)); -- Content of row a
	variable old_row_b : RealArray(M'range(2)); -- Content of row b
begin
	-- Save old rows
	old_row_a := MatrixGetRow(M,row_a);
	old_row_b := MatrixGetRow(M,row_b);

	-- Swap rows
	MatrixSetRow(M,row_a,old_row_b);
	MatrixSetRow(M,row_b,old_row_a);
end procedure MatrixSwapRows;
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Addition
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
--  Such operation requires that both matrix have exactly the same dimensions
--
--     M           N              P
--
-- ( a b c )   ( j k l )   ( a+j b+k c+l )
-- ( d e f ) + ( m n o ) = ( d+m e+n f+o )
-- ( g h i )   ( p q r )   ( g+p h+q i+r )
--
function "+" (M : SlMatrix ; N : SlMatrix) return SlMatrix is
	variable P : SlMatrix(M'range(1),M'range(2)); -- Result
begin
	--Ensure that both matrixes have the same size (rows & columns)
	assert M'length(1)=N'length(1) and M'length(2)=N'length(2)
		report "[pkg_std] : Matrix addition must be done with two matrix of the same dimension !!"
		severity failure;

	for row in M'range(1) loop                        -- For all rows in M
		for col in M'range(2) loop                    --   For all cols in M
			P(row,col) := M(row,col) xor N(row,col);  --      Add objects
		end loop;                                     --
	end loop;                                         --
	return P;
end function "+";

function "+" (M : RealMatrix ; N : RealMatrix) return RealMatrix is
	variable P : RealMatrix(M'range(1),M'range(2)); -- Result
begin
	--Ensure that both matrixes have the same size (rows & columns)
	assert M'length(1)=N'length(1) and M'length(2)=N'length(2)
		report "[pkg_std] : Matrix addition must be done with two matrix of the same dimension !!"
		severity failure;

	for row in M'range(1) loop                      -- For all rows in M
		for col in M'range(2) loop                  --   For all cols in M
			P(row,col) := M(row,col) + N(row,col);  --      Add objects
		end loop;                                   --
	end loop;                                       --
	return P;
end function "+";

--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
-- Multiplication
--¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
--  Such operation requires that M columns number shall be equal to N rows number
--
--     M          N              P
--
-- ( a b c )   ( j k )   ( aj+bm+cp  ak+bn+cq )
-- ( d e f ) * ( m n ) = ( dj+em+fp  dk+en+fq )
--             ( p q )
--
function "*" ( M : SlMatrix; N : SlMatrix) return SlMatrix is
	constant P_ROW : int := M'length(1)             ; -- Number of rows    in P matrix = rows    in M
	constant P_COL : int := N'length(2)             ; -- Number of columns in P matrix = columns in N
	variable P     : SlMatrix(1 to P_ROW,1 to P_COL); -- Result
	variable tmp   : sl                             ; -- Partial result
	variable row_m : int                            ; -- Index for row    in M matrix
	variable row_n : int                            ; -- Index for row    in N matrix
	variable col_n : int                            ; -- Index for column in N matrix
begin
	-- Ensure that M'cols number = N'rows number
	assert M'length(2)=N'length(1)
		report "[pkg_std] : Can't perform multiplier with these matrix : M'cols(" & to_Str(M'length(2)) & ") must be equal to N'rows(" & to_Str(N'length(1)) & ")"
		severity failure;

	row_m := M'left(1);
	row_n := N'left(1);
	col_n := N'left(2);

	for row_p in 1 to P_ROW loop                                     -- For each row in P
		for col_p in 1 to P_COL loop                                 --   For each col in P
			tmp := '0';                                              --     Clear partial result
			                                                         --
			row_n := N'left(1);                                      --
			for col_m in M'range(2) loop                             --       For each col in M
				tmp := tmp xor (M(row_m,col_m) and N(row_n,col_n));  --         Accumulate product from M(row,i) * N(i,col)
				if N'ascending(1) then row_n := row_n + 1;           --
				else                   row_n := row_n - 1; end if;   --
			end loop;                                                --
			                                                         --
			P(row_p,col_p) := tmp;                                   --       When partial result is final, store result to destination matrix
		end loop;                                                    --
		                                                             --
		if M'ascending(1) then row_m := row_m + 1;                   --
		else                   row_m := row_m - 1; end if;           --
	end loop;                                                        --
	return P;
end function "*";

function "*" ( M : RealMatrix; N : RealMatrix) return RealMatrix is
	constant P_ROW : int := M'length(1)               ; -- Number of rows    in P matrix = rows    in M
	constant P_COL : int := N'length(2)               ; -- Number of columns in P matrix = columns in N
	variable P     : RealMatrix(1 to P_ROW,1 to P_COL); -- Result
	variable tmp   : real                             ; -- Partial result
	variable row_m : int                              ; -- Index for row    in M matrix
	variable row_n : int                              ; -- Index for row    in N matrix
	variable col_n : int                              ; -- Index for column in N matrix
begin
	-- Ensure that M'cols number = N'rows number
	assert M'length(2)=N'length(1)
		report "[pkg_std] : Can't perform multiplier with these matrix : M'cols(" & to_Str(M'length(2)) & ") must be equal to N'rows(" & to_Str(N'length(1)) & ")"
		severity failure;

	row_m := M'left(1);
	row_n := N'left(1);
	col_n := N'left(2);

	for row_p in 1 to P_ROW loop                                     -- For each row in P
		for col_p in 1 to P_COL loop                                 --   For each col in P
			tmp := 0.0;                                              --     Clear partial result
			                                                         --
			row_n := N'left(1);                                      --
			for col_m in M'range(2) loop                             --       For each col in M
				tmp := tmp + (M(row_m,col_m) * N(row_n,col_n));      --         Accumulate product from M(row,i) * N(i,col)
				if N'ascending(1) then row_n := row_n + 1;           --
				else                   row_n := row_n - 1; end if;   --
			end loop;                                                --
			                                                         --
			P(row_p,col_p) := tmp;                                   --       When partial result is final, store result to destination matrix
		end loop;                                                    --
		                                                             --
		if M'ascending(1) then row_m := row_m + 1;                   --
		else                   row_m := row_m - 1; end if;           --
	end loop;                                                        --
	return P;
end function "*";
--******************************************************************************
-- Polynomial
--******************************************************************************
-- dividend = quotient * divisor + remainder, with 0<remainder<quotient
--
--  dividend | divisor
-- ----------+--------
--    x y z  | quotient
--  remainder|
--
procedure PolyDivide( dividend  : in    slv
                    ; divisor   : in    slv
                    ; quotient  : inout slv
                    ; remainder : inout slv
                    ) is
	variable degree_remainder : int                                                  ; -- Polynomial degree of 'dividend'
	constant DEGREE_DIVISOR   : nat                                := PosMSB(divisor); -- Polynomial degree of 'divisor'
	constant ZERO_QUOTIENT    : slv(  quotient 'length-1 downto 0) := (others=>'0')  ;
	constant ZERO_REMAINDER   : slv(  remainder'length-1 downto 0) := (others=>'0')  ;
	variable working_bit      : nat                                                  ;
	variable working_value    : slv(2*dividend 'length-1 downto 0)                   ;
begin
	assert dividend 'low=0  report "[pkg_std / PolyDivide] : 'dividend'"  & " polynomial shall have the bit #0" severity failure;
	assert divisor  'low=0  report "[pkg_std / PolyDivide] : 'divisor'"   & " polynomial shall have the bit #0" severity failure;
	assert quotient 'low=0  report "[pkg_std / PolyDivide] : 'quotient'"  & " polynomial shall have the bit #0" severity failure;
	assert remainder'low=0  report "[pkg_std / PolyDivide] : 'remainder'" & " polynomial shall have the bit #0" severity failure;
	assert or1(divisor)='1' report "[pkg_std / PolyDivide] : 'divisor' shall be NON null !!!"                   severity failure; -- Division by 0 is not allowed

	-- Initialize internal values
	quotient  := ZERO_QUOTIENT;
	remainder := dividend     ;

	loop
		degree_remainder := PosMSB(remainder); -- Return (-1) if remainder=0

		-- Division is possible
		if degree_remainder>=DEGREE_DIVISOR then
			working_bit           := degree_remainder - DEGREE_DIVISOR                  ; -- Quotient / compute new sub-part
			quotient(working_bit) := '1'                                                ; -- Quotient / add this part
			working_value         := Extend0L(divisor & Dup('0',working_bit),working_value'length); -- Perform (sub-part)*(divisor)
			remainder             := remainder xor lsb(working_value,remainder'length)  ; -- Remove this (sub-part)*(divisor) from remainder
		-- Division is NOT possible => end
		else
			exit;
		end if;
	end loop;

end procedure PolyDivide;
--******************************************************************************
-- CRC
--******************************************************************************
-- This implementation is done according to RFC1071 (see http://www.faqs.org/rfcs/rfc1071.html for more details)
function crc_rfc1071(data : slv8array) return slv16 is
	variable sum    : uns17; -- Partial sum
	variable data16 : slv16; -- 16-bit word
	variable result : slv16; -- Result
begin
	sum := (others=>'0');
	for i in 0 to data'length/2-1 loop
		data16 := data(2*i+1) & data(2*i);
		sum    := sum + uns(data16);
		sum    := '0' & sum(15 downto 0) + sum(16);
	end loop;

	result := slv(not(sum(15 downto 0))); -- Don't return directly result because : (vcom-1200) Function "crc_rfc1071" return type index bounds do not match RETURN value index bounds
	return result;
end function crc_rfc1071;

-- This implementation is done according to RFC1071 (see http://www.faqs.org/rfcs/rfc1071.html for more details)
function crc_rfc1071(data : slv16; partial_crc : slv16) return slv16 is
	variable sum    : uns17; -- Partial sum
	variable data16 : slv16; -- 16-bit word
	variable result : slv16; -- Result
begin
	sum := '0' & uns(not(partial_crc));      -- Retrieve previous partial CRC
	sum := sum + uns(data);                  -- Add current data value
	sum := '0' & sum(15 downto 0) + sum(16); -- Propagate carry to LSB

	result := slv(not(sum(15 downto 0))); -- Don't return directly result because : (vcom-1200) Function "crc_rfc1071" return type index bounds do not match RETURN value index bounds
	return result;
end function crc_rfc1071;

end package body pkg_std;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
-- Description : Test entity for matricial product
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;

entity pkg_std_test_SlMatrixMult is generic
	( M_COL : nat                                  -- M / number of columns
	; M_ROW : nat                                  -- M / number of rows
	; N_COL : nat                                  -- N / number of columns
	; N_ROW : nat                                  -- N / number of rows
	); port                                        --
	( dmn   : in  domain                           -- Reset/clock
	; m     : in  SlMatrix(1 to M_ROW, 1 to M_COL) -- M matrix
	; n     : in  SlMatrix(1 to N_ROW, 1 to N_COL) -- N matrix
	; p     : out SlMatrix(1 to M_ROW, 1 to N_COL) -- P matrix
	);
end entity pkg_std_test_SlMatrixMult;

architecture rtl of pkg_std_test_SlMatrixMult is
	signal          m_r : SlMatrix(1 to M_ROW, 1 to M_COL); -- M matrix, registered version
	signal          n_r : SlMatrix(1 to N_ROW, 1 to N_COL); -- N matrix, registered version
	signal          p_x : SlMatrix(1 to M_ROW, 1 to N_COL); -- P matrix, registered version
begin

main :process(dmn)
begin
if dmn.rst='1' then
	for row in m_r'range(1) loop for col in m_r'range(2) loop m_r(row,col) <= '0'; end loop; end loop;
	for row in n_r'range(1) loop for col in n_r'range(2) loop n_r(row,col) <= '0'; end loop; end loop;
	for row in p_x'range(1) loop for col in p_x'range(2) loop p_x(row,col) <= '0'; end loop; end loop;
	for row in p  'range(1) loop for col in p  'range(2) loop p  (row,col) <= '0'; end loop; end loop;
elsif rising_edge(dmn.clk) then
	m_r <= m;
	n_r <= n;
	p_x <= m_r * n_r;
	p   <= p_x;
end if;
end process main;

end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--synthesis translate_off
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;

entity crc_rfc1071_tb is
end entity crc_rfc1071_tb;

architecture testbench of crc_rfc1071_tb is
	signal result_partial : slv16 := (others=>'1');
	signal result_full    : slv16 := (others=>'0');
begin

/*
Procedure
	* Adjacent octets to be checksummed are paired to form 16-bit words. The checksum field is cleared.
	* The 16-bit 1's complement sum is computed over the 16-bit words. Any overflows are added to the sum.
	* The 1's complement of this sum is placed in the checksum field.
	* To verify a checksum, the 1's complement sum is computed over the same set of octets, including the checksum field.
	* If the result is all 1 bits, the check succeeds.

Example (numerical values from RFC1071.rtf, §3)
           Normal     Swapped
           Order      Order
Byte 0/1 : 0001       0100
Byte 2/3 : F203       03F2
Byte 4/5 : F4F5       F5F4
Byte 6/7 : F6F7       F7F6
          -----      -----
Sum 1   : 2DDF0      1F2DC


           DDF0       F2DC
Carrys        2          1
           ----       ----
Sum2       DDF2       F2DD

Final Swap DDF2       DDF2

Checksum not(DDF2)=220D
*/

partial : process
	variable data16 : slv16;
begin
	wait for 10 ns;

	data16 := x"0001"; result_partial <= crc_rfc1071(data16,result_partial); wait for 10 ns;
	data16 := x"F203"; result_partial <= crc_rfc1071(data16,result_partial); wait for 10 ns;
	data16 := x"F4F5"; result_partial <= crc_rfc1071(data16,result_partial); wait for 10 ns;
	data16 := x"F6F7"; result_partial <= crc_rfc1071(data16,result_partial); wait for 10 ns;
	wait;
end process partial;

full : process
	variable data16 : slv8array(7 downto 0);
begin
	wait for 10 ns;
	data16(1) := x"00"; data16(0) := x"01";
	data16(3) := x"F2"; data16(2) := x"03";
	data16(5) := x"F4"; data16(4) := x"F5";
	data16(7) := x"F6"; data16(6) := x"F7";
	result_full <= crc_rfc1071(data16);
	wait;
end process full;

end architecture testbench;
--synthesis translate_on
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--synthesis translate_off
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;

entity poly_divide_tb is
end entity poly_divide_tb;

architecture testbench of poly_divide_tb is
begin

process
	variable dividend  : slv16 := x"0000";
	variable divisor   : slv16 := x"1021";
	variable quotient  : slv16           ;
	variable remainder : slv16           ;
begin
	wait for 10 ns;
	dividend := x"0000";
	PolyDivide(dividend,divisor,quotient,remainder);

	dividend := x"0001";
	PolyDivide(dividend,divisor,quotient,remainder);

	dividend := x"0002";
	PolyDivide(dividend,divisor,quotient,remainder);

	dividend := x"0003";
	PolyDivide(dividend,divisor,quotient,remainder);

	wait;
end process;

end architecture testbench;
--synthesis translate_on
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
