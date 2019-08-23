----------------------------------------------------------------------------------------------------
-- Copyright (c) ReFLEX CES 1998-2013
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
-- Arbiter with simple round robin behaviour.
--
----------------------------------------------------------------------------------------------------
-- Version      Date            Author               Description
-- 0.1          2013/12/09      FLA                  Creation
-- 0.2          2014/01/28      FLA                  Add: data management, "priority" mode.
-- 0.3          2016/10/13      JDU                 Change lib_jlf to work 
----------------------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

entity arbiter is
    generic (
          NB_INPUT          : integer           := 4                    -- Number of inputs to manage
        ; MODE              : string            := "round_robin"        -- "round_robin", "priority"
        ; DATA_WIDTH        : integer           := 33                   -- Input is NB_INPUT*DATA_WIDTH
    );          
    port (          
          rst               : in    sl                                  -- Active high (A)synchronous reset
        ; clk               : in    sl                                  -- Clock
            
        ; i_dat             : in    slv(NB_INPUT*DATA_WIDTH-1 downto 0) -- Input data 
        ; i_vld             : in    slv(NB_INPUT-1 downto 0)            -- Valid input
        ; i_eop             : in    slv(NB_INPUT-1 downto 0)            -- Last cycle (switch allowed the cycle after)
        ; i_rdy             : out   slv(NB_INPUT-1 downto 0)            -- Input ready
            
        ; o_dat             : out   slv(DATA_WIDTH-1 downto 0)          -- Output data
        ; o_vld             : out   sl                                  -- Output valid
        ; o_eop             : out   sl                                  -- Output EOF
        ; o_rdy             : in    sl                                  -- Output ready
    );
end entity arbiter;

architecture rtl of arbiter is
    ----------------------------------------------------------------
    -- Function and Procedure declarations
    ----------------------------------------------------------------
    
    ----------------------------------------------------------------
    -- Constant and Type declarations
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    -- Component declarations
    ----------------------------------------------------------------
    
    ----------------------------------------------------------------
    -- Signal declarations
    ----------------------------------------------------------------
    signal s_sel        : slv(i_vld'range);
    signal s_sel_r      : slv(i_vld'range);
    signal s_sel_comb   : slv(i_vld'range);
    signal s_sop        : sl;
    signal s_i_rdy      : slv(i_vld'range);
    signal s_i_eop      : sl;
    signal s_o_vld      : sl;
begin
    --============================================================================================================================
    -- Check
    --============================================================================================================================
    assert MODE="round_robin" or MODE="priority" report "[arbiter]: invalid for MODE." severity failure;

    --############################################################################################################################
    --############################################################################################################################
    -- Round Robin
    --############################################################################################################################
    --############################################################################################################################
    gen_roundrobin : if MODE="round_robin" generate
        signal sb_req_off   : slv(i_vld'range);
        signal sb_any_vld   : sl;
    begin
        --============================================================================================================================
        -- Comb process
        --============================================================================================================================
        -- Filter already acknowledged inputs
        sb_any_vld <= or1(i_vld and not(sb_req_off));
        
        -- Build input selection
        process (sb_req_off, i_vld, sb_any_vld)
            variable v_sel      : slv(NB_INPUT-1 downto 0);
        begin
            v_sel := (others=>'0');
            for i in i_vld'range loop
                -- Assert ack if request asserted and not already processed in this round
                if i_vld(i)='1' and (sb_req_off(i)='0' or sb_any_vld='0') then v_sel(i) := '1'; end if;
                
                -- Exit loop (to assert only one input)
                if v_sel(i)='1' then exit; end if;
            end loop;
            
            -- To output
            s_sel_comb <= v_sel;
        end process;
        
        --============================================================================================================================
        -- Clocked process
        --============================================================================================================================
        process (rst, clk)
        begin
        if rst='1' then
            sb_req_off   <= (others=>'0');
        elsif rising_edge(clk) then
            -- Disable processed inputs
            if s_i_eop='1' then 
                if or1(not(sb_req_off or s_sel) and i_vld)='0'  then sb_req_off <=            (others=>'0'); -- all inputs enabled (no other input valid than the current one).
                else                                                 sb_req_off <= sb_req_off or s_sel     ; -- append current input to disable it.
                end if;
            end if;
        end if;
        end process;
    end generate gen_roundrobin;
    
    --############################################################################################################################
    --############################################################################################################################
    -- Round Robin
    --############################################################################################################################
    --############################################################################################################################
    gen_priority : if MODE="priority" generate
    begin
        --============================================================================================================================
        -- Comb process
        --============================================================================================================================
        -- Build input selection
        process (i_vld)
            variable v_sel      : slv(NB_INPUT-1 downto 0);
        begin
            v_sel := (others=>'0');
            for i in 0 to NB_INPUT-1 loop
                -- Assert ack if request asserted
                if i_vld(i)='1' then v_sel(i) := '1'; end if;
                
                -- Exit loop (to assert only one input)
                if v_sel(i)='1' then exit; end if;
            end loop;
            
            -- To output
            s_sel_comb <= v_sel;
        end process;
    end generate gen_priority;
    
    --############################################################################################################################
    --############################################################################################################################
    -- Common
    --############################################################################################################################
    --############################################################################################################################
    --============================================================================================================================
    -- Build filtered input EOP
    --============================================================================================================================
    s_i_eop <= or1(i_vld and s_i_rdy and i_eop);
    
    --============================================================================================================================
    -- Build output signals
    --============================================================================================================================
    process (rst, clk)
    begin
    if rst='1' then
        s_sop   <= '1';
        s_o_vld <= '0';
        o_eop   <= '0';
        s_sel_r <= (others=>'0');
        o_dat   <= (others=>'0');
    elsif rising_edge(clk) then
        -- Build SOP flag
        if or1(i_vld and s_i_rdy)='1' then s_sop <= s_i_eop; end if;
        
        -- Hold selection found at SOP
        if s_sop='1' then s_sel_r <= s_sel_comb; end if;
        
        -- Build output validation
        if s_o_vld='0' or o_rdy='1' then s_o_vld <= or1(i_vld and s_i_rdy); end if;
        
        -- Build EOP flag
           if s_i_eop='1' then o_eop <= '1';
        elsif o_rdy='1'   then o_eop <= '0';
        end if;
        
        -- Output Data
        for i in 0 to NB_INPUT-1 loop
            if i_vld(i)='1' and s_i_rdy(i)='1' then o_dat <= i_dat((i+1)*DATA_WIDTH-1 downto i*DATA_WIDTH); exit; end if;
        end loop;
    end if;
    end process;
        
    --============================================================================================================================
    -- Misc.
    --============================================================================================================================
    s_sel   <= s_sel_comb when s_sop='1' else s_sel_r;
    s_i_rdy <= s_sel when s_o_vld='0' or o_rdy='1' else (others=>'0');
    i_rdy   <= s_i_rdy;
    o_vld   <= s_o_vld;
end architecture rtl;
