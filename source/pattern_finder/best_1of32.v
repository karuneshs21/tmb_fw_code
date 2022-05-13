`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------------------------------
// Best 1 of 32 1/2-strip hit patterns:
//	Uses compare-by-twos tree to find best 1 of 32 pattern hits
//	Returns pattern ID, hits, and key
//  If two patterns are equal, the lower key is returned
//
//	11/08/06	Initial
//	12/11/06 Add pipeline latches
//	12/13/06 Non-busy version
//	12/20/06 Replace envelope hits with pattern ids
//	12/22/06 Sort based on 6-bit patterns instead of just number of hits
//	01/10/07 Increase pattern bits to 3 hits + 4 bends
//	02/01/07 Revert from sorting on patterns to sorting on hits
//	02/20/07 Go back to sorting on pattern numbers
//	05/07/07 Confirm pipeline is optimized at best 2 of 4 stage
//	05/08/07 Change pattern numbers 1-9 to 0-8 so lsb now implies bend direction, ignore lsb during sort
//	08/20/09 Add register balancing
//	08/21/09 Take out register balancing, ise8.2 does not need it
//	08/12/10 Port to ise 12
//-------------------------------------------------------------------------------------------------------------------
	module best_1of32
	(
	clock,

	pat00, pat01, pat02, pat03, pat04, pat05, pat06, pat07,
	pat08, pat09, pat10, pat11, pat12, pat13, pat14, pat15,
	pat16, pat17, pat18, pat19, pat20, pat21, pat22, pat23,
	pat24, pat25, pat26, pat27, pat28, pat29, pat30, pat31,

	best_pat,
	best_key
	);

// Constants
	parameter MXPIDB		=	4;				// Pattern ID bits
	parameter MXHITB		=	3;				// Hits on pattern bits
	parameter MXPATB		=	3+4;			// Pattern bits
	parameter MXKEYB		=	5;				// Number of 1/2-strip key bits on 1 CFEB

// Ports
	input					clock;

	input	[MXPATB-1:0]	pat00, pat01, pat02, pat03, pat04, pat05, pat06, pat07;
	input	[MXPATB-1:0]	pat08, pat09, pat10, pat11, pat12, pat13, pat14, pat15;
	input	[MXPATB-1:0]	pat16, pat17, pat18, pat19, pat20, pat21, pat22, pat23;
	input	[MXPATB-1:0]	pat24, pat25, pat26, pat27, pat28, pat29, pat30, pat31;

	output	[MXPATB-1:0]	best_pat;
	output	[MXKEYB-1:0]	best_key;

// Local 2d Arrays
	wire [MXPATB-1:0]	pat_s0	[15:0];
	wire [MXPATB-1:0]	pat_s1	[7:0];
	wire [MXPATB-1:0]	pat_s2	[3:0];
	reg  [MXPATB-1:0]	pat_s3	[1:0];
	wire [MXPATB-1:0]	pat_s4	[0:0];

	wire [0:0]	key_s0	[15:0];
	wire [1:0]	key_s1	[7:0];
	wire [2:0]	key_s2	[3:0];
	reg  [3:0]	key_s3	[1:0];
	wire [4:0]	key_s4	[0:0];

// Stage 0: Best 16 of 32
	assign {pat_s0[15],key_s0[15]} = (pat31[6:1] > pat30[6:1]) ? {pat31,1'b1} : {pat30,1'b0};
	assign {pat_s0[14],key_s0[14]} = (pat29[6:1] > pat28[6:1]) ? {pat29,1'b1} : {pat28,1'b0};
	assign {pat_s0[13],key_s0[13]} = (pat27[6:1] > pat26[6:1]) ? {pat27,1'b1} : {pat26,1'b0};
	assign {pat_s0[12],key_s0[12]} = (pat25[6:1] > pat24[6:1]) ? {pat25,1'b1} : {pat24,1'b0};

	assign {pat_s0[11],key_s0[11]} = (pat23[6:1] > pat22[6:1]) ? {pat23,1'b1} : {pat22,1'b0};
	assign {pat_s0[10],key_s0[10]} = (pat21[6:1] > pat20[6:1]) ? {pat21,1'b1} : {pat20,1'b0};
	assign {pat_s0[ 9],key_s0[ 9]} = (pat19[6:1] > pat18[6:1]) ? {pat19,1'b1} : {pat18,1'b0};
	assign {pat_s0[ 8],key_s0[ 8]} = (pat17[6:1] > pat16[6:1]) ? {pat17,1'b1} : {pat16,1'b0};

	assign {pat_s0[ 7],key_s0[ 7]} = (pat15[6:1] > pat14[6:1]) ? {pat15,1'b1} : {pat14,1'b0};
	assign {pat_s0[ 6],key_s0[ 6]} = (pat13[6:1] > pat12[6:1]) ? {pat13,1'b1} : {pat12,1'b0};
	assign {pat_s0[ 5],key_s0[ 5]} = (pat11[6:1] > pat10[6:1]) ? {pat11,1'b1} : {pat10,1'b0};
	assign {pat_s0[ 4],key_s0[ 4]} = (pat09[6:1] > pat08[6:1]) ? {pat09,1'b1} : {pat08,1'b0};

	assign {pat_s0[ 3],key_s0[ 3]} = (pat07[6:1] > pat06[6:1]) ? {pat07,1'b1} : {pat06,1'b0};
	assign {pat_s0[ 2],key_s0[ 2]} = (pat05[6:1] > pat04[6:1]) ? {pat05,1'b1} : {pat04,1'b0};
	assign {pat_s0[ 1],key_s0[ 1]} = (pat03[6:1] > pat02[6:1]) ? {pat03,1'b1} : {pat02,1'b0};
	assign {pat_s0[ 0],key_s0[ 0]} = (pat01[6:1] > pat00[6:1]) ? {pat01,1'b1} : {pat00,1'b0};

// Stage 1: Best 8 of 16
	assign {pat_s1[7],key_s1[7]} = (pat_s0[15][6:1] > pat_s0[14][6:1]) ? {pat_s0[15],{1'b1,key_s0[15]}} : {pat_s0[14],{1'b0,key_s0[14]}};
	assign {pat_s1[6],key_s1[6]} = (pat_s0[13][6:1] > pat_s0[12][6:1]) ? {pat_s0[13],{1'b1,key_s0[13]}} : {pat_s0[12],{1'b0,key_s0[12]}};
	assign {pat_s1[5],key_s1[5]} = (pat_s0[11][6:1] > pat_s0[10][6:1]) ? {pat_s0[11],{1'b1,key_s0[11]}} : {pat_s0[10],{1'b0,key_s0[10]}};
	assign {pat_s1[4],key_s1[4]} = (pat_s0[ 9][6:1] > pat_s0[ 8][6:1]) ? {pat_s0[ 9],{1'b1,key_s0[ 9]}} : {pat_s0[ 8],{1'b0,key_s0[ 8]}};
	assign {pat_s1[3],key_s1[3]} = (pat_s0[ 7][6:1] > pat_s0[ 6][6:1]) ? {pat_s0[ 7],{1'b1,key_s0[ 7]}} : {pat_s0[ 6],{1'b0,key_s0[ 6]}};
	assign {pat_s1[2],key_s1[2]} = (pat_s0[ 5][6:1] > pat_s0[ 4][6:1]) ? {pat_s0[ 5],{1'b1,key_s0[ 5]}} : {pat_s0[ 4],{1'b0,key_s0[ 4]}};
	assign {pat_s1[1],key_s1[1]} = (pat_s0[ 3][6:1] > pat_s0[ 2][6:1]) ? {pat_s0[ 3],{1'b1,key_s0[ 3]}} : {pat_s0[ 2],{1'b0,key_s0[ 2]}};
	assign {pat_s1[0],key_s1[0]} = (pat_s0[ 1][6:1] > pat_s0[ 0][6:1]) ? {pat_s0[ 1],{1'b1,key_s0[ 1]}} : {pat_s0[ 0],{1'b0,key_s0[ 0]}};

// Stage 2: Best 4 of 8
	assign {pat_s2[3],key_s2[3]} = (pat_s1[7][6:1] > pat_s1[6][6:1]) ? {pat_s1[7],{1'b1,key_s1[7]}} : {pat_s1[6],{1'b0,key_s1[6]}};
	assign {pat_s2[2],key_s2[2]} = (pat_s1[5][6:1] > pat_s1[4][6:1]) ? {pat_s1[5],{1'b1,key_s1[5]}} : {pat_s1[4],{1'b0,key_s1[4]}};
	assign {pat_s2[1],key_s2[1]} = (pat_s1[3][6:1] > pat_s1[2][6:1]) ? {pat_s1[3],{1'b1,key_s1[3]}} : {pat_s1[2],{1'b0,key_s1[2]}};
	assign {pat_s2[0],key_s2[0]} = (pat_s1[1][6:1] > pat_s1[0][6:1]) ? {pat_s1[1],{1'b1,key_s1[1]}} : {pat_s1[0],{1'b0,key_s1[0]}};

// Stage 3: Best 2 of 4, pipeline latch
	always @(posedge clock) begin
	       {pat_s3[1],key_s3[1]} = (pat_s2[3][6:1] > pat_s2[2][6:1]) ? {pat_s2[3],{1'b1,key_s2[3]}} : {pat_s2[2],{1'b0,key_s2[2]}};
	       {pat_s3[0],key_s3[0]} = (pat_s2[1][6:1] > pat_s2[0][6:1]) ? {pat_s2[1],{1'b1,key_s2[1]}} : {pat_s2[0],{1'b0,key_s2[0]}};
	end

// Stage 4: Best 1 of 2
	assign {pat_s4[0],key_s4[0]} = (pat_s3[1][6:1] > pat_s3[0][6:1]) ? {pat_s3[1],{1'b1,key_s3[1]}} : {pat_s3[0],{1'b0,key_s3[0]}};

	assign best_pat = pat_s4[0];
	assign best_key = key_s4[0];

	endmodule
