----------------------------------------------------------------------------------------------------
-- Copyright (c) ReFLEX CES 1998-2012
--
-- Use of this source code through a simulator and/or a compiler tool
-- is illegal if not authorised through ReFLEX CES License agreement.
----------------------------------------------------------------------------------------------------
-- Project     : 
----------------------------------------------------------------------------------------------------
-- Top level   : top.vhd
-- File        : rate_count.vhd
-- Author      : Frederic LAVENANT       flavenant@reflexces.com
-- Company     : ReFLEX CES
--               2, rue du gevaudan
--               91047 LISSES
--               FRANCE
--               http://www.reflexces.com
-- Plateforme  : Windows XP
-- Simulator   : Mentor Graphics ModelSim
-- Synthesis   : 
-- Target      : 
-- Dependency  :
----------------------------------------------------------------------------------------------------
-- Description :
--
-- Count number of cycles between two ticks.
-- Can optionally use an increment greater than 1.
--
----------------------------------------------------------------------------------------------------
-- Version      Date            Author               Description
-- 0.1          2012/01/26      FLA                  Creation
-- 0.2          2012/07/20      FLA                  Add: active high reset and commentaries on ports.
-- 0.3          2012/07/25      FLA                  Add: another clock domain for rate (allow direct measure of intermittent clock frequency)
----------------------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity rate_count is
    generic (
          COUNT_WIDTH               : integer   := 32                                                   -- number of bits for output counter
        ; INC_WIDTH                 : integer   := 1                                                    -- number of bits for the input increment
    );  
	port (  
        -- Cycle info   
          cycle_clk                 : in    std_logic                                                   -- clock for the input rate
        ; cycle_rst                 : in    std_logic                               := '0'              -- reset for input rate              /!\ only use one reset /!\
        ; cycle_rst_n               : in    std_logic                               := '1'              -- reset for input rate (active low) /!\ only use one reset /!\
        ; cycle_vld                 : in    std_logic                               := '1'              -- assert to take into account the increment
        ; cycle_inc                 : in    std_logic_vector(INC_WIDTH-1 downto 0)  := (others=>'1')    -- increment value to add to output counter on each valid cycle
        ; cycle_count               : out   std_logic_vector(COUNT_WIDTH-1 downto 0)                    -- output counter (rate) (cycle_clk clock domain)
        
        -- Rate info
        ; rate_rst                  : in    std_logic                               := '0'              -- reset for the rate clock              /!\ only use one reset /!\
        ; rate_rst_n                : in    std_logic                               := '1'              -- reset for the rate clock (active low) /!\ only use one reset /!\ 
        ; rate_clk                  : in    std_logic                               := '0'              -- optionnal clock domain for rate counter
        ; rate_count                : out   std_logic_vector(COUNT_WIDTH-1 downto 0)                    -- output counter (rate) (rate_clk clock domain)
    
        -- Input tick   
        ; tick_rst                  : in    std_logic                               := '0'              -- reset for the reference clock              /!\ only use one reset /!\
        ; tick_rst_n                : in    std_logic                               := '1'              -- reset for the reference clock (active low) /!\ only use one reset /!\ 
        ; tick_clk                  : in    std_logic                                                   -- reference clock for the measure
        ; tick                      : in    std_logic := '0'                                            -- pulse to define measure interval
	);
end entity rate_count;

architecture rtl of rate_count is
	----------------------------------------------------------------
	-- Type declarations
	----------------------------------------------------------------

	----------------------------------------------------------------
	-- Function declarations
	----------------------------------------------------------------
    
	----------------------------------------------------------------
	-- Constant declarations
	----------------------------------------------------------------
    constant C_NULL         : unsigned(cycle_count'range) := (others=>'0');

	----------------------------------------------------------------
	-- Signal declarations
	----------------------------------------------------------------
    signal s_tick_t         : std_logic;
    
    signal s_cycle_count    : std_logic_vector(cycle_count'range);   
    signal s_rate_t         : std_logic;
    
begin

    --##############################################################
    -- Tick clock domain crossing
    --##############################################################
	 process (tick_rst, tick_rst_n, tick_clk)
    begin
       if tick_rst_n='0' or tick_rst='1' then s_tick_t <= '0';
    elsif rising_edge(tick_clk)          then s_tick_t <= s_tick_t xor tick;
    end if;
    end process;
    
    --##############################################################
    -- Count cycles
    --##############################################################
    blk_count : block is
        signal sb_cycle_count   : unsigned(cycle_count'range);
        signal sb_tick_t_r      : std_logic;
        signal sb_tick_t_rr     : std_logic;
        signal sb_tick_t_rrr    : std_logic;
    begin
        process (cycle_rst, cycle_rst_n, cycle_clk)
        begin
        if cycle_rst_n='0' or cycle_rst='1' then
            sb_tick_t_r     <= '0';
            sb_tick_t_rr    <= '0';
            sb_tick_t_rrr   <= '0';
            s_rate_t        <= '0';
            sb_cycle_count  <= (others=>'0');
            s_cycle_count   <= (others=>'0');
        elsif rising_edge(cycle_clk) then
            -- Detect tick edges
            sb_tick_t_r   <= s_tick_t;
            sb_tick_t_rr  <= sb_tick_t_r;
            sb_tick_t_rrr <= sb_tick_t_rr;
            
            -- Count cycles between two ticks
               if sb_tick_t_rrr/=sb_tick_t_rr and cycle_vld='0' then sb_cycle_count <= C_NULL;
            elsif sb_tick_t_rrr/=sb_tick_t_rr and cycle_vld='1' then sb_cycle_count <= C_NULL + unsigned(cycle_inc); -- Count this cycle during tick
            elsif cycle_vld='1'                                 then sb_cycle_count <= sb_cycle_count + unsigned(cycle_inc); end if;
            
            -- Update output
            if sb_tick_t_rrr/=sb_tick_t_rr then s_cycle_count <= std_logic_vector(sb_cycle_count); end if;
            if sb_tick_t_rrr/=sb_tick_t_rr then s_rate_t      <= not(s_rate_t); end if;
            
        end if;
        end process;
        cycle_count <= s_cycle_count;
    end block blk_count;
    
    --##############################################################
    -- Rate clock domain
    --##############################################################
    blk_rate : block is
        signal sb_tick_t_r          : std_logic;
        signal sb_tick_t_rr         : std_logic;
        signal sb_tick_t_rrr        : std_logic;
        signal sb_rate_t_r          : std_logic;
        signal sb_rate_t_rr         : std_logic;
        signal sb_rate_t_rrr        : std_logic;
        signal sb_no_upd            : std_logic;
    begin
        process (rate_rst, rate_rst_n, rate_clk)
        begin
        if rate_rst_n='0' or rate_rst='1' then
            sb_tick_t_r      <= '0';
            sb_tick_t_rr     <= '0';
            sb_tick_t_rrr    <= '0';
            sb_rate_t_r      <= '0';
            sb_rate_t_rr     <= '0';
            sb_rate_t_rrr    <= '0';
            sb_no_upd        <= '0';
            rate_count      <= (others=>'0');
        elsif rising_edge(rate_clk) then
            -- Detect tick edges
            sb_tick_t_r   <=  s_tick_t;
            sb_tick_t_rr  <= sb_tick_t_r;
            sb_tick_t_rrr <= sb_tick_t_rr;
            
            -- Detect rate edges
            sb_rate_t_r   <=  s_rate_t;
            sb_rate_t_rr  <= sb_rate_t_r;
            sb_rate_t_rrr <= sb_rate_t_rr;
            
            -- If no update is detect rate should be 0
               if sb_rate_t_rrr/=sb_rate_t_rr then sb_no_upd <= '0';
            elsif sb_tick_t_rrr/=sb_tick_t_rr then sb_no_upd <= '1';
            end if;
            
            -- Update output (rate is set to 0 if no update is detected)
               if sb_rate_t_rrr/=sb_rate_t_rr                   then rate_count <= std_logic_vector(s_cycle_count);
            elsif sb_tick_t_rrr/=sb_tick_t_rr and sb_no_upd='1' then rate_count <= (others=>'0');
            end if;
            
        end if;
        end process;
    end block blk_rate;
    
end architecture rtl;

