/*--------------------------------------------------------------------------------------------------------------------------------------------------------------
Author      : Jean-Louis FLOQUET
Title       : Package for unsigned operations
File        : pkg_std_unsigned.vhd
Application : RTL & Simulation
Created     : 2006, August 11th
Last update : 2014/02/18 17:14
Version     : 2.01.01
Dependency  : pkg_std
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Description : This package provides easy usage for operators with "ieee.numeric_std" and "pkg_std" libraries.

All STD_LOGIC_VECTOR are considered as UNSIGNED ! !

 Mini, Maxi : works with integer or std_logic_vector. Because "min" is already used in VHDL for time unit "minute" (sometimes, VHDL is really crazy : why not
              had called this "mn" ??, pfff...). So, "min" function has to be renamed to "Mini", and for consistency reasons "max" to "Maxi"
 < <= > >=  : integer or slv
 + -        : integer or slv

Notes
1) It is NOT a good idea to add comparaison functions between slv and uns. Even if these functions allow comparaisons for what they have
   been created, synthesizer will encounter problem when a slv is compared with a explicit binary constant (like "010011"). In such case,
   synthesizer is not able to choose between slv/slv and slv/uns and return error which cause synthesis to abort.

2) Operations slv/int -> int and int/slv -> int have been removed. Similar operators returning slv already exist and create ambiguous definition
   when such code is written : vector_a=vector_b+1 because 'vector_b+1' could return int or slv. So, comparaison '=' has 2 possibilities :
   performing slv=slv or slv=int.
----------------------------------------------------------------------------------------------------------------------------------------------------------------
   Rev.  |    Date    | Description
 2.01.01 | 2014/02/18 | 1) New : to_Str(slv)
 2.00.00 | 2013/12/05 | 1) Chg : VHDL-2008 required
---------+------------+-----------------------------------------------------------------------------------------------------------------------------------------
 1.08.02 | 2013/08/29 | 1) Chg : Check_Int_vs_SLV renamed to Check_SLV_vs_Int for parameters order coherency
         |            | 2) Enh : "+" & "-" mixed operations (slv/int and int/slv) verify slv length
 1.07.01 | 2012/11/19 | 1) Fix : Check_Int_vs_SLV for Xilinx compatibility
 1.06.02 | 2011/08/02 | 1) Fix : Removed operator slv/int -> int and int/slv -> int
         | 2011/10/25 | 2) New : Inside functions (GeLe,GeLt,GtLe,GtLt)
 1.05.02 | 2009/10/12 | 1) New : Functions Maxi & Mini : add support to SLV for different lengths
         | 2010/11/25 | 2) Fix : Internal function Check_Int_vs_SLV was using integers to perform a range check instead of real numbers
 1.04.01 | 2009/07/20 | 1) Chg : Imported all non signed/unsigned basic operators & comparators from pkg_math_simu
 1.03.01 | 2009/07/09 | 1) Enh : For comparisons between SLV and INTEGER, check that vector is wide enough to contain integer value
 1.02.04 | 2008/01/28 | 1) Fix : 'Mini' & 'Maxi' functions returned vector's length
         | 2008/04/22 | 2) New : Imported conv_int(slv) from pkg_std
         | 2008/06/10 | 3) New : "*" & "/" operators
         | 2009/01/17 | 4) New : Extend "*" & "/" support
 1.01.01 | 2007/08/09 | 1) New : CheckRange function (extract from obsolet pkg_math_rtl)
 1.00.00 | 2006/08/11 | Initial Release
         |            |
--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;

package pkg_std_unsigned is
--**************************************************************************************************************************************************************
-- Basic Operators
--**************************************************************************************************************************************************************
	function "+"     (l : slv ; r : slv ) return slv ;
	function "-"     (l : slv ; r : slv ) return slv ;
	function "*"     (l : slv ; r : slv ) return slv ;
	function "/"     (l : slv ; r : slv ) return slv ;

	function "+"     (l : slv ; r : int ) return slv ;
	function "-"     (l : slv ; r : int ) return slv ;
	function "*"     (l : slv ; r : int ) return slv ;
	function "/"     (l : slv ; r : int ) return slv ;

	function "+"     (l : int ; r : slv ) return slv ;
	function "-"     (l : int ; r : slv ) return slv ;
	function "*"     (l : int ; r : slv ) return slv ;
	function "/"     (l : int ; r : slv ) return slv ;

-- DO NOT ADD following operators
-- For example : in 'vector_a=vector_b+1', 'vector_b+1' could return int or slv. So, comparaison '=' could be slv/slv or slv/int)
--	function "+"     (l : slv ; r : int ) return int ;
--	function "-"     (l : slv ; r : int ) return int ;
--	function "*"     (l : slv ; r : int ) return int ;
--	function "/"     (l : slv ; r : int ) return int ;
--
--	function "+"     (l : int ; r : slv ) return int ;
--	function "-"     (l : int ; r : slv ) return int ;
--	function "*"     (l : int ; r : slv ) return int ;
--	function "/"     (l : int ; r : slv ) return int ;

	function "+"     (l : slv ; r : real) return real;
	function "-"     (l : slv ; r : real) return real;
	function "*"     (l : slv ; r : real) return real;
	function "/"     (l : slv ; r : real) return real;

	function "+"     (l : real; r : slv ) return real;
	function "-"     (l : real; r : slv ) return real;
	function "*"     (l : real; r : slv ) return real;
	function "/"     (l : real; r : slv ) return real;

	function "+"     (l : slv ; r : sl  ) return slv ;
	function "-"     (l : slv ; r : sl  ) return slv ;

--**************************************************************************************************************************************************************
-- Comparators
--**************************************************************************************************************************************************************
	function "="     (l : slv ; r : slv ) return boolean;
	function "/="    (l : slv ; r : slv ) return boolean;
	function "<"     (l : slv ; r : slv ) return boolean;
	function "<="    (l : slv ; r : slv ) return boolean;
	function ">"     (l : slv ; r : slv ) return boolean;
	function ">="    (l : slv ; r : slv ) return boolean;

-- DO NOT ADD following operators
-- Comparaison between a slv and an explicit binary constant (like "010011") could be performed with slv/slv or slv/uns.
--	function "="     (l : slv ; r : uns ) return boolean;
--	function "/="    (l : slv ; r : uns ) return boolean;
--	function "<"     (l : slv ; r : uns ) return boolean;
--	function "<="    (l : slv ; r : uns ) return boolean;
--	function ">"     (l : slv ; r : uns ) return boolean;
--	function ">="    (l : slv ; r : uns ) return boolean;
--
--	function "="     (l : uns ; r : slv ) return boolean;
--	function "/="    (l : uns ; r : slv ) return boolean;
--	function "<"     (l : uns ; r : slv ) return boolean;
--	function "<="    (l : uns ; r : slv ) return boolean;
--	function ">"     (l : uns ; r : slv ) return boolean;
--	function ">="    (l : uns ; r : slv ) return boolean;

	function "="     (l : slv ; r : int ) return boolean;
	function "/="    (l : slv ; r : int ) return boolean;
	function "<"     (l : slv ; r : int ) return boolean;
	function "<="    (l : slv ; r : int ) return boolean;
	function ">"     (l : slv ; r : int ) return boolean;
	function ">="    (l : slv ; r : int ) return boolean;

	function "="     (l : int ; r : slv ) return boolean;
	function "/="    (l : int ; r : slv ) return boolean;
	function "<"     (l : int ; r : slv ) return boolean;
	function "<="    (l : int ; r : slv ) return boolean;
	function ">"     (l : int ; r : slv ) return boolean;
	function ">="    (l : int ; r : slv ) return boolean;

--**************************************************************************************************************************************************************
-- Maxi & Mini
--**************************************************************************************************************************************************************
	function Maxi    (l : slv ; r : int ; size : int) return slv;
	function Maxi    (l : int ; r : slv ; size : int) return slv;
	function Maxi    (l : slv ; r : int             ) return int;
	function Maxi    (l : int ; r : slv             ) return int;
	function Maxi    (l : slv ; r : slv             ) return slv;
	function Maxi    (l : slv ; r : slv ; size : int) return slv;

	function Maxi    (l : uns ; r : int ; size : int) return uns;
	function Maxi    (l : int ; r : uns ; size : int) return uns;
	function Maxi    (l : uns ; r : int             ) return int;
	function Maxi    (l : int ; r : uns             ) return int;
	function Maxi    (l : uns ; r : uns             ) return uns;

	function Mini    (l : slv ; r : int ; size : int) return slv;
	function Mini    (l : int ; r : slv ; size : int) return slv;
	function Mini    (l : slv ; r : int             ) return int;
	function Mini    (l : int ; r : slv             ) return int;
	function Mini    (l : slv ; r : slv             ) return slv;
	function Mini    (l : slv ; r : slv ; size : int) return slv;

	function Mini    (l : uns ; r : int ; size : int) return uns;
	function Mini    (l : int ; r : uns ; size : int) return uns;
	function Mini    (l : uns ; r : int             ) return int;
	function Mini    (l : int ; r : uns             ) return int;
	function Mini    (l : uns ; r : uns             ) return uns;

--**************************************************************************************************************************************************************
-- Inside
--**************************************************************************************************************************************************************
	function GeLe (a : slv ; l : int ; r : int) return boolean; -- True if l<=a<=r
	function GeLt (a : slv ; l : int ; r : int) return boolean; -- True if l<=a< r
	function GtLe (a : slv ; l : int ; r : int) return boolean; -- True if l< a<=r
	function GtLt (a : slv ; l : int ; r : int) return boolean; -- True if l< a< r

	function GeLe (a : slv ; l : slv ; r : int) return boolean; -- True if l<=a<=r
	function GeLt (a : slv ; l : slv ; r : int) return boolean; -- True if l<=a< r
	function GtLe (a : slv ; l : slv ; r : int) return boolean; -- True if l< a<=r
	function GtLt (a : slv ; l : slv ; r : int) return boolean; -- True if l< a< r

	function GeLe (a : slv ; l : int ; r : slv) return boolean; -- True if l<=a<=r
	function GeLt (a : slv ; l : int ; r : slv) return boolean; -- True if l<=a< r
	function GtLe (a : slv ; l : int ; r : slv) return boolean; -- True if l< a<=r
	function GtLt (a : slv ; l : int ; r : slv) return boolean; -- True if l< a< r

	function GeLe (a : slv ; l : slv ; r : slv) return boolean; -- True if l<=a<=r
	function GeLt (a : slv ; l : slv ; r : slv) return boolean; -- True if l<=a< r
	function GtLe (a : slv ; l : slv ; r : slv) return boolean; -- True if l< a<=r
	function GtLt (a : slv ; l : slv ; r : slv) return boolean; -- True if l< a< r

--**************************************************************************************************************************************************************
-- String
--**************************************************************************************************************************************************************
	function  to_Str      (i:slv                                   ) return string   ; --
	function  to_Str      (i:slv; size:nat;padding:character:=' '  ) return string   ; -- Force return string to have 'size' digits, padding with specified character

--**************************************************************************************************************************************************************
-- Misc
--**************************************************************************************************************************************************************
	function "mod"   (l : int ; r : slv             ) return int ;
	function "mod"   (l : slv ; r : int             ) return int ;

	function conv_int  (a : slv                     ) return int ; -- SLV     -> int
	function CheckRange(val,min,max : slv           ) return sl  ;

	function to_integer(l : slv) return int;
end package pkg_std_unsigned;
--**************************************************************************************************************************************************************
--**************************************************************************************************************************************************************
--**************************************************************************************************************************************************************
package body pkg_std_unsigned is

-- This procedure checks that SLV is wide enough to be able representing the integer value
procedure Check_SLV_vs_Int(v : slv; i : int) is
begin
	--synthesis translate_off
		assert real(i)<real(2.0**v'length)
			report "[Check_SLV_vs_Int] : Trying to return a slv not wide enough (" & to_Str(v'length) & "bits) to convert providen integer (" & to_Str(i) & ")"
			severity failure;
	--synthesis translate_on

	if not(SIMULATION) then
		assert i<2**Mini(v'length,31) or v'length=32
			report "[Check_SLV_vs_Int] : conv_slv tries to return a slv not wide enough (" & to_Str(v'length) & "bits) to convert providen integer (" & to_Str(i) & ")"
			severity failure;
	end if;
end procedure Check_SLV_vs_Int;
--**************************************************************************************************************************************************************
-- Basic Operators
--**************************************************************************************************************************************************************
function "+"  (l : slv ; r : slv ) return slv  is begin                        return slv(          uns(l)   +               uns(r)) ; end function "+";
function "-"  (l : slv ; r : slv ) return slv  is begin                        return slv(          uns(l)   -               uns(r)) ; end function "-";
function "*"  (l : slv ; r : slv ) return slv  is begin                        return slv(          uns(l)   *               uns(r)) ; end function "*";
function "/"  (l : slv ; r : slv ) return slv  is begin                        return slv(          uns(l)   /               uns(r)) ; end function "/";

function "+"  (l : slv ; r : int ) return slv  is begin Check_SLV_vs_Int(l,r); return slv(          uns(l)   +                   r ) ; end function "+";
function "-"  (l : slv ; r : int ) return slv  is begin Check_SLV_vs_Int(l,r); return slv(          uns(l)   -                   r ) ; end function "-";
function "*"  (l : slv ; r : int ) return slv  is begin                        return slv(          uns(l)   *                   r ) ; end function "*";
function "/"  (l : slv ; r : int ) return slv  is begin                        return slv(          uns(l)   /                   r ) ; end function "/";

function "+"  (l : int ; r : slv ) return slv  is begin Check_SLV_vs_Int(r,l); return slv(              l    +               uns(r)) ; end function "+";
function "-"  (l : int ; r : slv ) return slv  is begin Check_SLV_vs_Int(r,l); return slv(              l    -               uns(r)) ; end function "-";
function "*"  (l : int ; r : slv ) return slv  is begin                        return slv(              l    *               uns(r)) ; end function "*";
function "/"  (l : int ; r : slv ) return slv  is begin                        return slv(              l    /               uns(r)) ; end function "/";

function "+"  (l : slv ; r : real) return real is begin                        return real(conv_int(uns(l))) +                   r   ; end function "+";
function "-"  (l : slv ; r : real) return real is begin                        return real(conv_int(uns(l))) -                   r   ; end function "-";
function "*"  (l : slv ; r : real) return real is begin                        return real(conv_int(uns(l))) *                   r   ; end function "*";
function "/"  (l : slv ; r : real) return real is begin                        return real(conv_int(uns(l))) /                   r   ; end function "/";

function "+"  (l : real; r : slv ) return real is begin                        return                   l    + real(conv_int(uns(r))); end function "+";
function "-"  (l : real; r : slv ) return real is begin                        return                   l    - real(conv_int(uns(r))); end function "-";
function "*"  (l : real; r : slv ) return real is begin                        return                   l    * real(conv_int(uns(r))); end function "*";
function "/"  (l : real; r : slv ) return real is begin                        return                   l    / real(conv_int(uns(r))); end function "/";

function "+"  (l : slv ; r : sl  ) return slv  is begin                        return slv(          uns(l)  +       uns(conv_slv(r))); end function "+";
function "-"  (l : slv ; r : sl  ) return slv  is begin                        return slv(          uns(l)  -       uns(conv_slv(r))); end function "-";
--**************************************************************************************************************************************************************
-- Comparators
--**************************************************************************************************************************************************************
function "="  (l : slv ; r : slv ) return boolean is begin                        return uns(l)= uns(r); end function "=" ;
function "/=" (l : slv ; r : slv ) return boolean is begin                        return uns(l)/=uns(r); end function "/=";
function "<"  (l : slv ; r : slv ) return boolean is begin                        return uns(l)< uns(r); end function "<" ;
function "<=" (l : slv ; r : slv ) return boolean is begin                        return uns(l)<=uns(r); end function "<=";
function ">"  (l : slv ; r : slv ) return boolean is begin                        return uns(l)> uns(r); end function ">" ;
function ">=" (l : slv ; r : slv ) return boolean is begin                        return uns(l)>=uns(r); end function ">=";

function "="  (l : slv ; r : int ) return boolean is begin Check_SLV_vs_Int(l,r); return uns(l) =    r ; end function "=" ;
function "/=" (l : slv ; r : int ) return boolean is begin Check_SLV_vs_Int(l,r); return uns(l)/=    r ; end function "/=";
function "<"  (l : slv ; r : int ) return boolean is begin Check_SLV_vs_Int(l,r); return uns(l)<     r ; end function "<" ;
function "<=" (l : slv ; r : int ) return boolean is begin Check_SLV_vs_Int(l,r); return uns(l)<=    r ; end function "<=";
function ">"  (l : slv ; r : int ) return boolean is begin Check_SLV_vs_Int(l,r); return uns(l)>     r ; end function ">" ;
function ">=" (l : slv ; r : int ) return boolean is begin Check_SLV_vs_Int(l,r); return uns(l)>=    r ; end function ">=";

function "="  (l : int ; r : slv ) return boolean is begin Check_SLV_vs_Int(r,l); return     l  =uns(r); end function "=" ;
function "/=" (l : int ; r : slv ) return boolean is begin Check_SLV_vs_Int(r,l); return     l /=uns(r); end function "/=";
function "<"  (l : int ; r : slv ) return boolean is begin Check_SLV_vs_Int(r,l); return     l < uns(r); end function "<" ;
function "<=" (l : int ; r : slv ) return boolean is begin Check_SLV_vs_Int(r,l); return     l <=uns(r); end function "<=";
function ">"  (l : int ; r : slv ) return boolean is begin Check_SLV_vs_Int(r,l); return     l > uns(r); end function ">" ;
function ">=" (l : int ; r : slv ) return boolean is begin Check_SLV_vs_Int(r,l); return     l >=uns(r); end function ">=";
--**************************************************************************************************************************************************************
-- Maxi & Mini
--**************************************************************************************************************************************************************
function Maxi(l : slv ; r : int; size : int) return slv is begin if uns(l)>    r  then return conv_slv(to_integer(uns(l)),size); else return          conv_slv(      r  ,size); end if; end function Maxi;
function Maxi(l : int ; r : slv; size : int) return slv is begin if     l >uns(r) then return conv_slv(               l  ,size); else return                         r        ; end if; end function Maxi;
function Maxi(l : slv ; r : int            ) return int is begin if uns(l)>    r  then return          to_integer(uns(l))      ; else return                         r        ; end if; end function Maxi;
function Maxi(l : int ; r : slv            ) return int is begin if     l >uns(r) then return                         l        ; else return          to_integer(uns(r))      ; end if; end function Maxi;
function Maxi(l : slv ; r : slv            ) return slv is begin if uns(l)>uns(r) then return                         l        ; else return                         r        ; end if; end function Maxi;
function Maxi(l : slv ; r : slv; size : int) return slv is begin if uns(l)>uns(r) then return conv_slv(to_integer(uns(l)),size); else return conv_slv(to_integer(uns(r)),size); end if; end function Maxi;

function Maxi(l : uns ; r : int; size : int) return uns is begin if     l >    r  then return                         l        ; else return          conv_uns(      r  ,size); end if; end function Maxi;
function Maxi(l : int ; r : uns; size : int) return uns is begin if     l >    r  then return conv_uns(               l  ,size); else return                         r        ; end if; end function Maxi;
function Maxi(l : uns ; r : int            ) return int is begin if     l >    r  then return              to_integer(l)       ; else return                         r        ; end if; end function Maxi;
function Maxi(l : int ; r : uns            ) return int is begin if     l >    r  then return                         l        ; else return              to_integer(r)       ; end if; end function Maxi;
function Maxi(l : uns ; r : uns            ) return uns is begin if     l >    r  then return                         l        ; else return                         r        ; end if; end function Maxi;

function Mini(l : slv ; r : int; size : int) return slv is begin if uns(l)<    r  then return conv_slv(to_integer(uns(l)),size); else return          conv_slv(      r  ,size); end if; end function Mini;
function Mini(l : int ; r : slv; size : int) return slv is begin if     l <uns(r) then return conv_slv(               l  ,size); else return                         r        ; end if; end function Mini;
function Mini(l : slv ; r : int            ) return int is begin if uns(l)<    r  then return          to_integer(uns(l))      ; else return                         r        ; end if; end function Mini;
function Mini(l : int ; r : slv            ) return int is begin if     l <uns(r) then return                         l        ; else return          to_integer(uns(r))      ; end if; end function Mini;
function Mini(l : slv ; r : slv            ) return slv is begin if uns(l)<uns(r) then return                         l        ; else return                         r        ; end if; end function Mini;
function Mini(l : slv ; r : slv; size : int) return slv is begin if uns(l)<uns(r) then return conv_slv(to_integer(uns(l)),size); else return conv_slv(to_integer(uns(r)),size); end if; end function Mini;

function Mini(l : uns ; r : int; size : int) return uns is begin if     l <    r  then return conv_uns(to_integer(    l ),size); else return          conv_uns(      r  ,size); end if; end function Mini;
function Mini(l : int ; r : uns; size : int) return uns is begin if     l <    r  then return conv_uns(               l  ,size); else return                         r        ; end if; end function Mini;
function Mini(l : uns ; r : int            ) return int is begin if     l <    r  then return              to_integer(l)       ; else return                         r        ; end if; end function Mini;
function Mini(l : int ; r : uns            ) return int is begin if     l <    r  then return                         l        ; else return              to_integer(r)       ; end if; end function Mini;
function Mini(l : uns ; r : uns            ) return uns is begin if     l >    r  then return                         l        ; else return                         r        ; end if; end function Mini;
--**************************************************************************************************************************************************************
-- Inside
--**************************************************************************************************************************************************************
function GeLe(a : slv ; l : int ; r : int) return boolean is begin return     l <=uns(a) and uns(a)<=    r ; end function GeLe;
function GeLt(a : slv ; l : int ; r : int) return boolean is begin return     l <=uns(a) and uns(a)<     r ; end function GeLt;
function GtLe(a : slv ; l : int ; r : int) return boolean is begin return     l < uns(a) and uns(a)<=    r ; end function GtLe;
function GtLt(a : slv ; l : int ; r : int) return boolean is begin return     l < uns(a) and uns(a)<     r ; end function GtLt;

function GeLe(a : slv ; l : slv ; r : int) return boolean is begin return uns(l)<=uns(a) and uns(a)<=    r ; end function GeLe;
function GeLt(a : slv ; l : slv ; r : int) return boolean is begin return uns(l)<=uns(a) and uns(a)<     r ; end function GeLt;
function GtLe(a : slv ; l : slv ; r : int) return boolean is begin return uns(l)< uns(a) and uns(a)<=    r ; end function GtLe;
function GtLt(a : slv ; l : slv ; r : int) return boolean is begin return uns(l)< uns(a) and uns(a)<     r ; end function GtLt;

function GeLe(a : slv ; l : int ; r : slv) return boolean is begin return     l <=uns(a) and uns(a)<=uns(r); end function GeLe;
function GeLt(a : slv ; l : int ; r : slv) return boolean is begin return     l <=uns(a) and uns(a)< uns(r); end function GeLt;
function GtLe(a : slv ; l : int ; r : slv) return boolean is begin return     l < uns(a) and uns(a)<=uns(r); end function GtLe;
function GtLt(a : slv ; l : int ; r : slv) return boolean is begin return     l < uns(a) and uns(a)< uns(r); end function GtLt;

function GeLe(a : slv ; l : slv ; r : slv) return boolean is begin return uns(l)<=uns(a) and uns(a)<=uns(r); end function GeLe;
function GeLt(a : slv ; l : slv ; r : slv) return boolean is begin return uns(l)<=uns(a) and uns(a)< uns(r); end function GeLt;
function GtLe(a : slv ; l : slv ; r : slv) return boolean is begin return uns(l)< uns(a) and uns(a)<=uns(r); end function GtLe;
function GtLt(a : slv ; l : slv ; r : slv) return boolean is begin return uns(l)< uns(a) and uns(a)< uns(r); end function GtLt;
--**************************************************************************************************************************************************************
-- String
--**************************************************************************************************************************************************************
function to_Str(i:slv                                 ) return string is begin return to_Str(conv_int(i)             ); end function to_Str;
function to_Str(i:slv; size:nat;padding:character:=' ') return string is begin return to_Str(conv_int(i),size,padding); end function to_Str;
--**************************************************************************************************************************************************************
-- MISC
--**************************************************************************************************************************************************************
function "mod" (l : int ; r : slv  ) return int is begin              return              l   mod conv_int(uns(r)); end function "mod";
function "mod" (l : slv ; r : int  ) return int is begin              return conv_int(uns(l)) mod              r  ; end function "mod";

function conv_int    (a:slv                ) return int is begin                return to_integer(unsigned(a))    ; end function conv_int;-- SLV     -> INT

function CheckRange(val,min,max : slv) return sl is
begin
	if val>=min and val<=max then return '1';
	else                          return '0'; end if;
end function CheckRange;

function to_integer(l : slv) return int is
begin
	return to_integer(unsigned(l));
end function to_integer;
end package body pkg_std_unsigned;
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
--##############################################################################################################################################################
