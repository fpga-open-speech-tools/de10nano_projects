/*--------------------------------------------------------------------------------------------------------------------------------------------------------------
Copyright (c) ReFLEX CES 1998-2014
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Project     : I²C Interface
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Top level   : i2c_avalon.vhd
File        : i2c_pkg.vhd
Author      : Jean-Louis FLOQUET
Organization: ReFLEX CES   http://www.reflexces.com
Created     : 2003/03/25
Last update : 2014/02/25 15:08
Version     : 2.00
Dependency  : pkg_std, pkg_std_unsigned, pkg_simu
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Description : Global declarations
--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
library ieee;
use     ieee.std_logic_1164.all;
-- synthesis translate_off
use     std.textio.all;
-- synthesis translate_on

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;
--synthesis translate_off
use     work.pkg_simu.all;
--synthesis translate_on

package i2c_pkg is
-------------------------------------------------------------------------------
-- Type definition
-------------------------------------------------------------------------------
	type core_type is ( idle              --
	                  , start_prep        --
	                  , start             --
	                  , stop              --
	                  , eot               --
	                  , ack_failed        --
                                          --
	                  , addr_prep         --
	                  , addr              --
	                  , addr_rwn          --
	                  , addr_ack_wait     --
	                  , addr_ack_ok       --
                                          --
	                  , sub_addr_prep     --
	                  , sub_addr          --
	                  , sub_addr_ack_wait --
	                  , sub_addr_ack_ok   --
                                          --
	                  , data_prep         -- Wait for data from internal memory
	                  , data_prep_ok      -- Data from internal memory is available
	                  , data              --
	                  , data_ack_wait     --
	                  , data_ack_ok       --
	                  , data_ack_ko       --
	                  , data_ack_gen      --
	                  , data_end          --
	                  );

	type Conf_Registers is record
		start    : sl  ; -- 0x00.0   - Start Transaction (Master specific)
		rwn      : sl  ; -- 0x00.1   - Read/Write
		ieot     : sl  ; -- 0x00.2   - Enable "Interrupt on end of Transaction"
		cirq     : sl  ; -- 0x00.3   - Clear IRQ
		usa      : sl  ; -- 0x00.4   - Use Sub-Address (Master specific)
		as       : sl  ; -- 0x00.5   - Auto-Start
		blk      : slv2; -- 0x00.7:6 - Block Number (Master specific)

		stop     : sl  ; -- 0x01.0   - Transaction stopped
		busy     : sl  ; -- 0x01.1   - I²C bus busy
		error    : sl  ; -- 0x01.2   - Error occurred during previous transaction
		nsa      : sl  ; -- 0x01.3   - No Slave Answer (Master specific)
		sbl      : sl  ; -- 0x01.4   - Slave Boundary Limit (Master specific)

		addr     : slv7; -- 0x02     - component address
		sub_addr : slv8; -- 0x03     - Sub Address
		ndbt     : slv8; -- 0x04     - Number of Data to Be Transferred
		last_ref : slv8; -- 0x05     - Last reference address (Slave specific)
		out_ctrl : slv8; -- 0x06     - Output control

		buf_addr : slv8; -- 0x       - Specific to MEM_MODE="BUFFER" & AGENT="MASTER"
	end record Conf_Registers;

	-- synthesis translate_off
	type rw_type is (read,write);
	-- synthesis translate_on

	type reference_type is (idle, write_first, wait_eot, write_second);

	constant CONF_REGISTERS_RST : Conf_Registers := Conf_Registers'( start    =>          '0'
	                                                               , rwn      =>          '0'
	                                                               , ieot     =>          '0'
	                                                               , cirq     =>          '0'
	                                                               , usa      =>          '0'
	                                                               , as       =>          '0'
	                                                               , blk      => (others=>'0')

	                                                               , stop     =>          '0'
	                                                               , busy     =>          '0'
	                                                               , error    =>          '0'
	                                                               , nsa      =>          '0'
	                                                               , sbl      =>          '0'

	                                                               , addr     => (others=>'0')
	                                                               , sub_addr => (others=>'0')
	                                                               , ndbt     => (others=>'0')
	                                                               , last_ref => (others=>'0')
	                                                               , out_ctrl => "00000001"

	                                                               , buf_addr => (others=>'0')
	                                                               );



	type conv_nb_block_type is array (1 to 4) of integer range 8 to 10;
	constant NB_BLOCK_2_APS : conv_nb_block_type := (8,9,10,10);
--Note about this constant.
--  NB_BLOCK can take any value between 1 and 4. We must have :
--    *  8 bits addressing for NB_BLOCK=1.
--    *  9 bits addressing for NB_BLOCK=2.
--    * 10 bits addressing for NB_BLOCK=3.
--    * 10 bits addressing for NB_BLOCK=4.
-------------------------------------------------------------------------------
-- Function & Procedure declarations
-------------------------------------------------------------------------------
-- synthesis translate_off
	file log  : text open WRITE_MODE is "i2c_log.html";

	procedure closefiles    (a        : in    boolean);

	procedure end_simulation(dummy    : in    boolean := true);

	procedure write_error   (s        : in    string;
	                         stamp    : in    boolean := true);

	procedure write_header  (dummy    : in    boolean := false);

	procedure writeln       (file f   :       text;
	                         s        : in    string;
	                         stamp    : in    boolean :=true);

	procedure write_log     (s        : in    string;
	                         stamp    : in    boolean :=true);

	procedure write_r       (byte     : in    slv8;
	                         sub_addr : in    slv8);

	procedure write_start   (dummy    : in    boolean := false);

	procedure write_stop    (dummy    : in    boolean := false);

	procedure write_w       (byte     : in    slv8;
	                         sub_addr : in    slv8);

	procedure write_warning (s        : in    string;
	                         stamp    : in    boolean := true);
-- synthesis translate_on
end package i2c_pkg;

package body i2c_pkg is
-- synthesis translate_off
--#############################################################
--#                 File access primitives                    #
--#############################################################
------------------------------------------------------------------------------------
-- Close file
procedure closefiles (a : in boolean) is
begin
	write_log("</table>",false);
	write_log("<br>" & "<hr><b><center>End of log</center></b>",false);
	file_close(log);
end;
------------------------------------------------------------------------------------
-- Report an error
procedure write_error(s      : in    string;
	                  stamp  : in    boolean := true) is
begin
	write_log("<font color=#FF0000>" & s & "</font>");
end procedure;

procedure write_warning (s        : in    string;
	                     stamp    : in    boolean := true) is
begin
	write_log("<font color=#0000FF>" & s & "</font>");
end procedure;
------------------------------------------------------------------------------------
-- Write header in log file
procedure write_header(dummy : in boolean := false) is
begin
	write_log("<br><hr><p align=center><font size=5>I²C Events Logger</font></p><hr>",false);
	write_log("<table border=0>",false);
end procedure;
------------------------------------------------------------------------------------
-- Write a string to a file with a time stamp
-- All events must be logged with the stamp activated
-- Stamp can only be deactivated at the top & bottom of the file
procedure writeln (file f :    text;
                   s      : in string;
                   stamp  : in boolean:=true) is
	variable l : line;
	constant col1_start : string(1 to 16) := "<td align=right>";
	constant col1_end   : string(1 to  8) := " : </td>";
	constant col2_start : string(1 to  4) := "<td>";
	constant col2_end   : string(1 to  5) := "</td>";
	constant line_end   : string(1 to  5) := "</tr>";

begin
	-- Time stamp
	if stamp then
		write(l,col1_start);
		write(l,now,right,4,us);
		write(l,col1_end);
	end if;

	-- String
	if stamp then write(l,col2_start); end if;
	write(l,s);
	if stamp then write(l,col2_end); write(l,line_end); end if;

	writeline(f,l);
end;
------------------------------------------------------------------------------------
procedure write_log(s     : in string;
                    stamp : in boolean :=true) is
begin
	writeln(log,s,stamp);
end procedure;
------------------------------------------------------------------------------------
-- Data transaction reporting
procedure write_r(byte     : slv8;
                  sub_addr : slv8) is
begin
	write_log("Read  "
	          & "0x"       & to_StrHex(byte)
	          & " @ 0x"    & to_StrHex(sub_addr));
end procedure;

procedure write_w(byte     : slv8;
                  sub_addr : slv8) is
begin
	write_log("Write  "
	          & "0x"       & to_StrHex(byte)
	          & " @ 0x"    & to_StrHex(sub_addr));
end procedure;
------------------------------------------------------------------------------------
-- START and STOP conditions reporting
procedure write_start(dummy : in boolean := false) is
begin
	write_log("<font color=#009933>START</font>");
end procedure;

procedure write_stop(dummy : in boolean := false) is
begin
	write_log("<font color=#00FF00>STOP</font>");
	write_log("<td align=right>&nbsp</td><td>&nbsp</td></tr>",false);
end procedure;
------------------------------------------------------------------------------------

--#############################################################
--#                     Miscellaneous                         #
--#############################################################
procedure end_simulation(dummy  : in    boolean := true) is
begin
	closefiles(true);
	assert false report "end of simulation" severity failure;
end procedure;
-- synthesis translate_on

end package body i2c_pkg;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
