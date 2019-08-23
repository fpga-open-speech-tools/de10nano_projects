/*--------------------------------------------------------------------------------------------------------------------------------------------------------------
Copyright (c) ReFLEX CES 1998-2014
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Project     : I²C Interface
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Title       : I²C Clock Generator
File        : i2c_clock.vhd
Author      : Jean-Louis FLOQUET
Organization: ReFLEX CES   http://www.reflexces.com
Created     : 2003/03/25
Last update : 2015/04/09 14:38
Version     : 3.02.01
Dependency  : pkg_std, pkg_std_unsigned, i2c_pkg
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Description : generate clock for I²C bus. when acting as I²C Master, handle clock stand-by from I²C Slave
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  Rev.   |    Date    | Description
 3.02.01 | 2015/04/09 | 1) New : User can specify the I²C clock period
 3.01.02 | 2014/03/20 | 1) Chg : Record 'domain'
         | 2014/09/19 | 2) Enh : 'PERIOD' is now a true constant
 3.00.00 | 2012/08/08 | 1) New : User can perform SMBus reset
 2.02.01 | 2011/06/23 | 1) Fix : scl1..scl7 was not high-Z in slave configuration
 2.01.02 | 2009/03/30 | 1) Chg : std_logic_arith replace with numeric_std
         | 2009/04/22 | 2) Chg : CLOCK (integer type) replaced by CLOCK_PERIOD (time type)
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

entity i2c_clock is generic
	( AGENT             : string                              -- "MASTER", "SLAVE"
	; CLOCK_PERIOD      : time                                -- Clock period
	; I2C_MODE          : string                              -- "STANDARD" (100kHz), "FAST" (400kHz), "USER" (see I2C_PERIOD)
	; I2C_PERIOD        : time                                -- User specific SCL clock period
	; SMBUS             : boolean                             -- Activate SMBus options
	); port                                                   --
	( dmn               : in    domain                        -- Reset/clock
	; smbus_rst         : in    sl                            -- SMBus / Reset
	; sm_core           : in    core_type                     -- Main core state machine
	; i2c_select        : in    slv8                          -- Select I²C bus
	; scl               : inout sl                            -- I²C SCL ('0' or 'Z', never drive to '1')
	; scl1              : inout sl                            -- I²C SCL ('0' or 'Z', never drive to '1')
	; scl2              : inout sl                            -- I²C SCL ('0' or 'Z', never drive to '1')
	; scl3              : inout sl                            -- I²C SCL ('0' or 'Z', never drive to '1')
	; scl4              : inout sl                            -- I²C SCL ('0' or 'Z', never drive to '1')
	; scl5              : inout sl                            -- I²C SCL ('0' or 'Z', never drive to '1')
	; scl6              : inout sl                            -- I²C SCL ('0' or 'Z', never drive to '1')
	; scl7              : inout sl                            -- I²C SCL ('0' or 'Z', never drive to '1')
	; scl_r             : in    sl                            -- I²C SCL read
	; scl_stop          : out   sl                            -- I²C SCL Stopped => stop sm_core
	; scl_90            : out   sl                            -- SCL 90° delayed
	; scl_90_fe         : out   sl                            -- SCL 90° delayed (falling edge)
	; scl_90_re         : out   sl                            -- SCL 90° delayed (rising  edge)
	; clk_dbg           : out   sl                            -- Clock for debugging I²C link (with SignalTap for example)
	);
end entity i2c_clock;

architecture rtl of i2c_clock is
	constant PERIOD_MASTER_STANDARD : int := NbClk(   10   us,CLOCK_PERIOD);
	constant PERIOD_MASTER_FAST     : int := NbClk(    2.5 us,CLOCK_PERIOD);
	constant PERIOD_MASTER_USER     : int := NbClk(I2C_PERIOD,CLOCK_PERIOD);

	function PeriodChoose return int is
		variable result : int;
	begin
		   if StrEq(I2C_MODE,"STANDARD") then result := PERIOD_MASTER_STANDARD;
		elsif StrEq(I2C_MODE,"FAST"    ) then result := PERIOD_MASTER_FAST    ;
		elsif StrEq(I2C_MODE,"USER"    ) then result := PERIOD_MASTER_USER    ; end if;
		return result;
	end function PeriodChoose;

	constant PERIOD                 : int    := PeriodChoose      ;

	signal   scl_idle               : sl                          ;
	signal   scl_o                  : sl                          ;
	signal   scl_90_o               : sl                          ; -- SCL line 90° shifted
	signal   scl_90_r               : sl                          ; -- SCL line 90° shifted (1 clock later)
	signal   scl_cnt_hi             : slv(Log2(PERIOD)   downto 0); -- Decounter for HIGH pulse
	signal   scl_cnt_lo             : slv(Log2(PERIOD)   downto 0); -- Decounter for LOW  pulse
	signal   clk_cnt                : slv(Log2(PERIOD)+1 downto 0);
	signal   clk_dbg_i              : sl                          ;

    -- Patch Quartus 14.1
    signal s_gnd        : std_logic;
    attribute keep      : boolean;
    attribute keep of s_gnd: signal is true;
begin

s_gnd <= '0';

process(dmn)
begin
if dmn.rst='1' then
	scl_90_r <= '0';
elsif rising_edge(dmn.clk) then
	scl_90_r <= scl_90_o;
end if;
end process;

scl_90    <= scl_90_o;
scl_90_fe <= not(scl_90_o) and     scl_90_r;
scl_90_re <=     scl_90_o  and not(scl_90_r);

---------------------------------------------------------------------------
-- Master clock generation
---------------------------------------------------------------------------
clk_gen_master : if AGENT="MASTER" generate
	process(dmn)
	begin
	if dmn.rst='1' then
		scl_idle   <= '0';
		scl_o      <= '1';
		scl_90_o   <= '0';
		scl_cnt_hi <= (others=>'0');
		scl_cnt_lo <= (others=>'0');
	elsif rising_edge(dmn.clk) then
		if    sm_core=start_prep            then scl_idle <= '0';
		elsif sm_core=stop and scl_90_o='1' then scl_idle <= '1'; end if;

		if scl_r='0' or sm_core=idle then scl_cnt_hi <= conv_slv(PERIOD/2,scl_cnt_hi'length); elsif msb(scl_cnt_hi)='0' then scl_cnt_hi <= scl_cnt_hi - 1; end if; -- Load when SCL=0 or IDLE / Decrease
		if scl_r='1'                 then scl_cnt_lo <= conv_slv(PERIOD/2,scl_cnt_lo'length); elsif msb(scl_cnt_lo)='0' then scl_cnt_lo <= scl_cnt_lo - 1; end if; -- Load when SCL=1         / Decrease

		-- I2C Bus Specifications 2.1 : PDF, page 8, § 5     : "When the bus is free, both lines are HIGH."
		-- I2C Bus Specifications 4.0 : PDF, page 8, § 3.1.1 : "When the bus is free, both lines are HIGH."
		   if msb(scl_cnt_hi)='1' and sm_core/=idle then scl_o <= '0';         -- High time level SCL expired ==> SCL goes low
		elsif msb(scl_cnt_lo)='1' or  sm_core =idle then scl_o <= '1'; end if; -- Low  time level SCL expired ==> SCL goes high (via external pull-up)

		-- Create 90° shifted SCL
		if    scl_cnt_lo=PERIOD/4 or sm_core=idle then scl_90_o <= '0';
		elsif scl_cnt_hi=PERIOD/4                 then scl_90_o <= '1'; end if;
	end if;
	end process;

	scl  <= s_gnd when (scl_o='0' and scl_idle='0' and i2c_select(0)='1') or (smbus_rst='1' and SMBUS) else 'Z';
	scl1 <= s_gnd when (scl_o='0' and scl_idle='0' and i2c_select(1)='1') or (smbus_rst='1' and SMBUS) else 'Z';
	scl2 <= s_gnd when (scl_o='0' and scl_idle='0' and i2c_select(2)='1') or (smbus_rst='1' and SMBUS) else 'Z';
	scl3 <= s_gnd when (scl_o='0' and scl_idle='0' and i2c_select(3)='1') or (smbus_rst='1' and SMBUS) else 'Z';
	scl4 <= s_gnd when (scl_o='0' and scl_idle='0' and i2c_select(4)='1') or (smbus_rst='1' and SMBUS) else 'Z';
	scl5 <= s_gnd when (scl_o='0' and scl_idle='0' and i2c_select(5)='1') or (smbus_rst='1' and SMBUS) else 'Z';
	scl6 <= s_gnd when (scl_o='0' and scl_idle='0' and i2c_select(6)='1') or (smbus_rst='1' and SMBUS) else 'Z';
	scl7 <= s_gnd when (scl_o='0' and scl_idle='0' and i2c_select(7)='1') or (smbus_rst='1' and SMBUS) else 'Z';

	scl_stop <= msb(scl_cnt_hi);
end generate clk_gen_master;
---------------------------------------------------------------------------
-- Slave clock generation
---------------------------------------------------------------------------
clk_gen_slave : if AGENT="SLAVE" generate
	-- Never drive SCL line (input only for SLAVE agent)
	scl      <= 'Z';
	scl1     <= 'Z'; -- 2.02.01
	scl2     <= 'Z';
	scl3     <= 'Z';
	scl4     <= 'Z';
	scl5     <= 'Z';
	scl6     <= 'Z';
	scl7     <= 'Z';
	scl_stop <= '0';

	process(dmn)
	begin
	if dmn.rst='1' then
		scl_90_o   <= '0';
		scl_cnt_hi <= (others=>'0');
		scl_cnt_lo <= (others=>'0');
	elsif rising_edge(dmn.clk) then
		if scl_r='0' then scl_cnt_hi <= conv_slv(PERIOD/2,scl_cnt_hi'length);  -- Load when SCL=0 or START
		else              scl_cnt_hi <= scl_cnt_hi - 1; end if;                -- Decrease
		if scl_r='1' then scl_cnt_lo <= conv_slv(PERIOD/2,scl_cnt_lo'length);  -- Load when SCL=1
		else              scl_cnt_lo <= scl_cnt_lo - 1; end if;                -- Decrease

		-- Create 90° shifted SCL
		if    scl_cnt_lo=PERIOD/4 then scl_90_o <= '0';
		elsif scl_cnt_hi=PERIOD/4 then scl_90_o <= '1'; end if;
	end if;
	end process;
end generate clk_gen_slave;
---------------------------------------------------------------------------
-- Misc.
---------------------------------------------------------------------------
process(dmn)
begin
if dmn.rst='1' then
	clk_cnt    <= (others=>'0');
	clk_dbg_i  <=          '0' ;
	clk_dbg    <=          '0' ;
elsif rising_edge(dmn.clk) then
	if msb(clk_cnt)='1' then clk_cnt <= '0' & conv_slv(PERIOD/20,clk_cnt'length-1);
	else                     clk_cnt <= clk_cnt - 1; end if;

	clk_dbg_i <= clk_dbg_i xor msb(clk_cnt);
	clk_dbg   <= clk_dbg_i;
end if;
end process;

end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
