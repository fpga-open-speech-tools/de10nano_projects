/*--------------------------------------------------------------------------------------------------------------------------------------------------------------
Copyright (c) ReFLEX CES 1998-2016
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Project     : I²C Interface
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Top level   : i2c_avalon_tb.vhd
File        : i2c_virtual_slave.vhd
Author      : Jean-Louis FLOQUET
Organization: ReFLEX CES   http://www.reflexces.com
Created     : 2003/03/25
Last update : 2016/02/16 10:26
Version     : 2.06.01
Dependency  : pkg_std, pkg_std_unsigned, pkg_simu, i2c_pkg
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Description : Virtual Slave & Bus Monitor
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  Rev.   |    Date    | Description
 2.06.01 | 2014/03/20 | 1) Chg : Record 'domain'
 2.05.02 | 2013/11/20 | 1) Chg : VHDL-2008 required
         |            | 2) Chg : shared variable replaced with regular signal (event detection required)
 2.04.01 | 2012/07/13 | 1) Chg : Illegal I²C bus value are now reported with a failure level
 2.03.01 | 2011/10/20 | 1) Chg : Updated with SlvEq renamed to SlvEqImp in pkg_std
 2.02.02 | 2009/03/30 | 1) Chg : std_logic_* replaced with numeric_std. Add pkg_std & pkg_std_unsigned
         | 2009/04/03 | 2) New : Possibility to load internal registers with external array
 2.01.01 | 2007/11/16 | 1) Enh : Check start command
 1.00.00 | 2003/03/25 | Initial release
         |            |
--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
--synthesis translate_off
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;
use     work.pkg_simu.all;
use     work.i2c_pkg.all;

entity i2c_virtual_slave is generic
	( DEV_ADDR    : slv7_1                                                   -- Device Address
	; MONITOR_I2C : boolean := true                                          -- Monitor I²C bus and create HTML report
	; PAGE_SIZE   : integer := 256                                           -- Page Size. At the end of each page, this device doesn't send acknowledge bit.
	); port                                                                  --
	( scl         : in    sl                                                 -- I²C / Serial Clock
	; sda         : inout sl                                                 -- I²C / Serial Data
	; load        : in    sl                      :=                   '0'   -- Load array to internal registers
	; load_regs   : in    slv8array(255 downto 0) := (others=>(others=>'0')) -- Array to load into internal registers
	);
end entity i2c_virtual_slave;

architecture simulation of i2c_virtual_slave is
	---------------------------------------------------
	-- Virtual Slave
	---------------------------------------------------
	type tb_vs_type  is ( idle           --
	                    , start          --
	                    , stop           --
	                    , stop_waiting   --
	                    , addr           --
	                    , addr_rwn       --
	                    , addr_ack       --
	                    , sub_addr       --
	                    , sub_addr_ack   --
	                    , data_in        --
	                    , data_in_ack    --
	                    , data_out       --
	                    , data_out_ack   --
	                    );

	signal          tb_sm        : tb_vs_type             ; -- State machine
	signal          bit_index    : integer range 0 to 7   ; -- Bit index
	signal          mem_array    : slv8array(255 downto 0); -- Main memory
	signal          end_of_page  : boolean                ; -- end of page flag
	signal          i2c_addr     : slv7   := (others=>'-'); -- Device addres
	signal          i2c_rwn      : sl     :=          '-' ; -- Transaction direction
	signal          i2c_sub_addr : slv8   := (others=>'-'); -- Sub-address
	signal          i2c_byte     : slv8   := (others=>'-'); -- Byte
	---------------------------------------------------
	-- Monitor
	---------------------------------------------------
	type tb_mon_type is (idle, start, stop,
	                     addr, addr_rwn, addr_ack,
	                     sub_addr, sub_addr_ack,
	                     data, data_ack);
	signal i2c_monitor        : tb_mon_type;
	signal sda_shift          : slv8                 ;
	signal i2c_mon_addr       : slv8 := (others=>'0'); -- Device addres
	signal i2c_mon_byte       : slv8 := (others=>'0'); -- Byte
	signal i2c_mon_rwn        : sl   :=          '-' ; -- Transaction direction
	signal i2c_mon_sub_addr   : slv8 := (others=>'0'); -- Sub-address
	---------------------------------------------------
	-- others signals
	---------------------------------------------------
	signal scl_in             : sl                   ; -- SCL converted to '0' / '1' values
	signal sda_in             : sl                   ; -- SDA converted to '0' / '1' values
	signal sda_out            : sl                   ;
	signal reset              : sl  :=           '1' ; -- Reset


begin
sda    <= sda_out;
sda_in <= '0' when sda='0' else '1';
scl_in <= '0' when scl='0' else '1';

-- Auto-reset
process
begin
	wait for 1 ns;
	-- Write header in log file
	if MONITOR_I2C then write_header(true); end if;
	reset <= '0';
	wait;
end process;

-------------------------------------------------------------------------------------------
-- I²C Virtual Target
-------------------------------------------------------------------------------------------
i2c_vt : process(scl_in,sda_in,reset,load)
begin
if load='1' then
	mem_array <= load_regs; -- Version 2.02.02
end if;

if sda_in'event then
	if scl_in='1' then
		if sda_in='0' then tb_sm <= start;                     -- START condition
		else               tb_sm <= stop;                      -- STOP  condition
		end if;
	end if;

elsif falling_edge(scl_in) then
	case tb_sm is
		when start =>
			tb_sm <= addr;
			bit_index <= 7;

		-- Address phase
		when addr =>
			i2c_addr(bit_index-1) <= sda_in;                   -- Save SDA bit
			if bit_index=1 then
				tb_sm <= addr_rwn;                             -- end of address phase, goes to R/W bit
			end if;
			bit_index <= bit_index - 1;                        -- Decrease bit index

		-- R/W bit phase
		when addr_rwn =>
			tb_sm   <= addr_ack;
			i2c_rwn <= sda_in;

		-- Decode broadcasted component address
		when addr_ack =>
			if i2c_addr=DEV_ADDR then                          -- Claim transaction
				if i2c_rwn='1' then tb_sm <= data_out;         -- Read  operation ==> data phase
				else                tb_sm <= sub_addr; end if; -- Write operation ==> sub-address phase
			else                    tb_sm <= idle; end if;
			bit_index <= 7;

		-- Sub-address phase & acknowledge
		when sub_addr =>
			i2c_sub_addr(bit_index) <= sda_in;                 -- Save SDA bit
			if bit_index=0 then
				tb_sm <= sub_addr_ack;                         -- end of Sub-address phase, goes to ack
			else
				bit_index <= bit_index - 1;                    -- Decrease bit index
			end if;
		when sub_addr_ack =>
			if i2c_rwn='1' then tb_sm <= data_out;             -- Read operation  (VT  ==> I²C)
			else                tb_sm <= data_in; end if;      -- Write operation (I²C ==> VT )
			bit_index <= 7;

		-----------------------------------------------------
		-- Read this device
		-----------------------------------------------------
		when data_out =>
			if bit_index=0 then                                -- On the last data bit :
				tb_sm        <= data_out_ack;                  --      * waiting for acknowledge
				i2c_sub_addr <= i2c_sub_addr + 1;              --      * increase internal address
			else
				bit_index <= bit_index - 1;                    -- Decrease bit indexindex
			end if;

		when data_out_ack =>
			if sda_in='0' then
				tb_sm     <= data_out;                         -- Master acknowledge ==> one more byte
				bit_index <= 7;
			else
				tb_sm     <= stop_waiting;                     -- Master doesn't acknowledge ==> was last byte
			end if;

		-----------------------------------------------------
		-- Write to this device
		-----------------------------------------------------
		when data_in =>
			i2c_byte(bit_index) <= sda_in;                     -- Save SDA bit
			if bit_index=0 then
				tb_sm <= data_in_ack;                          -- Last bit ==> will generate acknowledge
			else
				bit_index <= bit_index - 1;                    -- Decrease bit index
			end if;

		when data_in_ack =>
			tb_sm     <= data_in;
			bit_index <= 7;
			if load='0' then
				mem_array(conv_int(i2c_sub_addr)) <= i2c_byte; -- Update internal memory
			end if;
			i2c_sub_addr <= i2c_sub_addr + 1;                  -- Increment address pointer

		when stop_waiting => null;

		when others => null;
	end case;
end if;

end process;

sda_out <= '0' when tb_sm=addr_ack and i2c_addr=DEV_ADDR                                else -- component address acknowledge
           '0' when tb_sm=sub_addr_ack                                                  else -- Sub-address acknowledge
           '0' when tb_sm=data_out and mem_array(conv_int(i2c_sub_addr))(bit_index)='0' else -- Provide read data bits
           '0' when tb_sm=data_in_ack and not(end_of_page)                              else -- Acknowledge for next byte if not end of current page
           'Z';

-- Calculate end of page from current sub-address
end_of_page <= (conv_int(i2c_sub_addr) mod PAGE_SIZE)=PAGE_SIZE-1;

-------------------------------------------------------------------------------------------
-- I²C Monitor
-------------------------------------------------------------------------------------------
monitor : if MONITOR_I2C generate
	-- Main Sequencer
	process(scl,sda,reset)
		variable bit_left    : integer range 0 to 8;
		variable i2c_running : boolean := false;
	begin
	if reset='1' then
		bit_left    := 0 ;
		i2c_monitor <= idle;
	elsif sda'event and scl='H' then        -- START or STOP condition
		if bit_left/=0 and bit_left/=8 then -- exclude START and STOP conditions...
			--assert false report "Suspicious transition" severity warning;
		elsif    sda='0' then
			i2c_running := true;
			i2c_monitor <= start;
		elsif sda='H' then
			i2c_running := false;
			i2c_monitor <= stop;
		else
			assert false report "Suspicious transition level" severity warning;
		end if;
	elsif rising_edge(scl) and i2c_running then
		case i2c_monitor is
			when start =>
				bit_left    := 7;
				i2c_monitor <= addr;

			-- Address phase
			when addr =>
				bit_left := bit_left - 1;
				if bit_left=0 then                               -- On last bit :
					i2c_mon_addr <= '0' & sda_shift(6 downto 0); --     * save component address (on 8bits length)
					i2c_monitor  <= addr_rwn;                    --     * goes to transfer direction
				end if;

			-- R/W bit
			when addr_rwn =>
				i2c_mon_rwn <= sda_shift(0);                     -- Save transfer direction
				i2c_monitor <= addr_ack;                         -- wait for acknowledge

			-- Address acknowledge
			when addr_ack =>
				bit_left  := 8;
				if i2c_mon_rwn='0' then
					i2c_monitor <= sub_addr;                     -- write operation ==> next byte is sub-address
				else
					i2c_monitor <= data;                         -- read  operation ==> next byte is data
				end if;

			-- Sub-address phase
			when sub_addr =>
				bit_left := bit_left - 1;
				if bit_left=0 then
					i2c_mon_sub_addr <= sda_shift;               -- Save sub-address
					i2c_monitor      <= sub_addr_ack;            -- wait for acknowledge
				end if;

			-- Sub-address acknowledge
			when sub_addr_ack =>
				bit_left    := 8;
				i2c_monitor <= data;

			-- Data phase
			when data =>
				bit_left := bit_left - 1;
				if bit_left=0 then
					i2c_mon_byte <= sda_shift;                   -- Save data
					i2c_monitor  <= data_ack;                    -- wait for acknowledge
				end if;

			-- Data acknowledge
			when data_ack =>
				bit_left         := 8;
				i2c_mon_sub_addr <= i2c_mon_sub_addr + 1;        -- Increment sub-address
				i2c_monitor      <= data;                        -- return to data phase

			when others => null;
		end case;
	end if;
	end process;

	-- SDA Shift Register
	process(scl)
	begin
	if falling_edge(scl) then
		if sda='0' then sda_shift <= sda_shift(6 downto 0) & '0';
		else            sda_shift <= sda_shift(6 downto 0) & '1'; end if;
	end if;
	end process;
	-------------------------------------------------------------------------------------------
	-- Log writter
	-------------------------------------------------------------------------------------------
	process(scl,sda,i2c_monitor)
	begin
	if sda'event and scl/='0' and now/=0 ns then
		if sda='0' then write_start(true);
		else            write_stop (true); end if;
	end if;

	if falling_edge(scl) then
		case i2c_monitor is
			when addr_ack     =>
				write_log("component address : " & "0x" & to_StrHex(i2c_mon_addr));
				if sda/='0' then
					write_warning("No Target Answer");
				end if;

			when sub_addr_ack =>
				write_log("Sub-address : " & "0x" & to_StrHex(i2c_mon_sub_addr));

			when data_ack     =>
				if i2c_mon_rwn='1' then write_r(i2c_mon_byte,i2c_mon_sub_addr);
				else                    write_w(i2c_mon_byte,i2c_mon_sub_addr); end if;

			when others       => null;
		end case;
	end if;

	end process;

	process(scl,sda,i2c_monitor)
	begin
	if sda'event then
		if sda='1' then printf(failure,"SDA driven to high !"   ); end if;
		if sda='X' then printf(failure,"SDA conflict !"         ); end if;
		if sda='U' then printf(failure,"SDA unknown state !"    ); end if;
		if sda='Z' then printf(failure,"SDA illegal tri-state !"); end if;
	end if;

	if scl'event then
		if scl='1' then printf(failure,"SCL driven to high !"   ); end if;
		if scl='X' then printf(failure,"SCL conflict !"         ); end if;
		if scl='U' then printf(failure,"SCL unknown state !"    ); end if;
		if scl='Z' then printf(failure,"SCL illegal tri-state !"); end if;
	end if;

	if i2c_monitor'event and i2c_monitor=addr_rwn then
		if SlvEqImp(i2c_mon_addr(6 downto 0),"0000000") then write_error("Illegal Slave Base Address : must be different of 000.0000, General Call Address / Start byte"); end if;
		if SlvEqImp(i2c_mon_addr(6 downto 0),"0000001") then write_error("Illegal Slave Base Address : must be different of 000.0001, CBUS address                     "); end if;
		if SlvEqImp(i2c_mon_addr(6 downto 0),"0000010") then write_error("Illegal Slave Base Address : must be different of 000.0010, Reserved for different bus format"); end if;
		if SlvEqImp(i2c_mon_addr(6 downto 0),"0000011") then write_error("Illegal Slave Base Address : must be different of 000.0011, Reserved for future purpose      "); end if;
		if SlvEqImp(i2c_mon_addr(6 downto 0),"00001--") then write_error("Illegal Slave Base Address : must be different of 000.01XX, HS-mode master code              "); end if;
		if SlvEqImp(i2c_mon_addr(6 downto 0),"11110--") then write_error("Illegal Slave Base Address : must be different of 111.10XX, 10-bit slave addressing          "); end if;
		if SlvEqImp(i2c_mon_addr(6 downto 0),"11111--") then write_error("Illegal Slave Base Address : must be different of 111.11XX, Reserved for future purpose      "); end if;
	end if;
	end process;
end generate;
end architecture simulation;
-- synthesis translate_on
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
