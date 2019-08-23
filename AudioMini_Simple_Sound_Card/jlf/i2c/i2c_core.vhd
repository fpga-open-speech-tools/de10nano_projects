/*--------------------------------------------------------------------------------------------------------------------------------------------------------------
Copyright (c) ReFLEX CES 1998-2014
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Project     : I²C Interface
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Title       : I²C Core
File        : i2c_core.vhd
Author      : Jean-Louis FLOQUET
Organization: ReFLEX CES   http://www.reflexces.com
Created     : 2003/03/25
Last update : 2015/04/09 14:39
Version     : 3.02.01
Dependency  :
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Description : Connect sub-entities and perform some basic operations
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  Rev.   |    Date    | Description
 3.02.01 | 2015/04/09 | 1) New : User can specify the I²C clock period
 3.01.01 | 2014/03/20 | 1) Chg : Record 'domain'
 3.00.02 | 2012/06/27 | 1) Enh : Capability to transfer 256bytes with a single start
         | 2012/08/08 | 2) New : User can perform SMBus reset
 2.02.05 | 2009/03/30 | 1) Chg : std_logic_* replaced with numeric_std. Add pkg_std & pkg_std_unsigned
         | 2009/03/30 | 2) Chg : Asynchronous reset not anymore cleaned by internal logic (shall be done by caller)
         | 2009/04/22 | 3) Chg : CLOCK (integer type) replaced by CLOCK_PERIOD (time type)
         | 2011/04/21 | 4) Enh : Cleaned start bit (useless transition at the end)
         | 2011/06/24 | 5) New : Add support for Use Sub-Address
 2.01.01 | 2007/11/16 | 1) New : Emulate on-board pull-up
 2.00.01 | 2003/05/29 | 1) Enh : Capability to use without Nios
 1.00.00 | 2003/03/25 | Initial release
         |            |
----------------------------------------------------------------------------------------------------------------------------------------------------------------
¤¤¤¤¤¤¤¤¤¤¤¤
¤ Notes    ¤
¤¤¤¤¤¤¤¤¤¤¤¤
* [Note 1] : Master Acknowledge (See "THE I2C-BUS SPECIFICATION", Version 2.1, January 2000, §7.2, pdf page 10/46)
        +-----
        | If a master-receiver is involved in a transfer, it must signal the end of data to the slave- transmitter by not generating an acknowledge on the
        | last byte that was clocked out of the slave. The slave-transmitter must release the data line to allow the master to generate a STOP or repeated
        | START condition.
        +-----

* [Note 2] : Generate a reset on SMBus
        +-----
        | First of all, generic parameter 'SMBUS' shall be set to true. Then, user can generate a SMBus reset by asserting simultaneously both 'rst' and
        | 'smbus_rst' during the minimum period according to its board specifications. It's the user responsability to ensure that these both signals
        | are set simultaneously and nothing happen on the backend during this time.
        +-----

--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;
use     work.i2c_pkg.all;

entity i2c_core is generic
	( AGENT             : string  := "MASTER"                 -- "MASTER", "SLAVE"
	; CLOCK_PERIOD      : time    := 10 ns                    -- Clock period
	; I2C_MODE          : string  := "STANDARD"               -- "STANDARD" (100kHz), "FAST" (400kHz), "USER" (see I2C_PERIOD)
	; I2C_PERIOD        : time    := 10 us                    -- User specific SCL clock period
	; SMBUS             : boolean := false                    -- Activate SMBus options
	  --synthesis translate_off                               --
	; VERBOSE           : boolean := false                    -- Verbose mode
	  --synthesis translate_on                                --
	); port                                                   --
	( dmn               : in    domain                        -- Reset/clock
	; smbus_rst         : in    sl        :=          '0'     -- SMBus / Reset
	  -- Backend signals                                      --
	; i2c_addr          : in    slv7                          -- I²C component address 7bits (!!!) (must be legal for I²C compliance)
	; i2c_rwn           : in    sl                            -- Read/Write
	; i2c_data_from     : out   slv8                          -- Data Received from I²C
	; i2c_data_to       : in    slv8                          -- Data to Write to I²C
	; i2c_data_ok       : out   sl                            -- Data transferred
	; i2c_busy          : out   sl                            -- I²C Bus Busy
	; i2c_select        : in    slv8      := "00000001"       -- Select I²C bus
	; i2c_finish        : out   sl                            -- Current bus cycle finished
	  -- Backend signals (Master specific)                    --
	; i2c_start         : in    sl        :=          '0'     -- Start Transaction
	; i2c_sub_addr      : in    slv8      := (others=>'0')    -- Sub Address
	; i2c_sbl           : in    sl        :=          '0'     -- Slave Boundary Limit
	; i2c_ndbt          : in    slv8      := (others=>'0')    -- Number of Data to Be Transferred
	; i2c_usa           : in    sl        :=          '0'     -- Use Sub-Address
	  -- I²C Avalon Core (hidden signals)                     --
	; h_sm_core         : out   core_type                     -- Main core state machine
	; h_sm_core_r       : out   core_type                     -- Main core state machine (1 clock later)
	; h_sda_shift       : out   slv8                          -- SDA Shift register (data to send or received)
	; clk_dbg           : out   sl                            -- Clock for debugging I²C link (with SignalTap for example)
	  -- I²C                                                  --
	; scl               : inout sl                            -- SCL ('0' or 'Z', never drive to '1')
	; sda               : inout sl                            -- SDA ('0' or 'Z', never drive to '1')
	; scl1              : inout sl                            -- SCL, bus #1   ('0' or 'Z', never drive to '1')
	; sda1              : inout sl                            -- SDA, bus #1   ('0' or 'Z', never drive to '1')
	; scl2              : inout sl                            -- SCL, bus #2   ('0' or 'Z', never drive to '1')
	; sda2              : inout sl                            -- SDA, bus #2   ('0' or 'Z', never drive to '1')
	; scl3              : inout sl                            -- SCL, bus #3   ('0' or 'Z', never drive to '1')
	; sda3              : inout sl                            -- SDA, bus #3   ('0' or 'Z', never drive to '1')
	; scl4              : inout sl                            -- SCL, bus #4   ('0' or 'Z', never drive to '1')
	; sda4              : inout sl                            -- SDA, bus #4   ('0' or 'Z', never drive to '1')
	; scl5              : inout sl                            -- SCL, bus #5   ('0' or 'Z', never drive to '1')
	; sda5              : inout sl                            -- SDA, bus #5   ('0' or 'Z', never drive to '1')
	; scl6              : inout sl                            -- SCL, bus #6   ('0' or 'Z', never drive to '1')
	; sda6              : inout sl                            -- SDA, bus #6   ('0' or 'Z', never drive to '1')
	; scl7              : inout sl                            -- SCL, bus #7   ('0' or 'Z', never drive to '1')
	; sda7              : inout sl                            -- SDA, bus #7   ('0' or 'Z', never drive to '1')
	);
end entity i2c_core;

architecture rtl of i2c_core is
	---------------------------------------------------------
	-- Core state machine and associated signals
	---------------------------------------------------------
	signal sm_core       : core_type; -- Main core state machine
	signal sm_core_r     : core_type; -- Main core state machine (1 clock later)
	signal sub_addr_done : sl       ; -- Sub-address has already been sent for this transaction
	signal bit_cnt       : slv3     ; -- Bit counter
	signal byte_cnt      : slv9     ; -- Byte decounter (number of byte to be transferred)
	signal sda_shift     : slv8     ; -- SDA Shift register (data to send or received)
	signal sda_nd        : sl       ; -- SDA shift register condition
	---------------------------------------------------------
	-- Register I²C signals
	---------------------------------------------------------
	signal scl_r         : sl       ;
	signal sda_o         : sl       ;
	signal sda_r         : sl       ;
	---------------------------------------------------------
	-- I²C timers and derivated signals
	---------------------------------------------------------
	signal scl_90        : sl       ; -- SCL delayed of 90°
	signal scl_90_fe     : sl       ; -- SCL delayed of 90° (falling edge)
	signal scl_90_re     : sl       ; -- SCL delayed of 90° (rising  edge)
	signal scl_stop      : sl       ; -- I²C SCL Stopped => stop sm_core

    -- Patch Quartus 14.1
    signal s_gnd        : std_logic;
    attribute keep      : boolean;
    attribute keep of s_gnd: signal is true;

begin

s_gnd <= '0';

--------------------------------------------------------------------------
-- SDA Line manager
---------------------------------------------------------------------------
sda_master : if AGENT="MASTER" generate
	sda_shift_reg : process(dmn)
	begin
	if dmn.rst='1' then
		bit_cnt   <= (others=>'0');
		byte_cnt  <= (others=>'0');
		sda_shift <= (others=>'0');
	elsif rising_edge(dmn.clk) then
		-- Bit counter
		if sm_core=addr_prep or sm_core=sub_addr_prep or sm_core=data_prep then bit_cnt <= "111";
		elsif bit_cnt/=0 and scl_90_fe='1'                                 then bit_cnt <= bit_cnt - 1; end if;

		-- Byte counter
		if    sm_core=idle                     then
			if i2c_ndbt=0                      then byte_cnt <= conv_slv(256,byte_cnt'length);
			else                                    byte_cnt <= '0' & i2c_ndbt; end if;
		elsif sm_core=data_end and byte_cnt/=0 then byte_cnt <= byte_cnt - 1; end if;

		case sm_core is
			when addr_prep                  =>                       sda_shift(7 downto 1) <= i2c_addr                                       ; -- Load component address
			                                                         sda_shift(0)          <= (    i2c_usa  and i2c_rwn and sub_addr_done) or  -- LSB forced to '0' (write) on the first part
			                                                                                  (not(i2c_usa) and i2c_rwn                  )   ; -- LSB directly provided by backend (Version 2.02.05)
			when sub_addr_prep              =>                       sda_shift             <= i2c_sub_addr                 ;                   -- Load sub-address
			when addr | addr_rwn | sub_addr => if scl_90_fe='1' then sda_shift             <= sda_shift(6 downto 0) & sda_r; end if;           -- SDA shift register when SCL=0 (Write I²C)
			when data_prep_ok               => if i2c_rwn  ='0' then sda_shift             <= i2c_data_to                  ; end if;           -- Load data
			when data                       => if sda_nd   ='1' then sda_shift             <= sda_shift(6 downto 0) & sda_r; end if;           -- SDA shift register when SCL=1 (read data) or SCL=0 (write data)
			when others => null;
		end case;
	end if;
	end process;

	sda_mgr : process(dmn)
	begin
	if dmn.rst='1' then
		sda_o <= '1';
	elsif rising_edge(dmn.clk) then
		case sm_core is
			when start                      => if scl_90 ='1' then sda_o <=          '0'; end if; -- Generate the START condition (Version 2.02.04)
			when stop                       =>                     sda_o <=     scl_90  ;         -- Generate the STOP condition
			when addr_prep                  => null;                                              -- Version 2.02.04
			when addr | addr_rwn | sub_addr =>                     sda_o <= sda_shift(7);         -- Get the MSB from SDA shift register
			when data                       => if i2c_rwn='0' then sda_o <= sda_shift(7);
			                                   else                sda_o <=          '1'; end if; -- Put MSB on SDA line (write) or inhibit SDA shift register
			when data_ack_gen               => if byte_cnt>1  then sda_o <=          '0'; end if; -- Master-Receiver
			when others                     =>                     sda_o <=          '1';         -- Do not drive SDA
		end case;
	end if;
	end process;
		-- Drive I²C SDA line
		sda  <= s_gnd when (sda_o='0' and sm_core/=idle and sm_core/=eot and i2c_select(0)='1') or (smbus_rst='1' and SMBUS) else 'Z';
		sda1 <= s_gnd when (sda_o='0' and sm_core/=idle and sm_core/=eot and i2c_select(1)='1') or (smbus_rst='1' and SMBUS) else 'Z';
		sda2 <= s_gnd when (sda_o='0' and sm_core/=idle and sm_core/=eot and i2c_select(2)='1') or (smbus_rst='1' and SMBUS) else 'Z';
		sda3 <= s_gnd when (sda_o='0' and sm_core/=idle and sm_core/=eot and i2c_select(3)='1') or (smbus_rst='1' and SMBUS) else 'Z';
		sda4 <= s_gnd when (sda_o='0' and sm_core/=idle and sm_core/=eot and i2c_select(4)='1') or (smbus_rst='1' and SMBUS) else 'Z';
		sda5 <= s_gnd when (sda_o='0' and sm_core/=idle and sm_core/=eot and i2c_select(5)='1') or (smbus_rst='1' and SMBUS) else 'Z';
		sda6 <= s_gnd when (sda_o='0' and sm_core/=idle and sm_core/=eot and i2c_select(6)='1') or (smbus_rst='1' and SMBUS) else 'Z';
		sda7 <= s_gnd when (sda_o='0' and sm_core/=idle and sm_core/=eot and i2c_select(7)='1') or (smbus_rst='1' and SMBUS) else 'Z';
end generate sda_master;

sda_slave : if AGENT="SLAVE" generate
	sda_shift_reg : process(dmn)
	begin
	if dmn.rst='1' then
		bit_cnt   <= (others=>'0');
		sda_shift <= (others=>'0');
	elsif rising_edge(dmn.clk) then
		-- Bit counter
		if sm_core=start or sm_core=addr_ack_ok or sm_core=sub_addr_ack_ok or sm_core=data_end then bit_cnt <= "111";
		elsif bit_cnt/=0 and scl_90_fe='1'                                                     then	bit_cnt <= bit_cnt - 1; end if;

		case sm_core is
			when addr | addr_rwn | sub_addr => if scl_90_re='1' then sda_shift <= sda_shift(6 downto 0) & sda_r; end if; -- Get SDA bit when SCL is high
			when data                       => if sda_nd   ='1' then sda_shift <= sda_shift(6 downto 0) & sda_r; end if; -- Get/Provide SDA bit
			when data_prep_ok               => if i2c_rwn  ='1' then sda_shift <= i2c_data_to                  ; end if; -- Load requested data
			when others                     => null;
		end case;
	end if;
	end process;

	sda_mgr : process(dmn)
	begin
	if dmn.rst='1' then
		sda_o <= '1';
	elsif rising_edge(dmn.clk) then
		case sm_core is
			when addr_ack_ok | sub_addr_ack_ok | data_ack_gen =>                     sda_o <=          '0';         -- I²C acknowledgement
			when data                                         => if i2c_rwn='1' then sda_o <= sda_shift(7);         -- Read operation  (Write on I²C buc : Slave  ==> I²C ==> Master)
			                                                     else                sda_o <=          '1'; end if; -- Write operation (Read     I²C bus : Master ==> I²C ==> Slave )
			when others                                       =>                     sda_o <=          '1';         -- Do not drive SDA line
		end case;
	end if;
	end process;

	sda  <= s_gnd when sda_o='0' and sm_core/=idle and i2c_select(0)='1' else 'Z'; -- Drive I²C SDA line
	sda1 <= s_gnd when sda_o='0' and sm_core/=idle and i2c_select(1)='1' else 'Z'; -- Drive I²C SDA line
	sda2 <= s_gnd when sda_o='0' and sm_core/=idle and i2c_select(2)='1' else 'Z'; -- Drive I²C SDA line
	sda3 <= s_gnd when sda_o='0' and sm_core/=idle and i2c_select(3)='1' else 'Z'; -- Drive I²C SDA line
	sda4 <= s_gnd when sda_o='0' and sm_core/=idle and i2c_select(4)='1' else 'Z'; -- Drive I²C SDA line
	sda5 <= s_gnd when sda_o='0' and sm_core/=idle and i2c_select(5)='1' else 'Z'; -- Drive I²C SDA line
	sda6 <= s_gnd when sda_o='0' and sm_core/=idle and i2c_select(6)='1' else 'Z'; -- Drive I²C SDA line
	sda7 <= s_gnd when sda_o='0' and sm_core/=idle and i2c_select(7)='1' else 'Z'; -- Drive I²C SDA line
	byte_cnt <= (others=>'0'); --dummy generate
end generate sda_slave;

-- Register input and delay some signals
process(dmn)
begin
if dmn.rst='1' then
	scl_r <= '0';
	sda_r <= '0';
elsif rising_edge(dmn.clk) then
	if (scl ='0' and i2c_select(0)='1') or
	   (scl1='0' and i2c_select(1)='1') or
	   (scl2='0' and i2c_select(2)='1') or
	   (scl3='0' and i2c_select(3)='1') or
	   (scl4='0' and i2c_select(4)='1') or
	   (scl5='0' and i2c_select(5)='1') or
	   (scl6='0' and i2c_select(6)='1') or
	   (scl7='0' and i2c_select(7)='1') then scl_r <= '0';
	else                                     scl_r <= '1'; end if;

	if (sda ='0' and i2c_select(0)='1') or
	   (sda1='0' and i2c_select(1)='1') or
	   (sda2='0' and i2c_select(2)='1') or
	   (sda3='0' and i2c_select(3)='1') or
	   (sda4='0' and i2c_select(4)='1') or
	   (sda5='0' and i2c_select(5)='1') or
	   (sda6='0' and i2c_select(6)='1') or
	   (sda7='0' and i2c_select(7)='1') then sda_r <= '0';
	else                                     sda_r <= '1'; end if;
end if;
end process;

i2c_busy      <= '0' when sm_core=idle else '1';
i2c_finish    <= '1' when sm_core=eot  else '0';

i2c_data_from <= sda_shift;
i2c_data_ok   <= '1' when (sm_core=data_end     and i2c_rwn='1') or
                          (sm_core=data_prep_ok and i2c_rwn='0') else
                 '0';
---------------------------------------------------------------------------
-- Sequencer
---------------------------------------------------------------------------
i2c_sequencer : entity work.i2c_sequencer generic map
	( AGENT         => AGENT                            -- "MASTER", "SLAVE"
	) port map
	( dmn           => dmn                              -- Reset/clock
	, sm_core       => sm_core                          -- Main core state machine
	, sm_core_r     => sm_core_r                        -- Main core state machine (1 clock later)
	  ----------------------------------------------------
	, scl_r         => scl_r                            -- I²C SCL (registered version)
	, sda_nd        => sda_nd                           -- SDA Shift Register condition
	, sda_r         => sda_r                            -- I²C SDA (registered version)
	, sda_shift     => sda_shift                        --
	, bit_cnt       => bit_cnt                          -- Bit counter
	, byte_cnt      => byte_cnt                         -- Byte decounter (number of byte to be transferred)
	, sub_addr_done => sub_addr_done                    --
	  ----------------------------------------------------
	  -- I²C timers and derivated signals               --
	  ----------------------------------------------------
	, scl_90        => scl_90                           -- SCL delayed of 90°
	, scl_90_fe     => scl_90_fe                        -- SCL delayed of 90° (falling edge)
	, scl_90_re     => scl_90_re                        -- SCL delayed of 90° (rising  edge)
	, scl_stop      => scl_stop                         -- I²C SCL Stopped => stop sm_core
	  ----------------------------------------------------
	  -- Configuration registers                        --
	  ----------------------------------------------------
	, i2c_addr      => i2c_addr                         -- component address
	, i2c_rwn       => i2c_rwn                          -- Read/Write
	, i2c_sbl       => i2c_sbl                          -- Slave Boundary Limit (Master specific)
	, i2c_start     => i2c_start                        -- Start Transaction (Master specific)
	, i2c_usa       => i2c_usa                          -- Use Sub-Address
	);
------------------------------------------------------------------
-- Clock generation
------------------------------------------------------------------
i2c_clock : entity work.i2c_clock generic map
	( AGENT         => AGENT                            --string          -- "MASTER", "SLAVE"
	, CLOCK_PERIOD  => CLOCK_PERIOD                     --time            -- Clock period
	, I2C_MODE      => I2C_MODE                         --string          -- "STANDARD" (100kHz), "FAST" (400kHz), "USER" (see I2C_PERIOD)
	, I2C_PERIOD    => I2C_PERIOD                       --time            -- User specific SCL clock period
	, SMBUS         => SMBUS                            --boolean         -- Activate SMBus options
	) port map                                          --                --
	( dmn           => dmn                              --in    domain    -- Reset/clock
	, smbus_rst     => smbus_rst                        --in    sl        -- SMBus / Reset
	, sm_core       => sm_core                          --in    core_type -- Main core state machine
	, i2c_select    => i2c_select                       --in    slv8      -- Select I²C bus
	, scl           => scl                              --inout sl        -- I²C SCL ('0' or 'Z', never drive to '1')
	, scl1          => scl1                             --inout sl        -- I²C SCL ('0' or 'Z', never drive to '1')
	, scl2          => scl2                             --inout sl        -- I²C SCL ('0' or 'Z', never drive to '1')
	, scl3          => scl3                             --inout sl        -- I²C SCL ('0' or 'Z', never drive to '1')
	, scl4          => scl4                             --inout sl        -- I²C SCL ('0' or 'Z', never drive to '1')
	, scl5          => scl5                             --inout sl        -- I²C SCL ('0' or 'Z', never drive to '1')
	, scl6          => scl6                             --inout sl        -- I²C SCL ('0' or 'Z', never drive to '1')
	, scl7          => scl7                             --inout sl        -- I²C SCL ('0' or 'Z', never drive to '1')
	, scl_r         => scl_r                            --in    sl        -- I²C SCL read
	, scl_stop      => scl_stop                         --out   sl        -- I²C SCL Stopped => stop sm_core
	, scl_90        => scl_90                           --out   sl        -- SCL 90° delayed
	, scl_90_fe     => scl_90_fe                        --out   sl        -- SCL 90° delayed (falling edge)
	, scl_90_re     => scl_90_re                        --out   sl        -- SCL 90° delayed (rising  edge)
	, clk_dbg       => clk_dbg                          --out   sl        -- Clock for debugging I²C link (with SignalTap for example)
	);

h_sm_core   <= sm_core  ;
h_sm_core_r <= sm_core_r;
h_sda_shift <= sda_shift;

---------------------------------------------------------------------------
-- Check I²C base address (Slave mode, simulation only)
---------------------------------------------------------------------------
-- synthesis translate_off
check_addr_slave : if AGENT="SLAVE" generate
	process
	begin
		wait until i2c_addr'event;
		if i2c_addr="0000000" then assert false report "Illegal Slave Base Address : must be different of 000.0000" severity warning; end if; -- General Call Address / Start byte
		if i2c_addr="0000001" then assert false report "Illegal Slave Base Address : must be different of 000.0001" severity warning; end if; -- CBUS address
		if i2c_addr="0000010" then assert false report "Illegal Slave Base Address : must be different of 000.0010" severity warning; end if; -- Reserved for different bus format
		if i2c_addr="0000011" then assert false report "Illegal Slave Base Address : must be different of 000.0011" severity warning; end if; -- Reserved for future purpose
		if i2c_addr="0000100" then assert false report "Illegal Slave Base Address : must be different of 000.01XX" severity warning; end if; -- Hs-mode master code
		if i2c_addr="0000101" then assert false report "Illegal Slave Base Address : must be different of 000.01XX" severity warning; end if; -- Hs-mode master code
		if i2c_addr="0000110" then assert false report "Illegal Slave Base Address : must be different of 000.01XX" severity warning; end if; -- Hs-mode master code
		if i2c_addr="0000111" then assert false report "Illegal Slave Base Address : must be different of 000.01XX" severity warning; end if; -- Hs-mode master code
		if i2c_addr="1111000" then assert false report "Illegal Slave Base Address : must be different of 111.10XX" severity warning; end if; -- 10-bit slave addressing
		if i2c_addr="1111001" then assert false report "Illegal Slave Base Address : must be different of 111.10XX" severity warning; end if; -- 10-bit slave addressing
		if i2c_addr="1111010" then assert false report "Illegal Slave Base Address : must be different of 111.10XX" severity warning; end if; -- 10-bit slave addressing
		if i2c_addr="1111011" then assert false report "Illegal Slave Base Address : must be different of 111.10XX" severity warning; end if; -- 10-bit slave addressing
		if i2c_addr="1111100" then assert false report "Illegal Slave Base Address : must be different of 111.11XX" severity warning; end if; -- Reserved for future purpose
		if i2c_addr="1111101" then assert false report "Illegal Slave Base Address : must be different of 111.11XX" severity warning; end if; -- Reserved for future purpose
		if i2c_addr="1111110" then assert false report "Illegal Slave Base Address : must be different of 111.11XX" severity warning; end if; -- Reserved for future purpose
		if i2c_addr="1111111" then assert false report "Illegal Slave Base Address : must be different of 111.11XX" severity warning; end if; -- Reserved for future purpose
	end process;
end generate check_addr_slave;
-- synthesis translate_on
---------------------------------------------------------------------------
-- Emulate on-board pull-up
---------------------------------------------------------------------------
--synthesis translate_off
scl  <= 'H';    sda  <= 'H';
scl1 <= 'H';    sda1 <= 'H';
scl2 <= 'H';    sda2 <= 'H';
scl3 <= 'H';    sda3 <= 'H';
scl4 <= 'H';    sda4 <= 'H';
scl5 <= 'H';    sda5 <= 'H';
scl6 <= 'H';    sda6 <= 'H';
scl7 <= 'H';    sda7 <= 'H';
--synthesis translate_on
end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
