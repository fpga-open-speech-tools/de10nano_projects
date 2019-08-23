library ieee;
use     ieee.std_logic_1164.all;

library altera_mf;
use     altera_mf.altera_mf_components.all;

entity rom_id is 
    generic (
          DEVICE            : string    := "Stratix IV"
        ; MIF_VERSION       : string    := "rom_id_version.mif"
        ; MIF_TIMECODE      : string    := "rom_id_timecode.mif"
        ; MIF_PARTNUMBER    : string    := "rom_id_partnumber.mif"
    );
    port
	(
          clk               : in  std_logic
        ; id_version        : out std_logic_vector( 32-1 downto 0)
        ; id_timecode       : out std_logic_vector( 32-1 downto 0)
        ; id_partnumber     : out std_logic_vector(256-1 downto 0)
	);
end entity rom_id;

architecture rtl of rom_id is
begin

rom_version : altsyncram generic map
	( address_aclr_a         => "NONE"
	, clock_enable_input_a   => "BYPASS"
	, clock_enable_output_a  => "BYPASS"
    , init_file              => MIF_VERSION
	, intended_device_family => DEVICE
	-- , lpm_hint               => "ENABLE_RUNTIME_MOD=NO"
	, lpm_hint               => "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=VERS"
	, lpm_type               => "altsyncram"
	, numwords_a             => 1
	, operation_mode         => "ROM"
	, outdata_aclr_a         => "NONE"
	, outdata_reg_a          => "UNREGISTERED"
	, widthad_a              => 1
	, width_a                => 32
	, width_byteena_a        => 1
	) port map
	( clock0                 => clk
	, address_a              => (others=>'0')
	, q_a                    => id_version
	);
    
rom_timecode : altsyncram generic map
	( address_aclr_a         => "NONE"
	, clock_enable_input_a   => "BYPASS"
	, clock_enable_output_a  => "BYPASS"
  	, init_file              => MIF_TIMECODE
	, intended_device_family => DEVICE
	-- , lpm_hint               => "ENABLE_RUNTIME_MOD=NO"
	, lpm_hint               => "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=TIME"
	, lpm_type               => "altsyncram"
	, numwords_a             => 1
	, operation_mode         => "ROM"
	, outdata_aclr_a         => "NONE"
	, outdata_reg_a          => "UNREGISTERED"
	, widthad_a              => 1
	, width_a                => 32
	, width_byteena_a        => 1
	) port map
	( clock0                 => clk
	, address_a              => (others=>'0')
	, q_a                    => id_timecode
	);

    
rom_partnumber : altsyncram generic map
	( address_aclr_a         => "NONE"
	, clock_enable_input_a   => "BYPASS"
	, clock_enable_output_a  => "BYPASS"
    , init_file              => MIF_PARTNUMBER
	, intended_device_family => DEVICE
	-- , lpm_hint               => "ENABLE_RUNTIME_MOD=NO"
	, lpm_hint               => "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=IDPN"
	, lpm_type               => "altsyncram"
	, numwords_a             => 1
	, operation_mode         => "ROM"
	, outdata_aclr_a         => "NONE"
	, outdata_reg_a          => "UNREGISTERED"
	, widthad_a              => 1
	, width_a                => 256
	, width_byteena_a        => 1
	) port map
	( clock0                 => clk
	, address_a              => (others=>'0')
	, q_a                    => id_partnumber
	);
    
end architecture rtl;
