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
-- Generic GearBox.
--
----------------------------------------------------------------------------------------------------
-- Version      Date            Author               Description
-- 0.1          2014/01/17      FLA                  Creation
-- 0.2          2016/10/13      JDU                 Change lib_jlf to work 
----------------------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_cst.all;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

entity gb_generic is
    generic (
          WIDTH_IN          : integer           := 2            -- 
        ; WIDTH_OUT         : integer           := 17           -- 
    );  
    port (  
          rst               : in    sl                          -- Active high (A)synchronous reset
        ; clk               : in    sl                          -- Clock
        
        -- Input interface
        ; i_dat             : in    slv(WIDTH_IN-1 downto 0)    --
        ; i_dat_vld         : in    sl                          --
        ; i_dat_rdy         : out   sl                          --
        
        -- Output interface
        ; o_dat             : out   slv(WIDTH_OUT-1 downto 0)   --
        ; o_dat_vld         : out   sl                          --
        ; o_dat_rdy         : in    sl                          --
        
        -- Control
        ; word_slip_req     : in    sl          := '0'          -- Assert for one cycle to skip one word on the narrower interface (effect is not immediate and depends on ration IN/OUT)
        ; word_slip_ack     : out   sl          := '0'          -- Asserted for one cycle when one word is skipped on the narrower interface.
    );
end entity gb_generic;

architecture rtl of gb_generic is
    --============================================================================================================================
    -- Function, Constant and Procedure declarations
    --============================================================================================================================
    -- Compute the Greatest Common Divisor (GCD)
    function GCD(a : integer; b : integer) return integer is
        variable v_a        : integer;
        variable v_b        : integer;
    begin
        v_a := a;
        v_b := b;
        while v_a/=v_b loop
            if (v_a<v_b) then v_b := v_b - v_a;
            else              v_a := v_a - v_b;
            end if;
        end loop;
        
        return v_a;
    end function GCD;
    
    -- How many cases for this gearbox
    constant C_GCD          : integer := GCD(WIDTH_OUT, WIDTH_IN);
    constant C_NB_CASES     : integer := Mini(WIDTH_IN, WIDTH_OUT) / C_GCD;
    
    --============================================================================================================================
    -- Type declarations
    --============================================================================================================================

    --============================================================================================================================
    -- Component declarations
    --============================================================================================================================
    
    --============================================================================================================================
    -- Signal declarations
    --============================================================================================================================
begin
    --############################################################################################################################
    --############################################################################################################################
    -- No GearBox if same width
    --############################################################################################################################
    --############################################################################################################################
    gen_nop : if WIDTH_IN=WIDTH_OUT generate
        o_dat       <= i_dat;
        o_dat_vld   <= i_dat_vld;
        i_dat_rdy   <= o_dat_rdy;
    end generate gen_nop;
    
    --############################################################################################################################
    --############################################################################################################################
    -- Wide to Narrow
    --############################################################################################################################
    --############################################################################################################################
    gen_w2n : if WIDTH_IN>WIDTH_OUT generate
        -- Return shifted extended vector
        function GetExtend(vec_n : slv(WIDTH_IN-1 downto 0); vec_p : slv(WIDTH_OUT-1 downto 0); idx : integer range 0 to C_NB_CASES-1) return slv is
            type TAValue is array (0 to C_NB_CASES-1) of slv(WIDTH_IN+WIDTH_OUT-1 downto 0);
            variable v_values   : TAValue;
            variable v_rtn      : slv(WIDTH_IN+WIDTH_OUT-1 downto 0);
        begin
            v_values := (others=>(others=>'0'));
            
            -- Generate all possible cases
            -- idx=0            : maximum shift
            -- idx=C_NB_CASES-1 : no shift
            for i in 0 to C_NB_CASES-1 loop
                for b in 0 to WIDTH_IN+(i+1)*C_GCD-1 loop --WIDTH_IN-((C_NB_CASES-1 - i)*C_GCD)-1 loop
                    if b<(i+1)*C_GCD then v_values(i)(b) := vec_p(b);
                    else                  v_values(i)(b) := vec_n(b-(i+1)*C_GCD);
                    end if;
                end loop;
            end loop;
            
            -- Choose the right one
            v_rtn := v_values(idx);
            
            return v_rtn;
        end function GetExtend;
    
        signal sb_i_dat_rdy     : sl;
        signal sb_o_dat_rdy     : sl;
        signal sb_o_dat_vld     : sl;
        signal sb_slices        : slv(WIDTH_IN-1 downto 0);
        signal sb_cnt_slice     : slv(Log2(WIDTH_IN/C_GCD)+1 downto 0);
        signal sb_word_slip_r   : sl;
    begin
        --============================================================================================================================
        -- Assignments
        --============================================================================================================================
        -- Comb.
        sb_o_dat_rdy    <= o_dat_rdy or not(sb_o_dat_vld);
        sb_i_dat_rdy    <= sb_o_dat_rdy and msb(sb_cnt_slice);
        
        -- Internal to port
        o_dat_vld       <= sb_o_dat_vld;
        i_dat_rdy       <= sb_i_dat_rdy;
        
        --============================================================================================================================
        -- Main process
        --============================================================================================================================
        process (rst, clk)
        begin
        if rst='1' then
            sb_cnt_slice    <= (others=>'1');
            sb_slices       <= (others=>'0');
            sb_o_dat_vld    <= '0';
            o_dat           <= (others=>'0');
            sb_word_slip_r  <= '0';
            word_slip_ack   <= '0';
        elsif rising_edge(clk) then
        
            ------------------------------------------------
            -- Slice counter
            ------------------------------------------------
            -- Word slip trigger
               if word_slip_req='1'                                                                 then sb_word_slip_r <= '1'; -- Set trigger
            elsif sb_o_dat_rdy='1' and msb(sb_cnt_slice)='1' and sb_i_dat_rdy='1' and i_dat_vld='1' then sb_word_slip_r <= '0'; -- Reset trigger
            elsif sb_o_dat_rdy='1' and msb(sb_cnt_slice)='0'                                        then sb_word_slip_r <= '0'; -- Reset trigger
            end if;
            
            -- Word slip acknowledge
               if sb_o_dat_rdy='1' and msb(sb_cnt_slice)='1' and sb_i_dat_rdy='1' and i_dat_vld='1' then word_slip_ack <= sb_word_slip_r;
            elsif sb_o_dat_rdy='1' and msb(sb_cnt_slice)='0'                                        then word_slip_ack <= sb_word_slip_r;
            else                                                                                         word_slip_ack <= '0';
            end if;
            
            -- Update counter
            if sb_word_slip_r='0' then -- If word slip is enabled, skip counter update for one cycle
                if sb_o_dat_rdy='1' then
                       if msb(sb_cnt_slice)='1' and sb_i_dat_rdy='1' and i_dat_vld='1' then sb_cnt_slice <= sb_cnt_slice - WIDTH_OUT/C_GCD + WIDTH_IN/C_GCD;
                    elsif msb(sb_cnt_slice)='0'                                        then sb_cnt_slice <= sb_cnt_slice - WIDTH_OUT/C_GCD;
                    end if;
                end if;
            end if;
            
            ------------------------------------------------
            -- Other signals
            ------------------------------------------------
            if sb_o_dat_rdy='1' then
                -- Get and shift input
                   if msb(sb_cnt_slice)='1' and sb_i_dat_rdy='1' and i_dat_vld='1' then sb_slices <= GetExtend(i_dat, sb_slices(WIDTH_OUT-1 downto 0), conv_int(sb_cnt_slice+C_NB_CASES))(sb_slices'high+WIDTH_OUT downto WIDTH_OUT);
                elsif msb(sb_cnt_slice)='0'                                        then sb_slices <= ZEROS(WIDTH_OUT-1 downto 0) & sb_slices(sb_slices'high downto WIDTH_OUT);
                end if;
            
                -- Output validation
                   if msb(sb_cnt_slice)='1' and sb_i_dat_rdy='1' and i_dat_vld='1' then sb_o_dat_vld <= '1';
                elsif msb(sb_cnt_slice)='0'                                        then sb_o_dat_vld <= '1';
                else                                                                    sb_o_dat_vld <= '0';
                end if;
            
                -- Output data
                   if msb(sb_cnt_slice)='1' and sb_i_dat_rdy='1' and i_dat_vld='1' then o_dat <= GetExtend(i_dat, sb_slices(WIDTH_OUT-1 downto 0), conv_int(sb_cnt_slice+C_NB_CASES))(WIDTH_OUT-1 downto 0);
                elsif msb(sb_cnt_slice)='0'                                        then o_dat <= sb_slices(WIDTH_OUT-1 downto 0);
                end if;
            end if;
        end if;
        end process;
    end generate gen_w2n;
    
    --############################################################################################################################
    --############################################################################################################################
    -- Narrow to Wide
    --############################################################################################################################
    --############################################################################################################################
    gen_n2w : if WIDTH_IN<WIDTH_OUT generate
        -- Return a slice with dynamic offset
        function GetSlice(vec_n : slv(WIDTH_IN-1 downto 0); vec_p : slv(WIDTH_OUT-C_GCD-1 downto 0); idx : integer range 0 to C_NB_CASES-1) return slv is
            type TASlice is array (0 to C_NB_CASES-1) of slv(WIDTH_OUT-1 downto 0);
            variable v_slices   : TASlice;
            variable v_rtn      : slv(WIDTH_OUT-1 downto 0);
            variable v_ext      : slv(vec_n'length+vec_p'length-1 downto 0);
        begin
            -- Extended vector
            v_ext := vec_n & vec_p;
            
            -- Generate all possible slices
            for i in 0 to C_NB_CASES-1 loop
                v_slices(i) := v_ext(i*C_GCD+WIDTH_OUT-1 downto i*C_GCD);
            end loop;
            
            -- Choose the right one
            v_rtn := v_slices(idx);
            
            return v_rtn;
        end function GetSlice;
        
        signal sb_i_dat_rdy     : sl;
        signal sb_o_dat_rdy     : sl;
        signal sb_o_dat_vld     : sl;
        signal sb_slices        : slv(WIDTH_OUT-C_GCD-1 downto 0);
        signal sb_cnt_slice     : slv(Log2(WIDTH_OUT/C_GCD)+1 downto 0);
        signal sb_word_slip_r   : sl;
    begin
        --============================================================================================================================
        -- Assignments
        --============================================================================================================================
        -- Comb.
        sb_o_dat_rdy    <= o_dat_rdy or not(sb_o_dat_vld);              -- Output stage ready if empty or interface is ready
        sb_i_dat_rdy    <= sb_o_dat_rdy or not(msb(sb_cnt_slice));      -- Input stage ready if room in accumulator or output stage ready
        
        -- Internal to port
        o_dat_vld       <= sb_o_dat_vld;
        i_dat_rdy       <= sb_i_dat_rdy;
        
        --============================================================================================================================
        -- Main process
        --============================================================================================================================
        process (rst, clk)
        begin
        if rst='1' then
            sb_cnt_slice    <= conv_slv(WIDTH_OUT/C_GCD-WIDTH_IN/C_GCD-1, sb_cnt_slice'length);
            sb_slices       <= (others=>'0');
            sb_o_dat_vld    <= '0';
            o_dat           <= (others=>'0');
            sb_word_slip_r  <= '0';
            word_slip_ack   <= '0';
        elsif rising_edge(clk) then
            ------------------------------------------------
            -- Slice counter
            ------------------------------------------------
            -- Word slip trigger
               if word_slip_req='1'                                                                 then sb_word_slip_r <= '1'; -- Set trigger
            elsif msb(sb_cnt_slice)='1' and sb_o_dat_rdy='1' and sb_i_dat_rdy='1' and i_dat_vld='1' then sb_word_slip_r <= '0'; -- Reset trigger
            elsif msb(sb_cnt_slice)='0'                      and sb_i_dat_rdy='1' and i_dat_vld='1' then sb_word_slip_r <= '0'; -- Reset trigger
            end if;
            
            -- Word slip acknowledge
               if msb(sb_cnt_slice)='1' and sb_o_dat_rdy='1' and sb_i_dat_rdy='1' and i_dat_vld='1' then word_slip_ack <= sb_word_slip_r;
            elsif msb(sb_cnt_slice)='0'                      and sb_i_dat_rdy='1' and i_dat_vld='1' then word_slip_ack <= sb_word_slip_r;
            else                                                                                         word_slip_ack <= '0';
            end if;
            
            -- Update counter
            if sb_word_slip_r='0' then -- If word slip is enabled, skip counter update for one cycle
                   if msb(sb_cnt_slice)='1' and sb_o_dat_rdy='1' and sb_i_dat_rdy='1' and i_dat_vld='1' then sb_cnt_slice <= sb_cnt_slice - WIDTH_IN/C_GCD + WIDTH_OUT/C_GCD;
                elsif msb(sb_cnt_slice)='0'                      and sb_i_dat_rdy='1' and i_dat_vld='1' then sb_cnt_slice <= sb_cnt_slice - WIDTH_IN/C_GCD;
                end if;
            end if;
            
            ------------------------------------------------
            -- Other signals
            ------------------------------------------------
            -- Accumulate input
            if sb_i_dat_rdy='1' and i_dat_vld='1' then
                if WIDTH_IN>sb_slices'high then sb_slices <= i_dat;
                else                            sb_slices <= i_dat & sb_slices(sb_slices'high downto WIDTH_IN);
                end if;
            end if;
                
            if sb_o_dat_rdy='1' then
                -- Output
                if msb(sb_cnt_slice)='1' and sb_i_dat_rdy='1' and i_dat_vld='1' then sb_o_dat_vld <= '1';
                else                                                                 sb_o_dat_vld <= '0';
                end if;
                
                -- Output data
                if msb(sb_cnt_slice)='1' and sb_i_dat_rdy='1' and i_dat_vld='1' then
                    o_dat <= GetSlice(i_dat, sb_slices, conv_int(sb_cnt_slice+C_NB_CASES));
                end if;
            end if;
        end if;
        end process;
    end generate gen_n2w;
    
end architecture rtl;
