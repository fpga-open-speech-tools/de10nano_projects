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
----------------------------------------------------------------------------------------------------
-- Version      Date            Author              Description
-- 0.1          2014/02/19      FLA                 Creation
-- 0.2          2014/04/03      FLA                 Upd: generic for number of edges between 2 ticks.
-- 0.3          2016/10/13      JDU                 Change lib_jlf to work 
----------------------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

entity clock_sensor is
    generic (
          NB_EDGES_MIN      : integer   := 256  -- Test clock must rise at least NB_EDGES_MIN between two ticks.
    );
    port (  
          rst               : in    sl          -- Active high (A)synchronous reset
        ; clk               : in    sl          -- Clock
                    
        -- Tick interval (clk domain)           
        ; tick              : in    sl          -- Test period.
                    
        -- Tested toggle            
        ; toggle_clk        : in    sl          -- Clock to be tested
            
        -- Status (clk domain)  
        ; toggle_ok         : out   sl          -- Asserted while toggle_clk is active
        ; toggle_ko         : out   sl          -- Asserted when toggle_clk is stuck 
    );
end entity clock_sensor;

architecture rtl of clock_sensor is
    --============================================================================================================================
    -- Function, Constant and Procedure declarations
    --============================================================================================================================
    
    --============================================================================================================================
    -- Type declarations
    --============================================================================================================================
    
    --============================================================================================================================
    -- Component declarations
    --============================================================================================================================
    
    --============================================================================================================================
    -- Signal declarations
    --============================================================================================================================
    signal s_rst_cnt_t  : sl;
    signal s_edge_t     : sl;
    signal s_lvl_o      : sl;
begin
    --============================================================================================================================
    -- Status process
    --============================================================================================================================
    blk_ref : block is
        signal sb_edge_dly  : slv4;
        signal sb_edge_ok   : sl;
    begin
        process (rst, clk)
        begin
        if rst='1' then
            s_rst_cnt_t     <= '0';
            sb_edge_ok      <= '0';
            sb_edge_dly     <= (others=>'0');
            toggle_ok       <= '0';
            toggle_ko       <= '1';
            
        elsif rising_edge(clk) then
            -- Send a counter reset request.
            if tick='1' then s_rst_cnt_t <= not(s_rst_cnt_t); end if;
            
            -- Register for edge detection.
            sb_edge_dly  <= sb_edge_dly(sb_edge_dly'high-1 downto 0) & s_edge_t;
            
            -- Check edge detection
               if xor1(msb(sb_edge_dly, 2))='1' then sb_edge_ok <= '1';
            elsif tick='1'                      then sb_edge_ok <= '0';
            end if;
            
            -- If input and output levels are different, toggle_clk is stuck
            if tick='1' then 
                toggle_ok <=     sb_edge_ok ;
                toggle_ko <= not(sb_edge_ok);
            end if;
        end if;
        end process;
    end block blk_ref;
    
    --============================================================================================================================
    -- Toggle process
    --============================================================================================================================
    blk_tog : block is
        signal sb_cnt       : slv(Log2(NB_EDGES_MIN)+1 downto 0);
        signal sb_cnt_msb   : sl;
        signal sb_rst_dly   : slv4;
    begin
        process (rst, toggle_clk)
        begin
        if rst='1' then -- this reset is fully asynchronous related to this clock domain.
            s_edge_t    <= '0';
            sb_cnt_msb  <= '0';
            sb_cnt      <= (others=>'0');
            sb_rst_dly  <= (others=>'0');
            
        elsif rising_edge(toggle_clk) then
            -- Register for edge detection.
            sb_rst_dly  <= sb_rst_dly(sb_rst_dly'high-1 downto 0) & s_rst_cnt_t;
        
            -- Reset counter on each request.
               if xor1(msb(sb_rst_dly, 2))='1' then sb_cnt <= conv_slv(NB_EDGES_MIN-4, sb_cnt'length); -- -4 because there are already some registers in the pipe.
            elsif msb(sb_cnt)='0'              then sb_cnt <= sb_cnt - 1;
            end if;
            
            -- Detect counter overflow
            sb_cnt_msb <= msb(sb_cnt);
            if msb(sb_cnt)='1' and sb_cnt_msb='0' then s_edge_t <= not(s_edge_t); end if;
        end if;
        end process;
    end block blk_tog;
    
end architecture rtl;
