library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package pll_sys_pkg is
	component pll_sys_altera_iopll_180_hm2x5zi is
		port (
			rst      : in  std_logic := 'X'; -- reset
			refclk   : in  std_logic := 'X'; -- clk
			locked   : out std_logic;        -- export
			outclk_0 : out std_logic         -- clk
		);
	end component pll_sys_altera_iopll_180_hm2x5zi;

end pll_sys_pkg;
