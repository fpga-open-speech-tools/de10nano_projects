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
-- Version      Date            Author              Description
-- 0.1          2014/01/27      FLA                 Creation
-- 0.2          2014/11/05      FLA                 Upd: use INTERNAL_RD_LAT=1 to increase Fmax (but also increase resource usage)
-- 0.3          2015/03/11      FLA                 Upd: add USE_SKIP feature.
--                                                  Upd: Rewrite some parts using blocks.
-- 0.4          2016/10/13      JDU                 Change lib_jlf to work 
----------------------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_std.all;
use     work.pkg_std_unsigned.all;

-- library altera_mf;
-- use altera_mf.altera_mf_components.all;

entity fifo_generic is
    generic (
          CLOCK_MODE        : string            := "Single"             -- "Single" or "Dual"
        ; DEVICE            : string            := "Stratix"            -- Target Device
        ; FIFO_SIZE         : integer           := 64                   -- In number of words (if 0, no FIFO is instantiated)
        ; LVL_AFULL         : integer           := -2                   -- Almost full flag threshold.
        ; DATA_WIDTH        : integer           := 32                   --
        ; IN_REG            : string            := "none"               -- "none", "data_only", "data_ready"
        ; OUT_REG           : string            := "none"               -- "none", "data_only", "data_ready"
        ; USE_EOF           : boolean           := true                 -- If true, EOF is stored with data.
        ; WAIT_EOF          : boolean           := false                -- If true, wait for EOF to validate output frame (USE_EOF must be true).
        ; USE_SKIP          : boolean           := false                -- If true, i_skp can be asserted during i_eof in order to skip the frame (invalidate data on output).
        ; INTERNAL_RD_LAT   : integer           := 0                    -- Internal FIFO read latency.
    );      
    port (      
        -- Input interface      
          i_rst             : in    sl                                  -- Active high (A)synchronous reset
        ; i_clk             : in    sl                                  --
        ; i_dat             : in    slv(DATA_WIDTH-1 downto 0)          --
        ; i_vld             : in    sl                                  --
        ; i_rdy             : out   sl                                  --
        ; i_eof             : in    sl                         := '0'   --
        ; i_skp             : in    sl                         := '0'   -- If assert during EOF, the frame is invalidated on output (skipped).
        ; i_afull           : out   sl                                  -- Almost full flag /!\ one cycle latency /!\
                        
        -- Output interface         
        ; o_rst             : in    sl                                  -- Active high (A)synchronous reset
        ; o_clk             : in    sl                                  --
        ; o_dat             : out   slv(DATA_WIDTH-1 downto 0)          --
        ; o_vld             : out   sl                                  --
        ; o_rdy             : in    sl                                  --
        ; o_eof             : out   sl                                  --
        ; o_skp             : out   sl                                  --
    );
end entity fifo_generic;

architecture rtl of fifo_generic is
    --============================================================================================================================
    -- Function and Procedure declarations
    --============================================================================================================================

    --============================================================================================================================
    -- Constant and Type declarations
    --============================================================================================================================
    constant C_PC_DATA_WIDTH    : integer := Maxi(1, conv_int(USE_SKIP))                ; -- width of data stored in ProCessing block (ensure we do not have a null range).
    constant C_FF_DATA_WIDTH    : integer := DATA_WIDTH + conv_int(USE_EOF)             ; -- width of data stored in the FiFo.
    constant C_RR_DATA_WIDTH    : integer := conv_int(USE_SKIP) + C_FF_DATA_WIDTH       ; -- width of data stored in input and output RegisteR
    
    subtype  C_DAT_BITS         is natural range DATA_WIDTH-1 downto 0;
    constant C_EOF_BIT          : integer := C_RR_DATA_WIDTH - 1 - conv_int(USE_SKIP)   ;
    constant C_SKP_BIT          : integer := C_RR_DATA_WIDTH - 1                        ;

    constant C_LOG_FIFO_SIZE    : integer := Log2(FIFO_SIZE);

    --============================================================================================================================
    -- Component declarations
    --============================================================================================================================
    
    --============================================================================================================================
    -- Signal declarations
    --============================================================================================================================
    signal s_rst            : sl;
    signal s_i_rst          : sl;
    signal s_o_rst          : sl;
    
    -- Register input related signals
    signal s_ri_o_dat       : slv(C_RR_DATA_WIDTH-1 downto 0) := (others=>'0')  ;
    signal s_ri_o_vld       : sl                                                ;
    signal s_ri_o_rdy       : sl                                                ;
    
    -- FIFO related signals
    signal s_ff_i_dat       : slv(C_RR_DATA_WIDTH-1 downto 0) := (others=>'0')  ;
    signal s_ff_i_vld       : sl                                                ;
    signal s_ff_i_rdy       : sl                                                ;
    
    signal s_ff_o_dat       : slv(C_RR_DATA_WIDTH-1 downto 0) := (others=>'0')  ;
    signal s_ff_o_vld       : sl                                                ;
    signal s_ff_o_rdy       : sl                                                ;
    
    -- Processing related signals
    signal s_pc_i_dat       : slv(C_RR_DATA_WIDTH-1 downto 0) := (others=>'0')  ;
    signal s_pc_i_vld       : sl                                                ;
    signal s_pc_i_rdy       : sl                                                ;
    
    signal s_pc_o_dat       : slv(C_RR_DATA_WIDTH-1 downto 0) := (others=>'0')  ;
    signal s_pc_o_vld       : sl                                                ;
    signal s_pc_o_rdy       : sl                                                ;
    
    -- Register output related signals
    signal s_ro_i_dat       : slv(C_RR_DATA_WIDTH-1 downto 0) := (others=>'0')  ;
    signal s_ro_i_vld       : sl                                                ;
    signal s_ro_i_rdy       : sl                                                ;
    
begin
    --============================================================================================================================
    -- Check
    --============================================================================================================================
    assert IN_REG ="none" or IN_REG ="data_only" or IN_REG ="data_ready"    report "[fifo_generic] : Invalid value for IN_REG generic."                 severity failure;
    assert OUT_REG="none" or OUT_REG="data_only" or OUT_REG="data_ready"    report "[fifo_generic] : Invalid value for OUT_REG generic."                severity failure;
    assert not(FIFO_SIZE=0 and WAIT_EOF=true)                               report "[fifo_generic] : FIFO_SIZE=0 and WAIT_EOF=true is not allowed."     severity failure;
    assert not(USE_EOF=false and WAIT_EOF=true)                             report "[fifo_generic] : USE_EOF=false and WAIT_EOF=true is not allowed."   severity failure;
    assert not(WAIT_EOF=false and USE_SKIP=true)                            report "[fifo_generic] : WAIT_EOF=false and USE_SKIP=true is not allowed."  severity failure;
    assert not(FIFO_SIZE=0 and CLOCK_MODE="Dual")                           report "[fifo_generic] : FIFO_SIZE=0 and CLOCK_MODE=Dual is not allowed."   severity failure;
    
    --############################################################################################################################
    --############################################################################################################################
    -- Reset
    --############################################################################################################################
    --############################################################################################################################
    -- Propagate reset to both sides
    s_rst <= i_rst or o_rst;
    
    -- Resync reset
    i_sync_rst : entity work.sync_rst
    generic map (
          NB_RESET     => 2             --     integer                               := 1             -- number of reset to synchronize
    ) port map (
          in_com_rst   => s_rst         -- in  std_logic                             := '0'           -- asynchronous active high reset common to all clock domains /!\ choose only one reset source for each output /!\
        , out_clk(0)   => i_clk         -- in  std_logic_vector(NB_RESET-1 downto 0)                  -- clocks used to synchronize resets
        , out_clk(1)   => o_clk         -- in  std_logic_vector(NB_RESET-1 downto 0)                  -- clocks used to synchronize resets
        , out_rst(0)   => s_i_rst       -- out std_logic_vector(NB_RESET-1 downto 0)                  -- synchronous de-asserted active high resets
        , out_rst(1)   => s_o_rst       -- out std_logic_vector(NB_RESET-1 downto 0)                  -- synchronous de-asserted active high resets
    );
    
    --############################################################################################################################
    --############################################################################################################################
    -- Input register (RR)
    --############################################################################################################################
    --############################################################################################################################
    blk_rr_in : block is
        signal sb_ri_i_dat       : slv(C_RR_DATA_WIDTH-1 downto 0)   ;
    begin
        --============================================================================================================================
        -- Combine data and flags
        --============================================================================================================================
        process (i_dat, i_eof, i_skp)
        begin
                             sb_ri_i_dat(C_DAT_BITS) <= i_dat;
            if USE_EOF  then sb_ri_i_dat(C_EOF_BIT)  <= i_eof; end if;
            if USE_SKIP then sb_ri_i_dat(C_SKP_BIT)  <= i_skp; end if;
        end process;
        
        --============================================================================================================================
        -- Pipe
        --============================================================================================================================
        i_pipe_generic : entity work.pipe_generic
        generic map (
              DATA_WIDTH => C_RR_DATA_WIDTH     --     integer                    := 33     -- 
            , REG_MODE   => IN_REG              --     string                     := "none" -- "none", "data_only", "data_ready"
        ) port map (
              rst        => s_i_rst             -- in  sl                                   -- Active high (A)synchronous reset
            , clk        => i_clk               -- in  sl                                   -- 
            , i_dat      => sb_ri_i_dat         -- in  slv(DATA_WIDTH-1 downto 0)           -- 
            , i_vld      => i_vld               -- in  sl                                   -- 
            , i_rdy      => i_rdy               -- out sl                                   -- 
            , o_dat      => s_ri_o_dat          -- out slv(DATA_WIDTH-1 downto 0)           -- 
            , o_vld      => s_ri_o_vld          -- out sl                                   -- 
            , o_rdy      => s_ri_o_rdy          -- in  sl                                   -- 
        );
        
    end block blk_rr_in;
    
    --############################################################################################################################
    --############################################################################################################################
    -- FIFO (FF)
    --############################################################################################################################
    --############################################################################################################################
    --============================================================================================================================
    -- Block input connect
    --============================================================================================================================
    -- Inputs
    s_ff_i_dat <= s_ri_o_dat;
    s_ff_i_vld <= s_ri_o_vld;
    s_ri_o_rdy <= s_ff_i_rdy;
    
    --============================================================================================================================
    -- FIFO instance
    --============================================================================================================================
    gen_fifo : if FIFO_SIZE>0 generate
        signal sb_ff_full           : sl;
        signal sb_ff_rdempty        : sl;
        signal sb_ff_wrreq          : sl;
        signal sb_ff_rdreq          : sl;
        signal sb_ff_rdack          : sl;
        signal sb_ff_usedw          : slv(C_LOG_FIFO_SIZE downto 0);
        signal sb_ff_wrdat          : slv(C_FF_DATA_WIDTH-1 downto 0);
        signal sb_ff_rddat          : slv(C_FF_DATA_WIDTH-1 downto 0);
    begin
        ------------------------------------------------
        -- Input
        ------------------------------------------------
        sb_ff_wrreq <= s_ff_i_rdy and s_ff_i_vld;
        sb_ff_wrdat <= s_ff_i_dat(sb_ff_wrdat'range);
        s_ff_i_rdy      <= not(sb_ff_full);
        
        ------------------------------------------------
        -- Data storage
        ------------------------------------------------
        i_buffer2ck : entity work.buffer2ck
        generic map( 
              CLOCK_MODE        => CLOCK_MODE               -- string                                        := "Dual"        -- "Single" / "Dual"
            , DEVICE            => DEVICE                   -- string                                        := "Stratix"     -- Target Device
            , RAM_BLOCK_TYPE    => "AUTO"                   -- string                                        := "AUTO"        -- "M512", "M4K", "M-RAM", "AUTO"
            , BYTE_MODE         => 9                        -- natural range 8 to 9                          := 8             -- Size for one "byte". If 9, use extra-bit from Memory block
            , RAW_DPS           => true                     -- boolean                                       := false         -- Enable all datapath size (but in this case, both sides shall have the same size)
            , A_APS             => C_LOG_FIFO_SIZE          -- natural                                       :=  8            -- Address Path Size
            , A_DPS             => C_FF_DATA_WIDTH          -- natural                                       := 16            -- Data    Path Size
            , A_LVL_FULL        => -1                       -- integer                                       :=  0            -- Level to report buffer as full
            , B_APS             => C_LOG_FIFO_SIZE          -- natural                                       :=  7            -- Address Path Size
            , B_DPS             => C_FF_DATA_WIDTH          -- natural                                       := 32            -- Data    Path Size
            , B_LAT_RD_DATA     => INTERNAL_RD_LAT          -- natural range 0 to 2                          :=  2            -- Read Latency between B_RdReq and B_RdData
        )                       
        port map(               
              A_Dmn.rst         => s_i_rst                  -- in  sl                                                        -                                 - Asynchronous reset
            , A_Dmn.ena         => '1'                      -- in  sl                                                        -                                 - Asynchronous reset
            , A_Dmn.clk         => i_clk                    -- in  sl                                                        -                                 - Asynchronous reset
            , A_Full            => sb_ff_full               -- out sl                                                        -                                 - Buffer is full
            , A_WrReq           => sb_ff_wrreq              -- in  sl                                        :=          '0' -                                 - Write Request
            , A_WrData          => sb_ff_wrdat              -- in  slv(     A_DPS                                            -1      downto 0) := (others=>'0')-- Write Data
            , A_UsedWord        => sb_ff_usedw              -- out slv(A_APS                       downto 0)                  -- Number of words for this side (msb <=> full)
            , B_Dmn.rst         => s_o_rst                  -- in  sl                                                        -                                 - Asynchronous reset
            , B_Dmn.ena         => '1'                      -- in  sl                                                        -                                 - Asynchronous reset
            , B_Dmn.clk         => o_clk                    -- in  sl                                                        -                                 - Asynchronous reset
            , B_Empty           => sb_ff_rdempty            -- out sl                                                        -                                 - Buffer is empty
            , B_RdReq           => sb_ff_rdreq              -- in  sl                                        :=          '0' -                                 - Read Request
            , B_RdAck           => sb_ff_rdack              -- out  sl                                        :=          '0'-                                 - Read Request
            , B_RdData          => sb_ff_rddat              -- out slv(     B_DPS                                            -1      downto 0)                 -- Read Data
        );
        
        -- Show ahead mode for RD_LAT=1
        gen_rd_lat_1 : if INTERNAL_RD_LAT=1 generate
            signal sb_ff_r          : slv(sb_ff_rddat'range);
        begin
            sb_ff_rdreq <= not(sb_ff_rdempty) and (s_ff_o_rdy or not(s_ff_o_vld));
            
            process (s_o_rst, o_clk)
            begin
            if s_o_rst='1' then
                s_ff_o_vld      <= '0';
                sb_ff_r         <= (others=>'0');
                
            elsif rising_edge(o_clk) then
                -- Data not valid
                if s_ff_o_rdy='1' or s_ff_o_vld='0' then s_ff_o_vld <= not(sb_ff_rdempty); end if;
                
                -- Data storage
                if sb_ff_rdack='1' then sb_ff_r <= sb_ff_rddat; end if;
            end if;
            end process;
            
            s_ff_o_dat(sb_ff_rddat'range) <= sb_ff_rddat when sb_ff_rdack='1' else sb_ff_r;
        end generate gen_rd_lat_1;
        
        -- Already show ahead
        gen_rd_lat_0 : if INTERNAL_RD_LAT=0 generate
            s_ff_o_vld                      <= not(sb_ff_rdempty);
            sb_ff_rdreq                     <= not(sb_ff_rdempty) and s_ff_o_rdy;
            s_ff_o_dat(sb_ff_rddat'range)   <= sb_ff_rddat;
        end generate gen_rd_lat_0;
        
        ------------------------------------------------
        -- Almost full
        ------------------------------------------------
        process (s_i_rst, i_clk)
        begin
        if s_i_rst='1' then
            i_afull <= '0';
        elsif rising_edge(i_clk) then
               if (LVL_AFULL<0 and sb_ff_usedw>=FIFO_SIZE+LVL_AFULL) then i_afull <= '1';
            elsif (LVL_AFULL>0 and sb_ff_usedw>=          LVL_AFULL) then i_afull <= '1';
            else                                                          i_afull <= '0';
            end if;
        end if;
        end process;
    end generate gen_fifo;
    
    --============================================================================================================================
    -- No FIFO
    --============================================================================================================================
    gen_nofifo : if FIFO_SIZE=0 generate
    begin
        s_ff_o_dat  <= s_ff_i_dat;
        s_ff_o_vld  <= s_ff_i_vld;
        s_ff_i_rdy  <= s_ff_o_rdy;
        i_afull     <= '0';
    end generate gen_nofifo;
    
    --############################################################################################################################
    --############################################################################################################################
    -- Processing
    --############################################################################################################################
    --############################################################################################################################
    --============================================================================================================================
    -- Block input connect
    --============================================================================================================================
    s_pc_i_dat <= s_ri_o_dat;
    s_pc_i_vld <= s_ri_o_vld;
    s_pc_i_rdy <= s_ff_i_rdy; -- do not write into Processing FIFO if we cannot store corresponding data.
    
    --============================================================================================================================
    -- Processing enabled
    --============================================================================================================================
    gen_proc : if WAIT_EOF generate
        function getEOF_DEVICE return string is
        begin
            if USE_SKIP then return DEVICE  ; -- Store SKIP bit.
            else             return "EMPTY" ; -- Nothing to store.
            end if;
        end function getEOF_DEVICE;
        
        constant C_LCL_DEVICE       : string  := getEOF_DEVICE;
        
        signal sb_ff_wrreq          : sl;
        signal sb_ff_rdreq          : sl;
        signal sb_ff_rdack          : sl;
        signal sb_ff_rdempty        : sl;
        signal sb_ff_wrdat          : slv(C_PC_DATA_WIDTH-1 downto 0)   := (others=>'0');
        signal sb_ff_rddat          : slv(C_PC_DATA_WIDTH-1 downto 0);
    begin
        -- Enable wrreq and rdreq only during EOF
        sb_ff_wrreq     <= s_pc_i_dat(C_EOF_BIT) and s_pc_i_rdy and s_pc_i_vld;
        sb_ff_wrdat(0)  <= s_pc_i_dat(C_SKP_BIT);
        
        -- FIFO for EOF storage
        i_buffer2ck : entity work.buffer2ck
        generic map( 
              CLOCK_MODE        => CLOCK_MODE               -- string                                        := "Dual"        -- "Single" / "Dual"
            , DEVICE            => C_LCL_DEVICE             -- string                                        := "Stratix"     -- Target Device
            , RAW_DPS           => true                     -- boolean                                       := false         -- Enable all datapath size (but in this case, both sides shall have the same size)
            , A_APS             => C_LOG_FIFO_SIZE          -- natural                                       :=  8            -- Address Path Size
            , A_DPS             => sb_ff_wrdat'length       -- natural                                       := 16            -- Data    Path Size
            , A_LVL_FULL        => -1                       -- integer                                       :=  0            -- Level to report buffer as full
            , B_APS             => C_LOG_FIFO_SIZE          -- natural                                       :=  7            -- Address Path Size
            , B_DPS             => sb_ff_rddat'length       -- natural                                       := 32            -- Data    Path Size
            , B_LAT_RD_DATA     => INTERNAL_RD_LAT          -- natural range 0 to 2                          :=  2            -- Read Latency between B_RdReq and B_RdData
        )                       
        port map(               
              A_Dmn.rst         => s_i_rst                  -- in  sl                                                        -                                 - Asynchronous reset
            , A_Dmn.ena         => '1'                      -- in  sl                                                        -                                 - Asynchronous reset
            , A_Dmn.clk         => i_clk                    -- in  sl                                                        -                                 - Asynchronous reset
            , A_WrReq           => sb_ff_wrreq              -- in  sl                                        :=          '0' -                                 - Write Request
            , A_WrData          => sb_ff_wrdat              -- in  slv(     A_DPS                                            -1      downto 0) := (others=>'0')-- Write Data
            , B_Dmn.rst         => s_o_rst                  -- in  sl                                                        -                                 - Asynchronous reset
            , B_Dmn.ena         => '1'                      -- in  sl                                                        -                                 - Asynchronous reset
            , B_Dmn.clk         => o_clk                    -- in  sl                                                        -                                 - Asynchronous reset
            , B_Empty           => sb_ff_rdempty            -- out sl                                                        -                                 - Buffer is empty
            , B_RdReq           => sb_ff_rdreq              -- in  sl                                        :=          '0' -                                 - Read Request
            , B_RdAck           => sb_ff_rdack              -- out sl                                        :=          '0' -                                 - Read Request
            , B_RdData          => sb_ff_rddat              -- out slv(     B_DPS                                            -1      downto 0)                 -- Read Data
        );
        
        -- Show ahead mode
        gen_rd_lat_1 : if INTERNAL_RD_LAT=1 generate
            signal sb_ff_rddat_r  : slv(sb_ff_rddat'range);
        begin
            sb_ff_rdreq <= not(sb_ff_rdempty) and (s_pc_o_rdy or not(s_pc_o_vld));
            
            process (s_o_rst, o_clk)
            begin
            if s_o_rst='1' then
                s_pc_o_vld      <= '0';
                sb_ff_rddat_r   <= (others=>'0');
            elsif rising_edge(o_clk) then
                -- Data not valid
                if s_pc_o_rdy='1' or s_pc_o_vld='0' then s_pc_o_vld <= not(sb_ff_rdempty); end if;
                
                -- Data storage
                if sb_ff_rdack='1' then sb_ff_rddat_r <= sb_ff_rddat; end if;
            end if;
            end process;
            
            s_pc_o_dat(C_SKP_BIT) <= sb_ff_rddat(0) when sb_ff_rdack='1' else sb_ff_rddat_r(0);
           
        end generate gen_rd_lat_1;
        
        -- Already show ahead mode
        gen_rd_lat_0 : if INTERNAL_RD_LAT=0 generate
            s_pc_o_vld              <= not(sb_ff_rdempty);
            sb_ff_rdreq             <= not(sb_ff_rdempty) and s_pc_o_rdy;
            s_pc_o_dat(C_SKP_BIT)   <= sb_ff_rddat(0);
        end generate gen_rd_lat_0;
    end generate gen_proc;
    
    --============================================================================================================================
    -- No processing
    --============================================================================================================================
    gen_noproc : if WAIT_EOF=false generate
    begin
        s_pc_o_dat <= s_pc_i_dat;
        s_pc_o_vld <= s_pc_i_vld;
        s_pc_i_rdy <= s_pc_o_rdy;
    end generate gen_noproc;
    
    --############################################################################################################################
    --############################################################################################################################
    -- PC/FF => RR connect
    --############################################################################################################################
    --############################################################################################################################
    -- Combine data
    process (s_ff_o_dat, s_pc_o_dat)
    begin
                         s_ro_i_dat(C_DAT_BITS) <= s_ff_o_dat(C_DAT_BITS);
        if USE_EOF  then s_ro_i_dat(C_EOF_BIT)  <= s_ff_o_dat(C_EOF_BIT) ; end if;
        if USE_SKIP then s_ro_i_dat(C_SKP_BIT)  <= s_pc_o_dat(C_SKP_BIT) ; end if;
    end process;
    
    -- Valid flag
    s_ro_i_vld <= s_ff_o_vld                                                when WAIT_EOF=false else
                  s_ff_o_vld and s_pc_o_vld                                 when USE_SKIP=false else
                  s_ff_o_vld and s_pc_o_vld and not(s_pc_o_dat(C_SKP_BIT));
                  
    -- Ready flags
    s_pc_o_rdy <= s_ff_o_dat(C_EOF_BIT) and s_ff_o_vld and s_ff_o_rdy;
    s_ff_o_rdy <= s_ro_i_rdy                                                when WAIT_EOF=false else
                  s_ro_i_rdy and s_pc_o_vld                                 when USE_SKIP=false else
                  s_pc_o_vld and (s_ro_i_rdy or s_pc_o_dat(C_SKP_BIT));
    
    --############################################################################################################################
    --############################################################################################################################
    -- Output register (RR)
    --############################################################################################################################
    --############################################################################################################################
    blk_rr_out : block is
        signal sb_ro_o_dat      : slv(C_RR_DATA_WIDTH-1 downto 0);
    begin

        --============================================================================================================================
        -- Pipe
        --============================================================================================================================
        i_pipe_generic : entity work.pipe_generic
        generic map (
              DATA_WIDTH => C_RR_DATA_WIDTH     --     integer                    := 33     -- 
            , REG_MODE   => OUT_REG             --     string                     := "none" -- "none", "data_only", "data_ready"
        ) port map (
              rst        => s_o_rst             -- in  sl                                   -- Active high (A)synchronous reset
            , clk        => o_clk               -- in  sl                                   -- 
            , i_dat      => s_ro_i_dat          -- in  slv(DATA_WIDTH-1 downto 0)           -- 
            , i_vld      => s_ro_i_vld          -- in  sl                                   -- 
            , i_rdy      => s_ro_i_rdy          -- out sl                                   -- 
            , o_dat      => sb_ro_o_dat         -- out slv(DATA_WIDTH-1 downto 0)           -- 
            , o_vld      => o_vld               -- out sl                                   -- 
            , o_rdy      => o_rdy               -- in  sl                                   -- 
        );
    
        --============================================================================================================================
        -- Extract data and flags
        --============================================================================================================================
        o_dat <= sb_ro_o_dat(C_DAT_BITS)                        ;
        o_eof <= sb_ro_o_dat(C_EOF_BIT)  when USE_EOF   else '0';
        o_skp <= sb_ro_o_dat(C_SKP_BIT)  when USE_SKIP  else '0';
    
    end block blk_rr_out;
    
end architecture rtl;
