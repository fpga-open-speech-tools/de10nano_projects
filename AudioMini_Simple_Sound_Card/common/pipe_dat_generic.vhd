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
-- 0.1          2014/01/27      FLA                  Creation
-- 0.2          2016/10/13      JDU                 Change lib_jlf to work 
----------------------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

entity pipe_dat_generic is
    generic (
          DATA_WIDTH        : integer   := 33                   --
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
end entity pipe_dat_generic;

architecture rtl of pipe_dat_generic is
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

    process (rst, clk)
    begin
    if rst='1' then
        o_dat   <= (others=>'0');
        s_o_vld <= '0';
    elsif rising_edge(clk) then
        -- Output data
        if i_vld='1' and s_i_rdy='1' then o_dat <= i_dat; end if;
        
        -- Output validation
        if s_i_rdy='1' then s_o_vld <= i_vld; end if;
    end if;
    end process;
    
    s_i_rdy <= o_rdy or not(s_o_vld);
    i_rdy   <= s_i_rdy;
    o_vld   <= s_o_vld;
    
end architecture rtl;
