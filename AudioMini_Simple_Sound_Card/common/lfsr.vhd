----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Author      : Jean-Louis FLOQUET (FLA update)
-- Title       : Linear Feedback Shift Register
-- File        : lfsr.vhd
-- Application : RTL & Simulation
-- Created     : 2009, October 19th
-- Last update : 2012/05/31 15:15
-- Version     : 1.01.01
-- Dependency  : pkg_std
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Description : This function generate a full-length sequence of pseudo-random number (all numbers except 0 are generated -> length=(2^N)-1)
--               LFSR is implemented according to the work of Roy Ward and Tim Molteno (October 26, 2007)
----------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Rev.   |    Date    | Description
-- 2.00.01 | 2016/10/13 | (JDU) Change lib_jlf to work 
-- 2.00.00 | 2014/01/27 | (FLA) Chg: Initial value to 1s.
-- 1.01.01 | 2012/05/31 | 1) Chg : Initial value for 'seed' to 1s because 0s don't allow starting to something
-- 1.00.00 | 2009/10/19 | Initial Release
----------------------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;
use     work.pkg_lfsr.all;

entity lfsr is generic
	( WIDTH : nat range 2 to 4096                        -- LFSR size
	); port                                              --
	( rst   : in  sl                                     -- Asynchronous reset
	; clk   : in  sl                                     -- Clock
	; ena   : in  sl                    :=          '1'  -- Clock Enable
	; load  : in  sl                    :=          '0'  -- Load
	; seed  : in  slv(WIDTH-1 downto 0) := (others=>'1') -- Initial SEED value
	; res   : out slv(WIDTH-1 downto 0)                  -- Result
	);
end entity lfsr;

architecture rtl of lfsr is
	signal    reg  : slv(WIDTH-1 downto 0)      ; -- Result
begin

process(rst,clk)
begin
if rst='1' then
	reg <= (others=>'1');
elsif rising_edge(clk) then
	   if load='1' then reg <= seed;
	elsif ena ='1' then reg <= MakeLFSR(reg); end if;
end if;
end process;

	res <= reg;

assert WIDTH<= 786 or
       WIDTH =1024 or
       WIDTH =2048 or
       WIDTH =4096
	report "[LFSR] : Unsupported WIDTH value !!"
	severity failure;

end architecture rtl;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--synthesis translate_off
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

entity lfsr_tb is
end entity lfsr_tb;

architecture testbench of lfsr_tb is
	constant  WIDTH : integer               :=           8  ; -- LFSR size
	signal    rst   : sl                    :=          '1' ; -- Asynchronous reset
	signal    clk   : sl                    :=          '1' ; -- Clock
	signal    ena   : sl                    :=          '1' ; -- Clock Enable
	signal    load  : sl                    :=          '0' ; -- Load
	signal    seed  : slv(WIDTH-1 downto 0) := (others=>'0'); -- Initial SEED value
	signal    res   : slv(WIDTH-1 downto 0)                 ; -- Result
begin

rst <= '0'      after 4 ns;
clk <= not(clk) after 5 ns;

process
begin
	wait until falling_edge(rst);
	WaitClk(clk);
	load <= '1'; seed <= (others=>'1'); WaitClk(clk);
	load <= '0'; seed <= (others=>'X'); WaitClk(clk);
	wait;
end process;

lfsr : entity work.lfsr generic map
	( WIDTH => WIDTH     --nat range 2 to 4096                        -- LFSR size
	) port map                                                        --
	( rst   => rst       --in  sl                                     -- Asynchronous reset
	, clk   => clk       --in  sl                                     -- Clock
	, ena   => ena       --in  sl                    :=          '1'  -- Clock Enable
	, load  => load      --in  sl                    :=          '0'  -- Load
	, seed  => seed      --in  slv(WIDTH-1 downto 0) := (others=>'0') -- Initial SEED value
	, res   => res       --out slv(WIDTH-1 downto 0)                  -- Result
	);


end architecture testbench;
--synthesis translate_on
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
