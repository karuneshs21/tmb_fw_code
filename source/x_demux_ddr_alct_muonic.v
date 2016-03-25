`include "firmware_version.v"

`ifdef VIRTEX6
`timescale 1ns / 1ps
//------------------------------------------------------------------------------------------------------------------
// Virtex6: 1-to-2 De-multiplexer converts 80MHz data to 40MHz - ALCT Version
//------------------------------------------------------------------------------------------------------------------
//	07/16/10 Port to Virtex 6
//	07/19/10 Change to non-pipelined iddr to match virtex 2 timing behavior
//	07/22/10 Remove simulator debug ports
//	11/30/10 Add virtex2|6 selection
//------------------------------------------------------------------------------------------------------------------
	module x_demux_ddr_alct_muonic
	(
	clock,
	clock_2x,
	clock_iob,
	clock_lac,
	posneg,
	clr,
	din,
	dout1st,
	dout2nd
	);

// Generic
	parameter WIDTH = 16;
	initial	$display("x_demux_ddr_alct_muonic: WIDTH=%d",WIDTH);

// Ports
	input				clock;			// 40MHz TMB main clock
	input				clock_2x;		// 80MHz commutator clock
	input				clock_iob;		// 40MHZ iob ddr clock
	input				clock_lac;		// 40MHz logic accessible clock
	input				posneg;			// Select inter-stage clock 0 or 180 degrees
	input				clr;			// Sync clear
	input	[WIDTH-1:0]	din;			// 80MHz ddr data
	output	[WIDTH-1:0]	dout1st;		// Data de-multiplexed 1st in time
	output	[WIDTH-1:0]	dout2nd;		// Data de-multiplexed 2nd in time

// Latch 80 MHz multiplexed inputs in DDR IOB FFs in the clock_iob time domain. Latch 1st-in-time on falling edge
	wire [WIDTH-1:0] din1st;
	wire [WIDTH-1:0] din2nd;

	genvar i;
	generate
	for (i=0; i<=WIDTH-1; i=i+1) begin: iddr_gen
	IDDR #(
	.DDR_CLK_EDGE	("SAME_EDGE"),	// "OPPOSITE_EDGE", "SAME_EDGE" or "SAME_EDGE_PIPELINED" 
	.INIT_Q1		(1'b0),			// Initial value of Q1: 1'b0 or 1'b1
	.INIT_Q2		(1'b0),			// Initial value of Q2: 1'b0 or 1'b1
	.SRTYPE			("SYNC")		// Set/Reset type: "SYNC" or "ASYNC" 
	) u0 (
	.C	(clock_iob),				// 1-bit clock input
	.CE	(1'b1),						// 1-bit clock enable input
	.R	(clr),						// 1-bit reset
	.S	(1'b0),						// 1-bit set
	.D	(din[i]),					// 1-bit DDR data input
	.Q2	(din1st[i]),				// 1-bit output for negative edge of clock		Latch 1st-in-time on falling edge
	.Q1	(din2nd[i]));				// 1-bit output for positive edge of clock		Latch 2nd-in-time on rising  edge			
	end
	endgenerate

// Interstage clock enable latches data on rising or falling edge of main clock using clock_2x 
	reg	is_en=0;

	always @(posedge clock_2x)begin
	is_en <= clock_lac ^ posneg;
	end

// Latch demux data in inter-stage time domain
	reg [WIDTH-1:0]	din1st_is=0;
	reg [WIDTH-1:0]	din2nd_is=0;

	always @(posedge clock_2x) begin
	if (is_en) begin
	din1st_is <= din1st;
	din2nd_is <= din2nd;
	end
	end

// Synchronize demux data in main clock time domain
	reg [WIDTH-1:0]	dout1st=0;
	reg [WIDTH-1:0]	dout2nd=0;

	always @(posedge clock) begin
	if (clr) begin
	dout1st <= 0;
	dout2nd <= 0;
	end
	else begin
	dout1st <= din1st_is;
	dout2nd <= din2nd_is;
	end
	end

//------------------------------------------------------------------------------------------------------------------
	endmodule
//------------------------------------------------------------------------------------------------------------------


`elsif VIRTEX2
`timescale 1ns / 1ps
//------------------------------------------------------------------------------------------------------------------
// Virtex2: 1-to-2 De-multiplexer converts 80MHz data to 40MHz - ALCT Version
//------------------------------------------------------------------------------------------------------------------
// 07/10/09 Initial	Copy from cfeb version, only difference is iob attribute is enabled in verilog, does not use ucf
// 07/22/09 Remove posneg
// 08/05/09 Remove interstage delay SRL and iob async clear, add final stage sync clear
// 08/13/09 Put posneg back in
// 08/20/09 2x posneg version with new ucf locs
// 07/19/10 Conform to virtex 6 ports
//------------------------------------------------------------------------------------------------------------------
	module x_demux_ddr_alct_muonic
	(
	clock,
	clock_2x,
	clock_iob,
	clock_lac,
	posneg,
	clr,
	din,
	dout1st,
	dout2nd
	);

// Generic
	parameter WIDTH = 16;
	initial	$display("x_demux_ddr_alct_muonic: WIDTH=%d",WIDTH);

// Ports
	input				clock;			// 40MHz TMB main clock
	input				clock_2x;		// 80MHz commutator clock
	input				clock_iob;		// 40MHZ iob ddr clock
	input				clock_lac;		// 40MHz logic accessible clock
	input				posneg;			// Select inter-stage clock 0 or 180 degrees
	input				clr;			// Sync clear
	input	[WIDTH-1:0]	din;			// 80MHz ddr data
	output	[WIDTH-1:0]	dout1st;		// Data de-multiplexed 1st in time
	output	[WIDTH-1:0]	dout2nd;		// Data de-multiplexed 2nd in time

// Latch 80 MHz multiplexed inputs in DDR IOB FFs in the clock_iob time domain
	reg		[WIDTH-1:0]	din1st=0;		// synthesis attribute IOB of din1st is "true";
	reg		[WIDTH-1:0]	din2nd=0;		// synthesis attribute IOB of din2nd is "true";		

	always @(negedge clock_iob) begin	// Latch 1st-in-time on falling edge
	din1st <= din;
	end
	always @(posedge clock_iob) begin	// Latch 2nd-in-time on rising edge
	din2nd <= din;
	end

// Delay 1st-in-time by 1/2 cycle to align with 2nd-in-time, in the clock_iob time domain
	reg	 [WIDTH-1:0] din1st_ff=0;

	always @(posedge clock_iob) begin
	din1st_ff <= din1st;
	end

// Interstage clock enable latches data on rising or falling edge of main clock using clock_2x 
	reg	is_en=0;

	always @(posedge clock_2x)begin
	is_en <= clock_lac ^ posneg;
	end

// Latch demux data in inter-stage time domain
	reg [WIDTH-1:0]	din1st_is=0;
	reg [WIDTH-1:0]	din2nd_is=0;

	always @(posedge clock_2x) begin
	if (is_en) begin
	din1st_is <= din1st_ff;
	din2nd_is <= din2nd;
	end
	end

// Synchronize demux data in main clock time domain
	reg [WIDTH-1:0]	dout1st=0;
	reg [WIDTH-1:0]	dout2nd=0;

	always @(posedge clock) begin
	if (clr) begin
	dout1st <= 0;
	dout2nd <= 0;
	end
	else begin
	dout1st <= din1st_is;
	dout2nd <= din2nd_is;
	end
	end

//------------------------------------------------------------------------------------------------------------------
	endmodule
//------------------------------------------------------------------------------------------------------------------
`endif
