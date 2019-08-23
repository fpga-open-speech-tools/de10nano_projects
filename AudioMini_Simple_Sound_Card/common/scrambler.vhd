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
-- Scramble input data (1 + x39 + x58).
--
----------------------------------------------------------------------------------------------------
-- Version      Date            Author               Description
-- 0.1          2014/01/22      FLA                  Creation
-- 0.2          2016/10/13      JDU                 Change lib_jlf to work 
----------------------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

entity scrambler is
    generic (
          DATA_WIDTH        : integer       := 32               -- Width of data buses
        ; FLAG_WIDTH        : integer       := 2                -- Width of flag buses
    );
    port (
        -- Clock and Reset
          rst               : in    sl                          -- Active high (A)synchronous reset
        ; clk               : in    sl                          -- Clock
       
        -- Input interface
        ; i_dat             : in    slv(DATA_WIDTH-1 downto 0)  -- Raw data
        ; i_dat_flg         : in    slv(FLAG_WIDTH-1 downto 0)  -- Flags (not scrambled)
        ; i_dat_vld         : in    sl                          --
        ; i_dat_rdy         : out   sl                          --
        
        -- Output interface
        ; o_dat             : out   slv(DATA_WIDTH-1 downto 0)  -- Scrambled data
        ; o_dat_flg         : out   slv(FLAG_WIDTH-1 downto 0)  -- Flags (not scrambled)
        ; o_dat_vld         : out   sl                          --
        ; o_dat_rdy         : in    sl                          --
    );
end entity scrambler;

architecture rtl of scrambler is
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
    signal s_lfsr_init  : slv58;
    signal s_i_dat_rdy  : sl;
    signal s_o_dat_vld  : sl;
begin
  
    --#######################################################################################################################
    --#######################################################################################################################
    -- scrambler (1 + x39 + x58)
    -- Only data are scrambled.
    --#######################################################################################################################
    --#######################################################################################################################
    --============================================================================================================================
    -- Manage control signals
    --============================================================================================================================
    s_i_dat_rdy <= o_dat_rdy or not(s_o_dat_vld);
    i_dat_rdy   <= s_i_dat_rdy;
    o_dat_vld   <= s_o_dat_vld;
    
    --============================================================================================================================
    -- Main process
    --============================================================================================================================
    process (rst, clk)
        variable v_lfsr         : slv58;
        variable v_lfsr_out     : slv(DATA_WIDTH-1 downto 0);
    begin
    if rst='1' then
        s_lfsr_init     <= (1=>'1', others=>'0');
        o_dat           <= (others=>'0');
        o_dat_flg       <= (others=>'0');
        s_o_dat_vld     <= '0';
    
    elsif rising_edge(clk) then
    
        -- LFSR Init
        v_lfsr := s_lfsr_init;
    
        -- Process one turn
        for i in 0 to DATA_WIDTH-1 loop
            v_lfsr_out(i)   := i_dat(i) xor v_lfsr(39-1) xor v_lfsr(58-1);
            v_lfsr          := v_lfsr(v_lfsr'high-1 downto 0) & v_lfsr_out(i);
        end loop;
    
        -- Update LFSR init
        if i_dat_vld='1' and s_i_dat_rdy='1' then s_lfsr_init <= v_lfsr; end if;
    
        -- Update output data
        if i_dat_vld='1' and s_i_dat_rdy='1' then o_dat     <= v_lfsr_out; end if;
        if i_dat_vld='1' and s_i_dat_rdy='1' then o_dat_flg <= i_dat_flg ; end if;
        
        -- Update output validation
           if i_dat_vld='1' and s_i_dat_rdy='1' then s_o_dat_vld <= '1';
        elsif o_dat_rdy='1'                     then s_o_dat_vld <= '0';
        end if;
        
    end if;
    end process;

end architecture rtl;
