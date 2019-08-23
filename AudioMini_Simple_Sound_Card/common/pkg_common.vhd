----------------------------------------------------------------------------------------------------
-- Copyright (c) ReFLEX CES 1998-2016
--
-- Use of this source code through a simulator and/or a compiler tool
-- is illegal if not authorised through ReFLEX CES License agreement.
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Author      : Frédéric Lavenant (from Jean-Louis FLOQUET entity)
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
-- 0.1          2014/04/01      FLA                  Creation
-- 0.2          2016/10/13      JDU                 Change lib_jlf to work 
----------------------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

package pkg_common is
    -- Get string at index idx in a string list (use ';' as separator at end of each element).
    function GetStringIdx(str : string; idx : integer) return string;
end package pkg_common;

package body pkg_common is
    --============================================================================================================================
    -- Get string at index idx in a string list (use ';' as separator at end of each element).
    --============================================================================================================================
    function GetStringIdx(str : string; idx : integer) return string is
        variable v_rtn      : string (str'range) := (others=>character'val(0));
        variable v_idx      : integer;
        variable v_pos_s    : integer;
    begin
        v_pos_s := 1;
        v_idx   := 0;
        
        for v_pos_e in 1 to str'length loop
            if str(v_pos_e)=';' then
                if v_idx=idx then
                    return str(v_pos_s to v_pos_e-1);
                else
                    v_idx   := v_idx + 1;
                    v_pos_s := v_pos_e + 1;
                end if;
            end if;
        end loop;
        
        report "[GetStringIdx]: function did not find the indexed string." severity failure;
        
        return v_rtn;
    end function GetStringIdx;
end package body pkg_common;
