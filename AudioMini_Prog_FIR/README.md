# Programmable FIR Filter
This project is a prototype of a programmable FIR filter that uses dual port RAM in the fpga fabric. 

## How to use it
### Setup
- put soc_system.dtb on the FAT32 partition of the SD card
- put all sh scripts and ko files on the SD card's rootfs
- put the coefficients txt files on the SD card's rootfs

### Usage
Load in the FE_DPRAM.ko and FE_pFIR.ko, in that order
```bash
insmod FE_DPRAM.ko
insmod FE_pFIR.ko
```
Then load the codec and headphone amplifier drivers.

To program the filter coefficients, run pFIR_HPF.sh or pFIR_LPF.sh with `bash`. 
You may need to adjust the scripts to point to the correct coefficients txt files. 
You may also need to adjust the major number for the DPRAM driver; if you load the 
DPRAM driver first, the major number should be 248, which matches the shell scripts.


## Notes
The DPRAM driver exposes every memory address as a separate register in sysfs. 
The pFIR driver exposes registers for address, data, and read/write lines; the pFIR
driver doesn't appear to be responsible for programming the DPRAM, at least not 
with the files that made it into the PRs. 
