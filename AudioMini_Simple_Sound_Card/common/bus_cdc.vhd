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
-- 0.1          2014/09/05      FLA                  Creation
-- 0.2          2016/10/13      JDU                 Change lib_jlf to work 
----------------------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

entity bus_cdc is
	generic (
          BUS_WIDTH             : integer                           := 8                -- bus width
        ; BUS_INV               : boolean                           := false            -- if 'true' o_bus=not(i_bus)
	);          
    port (  
          i_rst                 : in    sl                          := '0'              -- Asynchronous reset (active high)
        ; i_clk                 : in    sl                                              -- 
        ; i_rst_value           : in    slv(BUS_WIDTH-1 downto 0)   := (others=>'0')    -- 
        ; i_bus                 : in    slv(BUS_WIDTH-1 downto 0)                       -- 
        ; i_latched             : out   sl                                              -- '1' when i_bus is latched
        ; i_latch_req           : in    sl                          := '1'              -- '1' in order to latch i_bus (can be tied to '1' for continuous operation)
                        
        ; o_rst                 : in    sl                          := '0'              -- Asynchronous reset (active high)                 
        ; o_clk                 : in    sl                                              -- 
        ; o_bus                 : out   slv(BUS_WIDTH-1 downto 0)                       --   
        ; o_updated             : out   sl                                              -- '1' when o_bus is updated
	);
end entity bus_cdc;

architecture rtl of bus_cdc is
	----------------------------------------------------------------
	-- Type declarations
	----------------------------------------------------------------
    
	----------------------------------------------------------------
	-- Function declarations
	----------------------------------------------------------------
   
	----------------------------------------------------------------
	-- Constant declarations
	----------------------------------------------------------------

	----------------------------------------------------------------
	-- Component declarations
	----------------------------------------------------------------    
    
	----------------------------------------------------------------
	-- Signal declarations
	----------------------------------------------------------------
    signal s_sync_in            : sl;
    signal s_sync_i_r           : sl;
    signal s_sync_i_rr          : sl;
    signal s_sync_i_rrr         : sl;
    
    signal s_sync_out           : sl;
    signal s_sync_o_r           : sl;
    signal s_sync_o_rr          : sl;
    signal s_sync_o_rrr         : sl;
    
    signal s_i_bus_r            : slv(BUS_WIDTH-1 downto 0);
    
begin
    process (i_rst, i_clk, i_rst_value)
    begin
    if i_rst='1' then
        s_sync_o_r      <= '0';
        s_sync_o_rr     <= '0';
        s_sync_o_rrr    <= '0';
        s_sync_in       <= '0';
        s_i_bus_r       <= i_rst_value;
        i_latched       <= '0';
        
    elsif rising_edge(i_clk) then
        
        -- synchro from other clock domain
        s_sync_o_r   <= s_sync_out;
        s_sync_o_rr  <= s_sync_o_r;
        s_sync_o_rrr <= s_sync_o_rr;
        
        if s_sync_in=s_sync_o_rrr and i_latch_req='1' then
            if BUS_INV=true then
                s_i_bus_r <= not(i_bus);
            else
                s_i_bus_r <=     i_bus;
            end if;
            s_sync_in   <= not(s_sync_in);
            i_latched  <= '1';
        else
            i_latched  <= '0';
        end if;
        
    end if;
    end process;
    
    process (o_rst, o_clk, i_rst_value)
    begin
    if o_rst='1' then
        s_sync_i_r      <= '0';
        s_sync_i_rr     <= '0';
        s_sync_i_rrr    <= '0';
        s_sync_out      <= '0';
        o_bus           <= i_rst_value;
        o_updated       <= '0';
        
    elsif rising_edge(o_clk) then
        
        -- synchro from other clock domain
        s_sync_i_r      <= s_sync_in;
        s_sync_i_rr     <= s_sync_i_r;
        s_sync_i_rrr    <= s_sync_i_rr;
        s_sync_out      <= s_sync_i_rrr;
        
        if s_sync_i_rr/=s_sync_i_rrr then
            o_bus  <= s_i_bus_r;
            o_updated <= '1';
        else
            o_updated <= '0';
        end if;
        
    end if;
    end process;


end architecture rtl;
