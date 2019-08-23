----------------------------------------------------------------------------------------------------
-- Copyright (c) ReFLEX CES 1998-2016
--
-- Use of this source code through a simulator and/or a compiler tool
-- is illegal if not authorised through ReFLEX CES License agreement.
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Author      : Frédéric Lavenant       flavenant@reflexces.com
-- Company     : ReFLEX CES
--               2, rue du gevaudan
--               91047 LISSES
--               FRANCE
--               http://www.reflexces.com
----------------------------------------------------------------------------------------------------
-- Description :
-- 
--
----------------------------------------------------------------------------------------------------
-- Version      Date            Author               Description
-- 0.1          2015/04/09      FLA                  Creation
-- 0.2          2015/09/08      FLA                  Upd: report KO if slave is in reset state without timeout delay.
-- 0.3          2016/10/13      JDU                 Change lib_jlf to work 
----------------------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

entity cdc_roundtrip is
    generic (
          CDC_STAGE_WIDTH           : integer               := 4                        -- Number of bits for synchronization stages.
    );
    port (      
        -- Master side
          ms_clk                    : in    sl                                          -- 
        ; ms_rst                    : in    sl                                          -- 
        ; ms_cdc_req                : in    sl              := '1'                      --
        ; ms_cdc_ack                : out   sl                                          -- Always asserted (= ack_ok OR ack_ko).
        ; ms_cdc_ack_ok             : out   sl                                          -- Asserted if no time out.
        ; ms_cdc_ack_ko             : out   sl                                          -- Asserted if time out.
        ; ms_timeout_tick           : in    sl              := '0'                      -- If there is no ACK between two tick, ACK is asserted to prevent dead lock.
        
        -- Slave side
        ; sl_clk                    : in    sl                                          -- 
        ; sl_rst                    : in    sl                                          -- 
        ; sl_latch_req              : out   sl              := '1'                      --
    );
end entity cdc_roundtrip;

architecture rtl of cdc_roundtrip is
    --============================================================================================================================
    -- Function and Procedure declarations
    --============================================================================================================================
    
    --============================================================================================================================
    -- Constant and Type declarations
    --============================================================================================================================

    --============================================================================================================================
    -- Component declarations
    --============================================================================================================================
    
    --============================================================================================================================
    -- Signal declarations
    --============================================================================================================================
    signal s_req_dly        : slv(CDC_STAGE_WIDTH-1 downto 0);
    signal s_ack_dly        : slv(CDC_STAGE_WIDTH-1 downto 0);
    signal s_req_t          : sl;
    signal s_ack_t          : sl;
    signal s_latch_req      : sl;
    signal s_latch_ack      : sl;
    signal s_latch_ack_ok   : sl;
    signal s_latch_ack_ko   : sl;
    signal s_timeout_dly    : slv3;
    signal s_rdy_dly        : slv2;
    signal s_ms_rdy         : slv2;
    signal s_sl_rdy         : sl;
    signal s_ms_cdc_req     : sl;
begin
    
    --############################################################################################################################
    --############################################################################################################################
    -- Master clock domain
    --############################################################################################################################
    --############################################################################################################################
    -- Comb. part
    s_ms_cdc_req    <= ms_cdc_req and msb(s_ms_rdy);
    
    s_latch_ack_ok  <= xor1(msb(s_ack_dly, 2));
    s_latch_ack     <= s_latch_ack_ok or s_latch_ack_ko;
    
    ms_cdc_ack_ok   <= s_latch_ack_ok;
    ms_cdc_ack_ko   <= s_latch_ack_ko;
    ms_cdc_ack      <= s_latch_ack;
    
    -- Sync. part
    process (ms_rst, ms_clk)
    begin
    if ms_rst='1' then
        s_ack_dly       <= (others=>'0');
        s_req_t         <= '0';
        s_timeout_dly   <= (others=>'0');
        s_ms_rdy        <= (others=>'0');
        s_latch_ack_ko  <= '0';
        
    elsif rising_edge(ms_clk) then
        -- Ready to process request
        s_ms_rdy <= s_ms_rdy(s_ms_rdy'high-1 downto 0) & s_sl_rdy;
        
        -- Register stages for edge detection
        s_ack_dly <= s_ack_dly(s_ack_dly'high-1 downto 0) & s_ack_t;
        
        -- Update REQUEST
        s_req_t <= s_req_t xor s_ms_cdc_req;
        
        -- Problem during CDC
           if msb(s_timeout_dly)='1'                then s_latch_ack_ko <= '1';
        elsif ms_cdc_req='1' and msb(s_ms_rdy)='0'  then s_latch_ack_ko <= '1';
        else                                             s_latch_ack_ko <= '0';
        end if;
        
        -- Timeout
           if s_latch_ack='1'       then s_timeout_dly <= (others=>'0');
        elsif s_ms_cdc_req='1'      then s_timeout_dly <= (0=>'1', others=>'0');
        elsif ms_timeout_tick='1'   then s_timeout_dly <= s_timeout_dly(s_timeout_dly'high-1 downto 0) & '0';
        end if;
        
    end if;
    end process;
    
    --############################################################################################################################
    --############################################################################################################################
    -- Slave clock domain
    --############################################################################################################################
    --############################################################################################################################
    -- Comb. part
    s_latch_req     <= xor1(msb(s_req_dly, 2));
    sl_latch_req    <= s_latch_req;
    
    -- Sync. part
    process (ms_rst, sl_rst, sl_clk)
    begin
    if or1(ms_rst & sl_rst)='1' then
        s_sl_rdy    <= '0';
        s_req_dly   <= (others=>'0');
        s_ack_t     <= '0';
        
    elsif rising_edge(sl_clk) then
        -- Ready to process request
        s_sl_rdy <= '1';
        
        -- Register stages for edge detection
        s_req_dly <= s_req_dly(s_req_dly'high-1 downto 0) & s_req_t;
        
        -- Toggle ACK for master side
        s_ack_t <= s_ack_t xor s_latch_req;
    end if;
    end process;
    
end architecture rtl;
