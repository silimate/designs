/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE Memory Controller Chip Select Register File       ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/mem_ctrl/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000 Rudolf Usselmann                         ////
////                    rudi@asics.ws                            ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: mc_cs_rf.v,v 1.2 2001/08/10 08:16:21 rudi Exp $
//
//  $Date:   22 Sep 2004 19:10:16  $
//  $Revision:   1.0  $
//  $Author:   kbrunham  $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log:   /pvcs/designs/hdl/oc_mem_ctrl/mc_cs_rf.v__  $
// 
//    Rev 1.0   22 Sep 2004 19:10:16   kbrunham
// initial version 
// TO, Wed Sep 22 03:09:49 2004
// 
//    Rev 1.0   09 Sep 2003 15:47:12   kbrunham
// initial version
// TO, Mon Sep 08 23:47:02 2003
//               Revision 1.2  2001/08/10 08:16:21  rudi
//
//               - Changed IO names to be more clear.
//               - Uniquifyed define names to be core specific.
//               - Removed "Refresh Early" configuration
//
//               Revision 1.1  2001/07/29 07:34:41  rudi
//
//
//               1) Changed Directory Structure
//               2) Fixed several minor bugs
//
//               Revision 1.3  2001/06/12 15:19:49  rudi
//
//
//               Minor changes after running lint, and a small bug fix reading csr and ba_mask registers.
//
//               Revision 1.2  2001/06/03 11:37:17  rudi
//
//
//               1) Fixed Chip Select Mask Register
//               	- Power On Value is now all ones
//               	- Comparison Logic is now correct
//
//               2) All resets are now asynchronous
//
//               3) Converted Power On Delay to an configurable item
//
//               4) Added reset to Chip Select Output Registers
//
//               5) Forcing all outputs to Hi-Z state during reset
//
//               Revision 1.1.1.1  2001/05/13 09:39:42  rudi
//               Created Directory Structure
//
//
//
//

`include "mc_defines.v"

module mc_cs_rf(clk, rst, wb_we_i, din, rf_we, addr, csc, tms, poc, csc_mask, cs,
		wp_err, lmr_req, lmr_ack, init_req, init_ack );

input		clk, rst;
input		wb_we_i;
input	[31:0]	din;
input		rf_we;
input	[31:0]	addr;

output	[31:0]	csc;
output	[31:0]	tms;
input	[31:0]	poc;
input	[31:0]	csc_mask;
output		cs;
output		wp_err;

output		lmr_req;
input		lmr_ack;
output		init_req;
input		init_ack;

parameter	[2:0]	this_cs = 0;
parameter	[3:0]	reg_select = this_cs + 2;

////////////////////////////////////////////////////////////////////
//
// Local Registers and Wires
//

reg	[31:0]	csc;
reg	[31:0]	tms;
wire		sel;
wire		cs_d;
wire		wp;
reg		inited;
reg		init_req;
reg		init_req_we;
reg		lmr_req;
reg		lmr_req_we;

////////////////////////////////////////////////////////////////////
//
// Write Logic
//

assign sel = addr[6:3] == reg_select[3:0];

always @(posedge clk)
	if(!rst)			csc <= #1 (this_cs[2:0] == `MC_DEF_SEL) ? 
			{26'h0, poc[1:0], 1'b0, poc[3:2], (poc[3:2] != 2'b00)} : 32'h0;
	else
	if(rf_we & sel & !addr[2])	csc <= #1 din;

always @(posedge clk)
	if(!rst)			tms <= #1 (this_cs[2:0] == `MC_DEF_SEL) ?
						`MC_DEF_POR_TMS : 32'h0;
	else
	if(rf_we & sel & addr[2])	tms <= #1 din;

////////////////////////////////////////////////////////////////////
//
// Load Mode Register Request/Ack Logic
//
always @(posedge clk)
	lmr_req_we <= #1 rf_we & sel & addr[2];

always @(posedge clk or negedge rst)
	if(!rst)	lmr_req <= #1 1'b0;
	else
	if(lmr_req_we & (csc[3:1] == `MC_MEM_TYPE_SDRAM))
			lmr_req <= #1 inited;
	else
	if(lmr_ack)	lmr_req <= #1 1'b0;

////////////////////////////////////////////////////////////////////
//
// Initialize SDRAM Request/Ack & tracking logic
//
always @(posedge clk)
	init_req_we <= #1 rf_we & sel & !addr[2];

always @(posedge clk or negedge rst)
	if(!rst)	init_req <= #1 1'b0;
	else
	if(init_req_we & (csc[3:1] == `MC_MEM_TYPE_SDRAM) & csc[0] & !inited)
			init_req <= #1 1'b1;
	else
	if(init_ack)	init_req <= #1 1'b0;

always @(posedge clk or negedge rst)
	if(!rst)	inited <= #1 1'b0;
	else
	if(init_ack)	inited <= #1 1'b1;

////////////////////////////////////////////////////////////////////
//
// Chip Select Generation Logic
//

assign cs_d = ((csc[23:16] & csc_mask[7:0]) == (addr[28:21] & csc_mask[7:0])) & csc[0];

assign wp = wb_we_i & csc[8];

assign wp_err = cs_d &  wp;
assign cs     = cs_d & !wp;

endmodule



// This dummy is used to terminate the outputs for non existing Chip Selects
module mc_cs_rf_dummy(clk, rst, wb_we_i, din, rf_we, addr, csc, tms, poc, csc_mask, cs,
		wp_err, lmr_req, lmr_ack, init_req, init_ack );

parameter	[2:0]	this_cs = 0;

input		clk, rst;
input		wb_we_i;
input	[31:0]	din;
input		rf_we;
input	[31:0]	addr;

output	[31:0]	csc;
output	[31:0]	tms;
input	[31:0]	poc;
input	[31:0]	csc_mask;
output		cs;
output		wp_err;

output		lmr_req;
input		lmr_ack;
output		init_req;
input		init_ack;

assign csc = 32'h0;
assign tms = 32'h0;
assign cs = 1'b0;
assign wp_err = 1'b0;
assign lmr_req = 1'b0;
assign init_req = 1'b0;

endmodule
