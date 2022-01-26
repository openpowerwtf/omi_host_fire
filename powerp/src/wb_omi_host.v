//
// Copyright 2021 International Business Machines
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// The patent license granted to you in Section 3 of the License, as applied
// to the "Work," hereby includes implementations of the Work in physical form.
//
// Unless required by applicable law or agreed to in writing, the reference design
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// The background Specification upon which this is based is managed by and available from
// the OpenCAPI Consortium.  More information can be found at https://opencapi.org.
//

// Wishbone Slave OMI Host
//
// Wishbone 32b, nonpipelined
// PHY
//   PHY lane usage handled by configuring DL (1/2/4/8)
//   PHY bits configured here (1/2/4/8/16/32/64 bits per lane per cycle)
//
// OC Transactions used:
//   pr_read_mem, 4B (32B with prefetch option)
//   > mem_rd_fail, mem_rd_response
//   pr_write_mem, 4B (with PABE extension to OC)
//   > mem_wr_fail, mem_wr_response
//  Plus:
//   return_tl_credits (TL rsp)
//   return_tlx_credits (TLx rsp)
//
// Prefetch Option:
//   Convert all WB reads to 32B reads
//   Cache one line to service subsequent reads until write-hit or read-miss
//   TLx returns all data at once so no need to worry about critical-first
//
// Spec claims intrp_req, intrp_req.d are mandatory tlx commands, but intrp_rdy is only mandatory
//   when afu issues intrp_req.


// Implemented transaction packets
//`define TL_CMD_NOP 0x00
`define TL_CMD_PR_RD_MEM 8'h28
`define TL_CMD_PR_WR_MEM 8'h86
//`define TL_RSP_NOP 8'h00
//`define TL_RSP_RTN_TLX_CREDITS 8'h01
//`define TLX_CMD_NOP 8'h00
//`define TLX_RSP_NOP 8'h00
//`define TLX_RSP_RTN_TL_CREDITS 8'h01
`define TLX_RSP_RD_RESPONSE 8'h01
`define TLX_RSP_RD_FAILED 8'h02
`define TLX_RSP_WR_RESPONSE 8'h04
`define TLX_RSP_WR_FAILED 8'h05

`define RSP_INITIAL_CREDITS 7'h7F

`timescale 1ns / 10ps

module wb_omi_host #(
        parameter PHY_BITS = 8,
        parameter OMI_CLK_RATIO = 1
)
(
        input                       clk,
        input                       clk_omi,
        input                       rst,

        input                       wb_cyc,
        input                       wb_stb,
        input                       wb_we,
        input   [3:0]               wb_sel,
        input   [31:0]              wb_adr,
        input   [31:0]              wb_dat_i,
        output                      wb_ack,
        output  [31:0]              wb_dat_o,

        input                       ln0_rx_valid,
        input   [1:0]               ln0_rx_header,
        input   [PHY_BITS-1:0]      ln0_rx_data,
        output                      ln0_rx_slip,
        input                       ln1_rx_valid,
        input   [1:0]               ln1_rx_header,
        input   [PHY_BITS-1:0]      ln1_rx_data,
        output                      ln1_rx_slip,
        input                       ln2_rx_valid,
        input   [1:0]               ln2_rx_header,
        input   [PHY_BITS-1:0]      ln2_rx_data,
        output                      ln2_rx_slip,
        input                       ln3_rx_valid,
        input   [1:0]               ln3_rx_header,
        input   [PHY_BITS-1:0]      ln3_rx_data,
        output                      ln3_rx_slip,
        input                       ln4_rx_valid,
        input   [1:0]               ln4_rx_header,
        input   [PHY_BITS-1:0]      ln4_rx_data,
        output                      ln4_rx_slip,
        input                       ln5_rx_valid,
        input   [1:0]               ln5_rx_header,
        input   [PHY_BITS-1:0]      ln5_rx_data,
        output                      ln5_rx_slip,
        input                       ln6_rx_valid,
        input   [1:0]               ln6_rx_header,
        input   [PHY_BITS-1:0]      ln6_rx_data,
        output                      ln6_rx_slip,
        input                       ln7_rx_valid,
        input   [1:0]               ln7_rx_header,
        input   [PHY_BITS-1:0]      ln7_rx_data,
        output                      ln7_rx_slip,
        output  [PHY_BITS-1:0]      dlx_l0_tx_data,
        output  [PHY_BITS-1:0]      dlx_l1_tx_data,
        output  [PHY_BITS-1:0]      dlx_l2_tx_data,
        output  [PHY_BITS-1:0]      dlx_l3_tx_data,
        output  [PHY_BITS-1:0]      dlx_l4_tx_data,
        output  [PHY_BITS-1:0]      dlx_l5_tx_data,
        output  [PHY_BITS-1:0]      dlx_l6_tx_data,
        output  [PHY_BITS-1:0]      dlx_l7_tx_data,
        output  [1:0]               dlx_l0_tx_header,
        output  [1:0]               dlx_l1_tx_header,
        output  [1:0]               dlx_l2_tx_header,
        output  [1:0]               dlx_l3_tx_header,
        output  [1:0]               dlx_l4_tx_header,
        output  [1:0]               dlx_l5_tx_header,
        output  [1:0]               dlx_l6_tx_header,
        output  [1:0]               dlx_l7_tx_header,
        output  [1:0]               dlx_l0_tx_seq,
        output  [1:0]               dlx_l1_tx_seq,
        output  [1:0]               dlx_l2_tx_seq,
        output  [1:0]               dlx_l3_tx_seq,
        output  [1:0]               dlx_l4_tx_seq,
        output  [1:0]               dlx_l5_tx_seq,
        output  [1:0]               dlx_l6_tx_seq,
        output  [1:0]               dlx_l7_tx_seq,

        //wtf are these config bits for dl?? i think gckn is clk_n?
        input                       ocde,
        input                       reg_04_val,
        output                      reg_04_hwwe,
        output  [31:0]              reg_04_update,
        output                      reg_05_hwwe,
        output  [31:0]              reg_05_update,
        output                      reg_06_hwwe,
        output  [31:0]              reg_06_update,
        output                      reg_07_hwwe,
        output  [31:0]              reg_07_update,
        output                      dlx_reset,

        // wtf generic i/o for various possible real/virt phy's
        // could use these to control bits, etc. dynamically
        input   [3:0]                phy_id,
        input   [31:0]               phy_in,
        output  [31:0]               phy_out,

   //wtf need these resets for sim and to connect to phy?
   //-- Xilinx PHY interface with DLx
      input clk_156_25MHz,                 // --  < input
      output gtwiz_reset_all_out,           // --  > output
      input hb_gtwiz_reset_all_in      ,   // --  < input
      input gtwiz_reset_tx_done_in      ,  // --  < input
      input gtwiz_reset_rx_done_in       , // --  < input
      input gtwiz_buffbypass_tx_done_in   ,// --  < input
      input gtwiz_buffbypass_rx_done_in ,  // --  < input
      input gtwiz_userclk_tx_active_in   , // --  < input
      input gtwiz_userclk_rx_active_in ,   // --  < input
      input send_first                  ,  // --  < input
// Signal used to indicate if the DLx should wait to transmit data before or after it starts receiving data.
// ************************************************************
// Determine when to first start sending pattern 'A'
// ************************************************************
// -- Note: In the 2 DLx/Transceiver design, one DLx should start transmitting pattern 'A' first while the other one waits
//          to receive it before it starts transmitting the same pattern 'A'.
//
//          send_first = 1'b0 : wait until the Xilinx receiver is initialized (receiving data) before transmitting pattern 'A'
//          send_first = 1'b1 : start transmitting pattern 'A' as soon as the Xilinx transmitter is initialized

      output gtwiz_reset_rx_datapath_out  , // --  > output
      input tsm_state2_to_3,
      input tsm_state4_to_5,
      input tsm_state6_to_1

    ) ;

   reg    [2:0]         cmdseq_q;
   wire   [2:0]         cmdseq_d;
   reg                  ack_q;
   wire                 ack_d;
   reg    [15:0]        error_q;
   wire   [15:0]        error_d;
   reg    [$clog2(OMI_CLK_RATIO)-1:0] stretcher_q;
   wire   [$clog2(OMI_CLK_RATIO)-1:0] stretcher_d;
   reg    [$clog2(OMI_CLK_RATIO)-1:0] stretcher_1_q;
   wire   [$clog2(OMI_CLK_RATIO)-1:0] stretcher_1_d;
   reg    [$clog2(OMI_CLK_RATIO)-1:0] shrinker_q;
   wire   [$clog2(OMI_CLK_RATIO)-1:0] shrinker_d;
   reg    [3:0]         cmd_credits_q;
   wire   [3:0]         cmd_credits_d;
   reg    [5:0]         cmd_data_credits_q;
   wire   [5:0]         cmd_data_credits_d;

   wire                 wb_cmd_val;
   wire                 wb_cmd_we;
   wire   [3:0]         wb_cmd_be;
   wire   [31:0]        wb_cmd_adr;
   wire   [31:0]        wb_cmd_dat;
   wire                 idle;
   wire                 tl_ready /* verilator public */;
   wire                 cmd_valid;
   wire   [7:0]         cmd_opcode;
   wire   [63:0]        cmd_pa;
   wire   [15:0]        cmd_afutag;
   wire   [1:0]         cmd_dl;
   wire   [2:0]         cmd_pl;
   wire   [63:0]        cmd_be;
   wire   [3:0]         cmd_flag;
   wire   [15:0]        cmd_bdf;
   wire   [3:0]         cmd_resp_code;
   wire   [15:0]        cmd_capptag;
   wire   [511:0]       cmd_data_bus;
   wire                 cmd_data_bdi;
   wire                 tlx_rsp_valid;
   wire                 rsp_valid;
   wire                 rsp_data_valid;
   wire   [2:0]         rsp_data_cnt;
   wire   [511:0]       rsp_data_bus;
   wire                 rsp_bad;
   wire   [3:0]         cmd_initial_credits;
   wire                 cmd_credits_inc;
   wire                 cmd_credits_dec;
   wire                 cmd_credits_hold;
   wire   [5:0]         cmd_data_initial_credits;
   wire                 cmd_data_credits_inc;
   wire                 cmd_data_credits_dec;
   wire                 cmd_data_credits_hold;
   wire   [6:0]         rsp_initial_credits;
   wire                 init;
   wire                 trans_error;
   wire                 tlx_cmd_credit;
   wire                 cmd_credit;
   wire                 tlx_cmd_data_credit;
   wire                 cmd_data_credit;

   // FF
   always @(posedge clk) begin
      if (rst) begin
         error_q <= 'h0;
         ack_q <= 'b0;
         cmdseq_q <= 'b111;
         cmd_credits_q <= cmd_initial_credits;
         cmd_data_credits_q <= cmd_data_initial_credits;
         stretcher_q <= 'h0;
         stretcher_1_q <= 'h0;
         shrinker_q <= 'h0;
      end else begin
         error_q <= error_d;
         ack_q <= ack_d;
         cmdseq_q <= cmdseq_d;
         cmd_credits_q <= cmd_credits_d;
         cmd_data_credits_q <= cmd_data_credits_d;
         stretcher_q <= stretcher_d;
         stretcher_1_q <= stretcher_1_d;
         shrinker_q <= shrinker_d;
      end
   end

   // Setup

   assign tl_xmit_tmpl_config_0 = 1;
   assign tl_xmit_tmpl_config_1 = 0;
   assign tl_xmit_tmpl_config_2 = 0;
   assign tl_xmit_tmpl_config_3 = 0;
   assign tl_xmit_rate_config_0 = 0;
   assign tl_xmit_rate_config_1 = 0;
   assign tl_xmit_rate_config_2 = 0;
   assign tl_xmit_rate_config_3 = 0;
   assign rcv_tmpl_capability_0 = 1;
   assign rcv_tmpl_capability_1 = 0;
   assign rcv_tmpl_capability_2 = 0;
   assign rcv_tmpl_capability_3 = 0;
   assign rcv_rate_capability_0 = 0;
   assign rcv_rate_capability_1 = 0;
   assign rcv_rate_capability_2 = 0;
   assign rcv_rate_capability_3 = 0;

   assign rsp_initial_credits = `RSP_INITIAL_CREDITS;
/*
tl/ocx_tlx_framer.v:    assign   tlx_afu_resp_initial_credit        =   4'b0111;         //  Set initial rsp credit to 7.  Reserve one for config responses.
tl/ocx_tlx_framer.v:    assign   tlx_afu_cmd_initial_credit         =   4'b1000;         //  Set initial cmd credit to 8.
tl/ocx_tlx_framer.v:    assign   tlx_afu_resp_data_initial_credit   =   6'b001111;       //  Set initial data credit to 15.  Reserve one for cofig responses.
tl/ocx_tlx_framer.v:    assign   tlx_afu_cmd_data_initial_credit    =   6'b100000;       //  Set initial data credit to 32.
*/


   // WB Interface
   // Simple interface does not require req latching

   assign wb_cmd_val = idle & wb_cyc & wb_stb & ~ack_q;
   assign wb_cmd_we = wb_we;
   assign wb_cmd_be = wb_sel;
   assign wb_cmd_adr = wb_adr;
   assign wb_cmd_dat = wb_dat_i;

   assign wb_ack = ack_q;
   assign wb_dat_o = rsp_data_bus[31:0];  //wtf or where is it???

// TL Command
//
// There are 7 credited interfaces exposed by TL.  WB host will only initiate commands and
//  receive responses.
//
// Intefaces used:
//    afu_tl_cmd_valid
//      tl_afu_cmd_initial_credit rcvd from tl
//    afu_tlx_cdata (data is credited separately)
//      tl_afu_cmd_data_credit rcvd from tl
//    tl_afu_resp
//      tl_resp_initial_credit=1
//
// Interfaces unused:
//   tl_afu_cmd
//     afu_tl_cmd_initial_credit=0
//   tl_cfg
//     cfg_tl_initial_credit=0
//   afu_tl_resp
//     tlx_afu_resp_initial_credit
//   afu_tlx_rdata
//     tlx_afu_resp_data_credit rcvd from tl and gracefully ignored
//

// omizer_tx creates tl command from wb request
// Two WB requests: rd-32 and wr-32
// Translate to pr_rd_mem (until prefetch option) and pr_wr_mem.be
// Handle credits normally, but there will never be multiple outstanding for either vc

   assign cmd_credits_inc = cmd_credit & ~cmd_tkn;
   assign cmd_credits_dec = cmd_tkn & ~cmd_credit;
   assign cmd_credits_hold = ~cmd_credits_inc & ~cmd_credits_dec;

   assign cmd_credits_d = ({4{cmd_credits_inc}} & cmd_credits_q + 1) |
                          ({4{cmd_credits_dec}} & cmd_credits_q - 1) |
                          ({4{cmd_credits_hold}} & cmd_credits_q);

   assign cmd_credit_ok = (cmd_credits_q != 0) & (~wb_cmd_we | (cmd_data_credits_q != 0));

   assign cmd_data_credits_inc = cmd_data_credit & ~cmd_tkn;
   assign cmd_data_credits_dec = cmd_tkn & wb_cmd_we & ~cmd_credit;  //wtf how many bytes per credit??? think it's 1 cmd's worth
   assign cmd_data_credits_hold = ~cmd_data_credits_inc & ~cmd_data_credits_dec;

   assign cmd_data_credits_d = ({6{cmd_data_credits_inc}} & cmd_data_credits_q + 1) |
                               ({6{cmd_data_credits_dec}} & cmd_data_credits_q - 1) |
                               ({6{cmd_data_credits_hold}} & cmd_data_credits_q);

   // does ack also need to check rsp_data_valid? assume not since it's a pr_rd

   //tbl cmdseq
   //n cmdseq_q                            cmdseq_d
   //n |   tl_ready                        |
   //n |   | wb_cmd_val                    |   cmd_tkn
   //n |   | |cmd_credit_ok                |   |
   //n |   | || rsp_valid                  |   |
   //n |   | || |rsp_bad                   |   | ack_d
   //n |   | || ||                         |   | | idle
   //n |   | || ||                         |   | | | trans_error
   //n |   | || ||                         |   | | | |
   //b 210 | || ||                         210 | | | |
   //t iii i ii ii                         ooo o o o o
   //*------------------------------------------------
   //* TL Not Ready **********************************
   //s 111 - -- --                         --- 0 0 1 0
   //s 111 0 -- --                         111 - - - -
   //s 111 1 -- --                         001 - - - -
   //* Idle ******************************************
   //s 001 - -- --                         --- - 0 1 0         *
   //s 001 0 -- --                         111 0 - - -         *
   //s 001 1 0- --                         001 0 - - -         * ...zzz...
   //s 001 1 10 --                         001 0 - - -         * need credits
   //s 001 1 11 --                         010 1 - - -         * start transaction
   //* Transaction Pending ***************************
   //s 010 - -- 0-                         010 0 0 0 0
   //s 010 - -- 10                         011 0 1 0 0
   //s 010 - -- 11                         000 0 0 0 0
   //* Response Send **********************************
   //s 011 - -- --                         001 0 0 0 0         * wb_ack=1
   //* Epic Failure **********************************
   //s 000 - -- --                         000 0 0 0 1
   //*------------------------------------------------
   //tbl cmdseq

   // clock crossing *****
   //wtf not sure these are entirely copacetic!  close enough for govt work, esp. since no overlapping cmds/rsps

   // hold cmd_valid, cmd_data_valid, rsp_credit for n cycles (n=omi:wb clk ratio)

   assign stretcher_d = cmd_tkn ? OMI_CLK_RATIO - 1 :
                        cmd_valid ? stretcher_q - 1 : 0;
   assign cmd_valid = cmd_tkn | stretcher_q != 0;
   assign cmd_data_valid = cmd_valid & wb_cmd_we;

   assign stretcher_1_d = ack_q ? OMI_CLK_RATIO - 1 :
                          rsp_credit ? stretcher_1_q - 1 : 0;
   assign rsp_credit = ack_q | stretcher_1_q != 0;

   // sample rsp_valid, cmd_credit, cmd_data_credit for 1 in n cycles

   assign shrinker_d = (shrinker_q == 0) & (tlx_rsp_valid | tlx_cmd_credit | tlx_cmd_data_credit) ? OMI_CLK_RATIO - 1 :
                       shrinker_q > 0 ? shrinker_q - 1 : 0;
   assign rsp_valid = tlx_rsp_valid & shrinker_q == OMI_CLK_RATIO-1;
   assign cmd_credit = tlx_cmd_credit & shrinker_q == OMI_CLK_RATIO-1;
   assign cmd_data_credit = tlx_cmd_data_credit & shrinker_q == OMI_CLK_RATIO-1;
   // clock crossing *****


   assign cmd_opcode = wb_cmd_we ? `TL_CMD_PR_WR_MEM : `TL_CMD_PR_RD_MEM;
   assign cmd_pa = {
      wb_cmd_we ? wb_cmd_be : 4'b0,    // or just always ignore 63:60 in device
      28'b0,
      wb_cmd_adr
   };
   assign cmd_afutag = 0;        // xlate_done, intrp_rdy
   assign cmd_dl = 2'b01;        // resp?
   assign cmd_pl = 3'b010;       // 4B
   assign cmd_be = 64'h0;        // write_mem.be
   assign cmd_flag = 4'h0;       // amo, mem_cntl
   assign cmd_bdf = 16'h0;       // tlx
   assign cmd_resp_code = 3'h0;  // xlate_done, intrp_rdy
   assign cmd_capptag = 16'h0;
   // assume this is always taken when cmd is
   //assign cmd_data_valid = wb_cmd_we & cmd_valid;
   assign cmd_data_bus = {{480{1'b1}}, wb_cmd_dat};   //wtf or vice versa????
   assign cmd_data_bdi = 0; //wtf ?

// TLx Response
//
// Without prefetch, no data storage here

   //wtf will this ensure rsp_data_valid same cycle as rsp_valid??? since just using pr_rd
   assign rsp_rd_req = 1;
   assign rsp_rd_cnt = 'b000; //wtf? what do i want

   assign rsp_ok = (rsp_opcode == `TLX_RSP_RD_RESPONSE) | (rsp_opcode == `TLX_RSP_WR_RESPONSE);

   assign error_d[7:0] = rsp_valid & ~rsp_ok ? rsp_opcode : 8'h0;
   assign error_d[30:8] = 23'h0;
   assign error_d[31] = rsp_valid & ~rsp_ok;

// PHY Interface
//
// How to handle in an extendable way (usable by FPGA GPIO and GTP of various widths)?
// Assume it's a separate component built into SOC and configured to match wb_omi_host for a given platform
//
// should convert from 64b -> PHY_BITS here and then pass on to PHY component?

omi_host #() omi_host
(
   .clk(clk_omi),
   .rst(rst),
   .tlx_afu_ready(tl_ready),

   .cfg_tlx_xmit_tmpl_config_0(tl_xmit_tmpl_config_0),
   .cfg_tlx_xmit_tmpl_config_1(tl_xmit_tmpl_config_1),
   .cfg_tlx_xmit_tmpl_config_2(tl_xmit_tmpl_config_2),
   .cfg_tlx_xmit_tmpl_config_3(tl_xmit_tmpl_config_3),
   .cfg_tlx_xmit_rate_config_0(tl_xmit_rate_config_0),
   .cfg_tlx_xmit_rate_config_1(tl_xmit_rate_config_1),
   .cfg_tlx_xmit_rate_config_2(tl_xmit_rate_config_2),
   .cfg_tlx_xmit_rate_config_3(tl_xmit_rate_config_3),
   .tlx_cfg_in_rcv_tmpl_capability_0(rcv_tmpl_capability_0),
   .tlx_cfg_in_rcv_tmpl_capability_1(rcv_tmpl_capability_1),
   .tlx_cfg_in_rcv_tmpl_capability_2(rcv_tmpl_capability_2),
   .tlx_cfg_in_rcv_tmpl_capability_3(rcv_tmpl_capability_3),
   .tlx_cfg_in_rcv_rate_capability_0(rcv_rate_capability_0),
   .tlx_cfg_in_rcv_rate_capability_1(rcv_rate_capability_1),
   .tlx_cfg_in_rcv_rate_capability_2(rcv_rate_capability_2),
   .tlx_cfg_in_rcv_rate_capability_3(rcv_rate_capability_3),

   .tlx_afu_cmd_initial_credit(cmd_initial_credits),
   .tlx_afu_cmd_credit(tlx_cmd_credit),
   .afu_tlx_cmd_valid(cmd_valid),
   .afu_tlx_cmd_opcode(cmd_opcode),
   .afu_tlx_cmd_pa_or_obj(cmd_pa),
   .afu_tlx_cmd_afutag(cmd_afutag),
   .afu_tlx_cmd_dl(cmd_dl),
   .afu_tlx_cmd_pl(cmd_pl),
   .afu_tlx_cmd_be(cmd_be),
   .afu_tlx_cmd_flag(cmd_flag),
   .afu_tlx_cmd_bdf(acmd_bdf),
   .afu_tlx_cmd_resp_code(cmd_resp_code),
   .afu_tlx_cmd_capptag(cmd_capptag),
   .tlx_afu_cmd_data_initial_credit(cmd_data_initial_credits),
   .tlx_afu_cmd_data_credit(tlx_cmd_data_credit),
   .afu_tlx_cdata_valid(cmd_data_valid),
   .afu_tlx_cdata_bus(cmd_data_bus),
   .afu_tlx_cdata_bdi(cmd_data_bdi),

   .afu_tlx_resp_initial_credit(rsp_initial_credits),
   .afu_tlx_resp_credit(rsp_credit),
   .tlx_afu_resp_valid(tlx_rsp_valid),
   .tlx_afu_resp_opcode(rsp_opcode),
   .tlx_afu_resp_afutag(rsp_afutag),
   .tlx_afu_resp_code(rsp_code),
   .tlx_afu_resp_pg_size(rsp_pg_size),
   .tlx_afu_resp_dl(rsp_dl),
   .tlx_afu_resp_dp(rsp_dp),
   .tlx_afu_resp_host_tag(rsp_host_tag),
   .tlx_afu_resp_cache_state(rsp_cache_state),
   .tlx_afu_resp_addr_tag(rsp_addr_tag),

//wtf how does this work?
   .afu_tlx_resp_rd_req(rsp_rd_req),
   .afu_tlx_resp_rd_cnt(rsp_rd_cnt),
   .tlx_afu_resp_data_valid(rsp_data_valid),
   .tlx_afu_resp_data_bus(rsp_data_bus),
   .tlx_afu_resp_data_bdi(rsp_data_bdi),

//wtf unused
   .afu_tlx_cmd_initial_credit('h0),
   .afu_tlx_cmd_credit('b0),
   .tlx_afu_cmd_valid(),
   .tlx_afu_cmd_opcode(),
   .tlx_afu_cmd_dl(),
   .tlx_afu_cmd_end(),
   .tlx_afu_cmd_pa(),
   .tlx_afu_cmd_flag(),
   .tlx_afu_cmd_os(),
   .tlx_afu_cmd_capptag(),
   .tlx_afu_cmd_pl(),
   .tlx_afu_cmd_be(),
   .cfg_tlx_initial_credit('h0),
   .cfg_tlx_credit_return('b0),
   .tlx_cfg_valid(),
   .tlx_cfg_opcode(),
   .tlx_cfg_pa(),
   .tlx_cfg_t(),
   .tlx_cfg_pl(),
   .tlx_cfg_capptag(),
   .tlx_cfg_data_bus(),
   .tlx_cfg_data_bdi(),
   .afu_tlx_cmd_rd_req('b0),
   .afu_tlx_cmd_rd_cnt('h0),
   .tlx_afu_cmd_data_valid(),
   .tlx_afu_cmd_data_bus(),
   .tlx_afu_cmd_data_bdi(),
   .tlx_afu_resp_initial_credit(),
   .tlx_afu_resp_credit(tlx_afu_resp_credit),
   .afu_tlx_resp_valid('b0),
   .afu_tlx_resp_opcode('h0),
   .afu_tlx_resp_dl('h0),
   .afu_tlx_resp_capptag('h0),
   .afu_tlx_resp_dp('h0),
   .afu_tlx_resp_code('h0),
   .tlx_afu_resp_data_initial_credit(),
   .tlx_afu_resp_data_credit(),
   .afu_tlx_rdata_valid('b0),
   .afu_tlx_rdata_bus('h0),
   .afu_tlx_rdata_bdi('b0),
   .cfg_tlx_resp_valid('b0),
   .cfg_tlx_resp_opcode('h0),
   .cfg_tlx_resp_capptag('h0),
   .cfg_tlx_resp_code('h0),
   .tlx_cfg_resp_ack(),
   .cfg_tlx_rdata_offset('h0),
   .cfg_tlx_rdata_bus('h0),
   .cfg_tlx_rdata_bdi('b0),
   .tlx_cfg_oc3_tlx_version(),
   .ro_dlx_version(),

// phy
   .ln0_rx_valid(ln0_rx_valid),
   .ln0_rx_header(ln0_rx_header),
   .ln0_rx_data(ln0_rx_data),
   .ln0_rx_slip(ln0_rx_slip),
   .ln1_rx_valid(ln1_rx_valid),
   .ln1_rx_header(ln1_rx_header),
   .ln1_rx_data(ln1_rx_data),
   .ln1_rx_slip(ln1_rx_slip),
   .ln2_rx_valid(ln2_rx_valid),
   .ln2_rx_header(ln2_rx_header),
   .ln2_rx_data(ln2_rx_data),
   .ln2_rx_slip(ln2_rx_slip),
   .ln3_rx_valid(ln3_rx_valid),
   .ln3_rx_header(ln3_rx_header),
   .ln3_rx_data(ln3_rx_data),
   .ln3_rx_slip(ln3_rx_slip),
   .ln4_rx_valid(ln4_rx_valid),
   .ln4_rx_header(ln4_rx_header),
   .ln4_rx_data(ln4_rx_data),
   .ln4_rx_slip(ln4_rx_slip),
   .ln5_rx_valid(ln5_rx_valid),
   .ln5_rx_header(ln5_rx_header),
   .ln5_rx_data(ln5_rx_data),
   .ln5_rx_slip(ln5_rx_slip),
   .ln6_rx_valid(ln6_rx_valid),
   .ln6_rx_header(ln6_rx_header),
   .ln6_rx_data(ln6_rx_data),
   .ln6_rx_slip(ln6_rx_slip),
   .ln7_rx_valid(ln7_rx_valid),
   .ln7_rx_header(ln7_rx_header),
   .ln7_rx_data(ln7_rx_data),
   .ln7_rx_slip(ln7_rx_slip),
   .dlx_l0_tx_data(dlx_l0_tx_data),
   .dlx_l1_tx_data(dlx_l1_tx_data),
   .dlx_l2_tx_data(dlx_l2_tx_data),
   .dlx_l3_tx_data(dlx_l3_tx_data),
   .dlx_l4_tx_data(dlx_l4_tx_data),
   .dlx_l5_tx_data(dlx_l5_tx_data),
   .dlx_l6_tx_data(dlx_l6_tx_data),
   .dlx_l7_tx_data(dlx_l7_tx_data),
   .dlx_l0_tx_header(dlx_l0_tx_header),
   .dlx_l1_tx_header(dlx_l1_tx_header),
   .dlx_l2_tx_header(dlx_l2_tx_header),
   .dlx_l3_tx_header(dlx_l3_tx_header),
   .dlx_l4_tx_header(dlx_l4_tx_header),
   .dlx_l5_tx_header(dlx_l5_tx_header),
   .dlx_l6_tx_header(dlx_l6_tx_header),
   .dlx_l7_tx_header(dlx_l7_tx_header),
   .dlx_l0_tx_seq(dlx_l0_tx_seq),
   .dlx_l1_tx_seq(dlx_l1_tx_seq),
   .dlx_l2_tx_seq(dlx_l2_tx_seq),
   .dlx_l3_tx_seq(dlx_l3_tx_seq),
   .dlx_l4_tx_seq(dlx_l4_tx_seq),
   .dlx_l5_tx_seq(dlx_l5_tx_seq),
   .dlx_l6_tx_seq(dlx_l6_tx_seq),
   .dlx_l7_tx_seq(dlx_l7_tx_seq),

   .opt_gckn(clk_omi),
   .dlx_reset(dlx_reset),  //wtf for phy??
   .ocde(ocde),
   .reg_04_val(reg_04_val),
   .reg_04_hwwe(reg_04_hwwe),
   .reg_04_update(reg_04_update),
   .reg_05_hwwe(reg_05_hwwe),
   .reg_05_update(reg_05_update),
   .reg_06_hwwe(reg_06_hwwe),
   .reg_06_update(reg_06_update),
   .reg_07_hwwe(reg_07_hwwe),
   .reg_07_update(reg_07_update),

   //wtf need these resets for sim and to connect to phy?
//-- Xilinx PHY interface with DLx
   .clk_156_25MHz(clk_156_25MHz)    ,             // --  < input
   .gtwiz_reset_all_out(gtwiz_reset_all_out) ,         // --  > output
   .hb_gtwiz_reset_all_in(hb_gtwiz_reset_all_in) ,        // --  < input
   .gtwiz_reset_tx_done_in(gtwiz_reset_tx_done_in),        // --  < input
   .gtwiz_reset_rx_done_in(gtwiz_reset_rx_done_in) ,       // --  < input
   .gtwiz_buffbypass_tx_done_in(gtwiz_buffbypass_tx_done_in),   // --  < input
   .gtwiz_buffbypass_rx_done_in(gtwiz_buffbypass_rx_done_in) ,  // --  < input
   .gtwiz_userclk_tx_active_in(gtwiz_userclk_tx_active_in) ,   // --  < input
   .gtwiz_userclk_rx_active_in(gtwiz_userclk_rx_active_in)  ,  // --  < input
   .send_first(send_first) ,                   // --  < input
   .gtwiz_reset_rx_datapath_out(gtwiz_reset_rx_datapath_out),   // --  > output
   .tsm_state2_to_3(tsm_state2_to_3),
   .tsm_state4_to_5(tsm_state4_to_5),
   .tsm_state6_to_1(tsm_state6_to_1)
);

// Generated
//vtable cmdseq
assign cmdseq_d[2] =
  (cmdseq_q[2] & cmdseq_q[1] & cmdseq_q[0] & ~tl_ready) +
  (~cmdseq_q[2] & ~cmdseq_q[1] & cmdseq_q[0] & ~tl_ready);
assign cmdseq_d[1] =
  (cmdseq_q[2] & cmdseq_q[1] & cmdseq_q[0] & ~tl_ready) +
  (~cmdseq_q[2] & ~cmdseq_q[1] & cmdseq_q[0] & ~tl_ready) +
  (~cmdseq_q[2] & ~cmdseq_q[1] & cmdseq_q[0] & tl_ready & wb_cmd_val & cmd_credit_ok) +
  (~cmdseq_q[2] & cmdseq_q[1] & ~cmdseq_q[0] & ~rsp_valid) +
  (~cmdseq_q[2] & cmdseq_q[1] & ~cmdseq_q[0] & rsp_valid & ~rsp_bad);
assign cmdseq_d[0] =
  (cmdseq_q[2] & cmdseq_q[1] & cmdseq_q[0] & ~tl_ready) +
  (cmdseq_q[2] & cmdseq_q[1] & cmdseq_q[0] & tl_ready) +
  (~cmdseq_q[2] & ~cmdseq_q[1] & cmdseq_q[0] & ~tl_ready) +
  (~cmdseq_q[2] & ~cmdseq_q[1] & cmdseq_q[0] & tl_ready & ~wb_cmd_val) +
  (~cmdseq_q[2] & ~cmdseq_q[1] & cmdseq_q[0] & tl_ready & wb_cmd_val & ~cmd_credit_ok) +
  (~cmdseq_q[2] & cmdseq_q[1] & ~cmdseq_q[0] & rsp_valid & ~rsp_bad) +
  (~cmdseq_q[2] & cmdseq_q[1] & cmdseq_q[0]);
assign cmd_tkn =
  (~cmdseq_q[2] & ~cmdseq_q[1] & cmdseq_q[0] & tl_ready & wb_cmd_val & cmd_credit_ok);
assign ack_d =
  (~cmdseq_q[2] & cmdseq_q[1] & ~cmdseq_q[0] & rsp_valid & ~rsp_bad);
assign idle =
  (cmdseq_q[2] & cmdseq_q[1] & cmdseq_q[0]) +
  (~cmdseq_q[2] & ~cmdseq_q[1] & cmdseq_q[0]);
assign trans_error =
  (~cmdseq_q[2] & ~cmdseq_q[1] & ~cmdseq_q[0]);
//vtable cmdseq

endmodule
