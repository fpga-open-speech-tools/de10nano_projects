----------------------------------------------------------------------------------
--
-- Company:          Flat Earth, Inc.
-- Author/Engineer:	Ross K. Snider
--
-- Create Date:      09/09/2016
--
-- Design Name:      AD1939_control.vhd  
--       				
-- Description:      This component initializes the AD1939 registers and read/writes individual registers
--
-- Target Device(s): Altera DE0-Nano-Soc Evaluation Board
-- Tool versions:    Quartus Prime 16.0
--
-- Dependencies:     AD1939_control.vhd
--                       spi_commands
--                       AD1939_Control.vhd
--                       AD1939_Data.vhd
--
-- Revisions:        1.0 (File Created)
--
-- Additional Comments: 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity AD1939_control is
		port (
		AD1939_SPI_CLK : in  std_logic; -- SPI Clock (also component clock) that must be <= 10 MHz
		reset          : in  std_logic; -- system reset
		state_monitor  : out std_logic_vector (3 downto 0);  -- debug
		----------------------------------------------------------------------------------------------------------------
		-- Signals to/from AD1939 SPI Control Port (data direction from AD1939 perspective)
		-- 10 MHz CCLK max (see page 7 of AD1939 data sheet)
		-- CIN data is 24-bits (see page 14 of AD1939 data sheet)
		-- CLATCH_n must have pull-up resistor so that AD1939 recognizes presence of SPI controller on power-up
		----------------------------------------------------------------------------------------------------------------
		AD1939_SPI_CIN      : out std_logic;  		 -- SPI Control Data Input to AD1939 pin 30 CIN
		AD1939_SPI_COUT     : in  std_logic;       -- SPI Control Data output from AD1939 pin 31 COUT
		AD1939_SPI_CCLK     : out std_logic;       -- SPI Control Clock Input to AD1939 pin 34 CCLK
		AD1939_SPI_CLATCH_n : out std_logic;       -- SPI Latch for control data, input to AD1939 pin 35 CLATCH_n (active low)
		----------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Simple interface to read/write AD1939 register data
		----------------------------------------------------------------------------------------------------------------------------------------------------------------
		AD1939_Reg_Addr				: in 		std_logic_vector (4 downto 0);   -- Address of AD1939 Register to be read/written (there are 17 registers)
		AD1939_Reg_Write_Data		: in 		std_logic_vector (7 downto 0);   -- Data to be written to AD1939 Register
		AD1939_Reg_Write_Start  	: in 		std_logic;                       -- Initiates the register write when asserted, must be deasserted to return from busy
		AD1939_Reg_Read_Data			: out		std_logic_vector (7 downto 0);   -- Data read from AD1939 Register
		AD1939_Reg_Read_Start	   : in 		std_logic;                       -- Initiates the register read when asserted, must be deasserted to return from busy
		AD1939_Reg_Read_Data_Ready	: out		std_logic;   							-- Clock pulse signifies data read from AD1939 Register and is ready to be captured
		AD1939_Reg_Busy	         : out 	std_logic                        -- read or write is occurring, any new read/write will be ignored 
		 );
end AD1939_control;

architecture behavioral of AD1939_control is

	-----------------------------------------------------------------------
	-- ROM that contains the register values that will be written upon
	-- power-up
   -----------------------------------------------------------------------
	component AD1939_reg_init_ROM
		PORT
		(
			address  : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			q		   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	end component; 
	
	component spi_commands is
	  generic(
	
	  command_used_g          : std_logic 	:= '1';
	  address_used_g          : std_logic 	:= '1';
	  command_width_bytes_g   : natural 	:= 1;
	  address_width_bytes_g   : natural 	:= 1;
	  data_length_bit_width_g : natural 	:= 8;
	  cpol_cpha               : std_logic_vector(1 downto 0) := "00"
	  );
		port(
			clk	           :in	std_logic;	
			rst_n 	        :in	std_logic;
			
			command_in      : in  std_logic_vector(command_width_bytes_g*8-1 downto 0);
			address_in      : in  std_logic_vector(address_width_bytes_g*8-1 downto 0);
			address_en_in   : in  std_logic;
			data_length_in  : in  std_logic_vector(data_length_bit_width_g - 1 downto 0);
			
			master_slave_data_in      :in   std_logic_vector(7 downto 0);
			master_slave_data_rdy_in  :in   std_logic;
			master_slave_data_ack_out :out  std_logic;
			command_busy_out          :out  std_logic;
			command_done              :out  std_logic;
	
			slave_master_data_out     : out std_logic_vector(7 downto 0);
			slave_master_data_ack_out : out std_logic;
	
			miso 				:in	std_logic;	
			mosi 				:out  std_logic;	
			sclk 				:out  std_logic;	
			cs_n 				:out  std_logic 
		);
	end component;

	
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
   signal   clk  	  : std_logic;                      
	
   -----------------------------------------------
	-- Define the states of the state machine
   -----------------------------------------------
	type state_type is (PowerUpReset, ROMLoadAddrData, ROMLoadRegData, ROMProgRegStart, ROMProgBusy, ROMProgNext, 
	                    SPIWait, SPIWriteLoad, SPIWriteStart, SPIWriteBusy, SPIReadSetup, SPIReadStart, SPIReadWait, SPIReadCapture); 
	signal current_state, next_state: state_type := PowerUpReset;  	
	--signal state_monitor : std_logic_vector (3 downto 0);  -- debug
	
	--------------------------------------------------------------------------------------------------
	-- Power Up (default) state that the AD1939 will be initialized to (i.e. power-up customization)
	-- There are 17 AD1939 registers to initialize at Power-up
	-- See the Matlab script AD1939_Register_Settings.m to create ROM initialization file. 
	---------------------------------------------------------------------------------------------------
	constant RegTotal   : std_logic_vector (4 downto 0) := "10001";   -- The AD1939 has 17 registers
	
begin


   clk <= AD1939_SPI_CLK;
	-----------------------------------------------------------------------
	-- ROM that contains the register values that will be written upon
	-- power-up
   -----------------------------------------------------------------------
	AD1939_reg_init_ROM_inst : AD1939_reg_init_ROM PORT MAP (
		address	 => ROM_addr,
		clock	    => clk,            -- the ROM registers the address so there is a 1 clock latency to get the data....
		q	       => ROM_data
	);
	ROM_addr <= reg_counter;          


	
	-----------------------------------------------------------------------
	-- SPI interface to the AD1939 SPI Control Port
   -----------------------------------------------------------------------
	spi_AD1939: spi_commands
		generic map (
			command_used_g            => '1',  -- command field is used
			address_used_g            => '1',  -- address field is used
			command_width_bytes_g     =>  1,   -- command is 1 byte
			address_width_bytes_g     =>  1,   -- address is 1 byte
			data_length_bit_width_g   =>  8,   -- data length is 8 bits (Note: AD1939 uses a 24-bit input data word where: Global_Address=23:17="0000100", R/W=16 (read=1), Register_Address=15:8, Register_Data=7:0    See Table 14 on page 24 of AD1939 Data Sheet).
			cpol_cpha                 => "00"  -- AD1939:  CPOL=0, CPHA=0
		)
		port map (
			clk	                    => AD1939_SPI_CLK,  					-- spi clock (10 MHz max)
			rst_n 	                 => not reset,		   				-- component reset
			command_in                => AD1939_spi_command,  				-- Command includes Global Address (0000100) and is either Read ("00001001") or Write ("00001000").
			address_in                => AD1939_spi_register_address,  	-- Register Address.  There are 17 Control Registers from address 0 to address 16.  See Control Register descriptions starting on page 24 of AD1939 Data Sheet
			address_en_in             => '1',          						-- 1=Address field will be used.
			data_length_in            => "00000001",   						-- Data payload will be 1 byte ("00000001").	
			master_slave_data_in      => AD1939_spi_write_data,			-- data to be written to an AD1939 register
			master_slave_data_rdy_in  => AD1939_spi_write_data_rdy,    	-- assert (clock pulse) to write the data
			master_slave_data_ack_out => open,                         	-- ignore acknowledgement 
			command_busy_out          => AD1939_spi_busy,					-- If 1, the spi is busy servicing a command. 
			command_done              => AD1939_spi_done,					-- pulse signals end of command
			slave_master_data_out     => AD1939_spi_read_data,				-- data read from AD1939 register
			slave_master_data_ack_out => AD1939_spi_read_data_ack,		-- data ready to be read
			miso 				           => AD1939_spi_COUT,					-- AD1939 SPI signal = data from AD1939 SPI registers
			mosi 					        => AD1939_spi_CIN,						-- AD1939 SPI signal = data to AD1939 SPI registers
			sclk 					        => AD1939_spi_CCLK,					-- AD1939 SPI signal = sclk: serial clock
			cs_n 					        => AD1939_spi_CLATCH_n				-- AD1939 SPI signal = ss_n: slave select (active low)
		);
	
	
	
   -----------------------------------------------
	-- State Machine - State Transition Process
   -----------------------------------------------
	process (clk,reset)
	begin
		if ( reset = '1' ) then
			current_state <= PowerUpReset;  	
		elsif (rising_edge(clk)) then
			current_state <= next_state; 	-- change the state to the next state
		end if;
	end process;

   -----------------------------------------------
	-- State Machine - Determine Next State
   -----------------------------------------------
	process (current_state, reg_counter, AD1939_spi_busy, AD1939_Reg_Write_Start, AD1939_Reg_Read_Start,               AD1939_spi_done, AD1939_spi_read_data_ack)
	begin	
	   ----------------------------------------------
		-- The Default is to stay in the current state
		-- unless the next state is explicity targeted
		----------------------------------------------
		next_state <= current_state;
		-----------------------------
		--- Determine the Next State
		-----------------------------
		case (current_state) is
		   ------------------------------------------------------------
		   -- States associated with ROM and power-up initialization
			------------------------------------------------------------
			when PowerUpReset =>  
				next_state <= ROMLoadAddrData;      
			---------------------------------------			
			when ROMLoadAddrData =>
				next_state <= ROMLoadRegData;     
			---------------------------------------			
			when ROMLoadRegData =>
				next_state <= ROMProgRegStart;     
			---------------------------------------		
			when ROMProgRegStart =>
				next_state <= ROMProgBusy;          
			---------------------------------------		
			when ROMProgBusy =>
			   if ( AD1939_spi_done = '1' ) then
				   next_state <= ROMProgNext;      
	         else
               next_state <= ROMProgBusy;             
            end if;				
			---------------------------------------		
			when ROMProgNext =>
				if ( reg_counter <= RegTotal ) then
					next_state <= ROMLoadAddrData;
				else
					next_state <= SPIWait;
				end if;
		   -------------------------------------------------------------------------
		   -- States associated with interface to read/write AD1939 register data
			-------------------------------------------------------------------------
			when SPIWait =>
				if ( AD1939_Reg_Write_Start = '1' ) then
					next_state <= SPIWriteLoad;
				elsif 
				   ( AD1939_Reg_Read_Start = '1' ) then
					next_state <= SPIReadStart;
				end if;
		   -------------------------------------------------------------------------
		   -- States associated with interface to write AD1939 register data
			-------------------------------------------------------------------------
			when SPIWriteLoad =>
				next_state <= SPIWriteStart;
			---------------------------------------			
			when SPIWriteStart =>
				next_state <= SPIWriteBusy;
			---------------------------------------			
			when SPIWriteBusy =>
				if ( (AD1939_spi_busy = '1') or (AD1939_Reg_Write_Start = '1') ) then   -- AD1939_Reg_Write_Start must be deasserted to return from busy
					next_state <= SPIWriteBusy;
				else
				   next_state <= SPIWait;
				end if;
		   -------------------------------------------------------------------------
		   -- States associated with interface to read AD1939 register data
			-------------------------------------------------------------------------
			when SPIReadSetup =>
				next_state <= SPIReadStart;
			---------------------------------------			
			when SPIReadStart =>
				next_state <= SPIReadWait;
			---------------------------------------			
			when SPIReadWait =>
				if ( AD1939_spi_read_data_ack = '1' ) then
					next_state <= SPIReadWait;
				else
				   next_state <= SPIReadCapture;
				end if;
			---------------------------------------			
			when SPIReadCapture =>
				next_state <= SPIWait;
		   -------------------------------------------------------------------------
		   -- Other States
			-------------------------------------------------------------------------
			when others =>
				next_state <= PowerUpReset;
			---------------------------------------			
		end case;
	end process;
	
   -----------------------------------------------
	-- State Machine - Generate Output Signals
   -----------------------------------------------
	process (current_state, reg_counter, reg_prog_done,          ROM_data, AD1939_Reg_Addr, AD1939_Reg_Write_Data, AD1939_spi_read_data)
	begin 
		-- Default Output Signals (value of signals if they are not explicitly set in a state)
		reg_counter_enable 	<= '0'; 
		reg_counter_clear  	<= '0';  
		reg_prog_start 		<= '0';		
		reg_load             <= "00";
		AD1939_spi_write_data_rdy     <= '0';
		AD1939_Reg_Busy               <= '1';   -- default is to signify busy unless in the SPIWait state waiting for commands.
		AD1939_Reg_Read_Data_Ready    <= '0';
		AD1939_spi_register_address   <= "00000000";
		AD1939_spi_write_data         <= "00000000"; 
		state_monitor                 <= "0000";  -- for debug...
		
		
		AD1939_Reg_Read_Data <= (others=>'0');
		
		
		--- Set state dependent values
		case (current_state) is
		   ------------------------------------------------------------
		   -- States associated with ROM and power-up initialization
			------------------------------------------------------------
			when PowerUpReset =>
				reg_counter_clear    <= '1';  
				state_monitor        <= "0001";
			---------------------------------------		
			when ROMLoadAddrData =>                                  -- there is a 1 cycle latency to get the ROM data since the address is registered at the input of the ROM
				AD1939_spi_register_address  <= "000" & reg_counter;  -- reg_addr = ROM_addr
				state_monitor                <= "0010";
			---------------------------------------		
			when ROMLoadRegData =>
				AD1939_spi_write_data        <= ROM_data;  
				AD1939_spi_command           <= AD1939_spi_command_write;
				AD1939_spi_register_address  <= "000" & reg_counter;  -- reg_addr = ROM_addr
				state_monitor                <= "0011";
			---------------------------------------		
			when ROMProgRegStart =>
				AD1939_spi_write_data        <= ROM_data;  
			   AD1939_spi_write_data_rdy    <= '1';
				reg_counter_enable 	        <= '1'; 
				AD1939_spi_register_address  <= "000" & reg_counter;  -- reg_addr = ROM_addr
				state_monitor                <= "0100";
			---------------------------------------		
			when ROMProgBusy =>
				state_monitor              <= "0101";
			---------------------------------------		
			when ROMProgNext =>
				state_monitor              <= "0110";
		   -------------------------------------------------------------------------
		   -- States associated with interface to read/write AD1939 register data
			-------------------------------------------------------------------------
			when SPIWait =>
				AD1939_Reg_Busy      		<= '0';  -- not busy and can accept read/write commands
				state_monitor              <= "0111";
		   -------------------------------------------------------------------------
		   -- States associated with interface to write AD1939 register data
			-------------------------------------------------------------------------
			when SPIWriteLoad =>
			   AD1939_spi_register_address <= "000" & AD1939_Reg_Addr;
				AD1939_spi_write_data       <= AD1939_Reg_Write_Data;
				AD1939_spi_command 			 <= AD1939_spi_command_write;
				state_monitor               <= "1000";
			---------------------------------------			
			when SPIWriteStart =>
			   AD1939_spi_write_data_rdy   <= '1';
			   AD1939_spi_register_address <= "000" & AD1939_Reg_Addr;
				state_monitor               <= "1001";
			---------------------------------------			
			when SPIWriteBusy =>
				state_monitor               <= "1010";				
		   -------------------------------------------------------------------------
		   -- States associated with interface to read AD1939 register data
			-------------------------------------------------------------------------
			when SPIReadSetup =>
			   AD1939_spi_register_address <= "000" & AD1939_Reg_Addr;
				AD1939_spi_command 			 <= AD1939_spi_command_read;
				state_monitor               <= "1011";			
			---------------------------------------			
			when SPIReadStart =>
			   AD1939_spi_write_data_rdy   <= '1';
			   AD1939_spi_register_address <= "000" & AD1939_Reg_Addr;
				state_monitor               <= "1100";				
			---------------------------------------			
			when SPIReadWait =>
				state_monitor               <= "1101";				
			---------------------------------------			
			when SPIReadCapture =>
			   AD1939_Reg_Read_Data        <= AD1939_spi_read_data;
				AD1939_Reg_Read_Data_Ready  <= '1';
				state_monitor               <= "1110";				
		   -------------------------------------------------------------------------
		   -- Other States
			-------------------------------------------------------------------------
			when others =>
				-- do nothing;
			---------------------------------------			
		end case;
	end process;
		
	-----------------------------------------------------------------------------
	-- Generate the Register Counter, i.e. ROM addresses (with clear and enable)
   -----------------------------------------------------------------------------
	process(clk,reset)
	begin
		if (reset = '1') then
			reg_counter <= "00000";
		elsif rising_edge(clk) then
			if (reg_counter_clear = '1') then
				reg_counter <= "00000";
			elsif (reg_counter_enable = '1') then
				reg_counter <= reg_counter + 1;
			end if;
		end if;		
	end process;
	
end behavioral;
