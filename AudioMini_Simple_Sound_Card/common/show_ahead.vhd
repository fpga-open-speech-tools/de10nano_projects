----------------------------------------------------------------------------------------------------
-- Copyright (c) ReFLEX CES 1998-2011
--
-- Use of this source code through a simulator and/or a compiler tool
-- is illegal if not authorised through ReFLEX CES License agreement.
----------------------------------------------------------------------------------------------------
-- Project     : 
----------------------------------------------------------------------------------------------------
-- File        : show_ahead.vhd
-- Author      : Frederic LAVENANT       flavenant@reflexces.com
-- Company     : ReFLEX CES
--               2, rue du gevaudan
--               91047 LISSES
--               FRANCE
--               http://www.reflexces.com
-- Plateforme  : 
-- Simulator   : 
-- Synthesis   : 
-- Target      : 
-- Dependency  :
----------------------------------------------------------------------------------------------------
-- Description :
--
-- Connect to a "standard" FIFO to convert its behavior to show ahead mode.
-- Preserve performance by adding some registers if needed.
-- Also allow preprocessing between FIFO data and registered output data.
--
----------------------------------------------------------------------------------------------------
-- Version      Date            Author               Description
-- 0.1          2011/06/16      FLA                  Creation
----------------------------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.std_logic_unsigned.all;

entity show_ahead is
    generic (
          DATA_BITS             : integer := 32
        ; ADD_EXTRA_REG         : boolean := false
        ; USE_PREPROCESSING     : boolean := false
    );
	port (
          clk           : in    std_logic
        ; rst           : in    std_logic := '0'
        ; rst_n         : in    std_logic := '1'
    
        -- From FIFO
        ; fifo_data     : in    std_logic_vector(DATA_BITS-1 downto 0)
        ; fifo_rdreq    : out   std_logic
        ; fifo_empty    : in    std_logic

        -- To User logic
        ; data          : out   std_logic_vector(DATA_BITS-1 downto 0)
        ; data_ack      : in    std_logic
        ; data_valid    : out   std_logic
        
        -- Optional user preprocessing (only with additional register)
        ; p0_data       : out   std_logic_vector(DATA_BITS-1 downto 0) 
        ; p0_valid      : out   std_logic                              
        ; p1_data       : in    std_logic_vector(DATA_BITS-1 downto 0) := (others=>'0')
        ; p1_update     : out   std_logic                              
	);
end entity show_ahead;

architecture rtl of show_ahead is

    --#############################################################################################################################
	-- Type declarations
	--#############################################################################################################################

	--#############################################################################################################################
	-- Constant declarations
	--#############################################################################################################################
    
	--#############################################################################################################################
	-- Function declarations
	--#############################################################################################################################

	--#############################################################################################################################
	-- Signal declarations
	--#############################################################################################################################
    signal s_p0_data        : std_logic_vector(DATA_BITS-1 downto 0);
    signal s_p1_data        : std_logic_vector(DATA_BITS-1 downto 0);
    signal s_p1_update      : std_logic;
    signal s_p1_valid       : std_logic;
    signal s_p0_valid       : std_logic;
    signal s_fifo_rdreq     : std_logic;
    
begin
    --#############################################################################################################################
    -- Combinatorial part
    --#############################################################################################################################
    ----------------------------------------------------------------
    -- Internal
    ----------------------------------------------------------------
    s_fifo_rdreq <= not(fifo_empty) and (data_ack or not(s_p0_valid) or (s_p0_valid and not(s_p1_valid))) when ADD_EXTRA_REG else
                    not(fifo_empty) and (data_ack or not(s_p0_valid));

    s_p0_data    <= fifo_data;
    
    s_p1_update  <= data_ack or (s_p0_valid and not(s_p1_valid));

    ----------------------------------------------------------------
    -- To outputs
    ----------------------------------------------------------------
    p1_update    <= s_p1_update;
    p0_data      <= s_p0_data;
    p0_valid     <= s_p0_valid;
    fifo_rdreq   <= s_fifo_rdreq;
    
    data         <= s_p1_data when ADD_EXTRA_REG else 
                    s_p0_data;
                                  
    data_valid   <= s_p1_valid when ADD_EXTRA_REG else
                    s_p0_valid;
               
    --#############################################################################################################################
    -- Synchronous part
    --#############################################################################################################################
    process (rst, rst_n, clk)
    begin
    if rst='1' or rst_n='0' then
        s_p0_valid   <= '0';
        s_p1_valid   <= '0';
        s_p1_data    <= (others=>'0'); 
        
    elsif rising_edge(clk) then
    
        ----------------------------------------------------------------
        -- Pipe stage 0
        ----------------------------------------------------------------
        if (s_fifo_rdreq='1') then
            s_p0_valid <= '1';
        else
            if (ADD_EXTRA_REG) then
                if (s_p1_update='1') then s_p0_valid <= '0'; end if;
            else
                if (data_ack='1'   ) then s_p0_valid <= '0'; end if;
            end if;
        end if;
        
        ----------------------------------------------------------------
        -- Pipe stage 1
        ----------------------------------------------------------------
        if (s_p1_update='1') then
            s_p1_valid   <= s_p0_valid;
            if (USE_PREPROCESSING) then s_p1_data    <= p1_data;
            else                        s_p1_data    <= s_p0_data;
            end if;
        end if;
        
    end if;
    end process;
    
    --#############################################################################################################################
    -- Some checking
    --#############################################################################################################################
    -- synthesis translate_off
    process
    begin
        if (USE_PREPROCESSING) then
            if (ADD_EXTRA_REG=false) then
                report "You should set ADD_EXTRA_REG=true if USE_PREPROCESSING=true" severity warning;
            end if;
        end if;
        wait;
    end process;
    -- synthesis translate_on

end architecture rtl;
