--! @file
--! 
--! @author Raymond Weber
--! @author Ross Snider


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

LIBRARY altera;
USE altera.altera_primitives_components.all;


entity DE10_Top_Level is
	port(
		----------------------------------------
		--  CLOCK Inputs
		----------------------------------------
		FPGA_CLK1_50  :  in std_logic;										--! The DE0-Nano SOC had 3x 50MHz clock input pins
		FPGA_CLK2_50  :  in std_logic;										--! The DE0-Nano SOC had 3x 50MHz clock input pins
		FPGA_CLK3_50  :  in std_logic;										--! The DE0-Nano SOC had 3x 50MHz clock input pins

    -- HDMI 
    HDMI_I2C_SCL : out std_logic;
    HDMI_I2C_SDA : inout std_logic;
    HDMI_I2S : out std_logic;
    HDMI_LRCLK : out std_logic;
    HDMI_MCLK : out std_logic;
    HDMI_SCLK : out std_logic;
    HDMI_TX_CLK : out std_logic;
    HDMI_TX_D : out std_logic_vector(23 downto 0); 
    HDMI_TX_DE : out std_logic;
    HDMI_TX_HS : out std_logic;
    HDMI_TX_INT : in std_logic;
    HDMI_TX_VS : out std_logic;

		----------------------------------------
		--  Push Button Inputs (KEY) - 2 inputs
		--  The KEY inputs produce a '0' when pressed (asserted)
		--  and produce a '1' in the rest state
		--  a better label for KEY would be Push_Button_n 
		----------------------------------------
		KEY : in std_logic_vector(1 downto 0);								--! Pushbuttons on the DE0-Nano SOC
		----------------------------------------
		--  Switch Inputs (SW) - 4 inputs
		----------------------------------------
		SW  : in std_logic_vector(3 downto 0);								--! DIP Switches on the DE0-Nano SOC
		----------------------------------------
		--  LED Outputs - 8 outputs
		----------------------------------------
		LED : out std_logic_vector(7 downto 0);							--! LEDs on the DE0-Nano SOC
		
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


--  ///////// ADC /////////
    ADC_CONVST					: out STD_LOGIC;
		ADC_SCK						: out STD_LOGIC;
		ADC_SDI						: out STD_LOGIC;
		ADC_SDO						: in STD_LOGIC;
		
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

--`ifdef ENABLE_HPS
--      ///////// HPS /////////
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
      HPS_UART_TX					: out STD_LOGIC;
      HPS_USB_CLKOUT				: in STD_LOGIC;
      HPS_USB_DATA				: inout STD_LOGIC_VECTOR(7 downto 0);
      HPS_USB_DIR					: in STD_LOGIC;
      HPS_USB_NXT					: in STD_LOGIC;
      HPS_USB_STP					: out STD_LOGIC
--`endif /*ENABLE_HPS*/		
			
	
	-- Ported from ghrd.v
	--fpga_clk_50 <= FPGA_CLK1_50;
	--assign stm_hw_events    = {{15{1'b0}}, SW, {8{1'b0}}, fpga_debounced_buttons};			
	);
end entity DE10_Top_Level;


architecture DE10_arch of DE10_Top_Level is



	signal hps_fpga_reset_n					: STD_LOGIC;
	signal fpga_debounced_buttons			: STD_LOGIC_VECTOR(3 downto 0);
	signal hps_reset_req						: STD_LOGIC_VECTOR(2 downto 0);
	signal hps_cold_reset					: STD_LOGIC;
	signal hps_warm_reset					: STD_LOGIC;
	signal hps_debug_reset					: STD_LOGIC;
	signal stm_hw_events						: STD_LOGIC_VECTOR(27 downto 0);
	signal fpga_clk_50					 	: STD_LOGIC;

	signal i2c_0_i2c_serial_sda_in		: STD_LOGIC;
	signal i2c_serial_scl_in				: STD_LOGIC;
	signal i2c_serial_sda_oe				: STD_LOGIC;
	signal serial_scl_oe						: STD_LOGIC;
	--signal LED 									: std_logic_vector(7 downto 0);

	signal HPS_spi_ss_n                 : STD_LOGIC;
	signal AD1939_spi_clatch_counter    : std_logic_vector(16 downto 0);  							--! AD1939 SPI signal = ss_n: slave select (active low)

	
	
	COMPONENT debounce is
		GENERIC ( WIDTH : INTEGER := 2; POLARITY : STRING := "LOW"; TIMEOUT : INTEGER := 50000; TIMEOUT_WIDTH : INTEGER := 16 );
		PORT
		(
			clk			:	 IN STD_LOGIC;
			reset_n		:	 IN STD_LOGIC;
			data_in		:	 IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
			data_out		:	 OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)
		);
	END COMPONENT;
	
--	COMPONENT hps_reset is
--		PORT
--		(
--			source_clk	: IN STD_LOGIC;
--			source	 	: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
--		);
--	END COMPONENT;
	
	COMPONENT altera_edge_detector
	GENERIC ( PULSE_EXT : INTEGER := 6; EDGE_TYPE : INTEGER := 1; IGNORE_RST_WHILE_BUSY : INTEGER := 1 );
	PORT
	(
		clk		:	 IN STD_LOGIC;
		rst_n		:	 IN STD_LOGIC;
		signal_in		:	 IN STD_LOGIC;
		pulse_out		:	 OUT STD_LOGIC
	);
	END COMPONENT;
	
	
	component OnePulse is
		port(
			clk      	    			: in  std_logic;  
			reset                   : in  std_logic;
			push_button	            : in  std_logic;  -- push button to generate pulse
			single_pulse            : out std_logic   -- pulse of 1 clock cycle sent out when push button is pressed
			);
	end component;		


  component soc_system is
        port (
            ad1939_mclk_clk                           : in    std_logic                     := 'X';             -- clk
            spi_clk_clk                               : out   std_logic                     := 'X';             -- clk
            ad1939_abclk_clk                          : in    std_logic                     := 'X';             -- clk
            ad1939_alrclk_clk                         : in    std_logic                     := 'X';             -- clk
            ad1939_physical_asdata2                   : in    std_logic                     := 'X';             -- asdata2
            ad1939_physical_dbclk                     : out   std_logic;                                        -- dbclk
            ad1939_physical_dlrclk                    : out   std_logic;                                        -- dlrclk
            ad1939_physical_dsdata1                   : out   std_logic;                                         -- dsdata1
            clk_clk                                                                : in    std_logic                     := 'X';             -- clk
            hps_0_f2h_cold_reset_req_reset_n                                       : in    std_logic                     := 'X';             -- reset_n
            hps_0_f2h_debug_reset_req_reset_n                                      : in    std_logic                     := 'X';             -- reset_n
            hps_0_f2h_stm_hw_events_stm_hwevents                                   : in    std_logic_vector(27 downto 0) := (others => 'X'); -- stm_hwevents
            hps_0_f2h_warm_reset_req_reset_n                                       : in    std_logic                     := 'X';             -- reset_n
            hps_0_h2f_reset_reset_n                                                : out   std_logic;                                        -- reset_n
            hps_0_hps_io_hps_io_emac1_inst_TX_CLK                                  : out   std_logic;                                        -- hps_io_emac1_inst_TX_CLK
            hps_0_hps_io_hps_io_emac1_inst_TXD0                                    : out   std_logic;                                        -- hps_io_emac1_inst_TXD0
            hps_0_hps_io_hps_io_emac1_inst_TXD1                                    : out   std_logic;                                        -- hps_io_emac1_inst_TXD1
            hps_0_hps_io_hps_io_emac1_inst_TXD2                                    : out   std_logic;                                        -- hps_io_emac1_inst_TXD2
            hps_0_hps_io_hps_io_emac1_inst_TXD3                                    : out   std_logic;                                        -- hps_io_emac1_inst_TXD3
            hps_0_hps_io_hps_io_emac1_inst_RXD0                                    : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD0
            hps_0_hps_io_hps_io_emac1_inst_MDIO                                    : inout std_logic                     := 'X';             -- hps_io_emac1_inst_MDIO
            hps_0_hps_io_hps_io_emac1_inst_MDC                                     : out   std_logic;                                        -- hps_io_emac1_inst_MDC
            hps_0_hps_io_hps_io_emac1_inst_RX_CTL                                  : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CTL
            hps_0_hps_io_hps_io_emac1_inst_TX_CTL                                  : out   std_logic;                                        -- hps_io_emac1_inst_TX_CTL
            hps_0_hps_io_hps_io_emac1_inst_RX_CLK                                  : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CLK
            hps_0_hps_io_hps_io_emac1_inst_RXD1                                    : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD1
            hps_0_hps_io_hps_io_emac1_inst_RXD2                                    : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD2
            hps_0_hps_io_hps_io_emac1_inst_RXD3                                    : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD3
            hps_0_hps_io_hps_io_sdio_inst_CMD                                      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_CMD
            hps_0_hps_io_hps_io_sdio_inst_D0                                       : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D0
            hps_0_hps_io_hps_io_sdio_inst_D1                                       : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D1
            hps_0_hps_io_hps_io_sdio_inst_CLK                                      : out   std_logic;                                        -- hps_io_sdio_inst_CLK
            hps_0_hps_io_hps_io_sdio_inst_D2                                       : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D2
            hps_0_hps_io_hps_io_sdio_inst_D3                                       : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D3
            hps_0_hps_io_hps_io_usb1_inst_D0                                       : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D0
            hps_0_hps_io_hps_io_usb1_inst_D1                                       : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D1
            hps_0_hps_io_hps_io_usb1_inst_D2                                       : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D2
            hps_0_hps_io_hps_io_usb1_inst_D3                                       : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D3
            hps_0_hps_io_hps_io_usb1_inst_D4                                       : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D4
            hps_0_hps_io_hps_io_usb1_inst_D5                                       : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D5
            hps_0_hps_io_hps_io_usb1_inst_D6                                       : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D6
            hps_0_hps_io_hps_io_usb1_inst_D7                                       : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D7
            hps_0_hps_io_hps_io_usb1_inst_CLK                                      : in    std_logic                     := 'X';             -- hps_io_usb1_inst_CLK
            hps_0_hps_io_hps_io_usb1_inst_STP                                      : out   std_logic;                                        -- hps_io_usb1_inst_STP
            hps_0_hps_io_hps_io_usb1_inst_DIR                                      : in    std_logic                     := 'X';             -- hps_io_usb1_inst_DIR
            hps_0_hps_io_hps_io_usb1_inst_NXT                                      : in    std_logic                     := 'X';             -- hps_io_usb1_inst_NXT
            hps_0_hps_io_hps_io_spim1_inst_CLK                                     : out   std_logic;                                        -- hps_io_spim1_inst_CLK
            hps_0_hps_io_hps_io_spim1_inst_MOSI                                    : out   std_logic;                                        -- hps_io_spim1_inst_MOSI
            hps_0_hps_io_hps_io_spim1_inst_MISO                                    : in    std_logic                     := 'X';             -- hps_io_spim1_inst_MISO
            hps_0_hps_io_hps_io_spim1_inst_SS0                                     : out   std_logic;                                        -- hps_io_spim1_inst_SS0
            hps_0_hps_io_hps_io_uart0_inst_RX                                      : in    std_logic                     := 'X';             -- hps_io_uart0_inst_RX
            hps_0_hps_io_hps_io_uart0_inst_TX                                      : out   std_logic;                                        -- hps_io_uart0_inst_TX
            hps_0_hps_io_hps_io_i2c0_inst_SDA                                      : inout std_logic                     := 'X';             -- hps_io_i2c0_inst_SDA
            hps_0_hps_io_hps_io_i2c0_inst_SCL                                      : inout std_logic                     := 'X';             -- hps_io_i2c0_inst_SCL
            hps_0_hps_io_hps_io_i2c1_inst_SDA                                      : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SDA
            hps_0_hps_io_hps_io_i2c1_inst_SCL                                      : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SCL
            hps_0_hps_io_hps_io_gpio_inst_GPIO09                                   : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO09
            hps_0_hps_io_hps_io_gpio_inst_GPIO35                                   : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO35
            hps_0_hps_io_hps_io_gpio_inst_GPIO40                                   : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO40
            hps_0_hps_io_hps_io_gpio_inst_GPIO53                                   : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO53
            hps_0_hps_io_hps_io_gpio_inst_GPIO54                                   : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO54
            hps_0_hps_io_hps_io_gpio_inst_GPIO61                                   : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO61
            memory_mem_a                                                           : out   std_logic_vector(14 downto 0);                    -- mem_a
            memory_mem_ba                                                          : out   std_logic_vector(2 downto 0);                     -- mem_ba
            memory_mem_ck                                                          : out   std_logic;                                        -- mem_ck
            memory_mem_ck_n                                                        : out   std_logic;                                        -- mem_ck_n
            memory_mem_cke                                                         : out   std_logic;                                        -- mem_cke
            memory_mem_cs_n                                                        : out   std_logic;                                        -- mem_cs_n
            memory_mem_ras_n                                                       : out   std_logic;                                        -- mem_ras_n
            memory_mem_cas_n                                                       : out   std_logic;                                        -- mem_cas_n
            memory_mem_we_n                                                        : out   std_logic;                                        -- mem_we_n
            memory_mem_reset_n                                                     : out   std_logic;                                        -- mem_reset_n
            memory_mem_dq                                                          : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
            memory_mem_dqs                                                         : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs
            memory_mem_dqs_n                                                       : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_n
            memory_mem_odt                                                         : out   std_logic;                                        -- mem_odt
            memory_mem_dm                                                          : out   std_logic_vector(3 downto 0);                     -- mem_dm
            memory_oct_rzqin                                                       : in    std_logic                     := 'X';             -- oct_rzqin
            reset_reset_n                                                          : in    std_logic                     := 'X';             -- reset_n
            --spi_0_external_MISO                                                    : in    std_logic                     := 'X';             -- MISO
            --spi_0_external_MOSI                                                    : out   std_logic;                                        -- MOSI
            --spi_0_external_SCLK                                                    : out   std_logic;                                        -- SCLK
            --spi_0_external_SS_n                                                    : out   std_logic;                                        -- SS_n
            --spi_0_spi_control_port_writedata                                       : in    std_logic_vector(15 downto 0) := (others => 'X'); -- writedata
            --spi_0_spi_control_port_readdata                                        : out   std_logic_vector(15 downto 0);                    -- readdata
            --spi_0_spi_control_port_address                                         : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- address
            --spi_0_spi_control_port_read_n                                          : in    std_logic                     := 'X';             -- read_n
            --spi_0_spi_control_port_chipselect                                      : in    std_logic                     := 'X';             -- chipselect
            --spi_0_spi_control_port_write_n                                         : in    std_logic                     := 'X';              -- write_n



        --Brought in from DE10 Terasic QT Demo

        alt_vip_itc_0_clocked_video_vid_clk                                     : in    std_logic                     := 'X';             -- vid_clk
        alt_vip_itc_0_clocked_video_vid_data                                    : out   std_logic_vector(31 downto 0);                    -- vid_data
        alt_vip_itc_0_clocked_video_underflow                                   : out   std_logic;                                        -- underflow
        alt_vip_itc_0_clocked_video_vid_datavalid                               : out   std_logic;                                        -- vid_datavalid
        alt_vip_itc_0_clocked_video_vid_v_sync                                  : out   std_logic;                                        -- vid_v_sync
        alt_vip_itc_0_clocked_video_vid_h_sync                                  : out   std_logic;                                        -- vid_h_sync
        alt_vip_itc_0_clocked_video_vid_f                                       : out   std_logic;                                        -- vid_f
        alt_vip_itc_0_clocked_video_vid_h                                       : out   std_logic;                                        -- vid_h
        alt_vip_itc_0_clocked_video_vid_v                                       : out   std_logic;                                        -- vid_v
        button_pio_external_connection_export                                   : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- export
        
        clk_130_clk                                                             : in    std_logic                     := 'X';             -- clk
        dipsw_pio_external_connection_export                                    : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- export
        led_pio_external_connection_export                                      : out   std_logic_vector(7 downto 0);                     -- export

        -- On chip memory breakout
        codec_clk_clk                             : out   std_logic;                                        -- clk
        onchip_memory2_0_s2_address               : in    std_logic_vector(15 downto 0) := (others => 'X'); -- address
        onchip_memory2_0_s2_chipselect            : in    std_logic                     := 'X';             -- chipselect
        onchip_memory2_0_s2_clken                 : in    std_logic                     := 'X';             -- clken
        onchip_memory2_0_s2_write                 : in    std_logic                     := 'X';             -- write
        onchip_memory2_0_s2_readdata              : out   std_logic_vector(31 downto 0);                    -- readdata
        onchip_memory2_0_s2_writedata             : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
        onchip_memory2_0_s2_byteenable            : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
        onchip_memory2_0_clk2_clk                 : in    std_logic                     := 'X';             -- clk
        onchip_memory2_0_reset2_reset             : in    std_logic                     := 'X';             -- reset
        --onchip_memory2_0_reset2_reset_req         : in    std_logic                     := 'X';              -- reset_req
        
        -- Line in data breakout
        line_in_data_channel                      : out   std_logic_vector(1 downto 0);                     -- channel
        line_in_data_data                         : out   std_logic_vector(31 downto 0);                    -- data
        line_in_data_error                        : out   std_logic_vector(1 downto 0);                     -- error
        line_in_data_valid                        : out   std_logic                                         -- valid
    );
    end component soc_system;




component I2C_HDMI_Config is port(      
--   Host Side
                  iCLK: in std_logic;
                   iRST_N: in std_logic;
--   I2C Side
                  I2C_SCLK: out std_logic;
                   I2C_SDAT: inout std_logic;
                  HDMI_TX_INT: in std_logic;
 READY : out std_logic
 );
end component I2C_HDMI_Config;
component vga_pll is port (
              refclk: in std_logic;
              rst: in std_logic;
              outclk_0: out std_logic;
              outclk_1: out std_logic;
              locked : out std_logic
      );
end component vga_pll;



	---------------------------------------------------------
	-- Signal declarations
	---------------------------------------------------------
	signal CLK_100    : std_logic;							 --! 100Mhz clock from the PLL
	signal CLK_50     : std_logic;							 --! 50Mhz clock from the PLL
	signal CLK_10     : std_logic;							 --! 10Mhz clock from the PLL
	signal CLK_5      : std_logic;							 --! 5Mhz clock from the PLL
	signal system_rst : std_logic;							 --! Global reset pin
	signal single_pulse : std_logic;
	signal Push_Button : std_logic_vector(1 downto 0);  --! a better description of KEY input, which should really be labelled as KEY_n

	signal   AD1939_spi_CLATCH_n_sig 			  : std_logic;  							--! AD1939 SPI signal = ss_n: slave select (active low)
	signal   clatch_counter 			     :std_logic_vector(16 downto 0);  							--! AD1939 SPI signal = ss_n: slave select (active low)
	
  signal   AD1939_HDR1_MCLK           : std_logic;   
	
	signal   switches     : std_logic_vector(3 downto 0);
  
  signal FRAME_LENGTH : integer := 1024;
  signal address_counter : integer := 0;
  signal byte_counter : unsigned(7 downto 0) := (others => '0');
  signal word_counter : unsigned(31 downto 0) := (others => '0');
  signal byte_mask    : std_logic_vector(4 downto 0) := "10000";
  signal codec_clk : std_logic;
  signal data_valid : std_logic;
  signal write_data : std_logic;
  -----------------------------------------------------------------------------------------------------
  -- SPI related signals
  -----------------------------------------------------------------------------------------------------
  signal   AD1939_spi_command       	  : std_logic_vector(7 downto 0);  
  constant AD1939_spi_command_read  	  : std_logic_vector(7 downto 0) := "00001001";  -- Insee page 24 of AD1939 data sheet   Note: AD1939_spi_command <= AD1939_spi_command_read or AD1939_spi_command_write
  constant AD1939_spi_command_write 	  : std_logic_vector(7 downto 0) := "00001000";  -- see page 24 of AD1939 data sheet
  signal   AD1939_spi_register_address  : std_logic_vector(7 downto 0);  
  signal   AD1939_spi_write_data        : std_logic_vector(7 downto 0);   -- data to be written to AD1939 register
  signal   AD1939_spi_write_data_rdy    : std_logic;                      -- assert (clock pulse) to write data
  signal   AD1939_spi_busy          	  : std_logic;                      -- If 1, the spi is busy servicing a command. Wait until 0 to send another command. 
  signal   AD1939_spi_done          	  : std_logic;                      
  signal   AD1939_spi_read_data         : std_logic_vector(7 downto 0);   -- data read from AD1939 register
  signal   AD1939_spi_read_data_ack  	  : std_logic;                      -- data ready to be read
	signal   AD1939_SPI_CLK               : std_logic;
  signal   REG_SETTINGS                 : std_logic_vector(79 downto 0) := x"0100008010C802000E00";
  
  
  -- Signals for the line in port of the AD1939
  signal line_in_data_channel : std_logic_vector(1 downto 0);
  signal line_in_data_data    : std_logic_vector(31 downto 0);
  signal line_in_data_error   : std_logic_vector(1 downto 0);
  signal line_in_data_valid   : std_logic;  
  
  signal line_in_data_channel_r : std_logic_vector(1 downto 0);
  signal line_in_data_data_r    : std_logic_vector(31 downto 0);
  signal line_in_data_error_r   : std_logic_vector(1 downto 0);
  signal line_in_data_valid_r   : std_logic;
  
  signal reg_counter   		: std_logic_vector (4 downto 0);
  signal reg_counter_enable 	: std_logic;
  signal reg_counter_clear 	: std_logic;
  signal reg_prog_start 		: std_logic;
  signal reg_prog_done 		: std_logic;
  signal reg_load  				: std_logic_vector (1 downto 0);
  signal reg_addr 		      : std_logic_vector (4 downto 0);
  signal reg_data 		      : std_logic_vector (7 downto 0);
  signal ROM_addr            : std_logic_vector (4 downto 0);
  signal ROM_data 		      : std_logic_vector (7 downto 0);
  
  signal init_counter       : integer := 0;
    
	--Tristate buffer with pullup for i2c lines
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
	
	
	constant zeros24        : std_logic_vector(23 downto 0) := "000000000000000000000000";	
   
    signal reset            : std_logic;
	signal SPI_clk          : std_logic;
	signal AD1939_state     : std_logic_vector(3 downto 0);                                    
       


  signal               clk_65:   std_logic; 
  signal               clk_130:   std_logic; 

  signal alt_vip_itc_0_clocked_video_vid_data_reg  : std_logic_vector(31 downto 0);


component spi_commands is
	  generic(
	
	  command_used_g          : std_logic 	:= '1';
	  address_used_g          : std_logic 	:= '1';
	  command_width_bits_g   : natural 	:= 1;
	  address_width_bits_g   : natural 	:= 1;
	  data_width_bits_g : natural 	:= 8;
	  output_bits_g           : natural   := 24;
	  cpol_cpha               : std_logic_vector(1 downto 0) := "00"
	  );
		port(
			clk	           :in	std_logic;	
			rst_n 	        :in	std_logic;
			
			command_in      : in  std_logic_vector(command_width_bits_g*8-1 downto 0);
			address_in      : in  std_logic_vector(address_width_bits_g*8-1 downto 0);
			address_en_in   : in  std_logic;
			data_length_in  : in  std_logic_vector(data_width_bits_g - 1 downto 0);
			
			master_slave_data_in      :in   std_logic_vector(data_width_bits_g-1 downto 0);
			master_slave_data_rdy_in  :in   std_logic;
			master_slave_data_ack_out :out  std_logic;
			command_busy_out          :out  std_logic;
			command_done              :out  std_logic;
	
			slave_master_data_out     : out std_logic_vector(output_bits_g-1 downto 0);
			slave_master_data_ack_out : out std_logic;
	
			miso 				:in	std_logic;	
			mosi 				:out  std_logic;	
			sclk 				:out  std_logic;	
			cs_n 				:out  std_logic 
		);
	end component;

  type state_type is (
    spi_init_load,
    spi_write_init_busy,
    spi_write_init_start,
    spi_done
  );
  
  signal state : state_type;

  
begin



	Push_Button <= not KEY;  -- push button : a better description of KEY input, which should really be labelled as KEY_n

   reset <= not KEY(1);
   
   
 	-------------------------------------------------------
	-- AD1939
	-------------------------------------------------------
	AD1939_RST_CODEC_n <= '1'; -- hold AD1939 out of reset
	
 	-------------------------------------------------------
	-- TPA6130
	-------------------------------------------------------
  TPA6130_power_off <= '1';  --! Enable the headphone amplifier output
 
	
    u0 : component soc_system
        port map (
            -- clock and data connections to AD1939
            ad1939_abclk_clk                    => AD1939_ADC_ABCLK,
            ad1939_alrclk_clk                   => AD1939_ADC_ALRCLK,
            ad1939_mclk_clk                     => AD1939_MCLK,                     
            spi_clk_clk                         => AD1939_SPI_CLK,                     
            ad1939_physical_asdata2             => AD1939_ADC_ASDATA2,
            ad1939_physical_dbclk               => AD1939_DAC_DBCLK,
            ad1939_physical_dlrclk              => AD1939_DAC_DLRCLK,
            ad1939_physical_dsdata1             => AD1939_DAC_DSDATA1,
            clk_clk                               => FPGA_CLK1_50,
            hps_0_f2h_cold_reset_req_reset_n      => not hps_cold_reset,
            hps_0_f2h_debug_reset_req_reset_n     => not hps_debug_reset ,
            hps_0_f2h_stm_hw_events_stm_hwevents  => stm_hw_events,
            hps_0_f2h_warm_reset_req_reset_n      => not hps_warm_reset,
            hps_0_h2f_reset_reset_n               => hps_fpga_reset_n,
            hps_0_hps_io_hps_io_emac1_inst_TX_CLK => HPS_ENET_GTX_CLK,
            hps_0_hps_io_hps_io_emac1_inst_TXD0   => HPS_ENET_TX_DATA(0),
            hps_0_hps_io_hps_io_emac1_inst_TXD1   => HPS_ENET_TX_DATA(1),
            hps_0_hps_io_hps_io_emac1_inst_TXD2   => HPS_ENET_TX_DATA(2), 
            hps_0_hps_io_hps_io_emac1_inst_TXD3   => HPS_ENET_TX_DATA(3),
            hps_0_hps_io_hps_io_emac1_inst_RXD0   => HPS_ENET_RX_DATA(0),
            hps_0_hps_io_hps_io_emac1_inst_MDIO   => HPS_ENET_MDIO,
            hps_0_hps_io_hps_io_emac1_inst_MDC    => HPS_ENET_MDC,
            hps_0_hps_io_hps_io_emac1_inst_RX_CTL => HPS_ENET_RX_DV,
            hps_0_hps_io_hps_io_emac1_inst_TX_CTL => HPS_ENET_TX_EN,
            hps_0_hps_io_hps_io_emac1_inst_RX_CLK => HPS_ENET_RX_CLK,
            hps_0_hps_io_hps_io_emac1_inst_RXD1   => HPS_ENET_RX_DATA(1),
            hps_0_hps_io_hps_io_emac1_inst_RXD2   => HPS_ENET_RX_DATA(2),
            hps_0_hps_io_hps_io_emac1_inst_RXD3   => HPS_ENET_RX_DATA(3),
            hps_0_hps_io_hps_io_sdio_inst_CMD     => HPS_SD_CMD,
            hps_0_hps_io_hps_io_sdio_inst_D0      => HPS_SD_DATA(0),
            hps_0_hps_io_hps_io_sdio_inst_D1      => HPS_SD_DATA(1),
            hps_0_hps_io_hps_io_sdio_inst_CLK     => HPS_SD_CLK,
            hps_0_hps_io_hps_io_sdio_inst_D2      => HPS_SD_DATA(2),
            hps_0_hps_io_hps_io_sdio_inst_D3      => HPS_SD_DATA(3),
            hps_0_hps_io_hps_io_usb1_inst_D0      => HPS_USB_DATA(0),
            hps_0_hps_io_hps_io_usb1_inst_D1      => HPS_USB_DATA(1),
            hps_0_hps_io_hps_io_usb1_inst_D2      => HPS_USB_DATA(2),
            hps_0_hps_io_hps_io_usb1_inst_D3      => HPS_USB_DATA(3),
            hps_0_hps_io_hps_io_usb1_inst_D4      => HPS_USB_DATA(4),
            hps_0_hps_io_hps_io_usb1_inst_D5      => HPS_USB_DATA(5),
            hps_0_hps_io_hps_io_usb1_inst_D6      => HPS_USB_DATA(6),
            hps_0_hps_io_hps_io_usb1_inst_D7      => HPS_USB_DATA(7),
            hps_0_hps_io_hps_io_usb1_inst_CLK     => HPS_USB_CLKOUT,
            hps_0_hps_io_hps_io_usb1_inst_STP     => HPS_USB_STP,
            hps_0_hps_io_hps_io_usb1_inst_DIR     => HPS_USB_DIR,
            hps_0_hps_io_hps_io_usb1_inst_NXT     => HPS_USB_NXT,
            hps_0_hps_io_hps_io_spim1_inst_CLK    => HPS_SPIM_CLK,
            hps_0_hps_io_hps_io_spim1_inst_MOSI   => HPS_SPIM_MOSI,
            hps_0_hps_io_hps_io_spim1_inst_MISO   => HPS_SPIM_MISO,
            hps_0_hps_io_hps_io_spim1_inst_SS0    => HPS_SPIM_SS,
            hps_0_hps_io_hps_io_uart0_inst_RX     => HPS_UART_RX,
            hps_0_hps_io_hps_io_uart0_inst_TX     => HPS_UART_TX,
            hps_0_hps_io_hps_io_i2c0_inst_SDA     => HPS_I2C0_SDAT,
            hps_0_hps_io_hps_io_i2c0_inst_SCL     => HPS_I2C0_SCLK,            
            hps_0_hps_io_hps_io_i2c1_inst_SDA     => HPS_I2C1_SDAT,
            hps_0_hps_io_hps_io_i2c1_inst_SCL     => HPS_I2C1_SCLK,
            hps_0_hps_io_hps_io_gpio_inst_GPIO09  => HPS_CONV_USB_N,
            hps_0_hps_io_hps_io_gpio_inst_GPIO35  => HPS_ENET_INT_N,
            hps_0_hps_io_hps_io_gpio_inst_GPIO40  => HPS_LTC_GPIO,
            hps_0_hps_io_hps_io_gpio_inst_GPIO53  => HPS_LED,
            hps_0_hps_io_hps_io_gpio_inst_GPIO54  => HPS_KEY,
            hps_0_hps_io_hps_io_gpio_inst_GPIO61  => HPS_GSENSOR_INT,
            memory_mem_a                          => HPS_DDR3_ADDR,
            memory_mem_ba                         => HPS_DDR3_BA,
            memory_mem_ck                         => HPS_DDR3_CK_P,
            memory_mem_ck_n                       => HPS_DDR3_CK_N,
            memory_mem_cke                        => HPS_DDR3_CKE,
            memory_mem_cs_n                       => HPS_DDR3_CS_N,
            memory_mem_ras_n                      => HPS_DDR3_RAS_N,
            memory_mem_cas_n                      => HPS_DDR3_CAS_N,
            memory_mem_we_n                       => HPS_DDR3_WE_N,
            memory_mem_reset_n                    => HPS_DDR3_RESET_N,
            memory_mem_dq                         => HPS_DDR3_DQ,
            memory_mem_dqs                        => HPS_DDR3_DQS_P,
            memory_mem_dqs_n                      => HPS_DDR3_DQS_N,
            memory_mem_odt                        => HPS_DDR3_ODT,
            memory_mem_dm                         => HPS_DDR3_DM,
            memory_oct_rzqin                      => HPS_DDR3_RZQ,
				
            reset_reset_n                         => hps_fpga_reset_n,


            --Brought in from DE10 Terasic QT Demo
            --alt_vip_itc_0_clocked_video_vid_clk                                     => clk_65,                                     --                         alt_vip_itc_0_clocked_video.vid_clk
            --alt_vip_itc_0_clocked_video_vid_data                                    => alt_vip_itc_0_clocked_video_vid_data_reg,                                    --                                                    .vid_data
            --alt_vip_itc_0_clocked_video_underflow                                   => open,                                   --                                                    .underflow
            --alt_vip_itc_0_clocked_video_vid_datavalid                               => HDMI_TX_DE,                               --                                                    .vid_datavalid
            --alt_vip_itc_0_clocked_video_vid_v_sync                                  => HDMI_TX_VS,                                  --                                                    .vid_v_sync
            --alt_vip_itc_0_clocked_video_vid_h_sync                                  => HDMI_TX_HS,                                  --                                                    .vid_h_sync
            --alt_vip_itc_0_clocked_video_vid_f                                       => open,                                       --                                                    .vid_f
            --alt_vip_itc_0_clocked_video_vid_h                                       => open,                                       --                                                    .vid_h
            --alt_vip_itc_0_clocked_video_vid_v                                       => open ,                                       --                                                    .v
            clk_130_clk                             => clk_130 ,    


            --Brought in from DE10 Terasic QT Demo
            alt_vip_itc_0_clocked_video_vid_clk                                     => clk_65,                                     --                         alt_vip_itc_0_clocked_video.vid_clk
            alt_vip_itc_0_clocked_video_vid_data                                    => alt_vip_itc_0_clocked_video_vid_data_reg,                                    --                                                    .vid_data
            alt_vip_itc_0_clocked_video_underflow                                   => open,                                   --                                                    .underflow
            alt_vip_itc_0_clocked_video_vid_datavalid                               => HDMI_TX_DE,                               --                                                    .vid_datavalid
            alt_vip_itc_0_clocked_video_vid_v_sync                                  => HDMI_TX_VS,                                  --                                                    .vid_v_sync
            alt_vip_itc_0_clocked_video_vid_h_sync                                  => HDMI_TX_HS,                                  --                                                    .vid_h_sync
            alt_vip_itc_0_clocked_video_vid_f                                       => open,                                       --                                                    .vid_f
            alt_vip_itc_0_clocked_video_vid_h                                       => open,                                       --                                                    .vid_h
            alt_vip_itc_0_clocked_video_vid_v                                       => open,    




            led_pio_external_connection_export    => LED      ,    --    led_pio_external_connection.export
            dipsw_pio_external_connection_export  => SW   , --  dipsw_pio_external_connection.export
            button_pio_external_connection_export =>  fpga_debounced_buttons(1 downto 0), --button_pio_external_connection.export       
				
            codec_clk_clk                             => codec_clk,
            onchip_memory2_0_s2_address               => std_logic_vector(to_unsigned(address_counter,16)),
            onchip_memory2_0_s2_chipselect            => '1',
            onchip_memory2_0_s2_clken                 => '1',
            onchip_memory2_0_s2_write                 => data_valid,
            onchip_memory2_0_s2_readdata              => open,   
            onchip_memory2_0_s2_writedata             => line_in_data_data_r,--std_logic_vector(word_counter),
            onchip_memory2_0_s2_byteenable            => byte_mask(3 downto 0),--(others => '1'),
            onchip_memory2_0_clk2_clk                 => codec_clk,
            onchip_memory2_0_reset2_reset             => hps_fpga_reset_n,
            
            line_in_data_channel                      => line_in_data_channel,
            line_in_data_data                         => line_in_data_data,
            line_in_data_error                        => line_in_data_error,
            line_in_data_valid                        => line_in_data_valid
      );
  -----------------------------------------------------------------------
  -- SPI interface to the AD1939 SPI Control Port
  -----------------------------------------------------------------------
	spi_AD1939: spi_commands
		generic map (
			command_used_g            => '1',  -- command field is used
			address_used_g            => '1',  -- address field is used
			command_width_bits_g     =>  1,   -- command is 1 byte
			address_width_bits_g     =>  1,   -- address is 1 byte
			data_width_bits_g   =>  8,   -- data length is 8 bits (Note: AD1939 uses a 24-bit input data word where: Global_Address=23:17="0000100", R/W=16 (read=1), Register_Address=15:8, Register_Data=7:0    See Table 14 on page 24 of AD1939 Data Sheet).
			output_bits_g       =>  24,
			cpol_cpha                 => "00"  -- AD1939:  CPOL=0, CPHA=0
		)
		port map (
			clk	                      => AD1939_SPI_CLK,  					-- spi clock (10 MHz max)
			rst_n 	                  => hps_fpga_reset_n,		   				-- component reset
			command_in                => AD1939_spi_command,  				-- Command includes Global Address (0000100) and is either Read ("00001001") or Write ("00001000").
			address_in                => AD1939_spi_register_address,  	-- Register Address.  There are 17 Control Registers from address 0 to address 16.  See Control Register descriptions starting on page 24 of AD1939 Data Sheet
			address_en_in             => '1',          						-- 1=Address field will be used.
			data_length_in            => "00000001",   						-- Data payload will be 1 byte ("00000001").	
			master_slave_data_in      => AD1939_spi_write_data,			-- data to be written to an AD1939 register
			master_slave_data_rdy_in  => AD1939_spi_write_data_rdy,    	-- assert (clock pulse) to write the data
			master_slave_data_ack_out => open,                         	-- ignore acknowledgement 
			command_busy_out          => AD1939_spi_busy,					-- If 1, the spi is busy servicing a command. 
			command_done              => AD1939_spi_done,					-- pulse signals end of command
			slave_master_data_out(7 downto 0)     => AD1939_spi_read_data,				-- data read from AD1939 register
			slave_master_data_ack_out => AD1939_spi_read_data_ack,		-- data ready to be read
			miso 				              => AD1939_spi_COUT,					-- AD1939 SPI signal = data from AD1939 SPI registers
			mosi 					            => AD1939_spi_CIN,						-- AD1939 SPI signal = data to AD1939 SPI registers
			sclk 					            => AD1939_spi_CCLK,					-- AD1939 SPI signal = sclk: serial clock
			cs_n 					            => AD1939_spi_CLATCH_n				-- AD1939 SPI signal = ss_n: slave select (active low)
		);
	
  -- ---------------------------------------------------------------------------------------------
	-- -- Extend the SPI slave select hold time 
	-- ---------------------------------------------------------------------------------------------
		-- holdSpiLatch : process (FPGA_CLK1_50)
		-- begin
			-- if rising_edge(FPGA_CLK1_50) then
				-- if HPS_spi_ss_n = '0' then
					-- AD1939_spi_clatch_counter   <= (others=>'0');                  -- reset counter
					-- AD1939_spi_CLATCH_n         <= '0';
				-- elsif AD1939_spi_clatch_counter < x"00000040" then
					-- AD1939_spi_clatch_counter   <= AD1939_spi_clatch_counter + 1;  -- increment counter
					-- AD1939_spi_CLATCH_n         <= '0';                            -- hold low until counter reaches threshold
				-- else
					-- AD1939_spi_CLATCH_n         <= '1';                            -- release clatch
				-- end if;
			-- end if;
		-- end process;
		




--

u_I2C_HDMI_Config: component I2C_HDMI_Config port map (
      iCLK => FPGA_CLK1_50,
      iRST_N => '1',
      I2C_SCLK => HDMI_I2C_SCL,
      I2C_SDAT => HDMI_I2C_SDA,
      HDMI_TX_INT => HDMI_TX_INT
      );

 vga_pll_inst: component vga_pll port map (
                  refclk => FPGA_CLK1_50,   --//  refclk.clk
               rst => '0',     -- //   reset.reset
               outclk_0 => clk_65, --// outclk0.clk
               outclk_1 => clk_130,-- // outclk1.clk
               locked => open   -- //  locked.export
);

  HDMI_TX_CLK <= clk_65;

	HDMI_TX_D <= 	alt_vip_itc_0_clocked_video_vid_data_reg(23 downto 0);
		
	
	
	
	--! Convert the signals to 32, 28f
	--! @note These are signed signals, so sign extensions are neccessary
	--! @todo Make this a component with generics to set the sizes
	--! @todo Instead of the ugly sign extension used used here, use resize(in, size) or SXT(in, size) or data_out <= std_logic_vector(resize(signed(data_in), data_out'length));
--	AD1939_Data_ADC1_Left_w32f28 <= AD1939_Data_ADC1_Left(23) & AD1939_Data_ADC1_Left(23) & AD1939_Data_ADC1_Left(23) & AD1939_Data_ADC1_Left(23) & AD1939_Data_ADC1_Left & "0000";
--	AD1939_Data_ADC1_Right_w32f28 <= AD1939_Data_ADC1_Right(23) & AD1939_Data_ADC1_Right(23) & AD1939_Data_ADC1_Right(23) & AD1939_Data_ADC1_Right(23) & AD1939_Data_ADC1_Right & "0000";
--	
--	AD1939_Data_ADC2_Left_w32f28 <= AD1939_Data_ADC2_Left(23) & AD1939_Data_ADC2_Left(23) & AD1939_Data_ADC2_Left(23) & AD1939_Data_ADC2_Left(23) & AD1939_Data_ADC2_Left & "0000";
--	AD1939_Data_ADC2_Right_w32f28 <= AD1939_Data_ADC2_Right(23) & AD1939_Data_ADC2_Right(23) & AD1939_Data_ADC2_Right(23) & AD1939_Data_ADC2_Right(23) & AD1939_Data_ADC2_Right & "0000";
	

	
	--input_select<="10";
	
	--! Crossbar select on the input source
	--! @todo Make this a component
	--! @note For the input_select line: "00" = Mute, "01" = Line In, "10" = Microphone in, "11" = Mems Microphone
	--! @todo Mems Microphone input is unconneted
--	audio_left_input_selected <= 	AD1939_Data_ADC1_Left_w32f28 when (input_select = "01") else
--											AD1939_Data_ADC2_Left_w32f28 when (input_select = "10") else
--											(others => '0');
--	
--	
--	audio_right_input_selected <= AD1939_Data_ADC1_Right_w32f28 when (input_select = "01") else
--											AD1939_Data_ADC2_Right_w32f28 when (input_select = "10") else
--											(others => '0');
--	


	
	
	
	--! Debounce a the reset button on the development board
	debounce_inst: component debounce
	port map (	
		clk			=> fpga_clk_50,
		reset_n		=> hps_fpga_reset_n,  
		data_in		=> KEY,
		data_out		=> fpga_debounced_buttons(1 downto 0)
	);
	
	--! These look like syncronizers for the various reset types (Altera/Intel code)
	--! @todo What exactly does this do?
	pulse_cold_reset: component altera_edge_detector 
	generic map ( PULSE_EXT => 6, EDGE_TYPE => 1, IGNORE_RST_WHILE_BUSY => 1 )
	port map (	
		clk       => fpga_clk_50,
		rst_n     => hps_fpga_reset_n,
		signal_in => hps_reset_req(0),
		pulse_out => hps_cold_reset
	);
	
	--! These look like syncronizers for the various reset types (Altera/Intel code)
	--! @todo What exactly does this do?
	pulse_warm_reset: component altera_edge_detector 
	generic map ( PULSE_EXT => 2, EDGE_TYPE => 1, IGNORE_RST_WHILE_BUSY => 1 )
	port map (	
		clk       => fpga_clk_50,
		rst_n     => hps_fpga_reset_n,
		signal_in => hps_reset_req(1),
		pulse_out => hps_warm_reset
	);
	
	--! These look like syncronizers for the various reset types (Altera/Intel code)
	--! @todo What exactly does this do?
	pulse_debug_reset: component altera_edge_detector 
	generic map ( PULSE_EXT => 32, EDGE_TYPE => 1, IGNORE_RST_WHILE_BUSY => 1 )
	port map (	
		clk       => fpga_clk_50,
		rst_n     => hps_fpga_reset_n,
		signal_in => hps_reset_req(2),
		pulse_out => hps_debug_reset
	);	

	
	
   -- ---------------------------------------------------------------------------------------------
	-- -- Tri-state buffer the I2C signals
	-- ---------------------------------------------------------------------------------------------
	-- ubuf1 : component alt_iobuf
    -- port map(
        -- i   => '0',
        -- oe  => i2c_serial_sda_oe,
        -- io  => TPA6130_i2c_SDA,
        -- o   => i2c_0_i2c_serial_sda_in
    -- );
	
	-- ubuf2 : component alt_iobuf
    -- port map(
        -- i   => '0',
        -- oe  => serial_scl_oe,
        -- io  => TPA6130_i2c_SCL,
        -- o   => i2c_serial_scl_in
    -- );	
		
    

  -- Simple counter process (also triggers the address changes)
  address_counter_process : process(codec_clk,hps_fpga_reset_n)
  begin 
    if hps_fpga_reset_n = '0' then 
      address_counter <= 0;
      byte_mask <= "10000";
    elsif rising_edge(codec_clk) then 
      if line_in_data_valid = '1' and line_in_data_channel = "00" then 
        write_data <= '1';
        word_counter <= word_counter + 1;
        line_in_data_data_r <= line_in_data_data;
        
      if address_counter = FRAME_LENGTH - 1 then 
        address_counter <= 0;
      else
        address_counter <= address_counter + 1;
      end if;
          
          
      -- else 
        -- write_data <= write_data;
        -- word_counter <= word_counter;
        -- line_in_data_data_r <= line_in_data_data_r;
      end if;
      
      if write_data = '1' then 
        if byte_mask(0) = '1' then 
          write_data <= '0';
          data_valid <= '0';  
        else
          -- if address_counter = FRAME_LENGTH - 1 then 
            -- address_counter <= 0;
          -- else
            -- address_counter <= address_counter + 1;
          -- end if;
          
          data_valid <= '1';
        end if;
        
        byte_mask <= byte_mask(0) & byte_mask(4 downto 1);
        
      end if;
    end if;
  end process;
    
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  process (AD1939_SPI_CLK, hps_fpga_reset_n)
  begin
  
    -- Reset the signals when the system reset is deasserted
    if hps_fpga_reset_n = '0' then
      state     <= spi_init_load;  
      init_counter <= 0;
      
    -- If the reset is not asserted, 
    elsif (rising_edge(AD1939_SPI_CLK)) then
      case state is  
           
        when spi_init_load => 
          state <= spi_write_init_start;
          
        when spi_write_init_start =>
          if AD1939_spi_busy = '1' then 
            state <= spi_write_init_busy;
          else
            state <= spi_write_init_start;
          end if;
          
        when spi_write_init_busy =>
          if AD1939_spi_busy = '1' then 
            state <= spi_write_init_busy;
          else
            state <= spi_init_load;
            init_counter <= init_counter + 1;
          end if; 

        when spi_done =>
          state <= spi_done;

        when others =>
          state <= spi_init_load;
          
      end case;
        
    end if;
  end process;

    --------------------------------------------------------------
    -- State Machine to implement Avalon streaming
    -- Generate Avalon streaming signals
    --------------------------------------------------------------
  process (AD1939_SPI_CLK)
  begin
    if (rising_edge(AD1939_SPI_CLK)) then
      case state is     
           
        when spi_init_load =>
          AD1939_spi_command              <= AD1939_spi_command_write;
          AD1939_spi_register_address     <= REG_SETTINGS(79-16*init_counter downto 72-16*init_counter);
          AD1939_spi_write_data 			    <= REG_SETTINGS(71-16*init_counter downto 64-16*init_counter);
          
        when spi_write_init_start =>
          AD1939_spi_write_data_rdy <= '1';
          
        when spi_write_init_busy =>
          AD1939_spi_write_data_rdy <= '0';
          
        when spi_done =>
                  
        when others => 
        -- do nothing
      end case;
    end if;
  end process;
	
	
	-------------------------------------------------------
	-- DE10-Nano Board (unused signals output signals)
	-------------------------------------------------------
	--LED               <= (others => '0');
	Audio_Mini_GPIO_0 <= (others => 'Z');
	Audio_Mini_GPIO_1 <= (others => 'Z');
	ADC_CONVST	      <= '0'; 				
  
  
  --data_valid <= '1' when line_in_data_channel = "00" else '0';
  
  
  
  
  
	
	
	
	
	
   
	
	
	
	
	
	

end architecture DE10_arch;
