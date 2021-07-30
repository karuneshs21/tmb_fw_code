# tmb_fw_code



# compile firmware and generate XSVF files, load firmware into prom/FPGA
To load the firmware through Emulib, use the XSVF format (~/firmware/tmb/20160326/typeA/tmb.xsvf) and it takes ~5 min to load the firmware (go to chamber test) 
The Jtag cable must be disconnected!

To load the firmware from impact, at TAMU lab use the impact software on cmslab1 and the mcs file for the first prom (closest to the FPGA on Jtag chain)  is ~/Run2bat904_TMBFW/20210105_typeA/tmb_virtex2_20202113_0.mcs and others are tmb_virtex2_20202113_1.mcs, tmb_virtex2_20202113_2.mcs, tmb_virtex2_20202113_3.mcs under same path.  Overall it took ~10 min in total.  Make sure the parallel mode is enabled for programming properties!

To create the XSVF files from Impact:

In Impact, do boundary scan with the tmb connected 

Then if you go to Output --> XSVF --> Create XSVF File 

Then choose a file name to save it as 

Then you go through the normal routine of clicking all the different proms, assigning the bitstreams, load the firmware

Then go back to Output --> XSVF --> stop writing xsvf file 

Between Create and Stop it records all the different jtag commands that it sends out and saves them in a file

To start the XDAQ for TMB test, I created one script on cmslab1 using EMUlib_V14_Master branch: ~/TMBTestslot8_startXdaq_instruction.sh

TMB firmware must be compiled with old ISE(ISE10.1) but can be programmed with new impact tool
