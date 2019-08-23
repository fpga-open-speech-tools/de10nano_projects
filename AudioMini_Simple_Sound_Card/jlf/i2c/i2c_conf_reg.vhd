/*--------------------------------------------------------------------------------------------------------------------------------------------------------------
Copyright (c) ReFLEX CES 1998-2016
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Project     : I²C Interface
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Title       : I²C Configuration Registers
File        : i2c_conf_reg.vhd
Author      : Jean-Louis FLOQUET
Organization: ReFLEX CES   http://www.reflexces.com
Created     : 2003/03/25
Last update : 2016/02/16 10:26
Version     : 2.04.01
Dependency  :
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Description : Configurations registers
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  Rev.   |    Date    | Description
 2.04.01 | 2015/04/17 | 1) Fix : 2.02.01 regression with single cycle start vs buf_addr (was stucked to 0s)
 2.03.01 | 2014/03/20 | 1) Chg : Record 'domain'
 2.02.02 | 2011/04/21 | 1) Fix : start must be active only one clock cycle
         | 2011/06/23 | 2) Fix : sm_reference was not driven
         | 2011/06/24 | 3) New : Add 'usa' bit
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

entity i2c_conf_reg is generic
	( AGENT             : string                              -- "MASTER", "SLAVE"
	; AVL_DPS           : integer range 8 to 32               -- Avalon / Data    Path Size
	; MEM_MODE          : string                              -- "BUFFER" (registers), "CACHE" (memory)
	; S_ADDRESS         : integer                             -- I²C component address (must be legal for I²C compliance)
	); port                                                   --
	( dmn               : in  domain                          -- Reset/clock
	; sm_core           : in  core_type                       -- Main Core State Machine
	; sm_core_r         : in  core_type                       -- Main Core State Machine (last state)
	; sm_reference      : out reference_type                  -- Address reference byte (Slave specific)
	; sda_shift         : in  slv8                            --
	  ----------------------------------------------------------
	  -- Avalon                                               --
	; avl_address       : in  slv11                           -- CPU address
	; avl_chipselect    : in  sl                              -- CPU chip select
	; avl_write         : in  sl                              -- CPU write request
	; avl_writedata     : in  slv(AVL_DPS-1 downto 0)         -- CPU write data
	  ----------------------------------------------------------
	  -- Configuration registers                              --
	; ConfReg           : out Conf_Registers
	);
end entity i2c_conf_reg;

architecture rtl of i2c_conf_reg is
	signal iConfReg        : Conf_Registers;
	signal sm_reference_i  : reference_type; -- State Machine for saving bytes reference
	signal sub_addr_saved  : slv8          ; -- Save the "user" start sub_addr to be able to start again at the same sub_addr
begin

---------------------------------------------------------------------------
-- Configuration registers manager
---------------------------------------------------------------------------
process(dmn)
begin
if dmn.rst='1' then
	if AGENT="MASTER" then
		iConfReg <= CONF_REGISTERS_RST;
	end if;
	if AGENT="SLAVE" then
		iConfReg.addr     <= conv_slv(S_ADDRESS,iConfReg.addr'length);
		iConfReg.last_ref <= (others=>'1');
		iConfReg.rwn      <=          '0' ;
		iConfReg.sub_addr <= (others=>'0');
	end if;
	iConfReg.cirq  <=          '0' ;
	iConfReg.ieot  <=          '0' ;
	iConfReg.busy  <=          '0' ;
	iConfReg.stop  <=          '0' ;
	sub_addr_saved <= (others=>'0');
elsif rising_edge(dmn.clk) then
	iConfReg.cirq  <= '0';  -- Reset after IRQ cleared
	iConfReg.start <= '0';

	if avl_chipselect='1' and avl_write='1' then
		if AVL_DPS=8 then
			case conv_int(avl_address) is
				when 0      =>                            iConfReg.blk      <= avl_writedata(07 downto 06);
				                                          iConfReg.as       <= avl_writedata(          05);
				                                          iConfReg.usa      <= avl_writedata(          04);
				                                          iConfReg.cirq     <= avl_writedata(          03); -- Get bit from control byte
				                                          iConfReg.ieot     <= avl_writedata(          02);
				                                          iConfReg.rwn      <= avl_writedata(          01);
				                                          iConfReg.start    <= avl_writedata(          00);
				when 2      =>                            iConfReg.addr     <= avl_writedata(06 downto 00);
				when 3      => if iConfReg.start='0' then iConfReg.sub_addr <= avl_writedata;
				                                          sub_addr_saved    <= avl_writedata; end if;
				when 4      =>                            iConfReg.ndbt     <= avl_writedata;
				when 6      => if AGENT="MASTER"     then iConfReg.out_ctrl <= avl_writedata; end if;
				when others =>
			end case;
		elsif AVL_DPS=32 then
			case conv_int(avl_address) is
				when 0      =>                            iConfReg.blk      <= avl_writedata(07 downto 06);
				                                          iConfReg.as       <= avl_writedata(          05);
				                                          iConfReg.usa      <= avl_writedata(          04);
				                                          iConfReg.cirq     <= avl_writedata(          03); -- Get bit from control byte
				                                          iConfReg.ieot     <= avl_writedata(          02);
				                                          iConfReg.rwn      <= avl_writedata(          01);
				                                          iConfReg.start    <= avl_writedata(          00);
				                                          iConfReg.addr     <= avl_writedata(22 downto 16);
				               if iConfReg.start='0' then iConfReg.sub_addr <= avl_writedata(31 downto 24);
				                                          sub_addr_saved    <= avl_writedata(31 downto 24); end if;
				when 4      =>                            iConfReg.ndbt     <= avl_writedata(07 downto 00);
				               if AGENT="MASTER"     then iConfReg.out_ctrl <= avl_writedata(23 downto 16); end if;
				when others =>
			end case;
		end if;
	end if;

	if AGENT="MASTER" then
		if iConfReg.as='1' and iConfReg.start='0' and iConfReg.busy='0' and iConfReg.error='0' then
			iConfReg.start    <= '1';
			iConfReg.sub_addr <= sub_addr_saved;
		end if;

		if sm_core=data_end then iConfReg.sub_addr <= iConfReg.sub_addr + 1; end if; -- Auto-increment during transaction (after each byte transferred)
	end if;

	if sm_core=start_prep then
		if    sm_core_r=idle     then iConfReg.sbl <= '0';         -- Clear on starting transaction
		elsif sm_core_r=data_end then iConfReg.sbl <= '1'; end if; -- Set if another byte wanted and Slave doesn't acknowledge
	end if;

	   if sm_core=start      then iConfReg.error <= '0';           -- Clear on starting transaction
	elsif sm_core=ack_failed then iConfReg.error <= '1'; end if;   -- Set if no expected acknowledge

	if AGENT="MASTER" and MEM_MODE="BUFFER" then
		if iConfReg.start='1'  then iConfReg.buf_addr <= (others=>'0');                 -- start a new transaction
		elsif sm_core=data_end then iConfReg.buf_addr <= iConfReg.buf_addr + 1; end if; -- data transferred
	elsif (AGENT="MASTER" and MEM_MODE="CACHE") or AGENT="SLAVE" then
		iConfReg.buf_addr <= (others=>'0');
	end if;

	if AGENT="SLAVE" then
		-- Increment pointer on the first & last byte transferred
		if (sm_reference_i=idle     and sm_core=data_ack_gen) or
		   (sm_reference_i=wait_eot and sm_core=idle)   then iConfReg.last_ref <= iConfReg.last_ref + 1;
		end if;

		if    sm_core=addr                            then iConfReg.rwn      <= '0';                  -- Clear the flag
		elsif sm_core=addr_ack_ok                     then iConfReg.rwn      <= sda_shift(0); end if; -- Get information on the last address bit

		-- Start from sub-address then auto-increment on each byte transferred
		if    sm_core=sub_addr_ack_ok                 then iConfReg.sub_addr <= sda_shift;
		elsif sm_core=data_end                        then iConfReg.sub_addr <= iConfReg.sub_addr + 1; end if;
	end if;


	-- Informative flags
	case sm_core is
		when idle       => iConfReg.stop <= '1'; iConfReg.busy <= iConfReg.start;
		when start      => iConfReg.stop <= '0';
		when others     => null;
	end case;

end if;
end process;

slave : if AGENT="SLAVE" generate
	-- Last reference state machine
	process(dmn)
	begin
	if dmn.rst='1' then
		sm_reference_i <= idle;
	elsif rising_edge(dmn.clk) then
		case sm_reference_i is
			when idle        => if sm_core=data_ack_gen then sm_reference_i <= write_first ; end if; -- Get the first received byte address
			when write_first =>                              sm_reference_i <= wait_eot    ;         -- One clock cycle for write operation
			when wait_eot    => if sm_core=idle         then sm_reference_i <= write_second; end if; -- At the end of the transaction (STOP condition detected), get the last received byte address+1
			when write_second =>                             sm_reference_i <= idle        ;         -- One clock cycle for write operation
		end case;
	end if;
	end process;
end generate;

-- Version 2.02.02
sm_reference <= sm_reference_i;

ConfReg <= iConfReg;
end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
