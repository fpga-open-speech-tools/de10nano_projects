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
-- 0.1          2015/03/11      FLA                  Creation
-- 0.2          2016/10/13      JDU                 Change lib_jlf to work 
----------------------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

entity pipe_generic is
    generic (
          DATA_WIDTH        : integer           := 33           --
        ; REG_MODE          : string            := "none"       -- "none", "data_only", "data_ready"
    );  
    port (  
          rst               : in    sl                          -- Active high (A)synchronous reset
        ; clk               : in    sl                          --
        
        -- Input interface
        ; i_dat             : in    slv(DATA_WIDTH-1 downto 0)  --
        ; i_vld             : in    sl                          --
        ; i_rdy             : out   sl                          --
            
        -- Output interface 
        ; o_dat             : out   slv(DATA_WIDTH-1 downto 0)  --
        ; o_vld             : out   sl                          --
        ; o_rdy             : in    sl                          --
    );
end entity pipe_generic;

architecture rtl of pipe_generic is
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
    signal s_i_rdy  : sl;
    signal s_o_vld  : sl;
begin

    --============================================================================================================================
    -- No register
    --============================================================================================================================
    gen_o_none : if REG_MODE="none" generate
    begin
        o_vld   <= i_vld;
        o_dat   <= i_dat;
        i_rdy   <= o_rdy;
    end generate gen_o_none;
    
    --============================================================================================================================
    -- Register on data only
    --============================================================================================================================
    gen_o_datonly : if REG_MODE="data_only" generate
    begin
        i_pipe_dat_generic : entity work.pipe_dat_generic
        generic map (
              DATA_WIDTH => DATA_WIDTH      --     integer                    := 33 -- 
        ) port map (
              rst        => rst             -- in  sl                               -- Active high (A)synchronous reset
            , clk        => clk             -- in  sl                               -- 
            , i_dat      => i_dat           -- in  slv(DATA_WIDTH-1 downto 0)       -- 
            , i_vld      => i_vld           -- in  sl                               -- 
            , i_rdy      => i_rdy           -- out sl                               -- 
            , o_dat      => o_dat           -- out slv(DATA_WIDTH-1 downto 0)       -- 
            , o_vld      => o_vld           -- out sl                               -- 
            , o_rdy      => o_rdy           -- in  sl                               -- 
        );
    end generate gen_o_datonly;
    
    --============================================================================================================================
    -- Register on data and ready
    --============================================================================================================================
    gen_o_datrdy : if REG_MODE="data_ready" generate
    begin
        i_pipe_rdy_generic : entity work.pipe_rdy_generic
        generic map (
              DATA_WIDTH => DATA_WIDTH      --     integer                                 := 1   -- Number of bits for data vector
        ) port map (
              rst        => rst             -- in  std_logic                               := '0' -- 
            , clk        => clk             -- in  std_logic                                      -- 
            , i_dat      => i_dat           -- in  std_logic_vector(DATA_WIDTH-1 downto 0)        -- 
            , i_vld      => i_vld           -- in  std_logic                                      -- 
            , i_rdy      => i_rdy           -- out std_logic                                      -- 
            , o_dat      => o_dat           -- out std_logic_vector(DATA_WIDTH-1 downto 0)        -- 
            , o_vld      => o_vld           -- out std_logic                                      -- 
            , o_rdy      => o_rdy           -- in  std_logic                                      -- 
        );
    end generate gen_o_datrdy;
    
end architecture rtl;
