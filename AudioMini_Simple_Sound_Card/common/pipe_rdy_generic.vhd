----------------------------------------------------------------------------------------------------
-- Copyright (c) ReFLEX CES 1998-2012
--
-- Use of this source code through a simulator and/or a compiler tool
-- is illegal if not authorised through ReFLEX CES License agreement.
----------------------------------------------------------------------------------------------------
-- Project     : 
----------------------------------------------------------------------------------------------------
-- Top level   :  
-- File        : pipe_rdy_generic.vhd
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
-- Break path by inserting register on data and ready signals in a READY / VALID data path.
--
----------------------------------------------------------------------------------------------------
-- Version      Date            Author              Description
-- 0.1          2012/07/03      FLA                 Creation
----------------------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.std_logic_unsigned.all;

entity pipe_rdy_generic is
    generic (
          DATA_WIDTH            : integer := 1          -- Number of bits for data vector
    );
    port (
          rst_n                 : in    std_logic   := '1'
        ; rst                   : in    std_logic   := '0'
        ; clk                   : in    std_logic
        ; i_dat                 : in    std_logic_vector(DATA_WIDTH-1 downto 0)    
        ; i_vld                 : in    std_logic
        ; i_rdy                 : out   std_logic
        ; o_dat                 : out   std_logic_vector(DATA_WIDTH-1 downto 0)    
        ; o_vld                 : out   std_logic
        ; o_rdy                 : in    std_logic
    );
end entity pipe_rdy_generic;

architecture rtl of pipe_rdy_generic is
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
    signal s_i_rdy      : std_logic;
    signal s_int_vld    : std_logic;
    signal s_out_vld    : std_logic;
    signal s_int_dat    : std_logic_vector(i_dat'range);
begin
    
    process (clk, rst_n, rst)
    begin
    if rst_n='0' or rst='1' then 
        s_out_vld   <= '0';
        o_dat       <= (others=>'0');
        s_i_rdy     <= '0';
        s_int_vld   <= '0';
        s_int_dat   <= (others=>'0');
    elsif rising_edge(clk) then
    
        -- Manage ready
           if s_i_rdy='1' and i_vld='1' and (o_rdy='0' and s_out_vld='1') then s_i_rdy <= '0';
        else                                                                   s_i_rdy <= o_rdy or not(s_out_vld);
        end if;
        
        -- Manage backup valid
           if s_i_rdy='1' and i_vld='1' and (o_rdy='0' and s_out_vld='1') then s_int_vld <= '1';
        elsif s_out_vld='1' and o_rdy='1' and s_int_vld='1'               then s_int_vld <= '0';
        end if;
        
        -- Manage backup data
           if s_i_rdy='1' and i_vld='1' and (o_rdy='0' and s_out_vld='1') then s_int_dat <= i_dat;
        end if;
    
        -- Manage output valid
           if s_i_rdy='1' and i_vld='1' and (o_rdy='1'  or s_out_vld='0') then s_out_vld <= '1';
        elsif s_out_vld='1' and o_rdy='1' and s_int_vld='1'               then s_out_vld <= '1';
        elsif s_out_vld='1' and o_rdy='1' and s_int_vld='0'               then s_out_vld <= '0';
        end if;
        
        -- Manage output data
           if s_i_rdy='1' and i_vld='1' and (o_rdy='1'  or s_out_vld='0') then o_dat <= i_dat;
        elsif s_out_vld='1' and o_rdy='1' and s_int_vld='1'               then o_dat <= s_int_dat;
        end if;
        
    end if;
    end process;   
    
    i_rdy   <= s_i_rdy;
    o_vld   <= s_out_vld;
    
    
end architecture rtl;
