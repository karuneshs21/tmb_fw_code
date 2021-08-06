# tmb_fw_code

Legacy Run2 TMB fiwmare 

# compile firmware and generate XSVF files, load firmware into prom/FPGA

### load firmware from emulib 
To load the firmware through Emulib, use the XSVF format (like tmb.xsvf) and it takes ~5 min to load the firmware (go to chamber test and click load TMB firmware ). 
The Jtag cable must be disconnected when loading  the firmware from emulib 

### load firmware with .mcs files using jtag 
To load the firmware from impact, open impact software and then select the mcs file in order.  The mcs file for the first prom (closest to the FPGA on Jtag chain)  is the one with filename ending with 0 when prom files are created, like tmb_virtex2_20202113_0.mcs. Other prom files for next 3 proms are like tmb_virtex2_20202113_1.mcs, tmb_virtex2_20202113_2.mcs, tmb_virtex2_20202113_3.mcs.  Overall it takes ~10 min in total to load firmware from impact.  Make sure the parallel mode is enabled for programming properties!


### create XSVF files from impact during loading firmware to FPGA
To create the XSVF files from Impact:

In Impact, do boundary scan with the tmb connected 

Then if you go to Output --> XSVF --> Create XSVF File 

Then choose a file name to save it as 

Then you go through the normal routine of clicking all the different proms, assigning the bitstreams, load the firmware

Then go back to Output --> XSVF --> stop writing xsvf file 

Between Create and Stop it records all the different jtag commands that it sends out and saves them in a file



### software environment 
TMB firmware must be compiled with old ISE(ISE10.1) but can be programmed with newer version of impact tool
