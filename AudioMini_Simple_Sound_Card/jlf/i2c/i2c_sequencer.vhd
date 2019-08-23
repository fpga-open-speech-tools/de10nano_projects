/*--------------------------------------------------------------------------------------------------------------------------------------------------------------
Copyright (c) ReFLEX CES 1998-2014
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Project     : I²C Interface
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Top level   : i2c_avalon.vhd
File        : i2c_sequencer.vhd
Author      : Jean-Louis FLOQUET
Organization: ReFLEX CES   http://www.reflexces.com
Created     : 2003/03/25
Last update : 2014/03/20 11:01
Version     : 3.01.01
Dependency  :
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Description : Main Sequencer for Master/Slave configurations
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  Rev.   |    Date    | Description
 3.01.01 | 2014/03/20 | 1) Chg : Record 'domain'
 3.00.02 | 2012/06/27 | 1) Enh : Capability to transfer 256bytes with a single start
         |            | 2) Fix : Slave boundary limit reached (=> no ACK received) on last byte to be transferred
 2.03.02 | 2011/06/23 | 1) Fix : sub_addr_done not driven for slave configuration
         | 2011/06/24 | 2) New : Add support for Use Sub-Address
 2.02.02 | 2009/03/30 | 1) Chg : std_logic_* replaced with numeric_std. Add pkg_std & pkg_std_unsigned
         | 2009/04/08 | 2) Fix : Unused core signals tied to idle (synthesis only)
 2.01.01 | 2007/11/16 | 2) Enh : Check start command
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

entity i2c_sequencer is generic
	( AGENT             : string                              -- "MASTER", "SLAVE"
	); port                                                   --
	( dmn               : in    domain                        -- Reset/clock
	; sm_core           : out   core_type                     -- Main core state machine
	; sm_core_r         : out   core_type                     -- Main core state machine (1 clock later)
	  ----------------------------------------------------------
	; scl_r             : in    sl                            -- I²C SCL (registered version)
	; sda_nd            : out   sl                            -- SDA Shift Register condition
	; sda_r             : in    sl                            -- I²C SDA (regeistered version)
	; sda_shift         : in    slv8                          --
	; bit_cnt           : in    slv3                          -- Bit counter
	; byte_cnt          : in    slv9                          -- Byte decounter (number of byte to be transferred)
	; sub_addr_done     : out   sl                            --
	  ----------------------------------------------------------
	  -- I²C timers and derivated signals                     --
	  ----------------------------------------------------------
	; scl_90            : in    sl                            -- SCL delayed of 90°
	; scl_90_fe         : in    sl                            -- SCL delayed of 90° (falling edge)
	; scl_90_re         : in    sl                            -- SCL delayed of 90° (rising  edge)
	; scl_stop          : in    sl                            -- I²C SCL Stopped => stop sm_core
	  ----------------------------------------------------------
	  -- Configuration registers                              --
	  ----------------------------------------------------------
	; i2c_addr          : in    slv7                          -- component address
	; i2c_rwn           : in    sl                            -- Read/Write
	; i2c_sbl           : in    sl                            -- Slave Boundary Limit (Master specific)
	; i2c_start         : in    sl                            -- Start Transaction (Master specific)
	; i2c_usa           : in    sl                            -- Use Sub-Address
	);
end entity i2c_sequencer;

architecture rtl of i2c_sequencer is
	---------------------------------------------------------
	-- Core state machine and associated signals (Master)
	---------------------------------------------------------
	signal auto_restart    : sl;                    -- Auto-restart a transaction after a missing Target Acknowledge
	signal core_m          : core_type;             -- Master core state machine
	signal core_m_r        : core_type;             -- Master core state machine (1 clock later)
	signal data_delay      : slv2; -- Delay for getting data from DPRAM
	-- synthesis translate_off
	signal i2c_dir_m       : rw_type;               -- I²C direction informative flag (not synthesized)
	-- synthesis translate_on
	signal sub_addr_done_i : sl;                    -- Sub-address has already been sent for this transaction
	---------------------------------------------------------
	-- Core state machine and associated signals (Slave)
	---------------------------------------------------------
	signal core_s          : core_type;             -- Slave core state machine
	signal core_s_r        : core_type;             -- Slave core state machine (1 clock later)
	signal restart_core    : sl;                    -- Restart the sequencer
	signal start_cond      : sl;                    -- START condition detected
	signal stop_cond       : sl;                    -- STOP  condition detected
	signal scl_line        : slv2;                  -- SCL buffer
	signal sda_line        : slv2;                  -- SDA buffer

begin

-- We have to do TWO separate signals (core_m & core_s) because these signals are nonresolved (enumerated type)
sm_core   <= core_m   when AGENT="MASTER" else core_s  ;
sm_core_r <= core_m_r when AGENT="MASTER" else core_s_r;
--###############################################################################################
--#                                            MASTER                                           #
--###############################################################################################
master : if AGENT="MASTER" generate
	-- I2C Bus Specifications 4.0.pdf, page 48, Table 10
	--  * Tbuf : bus free time between a STOP and START condition : 4.7µs minimum
	--
	process(dmn)
	begin
	if dmn.rst='1' then
		core_m          <= idle         ;
		auto_restart    <=          '0' ;
		core_m_r        <= idle         ;
		data_delay      <= (others=>'0');
		sda_nd          <=          '0' ;
		sub_addr_done_i <=          '0' ;
	elsif rising_edge(dmn.clk) then
		-----------------------------------------------------------------
		-- Sequencer
		-----------------------------------------------------------------
		case core_m is
			when idle              => if i2c_start='1'                                            then core_m <= start_prep       ; end if; -- Start (no more restriction on byte quantity because 0 now means 256 bytes)
			-- Start & Stop                                                                                                                 --
			when start_prep        => if scl_90   ='0'                                            then core_m <= start            ; end if; -- Wait for synchronisation
			when start             => if scl_90_fe='1'                                            then core_m <= addr_prep        ; end if; -- Send START condition
			when ack_failed        => if scl_90_fe='1'                                            then core_m <= stop             ; end if; -- Goes here after a non-received acknowledge
			when stop              => if scl_stop ='1'                                            then core_m <= eot              ; end if; -- Send STOP condition
			when eot               =>                                                                  core_m <= idle             ;         -- end of Transaction
			-- Address                                                                                                                      --
			when addr_prep         =>                                                                  core_m <= addr             ;         -- Prepare the component address
			when addr              => if scl_90_fe='1' and bit_cnt=1                              then core_m <= addr_rwn         ; end if; -- Send component address
			when addr_rwn          => if scl_90_fe='1'                                            then core_m <= addr_ack_wait    ; end if; -- Send direction bit
			when addr_ack_wait     => if scl_90   ='1' then                                                                                 -- Wait for Slave acknowledge
			                              if sda_r='0' then                                            core_m <= addr_ack_ok      ;         -- Acknowledge received
			                              else                                                         core_m <= ack_failed       ; end if; -- Acknowledge not received
			                          end if;                                                                                               --
			when addr_ack_ok       => if scl_90_fe='1' then                                                                                 --
			                              if i2c_usa='1' and (sub_addr_done_i='0' or i2c_sbl='1') then core_m <= sub_addr_prep    ;         -- Send sub-address if needed (Version 2.03.02)
			                              else                                                         core_m <= data_prep        ; end if; --
			                          end if;                                                                                               --
			-- Sub-Address                                                                                                                  --
			when sub_addr_prep     =>                                                                  core_m <= sub_addr         ;         -- Prepare the sub-address
			when sub_addr          => if scl_90_fe='1' and bit_cnt=0                              then core_m <= sub_addr_ack_wait; end if; -- Send sub-address bits
			when sub_addr_ack_wait => if scl_90   ='1' then                                                                                 -- Wait for Slave acknowledgement
			                              if sda_r='0'                                            then core_m <= sub_addr_ack_ok  ;         -- Sub-address is valid
			                              else                                                         core_m <= ack_failed       ; end if; -- Sub-address exceed boundary limit --> set 'error' flag
			                          end if;
			when sub_addr_ack_ok   => if scl_90_fe='1' then
			                              if i2c_rwn='0'                                          then core_m <= data_prep        ;
			                              else                                                         core_m <= start_prep       ; end if;
			                          end if;
			-- Data
			when data_prep         => if data_delay=0                                             then core_m <= data_prep_ok     ; end if; -- Prepare the next data (get it from internal memory)
			when data_prep_ok      =>                                                                  core_m <= data             ;         -- Data ready ==> store it into shift register

			-- Transferring data bits
			when data              => if bit_cnt=0 and scl_90_fe='1'                              then                                      -- Last bit transmitted
			                              if i2c_rwn='0'                                          then core_m <= data_ack_wait    ;         -- Master is sending data (write operation)
			                              else                                                         core_m <= data_ack_gen     ; end if; -- Master is receiving data (read operation)
			                          end if;

			-- Wait for Slave acknowledge (Write operation : sending data, receiving acknowledge)
			when data_ack_wait =>
				if scl_90='1' then
					if sda_r='0'     then core_m <= data_ack_ok;         -- Slave acknowledge --> can eventually send another one data
					elsif byte_cnt>1 then core_m <= data_end;            -- Slave doesn't acknowledge (boundary limit) and Master         need to transfer others data --> start a new transaction
					else                  core_m <= data_ack_ko; end if; -- Slave doesn't acknowledge (boundary limit) but Master doesn't need to transfer more   data --> finish (without error) the current transaction
				end if;
			when data_ack_ok =>
				if scl_90_fe='1' then
					core_m <= data_end;
				end if;
			when data_ack_ko =>
				if scl_90_fe='1' then
					core_m <= stop;
				end if;

			-- Generate an acknowledge (Read operation : receiving data, generating acknowledge)
			when data_ack_gen =>
				if scl_90_fe='1' then
					core_m <= data_end;
				end if;

			-- Check number of data to be transferred
			when data_end =>
				if    auto_restart='1' then core_m <= start_prep;
				elsif byte_cnt=1       then core_m <= stop;                       -- Last data has just been transferred
				else                        core_m <= data_prep; end if;          -- At least one more data to transfer
		end case;
		-----------------------------------------------------------------
		-- Misc.
		-----------------------------------------------------------------
		-- Auto-restart if Target doesn't acknowledge a byte and Master have others data to transfer
		if core_m/=data_ack_wait                      then auto_restart <= '0';
		elsif scl_90='1' and sda_r='1' and byte_cnt>1 then auto_restart <= '1'; end if;

		-- Save last state
		core_m_r <= core_m;

		-- Number of clock cycles needed to read internal memory block and put it in the SDA shift register
		if core_m/=data_prep then data_delay <= "10";
		else                      data_delay <= data_delay - 1; end if;

		-- Generate the SDA shift register condition
		if (i2c_rwn='1' and scl_90_re='1') or (i2c_rwn='0' and scl_90_fe='1') then sda_nd <= '1';
		else                                                                       sda_nd <= '0'; end if;

		-- Indicates if sub-address has been already sent to the target
		if core_m=stop                 then sub_addr_done_i <= '0';
		elsif core_m=sub_addr_ack_wait then sub_addr_done_i <= '1'; end if;
	end if;
	end process;

	sub_addr_done <= sub_addr_done_i;

	-- synthesis translate_off
	process(dmn)
	begin
	if dmn.rst='1' then
		i2c_dir_m <= read;
	elsif rising_edge(dmn.clk) then
		case core_m is
			when start  =>                     i2c_dir_m <= write;
			when data   => if i2c_rwn='1' then i2c_dir_m <= read;
				           else                i2c_dir_m <= write; end if;
			when others => null;
		end case;

		if i2c_start='1' and core_m/=idle   then report "Illegal start command while sequencer is active !!" severity failure; end if;
		if i2c_start='1' and Is_X(i2c_addr) then report "Illegal i2c_addr on start command !!"               severity failure; end if;
		if i2c_start='1' and Is_X(i2c_rwn)  then report "Illegal i2c_rwn on start command !!"                severity failure; end if;
	end if;
	end process;
	-- synthesis translate_on
end generate master;

--synthesis read_comments_as_HDL on
--master_noinst : if AGENT/="MASTER" generate
--	core_m   <= idle;
--	core_m_r <= idle;
--end generate master_noinst;
--synthesis read_comments_as_HDL off
--###############################################################################################
--#                                            SLAVE                                            #
--###############################################################################################
slave : if AGENT="SLAVE" generate
	sequencer : process(dmn,restart_core)
	begin
	-- Asynchrounsly restart core state machine on START or STOP conditions
	if dmn.rst='1' or restart_core='1' then
		core_s <= idle;
	elsif rising_edge(dmn.clk) then
		case core_s is
			when idle            => if start_cond='1'                 then core_s <= start          ; end if; -- Waiting START condition
			when start           => if scl_90_fe ='1'                 then core_s <= addr           ; end if; -- START condition detected
			-- Address
			when addr            => if scl_90_fe ='1' and bit_cnt=1   then core_s <= addr_rwn       ; end if; -- Receive broadcasted address
			when addr_rwn        => if scl_90_fe ='1'                 then core_s <= addr_ack_wait  ; end if; -- Receive direction bit
			when addr_ack_wait   => if sda_shift(7 downto 1)=i2c_addr then core_s <= addr_ack_ok    ; end if; -- Decode the received address and eventually claims the transaction
			when addr_ack_ok     => if scl_90_fe ='1' then                                                    -- Address succesfully decoded
			                            if sda_shift(0)='1'           then core_s <= data_prep      ;
			                            else                               core_s <= sub_addr       ; end if;
			                        end if;
			-- Sub-Address
			when sub_addr        => if scl_90_fe ='1' and bit_cnt=0   then core_s <= sub_addr_ack_ok; end if; -- Receive sub-address bits
			when sub_addr_ack_ok => if scl_90_fe ='1'                 then core_s <= data           ; end if; -- Generate acknowledge
			-- Data
			when data_prep       => if data_delay=0                   then core_s <= data_prep_ok   ; end if; -- Prepare the next data (get it from internal memory)
			when data_prep_ok    =>                                        core_s <= data           ;         -- Data ready ==> store it into shift register
			when data            => if scl_90_fe ='1' and bit_cnt=0   then                                    -- Transferring data bits
			                          if i2c_rwn ='0'                 then core_s <= data_ack_gen   ;
			                          else                                 core_s <= data_ack_wait  ; end if;
			                        end if;
			when data_ack_wait   => if scl_90_re ='1'                 then                                    -- Wait for Master acknowledge (Read operation : sending data)
			                            if sda_r ='0'                 then core_s <= data_ack_ok    ;
			                            else                               core_s <= idle           ; end if;
			                        end if;
			when data_ack_ok    => if scl_90_fe  ='1'                 then core_s <= data_end       ; end if;
			when data_ack_gen   => if scl_90_fe  ='1'                 then core_s <= data_end       ; end if; -- Generate an acknowledge (Write operation : receiving data)
			when data_end       => if i2c_rwn    ='1'                 then core_s <= data_prep      ;         -- Restart data phase
			                       else                                    core_s <= data           ; end if;
			when others         => null;                                                                      -- Some states are Master specific
		end case;
	end if;
	end process sequencer;

	process(dmn)
	begin
	if dmn.rst='1' then
		core_s_r   <= idle;
		data_delay <= (others=>'0');
		sda_nd     <= '0';
	elsif rising_edge(dmn.clk) then
		-- Save last state
		core_s_r <= core_s;

		-- Number of clock cycles needed to read internal memory block and put it in the SDA shift register
		if core_s/=data_prep then data_delay <= "10";
		else                      data_delay <= data_delay - 1; end if;

		-- SDA shift register shifting condition
		if (i2c_rwn='1' and scl_90_fe='1') or (i2c_rwn='0' and scl_90_re='1') then sda_nd <= '1';
		else                                                                       sda_nd <= '0'; end if;
	end if;
	end process;

	i2c_conditions_detector : process(dmn)
	begin
	if dmn.rst='1' then
		restart_core <= '0';
		scl_line     <= (others=>'0');
		sda_line     <= (others=>'0');
		start_cond   <= '0';
		stop_cond    <= '0';
	elsif rising_edge(dmn.clk) then

		-- Shift registers for SCL & SDA lines
		scl_line <= scl_line(0) & scl_r;
		sda_line <= sda_line(0) & sda_r;

		-- Detect START condition (valid until SCL goes low)
		if    scl_line="00"                   then start_cond <= '0';
		elsif scl_line="11" and sda_line="10" then start_cond <= '1'; end if;

		-- Detect STOP condition (valid until SCL goes low)
		if    scl_line="00"                   then stop_cond  <= '0';
		elsif scl_line="11" and sda_line="01" then stop_cond  <= '1'; end if;

		-- Detect START and STOP conditions (valid only one clock cycle)
		if scl_line="11" and (sda_line="10" or sda_line="01") then restart_core <= '1';
		else                                                       restart_core <= '0'; end if;
	end if;
	end process;

	sub_addr_done <= '0'; -- Version 2.03.01
end generate slave;

--synthesis read_comments_as_HDL on
--slave_noinst : if AGENT/="SLAVE" generate
--	core_s   <= idle;
--	core_s_r <= idle;
--end generate slave_noinst;
--synthesis read_comments_as_HDL off
end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
