----------------------------------------------------------------------------------------------------
-- Copyright (c) ReFLEX CES 1998-2011
--
-- Use of this source code through a simulator and/or a compiler tool
-- is illegal if not authorised through ReFLEX CES License agreement.
----------------------------------------------------------------------------------------------------
-- Project     : 
----------------------------------------------------------------------------------------------------
-- Top level   : top.vhd
-- File        : synchronizer.vhd
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
-- Delay line for signals synchronization.
--
----------------------------------------------------------------------------------------------------
-- Version      Date            Author              Description
-- 0.1          2011/12/29      FLA                 Creation
-- 0.2          2013/11/20      FLA                 Add: active high reset
-- 0.3          2014/09/25      FLA                 Upd: change delay line length
----------------------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity synchronizer is
    generic (
          V_WIDTH               : integer := 1          -- Number of bits for input and output
        ; LINE_LENGTH           : integer := 2          -- Number of stage in the delay line
    );
    port (
          rst_n                 : in    std_logic   := '1'
        ; rst                   : in    std_logic   := '0'
        ; clk                   : in    std_logic
        ; v_in                  : in    std_logic_vector(V_WIDTH-1 downto 0)    
        ; v_out                 : out   std_logic_vector(V_WIDTH-1 downto 0)    
    );
end entity synchronizer;

architecture rtl of synchronizer is
	----------------------------------------------------------------
	-- Type declarations
	----------------------------------------------------------------
    type TDLYLine is array (natural range <>) of std_logic_vector(V_WIDTH-1 downto 0);
    
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
    signal s_dly_line   : TDLYLine(LINE_LENGTH-1 downto 0);
begin
    p_main : process (clk, rst, rst_n)
    begin
    if rst_n='0' or rst='1' then 
        s_dly_line  <= (others=>(others=>'0'));
    elsif rising_edge(clk) then
        s_dly_line <= s_dly_line(s_dly_line'high-1 downto 0) & v_in;
    end if;
    end process p_main;   
    
    v_out <= s_dly_line(s_dly_line'high);
    
end architecture rtl;
