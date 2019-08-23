--! @file
--! 
--! @author Ross Snider
--! @author Tyler Davis


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

LIBRARY altera;
USE altera.altera_primitives_components.all;


-----------------------------------------------------------
-- Signal Names are defined in the DE10-Nano User Manual
-- http://de10-nano.terasic.com
-----------------------------------------------------------
entity DE10Nano_System is

	port(
		----------------------------------------
		--  CLOCK Inputs
		--  See DE10 Nano User Manual page 23
		----------------------------------------
		FPGA_CLK1_50  :  in std_logic;										--! 50 MHz clock input #1
		FPGA_CLK2_50  :  in std_logic;										--! 50 MHz clock input #2
		FPGA_CLK3_50  :  in std_logic;										--! 50 MHz clock input #3
		
		
		----------------------------------------
		--  Push Button Inputs (KEY) 
		--  See DE10 Nano User Manual page 24
		--  The KEY push button inputs produce a '0' 
		--  when pressed (asserted)
		--  and produce a '1' in the rest (non-pushed) state
		--  a better label for KEY would be Push_Button_n 
		----------------------------------------
		KEY : in std_logic_vector(1 downto 0);								--! Two Pushbuttons (active low)
		
		
		----------------------------------------
		--  Slide Switch Inputs (SW) 
		--  See DE10 Nano User Manual page 25
		--  The slide switches produce a '0' when
		--  in the down position 
		--  (towards the edge of the board)
		----------------------------------------
		SW  : in std_logic_vector(3 downto 0);								--! Four Slide Switches 
		
		
		----------------------------------------
		--  LED Outputs 
		--  See DE10 Nano User Manual page 26
		--  Setting LED to 1 will turn it on
		----------------------------------------
		LED : out std_logic_vector(7 downto 0);							--! Eight LEDs
		
		
		----------------------------------------
		--  GPIO Expansion Headers (40-pin)
		--  See DE10 Nano User Manual page 27
		--  Pin 11 = 5V supply (1A max)
		--  Pin 29 - 3.3 supply (1.5A max)
		--  Pins 12, 30 GND
		--  Note: the DE10-Nano GPIO_0 & GPIO_1 signals
		--  have been replaced by
		--  Audio_Mini_GPIO_0 & Audio_Mini_GPIO_1
		--  since some of the DE10-Nano GPIO pins
		--  have been dedicated to the Audio Mini
		--  plug-in card.  The new signals 
		--  Audio_Mini_GPIO_0 & Audio_Mini_GPIO_1 
		--  contain the available GPIO.
		----------------------------------------
		--GPIO_0 : inout std_logic_vector(35 downto 0);					--! The 40 pin header on the top of the board
		--GPIO_1 : inout std_logic_vector(35 downto 0);					--! The 40 pin header on the bottom of the board 
		Audio_Mini_GPIO_0 : inout std_logic_vector(33 downto 0);		--! 34 available I/O pins on GPIO_0
		Audio_Mini_GPIO_1 : inout std_logic_vector(12 downto 0);		--! 13 available I/O pins on GPIO_1 
	

		----------------------------------------
		--  AD1939 Audio Codec
		--  Physical Connection signals
		----------------------------------------
      -- AD1939 clock and Reset
	   AD1939_MCLK 		    : in  std_logic;       		         --! 12.288 MHz clock driving AD1939   
	   AD1939_RST_CODEC_n    : out std_logic;  
	   -- AD1939 SPI
     AD1939_spi_CIN        : out std_logic;                      --! AD1939 SPI signal = mosi data to AD1939 registers     
     AD1939_spi_CLATCH_n   : out std_logic;                      --! AD1939 SPI signal = ss_n: slave select (active low)  
     AD1939_spi_CCLK       : out std_logic;                      --! AD1939 SPI signal = sclk: serial clock               
     AD1939_spi_COUT       : in  std_logic;                      --! AD1939 SPI signal = miso data from AD1939 registers  
	   -- AD1939 ADC Serial Data
	   AD1939_ADC_ABCLK 		 : in  std_logic;		 	               --! Serial data from AD1939 pin 28 ABCLK,   Bit Clock for ADCs (Master Mode)
	   AD1939_ADC_ALRCLK   	 : in  std_logic;	    	               --! Serial data from AD1939 pin 29 ALRCLK,  LR Clock for ADCs  (Master Mode)
	   AD1939_ADC_ASDATA2 	 : in  std_logic;	 		               --! Serial data from AD1939 pin 26 ASDATA2, ADC2 24-bit normal stereo serial mode
	   -- AD1939 DAC Serial Data
	   AD1939_DAC_DBCLK      : out std_logic;                      --! Serial data to   AD1939 pin 21 DBCLK,   Bit Clock for DACs (Slave Mode)
	   AD1939_DAC_DLRCLK     : out std_logic;                      --! Serial data to   AD1939 pin 22 DLRCLK,  LR Clock for DACs  (Slave Mode)
	   AD1939_DAC_DSDATA1    : out std_logic;                      --! Serial data to   AD1939 pin 20 DSDATA1, DAC1 24-bit normal stereo serial mode

		
		----------------------------------------
		--  Headphone Amplifier TI TPA6130
		--  Physical connection signals
		----------------------------------------
		TPA6130_i2c_SDA       : inout std_logic;
		TPA6130_i2c_SCL       : inout std_logic;
		TPA6130_power_off     : out   std_logic;
		
		
		----------------------------------------
		--  Digital Microphone INMP621
		--  Physical connection signals
		----------------------------------------
		INMP621_mic_CLK       : out std_logic;
		INMP621_mic_DATA      : in  std_logic;
	
	
		----------------------------------------
		--  Audio Mini LEDs and Switches
		----------------------------------------
		Audio_Mini_LEDs     : out std_logic_vector(3 downto 0);					
		Audio_Mini_SWITCHES : in  std_logic_vector(3 downto 0);					
		
		
		----------------------------------------
		--  Arduino Uno R3 Expansion Header
		--  See DE10 Nano User Manual page 30
		--  500 ksps, 8-channel, 12-bit ADC
		----------------------------------------
		ARDUINO_IO		 : inout STD_LOGIC_VECTOR(15 downto 0);      --! 16 Arduino I/O
		ARDUINO_RESET_N : inout STD_LOGIC;                          --! Reset signal, active low
		
		
		----------------------------------------
		--  ADC
		--  See DE10 Nano User Manual page 33
		--  500 ksps, 8-channel, 12-bit ADC
		----------------------------------------
      ADC_CONVST					: out STD_LOGIC;                    --! ADC Conversion Start
		ADC_SCK						: out STD_LOGIC;                    --! ADC Serial Data Clock
		ADC_SDI						: out STD_LOGIC;                    --! ADC Serial Data Input  (FPGA to ADC)
		ADC_SDO						: in  STD_LOGIC;                    --! ADC Serial Data Output (ADC to FPGA)
		
		
		----------------------------------------
		--  Hard Processor System (HPS) 
		--  See DE10 Nano User Manual page 36
		----------------------------------------
      HPS_CONV_USB_N				: inout STD_LOGIC;
      HPS_DDR3_ADDR				: out STD_LOGIC_VECTOR(14 downto 0);
      HPS_DDR3_BA					: out STD_LOGIC_VECTOR(2 downto 0);
      HPS_DDR3_CAS_N				: out STD_LOGIC;
      HPS_DDR3_CKE				: out STD_LOGIC;
      HPS_DDR3_CK_N				: out STD_LOGIC;
      HPS_DDR3_CK_P				: out STD_LOGIC;
      HPS_DDR3_CS_N				: out STD_LOGIC;
      HPS_DDR3_DM					: out STD_LOGIC_VECTOR(3 downto 0);
      HPS_DDR3_DQ					: inout STD_LOGIC_VECTOR(31 downto 0);
      HPS_DDR3_DQS_N				: inout STD_LOGIC_VECTOR(3 downto 0);
      HPS_DDR3_DQS_P				: inout STD_LOGIC_VECTOR(3 downto 0);
      HPS_DDR3_ODT				: out STD_LOGIC;
      HPS_DDR3_RAS_N				: out STD_LOGIC;
      HPS_DDR3_RESET_N			: out STD_LOGIC;
      HPS_DDR3_RZQ				: in STD_LOGIC;
      HPS_DDR3_WE_N				: out STD_LOGIC;
      HPS_ENET_GTX_CLK			: out STD_LOGIC;
      HPS_ENET_INT_N				: inout STD_LOGIC;
      HPS_ENET_MDC				: out STD_LOGIC;
      HPS_ENET_MDIO				: inout STD_LOGIC;
      HPS_ENET_RX_CLK			: in STD_LOGIC;
      HPS_ENET_RX_DATA			: in STD_LOGIC_VECTOR(3 downto 0);
      HPS_ENET_RX_DV				: in STD_LOGIC;
      HPS_ENET_TX_DATA			: out STD_LOGIC_VECTOR(3 downto 0);
      HPS_ENET_TX_EN				: out STD_LOGIC;
      HPS_GSENSOR_INT			: inout STD_LOGIC;
      HPS_I2C0_SCLK				: inout STD_LOGIC;
      HPS_I2C0_SDAT				: inout STD_LOGIC;
      HPS_I2C1_SCLK				: inout STD_LOGIC;
      HPS_I2C1_SDAT				: inout STD_LOGIC;
      HPS_KEY						: inout STD_LOGIC;
      HPS_LED						: inout STD_LOGIC;
      HPS_LTC_GPIO				: inout STD_LOGIC;
      HPS_SD_CLK					: out STD_LOGIC;
      HPS_SD_CMD					: inout STD_LOGIC;
      HPS_SD_DATA					: inout STD_LOGIC_VECTOR(3 downto 0);
      HPS_SPIM_CLK				: out STD_LOGIC;
      HPS_SPIM_MISO				: in STD_LOGIC;
      HPS_SPIM_MOSI				: out STD_LOGIC;
      HPS_SPIM_SS					: inout STD_LOGIC;
      HPS_UART_RX					: in STD_LOGIC;
      HPS_UART_TX					: out STD_LOGIC

	);
end entity DE10Nano_System;



architecture DE10Nano_arch of DE10Nano_System is

	
  --------------------------------------------------------------
  -- SoC Component from Intel Platform Designer
  --------------------------------------------------------------
  component soc_system is
    port (
      clk_clk                             : in    std_logic                     := 'X';             -- clk
      ad1939_abclk_clk                    : in    std_logic                     := 'X';             -- clk
      ad1939_alrclk_clk                   : in    std_logic                     := 'X';             -- clk
      ad1939_mclk_clk                     : in    std_logic                     := 'X';             -- clk
      hps_f2h_dma_req0_dma_req            : in    std_logic                     := '0';             --        hps_f2h_dma_req0.dma_req
      hps_f2h_dma_req0_dma_single         : in    std_logic                     := '0';             --                        .dma_single
      hps_f2h_dma_req0_dma_ack            : out   std_logic;                                        --                        .dma_ack
      hps_f2h_dma_req1_dma_req            : in    std_logic                     := '0';             --        hps_f2h_dma_req1.dma_req
      hps_f2h_dma_req1_dma_single         : in    std_logic                     := '0';             --                        .dma_single
      hps_f2h_dma_req1_dma_ack            : out   std_logic;                                        --                        .dma_ack
      hps_h2f_reset_reset_n               : out   std_logic;                                        -- reset_n
      hps_hps_io_hps_io_emac1_inst_TX_CLK : out   std_logic;                                        -- hps_io_emac1_inst_TX_CLK
      hps_hps_io_hps_io_emac1_inst_TXD0   : out   std_logic;                                        -- hps_io_emac1_inst_TXD0
      hps_hps_io_hps_io_emac1_inst_TXD1   : out   std_logic;                                        -- hps_io_emac1_inst_TXD1
      hps_hps_io_hps_io_emac1_inst_TXD2   : out   std_logic;                                        -- hps_io_emac1_inst_TXD2
      hps_hps_io_hps_io_emac1_inst_TXD3   : out   std_logic;                                        -- hps_io_emac1_inst_TXD3
      hps_hps_io_hps_io_emac1_inst_RXD0   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD0
      hps_hps_io_hps_io_emac1_inst_MDIO   : inout std_logic                     := 'X';             -- hps_io_emac1_inst_MDIO
      hps_hps_io_hps_io_emac1_inst_MDC    : out   std_logic;                                        -- hps_io_emac1_inst_MDC
      hps_hps_io_hps_io_emac1_inst_RX_CTL : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CTL
      hps_hps_io_hps_io_emac1_inst_TX_CTL : out   std_logic;                                        -- hps_io_emac1_inst_TX_CTL
      hps_hps_io_hps_io_emac1_inst_RX_CLK : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CLK
      hps_hps_io_hps_io_emac1_inst_RXD1   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD1
      hps_hps_io_hps_io_emac1_inst_RXD2   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD2
      hps_hps_io_hps_io_emac1_inst_RXD3   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD3
      hps_hps_io_hps_io_sdio_inst_CMD     : inout std_logic                     := 'X';             -- hps_io_sdio_inst_CMD
      hps_hps_io_hps_io_sdio_inst_D0      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D0
      hps_hps_io_hps_io_sdio_inst_D1      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D1
      hps_hps_io_hps_io_sdio_inst_CLK     : out   std_logic;                                        -- hps_io_sdio_inst_CLK
      hps_hps_io_hps_io_sdio_inst_D2      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D2
      hps_hps_io_hps_io_sdio_inst_D3      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D3
      hps_hps_io_hps_io_spim1_inst_CLK    : out   std_logic;                                        -- hps_io_spim1_inst_CLK
      hps_hps_io_hps_io_spim1_inst_MOSI   : out   std_logic;                                        -- hps_io_spim1_inst_MOSI
      hps_hps_io_hps_io_spim1_inst_MISO   : in    std_logic                     := 'X';             -- hps_io_spim1_inst_MISO
      hps_hps_io_hps_io_spim1_inst_SS0    : out   std_logic;                                        -- hps_io_spim1_inst_SS0
      hps_hps_io_hps_io_uart0_inst_RX     : in    std_logic                     := 'X';             -- hps_io_uart0_inst_RX
      hps_hps_io_hps_io_uart0_inst_TX     : out   std_logic;                                        -- hps_io_uart0_inst_TX
      hps_hps_io_hps_io_i2c1_inst_SDA     : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SDA
      hps_hps_io_hps_io_i2c1_inst_SCL     : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SCL
      hps_hps_io_hps_io_gpio_inst_GPIO09  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO09
      hps_hps_io_hps_io_gpio_inst_GPIO35  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO35
      hps_hps_io_hps_io_gpio_inst_GPIO40  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO40
      hps_hps_io_hps_io_gpio_inst_GPIO53  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO53
      hps_hps_io_hps_io_gpio_inst_GPIO54  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO54
      hps_hps_io_hps_io_gpio_inst_GPIO61  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO61
      hps_i2c0_out_data                   : out   std_logic;                                        -- out_data
      hps_i2c0_sda                        : in    std_logic                     := 'X';             -- sda
      hps_i2c0_clk_clk                    : out   std_logic;                                        -- clk
      hps_i2c0_scl_in_clk                 : in    std_logic                     := 'X';             -- clk
      hps_spim0_txd                       : out   std_logic;                                        -- txd
      hps_spim0_rxd                       : in    std_logic                     := 'X';             -- rxd
      hps_spim0_ss_in_n                   : in    std_logic                     := 'X';             -- ss_in_n
      hps_spim0_ssi_oe_n                  : out   std_logic;                                        -- ssi_oe_n
      hps_spim0_ss_0_n                    : out   std_logic;                                        -- ss_0_n
      hps_spim0_ss_1_n                    : out   std_logic;                                        -- ss_1_n
      hps_spim0_ss_2_n                    : out   std_logic;                                        -- ss_2_n
      hps_spim0_ss_3_n                    : out   std_logic;                                        -- ss_3_n
      hps_spim0_sclk_out_clk              : out   std_logic;                                        -- clk
      memory_mem_a                        : out   std_logic_vector(14 downto 0);                    -- mem_a
      memory_mem_ba                       : out   std_logic_vector(2 downto 0);                     -- mem_ba
      memory_mem_ck                       : out   std_logic;                                        -- mem_ck
      memory_mem_ck_n                     : out   std_logic;                                        -- mem_ck_n
      memory_mem_cke                      : out   std_logic;                                        -- mem_cke
      memory_mem_cs_n                     : out   std_logic;                                        -- mem_cs_n
      memory_mem_ras_n                    : out   std_logic;                                        -- mem_ras_n
      memory_mem_cas_n                    : out   std_logic;                                        -- mem_cas_n
      memory_mem_we_n                     : out   std_logic;                                        -- mem_we_n
      memory_mem_reset_n                  : out   std_logic;                                        -- mem_reset_n
      memory_mem_dq                       : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
      memory_mem_dqs                      : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs
      memory_mem_dqs_n                    : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_n
      memory_mem_odt                      : out   std_logic;                                        -- mem_odt
      memory_mem_dm                       : out   std_logic_vector(3 downto 0);                     -- mem_dm
      memory_oct_rzqin                    : in    std_logic                     := 'X';             -- oct_rzqin
      reset_reset_n                       : in    std_logic                     := 'X';             -- reset_n
      i2s_output_apb_0_capture_dma_req            : out   std_logic;                                        -- req
      i2s_output_apb_0_capture_dma_ack            : in    std_logic                     := 'X';             -- ack
      i2s_output_apb_0_capture_dma_enable         : out   std_logic;                                        -- enable
      i2s_output_apb_0_capture_fifo_data          : in    std_logic_vector(63 downto 0) := (others => 'X'); -- data
      i2s_output_apb_0_capture_fifo_write         : in    std_logic                     := 'X';             -- write
      i2s_output_apb_0_capture_fifo_full          : out   std_logic;                                        -- full
      i2s_output_apb_0_capture_fifo_clk           : in    std_logic                     := 'X';             -- clk
      i2s_output_apb_0_capture_fifo_empty         : out   std_logic;                                        -- empty
      i2s_output_apb_0_playback_dma_req           : out   std_logic;                                        -- req
      i2s_output_apb_0_playback_dma_ack           : in    std_logic                     := 'X';             -- ack
      i2s_output_apb_0_playback_dma_enable        : out   std_logic;                                        -- enable
      i2s_output_apb_0_playback_fifo_read         : in    std_logic                     := 'X';             -- read
      i2s_output_apb_0_playback_fifo_empty        : out   std_logic;                                        -- empty
      i2s_output_apb_0_playback_fifo_full         : out   std_logic;                                        -- full
      i2s_output_apb_0_playback_fifo_clk          : in    std_logic                     := 'X';             -- clk
      i2s_output_apb_0_playback_fifo_data         : out   std_logic_vector(63 downto 0);                    -- data
      i2s_clkctrl_api_0_ext_bclk                  : in    std_logic                     := 'X';             -- bclk
      i2s_clkctrl_api_0_ext_capture_lrclk         : in    std_logic                     := 'X';             -- capture_lrclk
      i2s_clkctrl_api_0_ext_playback_lrclk        : in    std_logic                     := 'X';             -- playback_lrclk
      i2s_clkctrl_api_0_mclk_clk                  : out   std_logic;                                        -- clk
      i2s_clkctrl_api_0_conduit_playback_lrclk    : out   std_logic;                                        -- playback_lrclk
      i2s_clkctrl_api_0_conduit_clk_sel_48_44     : out   std_logic;                                        -- clk_sel_48_44
      i2s_clkctrl_api_0_conduit_master_slave_mode : out   std_logic;                                        -- master_slave_mode
      i2s_clkctrl_api_0_conduit_bclk              : out   std_logic;                                        -- bclk
      i2s_clkctrl_api_0_conduit_capture_lrclk     : out   std_logic;                                        -- capture_lrclk
      hps_h2f_debug_apb_sideband_pclken           : in    std_logic                     := 'X';             -- pclken
      hps_h2f_debug_apb_sideband_dbg_apb_disable  : in    std_logic                     := 'X';             -- dbg_apb_disable
      hps_h2f_debug_apb_paddr                     : out   std_logic_vector(17 downto 0);                    -- paddr
      hps_h2f_debug_apb_paddr31                   : out   std_logic;                                        -- paddr31
      hps_h2f_debug_apb_penable                   : out   std_logic;                                        -- penable
      hps_h2f_debug_apb_prdata                    : in    std_logic_vector(31 downto 0) := (others => 'X'); -- prdata
      hps_h2f_debug_apb_pready                    : in    std_logic                     := 'X';             -- pready
      hps_h2f_debug_apb_psel                      : out   std_logic;                                        -- psel
      hps_h2f_debug_apb_pslverr                   : in    std_logic                     := 'X';             -- pslverr
      hps_h2f_debug_apb_pwdata                    : out   std_logic_vector(31 downto 0);                    -- pwdata
      hps_h2f_debug_apb_pwrite                    : out   std_logic;                                        -- pwrite
      hps_h2f_debug_apb_reset_reset_n             : out   std_logic;
      clock_bridge_24p546mhz_out_clk_clk  : out   std_logic                                         -- clk
  );
  end component soc_system;
    
  ------------------------------------------------------------
  -- I2S shifting components
  ------------------------------------------------------------
	component i2s_shift_out is 
    port (
      reset_n           :   in  std_logic;
      clk               :   in  std_logic;
      
      fifo_right_data   :   in  std_logic_vector(31 downto 0);
      fifo_left_data    :   in  std_logic_vector(31 downto 0);
      fifo_ready        :   in  std_logic;
      fifo_ack          :   out std_logic;
      
      enable            :   in  std_logic;
      bclk              :   in  std_logic;
      lrclk             :   in  std_logic;
      data_out          :   out std_logic
    );
  end component i2s_shift_out;
	 	
  component i2s_shift_in is
    port (
      reset_n           :   in  std_logic;
      clk               :   in  std_logic;
      
      fifo_right_data   :   out std_logic_vector(31 downto 0);
      fifo_left_data    :   out std_logic_vector(31 downto 0);    
      fifo_ready        :   in  std_logic;
      fifo_write        :   out std_logic;
      
      enable            :   in  std_logic;
      bclk              :   in  std_logic;
      lrclk             :   in  std_logic;
      data_in           :   in  std_logic
  );
  end component i2s_shift_in;
		
	------------------------------------------------------------
	--Tristate buffer with pullup for i2c lines
	------------------------------------------------------------
	component alt_iobuf
    generic(
        io_standard           : string  := "3.3-V LVTTL";
        current_strength      : string  := "maximum current";
        slew_rate             : integer := -1;
        slow_slew_rate        : string  := "NONE";
        location              : string  := "NONE";
        enable_bus_hold       : string  := "NONE";
        weak_pull_up_resistor : string  := "ON";
        termination           : string  := "NONE";
        input_termination     : string  := "NONE";
        output_termination    : string  := "NONE" );
    port(
        i  : in std_logic;
        oe : in std_logic;
        io : inout std_logic;
        o  : out std_logic);
	end component;
	
	
	
	---------------------------------------------------------
	-- Signal declarations
	---------------------------------------------------------
	  	
	signal hps_fpga_reset_n					    : STD_LOGIC;
	signal hps_reset_req						    : STD_LOGIC_VECTOR(2 downto 0);

	signal hps_cold_reset					      : STD_LOGIC;
	signal hps_warm_reset					      : STD_LOGIC;
	signal hps_debug_reset					    : STD_LOGIC;
	signal hps_h2f_reset_n                : STD_LOGIC;

	signal i2c_0_i2c_serial_sda_in		  : STD_LOGIC;
	signal i2c_serial_scl_in				    : STD_LOGIC;
	signal i2c_serial_sda_oe				    : STD_LOGIC;
	signal serial_scl_oe						    : STD_LOGIC;
	
  signal clock_bridge_24p546mhz_out_clk_clk : std_logic;                                 --           clock_bridge_24p546mhz_out_clk.clk
  signal stm_hw_events : std_logic_vector(27 downto 0) := (others => '0');
                                                      --                                      i2s_48clk.clk
  signal i2s_output_apb_0_capture_dma_req            :    std_logic;                                        -- req
  signal i2s_output_apb_0_capture_dma_ack            :     std_logic;             -- ack
  signal i2s_output_apb_0_capture_dma_enable         :    std_logic;                                        -- enable
  signal i2s_output_apb_0_capture_fifo_data          :     std_logic_vector(63 downto 0); -- data
  signal i2s_output_apb_0_capture_fifo_write         :     std_logic;             -- write
  signal i2s_output_apb_0_capture_fifo_full          :    std_logic;                                        -- full
  signal i2s_output_apb_0_capture_fifo_clk           :     std_logic;             -- clk
  signal i2s_output_apb_0_capture_fifo_empty         :    std_logic;                                        -- empty
  signal i2s_output_apb_0_playback_dma_req           :    std_logic;                                        -- req
  signal i2s_output_apb_0_playback_dma_ack           :     std_logic;             -- ack
  signal i2s_output_apb_0_playback_dma_enable        :    std_logic;                                        -- enable
  signal i2s_output_apb_0_playback_fifo_read         :     std_logic;             -- read
  signal i2s_output_apb_0_playback_fifo_empty        :    std_logic;                                        -- empty
  signal i2s_output_apb_0_playback_fifo_full         :    std_logic;                                        -- full
  signal i2s_output_apb_0_playback_fifo_clk          :     std_logic;             -- clk
  signal i2s_output_apb_0_playback_fifo_data         :    std_logic_vector(63 downto 0);                    -- data
  signal i2s_clkctrl_api_0_ext_bclk                  :     std_logic;             -- bclk
  signal i2s_clkctrl_api_0_ext_capture_lrclk         :     std_logic;             -- capture_lrclk
  signal i2s_clkctrl_api_0_ext_playback_lrclk        :     std_logic;             -- playback_lrclk
  signal i2s_clkctrl_api_0_mclk_clk                  :    std_logic;                                        -- clk
  signal i2s_clkctrl_api_0_conduit_playback_lrclk    :    std_logic;                                        -- playback_lrclk
  signal i2s_clkctrl_api_0_conduit_clk_sel_48_44     :    std_logic;                                        -- clk_sel_48_44
  signal i2s_clkctrl_api_0_conduit_master_slave_mode :    std_logic;                                        -- master_slave_mode
  signal i2s_clkctrl_api_0_conduit_bclk              :    std_logic;                                        -- bclk
  signal i2s_clkctrl_api_0_conduit_capture_lrclk     :    std_logic;                                         -- capture_lrclk
  
  
  signal hps_h2f_debug_apb_sideband_pclken_r            :     std_logic;             -- pclken
  signal hps_h2f_debug_apb_sideband_dbg_apb_disable_r   :     std_logic;             -- dbg_apb_disable
  signal hps_h2f_debug_apb_paddr_r                      :    std_logic_vector(17 downto 0);                    -- paddr
  signal hps_h2f_debug_apb_paddr31_r                    :    std_logic;                                        -- paddr31
  signal hps_h2f_debug_apb_penable_r                    :    std_logic;                                        -- penable
  signal hps_h2f_debug_apb_prdata_r                     :     std_logic_vector(31 downto 0); -- prdata
  signal hps_h2f_debug_apb_pready_r                     :     std_logic;             -- pready
  signal hps_h2f_debug_apb_psel_r                       :    std_logic;                                        -- psel
  signal hps_h2f_debug_apb_pslverr_r                    :     std_logic;             -- pslverr
  signal hps_h2f_debug_apb_pwdata_r                     :    std_logic_vector(31 downto 0);                    -- pwdata
  signal hps_h2f_debug_apb_pwrite_r                     :    std_logic;                                         -- pwrite
  signal hps_h2f_debug_apb_reset_reset_n_r              : std_logic;
  
  signal i2s_playback_enable  : std_logic;
  signal i2s_capture_enable   : std_logic;
  
  signal i2s_read_sync        : std_logic_vector(2 downto 0);
  signal i2s_write_sync       : std_logic_vector(2 downto 0);
  
  signal i2s_playback_fifo_ack : std_logic;
  signal i2s_capture_fifo_write : std_logic;
  signal i2s_data_in  : std_logic ;
  signal i2s_data_out : std_logic;
  
  signal hps_f2h_dma_req0_dma_req : std_logic;                                         --                             hps_0_f2h_dma_req0.dma_req
  signal hps_f2h_dma_req0_dma_single : std_logic;                                      --                                               .dma_single
  signal hps_f2h_dma_req0_dma_ack : std_logic;                                         --                                               .dma_ack
  signal hps_f2h_dma_req1_dma_req : std_logic;                                         --                             hps_0_f2h_dma_req1.dma_req
  signal hps_f2h_dma_req1_dma_single : std_logic;                                      --                                               .dma_single
  signal hps_f2h_dma_req1_dma_ack : std_logic;   
    
	signal HPS_spi_ss_n                 : STD_LOGIC;
	signal AD1939_spi_clatch_counter    : std_logic_vector(16 downto 0);  							--! AD1939 SPI signal = ss_n: slave select (active low)

	
	signal system_rst                   : std_logic;							 --! Global reset pin
	signal Push_Button                  : std_logic_vector(1 downto 0);  --! a better description of KEY input, which should really be labelled as KEY_n
  
  signal reset                        : std_logic;
   
       
begin

  ---------------------------------------------------------------------------------------------
	-- Signal Renaming to make code more readable
	---------------------------------------------------------------------------------------------
	Push_Button    <= not KEY;  -- Rename signal to push button, which is a better description of KEY input (which really should be labelled as KEY_n since it is active low).
  reset          <= Push_Button(1);
	hps_cold_reset <= reset;
	
	-------------------------------------------------------
	-- Control Audio Mini LEDs using switches
	-------------------------------------------------------
	Audio_Mini_LEDs <= Audio_Mini_switches;

 	-------------------------------------------------------
	-- AD1939
	-------------------------------------------------------
	AD1939_RST_CODEC_n <= '1'; -- hold AD1939 out of reset
	
 	-------------------------------------------------------
	-- TPA6130
	-------------------------------------------------------
  TPA6130_power_off <= '1';  --! Enable the headphone amplifier output
  
	-------------------------------------------------------
	-- HPS
	-------------------------------------------------------
	hps_debug_reset <= '0';
	hps_warm_reset  <= '0';
	
  ---------------------------------------------------------------------------------------------
	-- SoC System
	---------------------------------------------------------------------------------------------
   u0 : component soc_system
    port map (
      -- clock and data connections to AD1939
      ad1939_abclk_clk                    => AD1939_ADC_ABCLK,
      ad1939_alrclk_clk                   => AD1939_ADC_ALRCLK,
      ad1939_mclk_clk                     => AD1939_MCLK,

      -- HPS DMA
      hps_f2h_dma_req0_dma_req            => hps_f2h_dma_req0_dma_req,                            --        f2h_dma_req0.dma_req
      hps_f2h_dma_req0_dma_single         => hps_f2h_dma_req0_dma_single,                         --                    .dma_single
      hps_f2h_dma_req0_dma_ack            => hps_f2h_dma_req0_dma_ack,                            --                    .dma_ack
      hps_f2h_dma_req1_dma_req            => hps_f2h_dma_req1_dma_req,                            --        f2h_dma_req1.dma_req
      hps_f2h_dma_req1_dma_single         => hps_f2h_dma_req1_dma_single,                         --                    .dma_single
      hps_f2h_dma_req1_dma_ack            => hps_f2h_dma_req1_dma_ack,                            --                    .dma_ack
  
      -- HPS SPI connection to AD1939
      hps_spim0_txd                     => AD1939_spi_CIN,                                                        
      hps_spim0_rxd                     => AD1939_spi_COUT,                                                        
      hps_spim0_ss_in_n                 => '1',                                                 
      hps_spim0_ssi_oe_n                => open,                                                  
      hps_spim0_ss_0_n                  => HPS_spi_ss_n,                                                     
      hps_spim0_ss_1_n                  => open,                                                     
      hps_spim0_ss_2_n                  => open,                                                    
      hps_spim0_ss_3_n                  => open,                                                     
      hps_spim0_sclk_out_clk    				=> AD1939_spi_CCLK,
    
      -- HPS I2C #1 connection to TPA6130
      hps_i2c0_out_data                   => i2c_serial_sda_oe,           
      hps_i2c0_sda                        => i2c_0_i2c_serial_sda_in,       
      hps_i2c0_clk_clk                    => serial_scl_oe,               
      hps_i2c0_scl_in_clk                 => i2c_serial_scl_in,       
    
      -- HPS Clock and Reset
      clk_clk                             => FPGA_CLK1_50,
      reset_reset_n                       => not hps_cold_reset,
      hps_h2f_reset_reset_n               => hps_h2f_reset_n,
    
      -- HPS Ethernet
      hps_hps_io_hps_io_emac1_inst_TX_CLK => HPS_ENET_GTX_CLK,
      hps_hps_io_hps_io_emac1_inst_TXD0   => HPS_ENET_TX_DATA(0),
      hps_hps_io_hps_io_emac1_inst_TXD1   => HPS_ENET_TX_DATA(1),
      hps_hps_io_hps_io_emac1_inst_TXD2   => HPS_ENET_TX_DATA(2), 
      hps_hps_io_hps_io_emac1_inst_TXD3   => HPS_ENET_TX_DATA(3),
      hps_hps_io_hps_io_emac1_inst_RXD0   => HPS_ENET_RX_DATA(0),
      hps_hps_io_hps_io_emac1_inst_MDIO   => HPS_ENET_MDIO,
      hps_hps_io_hps_io_emac1_inst_MDC    => HPS_ENET_MDC,
      hps_hps_io_hps_io_emac1_inst_RX_CTL => HPS_ENET_RX_DV,
      hps_hps_io_hps_io_emac1_inst_TX_CTL => HPS_ENET_TX_EN,
      hps_hps_io_hps_io_emac1_inst_RX_CLK => HPS_ENET_RX_CLK,
      hps_hps_io_hps_io_emac1_inst_RXD1   => HPS_ENET_RX_DATA(1),
      hps_hps_io_hps_io_emac1_inst_RXD2   => HPS_ENET_RX_DATA(2),
      hps_hps_io_hps_io_emac1_inst_RXD3   => HPS_ENET_RX_DATA(3),
    
      -- HPS SD Card
      hps_hps_io_hps_io_sdio_inst_CMD     => HPS_SD_CMD,
      hps_hps_io_hps_io_sdio_inst_D0      => HPS_SD_DATA(0),
      hps_hps_io_hps_io_sdio_inst_D1      => HPS_SD_DATA(1),
      hps_hps_io_hps_io_sdio_inst_CLK     => HPS_SD_CLK,
      hps_hps_io_hps_io_sdio_inst_D2      => HPS_SD_DATA(2),
      hps_hps_io_hps_io_sdio_inst_D3      => HPS_SD_DATA(3),
    
      -- HPS SPI
      hps_hps_io_hps_io_spim1_inst_CLK    => HPS_SPIM_CLK,
      hps_hps_io_hps_io_spim1_inst_MOSI   => HPS_SPIM_MOSI,
      hps_hps_io_hps_io_spim1_inst_MISO   => HPS_SPIM_MISO,
      hps_hps_io_hps_io_spim1_inst_SS0    => HPS_SPIM_SS,
    
      -- HPS UART
      hps_hps_io_hps_io_uart0_inst_RX     => HPS_UART_RX,
      hps_hps_io_hps_io_uart0_inst_TX     => HPS_UART_TX,
    
      -- HPS I2C #2
      hps_hps_io_hps_io_i2c1_inst_SDA     => HPS_I2C1_SDAT,
      hps_hps_io_hps_io_i2c1_inst_SCL     => HPS_I2C1_SCLK,
    
      -- HPS GPIO
      hps_hps_io_hps_io_gpio_inst_GPIO09  => HPS_CONV_USB_N,
      hps_hps_io_hps_io_gpio_inst_GPIO35  => HPS_ENET_INT_N,
      hps_hps_io_hps_io_gpio_inst_GPIO40  => HPS_LTC_GPIO,
      hps_hps_io_hps_io_gpio_inst_GPIO53  => HPS_LED,
      hps_hps_io_hps_io_gpio_inst_GPIO54  => HPS_KEY,
      hps_hps_io_hps_io_gpio_inst_GPIO61  => HPS_GSENSOR_INT,
        
      -- I2S Signals
      i2s_output_apb_0_capture_dma_req            => hps_f2h_dma_req1_dma_single,                 --   i2s_output_apb_0_capture_dma.req
      i2s_output_apb_0_capture_dma_ack            => hps_f2h_dma_req1_dma_ack,                    --                               .ack
      i2s_output_apb_0_capture_dma_enable         => i2s_output_apb_0_capture_dma_enable,         --                               .enable
      i2s_output_apb_0_capture_fifo_data          => i2s_output_apb_0_capture_fifo_data,          --  i2s_output_apb_0_capture_fifo.data
      i2s_output_apb_0_capture_fifo_write         => i2s_output_apb_0_capture_fifo_write,         --                               .write
      i2s_output_apb_0_capture_fifo_full          => i2s_output_apb_0_capture_fifo_full,          --                               .full
      i2s_output_apb_0_capture_fifo_clk           => i2s_output_apb_0_capture_fifo_clk,           --                               .clk
      i2s_output_apb_0_capture_fifo_empty         => i2s_output_apb_0_capture_fifo_empty,         --                               .empty
      
      i2s_output_apb_0_playback_dma_req           => hps_f2h_dma_req0_dma_single,                 --  i2s_output_apb_0_playback_dma.req
      i2s_output_apb_0_playback_dma_ack           => hps_f2h_dma_req0_dma_ack,                    --                               .ack
      i2s_output_apb_0_playback_dma_enable        => i2s_output_apb_0_playback_dma_enable,        --                               .enable
      i2s_output_apb_0_playback_fifo_read         => i2s_output_apb_0_playback_fifo_read,         -- i2s_output_apb_0_playback_fifo.read
      i2s_output_apb_0_playback_fifo_empty        => i2s_output_apb_0_playback_fifo_empty,        --                               .empty
      i2s_output_apb_0_playback_fifo_full         => i2s_output_apb_0_playback_fifo_full,         --                               .full
      i2s_output_apb_0_playback_fifo_clk          => i2s_output_apb_0_playback_fifo_clk,          --                               .clk
      i2s_output_apb_0_playback_fifo_data         => i2s_output_apb_0_playback_fifo_data,         --                               .data
      
      i2s_clkctrl_api_0_ext_bclk                  => i2s_clkctrl_api_0_ext_bclk,                  --          i2s_clkctrl_api_0_ext.bclk
      i2s_clkctrl_api_0_ext_capture_lrclk         => i2s_clkctrl_api_0_ext_capture_lrclk,         --                               .capture_lrclk
      i2s_clkctrl_api_0_ext_playback_lrclk        => i2s_clkctrl_api_0_ext_playback_lrclk,        --                               .playback_lrclk
      i2s_clkctrl_api_0_mclk_clk                  => i2s_clkctrl_api_0_mclk_clk,                  --         i2s_clkctrl_api_0_mclk.clk
      i2s_clkctrl_api_0_conduit_playback_lrclk    => i2s_clkctrl_api_0_conduit_playback_lrclk,    --      i2s_clkctrl_api_0_conduit.playback_lrclk
      i2s_clkctrl_api_0_conduit_clk_sel_48_44     => i2s_clkctrl_api_0_conduit_clk_sel_48_44,     --                               .clk_sel_48_44
      i2s_clkctrl_api_0_conduit_master_slave_mode => i2s_clkctrl_api_0_conduit_master_slave_mode, --                               .master_slave_mode
      i2s_clkctrl_api_0_conduit_bclk              => i2s_clkctrl_api_0_conduit_bclk,              --                               .bclk
      i2s_clkctrl_api_0_conduit_capture_lrclk     => i2s_clkctrl_api_0_conduit_capture_lrclk,     --                               .capture_lrclk
    
      -- HPS DDR3 DRAM
      memory_mem_a                        => HPS_DDR3_ADDR,
      memory_mem_ba                       => HPS_DDR3_BA,
      memory_mem_ck                       => HPS_DDR3_CK_P,
      memory_mem_ck_n                     => HPS_DDR3_CK_N,
      memory_mem_cke                      => HPS_DDR3_CKE,
      memory_mem_cs_n                     => HPS_DDR3_CS_N,
      memory_mem_ras_n                    => HPS_DDR3_RAS_N,
      memory_mem_cas_n                    => HPS_DDR3_CAS_N,
      memory_mem_we_n                     => HPS_DDR3_WE_N,
      memory_mem_reset_n                  => HPS_DDR3_RESET_N,
      memory_mem_dq                       => HPS_DDR3_DQ,
      memory_mem_dqs                      => HPS_DDR3_DQS_P,
      memory_mem_dqs_n                    => HPS_DDR3_DQS_N,
      memory_mem_odt                      => HPS_DDR3_ODT,
      memory_mem_dm                       => HPS_DDR3_DM,
      memory_oct_rzqin                    => HPS_DDR3_RZQ,

      -- DMA debug signals
      hps_h2f_debug_apb_sideband_pclken           => hps_h2f_debug_apb_sideband_pclken_r,           --     hps_h2f_debug_apb_sideband.pclken
      hps_h2f_debug_apb_sideband_dbg_apb_disable  => hps_h2f_debug_apb_sideband_dbg_apb_disable_r,  --                               .dbg_apb_disable
      hps_h2f_debug_apb_paddr                     => hps_h2f_debug_apb_paddr_r,                     --              hps_h2f_debug_apb.paddr
      hps_h2f_debug_apb_paddr31                   => hps_h2f_debug_apb_paddr31_r,                   --                               .paddr31
      hps_h2f_debug_apb_penable                   => hps_h2f_debug_apb_penable_r,                   --                               .penable
      hps_h2f_debug_apb_prdata                    => hps_h2f_debug_apb_prdata_r,                    --                               .prdata
      hps_h2f_debug_apb_pready                    => hps_h2f_debug_apb_pready_r,                    --                               .pready
      hps_h2f_debug_apb_psel                      => hps_h2f_debug_apb_psel_r,                      --                               .psel
      hps_h2f_debug_apb_pslverr                   => hps_h2f_debug_apb_pslverr_r,                   --                               .pslverr
      hps_h2f_debug_apb_pwdata                    => hps_h2f_debug_apb_pwdata_r,                    --                               .pwdata
      hps_h2f_debug_apb_pwrite                    => hps_h2f_debug_apb_pwrite_r,                     --                               .pwrite
      hps_h2f_debug_apb_reset_reset_n             => hps_h2f_debug_apb_reset_reset_n_r,
      -- Clock bridges
      clock_bridge_24p546mhz_out_clk_clk  => clock_bridge_24p546mhz_out_clk_clk           --  clock_bridge_0_out_clk.clk
    );
  ------------------------------------------------------------
  -- Digital and Analog Clock Mapping
  ------------------------------------------------------------
  AD1939_DAC_DBCLK  <= AD1939_ADC_ABCLK;
  AD1939_DAC_DLRCLK <= AD1939_ADC_ALRCLK;
  
  ------------------------------------------------------------
  -- I2S shifting components
  ------------------------------------------------------------
	i2s_out : component i2s_shift_out
    port map (
      reset_n           => hps_h2f_reset_n,
      clk               => clock_bridge_24p546mhz_out_clk_clk,
      
      fifo_right_data   => i2s_output_apb_0_playback_fifo_data(63 downto 32),
      fifo_left_data    => i2s_output_apb_0_playback_fifo_data(31 downto 0),
      fifo_ready        => not i2s_output_apb_0_playback_fifo_empty,
      fifo_ack          => i2s_playback_fifo_ack,
      
      enable            => i2s_playback_enable,
      bclk              => i2s_clkctrl_api_0_ext_bclk,
      lrclk             => i2s_clkctrl_api_0_ext_playback_lrclk,
      data_out          => AD1939_DAC_DSDATA1
    );
	 	
  i2s_in : component i2s_shift_in
    port map(
      reset_n           => hps_h2f_reset_n,
      clk               => clock_bridge_24p546mhz_out_clk_clk,
      
      fifo_right_data   => i2s_output_apb_0_capture_fifo_data(63 downto 32),
      fifo_left_data    => i2s_output_apb_0_capture_fifo_data(31 downto 0), 
      fifo_ready        => not i2s_output_apb_0_capture_fifo_full,
      fifo_write        => i2s_capture_fifo_write,

      enable            => i2s_capture_enable,
      bclk              => i2s_clkctrl_api_0_ext_bclk,
      lrclk             => i2s_clkctrl_api_0_ext_capture_lrclk,
      data_in           => AD1939_ADC_ASDATA2
    );	
				
				
        
        
  ------------------------------------------------------------
  -- I2S logic
  ------------------------------------------------------------			
  -- Capture and playback enables
	i2s_playback_enable <= i2s_output_apb_0_playback_dma_enable and not i2s_output_apb_0_playback_fifo_empty;
  i2s_capture_enable  <= i2s_output_apb_0_capture_dma_enable  and not i2s_output_apb_0_capture_fifo_full;
  
  -- Read sync
  read_sync : process(FPGA_CLK1_50,hps_h2f_reset_n)
  begin 
    if rising_edge(FPGA_CLK1_50) then
      if hps_h2f_reset_n = '0' then 
        i2s_read_sync <= (others => '0');
      else 
        i2s_read_sync <= i2s_read_sync(1 downto 0) & i2s_playback_fifo_ack;
      end if;
    end if;
  end process;
  i2s_output_apb_0_playback_fifo_read <= i2s_read_sync(2) and not i2s_read_sync(1);
  i2s_output_apb_0_playback_fifo_clk <= FPGA_CLK1_50;
  
  -- Write sync
  write_sync : process(FPGA_CLK1_50,hps_h2f_reset_n)
  begin 
    if rising_edge(FPGA_CLK1_50) then
      if hps_h2f_reset_n = '0' then 
        i2s_write_sync <= (others => '0');
      else 
        i2s_write_sync <= i2s_write_sync(1 downto 0) & i2s_capture_fifo_write;
      end if;
    end if;
  end process;
  i2s_output_apb_0_capture_fifo_write <= i2s_write_sync(2) and not i2s_write_sync(1);
  i2s_output_apb_0_capture_fifo_clk <= FPGA_CLK1_50;
  
  -- Clock master/slave assignments
  assign_clk : process(FPGA_CLK1_50,hps_h2f_reset_n)
  begin 
    if rising_edge(FPGA_CLK1_50) then
      if i2s_clkctrl_api_0_conduit_master_slave_mode = '0' then 
        i2s_clkctrl_api_0_ext_bclk <= AD1939_ADC_ABCLK;
        i2s_clkctrl_api_0_ext_capture_lrclk <= AD1939_ADC_ALRCLK;
        i2s_clkctrl_api_0_ext_playback_lrclk <= AD1939_ADC_ALRCLK;
      else
        -- i2s_clkctrl_api_0_ext_bclk <= AD1939_ADC_ABCLK;
        -- i2s_clkctrl_api_0_ext_capture_lrclk <= AD1939_ADC_ALRCLK;
        -- i2s_clkctrl_api_0_ext_playback_lrclk <= AD1939_ADC_ALRCLK;
        i2s_clkctrl_api_0_ext_bclk <= i2s_clkctrl_api_0_conduit_bclk;
        i2s_clkctrl_api_0_ext_capture_lrclk <= i2s_clkctrl_api_0_conduit_capture_lrclk;
        i2s_clkctrl_api_0_ext_playback_lrclk <= i2s_clkctrl_api_0_conduit_playback_lrclk;
      end if;
    end if;
  end process;
    
  
  ---------------------------------------------------------------------------------------------
	-- Extend the SPI slave select hold time 
	---------------------------------------------------------------------------------------------
		holdSpiLatch : process (FPGA_CLK1_50)
		begin
			if rising_edge(FPGA_CLK1_50) then
				if HPS_spi_ss_n = '0' then
					AD1939_spi_clatch_counter   <= (others=>'0');                  -- reset counter
					AD1939_spi_CLATCH_n         <= '0';
				elsif AD1939_spi_clatch_counter < x"00000040" then
					AD1939_spi_clatch_counter   <= AD1939_spi_clatch_counter + 1;  -- increment counter
					AD1939_spi_CLATCH_n         <= '0';                            -- hold low until counter reaches threshold
				else
					AD1939_spi_CLATCH_n         <= '1';                            -- release clatch
				end if;
			end if;
		end process;
		
		
   ---------------------------------------------------------------------------------------------
	-- Tri-state buffer the I2C signals
	---------------------------------------------------------------------------------------------
	ubuf1 : component alt_iobuf
    port map(
        i   => '0',
        oe  => i2c_serial_sda_oe,
        io  => TPA6130_i2c_SDA,
        o   => i2c_0_i2c_serial_sda_in
    );
	
	ubuf2 : component alt_iobuf
    port map(
        i   => '0',
        oe  => serial_scl_oe,
        io  => TPA6130_i2c_SCL,
        o   => i2c_serial_scl_in
    );	
	
	
	
 	-------------------------------------------------------
	-- DE10-Nano Board (unused signals output signals)
	-------------------------------------------------------
	LED               <= (others => '0');
	Audio_Mini_GPIO_0 <= (others => 'Z');
	Audio_Mini_GPIO_1 <= (others => 'Z');
	ARDUINO_IO		    <= (others => 'Z');
  ARDUINO_RESET_N   <= 'Z';
	ADC_CONVST	      <= '0'; 				
  ADC_SCK			      <= '0';			
	ADC_SDI			      <= '0';		
end architecture DE10Nano_arch;
