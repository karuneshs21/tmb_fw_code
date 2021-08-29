# tmb_fw_code
Firwmare code for TMB (virtex2)

## master branch: Run1 Run2 legacy code
## TMB_FW_2021 branch
Remove obsolete modules (RPC and Miniscope) on top of master branch 
## TMB_FW_2021_CCLUT branch
This branch included new features ported from new OTMB firmware, developed on top of TMB_FW_2021 branch
   - CCLUT algorithm
   - High multiplicity trigger(HMT)
   - new trigger data format and DAQ data format
   - new VME registers to control above features

But unfortunately the compilation failed because too many resource are used. Need to test the version with less new features probably.  The following the resouce usage from last try

Interim Summary

Logic Utilization:

  Number of Slice Flip Flops:        24,974 out of  46,080   54%
  
  Number of 4 input LUTs:            64,820 out of  46,080  140% (OVERMAPPED)




## compile firmware and generate XSVF files, load firmware into prom/FPGA at TAMU cms lab

### load firmware from emulib 
To load the firmware through Emulib, use the XSVF format (like tmb.xsvf, ~/firmware/tmb/20160326/typeA/tmb.xsvf on cmslab1) and it takes ~5 min to load the firmware (go to chamber test and click load TMB firmware ). 
The Jtag cable must be disconnected when loading  the firmware from emulib 

### load firmware with .mcs files using jtag 
To load the firmware from impact, open impact software and then select the mcs file in order.  The mcs file for the first prom (closest to the FPGA on Jtag chain)  is the one with filename ending with 0 when prom files are created, like tmb_virtex2_20202113_0.mcs. Other prom files for next 3 proms are like tmb_virtex2_20202113_1.mcs, tmb_virtex2_20202113_2.mcs, tmb_virtex2_20202113_3.mcs.  Overall it takes ~10 min in total to load firmware from impact.  Make sure the parallel mode is enabled for programming properties!


### create XSVF files from impact during loading firmware to proms
Creating the XSVF files from Impact includes two parts:

First step is to creat the mcs files from impact:
   - open impact, go to create prom file
   - step1: xilinx Flash/Prom  -> step2 add Storage Device: add 4 xc18v04 devices -> step3 fill the Output filename and select output directory
   - click ok button to create the four mcs files:  output_filename_0.mcs (for the prom next to FPGA), output_filename_1.mcs, output_filename_2.mcs, output_filename_3.mcs

The second step is to create the XSVF during loading firmware to proms:

In Impact, do boundary scan with the tmb connected 

Then if you go to Output --> XSVF --> Create XSVF File 

Then choose a file name to save it as 

Then you go through the normal routine of clicking all the different proms, assigning the bitstreams, load the firmware

Then go back to Output --> XSVF --> stop writing xsvf file 

Between Create and Stop it records all the different jtag commands that it sends out and saves them in a file



### software environment 
TMB firmware must be compiled with old ISE(ISE10.1) but can be programmed with newer version(like 14.7) of impact tool


### run emulib for loading and testing TMB firmware at TAMU cmslab

To start the XDAQ for TMB test, I created one script on cmslab1 using EMUlib_V14_Master branch: ~/TMBTestslot8_startXdaq_instruction.sh. The TMB should be in slot8

