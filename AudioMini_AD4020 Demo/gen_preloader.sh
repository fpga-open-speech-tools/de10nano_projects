#!/usr/bin/sh
# config options 
PRELOADER_SETTINGS_DIR=hps_isw_handoff/soc_system_hps_0 
BSP_DIR=software/spl_bsp

# look for previously-created bsp settings 
if [[ -f $BSP_DIR/settings.bsp ]]; then 
# the settings.bsp file already exists 
# we could update it with bsp-update-settings if we wanted to 
printf "settings.bsp already exists; moving on...\n" 
else 
# the settings.bsp file doesn't exist, so create it 
printf "creating bsp settings...\n" 
bsp-create-settings 
    --type spl\ 
    --bsp-dir $BSP_DIR\ 
    --settings $BSP_DIR/settings.bsp\ 
    --preloader-settings-dir $PRELOADER_SETTINGS_DIR 
fi
# generate the bsp files 
printf "\ngenerating bsp files...\n" 
bsp-generate-files --settings $BSP_DIR/settings.bsp --bsp-dir $BSP_DIR
# make the preloader printf "\nmaking the preloader...\n" 
cd $BSP_DIR 
make