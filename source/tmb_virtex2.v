`timescale 1ns / 1ps
//`define DEBUG_TMB_VIRTEX2 1
//-------------------------------------------------------------------------------------------------------------------
//	tmb_virtex2:	Top Level
//-------------------------------------------------------------------------------------------------------------------
//	03/12/2003	Initial: Ported TMB2003a from tmb2001a+cfebreqst
//	03/13/2003	New TTC decodes in ccb.v
//	03/14/2003	Gpio1 pulldown moved to gpio0, cylon waits for phos4
//	03/15/2003	Sequencer mods for l1reset, scope clock changed, onboard LEDs pup, replace ccb_bx0 with decode
//	03/16/2003	Sequencer mod for l1a leds, vme fix for seqmod
//	03/17/2003	Minor mods to VME section, add phos4_busy_done to phos4_lock
//	03/17/2003	Add dmb_busy to scope
//	03/19/2003	Fix cfebs_exist, un-reverse crc22, latch la1_tx at xtmb+1 instead of pretrig
//	03/25/2003	Fix active_feb_flag double pulse, add invp to scope, add start trigger on bx0 to ccb.v
//	04/04/2003	Sequencer outputs dmb data available after l1a window closes, replaces 1st word flag
//	04/15/2003	Sequencer mods for dmb_dav and bxn at l1a to fix dav failure on 2nd l1a within 75ns
//	04/17/2003	Shorten max bxn from 3564 to 924 for CERN beam test
//	04/22/2003	Mod alct.v to set wr_fifo high when disabled by VME
//	04/29/2003	LHC_CYCLE changed from parameter to VME programmable, added ttc_bxreset
//	04/30/2003	Add mpc_accept_tp for scope display
//	05/05/2003	Fix cfeb_v8 hs ds selection rule
//	05/06/2003	Use hs_thresh_ff for hs ds selection instead of hs_thresh, add pipeline ff to cfeb_v8.v, alas
//	05/07/2003	Add new scope signals
//	05/08/2003	Mods for scope v1h
//	05/12/2003	New scope channels, add cfebn_hsds tag to pretrigger
//	05/13/2003	Add scope96
//	05/16/2003	Add sequencer readout of scope96
//	05/19/2003	Don't allow scope nrams to be programmable
//	05/20/2003	Fix ram mux in scope96 for auto mode
//	05/22/2003	Mod vme.v for usr_jtag to match boot register, swap tdi tdo port directions
//	05/27/2003	Re-allow scope nrams to be programmable because OSUs DMB fails to read large events
//	06/04/2003	Add led_flash_rate and overload nl1a to show buffers full
//	09/11/2003	Moved mpc_accept_tp and mpc_accept_vme from tmb.v to sequencer, removed FF enables
//	09/12/2003	Add allowpretrignoflush to allow next pretrig without flushing after a nobuffer pretrig 
//	10/06/2003	Ported from TMB2003a
//	03/11/2004	Updates from bdtestv3.v, new ddd.v, new clock3.v, new dsn.v, new rpc signals
//	03/15/2004	Convert all 80MHz inputs to DDR
//	04/12/2004	Un-inverted tmb_cfg_done beco no pull-ups on TMB
//	04/13/2004	Re-invert tmb_cfg_done beco GTL drivers have bus hold
//	04/19/2004	Clear alct ram word count on vme reset
//	04/19/2004	Revert alct_rx from DDR to 80MHz, had sync err on some bits for unknown reason
//	04/20/2004	Revert all DDR to 80MHz, 4/19 mod failed in PAR
//	04/26/2004	Add raw hits readout for RPC data
//	04/28/2004	Add rpc raw hits delay
//	05/06/2004	New rpc unit
//	05/12/2004	More rpc mods
//	05/20/2004	Add RPC to sequencer, and VME
//	05/21/2004	Change rpc injector defaults
//	05/24/2004	Mod sequencer readout machine to skip empty RPCs
//	05/25/2004	Tuning RPC readout
//	06/07/2004	Fix tmb.v injector and 1st clct window latching error, change to x_demux_v2, has aset for mpc
//	06/08/2004	Mod vme.v csc_id logic
//	06/09/2004	Change RAT delay default to 9, change -1 logic in sequencer to avoid 32-bit underflow
//	06/10/2004	Add programmable mpc barrel shifter delay
//	06/17/2004	Add programmable scope trigger channel, vme uses direct _ga for board_id default
//	07/23/2004	Add nph_pattern to header
//	07/30/2004	Add crc checking for alct raw hits
//	08/03/2004	Add event counters
//	08/04/2004	Fix l1a counter
//	08/06/2004	Add mpc accept counters
//	08/09/2004	Add oneshot to alct ext_trig and ext_inject
//	08/18/2004	Change alct_ccb_ext_trig_en default to 0
//	08/23/2004	Add alct registers for alct board debug firmware
//	08/25/2004	separate ccb_clock40_enable from alct_clock_enable
//	08/26/2004	Add counter stop if any overflows
//	08/30/2004	Add alct_ext_trig bypass similar to clct for blocked ccb
//	08/31/2004	Add alct lct error counter for alct debug firmware
//	09/01/2004	Fix alct err counter
//	10/01/2004	Add scp_auto to header
//	10/04/2004	Poobah demands ttc_bx0 sent to mpc instead of bx0_local
//	10/05/2004	Add alct crc error test point for oscope trigger
//	11/15/2004	New power-up defaults for RAT2004A
//	04/21/2005	Mods for tmb2005a prototype, add mez test points
//	06/09/2005	Mods for TMB2005 new signal assignments:
//				alct_front_rear	--> alct_rxoe
//				_alct_oe			--> alct_txoe
//				rpc_rxalt[0]		-->	rpc_smbrx
//				rpc_rxalt[1]		--> rpc_dsn  (aliases rpc_free_rx0, alct_rx[30])
//				alct_rx[29]			--> rpc_done (shares gp_io[4])
//				boot[13]			--> rpc_hard_reset
//	06/10/2005	Temporarily flip led_fp for proto board
//	06/15/2005	Make loopback reg bits alct_txoe and alct_rxoe readonly for lazy software programmers
//	06/17/2005	Change version ID to E for tmb2005
//	08/05/2005	Change default alct_status_en and clct_status_en to off for multi-TMB-in-crate
//	08/05/2005	Fix cnt_tmb_nol1a no connected
//	08/08/2005	Tri-state ccb if gtl_loop or ccb_status_oe to prevent bus contention, change _ccb_status_ to ccb_status_oe
//	09/09/2005	Unflip leds for production boards
//	02/27/2006	Updated date codes, compile with 12mA mpc drive per riceu tests
//	03/17/2006	Float usr jtag io after hard reset so u76 device-type can be detected
//	04/24/2006	Add jtag state machine to read alct prom
//	05/19/2006	Add active_feb_flag blanking for disabled CFEBs per OSU request
//	05/22/2006	Mod sequencer to block clct pattern triggers from disabled cfebs
//	05/24/2006	Add alct dav etc to scope
//	05/25/2006	bug fixes for cfeb_en
//	07/26/2006	Add vmesm state machine
//	07/27/2006	Add uptimer and health bits to raw hits header
//	08/02/2006	Add layer trigger mode
//	08/07/2006	Mod ddd to wait for vme state machine to finish
//	08/15/2006	Remove ff from layer_trig signal to speed up by 1 clock
//	08/28/2006	Add ddd_rat for RAT module, rename ddd to ddd_tmb
//  08/30/2006	Add clct and alct bxns to vme readout
//	08/31/2006	Fix missing default writes in vme.v
//	09/01/2006	Fix rpc_dsn iob in rpc.v and vme.v
//	09/11/2006	Port from FND 4.2 to ISE 8.2
//	09/15/2006	XST mods to cfeb,scope
//	09/18/2006	XST mods to ramlut
//	09/25/2006	XST mods to tmb.v, x_delay.v, x_delay_os.v
//	10/02/2006	Mod vmesm to remove autostart ff because its always set by parameter
//	10/03/2006	Change ramult.v from explict reference to xst inferred rams
//	10/04/2006	Mods to cfeb.v replace for-loops, use generate statement for triad_decoders
//	10/04/2006	Power-up mods for xst in vme.v
//	10/04/2006	Set ffs=0 init value. XST should be doing that, but does not
//	10/04/2006	Restructure cmd decoder loop in ccb.v
//	10/05/2006	Replace for-loops with while-loops for xst in clct_fifo.v, rpc.v, and sequencer.v
//	10/06/2006	Add ise version register
//	10/09/2006	Convert rpc.v to ddr
//	10/10/2006	Replace 80mhz mux and demux with 40mhz ddr, change bufg to bufgmux for virtex2
//	10/11/2006	Cylon now uses srl init
//	10/11/2006	reg=0 mods to sequencer, vme jen
//	10/16/2006	Temporarily revert triad persistence to 6-1=5 for software compatibility
//	10/16/2006	Unrevert, so persitence is now 6=6
//	10/17/2006	Add first_pat to scope
//	10/20/2006	Add l1a window position to header22 in sequencer.v
//	10/20/2006	Fix l1a received counter in sequencer.v
//	10/23/2006	Mods to l1a window position counter in sequencer.v
//	10/24/2006	More mods to l1a window position logic
//	10/25/2006	Yet more mods to l1a window position logic
//	11/22/2006	Mod scope channels in sequencer.v
//	11/27/2006	More scope channel mods
//	11/28/2006	Fix resolver.v cfeb3/cfeb4 boundary logic to delete cfeb4 correctly
//	12/06/2006	New triad_decoder.v zero deadtime decoder machine, extending hs pulses
//	01/09/2007	Change synthesis attribute in triad_decoder
//	02/12/2007	Mod sequencer to set all_cfebs_active only for cfebs enabled for readout
//	04/06/2007	Reduce RPC arrays from 2 to 4, updated rpc.v with 1bx faster rat demux
//	04/09/2007	Add mpc_oe to tmb.v and vme.v
//	04/27/2007	Remove alct+cfeb+mpc rx sync stages, shifts rx clocks by 12.5ns
//	04/27/2007	Mod ccb.v fmm state machine, ttc_l1reset renamed to ttc_resync, add ignore ttc_start/stop bit
//	04/30/2007	Revert mpc rx sync stage, because we can't shift mpc rx data by the necessary half cycle for ddr2
//	05/15/2007	Pattern finder a/b multiplexer select trials
//	05/16/2007	Forced init on a/b multiplexer select and moved signal from lut to 80mhz ff
//	05/21/2007	Shorten tmb.v by 2bx, blank mpc quality if no valid lct
//	05/22/2007	Reduce to just one vme clct separation parameter, add triad skip counter
//	05/23/2007	Mod pattern 3 ly5 to mirror pattern 2 in pattern_unit
//	05/25/2007	Fix persist1 signal in cfeb.v
//	06/13/2007	Change pattern_finder a/b commutation to use new direct clock mirror from dcm
//	06/14/2007	Replace a/b commutation with logic accissible clock, add serial fanout in pattern finder
//	06/20/2007	Replace pattern finder with integrated layer-trigger version, shifts pattern IDs +2
//	06/21/2007	Add bit to block writes to adr 10 to allow parallel downloads to selected alcts
//	06/22/2007	Increase tmb match timeout in sequencer.v beco clct_width is temporarily 7bx
//	07/02/2007	Change key layer from ly3 to ly2. Revert tmb timeouts temporarily until checked in simulator
//	07/02/2007	Mod pattern_unit.v to match prior ly3 result, reduces fpga usage from 93% to 90%
//	07/03/2007	Mod pid_thresh_pretrig AND logic in pattern_finder
//	07/05/2007	Fix adjcfeb logic, extend masks to span full cfeb, increase adjcfeb_dist to 6 bits
//	07/10/2007	Increase tmb match timeout, but make clct_sm wait before re-arming for new event, else get wrong tmb buf
//	07/16/2007	Update alct.v rams and state machines, add global reset input
//	07/18/2007	Update tmb.v rams and state machines
//	07/19/2007	Swap tmb.v mpc injector ram frames
//	07/20/2007	Revert mpc ram, too many problems with asymmetric ports
//	07/23/2007	New scope.v and sequencer.v with fewer rams, increase scope from 256tbins to 512
//	07/25/2007	New rpc.v injector rams, new mpc ram, solved asymmetric ports problem
//	07/26/2007	Mod rpc.v bxn ram, delay injector_go_rpc 1bx to match cfeb raw hits
//	07/30/2007	Fix rpc.v bxn ram sump OR
//	07/31/2007	Increase tmb match timeout again, extend count to 5 bits, to allow for clct_width=15 but not 16 (ie 0)
//	08/03/2007	Return scope channels to normal assignments, fix alct dangling ram warning
//	08/10/2007	Replace sequencer.v and tmb.v, new rams, fix tmb_trig_pulse to handle no-match when set to match-only
//	08/10/2007	Replace scope with 512 tbin version to work with new sequencer.v
//	08/13/2007	Swap in x-version, add buffer reset counter
//	08/22/2007	New header/trailer format in sequencer.v
//	08/23/2007	New crc in alct.v
//	08/24/2007	Header debugging
//	08/27/2007	Bugfix in sequencer sump
//	08/28/2007	More header debugging
//	08/29/2007	Yet more header debugging
//	08/30/2007	Header mods, expand year in revcode
//	08/31/2007	Header mods, increase vme counter width
//	09/04/2007	Consolidate counter widths
//	09/06/2007	Delay pretrig and trig counters 1bx in sequencer.v
//	09/07/2007	Fix header 22,37,38 + alct counter
//	09/10/2007	Mod trigpath check logic from alct.v, add tmb matching details to header, restructure vme counters
//	09/11/2007	Increment readout counter 1bx earlier, add temporary debug channels to scope
//	09/12/2007	Latch tmb dupe signals using mpc data strobe, which is 1bx later than matching info
//	09/13/2007	Add alct ddr constraints, add no alct counter, mod alct trig path errors, remove tmb dupe ffs
//	09/14/2007	Injected alct now counts as alct received in alct.v, sequencer.v revert to normal scope signals
//	09/17/2007	Big raw hits buffer version started
//	09/18/2007	Convert 5 cfeb instances to 1 gen loop
//	09/19/2007	Replace rpc.v with big buffer version, increase inj_rwadr width
//	09/25/2007	Replace clct_fifo with big buffer version
//	10/01/2007	New clct_fifo with conforming cfeb and rpc sections
//	10/04/2007	Subtract read address offset from fifo ram read address to compensate for pre-trigger latency
//	10/09/2007	Conform sequencer crc logic to ddu, skip de0f marker because ddu logic fails to include it
//	10/11/2007	Conform alct crc logic to ddu's inferior algorithm
//	10/15/2007	Replace clct_fifo section with cfeb and rpc timing mods
//	10/16/2007	Remove OR of 2 high order tbin bits in of raw hits stream, just let 4-bit tbin markers wrap at 16
//	10/29/2007	Replace distributed header rams with block rams
//	11/02/2007	Replace sequencer.v and tmb.v, mod vme.v to replace timeout counters with phase reply counters
//	12/12/2007	Add new buffer control logic module, remove old code from clct_fifo module
//	12/14/2007	New buffer status signals, rename clct_fifo
//	12/18/2007	Add inhibit for auto buffer reset
//	12/20/2007	Replace L1A stack
//	12/21/2007	L1A bug fixes
//	01/24/2008	Replace buf write/read modules, replace l1a section of sequencer, replace lct quality
//	01/28/2008	Changed wr_buf_adr_l1a to wr_adr_l1a in sequencer.v
//	01/31/2008	Remove 2bx FF delay in alct.v, route alcts to seqencer instead of tmb.v
//	02/01/2008	Add parity to cfeb and rpc raw hits rams for seu detection
//	02/04/2008	Move parity to separate module
//	02/05/2008	Replace inferred raw hits rams with instantiated ram, xst fails to build dual port parity block rams
//	02/05/2008	Add parity errors to header27 and vme adr FA
//	02/06/2008	Replace alct window width oneshot with triad decoder zero delay counter logic
//	02/07/2008	Add pretrig-drift_delay pipleline
//	04/18/2008	Replace sequencer.v and tmb.v with pipeline versions from sequencer_tmb_wrbuf sub-design
//	04/21/2008	Change tp to tprt realtime test points in sequencer.v scope
//	04/22/2008	Add triad test point at raw hits RAM input for internal scope
//	04/22/2008	Decrease drift delay pipe 1bx in sequencer
//	04/22/2008	Tune read_adr_offset in buffer_read/write_ctrl.v for new pre-trigger state machine
//	04/23/2008	Clct blanking mods to pattern_finder.v and sequencer.v
//	04/24/2008	Make clct1 invalid if it has hits below threshold
//	04/25/2008	Add alct_bx0 to mpc frame, allow independent cfeb and rpc tbins, mod header36
//	04/28/2008	Reoragnize counters, block clct-unblanking unless non-standard trigger and L1A modes are enabled
//	04/29/2008	Add new tmb status counter signals, convert counters to 2D arrays
//	04/30/2008	New scope channel assignments, added throttle state to deadtime counter
//	05/01/2008	Rearrange scope channels, push clct_counter into ram 1bx after xtmb, fix hdr11,22,28 write strobes
//	05/09/2008	Move xmpc frame storage to latch after mpc_tx_delay instead of before, makes bx0 delay independent
//	05/12/2008	Fix alct data wr_buf adr in sequencer.v
//	05/14/2008	Updates to global reset in clock_virtex2
//	05/19/2008	Replace mpc rx pipeline, response pipe chained to tx delay pipe, fixes mpc response counter too
//	05/22/2008	Connected global_reset to local power-up resets
//	05/23/2008	Mod global_reset to pulse when DLL re-locks, latch lock loss for sync_err
//	05/29/2008	Updates to alct.v, structure error counters, remove raw hits sync that never worked
//	05/30/2008	Add resync to cfeb.v etc, change default clear_on_resync
//	06/02/2008	Add global_reset_en to clock module
//	06/03/2008	Add mux for active_feb_list to include in scope, add scope mux-mode for alct inputs
//	06/26/2008	Replace alct jtag machine with compact-data version
//	07/01/2008	Mods to alct jtag machine, new signals to vme reg
//	07/02/2008	Mods to alct jtag machine, added prom emulator
//	07/07/2008	Replace jtagsm
//	07/08/2008	Mod status clear in jtagsm, mod chain word arithmetic
//	07/09/2008	Rename hit_thresh_pretrig, pid_thresh_pretrig, hit_thresh_postdrift, add pid_thresh_pretrig_postdrift
//	07/11/2008	Add non-triggering event readout option to tmb.v
//	07/14/2008	Mods to tmb.v
//	07/15/2008	Bugfix non-triggering event logic
//	07/18/2008	Replace corrupted ucf with backup copy
//	08/01/2008	Mod pattern_finder, add purge machine, remove stagger mux, make stagger_csc an output
//	08/01/2008	Gate r_nrpcs_read with rpc_read_enable to zero rpc count in header if rpc readout is off
//	08/04/2008	Add me1a/b pattern finder modules, alas
//	08/12/2008	Add bx0_match to tmb.v
//	08/12/2008	Add pgm delay to alct tx data
//	08/19/2008	Add jsm_sel to select new or old alct user prom state machine and data format
//	08/20/2008	New pattern finder module for me1a/b hs reversal
//	08/21/2008	New reversal mux in pattern finder beco last version was too slow
//	08/23/2008	Add hs reversal option for normal csc
//	08/25/2008	Mod pattern_finder to have non-programmable stagger and reversal, add new multi-compile types
//	08/27/2008	Add ttc PLL lock-loss counter in ccb.v
//	08/28/2008	Remove vme adr FE ccb_stat2, move ccb PLL counters to cnt[56] cnt[57]
//	08/28/2008	Expand trigger source vector to include ME1A and ME1B, replace pattern finder ifdefs
//	09/05/2008	Replace tmb me1a processing to block clcts to mpc
//	09/11/2008	Add tmb trig keep strobes to header
//	10/22/2008	Conform tmb signal names to sequencer output signals
//	11/14/2008	Add sync error counter
//	11/16/2008	Mod fence queue to store l1a data
//	11/18/2008	Mod parity module
//	01/13/2009	Expand alct_seq_cmd to 4 bits, take 1 from alct_reserved_in[4]
//	01/20/2009	Add alct cable loopback test ports
//	02/24/2009	Add ecc to data received from alct, add 2 ecc error counters
//	03/02/2009	Fix sync blanking in alct.v, add ecc to alct trigger data for header, add ecc vme enable
//	04/29/2009	Add miniscope
//	04/30/2009	Add miniscope parity
//	05/04/2009	Add alct1 realtime testpoint for miniscope
//	05/28/2009	Mod clock io list for new alct muonic timing
//	06/11/2009	Change to digital phase shift for alct rxd txd
//	06/12/2009	Change to lac clock for alct rxd txd interstages
//	06/16/2009	Remove digital phase shifter per poobah
//	06/25/2009	Reinstall alct digital phase shifters, add muonic cfeb
//	06/29/2009	Remove digital phase shifters for cfebs, certain cfeb IOBs can not have 2 clock domains
//	07/10/2009	Return digital phase shifters for cfebs, mod ucf to move 5 IOB DDRs to fabric
//	07/22/2009	Remove clock_vme global net to make room for cfeb digital phase shifter gbufs
//	08/05/2009	Remove alct posneg and interstage delay, remove cfeb posnegs
//	08/07/2009	Remove cfeb phase shifter global buffers, revert to 10mhz vme clock
//	08/11/2009	Replace clock_vme with clock in cfeb.v
//	08/12/2009	Replace clock_vme everywhere except vme core logic
//	08/13/2009	Put posneg back in alct receiver
//	08/14/2009	Take alct posneg back out, can not pass timing in par
//	08/20/2009	Put alct posneg back in, passes timing in par with ise 8.2 or with register balancing
//	09/03/2009	Signal name changes to conform to c++ code
//	09/04/2009	Add bx0 mez test points
//	09/08/2009	Add phaser autostart
//	09/09/2009	Remove bx0 mez test points
//	09/14/2009	Add sync err control module
//	04/27/2010	Add bx0 emulator to ccb.v add ttc_resync clears clock_lock_lost
//	05/10/2010	Change vme instantiation to use defparams for firmware version constants
//	06/26/2010	Add miniscope write address offset
//	06/30/2010	Mod injector RAM for alct and l1a bits
//	11/30/2010	Add virtex6 unified module names
//	05/31/2011	Mod vme to tri-state during write cycles
//	08/16/2012	Add ALCT Spartan-6 startup wait status to meztp
//	08/17/2012	Increase Spartan-6 startup delay 1ms for comfort
//	05/01/2013	Archive compile
//
//-------------------------------------------------------------------------------------------------------------------
//	Port Declarations
//-------------------------------------------------------------------------------------------------------------------
	module tmb_virtex2
	(
// CFEB
	cfeb0_rx,
	cfeb1_rx,
	cfeb2_rx,
	cfeb3_rx,
	cfeb4_rx,
	cfeb_clock_en,
	cfeb_oe,

// ALCT
	alct_rx,
	alct_txa,
	alct_txb,
	alct_clock_en,
	alct_rxoe,
	alct_txoe,
	alct_loop,

// DMB
	dmb_rx,
	dmb_tx,
	dmb_loop,
	_dmb_oe,

// MPC
	_mpc_tx,

// RPC
	rpc_rx,
	rpc_smbrx,
	rpc_dsn,
	rpc_loop,
// JGedit, comment out rpc:	rpc_tx,

	 
// CCB
	_ccb_rx,
	_ccb_tx,
	_gtl_oe,
	ccb_status_oe,
	_hard_reset_alct_fpga,
	_hard_reset_tmb_fpga,
	gtl_loop,

// VME
	vme_d,
	vme_a,
	vme_am,
	_vme_cmd,
	_vme_geo,
	vme_reply,

// JTAG
	jtag_usr,
	jtag_usr0_tdo,
	sel_usr,

// PROM
	prom_led,
	prom_ctrl,

// Clock
	tmb_clock0,
	tmb_clock0d,
	tmb_clock1,
	alct_rxclock,
	alct_rxclockd,
	mpc_clock,
	dcc_clock,
	step,

// 3D3444
	ddd_clock,
	ddd_adr_latch,
	ddd_serial_in,
	ddd_serial_out,

// Status
	mez_done,
	vstat,
	_t_crit,
	tmb_sn,
	smb_data,
	mez_sn,
	adc_io,
	adc_io3_dout,
	smb_clk,
	mez_busy,
	led_fp,

// General Purpose
	gp_io0,gp_io1,gp_io2,gp_io3,
	gp_io4,gp_io5,gp_io6,gp_io7,

// Mezzanine Test Points
	meztp20,
	meztp21,
	meztp22,
	meztp23,
	meztp24,
	meztp25,
	meztp26,
	meztp27
	);
//-------------------------------------------------------------------------------------------------------------------
//	Array Size Declarations
//-------------------------------------------------------------------------------------------------------------------
// CFEB Constants
	parameter MXCFEB		= 	5;				// Number of CFEBs on CSC
	parameter MXCFEBB		=	3;				// Number of CFEB ID bits
	parameter MXLY			=	6;				// Number Layers in CSC
	parameter MXCELL		=	3;				// Pattern cell width in 1/2-strips
	parameter MXCELLSZ		=	MXCELL*MXLY;	// Pattern cell area in 1/2-strips

	parameter MXMUX			=	24;				// Number of multiplexed CFEB bits
	parameter MXDS			=	8;				// Number of DiStrips per layer
	parameter MXDSX			=	MXCFEB*MXDS;	// Number of DiStrips per layer on 5 CFEBs
	parameter MXHS			=	32;				// Number of 1/2-Strips per layer
	parameter MXHSX			=	MXCFEB*MXHS;	// Number of 1/2-Strips per layer on 5 CFEBs
	parameter MXKEY			=	MXHS;			// Number of Key 1/2-strips
	parameter MXKEYB		=	5;				// Number of key bits
	parameter MXTR			=	MXMUX*2;		// Number of Triad bits per CFEB

// CFEB Raw hits RAM parameters
	parameter RAM_DEPTH		=	2048;			// Storage bx depth
	parameter RAM_ADRB		=	11;				// Address width=log2(ram_depth)
	parameter RAM_WIDTH		=	8;				// Data width

// Raw hits buffer parameters
	parameter MXBADR		=	RAM_ADRB;		// Header buffer data address bits
	parameter MXBDATA		=	32;				// Pushed data width
	parameter MXSTAT		=	3;				// Buffer status bits

// Pattern Finder Constants
	parameter MXKEYX		=	MXHSX;			// Number of key 1/2-strips on 5 CFEBs
	parameter MXKEYBX		=	8;				// Number of 1/2-strip key bits on 5 CFEBs
	parameter MXPIDB		=	4;				// Pattern ID bits
	parameter MXHITB		=	3;				// Hits on pattern bits
	parameter MXPATB		=	3+4;			// Pattern bits
        parameter MXXKYB                = 10;
         //CCLUT
        //parameter MXSUBKEYBX = 10;            // Number of EightStrip key bits on 7 CFEBs, was 8 bits with traditional pattern finding
        parameter MXPATC   = 12;                // Pattern Carry Bits
        parameter MXOFFSB = 4;                 // Quarter-strip bits
        parameter MXBNDB  = 5;                 // Bend bits, 4bits for value, 1bit for sign
        parameter MXPID   = 11;                // Number of patterns
        parameter MXPAT   = 5;                 // Number of patterns
        parameter MXHMTB     =  4;// bits for HMT

// Sequencer Constants
	parameter INJ_MXTBIN	=	5;				// Injector time bin counter width
	parameter INJ_LASTTBIN	=	31;				// Injector last time bin
	parameter MXBDID		=	5;				// Number TMB Board ID bits
	parameter MXCSC			=	4;				// Number CSC Chamber ID bits
	parameter MXRID			=	4;				// Number Run ID bits
	parameter MXDMB			=	49;				// Number DAQMB output bits, not including hardware dmb clock
	parameter MXDRIFT		=	2;				// Number drift delay bits
	parameter MXBXN			=	12;				// Number BXN bits, LHC bunchs numbered 0 to 3563
	parameter MXFLUSH		=	4;				// Number bits needed for flush counter
	parameter MXTHROTTLE	=	8;				// Number bits needed for throttle counte	parameter MXBXN			=	12;				// Number BXN bits, LHC bunchs numbered 0 to 3563
	parameter MXEXTDLY		=	4;				// Number CLCT external trigger delay counter bits

	parameter MXL1DELAY		=	8;				// NUmber L1Acc delay counter bits
	parameter MXL1WIND		=	4;				// Number L1Acc window width bits

	parameter MXBUF			=	8;				// Number of buffers
	parameter MXBUFB		=	3;				// Buffer address width 
	parameter MXFMODE		=	3;				// Number FIFO Mode bits
	parameter MXTBIN		=	5;				// Number FIFO time bin bits
	parameter MXFIFO		=	8;				// FIFO Slice data width

// ALCT RAM Constants
	parameter MXARAMADR		=	11;				// Number ALCT Raw Hits RAM address bits
	parameter MXARAMDATA	=	18;				// Number ALCT Raw Hits RAM data bits, does not include fifo wren

// DMB RAM Constants
	parameter MXRAMADR		=	12;				// Number Raw Hits RAM address bits
	parameter MXRAMDATA		=	18;				// Number Raw Hits RAM data bits, does not include fifo wren

// TMB Constants
	parameter MXCLCT		=	16;				// Number bits per CLCT word
	parameter MXCLCTC		=	3;				// Number bits per CLCT common data word
	parameter MXALCT		=	16;				// Number bits per ALCT word
	parameter MXMPCRX		=	2;				// Number bits from MPC
	parameter MXMPCTX		=	32;				// Number bits sent to MPC
	parameter MXFRAME		=	16;				// Number bits per muon frame
	parameter NHBITS		=	6;				// Number bits needed for header count
	parameter MXMPCDLY		=	4;				// MPC delay time bits

// RPC Constants
   // JGedit: does not work as 0, leave as 2...
	parameter MXRPC			=	2;				// Number RPCs
	parameter MXRPCB		=	1;				// Number RPC ID bits
	parameter MXRPCPAD		=	16;				// Number RPC pads per link board
	parameter MXRPCDB		=	19;				// Number RPC bits per link board
	parameter MXRPCRX		=	38;				// Number RPC bits per phase from RAT module

// Counters
	parameter MXCNTVME		=	30;				// VME counter width
	parameter MXORBIT		=	30;				// Number orbit counter bits
	parameter MXL1ARX		=	12;				// Number L1As received counter bits

//-------------------------------------------------------------------------------------------------------------------
// I/O Port Declarations
//-------------------------------------------------------------------------------------------------------------------
// CFEB
	input	[23:0]	cfeb0_rx;
	input	[23:0]	cfeb1_rx;
	input	[23:0]	cfeb2_rx;
	input	[23:0]	cfeb3_rx;
	input	[23:0]	cfeb4_rx;
	output	[4:0]	cfeb_clock_en;
	output			cfeb_oe;

// ALCT
	input	[28:1]	alct_rx;
	output	[17:5]	alct_txa;	// alct_tx[18] no pin
	output	[23:19]	alct_txb;
	output			alct_clock_en;
	output			alct_rxoe;
	output			alct_txoe;
	output			alct_loop;

// DMB
	input	[5:0]	dmb_rx;	
	output	[48:0]	dmb_tx;
	output			dmb_loop;
	output			_dmb_oe;

// MPC
	output	[31:0]	_mpc_tx;

// RPC
	input	[37:0]	rpc_rx;
	input			rpc_smbrx;	// was rpc_rxalt[0]
	input			rpc_dsn;	// was rpc_rxalt[1]	
	output			rpc_loop;
// JGedit, comment out rpc:	output	[3:0]	rpc_tx;

// CCB
	input	[50:0]	_ccb_rx;
	output	[26:0]	_ccb_tx;
	output			_gtl_oe;
	output			ccb_status_oe;
	output			_hard_reset_alct_fpga;
	output			_hard_reset_tmb_fpga;
	output			gtl_loop;

// VME
	inout	[15:0]	vme_d;
	input	[23:1]	vme_a;
	input	[5:0]	vme_am;
	input	[10:0]	_vme_cmd;
	input	[6:0]	_vme_geo;
	output	[6:0]	vme_reply;

// JTAG
	inout	[3:1]	jtag_usr;
	input			jtag_usr0_tdo;
	inout	[3:0]	sel_usr;

// PROM
	inout	[7:0]	prom_led;
	output	[5:0]	prom_ctrl;	

// Clock
	input			tmb_clock0;
	input			tmb_clock0d;
	input			tmb_clock1;
	input			alct_rxclock;
	input			alct_rxclockd;
	input			mpc_clock;
	input			dcc_clock;
	output	[4:0]	step;

// 3D3444
	output			ddd_clock;
	output			ddd_adr_latch;
	output			ddd_serial_in;
	input			ddd_serial_out;

// Status
	input			mez_done;
	input	[3:0]	vstat;
	input			_t_crit;
	inout			tmb_sn;
	inout			smb_data;
	inout			mez_sn;
	output	[2:0]	adc_io;
	input			adc_io3_dout;
	output			smb_clk;
	output			mez_busy;
	output	[7:0]	led_fp;

// General Purpose I/Os
	inout			gp_io0;		// jtag_fgpa0 tdo (out) shunted to gp_io1, usually
	inout			gp_io1;		// jtag_fpga1 tdi (in) 
	inout			gp_io2;		// jtag_fpga2 tms
	inout			gp_io3;		// jtag_fpga3 tck
	input			gp_io4;		// rpc_done
	output			gp_io5;		// _init  on mezzanine card, use only as an FPGA output
	output			gp_io6;		// _write on mezzanine card, use only as an FPGA output
	output			gp_io7;		// _cs    on mezzanine card, use only as an FPGA output// General Purpose I/Os

// Mezzanine Test Points
	output			meztp20;
	output			meztp21;
	output			meztp22;
	output			meztp23;
	output			meztp24;
	output			meztp25;
	output			meztp26;
	output			meztp27;

//-------------------------------------------------------------------------------------------------------------------
// Display definitions in synth log
//-------------------------------------------------------------------------------------------------------------------
// Load global defines
	`include "tmb_virtex2_fw_version.v"

// Display
	`ifdef FIRMWARE_TYPE		initial	$display ("FIRMWARE_TYPE %H", `FIRMWARE_TYPE);	`endif
	`ifdef VERSION				initial	$display ("VERSION       %H", `VERSION      );	`endif
	`ifdef MONTHDAY				initial	$display ("MONTHDAY      %H", `MONTHDAY     );	`endif
	`ifdef YEAR 				initial	$display ("YEAR          %H", `YEAR         );	`endif
	`ifdef FPGAID 				initial	$display ("FPGAID        %H", `FPGAID       );	`endif
	`ifdef ISE_VERSION			initial	$display ("ISE_VERSION   %H", `ISE_VERSION  );	`endif
	`ifdef MEZCARD				initial	$display ("MEZCARD       %H", `MEZCARD      );	`endif
	`ifdef VIRTEX2				initial $display ("VIRTEX2       %H", `VIRTEX2      );	`endif

	`ifdef AUTO_VME 			initial	$display ("AUTO_VME      %H", `AUTO_VME     );	`endif
	`ifdef AUTO_JTAG			initial	$display ("AUTO_JTAG     %H", `AUTO_JTAG    );	`endif
	`ifdef AUTO_PHASER			initial	$display ("AUTO_PHASER   %H", `AUTO_PHASER  );	`endif

	`ifdef ALCT_MUONIC			initial	$display ("ALCT_MUONIC   %H", `ALCT_MUONIC  );	`endif
	`ifdef CFEB_MUONIC			initial	$display ("CFEB_MUONIC   %H", `CFEB_MUONIC  );	`endif

	`ifdef CSC_TYPE_A			initial	$display ("CSC_TYPE_A    %H", `CSC_TYPE_A   );	`endif			
	`ifdef CSC_TYPE_B			initial	$display ("CSC_TYPE_B    %H", `CSC_TYPE_B   );	`endif			
	`ifdef CSC_TYPE_C			initial	$display ("CSC_TYPE_C    %H", `CSC_TYPE_C   );	`endif			
	`ifdef CSC_TYPE_D			initial	$display ("CSC_TYPE_D    %H", `CSC_TYPE_D   );	`endif			

        `ifdef CCLUT                            initial $display ("CCLUT         %H", `CCLUT        );  `endif  
            
        `ifdef VERSION_MAJOR  initial $display ("VERSION_MAJOR  %H", `VERSION_MAJOR );  `endif
        `ifdef VERSION_MINOR  initial $display ("VERSION_MINOR  %H", `VERSION_MINOR );  `endif
        `ifdef VERSION_FORMAT initial $display ("VERSION_FORMAT %H", `VERSION_FORMAT);  `endif


//-------------------------------------------------------------------------------------------------------------------
// Clock DCM Instantiation
//-------------------------------------------------------------------------------------------------------------------
// Phaser VME control/status ports
	wire [6:0]	dps_fire;
	wire [6:0]	dps_reset;
	wire [6:0]	dps_busy;
	wire [6:0]	dps_lock;

	wire [7:0]	dps0_phase;
	wire [7:0]	dps1_phase;
	wire [7:0]	dps2_phase;
	wire [7:0]	dps3_phase;
	wire [7:0]	dps4_phase;
	wire [7:0]	dps5_phase;
	wire [7:0]	dps6_phase;

	wire [2:0]	dps0_sm_vec;
	wire [2:0]	dps1_sm_vec;
	wire [2:0]	dps2_sm_vec;
	wire [2:0]	dps3_sm_vec;
	wire [2:0]	dps4_sm_vec;
	wire [2:0]	dps5_sm_vec;
	wire[2:0]	dps6_sm_vec;

	wire [MXCFEB-1:0] clock_cfeb_rxd;

	clock_ctrl uclock_ctrl
	(
// Clock inputs
	.tmb_clock0				(tmb_clock0),				// In	40MHz clock bypasses 3D3444 and loads Mez PROMs, chip bottom
	.tmb_clock0d			(tmb_clock0d),				// In	40MHz clock bypasses 3D3444 and loads Mez PROMs, chip top
	.tmb_clock1				(tmb_clock1),				// In	40MHz clock with 3D3444 delay
	.alct_rxclock			(alct_rxclock),				// In	40MHz ALCT receive data clock with 3D3444 delay, chip bottom
	.alct_rxclockd			(alct_rxclockd),			// In	40MHz ALCT receive data clock with 3D3444 delay, chip top
	.mpc_clock				(mpc_clock),				// In	40MHz MPC clock
	.dcc_clock				(dcc_clock),				// In	40MHz Duty cycle corrected clock with 3D3444 delay
	.rpc_sig				(gp_io4),					// In	40MHz Unused

// Main clock outputs
	.clock					(clock),					// Out	40MHz global TMB clock
	.clock_2x				(clock_2x),					// Out	80MHz global TMB clock
	.clock_vme				(clock_vme),				// Out	10MHz global VME clock
	.clock_lac				(clock_lac),				// Out	40MHz pattern finder multiplexer a/b select

// Phase delayed clocks
	.clock_alct_txd			(clock_alct_txd),			// Out	40MHz ALCT transmit data clock 1x
	.clock_alct_rxd			(clock_alct_rxd),			// Out	40MHz ALCT receive  data clock 1x
	.clock_cfeb0_rxd		(clock_cfeb_rxd[0]),		// Out	40MHz CFEB receive  data clock 1x
	.clock_cfeb1_rxd		(clock_cfeb_rxd[1]),		// Out	40MHz CFEB receive  data clock 1x
	.clock_cfeb2_rxd		(clock_cfeb_rxd[2]),		// Out	40MHz CFEB receive  data clock 1x
	.clock_cfeb3_rxd		(clock_cfeb_rxd[3]),		// Out	40MHz CFEB receive  data clock 1x
	.clock_cfeb4_rxd		(clock_cfeb_rxd[4]),		// Out	40MHz CFEB receive  data clock 1x

// Global reset
	.global_reset_en		(global_reset_en),			// In	Enable global reset on lock_lost
	.global_reset			(global_reset),				// Out	Global reset
	.clock_lock_lost_err	(clock_lock_lost_err),		// Out	40MHz main clock lost lock

// Clock DCM lock status
	.lock_tmb_clock0		(lock_tmb_clock0),			// Out	DCM lock status
	.lock_tmb_clock0d		(lock_tmb_clock0d),			// Out	DCM lock status
	.lock_alct_rxclockd		(lock_alct_rxclockd),		// Out	DCM lock status
	.lock_mpc_clock			(lock_mpc_clock),			// Out	DCM lock status
	.lock_dcc_clock			(lock_dcc_clock),			// Out	DCM lock status
	.lock_rpc_rxalt1		(lock_rpc_rxalt1),			// Out	DCM lock status
	.lock_tmb_clock1		(lock_tmb_clock1),			// Out	DCM lock status
	.lock_alct_rxclock		(lock_alct_rxclock),		// Out	DCM lock status
	.clock_ctrl_sump		(clock_ctrl_sump),			// Out	Unused signals

// Phaser VME control/status ports
	.dps_fire				(dps_fire[6:0]),			// In	Set new phase
	.dps_reset				(dps_reset[6:0]),			// In	VME Reset current phase
	.dps_busy				(dps_busy[6:0]),			// Out	Phase shifter busy
	.dps_lock				(dps_lock[6:0]),			// Out	PLL lock status

	.dps0_phase				(dps0_phase[7:0]),			// In	Phase to set, 0-255
	.dps1_phase				(dps1_phase[7:0]),			// In	Phase to set, 0-255
	.dps2_phase				(dps2_phase[7:0]),			// In	Phase to set, 0-255
	.dps3_phase				(dps3_phase[7:0]),			// In	Phase to set, 0-255
	.dps4_phase				(dps4_phase[7:0]),			// In	Phase to set, 0-255
	.dps5_phase				(dps5_phase[7:0]),			// In	Phase to set, 0-255
	.dps6_phase				(dps6_phase[7:0]),			// In	Phase to set, 0-255

	.dps0_sm_vec			(dps0_sm_vec[2:0]),			// Out	Phase shifter machine state
	.dps1_sm_vec			(dps1_sm_vec[2:0]),			// Out	Phase shifter machine state
	.dps2_sm_vec			(dps2_sm_vec[2:0]),			// Out	Phase shifter machine state
	.dps3_sm_vec			(dps3_sm_vec[2:0]),			// Out	Phase shifter machine state
	.dps4_sm_vec			(dps4_sm_vec[2:0]),			// Out	Phase shifter machine state
	.dps5_sm_vec			(dps5_sm_vec[2:0]),			// Out	Phase shifter machine state
	.dps6_sm_vec			(dps6_sm_vec[2:0])			// Out	Phase shifter machine state
	);

//------------------------------------------------------------------------------------------------------------------
//	CCB Instantiation
//-------------------------------------------------------------------------------------------------------------------
// CCB Arrays
	wire	[8:0]	clct_status;
	wire	[8:0]	alct_status;
	wire	[5:0]	alct_state;
	wire	[7:0]	ccb_cmd;
	wire	[4:0]	ccb_reserved;
	wire	[1:0]	tmb_reserved;
	wire	[4:0]	tmb_reserved_in;
	wire	[2:0]	tmb_reserved_out;
	wire	[2:0]	dmb_cfeb_calibrate;
	wire	[4:0]	dmb_reserved_out;
	wire	[2:0]	dmb_reserved_in;
	wire	[5:0]	dmb_rx_ff;
	wire	[7:0]	l1a_delay_vme;
	wire	[7:0]	vme_ccb_cmd;
	wire	[2:0]	fmm_state;
	wire	[7:0]			ccb_ttcrx_lost_cnt;
	wire	[7:0]			ccb_qpll_lost_cnt;
	wire	[MXMPCRX-1:0]	_mpc_rx;					// Received by ccb GTL chip, passed to TMB section
	wire	[MXBXN-1:0]		lhc_cycle;

// CCB Local
	wire	alct_vpf_tp;
	wire	clct_vpf_tp;
	wire	scint_veto;

// CCB Front panel ECL outputs: ALCT shares with TMB signals
	assign alct_status[5:0]	=	alct_state[5:0];		// ALCT status signals
	assign alct_status[6]	=	alct_vpf_tp;			// TMB ALCT Valid pattern flag
	assign alct_status[7]	=	clct_vpf_tp;			// TMB CLCT Valid pattern flag
	assign alct_status[8]	=	scint_veto;				// Fast Site scintillator veto

// CCB Instantiation
	ccb uccb
	(
// CCB I/O
	.clock					(clock),					// In	40MHz clock without DDD delay
	.global_reset			(global_reset),				// In	Global reset
	._ccb_rx				(_ccb_rx[50:0]),			// In	GTLP data from CCB, inverted
	._ccb_tx				(_ccb_tx[26:0]),			// Out	GTLP data to   CCB, inverted

// VME Control Ports
	.ccb_ignore_rx			(ccb_ignore_rx),			// In	Ignore CCB backplane inputs
	.ccb_allow_ext_bypass	(ccb_allow_ext_bypass),		// In	1=Allow clct_ext_trigger_ccb even if ccb_ignore_rx=1
	.ccb_disable_tx			(ccb_disable_tx),			// In	Disable CCB backplane outputs
	.ccb_int_l1a_en			(ccb_int_l1a_en),			// In	1=Enable CCB internal l1a emulator
	.ccb_ignore_startstop	(ccb_ignore_startstop),		// In	1=ignore ttc trig_start/stop commands
	.alct_status_en			(alct_status_en),			// In	1=Enable status GTL outputs for alct
	.clct_status_en			(clct_status_en),			// In	1=Enable status GTL outputs for clct
	.gtl_loop_lcl			(gtl_loop_lcl),				// In	1=Enable gtl loop mode
	.ccb_status_oe_lcl		(ccb_status_oe_lcl),		// In	1=Enable status GTL outputs
	.lhc_cycle				(lhc_cycle[MXBXN-1:0]),		// In	LHC period, max BXN count+1

// TMB signals transmitted to CCB
	.clct_status			(clct_status[8:0]),			// In	CLCT status for CCB front panel (VME sets status_oe)
	.alct_status			(alct_status[8:0]),			// In	ALCT status for CCB front panel
	.tmb_cfg_done			(tmb_cfg_done),				// In	FPGA loaded
	.alct_cfg_done			(alct_cfg_done),			// In	FPGA loaded
	.tmb_reserved_in		(tmb_reserved_in[4:0]),		// In	Unassigned

// TTC Command Word
	.ccb_cmd				(ccb_cmd[7:0]),				// Out	CCB command word
	.ccb_cmd_strobe			(ccb_cmd_strobe),			// Out	CCB command word strobe
	.ccb_data_strobe		(ccb_data_strobe),			// Out	CCB data word strobe
	.ccb_subaddr_strobe		(ccb_subaddr_strobe),		// Out	CCB subaddress strobe

// TMB signals received from CCB
	.ccb_clock40_enable		(ccb_clock40_enable),		// Out	Enable 40MHz clock
	.ccb_reserved			(ccb_reserved[4:0]),		// Out	Unassigned
	.ccb_evcntres			(ccb_evcntres),				// Out	Event counter reset
	.ccb_bcntres			(ccb_bcntres),				// Out	Bunch crossing counter reset
	.ccb_bx0				(ccb_bx0),					// Out	Bunch crossing zero
	.ccb_l1accept			(ccb_l1accept),				// Out	Level 1 Accept
	.tmb_hard_reset			(tmb_hard_reset	),			// Out	Reload TMB  FPGA
	.alct_hard_reset		(alct_hard_reset),			// Out	Reload ALCT FPGA
	.tmb_reserved			(tmb_reserved[1:0]),		// Out	Unassigned
	.alct_adb_pulse_sync	(alct_adb_pulse_sync),		// Out	ALCT synchronous  test pulse
	.alct_adb_pulse_async	(alct_adb_pulse_async),		// Out	ALCT asynchronous test pulse
	.clct_ext_trig			(clct_ext_trig),			// Out	CLCT external trigger
	.alct_ext_trig			(alct_ext_trig),			// Out	ALCT external trigger
	.dmb_ext_trig			(dmb_ext_trig),				// Out	DMB  external trigger
	.tmb_reserved_out		(tmb_reserved_out[2:0]),	// Out	Unassigned
	.ccb_sump				(ccb_sump),					// Out	Unused signals

// Monitored DMB Signals
	.dmb_cfeb_calibrate		(dmb_cfeb_calibrate[2:0]),	// Out	DMB calibration
	.dmb_l1a_release		(dmb_l1a_release),			// Out	DMB test
	.dmb_reserved_out		(dmb_reserved_out[4:0]),	// Out	DMB unassigned
	.dmb_reserved_in		(dmb_reserved_in[2:0]),		// Out	DMB unassigned

// DMB Received
	.dmb_rx					(dmb_rx[5:0]),				// In	DMB Received data
	.dmb_rx_ff				(dmb_rx_ff[5:0]),			// Out	DMB latched for VME

// MPC GTL Received data
	.mpc_in					(_mpc_rx[1:0]),				// Out	MPC muon accept reply, 80MHz

// Level 1 Accept Ports from VME and Sequencer
	.clct_ext_trig_l1aen	(clct_ext_trig_l1aen),		// In	1=Request ccb l1a on clct ext_trig
	.alct_ext_trig_l1aen	(alct_ext_trig_l1aen),		// In	1=Request ccb l1a on alct ext_trig
	.seq_trig_l1aen			(seq_trig_l1aen),			// In	1=Request ccb l1a on sequencer trigger
	.seq_trigger			(seq_trigger),				// In	Sequencer requests L1A from CCB

// Trigger Ports from VME
	.alct_ext_trig_vme		(alct_ext_trig_vme),		// In	1=Fire alct_ext_trig oneshot
	.clct_ext_trig_vme		(clct_ext_trig_vme),		// In	1=Fire clct_ext_trig oneshot
	.ext_trig_both			(ext_trig_both),			// In	1=clct_ext_trig fires alct and alct fires clct_trig, DC level
	.l1a_vme				(l1a_vme),					// In	1=fire ccb_l1accept oneshot
	.l1a_delay_vme			(l1a_delay_vme[7:0]),		// In	Internal L1A delay
	.l1a_inj_ram			(l1a_inj_ram),				// In	L1A injector RAM pulse
	.l1a_inj_ram_en			(l1a_inj_ram_en),			// In	L1A injector RAM enable
	.inj_ramout_busy		(inj_ramout_busy),			// In	Injector RAM busy

// TTC Decoded Commands
	.ttc_bx0				(ttc_bx0),					// Out	Bunch crossing zero
	.ttc_resync				(ttc_resync),				// Out	TTC resync
	.ttc_bxreset			(ttc_bxreset),				// Out	Reset bxn
	.ttc_mpc_inject			(ttc_mpc_inject),			// Out	Start MPC injector
	.ttc_orbit_reset		(ttc_orbit_reset),			// Out	Reset orbit counter
	.fmm_trig_stop			(fmm_trig_stop),			// Out	Stop clct trigger sequencer

// VME
	.vme_ccb_cmd_enable		(vme_ccb_cmd_enable),		// In	Disconnect ccb_cmd_bpl, use vme_ccb_cmd;
	.vme_ccb_cmd			(vme_ccb_cmd[7:0]),			// In	CCB command word
	.vme_ccb_cmd_strobe		(vme_ccb_cmd_strobe),		// In	CCB command word strobe
	.vme_ccb_data_strobe	(vme_ccb_data_strobe),		// In	CCB data word strobe
	.vme_ccb_subaddr_strobe	(vme_ccb_subaddr_strobe),	// In	CCB subaddress strobe
	.vme_evcntres			(vme_evcntres),				// In	Event counter reset, from VME
	.vme_bcntres			(vme_bcntres),				// In	Bunch crossing counter reset, from VME
	.vme_bx0				(vme_bx0),					// In	Bunch crossing zero, from VME
	.vme_bx0_emu_en			(vme_bx0_emu_en),			// In	BX0 emulator enable
	.fmm_state				(fmm_state[2:0]),			// Out	FMM machine state

//	CCB TTC lock status
	.cnt_all_reset			(cnt_all_reset),			// In	Trigger/Readout counter reset
	.ccb_ttcrx_lock_never	(ccb_ttcrx_lock_never),		// Out	Lock never achieved
	.ccb_ttcrx_lost_ever	(ccb_ttcrx_lost_ever),		// Out	Lock was lost at least once
	.ccb_ttcrx_lost_cnt		(ccb_ttcrx_lost_cnt[7:0]),	// Out	Number of times lock has been lost
	.ccb_qpll_lock_never	(ccb_qpll_lock_never),		// Out	Lock never achieved
	.ccb_qpll_lost_ever		(ccb_qpll_lost_ever),		// Out	Lock was lost at least once
	.ccb_qpll_lost_cnt		(ccb_qpll_lost_cnt[7:0])	// Out	Number of times lock has been lost
	);

//-------------------------------------------------------------------------------------------------------------------
//	ALCT Instantiation
//-------------------------------------------------------------------------------------------------------------------
// Local
	wire	[MXALCT-1:0]	alct0_tmb;
	wire	[MXALCT-1:0]	alct1_tmb;
	wire	[15:0]			alct0_vme;
	wire	[15:0]			alct1_vme;
	wire	[18:0]			alct_dmb;
	wire	[4:0]			bxn_alct_vme;			// ALCT bxn on last alct valid pattern flag
	wire	[1:0]			alct_ecc_err;			// ALCT ecc syndrome code
	wire	[3:0]			alct_seq_cmd;
	wire	[55:0]			scp_alct_rx;
	wire	[3:0]			alct_txd_int_delay;
	wire	[4:0]			alct_inj_delay;
	wire	[15:0]			alct0_inj;			
	wire	[15:0]			alct1_inj;

// VME ALCT sync mode ports
	wire	[28:1]			alct_sync_rxdata_1st;	// Demux data for demux timing-in
	wire	[28:1]			alct_sync_rxdata_2nd;	// Demux data for demux timing-in
	wire	[28:1]			alct_sync_expect_1st;	// Expected demux data for demux timing-in
	wire	[28:1]			alct_sync_expect_2nd;	// Expected demux data for demux timing-in
	wire	[1:0]			alct_sync_ecc_err;		// ALCT sync mode ecc error syndrome

	wire	[9:0]			alct_sync_txdata_1st;	// ALCT sync mode data to send for loopback
	wire	[9:0]			alct_sync_txdata_2nd;	// ALCT sync mode data to send for loopback
	wire	[3:0]			alct_sync_rxdata_dly;	// ALCT sync mode delay pointer to valid data
	wire	[3:0]			alct_sync_rxdata_pre;	// ALCT sync mode delay pointer to valid data, fixed pre-delay

	wire	[MXARAMADR-1:0]	alct_raw_radr;
	wire	[MXARAMDATA-1:0]alct_raw_rdata;
	wire	[MXARAMADR-1:0]	alct_raw_wdcnt;

// ALCT Event Counters
	wire	[MXCNTVME-1:0]	event_counter0;
	wire	[MXCNTVME-1:0]	event_counter1;
	wire	[MXCNTVME-1:0]	event_counter2;
	wire	[MXCNTVME-1:0]	event_counter3;
	wire	[MXCNTVME-1:0]	event_counter4;
	wire	[MXCNTVME-1:0]	event_counter5;
	wire	[MXCNTVME-1:0]	event_counter6;
	wire	[MXCNTVME-1:0]	event_counter7;
	wire	[MXCNTVME-1:0]	event_counter8;
	wire	[MXCNTVME-1:0]	event_counter9;
	wire	[MXCNTVME-1:0]	event_counter10;
	wire	[MXCNTVME-1:0]	event_counter11;
	wire	[MXCNTVME-1:0]	event_counter12;

// TMB Event Counters
	wire	[MXCNTVME-1:0]	event_counter13;
	wire	[MXCNTVME-1:0]	event_counter14;
	wire	[MXCNTVME-1:0]	event_counter15;
	wire	[MXCNTVME-1:0]	event_counter16;
	wire	[MXCNTVME-1:0]	event_counter17;
	wire	[MXCNTVME-1:0]	event_counter18;
	wire	[MXCNTVME-1:0]	event_counter19;
	wire	[MXCNTVME-1:0]	event_counter20;
	wire	[MXCNTVME-1:0]	event_counter21;
	wire	[MXCNTVME-1:0]	event_counter22;
	wire	[MXCNTVME-1:0]	event_counter23;
	wire	[MXCNTVME-1:0]	event_counter24;
	wire	[MXCNTVME-1:0]	event_counter25;
	wire	[MXCNTVME-1:0]	event_counter26;
	wire	[MXCNTVME-1:0]	event_counter27;
	wire	[MXCNTVME-1:0]	event_counter28;
	wire	[MXCNTVME-1:0]	event_counter29;
	wire	[MXCNTVME-1:0]	event_counter30;
	wire	[MXCNTVME-1:0]	event_counter31;
	wire	[MXCNTVME-1:0]	event_counter32;
	wire	[MXCNTVME-1:0]	event_counter33;
	wire	[MXCNTVME-1:0]	event_counter34;
	wire	[MXCNTVME-1:0]	event_counter35;
	wire	[MXCNTVME-1:0]	event_counter36;
	wire	[MXCNTVME-1:0]	event_counter37;
	wire	[MXCNTVME-1:0]	event_counter38;
	wire	[MXCNTVME-1:0]	event_counter39;
	wire	[MXCNTVME-1:0]	event_counter40;
	wire	[MXCNTVME-1:0]	event_counter41;
	wire	[MXCNTVME-1:0]	event_counter42;
	wire	[MXCNTVME-1:0]	event_counter43;
	wire	[MXCNTVME-1:0]	event_counter44;
	wire	[MXCNTVME-1:0]	event_counter45;
	wire	[MXCNTVME-1:0]	event_counter46;
	wire	[MXCNTVME-1:0]	event_counter47;
	wire	[MXCNTVME-1:0]	event_counter48;
	wire	[MXCNTVME-1:0]	event_counter49;
	wire	[MXCNTVME-1:0]	event_counter50;
	wire	[MXCNTVME-1:0]	event_counter51;
	wire	[MXCNTVME-1:0]	event_counter52;
	wire	[MXCNTVME-1:0]	event_counter53;
	wire	[MXCNTVME-1:0]	event_counter54;
	wire	[MXCNTVME-1:0]	event_counter55;
	wire	[MXCNTVME-1:0]	event_counter56;
	wire	[MXCNTVME-1:0]	event_counter57;
	wire	[MXCNTVME-1:0]	event_counter58;
	wire	[MXCNTVME-1:0]	event_counter59;
	wire	[MXCNTVME-1:0]	event_counter60;
	wire	[MXCNTVME-1:0]	event_counter61;
	wire	[MXCNTVME-1:0]	event_counter62;
	wire	[MXCNTVME-1:0]	event_counter63;
	wire	[MXCNTVME-1:0]	event_counter64;
	wire	[MXCNTVME-1:0]	event_counter65;

// ALCT Structure Error Counters
	wire	[7:0]			alct_err_counter0;			// Error counter 1D remap
	wire	[7:0]			alct_err_counter1;
	wire	[7:0]			alct_err_counter2;
	wire	[7:0]			alct_err_counter3;
	wire	[7:0]			alct_err_counter4;
	wire	[7:0]			alct_err_counter5;

// CLCT pre-trigger coincidence counters
  wire  [MXCNTVME-1:0] preClct_l1a_counter;  // CLCT pre-trigger AND L1A coincidence counter
  wire  [MXCNTVME-1:0] preClct_alct_counter; // CLCT pre-trigger AND ALCT coincidence counter

// Active CFEB(s) counters
  wire  [MXCNTVME-1:0] active_cfebs_event_counter;      // Any CFEB active flag sent to DMB
  wire  [MXCNTVME-1:0] active_cfeb0_event_counter;      // CFEB0 active flag sent to DMB
  wire  [MXCNTVME-1:0] active_cfeb1_event_counter;      // CFEB1 active flag sent to DMB
  wire  [MXCNTVME-1:0] active_cfeb2_event_counter;      // CFEB2 active flag sent to DMB
  wire  [MXCNTVME-1:0] active_cfeb3_event_counter;      // CFEB3 active flag sent to DMB
  wire  [MXCNTVME-1:0] active_cfeb4_event_counter;      // CFEB4 active flag sent to DMB

  wire  [MXCNTVME-1:0] bx0_match_counter;      // ALCT CLCT bx0 match counter
// CFEB injector RAM map 2D arrays into 1D for ALCT
	wire	[MXCFEB-1:0]	inj_ramout_pulse;
	assign inj_ramout_busy=|inj_ramout_pulse;

	wire	[5:0]			inj_ramout [MXCFEB-1:0];
	wire	[29:0]			inj_ramout_mux;

	assign inj_ramout_mux[5:0]   = inj_ramout[0][5:0];
	assign inj_ramout_mux[11:6]  = inj_ramout[1][5:0];
	assign inj_ramout_mux[17:12] = inj_ramout[2][5:0];
	assign inj_ramout_mux[23:18] = inj_ramout[3][5:0];
	assign inj_ramout_mux[29:24] = inj_ramout[4][5:0];

// ALCT Injectors
	wire	[10:0]			alct0_inj_ram = inj_ramout_mux[10:0];	// Injector RAM ALCT0
	wire	[10:0]			alct1_inj_ram = inj_ramout_mux[21:11];	// Injector RAM ALCT1
	wire	[4:0]			alctb_inj_ram = inj_ramout_mux[26:22];	// Injector RAM ALCT bxn
	assign					l1a_inj_ram   = inj_ramout_mux[27];		// Injector RAM L1A
	wire					inj_ram_sump  =|inj_ramout_mux[29:28]; 	// Injector RAM unused

	wire alct_ext_inject = alct_ext_trig;				// CCB failed to implement this signal

	alct ualct
	(
// Clock Ports
	.clock					(clock), 					// In	40MHz TMB system clock
	.clock_lac				(clock_lac),				// In	40MHz logic accessible clock
	.clock_2x				(clock_2x),					// In	80MHz commutator clock

// Phase delayed clocks
	.clock_alct_rxd			(clock_alct_rxd),			// In	ALCT rxd  40 MHz clock
	.clock_alct_txd			(clock_alct_txd),			// In	ALCT txd  40 MHz clock
	.alct_rxd_posneg		(alct_rxd_posneg),			// In	Select inter-stage clock 0 or 180 degrees
	.alct_txd_posneg		(alct_txd_posneg),			// In	Select inter-stage clock 0 or 180 degrees

// Global resets
	.global_reset			(global_reset),				// In	Global reset
	.ttc_resync				(ttc_resync),				// In	TTC resync

// ALCT Ports
	.alct_rx				(alct_rx[28:1]),			// In	80MHz LVDS inputs  from ALCT, alct_rx[0] is JTAG TDO, non-mux'd
	.alct_txa				(alct_txa[17:5]),			// Out	80MHz LVDS outputs
	.alct_txb				(alct_txb[23:19]),			// Out	80MHz LVDS outputs

// TTC Command Word
	.ccb_cmd				(ccb_cmd[7:0]),				// In	TTC command word
	.ccb_cmd_strobe			(ccb_cmd_strobe),			// In	TTC command valid
	.ccb_data_strobe		(ccb_data_strobe),			// In	TTC data valid
	.ccb_subaddr_strobe		(ccb_subaddr_strobe),		// In	TTC sub-addr valid

// CCB Ports
	.ccb_bx0				(ccb_bx0),					// In	TTC bx0
	.alct_ext_inject		(alct_ext_inject),			// In	External inject
	.alct_ext_trig			(alct_ext_trig),			// In	External trigger
	.ccb_l1accept			(ccb_l1accept),				// In	L1A
	.ccb_evcntres			(ccb_evcntres),				// In	Event counter reset
	.alct_adb_pulse_sync	(alct_adb_pulse_sync),		// In	Synchronous test pulse (asyn pulse is on PCB)
	.alct_cfg_done			(alct_cfg_done),			// Out	ALCT reports FPGA configuration done
	.alct_state				(alct_state[5:0]),			// Out	ALCT state for CCB front panel ECL outputs

// Sequencer Ports
	.alct_active_feb		(alct_active_feb),			// Out	ALCT has an active FEB
	.alct0_valid			(alct0_valid),				// Out	ALCT has valid LCT
	.alct1_valid			(alct1_valid),				// Out	ALCT has valid LCT
	.alct_dmb				(alct_dmb[18:0]),			// Out	ALCT to DMB
	.read_sm_xdmb			(read_sm_xdmb),				// In	TMB sequencer starting a readout

// TMB Ports
	.alct0_tmb				(alct0_tmb[MXALCT-1:0]),	// Out	ALCT best muon
	.alct1_tmb				(alct1_tmb[MXALCT-1:0]),	// Out	ALCT second best muon
	.alct_bx0_rx			(alct_bx0_rx),				// Out	ALCT bx0 received
	.alct_ecc_err			(alct_ecc_err[1:0]),		// Out	ALCT ecc syndrome code
	.alct_ecc_rx_err		(alct_ecc_rx_err),			// Out	ALCT uncorrected ECC error in data ALCT received from TMB
	.alct_ecc_tx_err		(alct_ecc_tx_err),			// Out	ALCT uncorrected ECC error in data ALCT transmitted to TMB

// VME Ports
	.alct_ecc_en			(alct_ecc_en),					// In	Enable ALCT ECC decoder, else do no ECC correction
	.alct_ecc_err_blank		(alct_ecc_err_blank),			// In	Blank alcts with uncorrected ecc errors
	.alct_txd_int_delay		(alct_txd_int_delay[3:0]),		// In	ALCT data transmit delay, integer bx
	.alct_clock_en_vme		(alct_clock_en_vme),			// In	Enable ALCT 40MHz clock
	.alct_seq_cmd			(alct_seq_cmd[3:0]),			// In	ALCT Sequencer command
	.event_clear_vme		(event_clear_vme),				// In	Event clear for aff,alct,clct,mpc vme diagnostic registers
	.alct0_vme				(alct0_vme[15:0]),				// Out	LCT latched last valid pattern
	.alct1_vme				(alct1_vme[15:0]),				// Out	LCT latched last valid pattern
	.bxn_alct_vme			(bxn_alct_vme),					// Out	ALCT bxn on last alct valid pattern flag

// VME ALCT sync mode ports
	.alct_sync_txdata_1st	(alct_sync_txdata_1st[9:0]),	// In	ALCT sync mode data to send for loopback
	.alct_sync_txdata_2nd	(alct_sync_txdata_2nd[9:0]),	// In	ALCT sync mode data to send for loopback
	.alct_sync_rxdata_dly	(alct_sync_rxdata_dly[3:0]),	// In	ALCT sync mode delay pointer to valid data
	.alct_sync_rxdata_pre	(alct_sync_rxdata_pre[3:0]),	// In	ALCT sync mode delay pointer to valid data, fixed pre-delay
	.alct_sync_tx_random	(alct_sync_tx_random),			// In	ALCT sync mode tmb transmits random data to alct
	.alct_sync_clr_err		(alct_sync_clr_err),			// In	ALCT sync mode clear rng error FFs

	.alct_sync_1st_err		(alct_sync_1st_err),			// Out	ALCT sync mode 1st-intime match ok, alct-to-tmb
	.alct_sync_2nd_err		(alct_sync_2nd_err),			// Out	ALCT sync mode 2nd-intime match ok, alct-to-tmb
	.alct_sync_1st_err_ff	(alct_sync_1st_err_ff),			// Out	ALCT sync mode 1st-intime match ok, alct-to-tmb, latched
	.alct_sync_2nd_err_ff	(alct_sync_2nd_err_ff),			// Out	ALCT sync mode 2nd-intime match ok, alct-to-tmb, latched
	.alct_sync_ecc_err		(alct_sync_ecc_err[1:0]),		// Out	ALCT sync mode ecc error syndrome

	.alct_sync_rxdata_1st	(alct_sync_rxdata_1st[28:1]),	// Out	Demux data for demux timing-in
	.alct_sync_rxdata_2nd	(alct_sync_rxdata_2nd[28:1]),	// Out	Demux data for demux timing-in
	.alct_sync_expect_1st	(alct_sync_expect_1st[28:1]),	// Out	Expected demux data for demux timing-in
	.alct_sync_expect_2nd	(alct_sync_expect_2nd[28:1]),	// Out	Expected demux data for demux timing-in

// VME ALCT Raw hits RAM Ports
	.alct_raw_reset			(alct_raw_reset),					// In	Reset raw hits write address and done flag
	.alct_raw_radr			(alct_raw_radr[MXARAMADR-1:0]),		// In	Raw hits RAM VME read address
	.alct_raw_rdata			(alct_raw_rdata[MXARAMDATA-1:0]),	// Out	Raw hits RAM VME read data
	.alct_raw_busy			(alct_raw_busy),					// Out	Raw hits RAM VME busy writing ALCT data
	.alct_raw_done			(alct_raw_done),					// Out	Raw hits ready for VME readout
	.alct_raw_wdcnt			(alct_raw_wdcnt[MXARAMADR-1:0]),	// Out	ALCT word count stored in FIFO

// TMB Control Ports
	.cfg_alct_ext_trig_en	(cfg_alct_ext_trig_en),			// In	1=Enable alct_ext_trig   from CCB
	.cfg_alct_ext_inject_en	(cfg_alct_ext_inject_en),		// In	1=Enable alct_ext_inject from CCB
	.cfg_alct_ext_trig		(cfg_alct_ext_trig),			// In	1=Assert alct_ext_trig
	.cfg_alct_ext_inject	(cfg_alct_ext_inject),			// In	1=Assert alct_ext_inject
	.alct_clear				(alct_clear),					// In	1=Blank alct_rx inputs
	.alct_inject			(alct_inject),					// In	1=Start ALCT injector
	.alct_inj_ram_en		(alct_inj_ram_en),				// In	1=Link  ALCT injector to CFEB injector RAM
	.alct_inj_delay			(alct_inj_delay[4:0]),			// In	ALCT Injector delay	
	.alct0_inj				(alct0_inj[15:0]),				// In	ALCT0 to inject				
	.alct1_inj				(alct1_inj[15:0]),				// In	ALCT1 to inject
	.alct0_inj_ram			(alct0_inj_ram[10:0]),			// In	Injector RAM ALCT0
	.alct1_inj_ram			(alct1_inj_ram[10:0]),			// In	Injector RAM ALCT1
	.alctb_inj_ram			(alctb_inj_ram[4:0]),			// In	Injector RAM ALCT bxn
	.inj_ramout_busy		(inj_ramout_busy),				// In	Injector RAM busy

// Trigger/Readout Counter Ports
	.cnt_all_reset			(cnt_all_reset),				// In	Trigger/Readout counter reset
	.cnt_stop_on_ovf		(cnt_stop_on_ovf),				// In	Stop all counters if any overflows
	.cnt_alct_debug			(cnt_alct_debug),				// In	Enable ALCT debug lct error counter
	.cnt_any_ovf_alct		(cnt_any_ovf_alct),				// Out	At least one alct counter overflowed
	.cnt_any_ovf_seq		(cnt_any_ovf_seq),				// In	At least one sequencer counter overflowed

	.event_counter0			(event_counter0[MXCNTVME-1:0]),	// Out	Event counters
	.event_counter1			(event_counter1[MXCNTVME-1:0]),	// Out
	.event_counter2			(event_counter2[MXCNTVME-1:0]),	// Out
	.event_counter3			(event_counter3[MXCNTVME-1:0]),	// Out
	.event_counter4			(event_counter4[MXCNTVME-1:0]),	// Out
	.event_counter5			(event_counter5[MXCNTVME-1:0]),	// Out
	.event_counter6			(event_counter6[MXCNTVME-1:0]),	// Out
	.event_counter7			(event_counter7[MXCNTVME-1:0]),	// Out
	.event_counter8			(event_counter8[MXCNTVME-1:0]),	// Out
	.event_counter9			(event_counter9[MXCNTVME-1:0]),	// Out
	.event_counter10		(event_counter10[MXCNTVME-1:0]),// Out
	.event_counter11		(event_counter11[MXCNTVME-1:0]),// Out
	.event_counter12		(event_counter12[MXCNTVME-1:0]),// Out

// ALCT Structure Error Counters
	.alct_err_counter0		(alct_err_counter0[7:0]),		// Out	Error counter 1D remap
	.alct_err_counter1		(alct_err_counter1[7:0]),		// Out
	.alct_err_counter2		(alct_err_counter2[7:0]),		// Out
	.alct_err_counter3		(alct_err_counter3[7:0]),		// Out
	.alct_err_counter4		(alct_err_counter4[7:0]),		// Out
	.alct_err_counter5		(alct_err_counter5[7:0]),		// Out

// Test Points
	.alct_wr_fifo_tp		(alct_wr_fifo_tp),				// Out	ALCT is writing to FIFO
	.alct_first_frame_tp	(alct_first_frame_tp),			// Out	ALCT first frame flag
	.alct_last_frame_tp		(alct_last_frame_tp),			// Out	ALCT last frame flag
	.alct_crc_err_tp		(alct_crc_err_tp),				// Out	AKCT CRC Error test point for oscope trigger
	.scp_alct_rx			(scp_alct_rx[55:0]),			// Out	ALCT received signals to scope

// Sump
	.alct_sump				(alct_sump)						// Out	Unused signals
	);

//-------------------------------------------------------------------------------------------------------------------
//	Common to all CFEBs
//-------------------------------------------------------------------------------------------------------------------
// CFEBs Instantiated
	wire [MXCFEB-1:0]	cfeb_exists;

// CFEB digital phase shifters
	wire [3:0]		  cfeb_rxd_int_delay [MXCFEB-1:0];			// Interstage delay
	wire [MXCFEB-1:0] cfeb_rxd_posneg;
	wire			  cfeb0_rxd_posneg;
	wire			  cfeb1_rxd_posneg;
	wire			  cfeb2_rxd_posneg;
	wire			  cfeb3_rxd_posneg;
	wire			  cfeb4_rxd_posneg;

	assign cfeb_rxd_posneg[0] = cfeb0_rxd_posneg;
	assign cfeb_rxd_posneg[1] = cfeb1_rxd_posneg;
	assign cfeb_rxd_posneg[2] = cfeb2_rxd_posneg;
	assign cfeb_rxd_posneg[3] = cfeb3_rxd_posneg;
	assign cfeb_rxd_posneg[4] = cfeb4_rxd_posneg;

// CFEB raw hits arrays
	wire [MXMUX-1:0] cfeb_rx [MXCFEB-1:0];
	
	assign cfeb_rx[0][MXMUX-1:0] = cfeb0_rx[MXMUX-1:0];
	assign cfeb_rx[1][MXMUX-1:0] = cfeb1_rx[MXMUX-1:0];
	assign cfeb_rx[2][MXMUX-1:0] = cfeb2_rx[MXMUX-1:0];
	assign cfeb_rx[3][MXMUX-1:0] = cfeb3_rx[MXMUX-1:0];
	assign cfeb_rx[4][MXMUX-1:0] = cfeb4_rx[MXMUX-1:0];

// Injector Ports
	wire	[MXCFEB-1:0]	mask_all;
	wire	[MXCFEB-1:0]	inj_febsel;
	wire	[MXCFEB-1:0]	injector_go_cfeb;
	wire	[11:0]			inj_last_tbin;
	wire	[2:0]			inj_wen;
	wire	[9:0]			inj_rwadr;
	wire	[17:0]			inj_wdata;
	wire	[2:0]			inj_ren;

// Raw Hits FIFO RAM Ports
	wire					fifo_wen;
	wire	[RAM_ADRB-1:0]	fifo_wadr;						// FIFO RAM write address
	wire	[RAM_ADRB-1:0]	fifo_radr_cfeb;					// FIFO RAM read tbin address
	wire	[2:0]			fifo_sel_cfeb;					// FIFO RAM read layer address 0-5
	wire	[RAM_WIDTH-1:0] fifo_rdata [MXCFEB-1:0];		// FIFO RAM read data

// Hot Channel Masks
	wire	[MXDS-1:0]		cfeb_ly0_hcm [MXCFEB-1:0];		// 1=enable DiStrip
	wire	[MXDS-1:0]		cfeb_ly1_hcm [MXCFEB-1:0];		// 1=enable DiStrip
	wire	[MXDS-1:0]		cfeb_ly2_hcm [MXCFEB-1:0];		// 1=enable DiStrip
	wire	[MXDS-1:0]		cfeb_ly3_hcm [MXCFEB-1:0];		// 1=enable DiStrip
	wire	[MXDS-1:0]		cfeb_ly4_hcm [MXCFEB-1:0];		// 1=enable DiStrip
	wire	[MXDS-1:0]		cfeb_ly5_hcm [MXCFEB-1:0];		// 1=enable DiStrip

// Bad CFEB rx bit detection
	wire	[MXCFEB-1:0]	cfeb_badbits_reset;				// Reset bad cfeb bits FFs
	wire	[MXCFEB-1:0]	cfeb_badbits_block;				// Allow bad bits to block triads
	wire	[MXCFEB-1:0]	cfeb_badbits_found;				// CFEB[n] has at least 1 bad bit
	wire	[15:0]			cfeb_badbits_nbx;				// Cycles a bad bit must be continuously high
	wire	[MXDS*MXLY-1:0]	cfeb_blockedbits[MXCFEB-1:0];	// 1=CFEB rx bit blocked by hcm or went bad, packed

	wire	[MXDS-1:0]		cfeb_ly0_badbits[MXCFEB-1:0];	// 1=CFEB rx bit went bad
	wire	[MXDS-1:0]		cfeb_ly1_badbits[MXCFEB-1:0];	// 1=CFEB rx bit went bad
	wire	[MXDS-1:0]		cfeb_ly2_badbits[MXCFEB-1:0];	// 1=CFEB rx bit went bad
	wire	[MXDS-1:0]		cfeb_ly3_badbits[MXCFEB-1:0];	// 1=CFEB rx bit went bad
	wire	[MXDS-1:0]		cfeb_ly4_badbits[MXCFEB-1:0];	// 1=CFEB rx bit went bad
	wire	[MXDS-1:0]		cfeb_ly5_badbits[MXCFEB-1:0];	// 1=CFEB rx bit went bad

// Triad Decoder Ports
	wire	[3:0]			triad_persist;
	wire	[MXCFEB-1:0]	triad_skip;
	wire					triad_clr;

// Triad Decoder Outputs
	wire	[MXHS-1:0]		cfeb_ly0hs [MXCFEB-1:0];		// Decoded 1/2-strip pulses
	wire	[MXHS-1:0]		cfeb_ly1hs [MXCFEB-1:0];		// Decoded 1/2-strip pulses
	wire	[MXHS-1:0]		cfeb_ly2hs [MXCFEB-1:0];		// Decoded 1/2-strip pulses
	wire	[MXHS-1:0]		cfeb_ly3hs [MXCFEB-1:0];		// Decoded 1/2-strip pulses
	wire	[MXHS-1:0]		cfeb_ly4hs [MXCFEB-1:0];		// Decoded 1/2-strip pulses
	wire	[MXHS-1:0]		cfeb_ly5hs [MXCFEB-1:0];		// Decoded 1/2-strip pulses

// Status Ports
	wire	[MXCFEB-1:0]	demux_tp_1st;
	wire	[MXCFEB-1:0]	demux_tp_2nd;
	wire	[MXCFEB-1:0]	triad_tp;						// Triad test point at raw hits RAM input
	wire	[MXLY-1:0]		parity_err_cfeb [MXCFEB-1:0];
	wire	[MXCFEB-1:0]	cfeb_sump;

// CFEB Injector data out multiplexler
	wire [17:0]	inj_rdata [MXCFEB-1:0];
	reg	 [17:0] inj_rdata_mux;

	always @(inj_febsel or inj_rdata[0][0]) begin
	case (inj_febsel[4:0])
	5'b00001:	inj_rdata_mux = inj_rdata[0][17:0];
	5'b00010:	inj_rdata_mux = inj_rdata[1][17:0];
	5'b00100:	inj_rdata_mux = inj_rdata[2][17:0];
	5'b01000:	inj_rdata_mux = inj_rdata[3][17:0];
	5'b10000:	inj_rdata_mux = inj_rdata[4][17:0];
	default		inj_rdata_mux = inj_rdata[0][17:0];
	endcase
	end

//-------------------------------------------------------------------------------------------------------------------
// CFEB Instantiation
//-------------------------------------------------------------------------------------------------------------------
   wire  [5:0]         cfeb_nhits [MXCFEB-1:0];


	genvar icfeb;
	generate
	for (icfeb=0; icfeb<=4; icfeb=icfeb+1) begin: gencfeb

	assign cfeb_exists[icfeb] = 1;							// Existence flag
	
	cfeb ucfeb
	(
// Clock
	.clock				(clock),							// In	40MHz TMB system clock
	.clock_cfeb_rxd		(clock_cfeb_rxd[icfeb]),			// In	CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
	.cfeb_rxd_posneg	(cfeb_rxd_posneg[icfeb]),			// In	CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
	.cfeb_rxd_int_delay	(cfeb_rxd_int_delay[icfeb][3:0]),	// In	Interstage delay, integer bx

// Resets
	.global_reset		(global_reset),						// In	Global reset
	.ttc_resync			(ttc_resync),						// In	TTC resync

// CFEBs
	.cfeb_rx			(cfeb_rx[icfeb][MXMUX-1:0]),		// In	Multiplexed LVDS inputs from CFEB
	.mask_all			(mask_all[icfeb]),					// In	1=Enable, 0=Turn off all inputs

// Injector Ports
	.inj_febsel			(inj_febsel[icfeb]),				// In	1=Enable RAM write
	.inject				(injector_go_cfeb[icfeb]),			// In	1=Start pattern injector
	.inj_last_tbin		(inj_last_tbin[11:0]),				// In	Last tbin, may wrap past 1024 ram adr
	.inj_wen			(inj_wen[2:0]),						// In	1=Write enable injector RAM
	.inj_rwadr			(inj_rwadr[9:0]),					// In	Injector RAM read/write address
	.inj_wdata			(inj_wdata[17:0]),					// In	Injector RAM write data
	.inj_ren			(inj_ren[2:0]),						// In	1=Read enable Injector RAM
	.inj_rdata			(inj_rdata[icfeb][17:0]),			// Out	Injector RAM read data
	.inj_ramout			(inj_ramout[icfeb][5:0]),			// Out	Injector RAM read data for ALCT and L1A
	.inj_ramout_pulse	(inj_ramout_pulse[icfeb]),			// Out	Injector RAM is injecting

// Raw Hits FIFO RAM Ports
	.fifo_wen			(fifo_wen),							// In	1=Write enable FIFO RAM
	.fifo_wadr			(fifo_wadr[RAM_ADRB-1:0]),			// In	FIFO RAM write address
	.fifo_radr			(fifo_radr_cfeb[RAM_ADRB-1:0]),		// In	FIFO RAM read tbin address
	.fifo_sel			(fifo_sel_cfeb[2:0]),				// In	FIFO RAM read layer address 0-5
	.fifo_rdata			(fifo_rdata[icfeb][RAM_WIDTH-1:0]),	// Out	FIFO RAM read data

// Hot Channel Mask Ports
	.ly0_hcm			(cfeb_ly0_hcm[icfeb][MXDS-1:0]),	// In	1=enable DiStrip
	.ly1_hcm			(cfeb_ly1_hcm[icfeb][MXDS-1:0]),	// In	1=enable DiStrip
	.ly2_hcm			(cfeb_ly2_hcm[icfeb][MXDS-1:0]),	// In	1=enable DiStrip
	.ly3_hcm			(cfeb_ly3_hcm[icfeb][MXDS-1:0]),	// In	1=enable DiStrip
	.ly4_hcm			(cfeb_ly4_hcm[icfeb][MXDS-1:0]),	// In	1=enable DiStrip
	.ly5_hcm			(cfeb_ly5_hcm[icfeb][MXDS-1:0]),	// In	1=enable DiStrip

// Bad CFEB rx bit detection
	.cfeb_badbits_reset	(cfeb_badbits_reset[icfeb]),		// In	Reset bad cfeb bits FFs
	.cfeb_badbits_block	(cfeb_badbits_block[icfeb]),		// In	Allow bad bits to block triads
	.cfeb_badbits_nbx	(cfeb_badbits_nbx[15:0]),			// In	Cycles a bad bit must be continuously high
	.cfeb_badbits_found	(cfeb_badbits_found[icfeb]),		// Out	CFEB[n] has at least 1 bad bit
	.cfeb_blockedbits	(cfeb_blockedbits[icfeb]),			// Out	1=CFEB rx bit blocked by hcm or went bad, packed

	.ly0_badbits		(cfeb_ly0_badbits[icfeb][MXDS-1:0]),		// Out	1=CFEB rx bit went bad
	.ly1_badbits		(cfeb_ly1_badbits[icfeb][MXDS-1:0]),		// Out	1=CFEB rx bit went bad
	.ly2_badbits		(cfeb_ly2_badbits[icfeb][MXDS-1:0]),		// Out	1=CFEB rx bit went bad
	.ly3_badbits		(cfeb_ly3_badbits[icfeb][MXDS-1:0]),		// Out	1=CFEB rx bit went bad
	.ly4_badbits		(cfeb_ly4_badbits[icfeb][MXDS-1:0]),		// Out	1=CFEB rx bit went bad
	.ly5_badbits		(cfeb_ly5_badbits[icfeb][MXDS-1:0]),		// Out	1=CFEB rx bit went bad

// Triad Decoder Ports
	.triad_persist		(triad_persist[3:0]),				// In	Triad 1/2-strip persistence
	.triad_clr			(triad_clr),						// In	Triad one-shot clear
	.triad_skip			(triad_skip[icfeb]),				// Out	Triads skipped

// Triad Decoder Outputs
	.ly0hs				(cfeb_ly0hs[icfeb][MXHS-1:0]),		// Out	Decoded 1/2-strip pulses
	.ly1hs				(cfeb_ly1hs[icfeb][MXHS-1:0]),		// Out	Decoded 1/2-strip pulses
	.ly2hs				(cfeb_ly2hs[icfeb][MXHS-1:0]),		// Out	Decoded 1/2-strip pulses
	.ly3hs				(cfeb_ly3hs[icfeb][MXHS-1:0]),		// Out	Decoded 1/2-strip pulses
	.ly4hs				(cfeb_ly4hs[icfeb][MXHS-1:0]),		// Out	Decoded 1/2-strip pulses
	.ly5hs				(cfeb_ly5hs[icfeb][MXHS-1:0]),		// Out	Decoded 1/2-strip pulses

   .nhits_per_cfeb (cfeb_nhits[icfeb]),  // Out nhits per cfeb for HMT   
// Status
	.demux_tp_1st		(demux_tp_1st[icfeb]),				// Out	Demultiplexer test point first-in-time
	.demux_tp_2nd		(demux_tp_2nd[icfeb]),				// Out	Demultiplexer test point second-in-time
	.triad_tp			(triad_tp[icfeb]),					// Out	Triad test point at raw hits RAM input
	.parity_err_cfeb	(parity_err_cfeb[icfeb][MXLY-1:0]),	// Out	Raw hits RAM parity error detected
	.cfeb_sump			(cfeb_sump[icfeb])					// Out	Unused signals wot must be connected
// Debug Ports
	);
	end
	endgenerate

//-------------------------------------------------------------------------------------------------------------------
// Pattern Finder declarations, common to ME1A+ME1B+ME234
//-------------------------------------------------------------------------------------------------------------------
// Pre-Trigger Ports
	wire	[3:0]			csc_type;						// Firmware compile type;
	wire	[MXCFEB-1:0]	cfeb_en;						// Enables CFEBs for triggering and active feb flag
	wire	[MXKEYB-1+1:0]	adjcfeb_dist;					// Distance from key to cfeb boundary for marking adjacent cfeb as hit

	wire	[2:0] lyr_thresh_pretrig;
	wire	[2:0] hit_thresh_pretrig;
	wire	[3:0] pid_thresh_pretrig;
	wire	[2:0] dmb_thresh_pretrig;

// 2nd CLCT separation RAM Ports
	wire			clct_sep_src;							// CLCT separation source 1=vme, 0=ram
	wire	[7:0]	clct_sep_vme;							// CLCT separation from vme
	wire			clct_sep_ram_we;						// CLCT separation RAM write enable
	wire	[3:0]	clct_sep_ram_adr;						// CLCT separation RAM rw address VME
	wire	[15:0]	clct_sep_ram_wdata;						// CLCT separation RAM write data VME
	wire	[15:0]	clct_sep_ram_rdata;						// CLCT separation RAM read  data VME

//-------------------------------------------------------------------------------------------------------------------
// Pattern Finder instantiation
//-------------------------------------------------------------------------------------------------------------------
  // 1st pattern lookup results, ccLUT,Tao
  wire [MXBNDB - 1   : 0] hs_bnd_1st; // new bending 
  wire [MXXKYB-1     : 0] hs_xky_1st; // new position with 1/8 precision
  wire [MXPATC-1     : 0] hs_carry_1st; // CC code 
  wire  [MXPIDB-1:0]  hs_run2pid_1st;

  // 2nd pattern lookup results, ccLUT,Tao
  wire [MXBNDB - 1   : 0] hs_bnd_2nd; // new bending 
  wire [MXXKYB-1     : 0] hs_xky_2nd; // new position with 1/8 precision
  wire [MXPATC-1     : 0] hs_carry_2nd; // CC code 
  wire  [MXPIDB-1:0]  hs_run2pid_2nd;

  reg reg_ccLUT_enable;
  //enable CCLUT, Tao
  `ifdef CCLUT
  initial reg_ccLUT_enable = 1'b1;
  `else
  initial reg_ccLUT_enable = 1'b0;
  `endif

   wire ccLUT_enable;
   assign ccLUT_enable = reg_ccLUT_enable;
   wire run3_trig_df; // Run3 trigger data format
   wire run3_daq_df;// Run3 daq data format
   wire run3_alct_df;


	wire	[MXCFEB-1:0]	cfeb_hit;						// This CFEB has a pattern over pre-trigger threshold
	wire	[MXCFEB-1:0]	cfeb_active;					// CFEBs marked for DMB readout
	wire	[MXLY-1:0]		cfeb_layer_or;					// OR of hstrips on each layer
	wire	[MXHITB-1:0]	cfeb_nlayers_hit;				// Number of CSC layers hit

	wire	[MXHITB-1:0]	hs_hit_1st;
	wire	[MXPIDB-1:0]	hs_pid_1st;
	wire	[MXKEYBX-1:0]	hs_key_1st;

	wire	[MXHITB-1:0]	hs_hit_2nd;
	wire	[MXPIDB-1:0]	hs_pid_2nd;
	wire	[MXKEYBX-1:0]	hs_key_2nd;
	wire					hs_bsy_2nd;
	
	wire					hs_layer_trig;					// Layer triggered
	wire	[MXHITB-1:0]	hs_nlayers_hit;					// Number of layers hit
	wire	[MXLY-1:0]		hs_layer_or;					// Layer ORs
	
	//CCLUT is off
  `ifndef CCLUT
   assign hs_bnd_1st[MXBNDB - 1   : 0] = hs_pid_1st;
   assign hs_xky_1st[MXXKYB - 1   : 0] = {hs_hit_1st, 2'b10};   
	assign hs_carry_1st[MXPATC - 1 : 0] = 0;
   assign hs_bnd_2nd[MXBNDB - 1   : 0] = hs_pid_2nd;
   assign hs_xky_2nd[MXXKYB - 1   : 0] = {hs_hit_2nd, 2'b10};
   assign hs_carry_2nd[MXPATC - 1 : 0] = 0;
   assign hs_run2pid_1st[MXPIDB-1:0]   = hs_pid_1st;
   assign hs_run2pid_2nd[MXPIDB-1:0]   = hs_pid_2nd;
  `endif
	
      wire       algo2016_use_dead_time_zone;         // Dead time zone switch: 0 - "old" whole chamber is dead when pre-CLCT is registered, 1 - algo2016 only half-strips around pre-CLCT are marked dead
      wire [4:0] algo2016_dead_time_zone_size;        // Constant size of the dead time zone. NOT used.  We used the fixed dead time zone!
      wire       algo2016_use_dynamic_dead_time_zone; // Dynamic dead time zone switch: 0 - dead time zone is set by algo2016_use_dynamic_dead_time_zone, 1 - dead time zone depends on pre-CLCT pattern ID. NOT USED, Tao
      wire       algo2016_drop_used_clcts;            // Drop CLCTs from matching in ALCT-centric algorithm: 0 - algo2016 do NOT drop CLCTs, 1 - drop used CLCTs
      wire       algo2016_cross_bx_algorithm;         // LCT sorting using cross BX algorithm: 0 - "old" no cross BX algorithm used, 1 - algo2016 uses cross BX algorithm, almost no effect, Tao
      wire       algo2016_clct_use_corrected_bx;      // NOT YET IMPLEMENTED: Use median of hits for CLCT timing: 0 - "old" no CLCT timing corrections, 1 - algo2016 CLCT timing calculated based on median of hits,  NOT USED, Tao
      wire       evenchamber;  // from VME register 0x198, 1 for even chamber and 0 for odd chamber

      wire       seq_trigger_nodeadtime;

//===============================================================
//pattern_finder_ccLUT_tmb: real CCLUT
//pattern_finder_ccLUT_simple: use run2 legacy pattern finding and convert run2 results into CCLUT results without using CC
//===============================================================

        `ifdef CCLUT
	//pattern_finder_ccLUT_tmb upattern_finder_cclut
	pattern_finder_ccLUT_simple upattern_finder_cclut
	(
// Ports
	.clock			(clock),								// In	40MHz TMB main clock
	.clock_lac		(clock_lac),							// In	40MHz pattern finder multiplexer a/b select
	.clock_2x		(clock_2x),								// In	80MHz TMB main clock doubled
	.global_reset	(global_reset),							// In	1=Reset everything

// CFEB Ports
	.cfeb0_ly0hs	(cfeb_ly0hs[0][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb0_ly1hs	(cfeb_ly1hs[0][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb0_ly2hs	(cfeb_ly2hs[0][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb0_ly3hs	(cfeb_ly3hs[0][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb0_ly4hs	(cfeb_ly4hs[0][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb0_ly5hs	(cfeb_ly5hs[0][MXHS-1:0]),				// In	1/2-strip pulses

	.cfeb1_ly0hs	(cfeb_ly0hs[1][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb1_ly1hs	(cfeb_ly1hs[1][MXHS-1:0]),				// In 	1/2-strip pulses
	.cfeb1_ly2hs	(cfeb_ly2hs[1][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb1_ly3hs	(cfeb_ly3hs[1][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb1_ly4hs	(cfeb_ly4hs[1][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb1_ly5hs	(cfeb_ly5hs[1][MXHS-1:0]),				// In	1/2-strip pulses

	.cfeb2_ly0hs	(cfeb_ly0hs[2][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb2_ly1hs	(cfeb_ly1hs[2][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb2_ly2hs	(cfeb_ly2hs[2][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb2_ly3hs	(cfeb_ly3hs[2][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb2_ly4hs	(cfeb_ly4hs[2][MXHS-1:0]),				// In 	1/2-strip pulses
	.cfeb2_ly5hs	(cfeb_ly5hs[2][MXHS-1:0]),				// In	1/2-strip pulses

	.cfeb3_ly0hs	(cfeb_ly0hs[3][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb3_ly1hs	(cfeb_ly1hs[3][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb3_ly2hs	(cfeb_ly2hs[3][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb3_ly3hs	(cfeb_ly3hs[3][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb3_ly4hs	(cfeb_ly4hs[3][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb3_ly5hs	(cfeb_ly5hs[3][MXHS-1:0]),				// In 	1/2-strip pulses

	.cfeb4_ly0hs	(cfeb_ly0hs[4][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb4_ly1hs	(cfeb_ly1hs[4][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb4_ly2hs	(cfeb_ly2hs[4][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb4_ly3hs	(cfeb_ly3hs[4][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb4_ly4hs	(cfeb_ly4hs[4][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb4_ly5hs	(cfeb_ly5hs[4][MXHS-1:0]),				// In	1/2-strip pulses

// CSC Orientation Ports
	.csc_type			(csc_type[3:0]),					// Out	Firmware compile type
	.csc_me1ab			(csc_me1ab),						// Out	1=ME1A or ME1B CSC type
	.stagger_hs_csc		(stagger_hs_csc),					// Out	1=Staggered CSC, 0=non-staggered
	.reverse_hs_csc		(reverse_hs_csc),					// Out	1=Reverse staggered CSC, non-me1
	.reverse_hs_me1a	(reverse_hs_me1a),					// Out	1=reverse me1a hstrips prior to pattern sorting
	.reverse_hs_me1b	(reverse_hs_me1b),					// Out	1=reverse me1b hstrips prior to pattern sorting

// PreTrigger Ports
	.layer_trig_en		(layer_trig_en),					// In	1=Enable layer trigger mode
	.lyr_thresh_pretrig	(lyr_thresh_pretrig[MXHITB-1:0]),	// In	Layers hit pre-trigger threshold
	.hit_thresh_pretrig	(hit_thresh_pretrig[MXHITB-1:0]),	// In	Hits on pattern template pre-trigger threshold
	.pid_thresh_pretrig	(pid_thresh_pretrig[MXPIDB-1:0]),	// In	Pattern shape ID pre-trigger threshold
	.dmb_thresh_pretrig	(dmb_thresh_pretrig[MXHITB-1:0]),	// In	Hits on pattern template DMB active-feb threshold
	.cfeb_en			(cfeb_en[MXCFEB-1:0]),				// In	1=Enable cfeb for pre-triggering
	.adjcfeb_dist		(adjcfeb_dist[MXKEYB-1+1:0]),		// In	Distance from key to cfeb boundary for marking adjacent cfeb as hit
	.clct_blanking		(clct_blanking),					// In	clct_blanking=1 clears clcts with 0 hits

	.cfeb_hit			(cfeb_hit[MXCFEB-1:0]),				// Out	This CFEB has a pattern over pre-trigger threshold
	.cfeb_active		(cfeb_active[MXCFEB-1:0]),			// Out	CFEBs marked for DMB readout

	.cfeb_layer_trig	(cfeb_layer_trig),					// Out	Layer pretrigger
	.cfeb_layer_or		(cfeb_layer_or[MXLY-1:0]),			// Out	OR of hstrips on each layer
	.cfeb_nlayers_hit	(cfeb_nlayers_hit[MXHITB-1:0]),		// Out	Number of CSC layers hit

// 2nd CLCT separation RAM Ports
	.clct_sep_src		(clct_sep_src),						// In	CLCT separation source 1=vme, 0=ram
	.clct_sep_vme		(clct_sep_vme[7:0]),				// In	CLCT separation from vme
	.clct_sep_ram_we	(clct_sep_ram_we),					// In	CLCT separation RAM write enable
	.clct_sep_ram_adr	(clct_sep_ram_adr[3:0]),			// In	CLCT separation RAM rw address VME
	.clct_sep_ram_wdata	(clct_sep_ram_wdata[15:0]),			// In	CLCT separation RAM write data VME
	.clct_sep_ram_rdata	(clct_sep_ram_rdata[15:0]),			// Out	CLCT separation RAM read  data VME

// CLCT Pattern-finder results
	.hs_hit_1st			(hs_hit_1st[MXHITB-1:0]),			// Out	1st CLCT pattern hits
	.hs_pid_1st			(hs_pid_1st[MXPIDB-1:0]),			// Out	1st CLCT pattern ID
	.hs_key_1st			(hs_key_1st[MXKEYBX-1:0]),			// Out	1st CLCT key 1/2-strip
        .hs_bnd_1st (hs_bnd_1st[MXBNDB - 1   : 0]),
        .hs_xky_1st (hs_xky_1st[MXXKYB-1 : 0]),
        .hs_car_1st (hs_carry_1st[MXPATC-1:0]),
        .hs_run2pid_1st (hs_run2pid_1st[MXPIDB-1:0]),  // Out  1st CLCT pattern ID


	.hs_hit_2nd			(hs_hit_2nd[MXHITB-1:0]),			// Out	2nd CLCT pattern hits
	.hs_pid_2nd			(hs_pid_2nd[MXPIDB-1:0]),			// Out	2nd CLCT pattern ID
	.hs_key_2nd			(hs_key_2nd[MXKEYBX-1:0]),			// Out	2nd CLCT key 1/2-strip
	.hs_bsy_2nd			(hs_bsy_2nd),						// Out	2nd CLCT busy, logic error indicator
        .hs_bnd_2nd (hs_bnd_2nd[MXBNDB - 1   : 0]),
        .hs_xky_2nd (hs_xky_2nd[MXXKYB-1 : 0]),
        .hs_car_2nd (hs_carry_2nd[MXPATC-1:0]),
        .hs_run2pid_2nd (hs_run2pid_2nd[MXPIDB-1:0]),  // Out  1st CLCT pattern ID

	.hs_layer_trig		(hs_layer_trig),					// Out	Layer triggered
	.hs_nlayers_hit		(hs_nlayers_hit[MXHITB-1:0]),		// Out	Number of layers hit
	.hs_layer_or		(hs_layer_or[MXLY-1:0])				// Out	Layer ORs
	);
       `else  // normal OTMB firmware with traditional pattern finding  
	pattern_finder upattern_finder
	(
// Ports
	.clock			(clock),								// In	40MHz TMB main clock
	.clock_lac		(clock_lac),							// In	40MHz pattern finder multiplexer a/b select
	.clock_2x		(clock_2x),								// In	80MHz TMB main clock doubled
	.global_reset	(global_reset),							// In	1=Reset everything

// CFEB Ports
	.cfeb0_ly0hs	(cfeb_ly0hs[0][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb0_ly1hs	(cfeb_ly1hs[0][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb0_ly2hs	(cfeb_ly2hs[0][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb0_ly3hs	(cfeb_ly3hs[0][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb0_ly4hs	(cfeb_ly4hs[0][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb0_ly5hs	(cfeb_ly5hs[0][MXHS-1:0]),				// In	1/2-strip pulses

	.cfeb1_ly0hs	(cfeb_ly0hs[1][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb1_ly1hs	(cfeb_ly1hs[1][MXHS-1:0]),				// In 	1/2-strip pulses
	.cfeb1_ly2hs	(cfeb_ly2hs[1][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb1_ly3hs	(cfeb_ly3hs[1][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb1_ly4hs	(cfeb_ly4hs[1][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb1_ly5hs	(cfeb_ly5hs[1][MXHS-1:0]),				// In	1/2-strip pulses

	.cfeb2_ly0hs	(cfeb_ly0hs[2][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb2_ly1hs	(cfeb_ly1hs[2][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb2_ly2hs	(cfeb_ly2hs[2][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb2_ly3hs	(cfeb_ly3hs[2][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb2_ly4hs	(cfeb_ly4hs[2][MXHS-1:0]),				// In 	1/2-strip pulses
	.cfeb2_ly5hs	(cfeb_ly5hs[2][MXHS-1:0]),				// In	1/2-strip pulses

	.cfeb3_ly0hs	(cfeb_ly0hs[3][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb3_ly1hs	(cfeb_ly1hs[3][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb3_ly2hs	(cfeb_ly2hs[3][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb3_ly3hs	(cfeb_ly3hs[3][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb3_ly4hs	(cfeb_ly4hs[3][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb3_ly5hs	(cfeb_ly5hs[3][MXHS-1:0]),				// In 	1/2-strip pulses

	.cfeb4_ly0hs	(cfeb_ly0hs[4][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb4_ly1hs	(cfeb_ly1hs[4][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb4_ly2hs	(cfeb_ly2hs[4][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb4_ly3hs	(cfeb_ly3hs[4][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb4_ly4hs	(cfeb_ly4hs[4][MXHS-1:0]),				// In	1/2-strip pulses
	.cfeb4_ly5hs	(cfeb_ly5hs[4][MXHS-1:0]),				// In	1/2-strip pulses

// CSC Orientation Ports
	.csc_type			(csc_type[3:0]),					// Out	Firmware compile type
	.csc_me1ab			(csc_me1ab),						// Out	1=ME1A or ME1B CSC type
	.stagger_hs_csc		(stagger_hs_csc),					// Out	1=Staggered CSC, 0=non-staggered
	.reverse_hs_csc		(reverse_hs_csc),					// Out	1=Reverse staggered CSC, non-me1
	.reverse_hs_me1a	(reverse_hs_me1a),					// Out	1=reverse me1a hstrips prior to pattern sorting
	.reverse_hs_me1b	(reverse_hs_me1b),					// Out	1=reverse me1b hstrips prior to pattern sorting

// PreTrigger Ports
	.layer_trig_en		(layer_trig_en),					// In	1=Enable layer trigger mode
	.lyr_thresh_pretrig	(lyr_thresh_pretrig[MXHITB-1:0]),	// In	Layers hit pre-trigger threshold
	.hit_thresh_pretrig	(hit_thresh_pretrig[MXHITB-1:0]),	// In	Hits on pattern template pre-trigger threshold
	.pid_thresh_pretrig	(pid_thresh_pretrig[MXPIDB-1:0]),	// In	Pattern shape ID pre-trigger threshold
	.dmb_thresh_pretrig	(dmb_thresh_pretrig[MXHITB-1:0]),	// In	Hits on pattern template DMB active-feb threshold
	.cfeb_en			(cfeb_en[MXCFEB-1:0]),				// In	1=Enable cfeb for pre-triggering
	.adjcfeb_dist		(adjcfeb_dist[MXKEYB-1+1:0]),		// In	Distance from key to cfeb boundary for marking adjacent cfeb as hit
	.clct_blanking		(clct_blanking),					// In	clct_blanking=1 clears clcts with 0 hits

	.cfeb_hit			(cfeb_hit[MXCFEB-1:0]),				// Out	This CFEB has a pattern over pre-trigger threshold
	.cfeb_active		(cfeb_active[MXCFEB-1:0]),			// Out	CFEBs marked for DMB readout

	.cfeb_layer_trig	(cfeb_layer_trig),					// Out	Layer pretrigger
	.cfeb_layer_or		(cfeb_layer_or[MXLY-1:0]),			// Out	OR of hstrips on each layer
	.cfeb_nlayers_hit	(cfeb_nlayers_hit[MXHITB-1:0]),		// Out	Number of CSC layers hit

// 2nd CLCT separation RAM Ports
	.clct_sep_src		(clct_sep_src),						// In	CLCT separation source 1=vme, 0=ram
	.clct_sep_vme		(clct_sep_vme[7:0]),				// In	CLCT separation from vme
	.clct_sep_ram_we	(clct_sep_ram_we),					// In	CLCT separation RAM write enable
	.clct_sep_ram_adr	(clct_sep_ram_adr[3:0]),			// In	CLCT separation RAM rw address VME
	.clct_sep_ram_wdata	(clct_sep_ram_wdata[15:0]),			// In	CLCT separation RAM write data VME
	.clct_sep_ram_rdata	(clct_sep_ram_rdata[15:0]),			// Out	CLCT separation RAM read  data VME

// CLCT Pattern-finder results
	.hs_hit_1st			(hs_hit_1st[MXHITB-1:0]),			// Out	1st CLCT pattern hits
	.hs_pid_1st			(hs_pid_1st[MXPIDB-1:0]),			// Out	1st CLCT pattern ID
	.hs_key_1st			(hs_key_1st[MXKEYBX-1:0]),			// Out	1st CLCT key 1/2-strip

	.hs_hit_2nd			(hs_hit_2nd[MXHITB-1:0]),			// Out	2nd CLCT pattern hits
	.hs_pid_2nd			(hs_pid_2nd[MXPIDB-1:0]),			// Out	2nd CLCT pattern ID
	.hs_key_2nd			(hs_key_2nd[MXKEYBX-1:0]),			// Out	2nd CLCT key 1/2-strip
	.hs_bsy_2nd			(hs_bsy_2nd),						// Out	2nd CLCT busy, logic error indicator

	.hs_layer_trig		(hs_layer_trig),					// Out	Layer triggered
	.hs_nlayers_hit		(hs_nlayers_hit[MXHITB-1:0]),		// Out	Number of layers hit
	.hs_layer_or		(hs_layer_or[MXLY-1:0])				// Out	Layer ORs
	);
        `endif

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  HMT instantiation
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
  wire hmt_sump;

  wire  hmt_enable;
  wire  hmt_me1a_enable;

  wire  hmt_allow_cathode;
  wire  hmt_allow_anode;
  wire  hmt_allow_match;
  wire  hmt_allow_cathode_ro;
  wire  hmt_allow_anode_ro;
  wire  hmt_allow_match_ro;
  wire  hmt_outtime_check;

  wire [NHMTHITB-1:0] hmt_nhits_sig_ff; //for header
  wire [NHMTHITB-1:0] hmt_nhits_bx7;
  wire [NHMTHITB-1:0] hmt_nhits_sig;
  wire [NHMTHITB-1:0] hmt_nhits_bkg;
  wire [7:0] hmt_thresh1, hmt_thresh2, hmt_thresh3;

  wire [6:0] hmt_aff_thresh;
  wire [MXCFEB-1:0] hmt_active_feb;
  wire hmt_pretrig_match;
  wire hmt_fired_pretrig;
  wire hmt_fired_xtmb;
  wire hmt_wr_avail_xtmb;
  wire [MXBADR-1:0] hmt_wr_adr_xtmb;

  wire [3:0]  hmt_delay;
  wire [3:0]  hmt_alct_win_size;
  wire [3:0]  hmt_match_win;

  wire [MXHMTB-1:0] hmt_anode;
  wire [MXHMTB-1:0] hmt_cathode;

  wire [MXBADR-1:0] wr_adr_xpre_hmt;
  wire              wr_push_xpre_hmt;
  wire              wr_avail_xpre_hmt; 

  wire [MXBADR-1:0] wr_adr_xpre_hmt_pipe;
  wire              wr_push_mux_hmt;
  wire              wr_avail_xpre_hmt_pipe; 
  
  wire hmt_fired_cathode_only;
  wire hmt_fired_anode_only;
  wire hmt_fired_match;

  wire [MXHMTB-1:0] hmt_trigger_tmb;// results aligned with ALCT vpf
  wire [MXHMTB-1:0] hmt_trigger_tmb_ro;// results aligned with ALCT vpf


`ifdef  TMBHMT
   hmt uhmt
  (
  .clock       (clock),          // In clock
  .ttc_resync  (ttc_resync),      // In
  .global_reset(global_reset),    // In

  .fmm_trig_stop (fmm_trig_stop), // In stop HMT when it is not ready
  .bx0_vpf_test  (bx0_vpf_test) ,  // In dynamic zero

  .nhit_cfeb0    (cfeb_nhits[0][NHITCFEBB-1: 0]),// In cfeb hit counter
  .nhit_cfeb1    (cfeb_nhits[1][NHITCFEBB-1: 0]),// In cfeb hit counter
  .nhit_cfeb2    (cfeb_nhits[2][NHITCFEBB-1: 0]),// In cfeb hit counter
  .nhit_cfeb3    (cfeb_nhits[3][NHITCFEBB-1: 0]),// In cfeb hit counter
  .nhit_cfeb4    (cfeb_nhits[4][NHITCFEBB-1: 0]),// In cfeb hit counter

  .layers_withhits_cfeb0 (cfeb_layers_withhits[0][MXLY-1:0]), // In layers with hits
  .layers_withhits_cfeb1 (cfeb_layers_withhits[1][MXLY-1:0]), // In layers with hits
  .layers_withhits_cfeb2 (cfeb_layers_withhits[2][MXLY-1:0]), // In layers with hits
  .layers_withhits_cfeb3 (cfeb_layers_withhits[3][MXLY-1:0]), // In layers with hits
  .layers_withhits_cfeb4 (cfeb_layers_withhits[4][MXLY-1:0]), // In layers with hits

  .hmt_enable    (hmt_enable) , // In hmt enabled
  .hmt_thresh1   (hmt_thresh1[7:0]), // In hmt thresh1
  .hmt_thresh2   (hmt_thresh2[7:0]), // In hmt thresh2
  .hmt_thresh3   (hmt_thresh3[7:0]), // In hmt thresh3
  .hmt_aff_thresh(hmt_aff_thresh[6:0]),//In hmt thresh for active cfeb flag

  .wr_adr_xpre_hmt        (wr_adr_xpre_hmt[MXBADR-1:0]),  //In wr_adr at pretrigger for hmt
  .wr_push_xpre_hmt       (wr_push_xpre_hmt), //In wr_push at pretrigger for hmt
  .wr_avail_xpre_hmt      (wr_avail_xpre_hmt),//In wr_avail at pretrigger for hmt

  .wr_adr_xpre_hmt_pipe   (wr_adr_xpre_hmt_pipe[MXBADR-1:0]),  //Out wr_adr at rtmb-1 for hmt
  .wr_push_mux_hmt        (wr_push_mux_hmt),       //Out wr_push at rtmb-1 for hmt
  .wr_avail_xpre_hmt_pipe (wr_avail_xpre_hmt_pipe),//Out wr_avail at rtmb-1 for hmt

  .hmt_delay          (hmt_delay[3:0]), // In hmt delay for matching
  .hmt_alct_win_size  (hmt_alct_win_size[3:0]),//In hmt-alct match window size
  .hmt_match_win      (hmt_match_win[3:0]),// In alct location in hmt window size
   //tmb port: input
  .alct_vpf_pipe     (alct_vpf_pipe),//In ALCT vpf after alct delay
  .hmt_anode         (hmt_anode[MXHMTB-1:0]),// In hmt bits from anode

  .clct_pretrig     (clct_pretrig),//In clct pretrigger
  .clct_vpf_pipe    (clct_vpf_pipe),//In CLCT vpf after delay

  // vme port: input
  .cfeb_allow_hmt_ro  (cfeb_allow_hmt_ro), //Out read out CFEB when hmt is fired
  .hmt_allow_cathode   (hmt_allow_cathode),//In hmt allow to trigger on cathode
  .hmt_allow_anode     (hmt_allow_anode),//In hmt allow to trigger on anode
  .hmt_allow_match     (hmt_allow_match),//In hmt allow to trigger on canode X anode match
  .hmt_allow_cathode_ro(hmt_allow_cathode_ro),//In hmt allow to readout on cathode
  .hmt_allow_anode_ro  (hmt_allow_anode_ro),//In hmt allow to readout on anode
  .hmt_allow_match_ro  (hmt_allow_match_ro),//In hmt allow to readout on match
  .hmt_outtime_check   (hmt_outtime_check),//In hmt fired shoudl check anode bg lower than threshold
  // sequencer port
  .hmt_fired_pretrig   (hmt_fired_pretrig),//out, hmt fired preCLCT bx
  .hmt_active_feb      (hmt_active_feb[MXCFEB-1:0]),//Out hmt active cfeb flags
  .hmt_pretrig_match   (hmt_pretrig_match),//out hmt & preCLCT
  .hmt_fired_xtmb      (hmt_fired_xtmb),//out, hmt fired preCLCT bx
  .hmt_wr_avail_xtmb   (hmt_wr_avail_xtmb),//Out hmt wr buf available
  .hmt_wr_adr_xtmb     (hmt_wr_adr_xtmb[MXBADR-1:0]),// Out hmt wr adr at CLCt bx

  //tmb port
  .hmt_nhits_bx7       (hmt_nhits_bx7     [NHMTHITB-1:0]),//Out hmt nhits for central bx
  .hmt_nhits_sig     (hmt_nhits_sig   [NHMTHITB-1:0]),//Out hmt nhits for in-time
  .hmt_nhits_bkg    (hmt_nhits_bkg  [NHMTHITB-1:0]),//Out hmt nhits for out-time
  .hmt_cathode_pipe    (hmt_cathode[MXHMTB-1:0]), //Out hmt bits in cathod

  //.hmt_cathode_fired     (hmt_cathode_fired),// Out
  //.hmt_anode_fired       (hmt_anode_fired),// Out
  .hmt_anode_alct_match  (hmt_anode_alct_match),//Out
  .hmt_cathode_alct_match(hmt_cathode_alct_match),// Out
  .hmt_cathode_clct_match(hmt_cathode_clct_match),// Out
  .hmt_cathode_lct_match (hmt_cathode_lct_match),// Out

  .hmt_fired_cathode_only (hmt_fired_cathode_only),//Out hmt is fired for cathode only
  .hmt_fired_anode_only   (hmt_fired_anode_only),//Out hmt is fired for anode only
  .hmt_fired_match        (hmt_fired_match),//Out hmt is fired for match
  .hmt_fired_or           (hmt_fired_or),//Out hmt is fired for match

  .hmt_trigger_tmb    (hmt_trigger_tmb[MXHMTB-1:0]),// results aligned with ALCT vpf latched for ALCT-CLCT match
  .hmt_trigger_tmb_ro (hmt_trigger_tmb_ro[MXHMTB-1:0]),// results aligned with ALCT vpf latched for ALCT-CLCT match
  .hmt_sump  (hmt_sump)
);
`endif // end if HMT is enabled for compiling


//-------------------------------------------------------------------------------------------------------------------
//	Sequencer Instantiation
//-------------------------------------------------------------------------------------------------------------------
	wire	[MXCFEBB-1:0]	cfeb_adr;
	wire	[MXTBIN-1:0]	cfeb_tbin;
	wire	[7:0]			cfeb_rawhits;

        wire [MXHMTB-1:0]             hmt_trigger_xtmb;
        wire [MXHMTB-1:0]             hmt_trigger_vme;

	wire	[MXCLCT-1:0]	clct0_xtmb;
	wire	[MXCLCT-1:0]	clct1_xtmb;
	wire	[MXCLCTC-1:0]	clctc_xtmb;				// Common to CLCT0/1 to TMB
	wire	[MXCFEB-1:0]	clctf_xtmb;				// Active cfeb list to TMB
        wire [MXBNDB - 1   : 0]   clct0_bnd_xtmb; // new bending
        wire [MXXKYB-1     : 0]   clct0_xky_xtmb; // new position with 1/8 precision
        wire [MXBNDB - 1   : 0]   clct1_bnd_xtmb; // new bending
        wire [MXXKYB-1     : 0]   clct1_xky_xtmb; // new position with 1/8 precision

	wire	[MXBADR-1:0]	wr_adr_xtmb;			// Buffer write address to TMB
	wire	[MXBADR-1:0]	wr_adr_rtmb;			// Buffer write address at TMB matching time
	wire	[MXBADR-1:0]	wr_adr_xmpc;			// wr_adr at mpc xmit to sequencer
	wire	[MXBADR-1:0]	wr_adr_rmpc;			// wr_adr at mpc received

	wire	[MXCFEB-1:0]	injector_mask_cfeb;
	wire	[3:0]			inj_delay_rat;			// CFEB/RPC Injector waits for RAT injector

	wire	[MXBXN-1:0]		bxn_offset_pretrig;
	wire	[MXBXN-1:0]		bxn_offset_l1a;
	wire	[MXL1ARX-1:0]	l1a_offset;
	wire	[MXDRIFT-1:0]	drift_delay;
	wire	[MXHITB-1:0]	hit_thresh_postdrift;
	wire	[MXPIDB-1:0]	pid_thresh_postdrift;
	wire	[MXFLUSH-1:0]	clct_flush_delay;
	wire	[MXTHROTTLE-1:0]clct_throttle;

	wire	[MXBDID-1:0]	board_id;
	wire	[MXCSC-1:0]		csc_id;
	wire	[MXRID-1:0]		run_id;

	wire	[15:0]			uptime;					// Uptime since last hard reset
	wire	[14:0]			bd_status;				// Board status summary
	wire	[4:0]			dmb_tx_reserved;

	wire	[MXL1DELAY-1:0]	l1a_delay;
	wire	[MXL1WIND-1:0]	l1a_window;
	wire	[MXL1WIND-1:0]	l1a_internal_dly;
	wire	[MXBADR-1:0]	l1a_lookback;
	
	wire	[7:0]			led_bd;
	wire	[11:0]			sequencer_state;
	wire	[10:0]			trig_source_vme;
	wire	[2:0]			nlayers_hit_vme;
	wire	[MXBXN-1:0]		bxn_clct_vme;			// CLCT BXN at pre-trigger
	wire	[MXBXN-1:0]		bxn_l1a_vme;			// CLCT BXN at L1A
	wire	[3:0]			alct_preClct_width;

	wire	[MXEXTDLY-1:0]	alct_preClct_dly;
	wire	[MXEXTDLY-1:0]	alct_pat_trig_dly;
	wire	[MXEXTDLY-1:0]	adb_ext_trig_dly;
	wire	[MXEXTDLY-1:0]	dmb_ext_trig_dly;
	wire	[MXEXTDLY-1:0]	clct_ext_trig_dly;
	wire	[MXEXTDLY-1:0]	alct_ext_trig_dly;

  wire [3:0] l1a_preClct_width;
  wire [7:0] l1a_preClct_dly;

	wire	[MXCLCT-1:0]	clct0_vme;
	wire	[MXCLCT-1:0]	clct1_vme;
	wire	[MXCLCTC-1:0]	clctc_vme;
	wire	[MXCFEB-1:0]	clctf_vme;

  wire [MXBNDB - 1   : 0] clct0_vme_bnd; // new bending 
  wire [MXXKYB-1     : 0] clct0_vme_xky; // new position with 1/8 precision

  wire [MXBNDB - 1   : 0] clct1_vme_bnd; // new bending 
  wire [MXXKYB-1     : 0] clct1_vme_xky; // new position with 1/8 precision

	wire	[MXRAMADR-1:0]	dmb_adr;
	wire	[MXRAMDATA-1:0]	dmb_wdata;
	wire	[MXRAMDATA-1:0]	dmb_rdata;
	wire	[MXRAMADR-1:0]	dmb_wdcnt;

	wire	[3:0]			alct_delay;
	wire	[3:0]			clct_window;
	wire	[3:0]			alct_bx0_delay;			// ALCT bx0 delay to mpc transmitter
	wire	[3:0]			clct_bx0_delay;			// CLCT bx0 delay to mpc transmitter

	wire	[MXMPCDLY-1:0]	mpc_rx_delay;
	wire	[MXMPCDLY-1:0]	mpc_tx_delay;
	wire	[MXFRAME-1:0]	mpc0_frame0_ff;
	wire	[MXFRAME-1:0]	mpc0_frame1_ff;
	wire	[MXFRAME-1:0]	mpc1_frame0_ff;
	wire	[MXFRAME-1:0]	mpc1_frame1_ff;

	wire	[10:0]			tmb_alct0;
	wire	[10:0]			tmb_alct1;
	wire	[ 4:0]			tmb_alctb;
	wire	[ 1:0]			tmb_alcte;

	wire	[1:0]			mpc_accept_ff;
	wire	[1:0]			mpc_reserved_ff;
	wire	[3:0]			tmb_match_win;
	wire	[3:0]			tmb_match_pri;
	wire	[MXCFEB-1:0]	tmb_aff_list;			// Active CFEBs for CLCT used in TMB match

// Buffer Arrays
	wire [MXFMODE-1:0]		fifo_mode;

	wire [MXTBIN-1:0]		fifo_tbins_cfeb;		// Number FIFO time bins to read out
	wire [MXTBIN-1:0]		fifo_tbins_rpc;			// Number FIFO time bins to read out
	wire [MXTBIN-1:0]		fifo_tbins_mini;		// Number FIFO time bins to read out

	wire [MXTBIN-1:0]		fifo_pretrig_cfeb;		// Number FIFO time bins before pretrigger
	wire [MXTBIN-1:0]		fifo_pretrig_rpc;		// Number FIFO time bins before pretrigger
	wire [MXTBIN-1:0]		fifo_pretrig_mini;		// Number FIFO time bins before pretrigger

	wire [MXBADR-1:0]		buf_pop_adr;			// Address of read buffer to release
	wire [MXBADR-1:0]		buf_push_adr;			// Address of write buffer to allocate	
	wire [MXBDATA-1:0]		buf_push_data;			// Data associated with push_adr
	wire [MXBADR-1:0]		wr_buf_adr;				// Current ddress of header write buffer

	wire [MXBADR-1:0]		buf_queue_adr;			// Buffer address of fence queued for readout
	wire [MXBDATA-1:0]		buf_queue_data;			// Data associated with queue adr

	wire [MXBADR-1:0]		buf_fence_dist;			// Distance to 1st fence address
	wire [MXBADR-1+1:0]		buf_fence_cnt;			// Number of fences in fence RAM currently
	wire [MXBADR-1+1:0]		buf_fence_cnt_peak;		// Peak number of fences in fence RAM
	wire [7:0]				buf_display;			// Buffer fraction in use display

// RPC Sequencer Readout Control
	wire	[MXRPC-1:0]		rpc_exists;				// RPC Readout list
	wire	[MXRPC-1:0] 	rd_list_rpc;			// List of RPCs to read out
	wire	[MXRPCB-1+1:0]	rd_nrpcs;				// Number of RPCs in rpc_list (0 or 1-to-2 depending on CSC type)
	wire	[RAM_ADRB-1:0]	rd_rpc_offset;			// RAM address rd_fifo_adr offset for rpc read out

	wire	[MXCFEBB-1:0]	rd_ncfebs;
	wire	[MXCFEB-1:0]	rd_list_cfeb;
	wire	[RAM_ADRB-1:0]	rd_fifo_adr;

	wire	[MXRPCB-1:0]	rpc_adr;				// FIFO dump RPC ID
	wire	[MXTBIN-1:0]	rpc_tbinbxn;			// FIFO dump RPC tbin or bxn for DMB
	wire	[7:0]			rpc_rawhits;			// FIFO dump RPC pad hits, 8 of 16 per cycle

// Scope
	wire	[2:0]			scp_rpc0_bxn;			// RPC0 bunch crossing number
	wire	[2:0]			scp_rpc1_bxn;			// RPC1 bunch crossing number
	wire	[3:0]			scp_rpc0_nhits;			// RPC0 number of pads hit
	wire	[3:0]			scp_rpc1_nhits;			// RPC1 number of pads hit

	wire	[7:0]			scp_trigger_ch;			// Trigger channel 0-159
	wire	[3:0]			scp_ram_sel;			// Scope RAM select
	wire	[2:0]			scp_tbins;				// Time bins per channel code, actual tbins/ch = (tbins+1)*64
	wire	[8:0]			scp_radr;				// Extended to 512 addresses 7/23/2007
	wire	[15:0]			scp_rdata;

// Miniscope
	wire	[RAM_WIDTH*2-1:0]	mini_rdata;			// FIFO dump miniscope
	wire	[RAM_WIDTH*2-1:0]	fifo_wdata_mini;	// FIFO RAM write data
	wire	[RAM_ADRB-1:0]		rd_mini_offset;		// RAM address rd_fifo_adr offset for miniscope read out
	wire	[RAM_ADRB-1:0]		wr_mini_offset;		// RAM address offset for miniscope write

// Blockedbits
	wire	[MXCFEB-1:0]	rd_list_bcb;			// List of CFEBs to read out
	wire	[MXCFEBB-1:0]	rd_ncfebs_bcb;			// Number of CFEBs in bcb_list (0 to 5)
	wire	[11:0]			bcb_blkbits;			// CFEB blocked bits frame data
	wire	[MXCFEBB-1:0]	bcb_cfeb_adr;			// CFEB ID	

// Header Counters
	wire	[MXCNTVME-1:0]	pretrig_counter;		// Pre-trigger counter
	wire	[MXCNTVME-1:0]	clct_counter;			// CLCT counter
	wire	[MXCNTVME-1:0]	trig_counter;			// TMB trigger counter
	wire	[MXCNTVME-1:0]	alct_counter;			// ALCTs received counter
	wire	[MXL1ARX-1:0]	l1a_rx_counter;			// L1As received from ccb counter
	wire	[MXL1ARX-1:0]	readout_counter;		// Readout counter
	wire	[MXORBIT-1:0]	orbit_counter;			// Orbit counter

// Revcode
	wire	[14:0]			revcode;

// Parity errors
	wire	[MXCFEB-1:0]	perr_cfeb;
	wire	[MXCFEB-1:0]	perr_cfeb_ff;
	wire	[48:0]			perr_ram_ff;

// VME debug register latches
	wire	[MXBADR-1:0]	deb_wr_buf_adr;			// Buffer write address at last pretrig
	wire	[MXBADR-1:0]	deb_buf_push_adr;		// Queue push address at last push
	wire	[MXBADR-1:0]	deb_buf_pop_adr;		// Queue pop  address at last pop
	wire	[MXBDATA-1:0]	deb_buf_push_data;		// Queue push data at last push
	wire	[MXBDATA-1:0]	deb_buf_pop_data;		// Queue pop  data at last pop

	sequencer usequencer
	(
// CCB
	.clock					(clock),						// In	40MHz TMB main clock
	.global_reset			(global_reset),					// In	Global reset
	.clock_lock_lost_err	(clock_lock_lost_err),			// In	40MHz main clock lost lock FF
	.ccb_l1accept			(ccb_l1accept),					// In	Level 1 Accept
	.ccb_evcntres			(ccb_evcntres),					// In	Event counter (L1A) reset command
	.ttc_bx0				(ttc_bx0),						// In	Bunch crossing 0 flag
	.ttc_resync				(ttc_resync),					// In	TTC resync
	.ttc_bxreset			(ttc_bxreset),					// In	Reset bxn
	.ttc_orbit_reset		(ttc_orbit_reset),				// In	Reset orbit counter
	.fmm_trig_stop			(fmm_trig_stop),				// In	Stop clct trigger sequencer
	.sync_err				(sync_err),						// In	Sync error OR of enabled error types
	.clct_bx0_sync_err		(clct_bx0_sync_err),			// Out	TMB  clock pulse count err bxn!=0+offset at ttc_bx0 arrival

// ALCT
	.alct_active_feb		(alct_active_feb),				// In	ALCT Pattern trigger
	.alct0_valid			(alct0_valid),					// In	ALCT has valid LCT
	.alct1_valid			(alct1_valid),					// In	ALCT has valid LCT

// External Triggers
	.alct_adb_pulse_sync	(alct_adb_pulse_sync),			// In	ADB Test pulse trigger
	.dmb_ext_trig			(dmb_ext_trig),					// In	DMB Calibration trigger
	.clct_ext_trig			(clct_ext_trig),				// In	CLCT External trigger from CCB
	.alct_ext_trig			(alct_ext_trig),				// In	ALCT External trigger from CCB
	.vme_ext_trig			(vme_ext_trig),					// In	External trigger from VME
	.ext_trig_inject		(ext_trig_inject),				// In	Changes clct_ext_trig to fire pattern injector

// External Trigger Enables
	.clct_pat_trig_en		(clct_pat_trig_en),				// In	Allow CLCT Pattern pre-triggers
	.alct_pat_trig_en		(alct_pat_trig_en),				// In	Allow ALCT Pattern pre-trigger
	.alct_match_trig_en		(alct_match_trig_en),			// In	Allow CLCT*ALCT Pattern pre-trigger
	.adb_ext_trig_en		(adb_ext_trig_en),				// In	Allow ADB Test pulse pre-trigger
	.dmb_ext_trig_en		(dmb_ext_trig_en),				// In	Allow DMB Calibration pre-trigger
	.clct_ext_trig_en		(clct_ext_trig_en),				// In	Allow CLCT External pre-trigger from CCB
	.alct_ext_trig_en		(alct_ext_trig_en),				// In	Allow ALCT External pre-trigger from CCB
	.layer_trig_en			(layer_trig_en),				// In	Allow layer-wide pre-triggering
	.all_cfebs_active		(all_cfebs_active),				// In	Make all CFEBs active when triggered
	.cfeb_en				(cfeb_en[MXCFEB-1:0]),			// In	1=Enable this CFEB for triggering + sending active feb flag
	.active_feb_src			(active_feb_src),				// In	Active cfeb flag source, 0=pretrig, 1=tmb-matching ~8bx later

	.alct_preClct_width		(alct_preClct_width[3:0]),			// In  ALCT (alct_active_feb flag) window width for ALCT*preCLCT overlap
	.wr_buf_required		(wr_buf_required),				// In	Require wr_buffer to pretrigger
	.wr_buf_autoclr_en		(wr_buf_autoclr_en),			// In	Enable frozen buffer auto clear
	.valid_clct_required	(valid_clct_required),			// In	Require valid pattern after drift to trigger

	.sync_err_stops_pretrig	(sync_err_stops_pretrig),		// In	Sync error stops CLCT pre-triggers
	.sync_err_stops_readout	(sync_err_stops_readout),		// In	Sync error stops L1A readouts

// External Trigger Delays
	.alct_preClct_dly		(alct_preClct_dly[MXEXTDLY-1:0]),	// In  ALCT (alct_active_feb flag) delay for ALCT*preCLCT
	.alct_pat_trig_dly		(alct_pat_trig_dly[MXEXTDLY-1:0]),	// In	ALCT pattern  trigger delay
	.adb_ext_trig_dly		(adb_ext_trig_dly[MXEXTDLY-1:0]),	// In	ADB  external trigger delay
	.dmb_ext_trig_dly		(dmb_ext_trig_dly[MXEXTDLY-1:0]),	// In	DMB  external trigger delay
	.clct_ext_trig_dly		(clct_ext_trig_dly[MXEXTDLY-1:0]),	// In	CLCT external trigger delay
	.alct_ext_trig_dly		(alct_ext_trig_dly[MXEXTDLY-1:0]),	// In	ALCT external trigger delay

// Sequencer Ports: pre-CLCT modifiers for L1A*preCLCT overlap
  .l1a_preClct_width (l1a_preClct_width[3:0]), // In  pre-CLCT window width for L1A*preCLCT overlap
  .l1a_preClct_dly   (l1a_preClct_dly[7:0]),   // In  pre-CLCT delay for L1A*preCLCT overlap

// CLCT/RPC/RAT Pattern Injector
	.inj_trig_vme			(inj_trig_vme),						// In	Start pattern injector
	.injector_mask_cfeb		(injector_mask_cfeb[MXCFEB-1:0]),	// In	Enable CFEB(n) for injector trigger
	.injector_mask_rat		(injector_mask_rat),				// In	Enable RAT for injector trigger
	.injector_mask_rpc		(injector_mask_rpc),				// In	Enable RPC for injector trigger
	.inj_delay_rat			(inj_delay_rat[3:0]),				// In	CFEB/RPC Injector waits for RAT injector
	.injector_go_cfeb		(injector_go_cfeb[MXCFEB-1:0]),		// Out	Start CFEB(n) pattern injector
	.injector_go_rat		(injector_go_rat),					// Out	Start RAT     pattern injector
	.injector_go_rpc		(injector_go_rpc),					// Out	Start RPC     pattern injector

// Status from CFEBs
	.triad_skip				(triad_skip[MXCFEB-1:0]),			// In	Triads skipped
	.triad_tp				(triad_tp[MXCFEB-1:0]),				// In	Triad test point at raw hits RAM input
	.cfeb_badbits_found		(cfeb_badbits_found[4:0]),			// In	CFEB[n] has at least 1 bad bit
	.cfeb_badbits_blocked	(cfeb_badbits_blocked),				// In	A CFEB had bad bits that were blocked

// Pattern Finder PreTrigger Ports
	.cfeb_hit				(cfeb_hit[MXCFEB-1:0]),				// In	This CFEB has a pattern over pre-trigger threshold
	.cfeb_active			(cfeb_active[MXCFEB-1:0]),			// In	CFEBs marked for DMB readout

	.cfeb_layer_trig		(cfeb_layer_trig),					// In	Layer pretrigger
	.cfeb_layer_or			(cfeb_layer_or[MXLY-1:0]),			// In	OR of hstrips on each layer
	.cfeb_nlayers_hit		(cfeb_nlayers_hit[MXHITB-1:0]),		// In	Number of CSC layers hit

        //Sequencer HMT results                                                                                                                                        
// Pattern Finder CLCT results
	.hs_hit_1st				(hs_hit_1st[MXHITB-1:0]),			// In	1st CLCT pattern hits
	.hs_pid_1st				(hs_pid_1st[MXPIDB-1:0]),			// In	1st CLCT pattern ID
	.hs_key_1st				(hs_key_1st[MXKEYBX-1:0]),			// In	1st CLCT key 1/2-strip
        .hs_bnd_1st (hs_bnd_1st[MXBNDB - 1   : 0]),
        .hs_xky_1st (hs_xky_1st[MXXKYB-1 : 0]),
        .hs_carry_1st (hs_carry_1st[MXPATC-1:0]),
        .hs_run2pid_1st (hs_run2pid_1st[MXPIDB-1:0]),  // In  1st CLCT pattern ID

	.hs_hit_2nd				(hs_hit_2nd[MXHITB-1:0]),			// In	2nd CLCT pattern hits
	.hs_pid_2nd				(hs_pid_2nd[MXPIDB-1:0]),			// In	2nd CLCT pattern ID
	.hs_key_2nd				(hs_key_2nd[MXKEYBX-1:0]),			// In	2nd CLCT key 1/2-strip
	.hs_bsy_2nd				(hs_bsy_2nd),						// In	2nd CLCT busy, logic error indicator
        .hs_bnd_2nd (hs_bnd_2nd[MXBNDB - 1   : 0]),
        .hs_xky_2nd (hs_xky_2nd[MXXKYB-1 : 0]),
        .hs_carry_2nd (hs_carry_2nd[MXPATC-1:0]),
        .hs_run2pid_2nd (hs_run2pid_2nd[MXPIDB-1:0]),  // In  1st CLCT pattern ID

	.hs_layer_trig			(hs_layer_trig),					// In	Layer triggered
	.hs_nlayers_hit			(hs_nlayers_hit[MXHITB-1:0]),		// In	Number of layers hit
	.hs_layer_or			(hs_layer_or[MXLY-1:0]),			// In	Layer ORs

// DMB Ports
	.alct_dmb				(alct_dmb[18:0]),					// In	ALCT to DMB
	.dmb_tx_reserved		(dmb_tx_reserved[4:0]),				// In	DMB backplane reserved
	.dmb_tx					(dmb_tx[MXDMB-1:0]),				// Out	DAQMB backplane connector

// ALCT Status
	.alct_cfg_done			(alct_cfg_done),					// In	ALCT FPGA configuration done

// CSC Orientation Ports
	.csc_me1ab				(csc_me1ab),						// In	1=ME1A or ME1B CSC type
	.stagger_hs_csc			(stagger_hs_csc),					// In	1=Staggered CSC, 0=non-staggered
	.reverse_hs_csc			(reverse_hs_csc),					// In	1=Reverse staggered CSC, non-me1
	.reverse_hs_me1a		(reverse_hs_me1a),					// In	1=reverse me1a hstrips prior to pattern sorting
	.reverse_hs_me1b		(reverse_hs_me1b),					// In	1=reverse me1b hstrips prior to pattern sorting

// CLCT VME Configuration Ports
	.clct_blanking			(clct_blanking),					// In	clct_blanking=1 clears clcts with 0 hits
	.bxn_offset_pretrig		(bxn_offset_pretrig[MXBXN-1:0]),	// In	BXN offset at reset, for pretrig bxn
	.bxn_offset_l1a			(bxn_offset_l1a[MXBXN-1:0]),		// In	BXN offset at reset, for L1A bxn
	.lhc_cycle				(lhc_cycle[MXBXN-1:0]),				// In	LHC period, max BXN count+1
	.l1a_offset				(l1a_offset[MXL1ARX-1:0]),			// In	L1A counter preset value
	.drift_delay			(drift_delay[MXDRIFT-1:0]),			// In	CSC Drift delay clocks
	.triad_persist			(triad_persist[3:0]),				// In	Triad 1/2-strip persistence

	.lyr_thresh_pretrig	 	(lyr_thresh_pretrig[MXHITB-1:0]),	// In	Layers hit pre-trigger threshold
	.hit_thresh_pretrig	 	(hit_thresh_pretrig[MXHITB-1:0]),	// In	Hits on pattern template pre-trigger threshold
	.pid_thresh_pretrig	 	(pid_thresh_pretrig[MXPIDB-1:0]),	// In	Pattern shape ID pre-trigger threshold
	.dmb_thresh_pretrig	 	(dmb_thresh_pretrig[MXHITB-1:0]),	// In	Hits on pattern template DMB active-feb threshold
	.hit_thresh_postdrift	(hit_thresh_postdrift[MXHITB-1:0]),// In	Minimum pattern hits for a valid pattern
	.pid_thresh_postdrift	(pid_thresh_postdrift[MXPIDB-1:0]),// In	Minimum pattern ID   for a valid pattern

	.clct_flush_delay		(clct_flush_delay[MXFLUSH-1:0]),// In	Trigger sequencer flush state timer
	.clct_throttle			(clct_throttle[MXTHROTTLE-1:0]),// In	Pre-trigger throttle to reduce trigger rate
	.clct_wr_continuous		(clct_wr_continuous),			// In	1=allow continuous header buffer writing for invalid triggers

	.alct_delay				(alct_delay[3:0]),				// In	Delay ALCT for CLCT match window
	.clct_window			(clct_window[3:0]),				// In	CLCT match window width

	.tmb_allow_alct			(tmb_allow_alct),				// In	Allow ALCT only 
	.tmb_allow_clct			(tmb_allow_clct),				// In	Allow CLCT only
	.tmb_allow_match		(tmb_allow_match),				// In	Allow ALCT+CLCT match

	.tmb_allow_alct_ro		(tmb_allow_alct_ro),			// In	Allow ALCT only  readout, non-triggering
	.tmb_allow_clct_ro		(tmb_allow_clct_ro),			// In	Allow CLCT only  readout, non-triggering
	.tmb_allow_match_ro		(tmb_allow_match_ro),			// In	Allow Match only readout, non-triggering

	.mpc_tx_delay			(mpc_tx_delay[MXMPCDLY-1:0]),	// In	MPC transmit delay
	.mpc_sel_ttc_bx0		(mpc_sel_ttc_bx0),				// In	MPC gets ttc_bx0 or bx0_local
	.pretrig_halt			(pretrig_halt),					// In	Pretrigger and halt until unhalt arrives

	.uptime					(uptime[15:0]),						// Out	Uptime since last hard reset
	.bd_status				(bd_status[14:0]),					// In	Board status summary

	.board_id				(board_id[MXBDID-1:0]),				// In	Board ID = VME Slot
	.csc_id					(csc_id[MXCSC-1:0]),				// In	CSC Chamber ID number
	.run_id					(run_id[MXRID-1:0]),				// In	Run ID

	.l1a_delay				(l1a_delay[MXL1DELAY-1:0]),			// In	Level1 Accept delay from pretrig status output
	.l1a_internal			(l1a_internal),						// In	Generate internal Level 1, overrides external
	.l1a_internal_dly		(l1a_internal_dly[MXL1WIND-1:0]),	// In	 Delay internal l1a to shift position in l1a match windwow
	.l1a_window				(l1a_window[MXL1WIND-1:0]),			// In	Level1 Accept window width after delay
	.l1a_win_pri_en			(l1a_win_pri_en),					// In	Enable L1A window priority
	.l1a_lookback			(l1a_lookback[MXBADR-1:0]),			// In	Bxn to look back from l1a wr_buf_adr
	.l1a_preset_sr			(l1a_preset_sr),					// In	Dummy VME bit to feign preset l1a sr group

	.l1a_allow_match		(l1a_allow_match),					// In	Readout allows tmb trig pulse in L1A window (normal mode)
	.l1a_allow_notmb		(l1a_allow_notmb),					// In	Readout allows no tmb trig pulse in L1A window
	.l1a_allow_nol1a		(l1a_allow_nol1a),					// In	Readout allows tmb trig pulse outside L1A window
	.l1a_allow_alct_only	(l1a_allow_alct_only),				// In	Allow alct_only events to readout at L1A

	.fifo_mode				(fifo_mode[MXFMODE-1:0]),			// In	FIFO Mode 0=no dump,1=full,2=local,3=sync
	.fifo_tbins_cfeb		(fifo_tbins_cfeb[MXTBIN-1:0]),		// In	Number CFEB FIFO time bins to read out
	.fifo_pretrig_cfeb		(fifo_pretrig_cfeb[MXTBIN-1:0]),	// In	Number CFEB FIFO time bins before pretrigger

	.seq_trigger			(seq_trigger),						// Out	Sequencer requests L1A from CCB
	.sequencer_state		(sequencer_state[11:0]),			// Out	Sequencer state for vme
        .seq_trigger_nodeadtime (seq_trigger_nodeadtime),  //IN no dead time for seq-trigger

	.event_clear_vme		(event_clear_vme),					// In	Event clear for aff,clct,mpc vme diagnostic registers
	.clct0_vme				(clct0_vme[MXCLCT-1:0]),			// Out	First  CLCT
	.clct1_vme				(clct1_vme[MXCLCT-1:0]),			// Out	Second CLCT
	.clctc_vme				(clctc_vme[MXCLCTC-1:0]),			// Out	Common to CLCT0/1 to TMB
	.clctf_vme				(clctf_vme[MXCFEB-1:0]),			// Out	Active cfeb list from TMB match
	.trig_source_vme		(trig_source_vme[10:0]),			// Out	Trigger source readback
	.nlayers_hit_vme		(nlayers_hit_vme[2:0]),				// Out	Number layers hit on layer trigger
	.bxn_clct_vme			(bxn_clct_vme[MXBXN-1:0]),			// Out	CLCT BXN at pre-trigger
	.bxn_l1a_vme			(bxn_l1a_vme[MXBXN-1:0]),			// Out	CLCT BXN at L1A

  .clct0_vme_bnd   (clct0_vme_bnd[MXBNDB - 1   : 0]), // Out, clct0 new bending 
  .clct0_vme_xky   (clct0_vme_xky[MXXKYB-1 : 0]),     // Out, clct0 new position with 1/8 strip resolution

  .clct1_vme_bnd   (clct1_vme_bnd[MXBNDB - 1   : 0]),  // out 
  .clct1_vme_xky   (clct1_vme_xky[MXXKYB-1 : 0]),     // out
// RPC VME Configuration Ports
	.rpc_exists				(rpc_exists[MXRPC-1:0]),			// In	RPC Readout list
	.rpc_read_enable		(rpc_read_enable),					// In	1 Enable RPC Readout
	.fifo_tbins_rpc			(fifo_tbins_rpc[MXTBIN-1:0]),		// In	Number RPC FIFO time bins to read out
	.fifo_pretrig_rpc		(fifo_pretrig_rpc[MXTBIN-1:0]),		// In	Number RPC FIFO time bins before pretrigger

// Status signals to CCB front panel
	.clct_status			(clct_status[8:0]),					// Out	Array of stat_ signals for CCB

// Scintillator Veto
	.scint_veto_clr			(scint_veto_clr),					// In	Clear scintillator veto ff
	.scint_veto				(scint_veto),						// Out	Scintillator veto for FAST Sites
	.scint_veto_vme			(scint_veto_vme),					// Out	Scintillator veto for FAST Sites, VME copy

// Front Panel CLCT LEDs:
	.led_lct				(led_lct),							// Out	LCT		Blue	LCT match
	.led_alct				(led_alct),							// Out	ALCT	Green	ALCT valid pattern
	.led_clct				(led_clct),							// Out	CLCT	Green	CLCT valid pattern
	.led_l1a_intime			(led_l1a_intime),					// Out	L1A		Green	Level 1 Accept from CCB or internal
	.led_invpat				(led_invpat),						// Out	INVP	Amber	Invalid pattern after drift delay
	.led_nomatch			(led_nomatch),						// Out	NMAT	Amber	ALCT or CLCT but no match
	.led_nol1a_flush		(led_nol1a_flush),					// Out	NL1A	Red		L1A did not arrive in window

// On Board LEDs
	.led_bd					(led_bd[7:0]),						// Out	On-board LEDs

// Buffer Write Control
	.buf_reset				(buf_reset),						// Out	Free all buffer space
	.buf_push				(buf_push),							// Out	Allocate write buffer
	.buf_push_adr			(buf_push_adr[MXBADR-1:0]),			// Out	Address of write buffer to allocate	
	.buf_push_data			(buf_push_data[MXBDATA-1:0]),		// Out	Data associated with push_adr

	.wr_buf_ready			(wr_buf_ready),						// In	Write buffer is ready
	.wr_buf_adr				(wr_buf_adr[MXBADR-1:0]),			// In	Current address of header write buffer

// Fence buffer adr and data at head of queue
	.buf_queue_adr			(buf_queue_adr[MXBADR-1:0]),		// In	Buffer address of fence queued for readout
	.buf_queue_data			(buf_queue_data[MXBDATA-1:0]),		// In	Data associated with queue adr

// Buffer Read Control
	.buf_pop				(buf_pop),							// Out	Specified buffer is to be released
	.buf_pop_adr			(buf_pop_adr[MXBADR-1:0]),			// Out	Address of read buffer to release

// Buffer Status
	.buf_q_full				(buf_q_full),						// In	All raw hits ram in use, ram writing must stop
	.buf_q_empty			(buf_q_empty),						// In	No fences remain on buffer stack
	.buf_q_ovf_err			(buf_q_ovf_err),					// In	Tried to push when stack full
	.buf_q_udf_err			(buf_q_udf_err),					// In	Tried to pop when stack empty
	.buf_q_adr_err			(buf_q_adr_err),					// In	Fence adr popped from stack doesnt match rls adr
	.buf_stalled			(buf_stalled),						// In	Buffer write pointer hit a fence and is stalled now
	.buf_stalled_once		(buf_stalled_once),					// In	Buffer stalled at least once since last resync
	.buf_fence_dist			(buf_fence_dist[MXBADR-1:0]),		// In	Current distance to next fence 0 to 2047
	.buf_fence_cnt			(buf_fence_cnt[MXBADR-1+1:0]),		// In	Number of fences in fence RAM currently
	.buf_fence_cnt_peak		(buf_fence_cnt_peak[MXBADR-1+1:0]),	// In	Peak number of fences in fence RAM
	.buf_display			(buf_display[7:0]),					// In	Buffer fraction in use display

// CFEB Sequencer Readout Control
	.rd_start_cfeb			(rd_start_cfeb),				// Out	Initiates a FIFO readout
	.rd_abort_cfeb			(rd_abort_cfeb),				// Out	Abort FIFO dump
	.rd_list_cfeb			(rd_list_cfeb[MXCFEB-1:0]),		// Out	List of CFEBs to read out
	.rd_ncfebs				(rd_ncfebs[MXCFEBB-1:0]),		// Out	Number of CFEBs in feb_list (4 or 5 depending on CSC type)
	.rd_fifo_adr			(rd_fifo_adr[RAM_ADRB-1:0]),	// Out	RAM address at pre-trig, must be valid 1bx before rd_start

// CFEB Blockedbits Readout Control
	.rd_start_bcb			(rd_start_bcb),					// Out	Start readout sequence
	.rd_abort_bcb			(rd_abort_bcb),					// Out	Cancel readout
	.rd_list_bcb			(rd_list_bcb[MXCFEB-1:0]),		// Out	List of CFEBs to read out
	.rd_ncfebs_bcb			(rd_ncfebs_bcb[MXCFEBB-1:0]),	// Out	Number of CFEBs in bcb_list (0 to 5)

// RPC Sequencer Readout Control
	.rd_start_rpc			(rd_start_rpc),					// Out	Start readout sequence
	.rd_abort_rpc			(rd_abort_rpc),					// Out	Cancel readout
	.rd_list_rpc			(rd_list_rpc[MXRPC-1:0]),		// Out	List of RPCs to read out
	.rd_nrpcs				(rd_nrpcs[MXRPCB-1+1:0]),		// Out	Number of RPCs in rpc_list (0 or 1-to-2 depending on CSC type)
	.rd_rpc_offset			(rd_rpc_offset[RAM_ADRB-1:0]),	// Out	RAM address rd_fifo_adr offset for rpc read out
	.clct_pretrig			(clct_pretrig),					// Out	Pre-trigger marker at (clct_sm==pretrig)

// CFEB Sequencer Frame
	.cfeb_first_frame		(cfeb_first_frame),				// In	First frame valid 2bx after rd_start
	.cfeb_last_frame		(cfeb_last_frame),				// In	Last frame valid 1bx after busy goes down
	.cfeb_adr				(cfeb_adr[MXCFEBB-1:0]),		// In	FIFO dump CFEB ID
	.cfeb_tbin				(cfeb_tbin[MXTBIN-1:0]),		// In	FIFO dump Time Bin #
	.cfeb_rawhits			(cfeb_rawhits[7:0]),			// In	Layer data from FIFO
	.cfeb_fifo_busy			(cfeb_fifo_busy),				// In	Readout busy sending data to sequencer, goes down 1bx

// CFEB Blockedbits Frame
	.bcb_read_enable		(bcb_read_enable),				// In	Enable blocked bits in readout
	.bcb_first_frame		(bcb_first_frame),				// In	First frame valid 2bx after rd_start
	.bcb_last_frame			(bcb_last_frame),				// In	Last frame valid 1bx after busy goes down
	.bcb_blkbits			(bcb_blkbits[11:0]),			// In	CFEB blocked bits frame data
	.bcb_cfeb_adr			(bcb_cfeb_adr[MXCFEBB-1:0]),	// In	CFEB ID	
	.bcb_fifo_busy			(bcb_fifo_busy),				// In	Readout busy sending data to sequencer, goes down 1bx early

// RPC Sequencer Frame
	.rpc_first_frame		(rpc_first_frame),				// In	First frame valid 2bx after rd_start
	.rpc_last_frame			(rpc_last_frame),				// In	Last frame valid 1bx after busy goes down
	.rpc_adr				(rpc_adr[MXRPCB-1:0]),			// In	FIFO dump RPC ID
	.rpc_tbinbxn			(rpc_tbinbxn[MXTBIN-1:0]),		// In	FIFO dump RPC tbin or bxn for DMB
	.rpc_rawhits			(rpc_rawhits[7:0]),				// In	FIFO dump RPC pad hits, 8 of 16 per cycle
	.rpc_fifo_busy			(rpc_fifo_busy),				// In	Readout busy sending data to sequencer, goes down 1bx

// CLCT Raw Hits RAM
	.dmb_wr					(dmb_wr),						// In	Raw hits RAM VME write enable
	.dmb_reset				(dmb_reset),					// In	Raw hits RAM VME address reset
	.dmb_adr				(dmb_adr[MXRAMADR-1:0]),		// In	Raw hits RAM VME read/write address
	.dmb_wdata				(dmb_wdata[MXRAMDATA-1:0]),		// In	Raw hits RAM VME write data
	.dmb_rdata				(dmb_rdata[MXRAMDATA-1:0]),		// Out	Raw hits RAM VME read data
	.dmb_wdcnt				(dmb_wdcnt[MXRAMADR-1:0]),		// Out	Raw hits RAM VME word count
	.dmb_busy				(dmb_busy),						// Out	Raw hits RAM VME busy writing DMB data
	.read_sm_xdmb			(read_sm_xdmb),					// Out	TMB sequencer starting a readout

// TMB-Sequencer Pipelines
	.wr_adr_xtmb			(wr_adr_xtmb[MXBADR-1:0]),		// Out	Buffer write address after drift time
	.wr_adr_rtmb			(wr_adr_rtmb[MXBADR-1:0]),		// In	Buffer write address at TMB matching time
	.wr_adr_xmpc			(wr_adr_xmpc[MXBADR-1:0]),		// In	Buffer write address at MPC xmit to sequencer
	.wr_adr_rmpc			(wr_adr_rmpc[MXBADR-1:0]),		// In	Buffer write address at MPC received

	.wr_push_xtmb			(wr_push_xtmb),					// Out	Buffer write strobe after drift time
	.wr_push_rtmb			(wr_push_rtmb),					// In	Buffer write strobe at TMB matching time
	.wr_push_xmpc			(wr_push_xmpc),					// In	Buffer write strobe at MPC xmit to sequencer
	.wr_push_rmpc			(wr_push_rmpc),					// In	Buffer write strobe at MPC received

	.wr_avail_xtmb			(wr_avail_xtmb),				// Out	Buffer available after drift time
	.wr_avail_rtmb			(wr_avail_rtmb),				// In	Buffer available at TMB matching time
	.wr_avail_xmpc			(wr_avail_xmpc),				// In	Buffer available at MPC xmit to sequencer
	.wr_avail_rmpc			(wr_avail_rmpc),				// In	Buffer available at MPC received

// TMB LCT Match results
	.clct0_xtmb				(clct0_xtmb[MXCLCT-1:0]),		// Out	First  CLCT
	.clct1_xtmb				(clct1_xtmb[MXCLCT-1:0]),		// Out	Second CLCT
	.clctc_xtmb				(clctc_xtmb[MXCLCTC-1:0]),		// Out	Common to CLCT0/1 to TMB
	.clctf_xtmb				(clctf_xtmb[MXCFEB-1:0]),		// Out	Active cfeb list to TMB
        //CCLUT, Tao  
        .clct0_bnd_xtmb   (clct0_bnd_xtmb[MXBNDB - 1   : 0]),
        .clct0_xky_xtmb   (clct0_xky_xtmb[MXXKYB-1 : 0]),
        .clct1_bnd_xtmb   (clct1_bnd_xtmb[MXBNDB - 1   : 0]),
        .clct1_xky_xtmb   (clct1_xky_xtmb[MXXKYB-1 : 0]),

	.bx0_xmpc				(bx0_xmpc),						// Out	bx0 to tmb aligned with clct0/1
	.bx0_match				(bx0_match),					// In	ALCT bx0 and CLCT bx0 match in time
	.bx0_match2				(bx0_match2),					// In	ALCT bx0 and CLCT bx0 match in time

	.tmb_trig_pulse			(tmb_trig_pulse),				// In	ALCT or CLCT or both triggered
	.tmb_trig_keep			(tmb_trig_keep),				// In	ALCT or CLCT or both triggered, and trigger is allowed
	.tmb_non_trig_keep		(tmb_non_trig_keep),			// In	Event did not trigger, but keep it for readout
	.tmb_match				(tmb_match),					// In	ALCT and CLCT matched in time
	.tmb_alct_only			(tmb_alct_only),				// In	Only ALCT triggered
	.tmb_clct_only			(tmb_clct_only),				// In	Only CLCT triggered
	.tmb_match_win			(tmb_match_win[3:0]),			// In	Location of alct in clct window
	.tmb_match_pri			(tmb_match_pri[3:0]),			// In	Priority of clct in clct window
	.tmb_alct_discard		(tmb_alct_discard),				// In	ALCT pair was not used for LCT
	.tmb_clct_discard		(tmb_clct_discard),				// In	CLCT pair was not used for LCT
	.tmb_clct0_discard		(tmb_clct0_discard),			// In	CLCT0 was not used for LCT because from ME1A
	.tmb_clct1_discard		(tmb_clct1_discard),			// In	CLCT1 was not used for LCT because from ME1A
	.tmb_aff_list			(tmb_aff_list[MXCFEB-1:0]),		// In	Active CFEBs for CLCT used in TMB match

	.tmb_match_ro			(tmb_match_ro),					// In	ALCT and CLCT matched in time, non-triggering readout
	.tmb_alct_only_ro		(tmb_alct_only_ro),				// In	Only ALCT triggered, non-triggering readout
	.tmb_clct_only_ro		(tmb_clct_only_ro),				// In	Only CLCT triggered, non-triggering readout

	.tmb_no_alct			(tmb_no_alct),					// In	No  ALCT
	.tmb_no_clct			(tmb_no_clct),					// In	No  CLCT
	.tmb_one_alct			(tmb_one_alct),					// In	One ALCT
	.tmb_one_clct			(tmb_one_clct),					// In	One CLCT
	.tmb_two_alct			(tmb_two_alct),					// In	Two ALCTs
	.tmb_two_clct			(tmb_two_clct),					// In	Two CLCTs
	.tmb_dupe_alct			(tmb_dupe_alct),				// In	ALCT0 copied into ALCT1 to make 2nd LCT
	.tmb_dupe_clct			(tmb_dupe_clct),				// In	CLCT0 copied into CLCT1 to make 2nd LCT
	.tmb_rank_err			(tmb_rank_err),					// In	LCT1 has higher quality than LCT0

	.tmb_alct0				(tmb_alct0[10:0]),				// In	ALCT best muon latched at trigger
	.tmb_alct1				(tmb_alct1[10:0]),				// In	ALCT second best muon latched at trigger
	.tmb_alctb				(tmb_alctb[4:0]),				// In	ALCT bxn latched at trigger
	.tmb_alcte				(tmb_alcte[1:0]),				// In	ALCT ecc error syndrome latched at trigger
        .tmb_hmt_match_win         (tmb_hmt_match_win[3:0]), //In  alct/anode hmt in cathode hmt tagged window
       .hmt_nhits_sig_ff (hmt_nhits_sig_ff[NHMTHITB-1:0]), // In hmt nhits for header

        //Enable CCLUT or not
        .ccLUT_enable       (ccLUT_enable),  // In
        .run3_trig_df       (run3_trig_df), // output, enable run3 trigger format or not
        .run3_daq_df        (run3_daq_df),  // output, enable run3 daq format or not
// MPC Status
	.mpc_frame_ff			(mpc_frame_ff),					// In	MPC frame latch strobe
	.mpc0_frame0_ff			(mpc0_frame0_ff[MXFRAME-1:0]),	// In	MPC best muon 1st frame
	.mpc0_frame1_ff			(mpc0_frame1_ff[MXFRAME-1:0]),	// In	MPC best buon 2nd frame
	.mpc1_frame0_ff			(mpc1_frame0_ff[MXFRAME-1:0]),	// In	MPC second best muon 1st frame
	.mpc1_frame1_ff			(mpc1_frame1_ff[MXFRAME-1:0]),	// In	MPC second best buon 2nd frame
	
	.mpc_xmit_lct0			(mpc_xmit_lct0),				// In	MPC LCT0 sent
	.mpc_xmit_lct1			(mpc_xmit_lct1),				// In	MPC LCT1 sent

	.mpc_response_ff		(mpc_response_ff),				// In	MPC accept latch strobe
	.mpc_accept_ff			(mpc_accept_ff[1:0]),			// In	MPC muon accept response, latched
	.mpc_reserved_ff		(mpc_reserved_ff[1:0]),			// In	MPC reserved

// TMB Status
	.alct0_vpf_tprt			(alct0_vpf_tprt),				// In	Timing test point, unbuffered real time for internal scope
	.alct1_vpf_tprt			(alct1_vpf_tprt),				// In	Timing test point
	.clct_vpf_tprt			(clct_vpf_tprt),				// In	Timing test point
	.clct_window_tprt		(clct_window_tprt),				// In	Timing test point

// Firmware Version
	.revcode				(revcode[14:0]),				// In	Firmware revision code

// RPC/ALCT Scope
	.scp_rpc0_bxn			(scp_rpc0_bxn[2:0]),			// In	RPC0 bunch crossing number
	.scp_rpc1_bxn			(scp_rpc1_bxn[2:0]),			// In	RPC1 bunch crossing number
	.scp_rpc0_nhits			(scp_rpc0_nhits[3:0]),			// In	RPC0 number of pads hit
	.scp_rpc1_nhits			(scp_rpc1_nhits[3:0]),			// In	RPC1 number of pads hit
	.scp_alct_rx			(scp_alct_rx[55:0]),			// In	ALCT received signals to scope

// Scope
	.scp_runstop			(scp_runstop),					// In	1=run 0=stop
	.scp_auto				(scp_auto),						// In	Sequencer readout mode
	.scp_ch_trig_en			(scp_ch_trig_en),				// In	Enable channel triggers
	.scp_trigger_ch			(scp_trigger_ch[7:0]),			// In	Trigger channel 0-159
	.scp_force_trig			(scp_force_trig),				// In	Force a trigger
	.scp_ch_overlay			(scp_ch_overlay),				// In	Channel source overlay
	.scp_ram_sel			(scp_ram_sel[3:0]),				// In	RAM bank select in VME mode
	.scp_tbins				(scp_tbins[2:0]),				// In	Time bins per channel code, actual tbins/ch = (tbins+1)*64
	.scp_radr				(scp_radr[8:0]),				// In	Channel data read address
	.scp_nowrite			(scp_nowrite),					// In	Preserves initial RAM contents for testing

	.scp_waiting			(scp_waiting),					// Out	Waiting for trigger
	.scp_trig_done			(scp_trig_done),				// Out	Trigger done, ready for readout 
	.scp_rdata				(scp_rdata[15:0]),				// Out	Recorded channel data

// Miniscope
	.mini_read_enable		(mini_read_enable),					// In	Enable Miniscope readout
	.mini_fifo_busy			(mini_fifo_busy),					// In	Readout busy sending data to sequencer, goes down 1bx early
	.mini_first_frame		(mini_first_frame),					// In	First frame valid 2bx after rd_start
	.mini_last_frame		(mini_last_frame),					// In	Last frame valid 1bx after busy goes down
	.mini_rdata				(mini_rdata[RAM_WIDTH*2-1:0]),		// In	FIFO dump miniscope
	.fifo_wdata_mini		(fifo_wdata_mini[RAM_WIDTH*2-1:0]),	// Out	Miniscope FIFO RAM write data
	.wr_mini_offset			(wr_mini_offset[RAM_ADRB-1:0]),		// Out	RAM address offset for miniscope write

// Mini Sequencer Readout Control
	.rd_start_mini			(rd_start_mini),					// Out	Start readout sequence
	.rd_abort_mini			(rd_abort_mini),					// Out	Cancel readout
	.rd_mini_offset			(rd_mini_offset[RAM_ADRB-1:0]),		// Out	RAM address rd_fifo_adr offset for miniscope read out

// Trigger/Readout Counters
	.cnt_all_reset			(cnt_all_reset),					// In	Trigger/Readout counter reset
	.cnt_stop_on_ovf		(cnt_stop_on_ovf),					// In	Stop all counters if any overflows
	.cnt_non_me1ab_en		(cnt_non_me1ab_en),					// In	Allow clct pretrig counters count non me1ab
	.cnt_any_ovf_alct		(cnt_any_ovf_alct),					// In	At least one alct counter overflowed
	.cnt_any_ovf_seq		(cnt_any_ovf_seq),					// Out	At least one sequencer counter overflowed

	.event_counter13		(event_counter13[MXCNTVME-1:0]),	// Out
	.event_counter14		(event_counter14[MXCNTVME-1:0]),	// Out
	.event_counter15		(event_counter15[MXCNTVME-1:0]),	// Out
	.event_counter16		(event_counter16[MXCNTVME-1:0]),	// Out
	.event_counter17		(event_counter17[MXCNTVME-1:0]),	// Out
	.event_counter18		(event_counter18[MXCNTVME-1:0]),	// Out
	.event_counter19		(event_counter19[MXCNTVME-1:0]),	// Out
	.event_counter20		(event_counter20[MXCNTVME-1:0]),	// Out
	.event_counter21		(event_counter21[MXCNTVME-1:0]),	// Out
	.event_counter22		(event_counter22[MXCNTVME-1:0]),	// Out
	.event_counter23		(event_counter23[MXCNTVME-1:0]),	// Out
	.event_counter24		(event_counter24[MXCNTVME-1:0]),	// Out
	.event_counter25		(event_counter25[MXCNTVME-1:0]),	// Out
	.event_counter26		(event_counter26[MXCNTVME-1:0]),	// Out
	.event_counter27		(event_counter27[MXCNTVME-1:0]),	// Out
	.event_counter28		(event_counter28[MXCNTVME-1:0]),	// Out
	.event_counter29		(event_counter29[MXCNTVME-1:0]),	// Out
	.event_counter30		(event_counter30[MXCNTVME-1:0]),	// Out
	.event_counter31		(event_counter31[MXCNTVME-1:0]),	// Out
	.event_counter32		(event_counter32[MXCNTVME-1:0]),	// Out
	.event_counter33		(event_counter33[MXCNTVME-1:0]),	// Out
	.event_counter34		(event_counter34[MXCNTVME-1:0]),	// Out
	.event_counter35		(event_counter35[MXCNTVME-1:0]),	// Out
	.event_counter36		(event_counter36[MXCNTVME-1:0]),	// Out
	.event_counter37		(event_counter37[MXCNTVME-1:0]),	// Out
	.event_counter38		(event_counter38[MXCNTVME-1:0]),	// Out
	.event_counter39		(event_counter39[MXCNTVME-1:0]),	// Out
	.event_counter40		(event_counter40[MXCNTVME-1:0]),	// Out
	.event_counter41		(event_counter41[MXCNTVME-1:0]),	// Out
	.event_counter42		(event_counter42[MXCNTVME-1:0]),	// Out
	.event_counter43		(event_counter43[MXCNTVME-1:0]),	// Out
	.event_counter44		(event_counter44[MXCNTVME-1:0]),	// Out
	.event_counter45		(event_counter45[MXCNTVME-1:0]),	// Out
	.event_counter46		(event_counter46[MXCNTVME-1:0]),	// Out
	.event_counter47		(event_counter47[MXCNTVME-1:0]),	// Out
	.event_counter48		(event_counter48[MXCNTVME-1:0]),	// Out
	.event_counter49		(event_counter49[MXCNTVME-1:0]),	// Out
	.event_counter50		(event_counter50[MXCNTVME-1:0]),	// Out
	.event_counter51		(event_counter51[MXCNTVME-1:0]),	// Out
	.event_counter52		(event_counter52[MXCNTVME-1:0]),	// Out
	.event_counter53		(event_counter53[MXCNTVME-1:0]),	// Out
	.event_counter54		(event_counter54[MXCNTVME-1:0]),	// Out
	.event_counter55		(event_counter55[MXCNTVME-1:0]),	// Out
	.event_counter56		(event_counter56[MXCNTVME-1:0]),	// Out
	.event_counter57		(event_counter57[MXCNTVME-1:0]),	// Out
	.event_counter58		(event_counter58[MXCNTVME-1:0]),	// Out
	.event_counter59		(event_counter59[MXCNTVME-1:0]),	// Out
	.event_counter60		(event_counter60[MXCNTVME-1:0]),	// Out
	.event_counter61		(event_counter61[MXCNTVME-1:0]),	// Out
	.event_counter62		(event_counter62[MXCNTVME-1:0]),	// Out
	.event_counter63		(event_counter63[MXCNTVME-1:0]),	// Out
	.event_counter64		(event_counter64[MXCNTVME-1:0]),	// Out
	.event_counter65		(event_counter65[MXCNTVME-1:0]),	// Out

// CLCT pre-trigger coincidence counters
  .preClct_l1a_counter   (preClct_l1a_counter[MXCNTVME-1:0]),  // Out
  .preClct_alct_counter  (preClct_alct_counter[MXCNTVME-1:0]), // Out
  
// Active CFEB(s) counters
  .active_cfebs_event_counter      (active_cfebs_event_counter[MXCNTVME-1:0]),      // Out
  .active_cfeb0_event_counter      (active_cfeb0_event_counter[MXCNTVME-1:0]),      // Out
  .active_cfeb1_event_counter      (active_cfeb1_event_counter[MXCNTVME-1:0]),      // Out
  .active_cfeb2_event_counter      (active_cfeb2_event_counter[MXCNTVME-1:0]),      // Out
  .active_cfeb3_event_counter      (active_cfeb3_event_counter[MXCNTVME-1:0]),      // Out
  .active_cfeb4_event_counter      (active_cfeb4_event_counter[MXCNTVME-1:0]),      // Out

  .bx0_match_counter  (bx0_match_counter),// Out

// Header Counters
	.hdr_clear_on_resync	(hdr_clear_on_resync),				// In	Clear header counters on ttc_resync
	.pretrig_counter		(pretrig_counter[MXCNTVME-1:0]),	// Out	Pre-trigger counter
	.clct_counter			(clct_counter[MXCNTVME-1:0]),		// Out	CLCT counter
	.alct_counter			(alct_counter[MXCNTVME-1:0]),		// Out	ALCTs received counter
	.trig_counter			(trig_counter[MXCNTVME-1:0]),		// Out	TMB trigger counter
	.l1a_rx_counter			(l1a_rx_counter[MXL1ARX-1:0]),		// Out	L1As received from ccb counter
	.readout_counter		(readout_counter[MXL1ARX-1:0]),		// Out	Readout counter
	.orbit_counter			(orbit_counter[MXORBIT-1:0]),		// Out	Orbit counter

// Parity Errors
	.perr_pulse				(perr_pulse),						// In	Parity error pulse for counting
	.perr_cfeb_ff			(perr_cfeb_ff[MXCFEB-1:0]),			// In	CFEB RAM parity error, latched
	.perr_rpc_ff			(perr_rpc_ff),						// In	RPC  RAM parity error, latched
	.perr_mini_ff			(perr_mini_ff),						// In	Mini RAM parity error, latched
	.perr_ff				(perr_ff),							// In	Parity error summary,  latched

// VME debug register latches
	.deb_wr_buf_adr			(deb_wr_buf_adr[MXBADR-1:0]),		// Out	Buffer write address at last pretrig
	.deb_buf_push_adr		(deb_buf_push_adr[MXBADR-1:0]),		// Out	Queue push address at last push
	.deb_buf_pop_adr		(deb_buf_pop_adr[MXBADR-1:0]),		// Out	Queue pop  address at last pop
	.deb_buf_push_data		(deb_buf_push_data[MXBDATA-1:0]),	// Out	Queue push data at last push
	.deb_buf_pop_data		(deb_buf_pop_data[MXBDATA-1:0]),	// Out	Queue pop  data at last pop

// Sump
	.sequencer_sump			(sequencer_sump)					// Out	Unused signals
	);

//-------------------------------------------------------------------------------------------------------------------
//	RPC Instantiation
//-------------------------------------------------------------------------------------------------------------------
// RPC Injector
	wire	[MXRPC-1:0]		rpc_inj_wen;					// 1=Write enable injector RAM
	wire	[9:0]			rpc_inj_rwadr;					// Injector RAM read/write address
	wire	[MXRPCDB-1:0]	rpc_inj_wdata;					// Injector RAM write data
	wire	[MXRPC-1:0]		rpc_inj_ren;					// 1=Read enable Injector RAM
	wire	[MXRPCDB-1:0]	rpc_inj_rdata;					// Injector RAM read data

// RPC raw hits delay
	wire	[3:0]			rpc0_delay;
	wire	[3:0]			rpc1_delay;

// Raw Hits FIFO RAM Ports
	wire	[RAM_ADRB-1:0]		fifo_radr_rpc;				// FIFO RAM read tbin address
	wire	[0:0]				fifo_sel_rpc;				// FIFO RAM read layer address 0-1
	wire	[RAM_WIDTH-1+4:0]	fifo0_rdata_rpc;			// FIFO RAM read data
	wire	[RAM_WIDTH-1+4:0]	fifo1_rdata_rpc;			// FIFO RAM read data

// RPC Raw hits VME Readback
	wire	[MXRPCB-1:0]	rpc_bank;						// RPC bank address
	wire	[15:0]			rpc_rdata;						// RPC RAM read data
	wire	[2:0]			rpc_rbxn;						// RPC RAM read bxn

// RPC Hot Channel Mask
	wire	[MXRPCPAD-1:0]	rpc0_hcm;						// 1=enable RPC pad
	wire	[MXRPCPAD-1:0]	rpc1_hcm;						// 1=enable RPC pad

// RPC Bxn Offset
	wire	[3:0]			rpc_bxn_offset;					// RPC bunch crossing offset
	wire	[3:0]			rpc0_bxn_diff;					// RPC - offset
	wire	[3:0]			rpc1_bxn_diff;					// RPC - offset

// Status
	wire	[4:0]			parity_err_rpc;					// Raw hits RAM parity error detected


/* JGedit, comment out module rpc call: 
	rpc	urpc
	(
// RAT Module Signals
	.clock					(clock),						// In	40MHz TMB main
	.global_reset			(global_reset),					// In	Global reset
	.rpc_rx					(rpc_rx[37:0]),					// In	RPC data inputs 80MHz DDR			
	.rpc_smbrx				(rpc_smbrx),					// In	SMB receive data
	.rpc_tx					(rpc_tx[3:0]),					// Out	RPC control output

// RAT Control
	.rpc_sync				(rpc_sync),						// In	Sync mode
	.rpc_posneg				(rpc_posneg),					// In	Clock phase
	.rpc_loop_tmb			(rpc_loop_tmb),					// In	Loop mode (loops in RAT Spartan)
	.rpc_free_tx0			(rpc_free_tx0),					// In	Unassigned
	.smb_data_rat			(smb_data_rat),					// Out	RAT smb_data

// RPC Ports: RAT 3D3444 Delay Signals
	.dddr_clock				(dddr_clock),					// In	DDDR clock			/ rpc_sync
	.dddr_adr_latch			(dddr_adr_latch),				// In	DDDR address latch	/ rpc_posneg
	.dddr_serial_in			(dddr_serial_in),				// In	DDDR serial in		/ rpc_loop_tmb
	.dddr_busy				(dddr_busy),					// In	DDDR busy			/ rpc_free_tx0

// RAT Serial Number
	.rat_sn_out				(rat_sn_out),					// In	RAT serial number, out = rpc_posneg
	.rat_dsn_en				(rat_dsn_en),					// In	RAT dsn enable

// RPC Injector
	.mask_all				(rpc_mask_all),					// In	1=Enable, 0=Turn off all RPC inputs
	.injector_go_rpc		(injector_go_rpc),				// In	1=Start RPC pattern injector
	.injector_go_rat		(injector_go_rat),				// In	1=Start RAT pattern injector
	.inj_last_tbin			(inj_last_tbin[11:0]),			// In	Last tbin, may wrap past 1024 ram adr
	.rpc_tbins_test			(rpc_tbins_test),				// In	Set write_data=address
	.inj_wen				(rpc_inj_wen[MXRPC-1:0]),		// In	1=Write enable injector RAM
	.inj_rwadr				(rpc_inj_rwadr[9:0]),			// In	Injector RAM read/write address
	.inj_wdata				(rpc_inj_wdata[MXRPCDB-1:0]),	// In	Injector RAM write data
	.inj_ren				(rpc_inj_ren[MXRPC-1:0]),		// In	1=Read enable Injector RAM
	.inj_rdata				(rpc_inj_rdata[MXRPCDB-1:0]),	// Out	Injector RAM read data

// RPC raw hits delay
	.rpc0_delay				(rpc0_delay[3:0]),				/// In	RPC0 raw hits delay
	.rpc1_delay				(rpc1_delay[3:0]),				/// In	RPC1 raw hits delay

// Raw Hits FIFO RAM Ports
	.fifo_wen				(fifo_wen),						// In	1=Write enable FIFO RAM
	.fifo_wadr				(fifo_wadr[RAM_ADRB-1:0]),		// In	FIFO RAM write address
	.fifo_radr				(fifo_radr_rpc[RAM_ADRB-1:0]),	// In	FIFO RAM read address
	.fifo_sel				(fifo_sel_rpc[0:0]),			// In	FIFO RAM select bank 0-4
	.fifo0_rdata			(fifo0_rdata_rpc[RAM_WIDTH-1+4:0]),// Out	FIFO RAM read data
	.fifo1_rdata			(fifo1_rdata_rpc[RAM_WIDTH-1+4:0]),// Out	FIFO RAM read data

// RPC Scope
	.scp_rpc0_bxn			(scp_rpc0_bxn[2:0]),			// Out	RPC0 bunch crossing number
	.scp_rpc1_bxn			(scp_rpc1_bxn[2:0]),			// Out	RPC1 bunch crossing number
	.scp_rpc0_nhits			(scp_rpc0_nhits[3:0]),			// Out	RPC0 number of pads hit
	.scp_rpc1_nhits			(scp_rpc1_nhits[3:0]),			// Out	RPC1 number of pads hit

// RPC Raw hits VME Readback Ports
	.rpc_bank				(rpc_bank[MXRPCB-1:0]),			// In	RPC bank address
	.rpc_rdata				(rpc_rdata[15:0]),				// Out	RPC RAM read data
	.rpc_rbxn				(rpc_rbxn[2:0]),				// Out	RPC RAM read bxn

// RPC Hot Channel Mask Ports
	.rpc0_hcm				(rpc0_hcm[MXRPCPAD-1:0]),		// In	1=enable RPC pad
	.rpc1_hcm				(rpc1_hcm[MXRPCPAD-1:0]),		// In	1=enable RPC pad

// RPC Bxn Offset
	.rpc_bxn_offset			(rpc_bxn_offset[3:0]),			// In	RPC bunch crossing offset
	.rpc0_bxn_diff			(rpc0_bxn_diff[3:0]),			// Out	RPC - offset
	.rpc1_bxn_diff			(rpc1_bxn_diff[3:0]),			// Out	RPC - offset

// Status Ports
	.clct_pretrig			(clct_pretrig),					// In	Pre-trigger marker at (clct_sm==pretrig)
	.parity_err_rpc			(parity_err_rpc[4:0]),			// Out	Raw hits RAM parity error detected

// Sump
	.rpc_sump				(rpc_sump)						// Out	Unused signals
	);
*/


//-------------------------------------------------------------------------------------------------------------------
//	Miniscope Instantiation
//-------------------------------------------------------------------------------------------------------------------
	wire	[RAM_ADRB-1:0]		fifo_wadr_mini;					// FIFO RAM write tbin address
	wire	[RAM_ADRB-1:0]		fifo_radr_mini;					// FIFO RAM read tbin address
	wire	[RAM_WIDTH*2-1:0]	fifo_rdata_mini;				// FIFO RAM read data
	wire	[1:0]				parity_err_mini;				// Miniscope RAM parity error detected

	assign fifo_wadr_mini = fifo_wadr-wr_mini_offset;			// FIFO RAM read tbin address

	miniscope uminiscope
	(
// Clock
	.clock					(clock),							// In	40MHz TMB main

// Raw Hits FIFO RAM Ports
	.fifo_wen				(fifo_wen),							// In	1=Write enable FIFO RAM
	.fifo_wadr_mini			(fifo_wadr_mini[RAM_ADRB-1:0]),		// In	FIFO RAM write address
	.fifo_radr_mini			(fifo_radr_mini[RAM_ADRB-1:0]),		// In	FIFO RAM read address
	.fifo_wdata_mini		(fifo_wdata_mini[RAM_WIDTH*2-1:0]),	// In	FIFO RAM write data
	.fifo_rdata_mini		(fifo_rdata_mini[RAM_WIDTH*2-1:0]),	// Out	FIFO RAM read data

// Status Ports
	.mini_tbins_test		(mini_tbins_test),					// In	Miniscope data=address for testing
	.parity_err_mini		(parity_err_mini[1:0]),				// Out	Miniscope RAM parity error detected

// Sump
	.mini_sump				(mini_sump)							// Out	Unused signals
	);

//-------------------------------------------------------------------------------------------------------------------
//	Buffer Write Control Instantiation:	Controls CLCT + RPC raw hits RAM write-mode logic
//-------------------------------------------------------------------------------------------------------------------
	buffer_write_ctrl ubuffer_write_ctrl
	(
// CCB Ports
	.clock				(clock),							// In	40MHz TMB main clock
	.ttc_resync			(ttc_resync),						// In	TTC resync

// CFEB Raw Hits FIFO RAM Ports
	.fifo_wen			(fifo_wen),							// Out	1=Write enable FIFO RAM
	.fifo_wadr			(fifo_wadr[RAM_ADRB-1:0]),			// Out	FIFO RAM write address

// CFEB VME Configuration Ports
	.fifo_pretrig_cfeb	(fifo_pretrig_cfeb[MXTBIN-1:0]),	// In	Number FIFO time bins before pretrigger
	.fifo_no_raw_hits	(fifo_no_raw_hits),					// In	1=do not wait to store raw hits

// RPC VME Configuration Ports
	.fifo_pretrig_rpc	(fifo_pretrig_rpc[MXTBIN-1:0]),		// In	Number FIFO time bins before pretrigger

// Sequencer Buffer Write Control
	.buf_reset			(buf_reset),						// In	Free all buffer space
	.buf_push			(buf_push),							// In	Allocate write buffer
	.buf_push_adr		(buf_push_adr[MXBADR-1:0]),			// In	Address of write buffer to allocate	
	.buf_push_data		(buf_push_data[MXBDATA-1:0]),		// In	Data associated with push_adr

	.wr_buf_ready		(wr_buf_ready),						// Out	Write buffer is ready
	.wr_buf_adr			(wr_buf_adr[MXBADR-1:0]),			// Out	Current address of header write buffer

// Fence buffer adr and data at head of queue
	.buf_queue_adr		(buf_queue_adr[MXBADR-1:0]),		// Out	Buffer address of fence queued for readout
	.buf_queue_data		(buf_queue_data[MXBDATA-1:0]),		// Out	Data associated with queue adr

// Sequencer Buffer Read Control
	.buf_pop			(buf_pop),							// In	Specified buffer is to be released
	.buf_pop_adr		(buf_pop_adr[MXBADR-1:0]),			// In	Address of read buffer to release

// Sequencer Buffer Status
	.buf_q_full			(buf_q_full),						// Out	All raw hits ram in use, ram writing must stop
	.buf_q_empty		(buf_q_empty),						// Out	No fences remain on buffer stack
	.buf_q_ovf_err		(buf_q_ovf_err),					// Out	Tried to push when stack full
	.buf_q_udf_err		(buf_q_udf_err),					// Out	Tried to pop when stack empty
	.buf_q_adr_err		(buf_q_adr_err),					// Out	Fence adr popped from stack doesnt match rls adr
	.buf_stalled		(buf_stalled),						// Out	Buffer write pointer hit a fence and is stalled now
	.buf_stalled_once	(buf_stalled_once),					// Out	Buffer stalled at least once since last resync
	.buf_fence_dist		(buf_fence_dist[MXBADR-1:0]),		// Out	Current distance to next fence 0 to 2047
	.buf_fence_cnt		(buf_fence_cnt[MXBADR-1+1:0]),		// Out	Number of fences in fence RAM currently
	.buf_fence_cnt_peak	(buf_fence_cnt_peak[MXBADR-1+1:0]),	// Out	Peak number of fences in fence RAM
	.buf_display		(buf_display[7:0]),					// Out	Buffer fraction in use display
	.buf_sump			(buf_sump) 							// Out	Unused signals
	);

//-------------------------------------------------------------------------------------------------------------------
//	Buffer Read Control Instantiation:	Controls CLCT + RPC raw hits readout
//-------------------------------------------------------------------------------------------------------------------
	buffer_read_ctrl ubuffer_read_ctrl
	(
// CCB Ports
	.clock				(clock),							// In	40MHz TMB main clock
	.ttc_resync			(ttc_resync),						// In	TTC resync

// CLCT Raw Hits FIFO RAM Ports
	.fifo_radr_cfeb		(fifo_radr_cfeb[RAM_ADRB-1:0]),		// Out	FIFO RAM read address
	.fifo_sel_cfeb		(fifo_sel_cfeb[2:0]),				// Out	FIFO RAM read layer address 0-5

// RPC Raw Hits FIFO RAM Ports
	.fifo_radr_rpc		(fifo_radr_rpc[RAM_ADRB-1:0]),		// Out	FIFO RAM read tbin address
	.fifo_sel_rpc		(fifo_sel_rpc[0:0]),				// Out	FIFO RAM read slice address 0-1

// Miniscpe FIFO RAM Ports
	.fifo_radr_mini		(fifo_radr_mini[RAM_ADRB-1:0]),		// Out	FIFO RAM read address

// CFEB Raw Hits Data Ports
	.fifo0_rdata_cfeb	(fifo_rdata[0][RAM_WIDTH-1:0]),		// In	FIFO RAM read data
	.fifo1_rdata_cfeb	(fifo_rdata[1][RAM_WIDTH-1:0]),		// In	FIFO RAM read data
	.fifo2_rdata_cfeb	(fifo_rdata[2][RAM_WIDTH-1:0]),		// In	FIFO RAM read data
	.fifo3_rdata_cfeb	(fifo_rdata[3][RAM_WIDTH-1:0]),		// In	FIFO RAM read data
	.fifo4_rdata_cfeb	(fifo_rdata[4][RAM_WIDTH-1:0]),		// In	FIFO RAM read data

// CFEB Blockedbits Data Ports
	.cfeb0_blockedbits		(cfeb_blockedbits[0]),			// In	1=CFEB rx bit blocked by hcm or went bad, packed
	.cfeb1_blockedbits		(cfeb_blockedbits[1]),			// In	1=CFEB rx bit blocked by hcm or went bad, packed
	.cfeb2_blockedbits		(cfeb_blockedbits[2]),			// In	1=CFEB rx bit blocked by hcm or went bad, packed
	.cfeb3_blockedbits		(cfeb_blockedbits[3]),			// In	1=CFEB rx bit blocked by hcm or went bad, packed
	.cfeb4_blockedbits		(cfeb_blockedbits[4]),			// In	1=CFEB rx bit blocked by hcm or went bad, packed

// RPC Raw hits Data Ports
	.fifo0_rdata_rpc	(fifo0_rdata_rpc[RAM_WIDTH-1+4:0]),	// In	FIFO RAM read data, rpc
	.fifo1_rdata_rpc	(fifo1_rdata_rpc[RAM_WIDTH-1+4:0]),	// In	FIFO RAM read data, rpc

// Miniscope Data Ports
	.fifo_rdata_mini	(fifo_rdata_mini[RAM_WIDTH*2-1:0]),	// In	FIFO RAM read data

// CLCT VME Configuration Ports
	.fifo_tbins_cfeb	(fifo_tbins_cfeb[MXTBIN-1:0]),		// In	Number CFEB FIFO time bins to read out
	.fifo_pretrig_cfeb	(fifo_pretrig_cfeb[MXTBIN-1:0]),	// In	Number CFEB FIFO time bins before pretrigger

// RPC VME Configuration Ports
	.fifo_tbins_rpc		(fifo_tbins_rpc[MXTBIN-1:0]),		// In	Number RPC  FIFO time bins to read out
	.fifo_pretrig_rpc	(fifo_pretrig_rpc[MXTBIN-1:0]),		// In	Number RPC  FIFO time bins before pretrigger

// Minisocpe VME Configuration Ports
	.mini_tbins_word	(mini_tbins_word),					// In	Insert tbins and pretrig tbins in 1st word
	.fifo_tbins_mini	(fifo_tbins_mini[MXTBIN-1:0]),		// In	Number Mini FIFO time bins to read out
	.fifo_pretrig_mini	(fifo_pretrig_mini[MXTBIN-1:0]),	// In	Number Mini FIFO time bins before pretrigger

// CFEB Sequencer Readout Control
	.rd_start_cfeb		(rd_start_cfeb),					// In	Initiates a FIFO readout
	.rd_abort_cfeb		(rd_abort_cfeb),					// In	Abort FIFO dump
	.rd_list_cfeb		(rd_list_cfeb[MXCFEB-1:0]),			// In	List of CFEBs to read out
	.rd_ncfebs			(rd_ncfebs[MXCFEBB-1:0]),			// In	Number of CFEBs in feb_list (4 or 5 depending on CSC type)
	.rd_fifo_adr		(rd_fifo_adr[RAM_ADRB-1:0]),		// In	RAM address at pre-trig, must be valid 1bx before rd_start

// CFEB Blockedbits Readout Control
	.rd_start_bcb		(rd_start_bcb),						// In	Start readout sequence
	.rd_abort_bcb		(rd_abort_bcb),						// In	Cancel readout
	.rd_list_bcb		(rd_list_bcb[MXCFEB-1:0]),			// In	List of CFEBs to read out
	.rd_ncfebs_bcb		(rd_ncfebs_bcb[MXCFEBB-1:0]),		// In	Number of CFEBs in bcb_list (0 to 5)

// RPC Sequencer Readout Control
	.rd_start_rpc		(rd_start_rpc),						// In	Start readout sequence
	.rd_abort_rpc		(rd_abort_rpc),						// In	Cancel readout
	.rd_list_rpc		(rd_list_rpc[MXRPC-1:0]),			// In	List of RPCs to read out
	.rd_nrpcs			(rd_nrpcs[MXRPCB-1+1:0]),			// In	Number of RPCs in rpc_list (0 or 1-to-2 depending on CSC type)
	.rd_rpc_offset		(rd_rpc_offset[RAM_ADRB-1:0]),		// In	RAM address rd_fifo_adr offset for rpc read out

// Mini Sequencer Readout Control
	.rd_start_mini		(rd_start_mini),					// In	Start readout sequence
	.rd_abort_mini		(rd_abort_mini),					// In	Cancel readout
	.rd_mini_offset		(rd_mini_offset[RAM_ADRB-1:0]),		// In	RAM address rd_fifo_adr offset for miniscope read out

// CFEB Sequencer Frame Output
	.cfeb_first_frame	(cfeb_first_frame),					// Out	First frame valid 2bx after rd_start
	.cfeb_last_frame	(cfeb_last_frame),					// Out	Last frame valid 1bx after busy goes down
	.cfeb_adr			(cfeb_adr[MXCFEBB-1:0]),			// Out	FIFO dump CFEB ID
	.cfeb_tbin			(cfeb_tbin[MXTBIN-1:0]),			// Out	FIFO dump Time Bin #
	.cfeb_rawhits		(cfeb_rawhits[7:0]),				// Out	Layer data from FIFO
	.cfeb_fifo_busy		(cfeb_fifo_busy),					// Out	Readout busy sending data to sequencer, goes down 1bx early

// CFEB Blockedbits Frame Output
	.bcb_first_frame	(bcb_first_frame),					// Out	First frame valid 2bx after rd_start
	.bcb_last_frame		(bcb_last_frame),					// Out	Last frame valid 1bx after busy goes down
	.bcb_blkbits		(bcb_blkbits[11:0]),				// Out	CFEB blocked bits frame data
	.bcb_cfeb_adr		(bcb_cfeb_adr[MXCFEBB-1:0]),		// Out	CFEB ID	
	.bcb_fifo_busy		(bcb_fifo_busy),					// Out	Readout busy sending data to sequencer, goes down 1bx early

// RPC Sequencer Frame Output
	.rpc_first_frame	(rpc_first_frame),					// Out	First frame valid 2bx after rd_start
	.rpc_last_frame		(rpc_last_frame),					// Out	Last frame valid 1bx after busy goes down
	.rpc_adr			(rpc_adr[MXRPCB-1:0]),				// Out	FIFO dump RPC ID
	.rpc_tbinbxn		(rpc_tbinbxn[MXTBIN-1:0]),			// Out	FIFO dump RPC tbin or bxn for DMB
	.rpc_rawhits		(rpc_rawhits[7:0]),					// Out	FIFO dump RPC pad hits, 8 of 16 per cycle
	.rpc_fifo_busy		(rpc_fifo_busy),					// Out	Readout busy sending data to sequencer, goes down 1bx early

// Mini Sequencer Frame Output
	.mini_first_frame	(mini_first_frame),					// Out	First frame valid 2bx after rd_start
	.mini_last_frame	(mini_last_frame),					// Out	Last frame valid 1bx after busy goes down
	.mini_rdata			(mini_rdata[RAM_WIDTH*2-1:0]),		// Out	FIFO dump miniscope
	.mini_fifo_busy		(mini_fifo_busy)					// Out	Readout busy sending data to sequencer, goes down 1bx early
	);

//-------------------------------------------------------------------------------------------------------------------
//	Raw Hits RAM Parity Check Instantiation
//-------------------------------------------------------------------------------------------------------------------
	parity uparity
	(
// Clock
	.clock				(clock),						// In	40MHz TMB main clock
	.global_reset		(global_reset),					// In	Global reset
	.perr_reset			(perr_reset),					// In	Parity error reset

// Parity inputs
	.parity_err_cfeb0	(parity_err_cfeb[0][MXLY-1:0]),	// In	CFEB raw hits RAM parity errors
	.parity_err_cfeb1	(parity_err_cfeb[1][MXLY-1:0]),	// In	CFEB raw hits RAM parity errors
	.parity_err_cfeb2	(parity_err_cfeb[2][MXLY-1:0]),	// In	CFEB raw hits RAM parity errors
	.parity_err_cfeb3	(parity_err_cfeb[3][MXLY-1:0]),	// In	CFEB raw hits RAM parity errors
	.parity_err_cfeb4	(parity_err_cfeb[4][MXLY-1:0]),	// In	CFEB raw hits RAM parity errors
	.parity_err_rpc		(parity_err_rpc[4:0]),			// In	RPC  raw hits RAM parity errors
	.parity_err_mini	(parity_err_mini[1:0]),			// In	Miniscope     RAM parity errors

// Raw hits RAM control
	.fifo_wen			(fifo_wen),						// In	1=Write enable FIFO RAM

// Parity summary to VME
	.perr_cfeb			(perr_cfeb[MXCFEB-1:0]),		// Out	CFEB RAM parity error
	.perr_rpc			(perr_rpc),						// Out	RPC  RAM parity error
	.perr_mini			(perr_mini),					// Out	Mini RAM parity error
	.perr_en			(perr_en),						// Out	Parity error latch enabled
	.perr				(perr),							// Out	Parity error summary		
	.perr_pulse			(perr_pulse),					// Out	Parity error pulse for counting
	.perr_cfeb_ff		(perr_cfeb_ff[MXCFEB-1:0]),		// Out	CFEB RAM parity error, latched
	.perr_rpc_ff		(perr_rpc_ff),					// Out	RPC  RAM parity error, latched
	.perr_mini_ff		(perr_mini_ff),					// Out	Mini RAM parity error, latched
	.perr_ff			(perr_ff),						// Out	Parity error summary,  latched
	.perr_ram_ff		(perr_ram_ff[48:0])				// Out	Mapped bad parity RAMs, 30 cfebs, 5 rpcs, 2 miniscope
	);

//-------------------------------------------------------------------------------------------------------------------
//	TMB Instantiation
//		Sends 80MHz data from ALCT and Sequencer to MPC
//		Outputs ALCT+CLCT match results for Sequencer header
//		Receives 80MHz MPC desision result, sends de-muxed to Sequencer
//-------------------------------------------------------------------------------------------------------------------
// Local
	wire	[1:0]			tmb_sync_err_en;
	wire	[7:0]			mpc_nframes;
	wire	[3:0]			mpc_wen;
	wire	[3:0]			mpc_ren;
	wire	[7:0]			mpc_adr;
	wire	[15:0]			mpc_wdata;
	wire	[15:0]			mpc_rdata;
	wire	[3:0]			mpc_accept_rdata;

	wire	[MXFRAME-1:0]	mpc0_frame0_vme;
	wire	[MXFRAME-1:0]	mpc0_frame1_vme;
	wire	[MXFRAME-1:0]	mpc1_frame0_vme;
	wire	[MXFRAME-1:0]	mpc1_frame1_vme;
	wire	[1:0]			mpc_accept_vme;
	wire	[1:0]			mpc_reserved_vme;

          wire [3:0] tmb_hmt_match_win;

  wire [NHMTHITB-1:0]             hmt_nhits_bx7_vme;
  wire [NHMTHITB-1:0]             hmt_nhits_sig_vme;
  wire [NHMTHITB-1:0]             hmt_nhits_bkg_vme;
  wire [MXHMTB-1:0]             hmt_cathode_vme;

	tmb utmb
	(
// Clock
	.clock				(clock),						// In	40MHz TMB main clock
	.ttc_resync			(ttc_resync),					// In	TTC resync

// ALCT
	.alct0_tmb			(alct0_tmb[MXALCT-1:0]),		// In	ALCT best muon
	.alct1_tmb			(alct1_tmb[MXALCT-1:0]),		// In	ALCT second best muon
	.alct_bx0_rx		(alct_bx0_rx),					// In	ALCT bx0 received
	.alct_ecc_err		(alct_ecc_err[1:0]),			// In	ALCT ecc syndrome code

// TMB-Sequencer Pipelines
	.wr_adr_xtmb		(wr_adr_xtmb[MXBADR-1:0]),		// In	Buffer write address after drift time
	.wr_adr_rtmb		(wr_adr_rtmb[MXBADR-1:0]),		// Out	Buffer write address at TMB matching time
	.wr_adr_xmpc		(wr_adr_xmpc[MXBADR-1:0]),		// Out	Buffer write address at MPC xmit to sequencer
	.wr_adr_rmpc		(wr_adr_rmpc[MXBADR-1:0]),		// Out	Buffer write address at MPC received

	.wr_push_xtmb		(wr_push_xtmb),					// In	Buffer write strobe after drift time
	.wr_push_rtmb		(wr_push_rtmb),					// Out	Buffer write strobe at TMB matching time
	.wr_push_xmpc		(wr_push_xmpc),					// Out	Buffer write strobe at MPC xmit to sequencer
	.wr_push_rmpc		(wr_push_rmpc),					// Out	Buffer write strobe at MPC received

	.wr_avail_xtmb		(wr_avail_xtmb),				// In	Buffer available after drift time
	.wr_avail_rtmb		(wr_avail_rtmb),				// Out	Buffer available at TMB matching time
	.wr_avail_xmpc		(wr_avail_xmpc),				// Out	Buffer available at MPC xmit to sequencer
	.wr_avail_rmpc		(wr_avail_rmpc),				// Out	Buffer available at MPC received

// Sequencer
	.clct0_xtmb			(clct0_xtmb[MXCLCT-1:0]),		// In	First  CLCT
	.clct1_xtmb			(clct1_xtmb[MXCLCT-1:0]),		// In	Second CLCT
	.clctc_xtmb			(clctc_xtmb[MXCLCTC-1:0]),		// In	Common to CLCT0/1 to TMB
	.clctf_xtmb			(clctf_xtmb[MXCFEB-1:0]),		// In	Active cfeb list to TMB  .clct0_qlt_xtmb   (clct0_qlt_xtmb[MXQLTB - 1   : 0]), //In
        //CCLUT, Tao 
      .clct0_bnd_xtmb   (clct0_bnd_xtmb[MXBNDB - 1   : 0]), //In
      .clct0_xky_xtmb   (clct0_xky_xtmb[MXXKYB-1 : 0]),    //In
      .clct1_bnd_xtmb   (clct1_bnd_xtmb[MXBNDB - 1   : 0]),  // In
      .clct1_xky_xtmb   (clct1_xky_xtmb[MXXKYB-1 : 0]),   // In 
	
	.bx0_xmpc			(bx0_xmpc),						// In	bx0 to mpc



	.tmb_trig_pulse		(tmb_trig_pulse),				// Out	ALCT or CLCT or both triggered
	.tmb_trig_keep		(tmb_trig_keep),				// Out	ALCT or CLCT or both triggered, and trigger is allowed
	.tmb_non_trig_keep	(tmb_non_trig_keep),			// Out	Event did not trigger, but keep it for readout
	.tmb_match			(tmb_match),					// Out	ALCT and CLCT matched in time
	.tmb_alct_only		(tmb_alct_only),				// Out	Only ALCT triggered
	.tmb_clct_only		(tmb_clct_only),				// Out	Only CLCT triggered
	.tmb_match_win		(tmb_match_win[3:0]),			// Out	Location of alct in clct window
	.tmb_match_pri		(tmb_match_pri[3:0]),			// Out	Priority of clct in clct window
	.tmb_alct_discard	(tmb_alct_discard),				// Out	ALCT pair was not used for LCT
	.tmb_clct_discard	(tmb_clct_discard),				// Out	CLCT pair was not used for LCT
	.tmb_clct0_discard	(tmb_clct0_discard),			// Out	CLCT0 was not used for LCT because from ME1A
	.tmb_clct1_discard	(tmb_clct1_discard),			// Out	CLCT1 was not used for LCT because from ME1A
	.tmb_aff_list		(tmb_aff_list[MXCFEB-1:0]),		// Out	Active CFEBs for CLCT used in TMB match

	.tmb_match_ro		(tmb_match_ro),					// Out	ALCT and CLCT matched in time, non-triggering readout
	.tmb_alct_only_ro	(tmb_alct_only_ro),				// Out	Only ALCT triggered, non-triggering readout
	.tmb_clct_only_ro	(tmb_clct_only_ro),				// Out	Only CLCT triggered, non-triggering readout

	.tmb_no_alct		(tmb_no_alct),					// Out	No  ALCT
	.tmb_no_clct		(tmb_no_clct),					// Out	No  CLCT
	.tmb_one_alct		(tmb_one_alct),					// Out	One ALCT
	.tmb_one_clct		(tmb_one_clct),					// Out	One CLCT
	.tmb_two_alct		(tmb_two_alct),					// Out	Two ALCTs
	.tmb_two_clct		(tmb_two_clct),					// Out	Two CLCTs
	.tmb_dupe_alct		(tmb_dupe_alct),				// Out	ALCT0 copied into ALCT1 to make 2nd LCT
	.tmb_dupe_clct		(tmb_dupe_clct),				// Out	CLCT0 copied into CLCT1 to make 2nd LCT
	.tmb_rank_err		(tmb_rank_err),					// Out	LCT1 has higher quality than LCT0

	.tmb_alct0			(tmb_alct0[10:0]),				// Out	ALCT best muon latched at trigger
	.tmb_alct1			(tmb_alct1[10:0]),				// Out	ALCT second best muon latched at trigger
	.tmb_alctb			(tmb_alctb[4:0]),				// Out	ALCT bxn latched at trigger
	.tmb_alcte			(tmb_alcte[1:0]),				// Out	ALCT ecc error syndrome latched at trigger

        //Enable CCLUT or not
        //.ccLUT_enable       (ccLUT_enable),  // In
        .run3_trig_df       (run3_trig_df), // output, enable run3 trigger format or not
        //.run3_daq_df        (run3_daq_df),  // output, enable run3 daq format or not

// MPC Status
	.mpc_frame_ff		(mpc_frame_ff),					// Out	MPC frame latch strobe
	.mpc0_frame0_ff		(mpc0_frame0_ff[MXFRAME-1:0]),	// Out	MPC best muon 1st frame
	.mpc0_frame1_ff		(mpc0_frame1_ff[MXFRAME-1:0]),	// Out	MPC best buon 2nd frame
	.mpc1_frame0_ff		(mpc1_frame0_ff[MXFRAME-1:0]),	// Out	MPC second best muon 1st frame
	.mpc1_frame1_ff		(mpc1_frame1_ff[MXFRAME-1:0]),	// Out	MPC second best buon 2nd frame

	.mpc_xmit_lct0		(mpc_xmit_lct0),				// Out	MPC LCT0 sent
	.mpc_xmit_lct1		(mpc_xmit_lct1),				// Out	MPC LCT1 sent

	.mpc_response_ff	(mpc_response_ff),				// Out	MPC accept latch strobe
	.mpc_accept_ff		(mpc_accept_ff[1:0]),			// Out	MPC muon accept response
	.mpc_reserved_ff	(mpc_reserved_ff[1:0]),			// Out	MPC reserved

// MPC
	._mpc_rx			(_mpc_rx[MXMPCRX-1:0]),			// In	MPC 80MHz tx data
	._mpc_tx			(_mpc_tx[MXMPCTX-1:0]),			// Out	MPC 80MHz rx data

// VME Configuration
	.alct_delay			(alct_delay[3:0]),				// In	Delay ALCT for CLCT match window
	.clct_window		(clct_window[3:0]),				// In	CLCT match window width

	.tmb_sync_err_en	(tmb_sync_err_en[1:0]),			// In	Allow sync_err to MPC for either muon
	.tmb_allow_alct		(tmb_allow_alct),				// In	Allow ALCT only 
	.tmb_allow_clct		(tmb_allow_clct),				// In	Allow CLCT only
	.tmb_allow_match	(tmb_allow_match),				// In	Allow ALCT+CLCT match

	.tmb_allow_alct_ro	(tmb_allow_alct_ro),			// In	Allow ALCT only  readout, non-triggering
	.tmb_allow_clct_ro	(tmb_allow_clct_ro),			// In	Allow CLCT only  readout, non-triggering
	.tmb_allow_match_ro	(tmb_allow_match_ro),			// In	Allow Match only readout, non-triggering

	.csc_id				(csc_id[MXCSC-1:0]),			// In	CSC station number
	.csc_me1ab			(csc_me1ab),					// In	1=ME1A or ME1B CSC type
	.alct_bx0_delay		(alct_bx0_delay[3:0]),			// In	ALCT bx0 delay to mpc transmitter
	.clct_bx0_delay		(clct_bx0_delay[3:0]),			// In	CLCT bx0 delay to mpc transmitter
	.alct_bx0_enable	(alct_bx0_enable),				// In	Enable using alct bx0, else copy clct bx0
	.bx0_vpf_test		(bx0_vpf_test),					// In	Sets clct_bx0=lct0_vpf for bx0 alignment tests
	.bx0_match			(bx0_match),					// Out	ALCT bx0 and CLCT bx0 match in time
	.bx0_match2			(bx0_match2),					// Out	ALCT bx0 and CLCT bx0 match in time

	.mpc_rx_delay		(mpc_rx_delay[MXMPCDLY-1:0]),	// In	MPC response delay
	.mpc_tx_delay		(mpc_tx_delay[MXMPCDLY-1:0]),	// In	MPC transmit delay
	.mpc_idle_blank		(mpc_idle_blank),				// In	Blank mpc output except on trigger, block bx0 too
	.mpc_me1a_block		(mpc_me1a_block),				// In	Block ME1A LCTs from MPC, but still queue for L1A readout
	.mpc_oe				(mpc_oe),						// In	MPC output enable, 1=en
	.sync_err_blanks_mpc(sync_err_blanks_mpc),			// In	Sync error blanks LCTs to MPC

// VME Status
	.event_clear_vme	(event_clear_vme),				// In	Event clear for aff,clct,mpc vme diagnostic registers
	.mpc0_frame0_vme	(mpc0_frame0_vme[MXFRAME-1:0]),	// Out	MPC best muon 1st frame
	.mpc0_frame1_vme	(mpc0_frame1_vme[MXFRAME-1:0]),	// Out	MPC best buon 2nd frame
	.mpc1_frame0_vme	(mpc1_frame0_vme[MXFRAME-1:0]),	// Out	MPC second best muon 1st frame
	.mpc1_frame1_vme	(mpc1_frame1_vme[MXFRAME-1:0]),	// Out	MPC second best buon 2nd frame
	.mpc_accept_vme		(mpc_accept_vme[1:0]),			// Out	MPC accept latched for VME
	.mpc_reserved_vme	(mpc_reserved_vme[1:0]),		// Out	MPC reserved latched for VME

// MPC Injector
	.mpc_inject			(mpc_inject),					// In	Start MPC test pattern injector, VME
	.ttc_mpc_inject		(ttc_mpc_inject),				// In	Start MPC injector, ttc command
	.ttc_mpc_inj_en		(ttc_mpc_inj_en),				// In	Enable ttc_mpc_inject
	.mpc_nframes		(mpc_nframes[7:0]),				// In	Number frames to inject
	.mpc_wen			(mpc_wen[3:0]),					// In	Select RAM to write
	.mpc_ren			(mpc_ren[3:0]),					// In	Select RAM to read 
	.mpc_adr			(mpc_adr[7:0]),					// In	Injector RAM read/write address
	.mpc_wdata			(mpc_wdata[15:0]),				// In	Injector RAM write data
	.mpc_rdata			(mpc_rdata[15:0]),				// Out	Injector RAM read  data
	.mpc_accept_rdata	(mpc_accept_rdata[3:0]),		// Out	MPC response stored in RAM
	.mpc_inj_alct_bx0	(mpc_inj_alct_bx0),				// In	ALCT bx0 injector
	.mpc_inj_clct_bx0	(mpc_inj_clct_bx0),				// In	CLCT bx0 injector

// Status
	.alct_vpf_tp		(alct_vpf_tp),					// Out	Timing test point, FF buffered for IOBs
	.clct_vpf_tp		(clct_vpf_tp),					// Out	Timing test point
	.clct_window_tp		(clct_window_tp),				// Out	Timing test point

	.alct0_vpf_tprt		(alct0_vpf_tprt),				// Out	Timing test point, unbuffered real time for internal scope
	.alct1_vpf_tprt		(alct1_vpf_tprt),				// Out	Timing test point
	.clct_vpf_tprt		(clct_vpf_tprt),				// Out	Timing test point
	.clct_window_tprt	(clct_window_tprt),				// Out	Timing test point

	.tmb_sump			(tmb_sump)						// Out	Unused signals
	);

//-------------------------------------------------------------------------------------------------------------------
//	General Purpose I/O Pin Assigments
//-------------------------------------------------------------------------------------------------------------------
	reg	[3:0]	gp_io_;									// Circumvent xst's inability to reg an inout signal
	wire		jsm_busy;								// JTAG State machine busy writing
	wire		tck_fpga = gp_io3;						// TCK from FPGA JTAG chain
	wire		sel_fpga_chain;							// sel_usr[3:0]==4'hC

	wire float_gpio=jsm_busy || (sel_fpga_chain);		// Float GPIO[3:0] while state machine running or fpga chain C selected

	always @* begin
	if (float_gpio) begin
	gp_io_[0]	<= 1'bz;
	gp_io_[1]	<= 1'bz;
	gp_io_[2]	<= 1'bz;
	gp_io_[3]	<= 1'bz;
	end
	else begin
//JGedit, gotta remove rpc_sn_out...	gp_io_[0]	<= rat_sn_out;
	gp_io_[0]	<= 1;			// Out	RAT dsn for debug		jtag_fgpa0 tdo (out) shunted to gp_io1, usually
	gp_io_[1]	<= alct_crc_err_tp;	// Out	CRC Error test point	jtag_fpga1 tdi (in) 
	gp_io_[2]	<= alct_vpf_tp;		// Out	Timing test point		jtag_fpga2 tms (in)
	gp_io_[3]	<= clct_window_tp;	// Out	Timing test point		jtag_fpga3 tck (in)
	end
	end

	assign gp_io0	= gp_io_[0];
	assign gp_io1	= gp_io_[1];
	assign gp_io2	= gp_io_[2];
	assign gp_io3	= gp_io_[3];
//	assign gp_io4	= alct_wr_fifo_tp;							// In	RPC_done
	assign gp_io5	= alct_first_frame_tp | alct_last_frame_tp;	// Out	ALCT first+last frame flag
	assign gp_io6	= alct_wr_fifo_tp;							// Out	ALCT fifo writing
	assign gp_io7	= demux_tp_1st[0] | demux_tp_2nd[0] |(| demux_tp_1st[4:1])||(| demux_tp_2nd[4:1]);// Out	CFEB Demux triad

	wire rpc_done = gp_io4;

//-------------------------------------------------------------------------------------------------------------------
// Mezzanine Test Points
//-------------------------------------------------------------------------------------------------------------------
	wire sump;					// Unused signals defined at end of module
	wire alct_startup_msec;		// Msec pulse
	wire alct_wait_dll;			// Waiting for TMB DLL lock
	wire alct_wait_vme;			// Waiting for TMB VME load from user PROM
	wire alct_wait_cfg;			// Waiting for ALCT FPGA to configure from mez PROM
	wire alct_startup_done;		// ALCT FPGA should be configured by now


	assign meztp20 = alct_startup_msec;	
	assign meztp21 = alct_wait_dll;
	assign meztp22 = alct_startup_done;
	assign meztp23 = alct_wait_vme;
	assign meztp24 = alct_wait_cfg;
	assign meztp25 = lock_tmb_clock0;
	assign meztp26 = 0;
	assign meztp27 = sump;

//-------------------------------------------------------------------------------------------------------------------
//	Sync Error Control Instantiation
//-------------------------------------------------------------------------------------------------------------------
	sync_err_ctrl usync_err_ctrl
	(
// Clock
	.clock						(clock),						// In	Main 40MHz clock
	.ttc_resync					(ttc_resync),					// In	TTC resync command
	.sync_err_reset				(sync_err_reset),				// In	VME sync error reset

// Sync error sources
	.clct_bx0_sync_err			(clct_bx0_sync_err),			// In	TMB  clock pulse count err bxn!=0+offset at ttc_bx0 arrival
	.alct_ecc_rx_err			(alct_ecc_rx_err),				// In	ALCT uncorrected ECC error in data ALCT received from TMB
	.alct_ecc_tx_err			(alct_ecc_tx_err),				// In	ALCT uncorrected ECC error in data ALCT transmitted to TMB
	.bx0_match_err				(!bx0_match),					// In	ALCT alct_bx0 != clct_bx0
	.clock_lock_lost_err		(clock_lock_lost_err),			// In	40MHz main clock lost lock

// Sync error source enables
	.clct_bx0_sync_err_en		(clct_bx0_sync_err_en),			// In	TMB  clock pulse count err bxn!=0+offset at ttc_bx0 arrival
	.alct_ecc_rx_err_en			(alct_ecc_rx_err_en),			// In	ALCT uncorrected ECC error in data ALCT received from TMB
	.alct_ecc_tx_err_en			(alct_ecc_tx_err_en),			// In	ALCT uncorrected ECC error in data ALCT transmitted to TMB
	.bx0_match_err_en			(bx0_match_err_en),				// In	ALCT alct_bx0 != clct_bx0
	.clock_lock_lost_err_en		(clock_lock_lost_err_en),		// In	40MHz main clock lost lock

// Sync error action enables
	.sync_err_blanks_mpc_en		(sync_err_blanks_mpc_en),		// In	Sync error blanks LCTs to MPC
	.sync_err_stops_pretrig_en	(sync_err_stops_pretrig_en),	// In	Sync error stops CLCT pre-triggers
	.sync_err_stops_readout_en	(sync_err_stops_readout_en),	// In	Sync error stops L1A readouts
	.sync_err_forced			(sync_err_forced),				// In	Force sync_err=1

// Sync error types latched for VME readout
	.sync_err					(sync_err),						// Out	Sync error OR of enabled types of error
	.alct_ecc_rx_err_ff			(alct_ecc_rx_err_ff),			// Out	ALCT uncorrected ECC error in data ALCT received from TMB
	.alct_ecc_tx_err_ff			(alct_ecc_tx_err_ff),			// Out	ALCT uncorrected ECC error in data ALCT transmitted to TMB
	.bx0_match_err_ff			(bx0_match_err_ff),				// Out	ALCT alct_bx0 != clct_bx0
	.clock_lock_lost_err_ff		(clock_lock_lost_err_ff),		// Out	40MHz main clock lost lock FF

// Sync error actions
	.sync_err_blanks_mpc		(sync_err_blanks_mpc),			// Out	Sync error blanks LCTs to MPC
	.sync_err_stops_pretrig		(sync_err_stops_pretrig),		// Out	Sync error stops CLCT pre-triggers
	.sync_err_stops_readout		(sync_err_stops_readout)		// Out	Sync error stops L1A readouts
	);

//-------------------------------------------------------------------------------------------------------------------
//	VME Interface Instantiation
//-------------------------------------------------------------------------------------------------------------------
	defparam uvme.FIRMWARE_TYPE		= `FIRMWARE_TYPE;			// C=Normal TMB, D=Debug PCB loopback version
	defparam uvme.VERSION			= `VERSION;					// Version revision number
	defparam uvme.MONTHDAY			= `MONTHDAY;				// Version date
	defparam uvme.YEAR				= `YEAR;					// Version date
	defparam uvme.FPGAID			= `FPGAID;					// FPGA Type XCVnnnn
	defparam uvme.ISE_VERSION		= `ISE_VERSION;				// ISE Compiler version
	defparam uvme.AUTO_VME			= `AUTO_VME;				// Auto init vme registers
	defparam uvme.AUTO_JTAG			= `AUTO_JTAG;				// Auto init jtag chain
	defparam uvme.AUTO_PHASER		= `AUTO_PHASER;				// Auto init digital phase shifters
	defparam uvme.ALCT_MUONIC		= `ALCT_MUONIC;				// Floats ALCT board  in clock-space with independent time-of-flight delay
	defparam uvme.CFEB_MUONIC		= `CFEB_MUONIC;				// Floats CFEB boards in clock-space with independent time-of-flight delay
	defparam uvme.CCB_BX0_EMULATOR	= `CCB_BX0_EMULATOR;		// Turns on bx0 emulator at power up, must be 0 for all CERN versions
        defparam uvme.VERSION_FORMAT   = `VERSION_FORMAT;
        defparam uvme.VERSION_MAJOR    = `VERSION_MAJOR;
        defparam uvme.VERSION_MINOR    = `VERSION_MINOR;


	vme uvme
	(
// Clock
	.clock					(clock),						// In	TMB 40MHz clock
	.clock_vme				(clock_vme),					// In	VME 10MHz clock
	.clock_lock_lost_err	(clock_lock_lost_err),			// In	40MHz main clock lost lock FF
	.ttc_resync				(ttc_resync),					// In	TTC resync
	.global_reset			(global_reset),					// In	Global reset
	.global_reset_en		(global_reset_en),				// Out	Enable global reset on lock_lost

// Firmware version
	.cfeb_exists			(cfeb_exists[MXCFEB-1:0]),		// In	CFEBs instantiated in this version
	.revcode				(revcode[14:0]),				// Out	Firmware revision code

// VME Bus Input
	.d_vme					(vme_d[15:0]),					// Bi	VME data 	D16
	.a						(vme_a[23:1]),					// In	VME Address	A24
	.am						(vme_am[5:0]),					// In	Address modifier
	._lword					(_vme_cmd[0]),					// In	Long word
	._as					(_vme_cmd[1]),					// In	Address Strobe
	._write					(_vme_cmd[2]),					// In	Write strobe
	._ds1					(_vme_cmd[3]),					// In	Data Strobe
	._sysclk				(_vme_cmd[4]),					// In	VME System clock
	._ds0					(_vme_cmd[5]),					// In	Data Strobe
	._sysfail				(_vme_cmd[6]),					// In	System fail
	._sysreset				(_vme_cmd[7]),					// In	System reset
	._acfail				(_vme_cmd[8]),					// In	AC power fail
	._iack					(_vme_cmd[9]),					// In	Interrupt acknowledge
	._iackin				(_vme_cmd[10]),					// In	Interrupt in, daisy chain
	._ga					(_vme_geo[4:0]),				// In	Geographic address
	._gap					(_vme_geo[5]),					// In	Geographic address parity
	._local					(_vme_geo[6]),					// In	Local Addressing: 0=using HexSw, 1=using backplane /GA

// VME Bus Output
	._oe					(vme_reply[0]),					// Out	Output enable: 0=D16 drives out to VME backplane
	.dir					(vme_reply[1]),					// Out	Data Direction: 0=read from backplane, 1=write to backplane
	.dtack					(vme_reply[2]),					// Out	Data acknowledge
	.iackout				(vme_reply[3]),					// Out	Interrupt out daisy chain
	.berr					(vme_reply[4]),					// Out	Bus error
	.irq					(vme_reply[5]),					// Out	Interrupt request
	.ready					(vme_reply[6]),					// Out	Ready: 1=FPGA logic is up, disconnects bootstrap logic hardware

// Loop-Back Control
	.cfeb_oe				(cfeb_oe),						// Out	1=Enable CFEB LVDS drivers
	.alct_loop				(alct_loop),					// Out	1=ALCT loopback mode
	.alct_rxoe				(alct_rxoe),					// Out	1=Enable RAT ALCT LVDS receivers
	.alct_txoe				(alct_txoe),					// Out	1=Enable RAT ALCT LVDS drivers
	.rpc_loop				(rpc_loop),						// Out	1=RPC loopback mode no   RAT
	.rpc_loop_tmb			(rpc_loop_tmb),					// Out	1=RPC loopback mode with RAT
	.dmb_loop				(dmb_loop),						// Out	1=DMB loopback mode
	._dmb_oe				(_dmb_oe),						// Out	0=Enable DMB drivers
	.gtl_loop				(gtl_loop),						// Out	1=GTL loopback mode
	._gtl_oe				(_gtl_oe),						// Out	0=Enable GTL drivers
	.gtl_loop_lcl			(gtl_loop_lcl),					// Out	copy for ccb.v

// User JTAG
	.tck_usr				(jtag_usr[3]),					// IO	User JTAG tck
	.tms_usr				(jtag_usr[2]),					// IO	User JTAG tms
	.tdi_usr				(jtag_usr[1]),					// IO	User JTAG tdi
	.tdo_usr				(jtag_usr0_tdo),				// In	User JTAG tdo
	.sel_usr				(sel_usr[3:0]),					// IO	Select JTAG chain: 00=ALCT, 01=Mez FPGA+PROMs, 10=User PROMs, 11=Readback
	.sel_fpga_chain			(sel_fpga_chain),				// Out	sel_usr[3:0]==4'hC

// PROM
	.prom_led				(prom_led[7:0]),				// Out	Bi	PROM data, shared with 2 PROMs and on-board LEDs
	.prom0_clk				(prom_ctrl[0]),					// Out	PROM 0 clock
	.prom0_oe				(prom_ctrl[1]),					// Out	1=Output enable, 0= Reset address
	._prom0_ce				(prom_ctrl[2]),					// Out	0=Chip enable
	.prom1_clk				(prom_ctrl[3]),					// Out	PROM 1 clock
	.prom1_oe				(prom_ctrl[4]),					// Out	1=Output enable, 0= Reset address
	._prom1_ce				(prom_ctrl[5]),					// Out	0=Chip enable
	.jsm_busy				(jsm_busy),						// Out	State machine busy writing
	.tck_fpga				(tck_fpga),						// Out	TCK from FPGA JTAG chain

// 3D3444
	.ddd_clock				(ddd_clock),					// Out	ddd clock
	.ddd_adr_latch			(ddd_adr_latch),				// Out	ddd address latch
	.ddd_serial_in			(ddd_serial_in),				// Out	ddd serial data
	.ddd_serial_out			(ddd_serial_out),				// In	ddd serial readback

// Clock Single Step
	.step_alct				(step[0]),						// Out	Single step ALCT clock
	.step_dmb				(step[1]),						// Out	Single step DMB  clock
	.step_rpc				(step[2]),						// Out	Single step RPC  clock
	.step_cfeb				(step[3]),						// Out	Single step CFEB clock
	.step_run				(step[4]),						// Out	1= Single step clocks, 0 = 40MHz clocks
	.cfeb_clock_en			(cfeb_clock_en[4:0]),			// Out	1=Enable CFEB LVDS clock drivers
	.alct_clock_en			(alct_clock_en),				// Out	1=Enable ALCT LVDS clock driver

// Hard Resets
	._hard_reset_alct_fpga	(_hard_reset_alct_fpga),		// Out	Hard Reset ALCT
	._hard_reset_tmb_fpga	(_hard_reset_tmb_fpga),			// Out	Hard Reset TMB (wire-or with power-on-reset chip)

// Status: LED
	.led_fp_lct				(led_lct),						// In	LCT		Blue	CLCT + ALCT match
	.led_fp_alct			(led_alct),						// In	ALCT	Green	ALCT valid pattern
	.led_fp_clct			(led_clct),						// In	CLCT	Green	CLCT valid pattern
	.led_fp_l1a				(led_l1a_intime),				// In	L1A		Green	Level 1 Accept from CCB or internal
	.led_fp_invp			(led_invpat),					// In	INVP	Amber	Invalid pattern after drift delay
	.led_fp_nmat			(led_nomatch),					// In	NMAT	Amber	ALCT or CLCT but no match
	.led_fp_nl1a			(led_nol1a_flush),				// In	NL1A	Red		L1A did not arrive in window
	.led_bd_in				(led_bd[7:0]),					// In	On-Board LEDs
	.led_fp_out				(led_fp[7:0]),					// Out	Front Panel LEDs (on board LEDs are connected to prom_led)

// Status: Power Supply Comparator
	.vstat_5p0v				(vstat[0]),						// In	Voltage Comparator +5.0V, 1=OK
	.vstat_3p3v				(vstat[1]),						// In	Voltage Comparator +3.3V, 1=OK
	.vstat_1p8v				(vstat[2]),						// In	Voltage Comparator +1.8V, 1=OK
	.vstat_1p5v				(vstat[3]),						// In	Voltage Comparator +1.5V, 1=OK

// Status: Power Supply ADC
	.adc_sclock				(adc_io[0]),					// Out	ADC serial clock
	.adc_din				(adc_io[1]),					// Out	ADC serial data in
	._adc_cs				(adc_io[2]),					// Out	ADC chip select
	.adc_dout				(adc_io3_dout),					// In	Serial data from ADC

// Status: Temperature ADC
	._t_crit				(_t_crit),						// In	Temperature ADC Tcritical
	.smb_data				(smb_data),						// Bi	Temperature ADC serial data
	.smb_clk				(smb_clk),						// Out	Temperature ADC serial clock
	.smb_data_rat			(smb_data_rat),					// In	Temperature ADC on RAT module

// Status: Digital Serial Numbers
	.mez_sn					(mez_sn),						// Bi	Mezzanine serial number
	.tmb_sn					(tmb_sn),						// Bi	TMB serial number
	.rpc_dsn				(rpc_dsn),						// In	RAT serial number, in  = rpc_dsn;
//JGedit, gotta remove rpc_sn_out...	.rat_sn_out				(rat_sn_out),					// Out	RAT serial number, out = rpc_posneg
	.rat_dsn_en				(rat_dsn_en),					// Out	RAT dsn enable

// Clock DCM lock status
	.lock_tmb_clock0		(lock_tmb_clock0),				// In	DCM lock status
	.lock_tmb_clock0d		(lock_tmb_clock0d),				// In	DCM lock status
	.lock_alct_rxclockd		(lock_alct_rxclockd),			// In	DCM lock status
	.lock_mpc_clock			(lock_mpc_clock),				// In	DCM lock status
	.lock_dcc_clock			(lock_dcc_clock),				// In	DCM lock status
	.lock_rpc_rxalt1		(lock_rpc_rxalt1),				// In	DCM lock status
	.lock_tmb_clock1		(lock_tmb_clock1),				// In	DCM lock status
	.lock_alct_rxclock		(lock_alct_rxclock),			// In	DCM lock status

// Status: Configuration State
	.tmb_cfg_done			(tmb_cfg_done),					// Out	TMB reports ready
	.alct_cfg_done			(alct_cfg_done),				// In	ALCT FPGA reports ready
	.mez_done				(mez_done),						// In	Mezzanine FPGA done loading
	.mez_busy				(mez_busy),						// Out	FPGA busy (asserted during config), user I/O after config
	.alct_startup_msec		(alct_startup_msec),			// Out	Msec pulse
	.alct_wait_dll			(alct_wait_dll),				// Out	Waiting for TMB DLL lock
	.alct_wait_vme			(alct_wait_vme),				// Out	Waiting for TMB VME load from user PROM
	.alct_wait_cfg			(alct_wait_cfg),				// Out	Waiting for ALCT FPGA to configure from mez PROM
	.alct_startup_done		(alct_startup_done),			// Out	ALCT FPGA should be configured by now

// CCB Ports: Status/Configuration
	.ccb_cmd				(ccb_cmd[7:0]),					// In	CCB command word
	.ccb_clock40_enable		(ccb_clock40_enable),			// In	Enable 40MHz clock
	.ccb_bcntres			(ccb_bcntres),					// In	Bunch crossing counter reset
	.ccb_bx0				(ccb_bx0),						// In	Bunch crossing zero
	.ccb_reserved			(ccb_reserved[4:0]),			// In	Unassigned
	.tmb_reserved			(tmb_reserved[1:0]),			// In	Unassigned
	.tmb_reserved_out		(tmb_reserved_out[2:0]),		// In	Unassigned
	.tmb_hard_reset			(tmb_hard_reset	),				// In	Reload TMB  FPGA
	.alct_hard_reset		(alct_hard_reset),				// In	Reload ALCT FPGA
	.alct_adb_pulse_sync	(alct_adb_pulse_sync),			// In	ALCT synchronous  test pulse
	.alct_adb_pulse_async	(alct_adb_pulse_async),			// In	ALCT asynchronous test pulse
	.fmm_trig_stop			(fmm_trig_stop),				// In	Stop clct trigger sequencer
	.ccb_ignore_rx			(ccb_ignore_rx),				// Out	1=Ignore CCB backplane inputs
	.ccb_allow_ext_bypass	(ccb_allow_ext_bypass),			// Out	1=Allow clct_ext_trigger_ccb even if ccb_ignore_rx=1
	.ccb_disable_tx			(ccb_disable_tx),				// Out	Disable CCB backplane outputs
	.ccb_int_l1a_en			(ccb_int_l1a_en),				// Out	1=Enable CCB internal l1a emulator
	.ccb_ignore_startstop	(ccb_ignore_startstop),			// Out	1=ignore ttc trig_start/stop commands
	.alct_status_en			(alct_status_en),				// Out	1=Enable status GTL outputs
	.clct_status_en			(clct_status_en),				// Out	1=Enable status GTL outputs
	.ccb_status_oe			(ccb_status_oe),				// Out	1=Enable ALCT+CLCT CCB status for CCB front panel
	.ccb_status_oe_lcl		(ccb_status_oe_lcl),			// Out	copy for ccb.v logic
	.tmb_reserved_in		(tmb_reserved_in[4:0]),			// Out	CCB reserved signals from TMB

// CCB Ports: VME TTC Command
	.vme_ccb_cmd_enable		(vme_ccb_cmd_enable),			// Out	Disconnect ccb_cmd_bpl, use vme_ccb_cmd;
	.vme_ccb_cmd			(vme_ccb_cmd[7:0]),				// Out	CCB command word
	.vme_ccb_cmd_strobe		(vme_ccb_cmd_strobe),			// Out	CCB command word strobe
	.vme_ccb_data_strobe	(vme_ccb_data_strobe),			// Out	CCB data word strobe
	.vme_ccb_subaddr_strobe	(vme_ccb_subaddr_strobe),		// Out	CCB subaddress strobe
	.vme_evcntres			(vme_evcntres),					// Out	Event counter reset, from VME
	.vme_bcntres			(vme_bcntres),					// Out	Bunch crossing counter reset, from VME
	.vme_bx0				(vme_bx0),						// Out	Bunch crossing zero, from VME
	.vme_bx0_emu_en			(vme_bx0_emu_en),				// Out	BX0 emulator enable
	.fmm_state				(fmm_state[2:0]),				// In	FMM machine state

//	CCB TTC lock status
	.ccb_ttcrx_lock_never	(ccb_ttcrx_lock_never),			// In	Lock never achieved
	.ccb_ttcrx_lost_ever	(ccb_ttcrx_lost_ever),			// In	Lock was lost at least once
	.ccb_ttcrx_lost_cnt		(ccb_ttcrx_lost_cnt[7:0]),		// In	Number of times lock has been lost

	.ccb_qpll_lock_never	(ccb_qpll_lock_never),			// In	Lock never achieved
	.ccb_qpll_lost_ever		(ccb_qpll_lost_ever),			// In	Lock was lost at least once
	.ccb_qpll_lost_cnt		(ccb_qpll_lost_cnt[7:0]),		// In	Number of times lock has been lost

// CCB Ports: Trigger Control
	.clct_ext_trig_l1aen	(clct_ext_trig_l1aen),			// Out	1=Request ccb l1a on clct ext_trig
	.alct_ext_trig_l1aen	(alct_ext_trig_l1aen),			// Out	1=Request ccb l1a on alct ext_trig
	.seq_trig_l1aen			(seq_trig_l1aen),				// Out	1=Request ccb l1a on sequencer trigger
	.alct_ext_trig_vme		(alct_ext_trig_vme),			// Out	1=Fire alct_ext_trig oneshot
	.clct_ext_trig_vme		(clct_ext_trig_vme),			// Out	1=Fire clct_ext_trig oneshot
	.ext_trig_both			(ext_trig_both),				// Out	1=clct_ext_trig fires alct and alct fires clct_trig, DC level
	.l1a_vme				(l1a_vme),						// Out	1=fire ccb_l1accept oneshot
	.l1a_delay_vme			(l1a_delay_vme[7:0]),			// Out	Internal L1A delay
	.l1a_inj_ram_en			(l1a_inj_ram_en),				// Out	L1A injector RAM enable

// ALCT Ports: Trigger Control
	.cfg_alct_ext_trig_en	(cfg_alct_ext_trig_en),			// Out	1=Enable alct_ext_trig   from CCB
	.cfg_alct_ext_inject_en	(cfg_alct_ext_inject_en),		// Out	1=Enable alct_ext_inject from CCB
	.cfg_alct_ext_trig		(cfg_alct_ext_trig),			// Out	1=Assert alct_ext_trig
	.cfg_alct_ext_inject	(cfg_alct_ext_inject),			// Out	1=Assert alct_ext_inject
	.alct_clear				(alct_clear),					// Out	1=Blank alct_rx inputs
	.alct_inject			(alct_inject),					// Out	1=Start ALCT injector
	.alct_inj_ram_en		(alct_inj_ram_en),				// Out	1=Link  ALCT injector to CFEB injector RAM
	.alct_inj_delay			(alct_inj_delay[4:0]),			// Out	ALCT Injector delay	
	.alct0_inj				(alct0_inj[15:0]),				// Out	ALCT0 to inject				
	.alct1_inj				(alct1_inj[15:0]),				// Out	ALCT1 to inject

// ALCT Ports: Sequencer Control/Status
	.alct0_vme				(alct0_vme[15:0]),				// In	ALCT latched at last valid pattern
	.alct1_vme				(alct1_vme[15:0]),				// In	ALCT latched at last valid pattern
	.alct_ecc_en			(alct_ecc_en),					// Out	Enable ALCT ECC decoder, else do no ECC correction
	.alct_ecc_err_blank		(alct_ecc_err_blank),			// Out	Blank alcts with uncorrected ecc errors
	.alct_txd_int_delay		(alct_txd_int_delay[3:0]),		// Out	ALCT data transmit delay, integer bx
	.alct_clock_en_vme		(alct_clock_en_vme),			// Out	Enable ALCT 40MHz clock
	.alct_seq_cmd			(alct_seq_cmd[3:0]),			// Out	ALCT Sequencer command

// VME ALCT sync mode ports
	.alct_sync_txdata_1st	(alct_sync_txdata_1st[9:0]),	// Out	ALCT sync mode data to send for loopback
	.alct_sync_txdata_2nd	(alct_sync_txdata_2nd[9:0]),	// Out	ALCT sync mode data to send for loopback
	.alct_sync_rxdata_dly	(alct_sync_rxdata_dly[3:0]),	// Out	ALCT sync mode lfsr delay pointer to valid data
	.alct_sync_rxdata_pre	(alct_sync_rxdata_pre[3:0]),	// Out	ALCT sync mode delay pointer to valid data, fixed pre-delay
	.alct_sync_tx_random	(alct_sync_tx_random),			// Out	ALCT sync mode tmb transmits random data to alct
	.alct_sync_clr_err		(alct_sync_clr_err),			// Out	ALCT sync mode clear rng error FFs

	.alct_sync_1st_err		(alct_sync_1st_err),			// In	ALCT sync mode 1st-intime match ok, alct-to-tmb
	.alct_sync_2nd_err		(alct_sync_2nd_err),			// In	ALCT sync mode 2nd-intime match ok, alct-to-tmb
	.alct_sync_1st_err_ff	(alct_sync_1st_err_ff),			// In	ALCT sync mode 1st-intime match ok, alct-to-tmb, latched
	.alct_sync_2nd_err_ff	(alct_sync_2nd_err_ff),			// In	ALCT sync mode 2nd-intime match ok, alct-to-tmb, latched
	.alct_sync_ecc_err		(alct_sync_ecc_err[1:0]),		// In	ALCT sync mode ecc error syndrome

	.alct_sync_rxdata_1st	(alct_sync_rxdata_1st[28:1]),	// In	Demux data for demux timing-in
	.alct_sync_rxdata_2nd	(alct_sync_rxdata_2nd[28:1]),	// In	Demux data for demux timing-in
	.alct_sync_expect_1st	(alct_sync_expect_1st[28:1]),	// In	Expected demux data for demux timing-in
	.alct_sync_expect_2nd	(alct_sync_expect_2nd[28:1]),	// In	Expected demux data for demux timing-in

// ALCT Raw hits RAM Ports
	.alct_raw_reset			(alct_raw_reset),				// Out	Reset raw hits write address and done flag
	.alct_raw_radr			(alct_raw_radr[MXARAMADR-1:0]),	// Out	Raw hits RAM VME read address
	.alct_raw_rdata			(alct_raw_rdata[MXARAMDATA-1:0]),// In	Raw hits RAM VME read data
	.alct_raw_busy			(alct_raw_busy),				// In	Raw hits RAM VME busy writing ALCT data
	.alct_raw_done			(alct_raw_done),				// In	Raw hits ready for VME readout
	.alct_raw_wdcnt			(alct_raw_wdcnt[MXARAMADR-1:0]),// In	ALCT word count stored in FIFO

// DMB Ports: Monitored Backplane Signals
	.dmb_cfeb_calibrate		(dmb_cfeb_calibrate[2:0]),		// In	DMB calibration
	.dmb_l1a_release		(dmb_l1a_release),				// In	DMB test
	.dmb_reserved_out		(dmb_reserved_out[4:0]),		// In	DMB unassigned
	.dmb_reserved_in		(dmb_reserved_in[2:0]),			// In	DMB unassigned
	.dmb_rx_ff				(dmb_rx_ff[5:0]),				// In	DMB received
	.dmb_tx_reserved		(dmb_tx_reserved[4:0]),			// Out	DMB backplane reserved

// CFEB Ports: Injector Control
	.mask_all				(mask_all[MXCFEB-1:0]),			// Out	1=Enable, 0=Turn off all CFEB inputs	
	.inj_last_tbin			(inj_last_tbin[11:0]),			// Out	Last tbin, may wrap past 1024 ram adr
	.inj_febsel				(inj_febsel[MXCFEB-1:0]),		// Out	1=Select CFEBn for RAM read/write
	.inj_wen				(inj_wen[2:0]),					// Out	1=Write enable injector RAM
	.inj_rwadr				(inj_rwadr[9:0]),				// Out	Injector RAM read/write address
	.inj_wdata				(inj_wdata[17:0]),				// Out	Injector RAM write data
	.inj_ren				(inj_ren[2:0]),					// Out	1=Read enable Injector RAM
	.inj_rdata				(inj_rdata_mux[17:0]),			// In	Injector RAM read data
	.inj_ramout_busy		(inj_ramout_busy),				// In	Injector busy

// CFEB Triad Decoder Ports
	.triad_persist			(triad_persist[3:0]),			// Out	Triad 1/2-strip persistence
	.triad_clr				(triad_clr),					// Out	Triad one-shot clear

// CFEB PreTrigger Ports
	.lyr_thresh_pretrig		(lyr_thresh_pretrig[MXHITB-1:0]),	// Out	Layers hit pre-trigger threshold
	.hit_thresh_pretrig		(hit_thresh_pretrig[MXHITB-1:0]),	// Out	Hits on pattern template pre-trigger threshold
	.pid_thresh_pretrig		(pid_thresh_pretrig[MXPIDB-1:0]),	// Out	Pattern shape ID pre-trigger threshold
	.dmb_thresh_pretrig		(dmb_thresh_pretrig[MXHITB-1:0]),	// Out	Hits on pattern template DMB active-feb threshold
	.adjcfeb_dist			(adjcfeb_dist[MXKEYB-1+1:0]),		// Out	Distance from key to cfeb boundary for marking adjacent cfeb as hit
        //Enable CCLUT or not
        .ccLUT_enable       (ccLUT_enable),  // In
        .run3_trig_df       (run3_trig_df), // output, enable run3 trigger format or not
        .run3_daq_df        (run3_daq_df),  // output, enable run3 daq format or not

// CFEB Ports: Hot Channel Mask
	.cfeb0_ly0_hcm			(cfeb_ly0_hcm[0][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb0_ly1_hcm			(cfeb_ly1_hcm[0][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb0_ly2_hcm			(cfeb_ly2_hcm[0][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb0_ly3_hcm			(cfeb_ly3_hcm[0][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb0_ly4_hcm			(cfeb_ly4_hcm[0][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb0_ly5_hcm			(cfeb_ly5_hcm[0][MXDS-1:0]),	// Out	1=enable DiStrip

	.cfeb1_ly0_hcm			(cfeb_ly0_hcm[1][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb1_ly1_hcm			(cfeb_ly1_hcm[1][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb1_ly2_hcm			(cfeb_ly2_hcm[1][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb1_ly3_hcm			(cfeb_ly3_hcm[1][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb1_ly4_hcm			(cfeb_ly4_hcm[1][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb1_ly5_hcm			(cfeb_ly5_hcm[1][MXDS-1:0]),	// Out	1=enable DiStrip

	.cfeb2_ly0_hcm			(cfeb_ly0_hcm[2][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb2_ly1_hcm			(cfeb_ly1_hcm[2][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb2_ly2_hcm			(cfeb_ly2_hcm[2][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb2_ly3_hcm			(cfeb_ly3_hcm[2][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb2_ly4_hcm			(cfeb_ly4_hcm[2][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb2_ly5_hcm			(cfeb_ly5_hcm[2][MXDS-1:0]),	// Out	1=enable DiStrip

	.cfeb3_ly0_hcm			(cfeb_ly0_hcm[3][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb3_ly1_hcm			(cfeb_ly1_hcm[3][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb3_ly2_hcm			(cfeb_ly2_hcm[3][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb3_ly3_hcm			(cfeb_ly3_hcm[3][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb3_ly4_hcm			(cfeb_ly4_hcm[3][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb3_ly5_hcm			(cfeb_ly5_hcm[3][MXDS-1:0]),	// Out	1=enable DiStrip

	.cfeb4_ly0_hcm			(cfeb_ly0_hcm[4][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb4_ly1_hcm			(cfeb_ly1_hcm[4][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb4_ly2_hcm			(cfeb_ly2_hcm[4][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb4_ly3_hcm			(cfeb_ly3_hcm[4][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb4_ly4_hcm			(cfeb_ly4_hcm[4][MXDS-1:0]),	// Out	1=enable DiStrip
	.cfeb4_ly5_hcm			(cfeb_ly5_hcm[4][MXDS-1:0]),	// Out	1=enable DiStrip

// Bad CFEB rx bit detection
	.bcb_read_enable		(bcb_read_enable),				// Out	Enable blocked bits in readout
	.cfeb_badbits_reset		(cfeb_badbits_reset[4:0]),		// Out	Reset bad cfeb bits FFs
	.cfeb_badbits_block		(cfeb_badbits_block[4:0]),		// Out	Allow bad bits to block triads
	.cfeb_badbits_found		(cfeb_badbits_found[4:0]),		// In	CFEB[n] has at least 1 bad bit
	.cfeb_badbits_blocked	(cfeb_badbits_blocked),			// Out	A CFEB had bad bits that were blocked
	.cfeb_badbits_nbx		(cfeb_badbits_nbx[15:0]),		// Out	Cycles a bad bit must be continuously high
	
	.cfeb0_ly0_badbits		(cfeb_ly0_badbits[0][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb0_ly1_badbits		(cfeb_ly1_badbits[0][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb0_ly2_badbits		(cfeb_ly2_badbits[0][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb0_ly3_badbits		(cfeb_ly3_badbits[0][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb0_ly4_badbits		(cfeb_ly4_badbits[0][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb0_ly5_badbits		(cfeb_ly5_badbits[0][MXDS-1:0]),// In	1=CFEB rx bit went bad
	
	.cfeb1_ly0_badbits		(cfeb_ly0_badbits[1][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb1_ly1_badbits		(cfeb_ly1_badbits[1][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb1_ly2_badbits		(cfeb_ly2_badbits[1][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb1_ly3_badbits		(cfeb_ly3_badbits[1][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb1_ly4_badbits		(cfeb_ly4_badbits[1][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb1_ly5_badbits		(cfeb_ly5_badbits[1][MXDS-1:0]),// In	1=CFEB rx bit went bad
	
	.cfeb2_ly0_badbits		(cfeb_ly0_badbits[2][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb2_ly1_badbits		(cfeb_ly1_badbits[2][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb2_ly2_badbits		(cfeb_ly2_badbits[2][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb2_ly3_badbits		(cfeb_ly3_badbits[2][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb2_ly4_badbits		(cfeb_ly4_badbits[2][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb2_ly5_badbits		(cfeb_ly5_badbits[2][MXDS-1:0]),// In	1=CFEB rx bit went bad
	
	.cfeb3_ly0_badbits		(cfeb_ly0_badbits[3][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb3_ly1_badbits		(cfeb_ly1_badbits[3][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb3_ly2_badbits		(cfeb_ly2_badbits[3][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb3_ly3_badbits		(cfeb_ly3_badbits[3][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb3_ly4_badbits		(cfeb_ly4_badbits[3][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb3_ly5_badbits		(cfeb_ly5_badbits[3][MXDS-1:0]),// In	1=CFEB rx bit went bad
	
	.cfeb4_ly0_badbits		(cfeb_ly0_badbits[4][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb4_ly1_badbits		(cfeb_ly1_badbits[4][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb4_ly2_badbits		(cfeb_ly2_badbits[4][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb4_ly3_badbits		(cfeb_ly3_badbits[4][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb4_ly4_badbits		(cfeb_ly4_badbits[4][MXDS-1:0]),// In	1=CFEB rx bit went bad
	.cfeb4_ly5_badbits		(cfeb_ly5_badbits[4][MXDS-1:0]),// In	1=CFEB rx bit went bad

// Sequencer Ports: External Trigger Enables
	.clct_pat_trig_en		(clct_pat_trig_en),				// Out	Allow CLCT Pattern pre-triggers
	.alct_pat_trig_en		(alct_pat_trig_en),				// Out	Allow ALCT Pattern pre-trigger
	.alct_match_trig_en		(alct_match_trig_en),			// Out	Allow ALCT*CLCT Pattern pre-trigger
	.adb_ext_trig_en		(adb_ext_trig_en),				// Out	Allow ADB Test pulse pre-trigger
	.dmb_ext_trig_en		(dmb_ext_trig_en),				// Out	Allow DMB Calibration pre-trigger
	.clct_ext_trig_en		(clct_ext_trig_en),				// Out	Allow CLCT External pre-trigger from CCB
	.alct_ext_trig_en		(alct_ext_trig_en),				// Out	Allow ALCT External pre-trigger from CCB
	.layer_trig_en			(layer_trig_en),				// Out	Allow layer-wide pre-triggering
	.all_cfebs_active		(all_cfebs_active),				// Out	Make all CFEBs active when pre-triggered
	.vme_ext_trig			(vme_ext_trig),					// Out	External pre-trigger from VME
	.cfeb_en				(cfeb_en[MXCFEB-1:0]),			// Out	Enables CFEBs for triggering and active feb flag
	.active_feb_src			(active_feb_src),				// Out	Active cfeb flag source, 0=pretrig, 1=tmb-matching ~8bx later

// Sequencer Ports: Trigger Modifiers
	.clct_flush_delay		(clct_flush_delay[MXFLUSH-1:0]),	// Out	Trigger sequencer flush state timer
	.clct_throttle			(clct_throttle[MXTHROTTLE-1:0]),	// Out	Pre-trigger throttle to reduce trigger rate
	.clct_wr_continuous		(clct_wr_continuous),				// Out	1=allow continuous header buffer writing for invalid triggers
	.alct_preClct_width		(alct_preClct_width[3:0]),				// Out  ALCT (alct_active_feb flag) window width for ALCT*preCLCT overlap
	.wr_buf_required		(wr_buf_required),					// Out	Require wr_buffer to pretrigger
	.wr_buf_autoclr_en		(wr_buf_autoclr_en),				// Out	Enable frozen buffer auto clear
	.valid_clct_required	(valid_clct_required),				// Out	Require valid pattern after drift to trigger

// Sequencer Ports: External Trigger Delays
	.alct_preClct_dly		(alct_preClct_dly[MXEXTDLY-1:0]),	// Out  ALCT (alct_active_feb flag) delay for ALCT*preCLCT overlap
	.alct_pat_trig_dly		(alct_pat_trig_dly[MXEXTDLY-1:0]),	// Out	ALCT pattern  trigger delay
	.adb_ext_trig_dly		(adb_ext_trig_dly[MXEXTDLY-1:0]),	// Out	ADB  external trigger delay
	.dmb_ext_trig_dly		(dmb_ext_trig_dly[MXEXTDLY-1:0]),	// Out	DMB  external trigger delay
	.clct_ext_trig_dly		(clct_ext_trig_dly[MXEXTDLY-1:0]),	// Out	CLCT external trigger delay
	.alct_ext_trig_dly		(alct_ext_trig_dly[MXEXTDLY-1:0]),	// Out	ALCT external trigger delay

  // Sequencer Ports: pre-CLCT modifiers for L1A*preCLCT overlap
  .l1a_preClct_width (l1a_preClct_width[3:0]), // Out  pre-CLCT window width for L1A*preCLCT overlap
  .l1a_preClct_dly   (l1a_preClct_dly[7:0]),   // Out  pre-CLCT delay for L1A*preCLCT overlap

// Sequencer Ports: CLCT/RPC/RAT Pattern Injector
	.inj_trig_vme			(inj_trig_vme),						// Out	Start pattern injector
	.injector_mask_cfeb		(injector_mask_cfeb[MXCFEB-1:0]),	// Out	Enable CFEB(n) for injector trigger
	.ext_trig_inject		(ext_trig_inject),					// Out	Changes clct_ext_trig to fire pattern injector
	.injector_mask_rat		(injector_mask_rat),				// Out	Enable RAT for injector trigger
	.injector_mask_rpc		(injector_mask_rpc),				// Out	Enable RPC for injector trigger
	.inj_delay_rat			(inj_delay_rat[3:0]),				// Out	CFEB/RPC Injector waits for RAT injector
	.rpc_tbins_test			(rpc_tbins_test),					// Out	Set write_data=address

// Sequencer Ports: CLCT Processing
	.sequencer_state		(sequencer_state[11:0]),			// In	Sequencer state for vme
	.scint_veto_vme			(scint_veto_vme),					// In	Scintillator veto for FAST Sites
	.drift_delay			(drift_delay[MXDRIFT-1:0]),			// Out	CSC Drift delay clocks
	.hit_thresh_postdrift	(hit_thresh_postdrift[MXHITB-1:0]),	// Out	Minimum pattern hits for a valid pattern
	.pid_thresh_postdrift	(pid_thresh_postdrift[MXPIDB-1:0]),	// Out	Minimum pattern ID   for a valid pattern
	.pretrig_halt			(pretrig_halt),						// Out	Pretrigger and halt until unhalt arrives
	.scint_veto_clr			(scint_veto_clr),					// Out	Clear scintillator veto ff

	.fifo_mode				(fifo_mode[MXFMODE-1:0]),			// Out	FIFO Mode 0=no dump,1=full,2=local,3=sync
	.fifo_tbins_cfeb		(fifo_tbins_cfeb[MXTBIN-1:0]),		// Out	Number CFEB FIFO time bins to read out
	.fifo_pretrig_cfeb		(fifo_pretrig_cfeb[MXTBIN-1:0]),	// Out	Number CFEB FIFO time bins before pretrigger
	.fifo_no_raw_hits		(fifo_no_raw_hits),					// Out	1=do not wait to store raw hits

	.l1a_delay				(l1a_delay[MXL1DELAY-1:0]),			// Out	Level1 Accept delay from pretrig status output
	.l1a_internal			(l1a_internal),						// Out	Generate internal Level 1, overrides external
	.l1a_internal_dly		(l1a_internal_dly[MXL1WIND-1:0]),	// Out	 Delay internal l1a to shift position in l1a match window
	.l1a_window				(l1a_window[MXL1WIND-1:0]),			// Out	Level1 Accept window width after delay
	.l1a_win_pri_en			(l1a_win_pri_en),					// Out	Enable L1A window priority
	.l1a_lookback			(l1a_lookback[MXBADR-1:0]),			// Out	Bxn to look back from l1a wr_buf_adr
	.l1a_preset_sr			(l1a_preset_sr),					// Out	Dummy VME bit to feign preset l1a sr group

	.l1a_allow_match		(l1a_allow_match),					// Out	Readout allows tmb trig pulse in L1A window (normal mode)
	.l1a_allow_notmb		(l1a_allow_notmb),					// Out	Readout allows no tmb trig pulse in L1A window
	.l1a_allow_nol1a		(l1a_allow_nol1a),					// Out	Readout allows tmb trig pulse outside L1A window
	.l1a_allow_alct_only	(l1a_allow_alct_only),				// Out	Allow alct_only events to readout at L1A

	.board_id				(board_id[MXBDID-1:0]),				// Out	Board ID = VME Slot
	.csc_id					(csc_id[MXCSC-1:0]),				// Out	CSC Chamber ID number
	.run_id					(run_id[MXRID-1:0]),				// Out	Run ID
	.bxn_offset_pretrig		(bxn_offset_pretrig[MXBXN-1:0]),	// Out	BXN offset at reset, for pretrig bxn
	.bxn_offset_l1a			(bxn_offset_l1a[MXBXN-1:0]),		// Out	BXN offset at reset, for l1a bxn
	.lhc_cycle				(lhc_cycle[MXBXN-1:0]),				// Out	LHC period, max BXN count+1
	.l1a_offset				(l1a_offset[MXL1ARX-1:0]),			// Out	L1A counter preset value

        //HMT port 
        .hmt_enable         (hmt_enable),        // In ME1a enable or not in HMT
        .hmt_nhits_bx7_vme    (hmt_nhits_bx7_vme   [NHMTHITB-1:0]),//In  HMT nhits for trigger
        .hmt_nhits_sig_vme  (hmt_nhits_sig_vme [NHMTHITB-1:0]),//In  HMT nhits for trigger
        .hmt_nhits_bkg_vme (hmt_nhits_bkg_vme[NHMTHITB-1:0]),//In  HMT nhits for trigger
        .hmt_cathode_vme           (hmt_cathode_vme[MXHMTB-1:0]), // In HMT trigger results, cathode
        .hmt_thresh1        (hmt_thresh1[7:0]),    // Out  loose HMT thresh
        .hmt_thresh2        (hmt_thresh2[7:0]),    // Out  median HMT thresh
        .hmt_thresh3        (hmt_thresh3[7:0]),    // Out  tight HMT thresh
        .hmt_aff_thresh      (hmt_aff_thresh[6:0]),    //Out hmt thresh
        .cfeb_allow_hmt_ro  (cfeb_allow_hmt_ro), //Out read out CFEB when hmt is fired
        .hmt_delay          (hmt_delay[3:0]),        //Out hmt delay for matching
        .hmt_alct_win_size  (hmt_alct_win_size[3:0]),//Out hmt-alct match window size
        .hmt_allow_cathode   (hmt_allow_cathode),//Out hmt allow to trigger on cathode
        .hmt_allow_anode     (hmt_allow_anode),  //Out hmt allow to trigger on anode
        .hmt_allow_match     (hmt_allow_match),  //Out hmt allow to trigger on canode X anode match
        .hmt_allow_cathode_ro(hmt_allow_cathode_ro), //Out hmt allow to readout on cathode
        .hmt_allow_anode_ro  (hmt_allow_anode_ro),   //Out hmt allow to readout on anode
        .hmt_allow_match_ro  (hmt_allow_match_ro),   //Out hmt allow to readout on match
        .hmt_outtime_check   (hmt_outtime_check),//In hmt fired shoudl check anode bg lower than threshold

// Sequencer Ports: Latched CLCTs + Status
	.event_clear_vme		(event_clear_vme),					// Out	Event clear for vme diagnostic registers
	.clct0_vme				(clct0_vme[MXCLCT-1:0]),			// In	First  CLCT
	.clct1_vme				(clct1_vme[MXCLCT-1:0]),			// In	Second CLCT
	.clctc_vme				(clctc_vme[MXCLCTC-1:0]),			// In	Common to CLCT0/1 to TMB
	.clctf_vme				(clctf_vme[MXCFEB-1:0]),			// In	Active cfeb list at TMB match
	.trig_source_vme		(trig_source_vme[10:0]),			// In	Trigger source vector readback
	.nlayers_hit_vme		(nlayers_hit_vme[2:0]),				// In	Number layers hit on layer trigger
	.bxn_clct_vme			(bxn_clct_vme[MXBXN-1:0]),			// In	CLCT BXN at pre-trigger
	.bxn_l1a_vme			(bxn_l1a_vme[MXBXN-1:0]),			// In	CLCT BXN at L1A
	.bxn_alct_vme			(bxn_alct_vme[4:0]),				// In	ALCT BXN at alct valid pattern flag
	.clct_bx0_sync_err		(clct_bx0_sync_err),				// In	Sync error: BXN counter==0 did not match bx0

        //CCLUT, Tao

      .clct0_vme_bnd   (clct0_vme_bnd[MXBNDB - 1   : 0]), // In clct0 new bending 
      .clct0_vme_xky   (clct0_vme_xky[MXXKYB-1 : 0]),     // In clct0 new key position with 1/8 strip resolution
      .clct1_vme_bnd   (clct1_vme_bnd[MXBNDB - 1   : 0]), // In 
      .clct1_vme_xky   (clct1_vme_xky[MXXKYB-1 : 0]),    // IN 

// Sequencer Ports: Raw Hits Ram
	.dmb_wr					(dmb_wr),							// Out	Raw hits RAM VME write enable
	.dmb_reset				(dmb_reset),						// Out	Raw hits RAM VME address reset
	.dmb_adr				(dmb_adr[MXRAMADR-1:0]),			// Out	Raw hits RAM VME read/write address
	.dmb_wdata				(dmb_wdata[MXRAMDATA-1:0]),			// Out	Raw hits RAM VME write data
	.dmb_rdata				(dmb_rdata[MXRAMDATA-1:0]),			// In	Raw hits RAM VME read data
	.dmb_wdcnt				(dmb_wdcnt[MXRAMADR-1:0]),			// In	Raw hits RAM VME word count
	.dmb_busy				(dmb_busy),							// In	Raw hits RAM VME busy writing DMB data

// Sequencer Ports: Buffer Status
	.wr_buf_ready			(wr_buf_ready),						// In	Write buffer is ready
	.wr_buf_adr				(wr_buf_adr[MXBADR-1:0]),			// In	Current address of header write buffer
	.buf_q_full				(buf_q_full),						// In	All raw hits ram in use, ram writing must stop
	.buf_q_empty			(buf_q_empty),						// In	No fences remain on buffer stack
	.buf_q_ovf_err			(buf_q_ovf_err),					// In	Tried to push when stack full
	.buf_q_udf_err			(buf_q_udf_err),					// In	Tried to pop when stack empty
	.buf_q_adr_err			(buf_q_adr_err),					// In	Fence adr popped from stack doesnt match rls adr
	.buf_stalled			(buf_stalled),						// In	Buffer write pointer hit a fence and is stalled now
	.buf_stalled_once		(buf_stalled_once),					// In	Buffer stalled at least once since last resync
	.buf_fence_dist			(buf_fence_dist[MXBADR-1:0]),		// In	Current distance to next fence 0 to 2047
	.buf_fence_cnt			(buf_fence_cnt[MXBADR-1+1:0]),		// In	Number of fences in fence RAM currently
	.buf_fence_cnt_peak		(buf_fence_cnt_peak[MXBADR-1+1:0]),	// In	Peak number of fences in fence RAM
	.buf_display			(buf_display[7:0]),					// In	Buffer fraction in use display

// Sequence Ports: Board Status
	.uptime					(uptime[15:0]),					// In	Uptime since last hard reset
	.bd_status				(bd_status[14:0]),				// Out	Board status summary

// Sequencer Ports: Scope
	.scp_runstop			(scp_runstop),					// Out	1=run 0=stop
	.scp_auto				(scp_auto),						// Out	Sequencer readout mode
	.scp_ch_trig_en			(scp_ch_trig_en),				// Out	Enable channel triggers
	.scp_trigger_ch			(scp_trigger_ch[7:0]),			// Out	Trigger channel 0-159
	.scp_force_trig			(scp_force_trig),				// Out	Force a trigger
	.scp_ch_overlay			(scp_ch_overlay),				// Out	Channel source overlay
	.scp_ram_sel			(scp_ram_sel[3:0]),				// Out	RAM bank select in VME mode
	.scp_tbins				(scp_tbins[2:0]),				// Out	Time bins per channel code, actual tbins/ch = (tbins+1)*64
	.scp_radr				(scp_radr[8:0]),				// Out	Channel data read address
	.scp_nowrite			(scp_nowrite),					// Out	Preserves initial RAM contents for testing
	.scp_waiting			(scp_waiting),					// In	Waiting for trigger
	.scp_trig_done			(scp_trig_done),				// In	Trigger done, ready for readout 
	.scp_rdata				(scp_rdata[15:0]),				// In	Recorded channel data

//  Sequencer Ports: Miniscope
	.mini_read_enable		(mini_read_enable),				// Out	Enable Miniscope readout
	.mini_tbins_test		(mini_tbins_test),				// Out	Miniscope data=address for testing
	.mini_tbins_word		(mini_tbins_word),				// Out	Insert tbins and pretrig tbins in 1st word
	.fifo_tbins_mini		(fifo_tbins_mini[MXTBIN-1:0]),	// Out	Number Mini FIFO time bins to read out
	.fifo_pretrig_mini		(fifo_pretrig_mini[MXTBIN-1:0]),// Out	Number Mini FIFO time bins before pretrigger

// TMB Ports: Configuration
	.alct_delay				(alct_delay[3:0]),				// Out	Delay ALCT for CLCT match window
	.clct_window			(clct_window[3:0]),				// Out	CLCT match window width

	.tmb_sync_err_en		(tmb_sync_err_en[1:0]),			// Out	Allow sync_err to MPC for either muon
	.tmb_allow_alct			(tmb_allow_alct),				// Out	Allow ALCT only 
	.tmb_allow_clct			(tmb_allow_clct),				// Out	Allow CLCT only
	.tmb_allow_match		(tmb_allow_match),				// Out	Allow ALCT+CLCT match

	.tmb_allow_alct_ro		(tmb_allow_alct_ro),			// Out	Allow ALCT only  readout, non-triggering
	.tmb_allow_clct_ro		(tmb_allow_clct_ro),			// Out	Allow CLCT only  readout, non-triggering
	.tmb_allow_match_ro		(tmb_allow_match_ro),			// Out	Allow Match only readout, non-triggering

	.alct_bx0_delay			(alct_bx0_delay[3:0]),			// Out	ALCT bx0 delay to mpc transmitter
	.clct_bx0_delay			(clct_bx0_delay[3:0]),			// Out	CLCT bx0 delay to mpc transmitter
	.alct_bx0_enable		(alct_bx0_enable),				// Out	Enable using alct bx0, else copy clct bx0
	.bx0_vpf_test			(bx0_vpf_test),					// Out	Sets clct_bx0=lct0_vpf for bx0 alignment tests
	.bx0_match				(bx0_match),					// In	ALCT bx0 and CLCT bx0 match in time

	.mpc_rx_delay			(mpc_rx_delay[MXMPCDLY-1:0]),	// Out	MPC response delay
	.mpc_tx_delay			(mpc_tx_delay[MXMPCDLY-1:0]),	// Out	MPC transmit delay
	.mpc_sel_ttc_bx0		(mpc_sel_ttc_bx0),				// Out	MPC gets ttc_bx0 or bx0_local
	.mpc_me1a_block			(mpc_me1a_block),				// Out	Block ME1A LCTs from MPC, but still queue for L1A readout
	.mpc_idle_blank			(mpc_idle_blank),				// Out	Blank mpc output except on trigger, block bx0 too
	.mpc_oe					(mpc_oe),						// Out	MPC output enable, 1=en

// TMB Ports: Status
	.mpc0_frame0_vme		(mpc0_frame0_vme[MXFRAME-1:0]),	// In	MPC best muon 1st frame
	.mpc0_frame1_vme		(mpc0_frame1_vme[MXFRAME-1:0]),	// In	MPC best buon 2nd frame
	.mpc1_frame0_vme		(mpc1_frame0_vme[MXFRAME-1:0]),	// In	MPC second best muon 1st frame
	.mpc1_frame1_vme		(mpc1_frame1_vme[MXFRAME-1:0]),	// In	MPC second best buon 2nd frame
	.mpc_accept_vme			(mpc_accept_vme[1:0]),			// In	MPC accept response
	.mpc_reserved_vme		(mpc_reserved_vme[1:0]),		// In	MPC reserved response

// TMB Ports: MPC Injector Control
	.mpc_inject				(mpc_inject),					// Out	Start MPC test pattern injector
	.ttc_mpc_inj_en			(ttc_mpc_inj_en),				// Out	Enable ttc_mpc_inject
	.mpc_nframes			(mpc_nframes[7:0]),				// Out	Number frames to inject
	.mpc_wen				(mpc_wen[3:0]),					// Out	Select RAM to write
	.mpc_ren				(mpc_ren[3:0]),					// Out	Select RAM to read 
	.mpc_adr				(mpc_adr[7:0]),					// Out	Injector RAM read/write address
	.mpc_wdata				(mpc_wdata[15:0]),				// Out	Injector RAM write data
	.mpc_rdata				(mpc_rdata[15:0]),				// In	Injector RAM read  data
	.mpc_accept_rdata		(mpc_accept_rdata[3:0]),		// In	MPC response stored in RAM
	.mpc_inj_alct_bx0		(mpc_inj_alct_bx0),				// Out	ALCT bx0 injector
	.mpc_inj_clct_bx0		(mpc_inj_clct_bx0),				// Out	CLCT bx0 injector

// RPC VME Configuration Ports
	.rpc_done				(rpc_done),						// In	rpc_done
	.rpc_exists				(rpc_exists[MXRPC-1:0]),		// Out	RPC Readout list
	.rpc_read_enable		(rpc_read_enable),				// Out	1 Enable RPC Readout
	.fifo_tbins_rpc			(fifo_tbins_rpc[MXTBIN-1:0]),	// Out	Number RPC FIFO time bins to read out
	.fifo_pretrig_rpc		(fifo_pretrig_rpc[MXTBIN-1:0]),	// Out	Number RPC FIFO time bins before pretrigger

// RPC Ports: RAT Control
	.rpc_sync				(rpc_sync),						// Out	Sync mode
	.rpc_posneg				(rpc_posneg),					// Out	Clock phase
	.rpc_free_tx0			(rpc_free_tx0),					// Out	Unassigned

// RPC Ports: RAT 3D3444 Delay Signals
	.dddr_clock				(dddr_clock),					// Out	DDDR clock			/ rpc_sync
	.dddr_adr_latch			(dddr_adr_latch),				// Out	DDDR address latch	/ rpc_posneg
	.dddr_serial_in			(dddr_serial_in),				// Out	DDDR serial in		/ rpc_loop_tmb
	.dddr_busy				(dddr_busy),					// Out	DDDR busy			/ rpc_free_tx0

// RPC Raw Hits Delay Ports
	.rpc0_delay				(rpc0_delay[3:0]),				// Out	RPC data delay value
	.rpc1_delay				(rpc1_delay[3:0]),				// Out	RPC data delay value

// RPC Injector Ports
	.rpc_mask_all			(rpc_mask_all),					// Out	1=Enable, 0=Turn off all RPC inputs
	.rpc_inj_sel			(rpc_inj_sel),					// Out	1=Enable RAM write
	.rpc_inj_wen			(rpc_inj_wen[MXRPC-1:0]),		// Out	1=Write enable injector RAM
	.rpc_inj_rwadr			(rpc_inj_rwadr[9:0]),			// Out	Injector RAM read/write address
	.rpc_inj_wdata			(rpc_inj_wdata[MXRPCDB-1:0]),	// Out	Injector RAM write data
	.rpc_inj_ren			(rpc_inj_ren[MXRPC-1:0]),		// Out	1=Read enable Injector RAM
	.rpc_inj_rdata			(rpc_inj_rdata[MXRPCDB-1:0]),	// In	Injector RAM read data

// RPC Ports: Raw Hits RAM
	.rpc_bank				(rpc_bank[MXRPCB-1:0]),			// Out	RPC bank address
	.rpc_rdata				(rpc_rdata[15:0]),				// In	RPC RAM read data
	.rpc_rbxn				(rpc_rbxn[2:0]),				// In	RPC RAM read bxn

// RPC Hot Channel Mask Ports
	.rpc0_hcm				(rpc0_hcm[MXRPCPAD-1:0]),		// Out	1=enable RPC pad
	.rpc1_hcm				(rpc1_hcm[MXRPCPAD-1:0]),		// Out	1=enable RPC pad

// RPC Bxn Offset
	.rpc_bxn_offset			(rpc_bxn_offset[3:0]),			// Out	RPC bunch crossing offset
	.rpc0_bxn_diff			(rpc0_bxn_diff[3:0]),			// In	RPC - offset
	.rpc1_bxn_diff			(rpc1_bxn_diff[3:0]),			// In	RPC - offset

// ALCT Trigger/Readout Counter Ports
	.cnt_all_reset			(cnt_all_reset),					// Out	Trigger/Readout counter reset
	.cnt_stop_on_ovf		(cnt_stop_on_ovf),					// Out	Stop all counters if any overflows
	.cnt_non_me1ab_en		(cnt_non_me1ab_en),					// Out	Allow clct pretrig counters count non me1ab
	.cnt_alct_debug			(cnt_alct_debug),					// Out	Enable alct lct error counter
	.cnt_any_ovf_alct		(cnt_any_ovf_alct),					// In	At least one alct counter overflowed
	.cnt_any_ovf_seq		(cnt_any_ovf_seq),					// In	At least one sequencer counter overflowed

// ALCT Event Counters
	.event_counter0			(event_counter0[MXCNTVME-1:0]),		// In	ALCT event counters
	.event_counter1			(event_counter1[MXCNTVME-1:0]),		// In
	.event_counter2			(event_counter2[MXCNTVME-1:0]),		// In
	.event_counter3			(event_counter3[MXCNTVME-1:0]),		// In
	.event_counter4			(event_counter4[MXCNTVME-1:0]),		// In
	.event_counter5			(event_counter5[MXCNTVME-1:0]),		// In
	.event_counter6			(event_counter6[MXCNTVME-1:0]),		// In
	.event_counter7			(event_counter7[MXCNTVME-1:0]),		// In
	.event_counter8			(event_counter8[MXCNTVME-1:0]),		// In
	.event_counter9			(event_counter9[MXCNTVME-1:0]),		// In
	.event_counter10		(event_counter10[MXCNTVME-1:0]),	// In
	.event_counter11		(event_counter11[MXCNTVME-1:0]),	// In
	.event_counter12		(event_counter12[MXCNTVME-1:0]),	// In

// TMB+CLCT Event Counters
	.event_counter13		(event_counter13[MXCNTVME-1:0]),	// In	TMB event counters
	.event_counter14		(event_counter14[MXCNTVME-1:0]),	// In
	.event_counter15		(event_counter15[MXCNTVME-1:0]),	// In
	.event_counter16		(event_counter16[MXCNTVME-1:0]),	// In
	.event_counter17		(event_counter17[MXCNTVME-1:0]),	// In
	.event_counter18		(event_counter18[MXCNTVME-1:0]),	// In
	.event_counter19		(event_counter19[MXCNTVME-1:0]),	// In
	.event_counter20		(event_counter20[MXCNTVME-1:0]),	// In
	.event_counter21		(event_counter21[MXCNTVME-1:0]),	// In
	.event_counter22		(event_counter22[MXCNTVME-1:0]),	// In
	.event_counter23		(event_counter23[MXCNTVME-1:0]),	// In
	.event_counter24		(event_counter24[MXCNTVME-1:0]),	// In
	.event_counter25		(event_counter25[MXCNTVME-1:0]),	// In
	.event_counter26		(event_counter26[MXCNTVME-1:0]),	// In
	.event_counter27		(event_counter27[MXCNTVME-1:0]),	// In
	.event_counter28		(event_counter28[MXCNTVME-1:0]),	// In
	.event_counter29		(event_counter29[MXCNTVME-1:0]),	// In
	.event_counter30		(event_counter30[MXCNTVME-1:0]),	// In
	.event_counter31		(event_counter31[MXCNTVME-1:0]),	// In
	.event_counter32		(event_counter32[MXCNTVME-1:0]),	// In
	.event_counter33		(event_counter33[MXCNTVME-1:0]),	// In
	.event_counter34		(event_counter34[MXCNTVME-1:0]),	// In
	.event_counter35		(event_counter35[MXCNTVME-1:0]),	// In
	.event_counter36		(event_counter36[MXCNTVME-1:0]),	// In
	.event_counter37		(event_counter37[MXCNTVME-1:0]),	// In
	.event_counter38		(event_counter38[MXCNTVME-1:0]),	// In
	.event_counter39		(event_counter39[MXCNTVME-1:0]),	// In
	.event_counter40		(event_counter40[MXCNTVME-1:0]),	// In
	.event_counter41		(event_counter41[MXCNTVME-1:0]),	// In
	.event_counter42		(event_counter42[MXCNTVME-1:0]),	// In
	.event_counter43		(event_counter43[MXCNTVME-1:0]),	// In
	.event_counter44		(event_counter44[MXCNTVME-1:0]),	// In
	.event_counter45		(event_counter45[MXCNTVME-1:0]),	// In
	.event_counter46		(event_counter46[MXCNTVME-1:0]),	// In
	.event_counter47		(event_counter47[MXCNTVME-1:0]),	// In
	.event_counter48		(event_counter48[MXCNTVME-1:0]),	// In
	.event_counter49		(event_counter49[MXCNTVME-1:0]),	// In
	.event_counter50		(event_counter50[MXCNTVME-1:0]),	// In
	.event_counter51		(event_counter51[MXCNTVME-1:0]),	// In
	.event_counter52		(event_counter52[MXCNTVME-1:0]),	// In
	.event_counter53		(event_counter53[MXCNTVME-1:0]),	// In
	.event_counter54		(event_counter54[MXCNTVME-1:0]),	// In
	.event_counter55		(event_counter55[MXCNTVME-1:0]),	// In
	.event_counter56		(event_counter56[MXCNTVME-1:0]),	// In
	.event_counter57		(event_counter57[MXCNTVME-1:0]),	// In
	.event_counter58		(event_counter58[MXCNTVME-1:0]),	// In
	.event_counter59		(event_counter59[MXCNTVME-1:0]),	// In
	.event_counter60		(event_counter60[MXCNTVME-1:0]),	// In
	.event_counter61		(event_counter61[MXCNTVME-1:0]),	// In
	.event_counter62		(event_counter62[MXCNTVME-1:0]),	// In
	.event_counter63		(event_counter63[MXCNTVME-1:0]),	// In
	.event_counter64		(event_counter64[MXCNTVME-1:0]),	// In
	.event_counter65		(event_counter65[MXCNTVME-1:0]),	// In

// Header Counter Ports
	.hdr_clear_on_resync	(hdr_clear_on_resync),				// Out	Clear header counters on ttc_resync
	.pretrig_counter		(pretrig_counter[MXCNTVME-1:0]),	// In	Pre-trigger counter
	.clct_counter			(clct_counter[MXCNTVME-1:0]),		// In	CLCT counter
	.trig_counter			(trig_counter[MXCNTVME-1:0]),		// In	TMB trigger counter
	.alct_counter			(alct_counter[MXCNTVME-1:0]),		// In	ALCTs received counter
	.l1a_rx_counter			(l1a_rx_counter[MXL1ARX-1:0]),		// In	L1As received from ccb counter
	.readout_counter		(readout_counter[MXL1ARX-1:0]),		// In	Readout counter
	.orbit_counter			(orbit_counter[MXORBIT-1:0]),		// In	Orbit counter

// ALCT Structure Error Counters
	.alct_err_counter0		(alct_err_counter0[7:0]),			// In	Error counter 1D remap
	.alct_err_counter1		(alct_err_counter1[7:0]),			// In
	.alct_err_counter2		(alct_err_counter2[7:0]),			// In
	.alct_err_counter3		(alct_err_counter3[7:0]),			// In
	.alct_err_counter4		(alct_err_counter4[7:0]),			// In
	.alct_err_counter5		(alct_err_counter5[7:0]),			// In

  // CLCT pre-trigger coincidence counters
  .preClct_l1a_counter  (preClct_l1a_counter[MXCNTVME-1:0]),  // In
  .preClct_alct_counter (preClct_alct_counter[MXCNTVME-1:0]), // In

  // Active CFEB(s) counters
  .active_cfebs_event_counter      (active_cfebs_event_counter[MXCNTVME-1:0]),      // In
  .active_cfeb0_event_counter      (active_cfeb0_event_counter[MXCNTVME-1:0]),      // In
  .active_cfeb1_event_counter      (active_cfeb1_event_counter[MXCNTVME-1:0]),      // In
  .active_cfeb2_event_counter      (active_cfeb2_event_counter[MXCNTVME-1:0]),      // In
  .active_cfeb3_event_counter      (active_cfeb3_event_counter[MXCNTVME-1:0]),      // In
  .active_cfeb4_event_counter      (active_cfeb4_event_counter[MXCNTVME-1:0]),      // In

  .bx0_match_counter  (bx0_match_counter),// In
// CSC Orientation Ports
	.csc_type				(csc_type[3:0]),					// In	Firmware compile type
	.csc_me1ab				(csc_me1ab),						// In	1=ME1A or ME1B CSC type
	.stagger_hs_csc			(stagger_hs_csc),					// In	1=Staggered CSC, 0=non-staggered
	.reverse_hs_csc			(reverse_hs_csc),					// In	1=Reverse staggered CSC, non-me1
	.reverse_hs_me1a		(reverse_hs_me1a),					// In	1=reverse me1a hstrips prior to pattern sorting
	.reverse_hs_me1b		(reverse_hs_me1b),					// In	1=reverse me1b hstrips prior to pattern sorting

// Pattern Finder Ports
	.clct_blanking			(clct_blanking),					// Out	clct_blanking clears clcts with 0 hits

// 2nd CLCT separation RAM Ports
	.clct_sep_src			(clct_sep_src),						// Out	CLCT separation source 1=vme, 0=ram
	.clct_sep_vme			(clct_sep_vme[7:0]),				// Out	CLCT separation from vme
	.clct_sep_ram_we		(clct_sep_ram_we),					// Out	CLCT separation RAM write enable
	.clct_sep_ram_adr		(clct_sep_ram_adr[3:0]),			// Out	CLCT separation RAM rw address VME
	.clct_sep_ram_wdata		(clct_sep_ram_wdata[15:0]),			// Out	CLCT separation RAM write data VME
	.clct_sep_ram_rdata		(clct_sep_ram_rdata[15:0]),			// In	CLCT separation RAM read  data VME

// Parity summary
	.perr_reset				(perr_reset),						// Out	Reset parity errors
	.perr_cfeb				(perr_cfeb[MXCFEB-1:0]),			// In	CFEB RAM parity error
	.perr_rpc				(perr_rpc),							// In	RPC  RAM parity error
	.perr_mini				(perr_mini),						// In	Mini RAM parity error
	.perr_en				(perr_en),							// In	Parity error latch enabled
	.perr					(perr),								// In	Parity error summary		
	.perr_cfeb_ff			(perr_cfeb_ff[MXCFEB-1:0]),			// In	CFEB RAM parity error, latched
	.perr_rpc_ff			(perr_rpc_ff),						// In	RPC  RAM parity error, latched
	.perr_mini_ff			(perr_mini_ff),						// In	Mini RAM parity error, latched
	.perr_ff				(perr_ff),							// In	Parity error summary,  latched
	.perr_ram_ff			(perr_ram_ff[48:0]),				// In	Mapped bad parity RAMs, 30 cfebs, 5 rpcs, 2 miniscope

// VME debug register latches
	.deb_wr_buf_adr			(deb_wr_buf_adr[MXBADR-1:0]),		// In	Buffer write address at last pretrig
	.deb_buf_push_adr		(deb_buf_push_adr[MXBADR-1:0]),		// In	Queue push address at last push
	.deb_buf_pop_adr		(deb_buf_pop_adr[MXBADR-1:0]),		// In	Queue pop  address at last pop
	.deb_buf_push_data		(deb_buf_push_data[MXBDATA-1:0]),	// In	Queue push data at last push
	.deb_buf_pop_data		(deb_buf_pop_data[MXBDATA-1:0]),	// In	Queue pop  data at last pop

// DDR Ports: Posnegs
	.alct_rxd_posneg		(alct_rxd_posneg),					// Out	40MHz  ALCT alct-to-tmb inter-stage clock select 0 or 180 degrees
	.alct_txd_posneg		(alct_txd_posneg),					// Out	40MHz  ALCT tmb-to-alct inter-stage clock select 0 or 180 degrees
	.cfeb0_rxd_posneg		(cfeb0_rxd_posneg),					// Out	CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
	.cfeb1_rxd_posneg		(cfeb1_rxd_posneg),					// Out	CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
	.cfeb2_rxd_posneg		(cfeb2_rxd_posneg),					// Out	CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
	.cfeb3_rxd_posneg		(cfeb3_rxd_posneg),					// Out	CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
	.cfeb4_rxd_posneg		(cfeb4_rxd_posneg),					// Out	CFEB cfeb-to-tmb inter-stage clock select 0 or 180 degrees
	
// Phaser VME control/status ports
	.dps_fire				(dps_fire[6:0]),					// Out	Set new phase
	.dps_reset				(dps_reset[6:0]),					// Out	VME Reset current phase
	.dps_busy				(dps_busy[6:0]),					// In	Phase shifter busy
	.dps_lock				(dps_lock[6:0]),					// In	PLL lock status

	.dps0_phase				(dps0_phase[7:0]),					// Out	Phase to set, 0-255
	.dps1_phase				(dps1_phase[7:0]),					// Out	Phase to set, 0-255
	.dps2_phase				(dps2_phase[7:0]),					// Out	Phase to set, 0-255
	.dps3_phase				(dps3_phase[7:0]),					// Out	Phase to set, 0-255
	.dps4_phase				(dps4_phase[7:0]),					// Out	Phase to set, 0-255
	.dps5_phase				(dps5_phase[7:0]),					// Out	Phase to set, 0-255
	.dps6_phase				(dps6_phase[7:0]),					// Out	Phase to set, 0-255

	.dps0_sm_vec			(dps0_sm_vec[2:0]),					// In	Phase shifter machine state
	.dps1_sm_vec			(dps1_sm_vec[2:0]),					// In	Phase shifter machine state
	.dps2_sm_vec			(dps2_sm_vec[2:0]),					// In	Phase shifter machine state
	.dps3_sm_vec			(dps3_sm_vec[2:0]),					// In	Phase shifter machine state
	.dps4_sm_vec			(dps4_sm_vec[2:0]),					// In	Phase shifter machine state
	.dps5_sm_vec			(dps5_sm_vec[2:0]),					// In	Phase shifter machine state
	.dps6_sm_vec			(dps6_sm_vec[2:0]),					// In	Phase shifter machine state

// Interstage delays
	.cfeb0_rxd_int_delay	(cfeb_rxd_int_delay[0][3:0]),		// Out	Interstage delay
	.cfeb1_rxd_int_delay	(cfeb_rxd_int_delay[1][3:0]),		// Out	Interstage delay
	.cfeb2_rxd_int_delay	(cfeb_rxd_int_delay[2][3:0]),		// Out	Interstage delay
	.cfeb3_rxd_int_delay	(cfeb_rxd_int_delay[3][3:0]),		// Out	Interstage delay
	.cfeb4_rxd_int_delay	(cfeb_rxd_int_delay[4][3:0]),		// Out	Interstage delay

// Sync error source enables
	.sync_err_reset				(sync_err_reset),				// Out	VME sync error reset
	.clct_bx0_sync_err_en		(clct_bx0_sync_err_en),			// Out	TMB  clock pulse count err bxn!=0+offset at ttc_bx0 arrival
	.alct_ecc_rx_err_en			(alct_ecc_rx_err_en),			// Out	ALCT uncorrected ECC error in data ALCT received from TMB
	.alct_ecc_tx_err_en			(alct_ecc_tx_err_en),			// Out	ALCT uncorrected ECC error in data ALCT transmitted to TMB
	.bx0_match_err_en			(bx0_match_err_en),				// Out	ALCT alct_bx0 != clct_bx0
	.clock_lock_lost_err_en		(clock_lock_lost_err_en),		// Out	40MHz main clock lost lock

// Sync error action enables
	.sync_err_blanks_mpc_en		(sync_err_blanks_mpc_en),		// Out	Sync error blanks LCTs to MPC
	.sync_err_stops_pretrig_en	(sync_err_stops_pretrig_en),	// Out	Sync error stops CLCT pre-triggers
	.sync_err_stops_readout_en	(sync_err_stops_readout_en),	// Out	Sync error stops L1A readouts
	.sync_err_forced			(sync_err_forced),				// Out	Force sync_err=1

// Sync error types latched for VME readout
	.sync_err					(sync_err),						// In	Sync error OR of enabled types of error
	.alct_ecc_rx_err_ff			(alct_ecc_rx_err_ff),			// In	ALCT uncorrected ECC error in data ALCT received from TMB
	.alct_ecc_tx_err_ff			(alct_ecc_tx_err_ff),			// In	ALCT uncorrected ECC error in data ALCT transmitted to TMB
	.bx0_match_err_ff			(bx0_match_err_ff),				// In	ALCT alct_bx0 != clct_bx0
	.clock_lock_lost_err_ff		(clock_lock_lost_err_ff),		// In	40MHz main clock lost lock FF

         .algo2016_use_dead_time_zone         (algo2016_use_dead_time_zone),         // Out Dead time zone switch: 0 - "old" whole chamber is dead when pre-CLCT is registered, 1 - algo2016 only half-strips around pre-CLCT are marked dead
      .algo2016_dead_time_zone_size        (algo2016_dead_time_zone_size[4:0]),   // Out Constant size of the dead time zone
      .algo2016_use_dynamic_dead_time_zone (algo2016_use_dynamic_dead_time_zone), // Out Dynamic dead time zone switch: 0 - dead time zone is set by algo2016_use_dynamic_dead_time_zone, 1 - dead time zone depends on pre-CLCT pattern ID
      .algo2016_drop_used_clcts            (algo2016_drop_used_clcts),            // Out Drop CLCTs from matching in ALCT-centric algorithm: 0 - algo2016 do NOT drop CLCTs, 1 - drop used CLCTs
      .algo2016_cross_bx_algorithm         (algo2016_cross_bx_algorithm),         // Out LCT sorting using cross BX algorithm: 0 - "old" no cross BX algorithm used, 1 - algo2016 uses cross BX algorithm
      .algo2016_clct_use_corrected_bx      (algo2016_clct_use_corrected_bx),      // Out Use median of hits for CLCT timing: 0 - "old" no CLCT timing corrections, 1 - algo2016 CLCT timing calculated based on median of hits NOT YET IMPLEMENTED:
      .seq_trigger_nodeadtime (seq_trigger_nodeadtime),  //Out no dead time for seq-trigger      attern_finder_ccLUT_tmb upattern_finder_cclut
      .evenchamber                         (evenchamber),   // evenodd parity. 1 for even chamber and 0 for odd chamber


// Sump
	.vme_sump					(vme_sump)						// Out	Unused signals
	);

//-------------------------------------------------------------------------------------------------------------------
// Unused Signal Sump
//-------------------------------------------------------------------------------------------------------------------
// JGedit, gotta remove rpc_sump...	assign sump = ccb_sump | alct_sump |   rpc_sump   | sequencer_sump | tmb_sump | buf_sump	|
	assign sump = ccb_sump | alct_sump | sequencer_sump | tmb_sump | buf_sump	|
	vme_sump | rpc_inj_sel | mini_sump | (|cfeb_sump) | inj_ram_sump   | clock_ctrl_sump;

//-------------------------------------------------------------------------------------------------------------------
	endmodule
//-------------------------------------------------------------------------------------------------------------------
