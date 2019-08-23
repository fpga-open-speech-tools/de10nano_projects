----------------------------------------------------------------------------------------------------
-- Copyright (c) ReFLEX CES 1998-2012
--
-- Use of this source code through a simulator and/or a compiler tool
-- is illegal if not authorised through ReFLEX CES License agreement.
----------------------------------------------------------------------------------------------------
-- Project     : 
----------------------------------------------------------------------------------------------------
-- Top level   : top.vhd
-- File        : pulse_resync.vhd
-- Author      : flavenant@reflexces.com
-- Company     : ReFLEX CES
--               2, rue du gevaudan
--               91047 LISSES
--               FRANCE
--               http://www.reflexces.com
-- Plateforme  : Windows XP
-- Simulator   : Mentor Graphics ModelSim
-- Synthesis   : Quartus II
-- Target      : Stratix IV
-- Dependency  :
----------------------------------------------------------------------------------------------------
-- Description :
-- Generate a one clock cycle pulse on output clock domain from an event on input clock domain.
--
-- Output pulses can be generated on the following condition (re, fe):
--  - (0, 0) : output pulse when input goes high for one clock cycle. Less resources and latency, but input pulse can be lost if input goes high for more than one clock cycle !!!
--  - (1, 0) : output pulse when input goes high (rising edge).
--  - (0, 1) : output pulse when input goes low (falling edge).
--  - (1, 1) : output pulse when input goes high or low (edge detection).
--
-- If lv_set is set to '1', output remains high while input is high.
--
----------------------------------------------------------------------------------------------------
-- Version      Date            Author              Description
-- 0.1          2012/01/17      FLA                 Creation
-- 0.2          2012/05/02      FLA                 Add ONLY_RE
-- 0.3          2012/05/03      FLA                 Add ADD_INPUT_REG, re_detect, fe_detect
-- 0.4          2014/01/14      FLA                 Add lv_set
----------------------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.std_logic_unsigned.all;

entity pulse_resync is
    generic (
          P_WIDTH               : integer := 1          -- Number of bits for input and output
        ; ADD_INPUT_REG         : boolean := false      -- If true, 2 registers are added on inputs (metastability protection for asynchronous input) 
    );
    port (
          rstin_n               : in    std_logic := '1'
        ; rstin                 : in    std_logic := '0'
        ; clkin                 : in    std_logic
        ; rstout_n              : in    std_logic := '1'
        ; rstout                : in    std_logic := '0'
        ; clkout                : in    std_logic
        ; p_in                  : in    std_logic_vector(P_WIDTH-1 downto 0)    
        ; p_out                 : out   std_logic_vector(P_WIDTH-1 downto 0)    
        ; re_detect             : in    std_logic_vector(P_WIDTH-1 downto 0) := (others=>'0')   -- set to '1' to detect rising edge on corresponding bit
        ; fe_detect             : in    std_logic_vector(P_WIDTH-1 downto 0) := (others=>'0')   -- set to '1' to detect falling edge on corresponding bit
        ; lv_set                : in    std_logic_vector(P_WIDTH-1 downto 0) := (others=>'0')   -- set to '1' to assert output while input is asserted ('1').
    );
end entity pulse_resync;

architecture rtl of pulse_resync is
	----------------------------------------------------------------
	-- Type declarations
	----------------------------------------------------------------
    
	----------------------------------------------------------------
	-- Function declarations
	----------------------------------------------------------------
    
	----------------------------------------------------------------
	-- Component declarations
	----------------------------------------------------------------
    
	----------------------------------------------------------------
	-- Constant declarations
	----------------------------------------------------------------

	----------------------------------------------------------------
	-- Signal declarations
	----------------------------------------------------------------
    signal s_toggle     : std_logic_vector(p_in'range);
begin
    --============================================================================================================================
    -- Input process
    --============================================================================================================================
    blk_in : block is
        signal sb_p_in_r     : std_logic_vector(p_in'range);
        signal sb_p_in_rr    : std_logic_vector(p_in'range);
        signal sb_p_in_rrr   : std_logic_vector(p_in'range);
    begin
        process (clkin, rstin_n, rstin)
            variable v_in       : std_logic_vector(p_in'range);
            variable v_in_r     : std_logic_vector(p_in'range);
        begin
        if rstin_n='0' or rstin='1' then 
            s_toggle    <= (others=>'0');
            sb_p_in_r   <= (others=>'0');
            sb_p_in_rr  <= (others=>'0');
            sb_p_in_rrr <= (others=>'0');
        elsif rising_edge(clkin) then
            -- Registers
            sb_p_in_r   <=    p_in;
            sb_p_in_rr  <= sb_p_in_r;
            sb_p_in_rrr <= sb_p_in_rr;
        
            -- Select stage according to generic
            if ADD_INPUT_REG then v_in := sb_p_in_rr; v_in_r := sb_p_in_rrr;
            else                  v_in :=    p_in   ; v_in_r := sb_p_in_r  ; end if;
        
            -- Detect event
            for i in p_in'range loop
                   if re_detect(i)='0' and fe_detect(i)='0' then s_toggle(i) <= s_toggle(i) xor v_in(i);
                elsif re_detect(i)='1' and fe_detect(i)='0' then s_toggle(i) <= s_toggle(i) xor (    v_in(i)  and not(v_in_r(i)));
                elsif re_detect(i)='0' and fe_detect(i)='1' then s_toggle(i) <= s_toggle(i) xor (not(v_in(i)) and     v_in_r(i) );
                elsif re_detect(i)='1' and fe_detect(i)='1' then s_toggle(i) <= s_toggle(i) xor (    v_in(i)  xor     v_in_r(i) );
                end if;
            end loop;
            
        end if;
        end process;   
    end block blk_in;
    
    --============================================================================================================================
    -- Output process
    --============================================================================================================================
    blk_out : block is
        signal sb_p_in_r     : std_logic_vector(p_in'range);
        signal sb_p_in_rr    : std_logic_vector(p_in'range);
        signal sb_toggle_r   : std_logic_vector(p_in'range);
        signal sb_toggle_rr  : std_logic_vector(p_in'range);
        signal sb_toggle_rrr : std_logic_vector(p_in'range);
    begin
        process (clkout, rstout_n, rstout)
        begin
        if rstout_n='0' or rstout='1' then 
            sb_p_in_r     <= (others=>'0');
            sb_p_in_rr    <= (others=>'0');
            sb_toggle_r   <= (others=>'0');
            sb_toggle_rr  <= (others=>'0');
            sb_toggle_rrr <= (others=>'0');
            p_out         <= (others=>'0');
        elsif rising_edge(clkout) then
            -- Registers input
            sb_p_in_r   <=    p_in;
            sb_p_in_rr  <= sb_p_in_r;
            
            -- Detect toggle
            sb_toggle_r   <= s_toggle;
            sb_toggle_rr  <= sb_toggle_r;
            sb_toggle_rrr <= sb_toggle_rr;
            
            p_out        <= (sb_toggle_rrr xor sb_toggle_rr) or (sb_p_in_rr and lv_set);
        end if;
        end process; 
    end block blk_out;
    
end architecture rtl;
