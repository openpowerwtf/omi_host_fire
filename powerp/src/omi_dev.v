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

// Simple OMI Device
//
// Internal memory
// One TL credit
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
// Spec claims intrp_req, intrp_req.d are mandatory tlx commands, but intrp_rdy is only mandatory
//   when afu issues intrp_req.


// Implemented transaction packets
//`define TL_CMD_NOP 0x00
`define TL_CMD_PR_RD_MEM 8'h28
`define TL_CMD_PR_WR_MEM 8'h86
//`define TL_RSP_NOP 8'h00
//`define TL_RSP_RTN_TLX_CREDITS 8'h01

//`define TLX_CMD_NOP 8'h00
`define TLX_RSP_NOP 8'h00
`define TLX_RSP_RTN_TL_CREDITS 8'h08
`define TLX_RSP_RD_RESPONSE 8'h01
`define TLX_RSP_RD_FAILED 8'h02
`define TLX_RSP_WR_RESPONSE 8'h04
`define TLX_RSP_WR_FAILED 8'h05

`define CMD_INITIAL_CREDITS 6'h3F
`define CFG_CMD_INITIAL_CREDITS 6'h3F

//`define RSP_INITIAL_CREDITS 7'h7F

`timescale 1ns / 10ps

module omi_dev #(
        parameter PHY_BITS = 8,
        parameter MEM_SIZE = 1024   // words
)
(
        input                             clk,
        input                             rst,

        output  [31:0]                    ro_dlx_version,
        input                             ln0_rx_valid,
        input   [1:0]                     ln0_rx_header,
        input   [63:0]                    ln0_rx_data,
        output                            ln0_rx_slip,
        input                             ln1_rx_valid,
        input   [1:0]                     ln1_rx_header,
        input   [63:0]                    ln1_rx_data,
        output                            ln1_rx_slip,
        input                             ln2_rx_valid,
        input   [1:0]                     ln2_rx_header,
        input   [63:0]                    ln2_rx_data,
        output                            ln2_rx_slip,
        input                             ln3_rx_valid,
        input   [1:0]                     ln3_rx_header,
        input   [63:0]                    ln3_rx_data,
        output                            ln3_rx_slip,
        input                             ln4_rx_valid,
        input   [1:0]                     ln4_rx_header,
        input   [63:0]                    ln4_rx_data,
        output                            ln4_rx_slip,
        input                             ln5_rx_valid,
        input   [1:0]                     ln5_rx_header,
        input   [63:0]                    ln5_rx_data,
        output                            ln5_rx_slip,
        input                             ln6_rx_valid,
        input   [1:0]                     ln6_rx_header,
        input   [63:0]                    ln6_rx_data,
        output                            ln6_rx_slip,
        input                             ln7_rx_valid,
        input   [1:0]                     ln7_rx_header,
        input   [63:0]                    ln7_rx_data,
        output                            ln7_rx_slip,
        output  [63:0]                    dlx_l0_tx_data,
        output  [63:0]                    dlx_l1_tx_data,
        output  [63:0]                    dlx_l2_tx_data,
        output  [63:0]                    dlx_l3_tx_data,
        output  [63:0]                    dlx_l4_tx_data,
        output  [63:0]                    dlx_l5_tx_data,
        output  [63:0]                    dlx_l6_tx_data,
        output  [63:0]                    dlx_l7_tx_data,
        output  [1:0]                     dlx_l0_tx_header,
        output  [1:0]                     dlx_l1_tx_header,
        output  [1:0]                     dlx_l2_tx_header,
        output  [1:0]                     dlx_l3_tx_header,
        output  [1:0]                     dlx_l4_tx_header,
        output  [1:0]                     dlx_l5_tx_header,
        output  [1:0]                     dlx_l6_tx_header,
        output  [1:0]                     dlx_l7_tx_header,
        output  [1:0]                     dlx_l0_tx_seq,
        output  [1:0]                     dlx_l1_tx_seq,
        output  [1:0]                     dlx_l2_tx_seq,
        output  [1:0]                     dlx_l3_tx_seq,
        output  [1:0]                     dlx_l4_tx_seq,
        output  [1:0]                     dlx_l5_tx_seq,
        output  [1:0]                     dlx_l6_tx_seq,
        output  [1:0]                     dlx_l7_tx_seq,

        input                             opt_gckn,
        input                             ocde,
        input                             reg_04_val,
        output                            reg_04_hwwe,
        output  [31:0]                    reg_04_update,
        output                            reg_05_hwwe,
        output  [31:0]                    reg_05_update,
        output                            reg_06_hwwe,
        output  [31:0]                    reg_06_update,
        output                            reg_07_hwwe,
        output  [31:0]                    reg_07_update,
        output                            dlx_reset,

    //wtf need some for phy reset?
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
      output gtwiz_reset_rx_datapath_out  , // --  > output
      input tsm_state2_to_3,
      input tsm_state4_to_5,
      input tsm_state6_to_1
    ) ;

   reg    [31:0]        mem[MEM_SIZE-1:0];

   reg    [2:0]         cmdseq_q;
   wire   [2:0]         cmdseq_d;
   reg    [15:0]        error_q;
   wire   [15:0]        error_d;
   reg    [6:0]         rsp_credits_q;
   wire   [6:0]         rsp_credits_d;
   reg    [31:0]        mem_adr_q;
   wire   [31:0]        mem_adr_d;
   reg    [3:0]         mem_be_q;
   wire   [3:0]         mem_be_d;
   reg    [31:0]        mem_datr_q;
   wire   [31:0]        mem_datr_d;
   reg    [31:0]        mem_datw_q;
   wire   [31:0]        mem_datw_d;

   wire                 tlx_ready /* verilator public */;
   wire                 dev_error;
   wire                 rsp_credits_inc;
   wire                 rsp_credits_dec;
   wire                 rsp_credits_hold;
   wire                 rsp_credit_ok;

   wire   [6:0]         rsp_initial_credits;
   wire                 rsp_credit;
   wire                 tlx_ready;
   wire   [511:0]       dlx_tlx_flit;
   wire   [511:0]       tlx_dlx_flit;
   wire                 tlx_dlx_flit_valid;
   wire   [3:0]         tlx_dlx_debug_encode;
   wire   [31:0]        tlx_dlx_debug_info;
   wire                 dlx_tlx_flit_valid;
   wire                 dlx_tlx_flit_crc_err;
   wire                 dlx_tlx_link_up /* verilator public */;
   wire                 dlx_tlx_flit_credit;
   wire   [2:0]         dlx_tlx_init_flit_depth;
   //wire   [31:0]      dlx_tlx_dlx_config_info;
   wire   [31:0]        dlx_config_info /* verilator public */;

   wire                 tlx_cmd_valid;
   wire                 tlx_cmd_credit;
   wire   [7:0]         tlx_cmd_opcode;
   wire   [1:0]         tlx_cmd_dl;
   wire                 tlx_cmd_end;
   wire   [63:0]        tlx_cmd_pa;
   wire   [3:0]         tlx_cmd_flag;
   wire                 tlx_cmd_os;
   wire   [2:0]         tlx_cmd_pl;
   wire   [63:0]        tlx_cmd_be;
   wire   [15:0]        tlx_cmd_capptag;
   wire                 tlx_cdata_valid;
   wire   [511:0]       tlx_cdata_bus;
   wire                 tlx_cdata_bdi;
   wire                 tlx_cmd_rd_req;
   wire   [2:0]         tlx_cmd_rd_cnt;
   wire                 tlx_rd;
   wire                 tlx_wr;
   wire                 do_read;
   wire                 do_write;
   wire                 rsp_valid;
   wire                 send_credit;
   wire                 rsp_tkn;
   wire   [7:0]         rsp_opcode;
   wire   [63:0]        rsp_pa;
   wire   [15:0]        rsp_afutag;
   wire   [1:0]         rsp_dl;
   wire   [2:0]         rsp_pl;
   wire   [63:0]        rsp_be;
   wire   [3:0]         rsp_flag;
   wire   [15:0]        rsp_bdf;
   wire   [3:0]         rsp_code;
   wire                 rdata_valid;
   wire   [511:0]       rdata_bus;
   wire                 rdata_bdi;


   // FF
   always @(posedge clk) begin
      if (rst) begin
         error_q <= 'h0;
         cmdseq_q <= 'b111;
         rsp_credits_q <= rsp_initial_credits;
         mem_adr_q <= 'h0;
         mem_be_q <= 'h0;
         mem_datr_q <= 'h0;
         mem_datw_q <= 'h0;
      end else begin
         error_q <= error_d;
         cmdseq_q <= cmdseq_d;
         rsp_credits_q <= rsp_credits_d;
         mem_adr_q <= mem_adr_d;
         mem_be_q <= mem_be_d;
         mem_datr_q <= mem_datr_d;
         mem_datw_q <= mem_datw_d;
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

   assign tlx_rd = tlx_cmd_valid & (tlx_cmd_opcode == `TL_CMD_PR_RD_MEM);
   assign tlx_wr = tlx_cmd_valid & (tlx_cmd_opcode == `TL_CMD_PR_WR_MEM);

   // Do something

   //wtf can write data come ahead of write cmd?
   //wtf need to do anything if tlx goes nonready?

   //tbl cmdseq
   //n cmdseq_q                          cmdseq_d
   //n |   tlx_ready                     |   do_read
   //n |   | tlx_rd                      |   |do_write
   //n |   | |tlx_wr                     |   || send_credit
   //n |   | ||tlx_cdata_valid           |   || |
   //n |   | ||| rsp_tkn                 |   || |
   //n |   | ||| |                       |   || | dev_error
   //n |   | ||| |                       |   || | |
   //b 210 | ||| |                       210 || | |
   //t iii i iii i                       ooo oo o o
   //*------------------------------------------------
   //* Reset *****************************************
   //s 111 0 --- -                       111 00 0 0         * wait for TLx
   //s 111 1 --- -                       001 00 0 0         *
   //* Idle ******************************************
   //s 001 - 000 -                       001 00 0 0         * ...zzz...
   //s 001 - 1-- -                       010 00 0 0         * TL read
   //s 001 - -10 -                       100 00 0 0         * TL write, wait for data
   //s 001 - -01 -                       101 00 0 0         * TL write data, wait for cmd
   //s 001 - -11 -                       110 00 0 0         * TL write with data
   //* Read ******************************************
   //s 010 - --- 0                       010 10 0 0         * processing...
   //s 010 - --- 1                       001 10 1 0         * responding
   //* Write, Data Pending ***************************
   //s 100 - --0 -                       100 00 0 0         * waiting for data
   //s 100 - --1 -                       101 00 0 0         *
   //* Write, Cmd Pending ****************************
   //s 101 - -0- -                       101 00 0 0         * waiting for cmd
   //s 101 - -1- -                       110 00 0 0         *
   //* Write *****************************************
   //s 110 - --- 0                       110 01 0 0         * processing...
   //s 110 - --- 1                       001 01 1 0         * responding
   //* Inglorious Ending *****************************
   //s 000 - --- -                       000 0    1         * seq error
   //*------------------------------------------------
   //tbl cmdseq

   assign rsp_credits_inc = rsp_credit & ~rsp_tkn;
   assign rsp_credits_dec = rsp_tkn & ~rsp_credit;
   assign rsp_credits_hold = ~rsp_credits_inc & ~rsp_credits_dec;

   assign rsp_credits_d = ({4{rsp_credits_inc}} & rsp_credits_q + 1) |
                          ({4{rsp_credits_dec}} & rsp_credits_q - 1) |
                          ({4{rsp_credits_hold}} & rsp_credits_q);

   assign rsp_credit_ok = (rsp_credits_q != 0);

   assign mem_adr_d = (tlx_rd | tlx_wr) ? tlx_cmd_pa[31:0] : mem_adr_q;
   assign mem_be_d = tlx_wr ? tlx_cmd_pa[63:60] : mem_be_q;
   assign mem_datr_d = (tlx_rd | tlx_wr) ? mem[tlx_cmd_pa[31:2]] : mem_datr_q;  // word addr
   assign mem_datw_d = tlx_cdata_valid ? tlx_cdata_bus[31:0] : mem_datw_q;

   always @ (*) begin
      if (do_write) begin
         mem[mem_adr_q[31:2]] = {mem_be_q[3] ? mem_datw_q[31:24] : mem_datr_q[31:24],
                                 mem_be_q[2] ? mem_datw_q[23:16] : mem_datr_q[23:16],
                                 mem_be_q[1] ? mem_datw_q[15:8]  : mem_datr_q[15:8] ,
                                 mem_be_q[0] ? mem_datw_q[7:0]   : mem_datr_q[7:0]  };
      end
   end

   assign rsp_valid = do_read | do_write;
   assign rsp_tkn = rsp_valid & rsp_credit_ok;
   assign rsp_opcode = do_read ? `TLX_RSP_RD_RESPONSE : `TLX_RSP_WR_RESPONSE;
   assign rsp_dl = 2'b01;
   assign rsp_afutag = 16'h0;
   assign rsp_dp = 2'b00;
   assign rsp_code = 4'h0; // fail only

   assign rdata_valid = do_read;  //wtf credits? dont see any
   assign rdata_bus = {{480{1'b1}}, mem_datr_q};
   assign rdata_bdi = 1'b0; //wtf?

   assign tlx_cmd_credit = send_credit;

   assign tlx_cmd_rd_req = 1; // this reads cmd data - could wait till after get cmd; also don't have to latch it here i guess
   assign tlx_cmd_rd_cnt = 3'd0;

ocx_tlx_top #(.GEMINI_NOT_APOLLO(1)) tl
(
   .clk(clk),
   .rst(rst),
   .tlx_afu_ready(tlx_ready),
   // r/w
   .afu_tlx_cmd_initial_credit(`CMD_INITIAL_CREDITS),
   .afu_tlx_cmd_credit(tlx_cmd_credit),
   .tlx_afu_cmd_valid(tlx_cmd_valid),
   .tlx_afu_cmd_opcode(tlx_cmd_opcode),
   .tlx_afu_cmd_dl(tlx_cmd_dl),
   .tlx_afu_cmd_end(tlx_cmd_end),
   .tlx_afu_cmd_pa(tlx_cmd_pa),
   .tlx_afu_cmd_flag(tlx_cmd_flag),
   .tlx_afu_cmd_os(tlx_cmd_os),
   .tlx_afu_cmd_capptag(tlx_cmd_capptag),
   .tlx_afu_cmd_pl(tlx_cmd_pl),
   .tlx_afu_cmd_be(tlx_cmd_be),
   // w
   .tlx_afu_cmd_data_valid(tlx_cdata_valid),
   .tlx_afu_cmd_data_bus(tlx_cdata_bus),
   .tlx_afu_cmd_data_bdi(tlx_cdata_bdi),
   // r/w
   .tlx_afu_resp_initial_credit(rsp_initial_credits),
   .tlx_afu_resp_credit(rsp_credit),
   .afu_tlx_resp_valid(rsp_valid),
   .afu_tlx_resp_opcode(rsp_opcode),
   .afu_tlx_resp_dl(rsp_dl),
   .afu_tlx_resp_capptag(rsp_afutag),
   .afu_tlx_resp_dp(rsp_dp),
   .afu_tlx_resp_code(rsp_code),
   // rd
   .afu_tlx_rdata_valid(rdata_valid),
   .afu_tlx_rdata_bus(rdata_bus),
   .afu_tlx_rdata_bdi(rdata_bdi),

   .afu_tlx_cmd_rd_req(tlx_cmd_rd_req), //dont know what this junk is (yet :)
   .afu_tlx_cmd_rd_cnt(tlx_cmd_rd_cnt),

   .cfg_tlx_initial_credit(`CFG_CMD_INITIAL_CREDITS),  // tl wants this > 0
   .cfg_tlx_credit_return(cfg_tlx_credit_return),
   .tlx_cfg_valid(tlx_cfg_valid),
   .tlx_cfg_opcode(tlx_cfg_opcode),
   .tlx_cfg_pa(tlx_cfg_pa),
   .tlx_cfg_t(tlx_cfg_t),
   .tlx_cfg_pl(tlx_cfg_pl),
   .tlx_cfg_capptag(tlx_cfg_capptag),
   .tlx_cfg_data_bus(tlx_cfg_data_bus),
   .tlx_cfg_data_bdi(tlx_cfg_data_bdi),
   .afu_tlx_resp_initial_credit(afu_tlx_resp_initial_credit),
   .afu_tlx_resp_credit(afu_tlx_resp_credit),
   .tlx_afu_resp_valid(tlx_afu_resp_valid),
   .tlx_afu_resp_opcode(tlx_afu_resp_opcode),
   .tlx_afu_resp_afutag(tlx_afu_resp_afutag),
   .tlx_afu_resp_code(tlx_afu_resp_code),
   .tlx_afu_resp_pg_size(tlx_afu_resp_pg_size),
   .tlx_afu_resp_dl(tlx_afu_resp_dl),
   .tlx_afu_resp_dp(tlx_afu_resp_dp),
   .tlx_afu_resp_host_tag(tlx_afu_resp_host_tag),
   .tlx_afu_resp_cache_state(tlx_afu_resp_cache_state),
   .tlx_afu_resp_addr_tag(tlx_afu_resp_addr_tag),
   .afu_tlx_resp_rd_req(afu_tlx_resp_rd_req),
   .afu_tlx_resp_rd_cnt(afu_tlx_resp_rd_cnt),
   .tlx_afu_resp_data_initial_credit(tlx_afu_resp_data_initial_credit),
   .tlx_afu_resp_data_credit(tlx_afu_resp_data_credit),
   .tlx_afu_resp_data_valid(tlx_afu_resp_data_valid),
   .tlx_afu_resp_data_bus(tlx_afu_resp_data_bus),
   .tlx_afu_resp_data_bdi(tlx_afu_resp_data_bdi),
   .tlx_afu_cmd_initial_credit(tlx_afu_cmd_initial_credit),
   .tlx_afu_cmd_credit(tlx_afu_cmd_credit),
   .afu_tlx_cmd_valid(afu_tlx_cmd_valid),
   .afu_tlx_cmd_opcode(afu_tlx_cmd_opcode),
   .afu_tlx_cmd_pa_or_obj(afu_tlx_cmd_pa_or_obj),
   .afu_tlx_cmd_afutag(afu_tlx_cmd_afutag),
   .afu_tlx_cmd_dl(afu_tlx_cmd_dl),
   .afu_tlx_cmd_pl(afu_tlx_cmd_pl),
   .afu_tlx_cmd_be(afu_tlx_cmd_be),
   .afu_tlx_cmd_flag(afu_tlx_cmd_flag),
   .afu_tlx_cmd_bdf(afu_tlx_cmd_bdf),
   .afu_tlx_cmd_resp_code(afu_tlx_cmd_resp_code),
   .afu_tlx_cmd_capptag(afu_tlx_cmd_capptag),
   .tlx_afu_cmd_data_initial_credit(tlx_afu_cmd_data_initial_credit),
   .tlx_afu_cmd_data_credit(tlx_afu_cmd_data_credit),
   .afu_tlx_cdata_valid(afu_tlx_cdata_valid),
   .afu_tlx_cdata_bus(afu_tlx_cdata_bus),
   .afu_tlx_cdata_bdi(afu_tlx_cdata_bdi),
   .cfg_tlx_resp_valid(cfg_tlx_resp_valid),
   .cfg_tlx_resp_opcode(cfg_tlx_resp_opcode),
   .cfg_tlx_resp_capptag(cfg_tlx_resp_capptag),
   .cfg_tlx_resp_code(cfg_tlx_resp_code),
   .tlx_cfg_resp_ack(tlx_cfg_resp_ack),
   .cfg_tlx_rdata_offset(cfg_tlx_rdata_offset),
   .cfg_tlx_rdata_bus(cfg_tlx_rdata_bus),
   .cfg_tlx_rdata_bdi(cfg_tlx_rdata_bdi),
   .dlx_tlx_flit_valid(dlx_tlx_flit_valid),
   .dlx_tlx_flit(dlx_tlx_flit),
   .dlx_tlx_flit_crc_err(dlx_tlx_flit_crc_err),
   .dlx_tlx_link_up(dlx_tlx_link_up),
   .dlx_tlx_flit_credit(dlx_tlx_flit_credit),
   .dlx_tlx_init_flit_depth(dlx_tlx_init_flit_depth),
   .tlx_dlx_flit_valid(tlx_dlx_flit_valid),
   .tlx_dlx_flit(tlx_dlx_flit),
   .tlx_dlx_debug_encode(tlx_dlx_debug_encode),
   .tlx_dlx_debug_info(tlx_dlx_debug_info),
   .dlx_tlx_dlx_config_info(dlx_config_info),
   .cfg_tlx_xmit_tmpl_config_0(cfg_tlx_xmit_tmpl_config_0),
   .cfg_tlx_xmit_tmpl_config_1(cfg_tlx_xmit_tmpl_config_1),
   .cfg_tlx_xmit_tmpl_config_2(cfg_tlx_xmit_tmpl_config_2),
   .cfg_tlx_xmit_tmpl_config_3(cfg_tlx_xmit_tmpl_config_3),
   .cfg_tlx_xmit_rate_config_0(cfg_tlx_xmit_rate_config_0),
   .cfg_tlx_xmit_rate_config_1(cfg_tlx_xmit_rate_config_1),
   .cfg_tlx_xmit_rate_config_2(cfg_tlx_xmit_rate_config_2),
   .cfg_tlx_xmit_rate_config_3(cfg_tlx_xmit_rate_config_3),
   .tlx_cfg_in_rcv_tmpl_capability_0(tlx_cfg_in_rcv_tmpl_capability_0),
   .tlx_cfg_in_rcv_tmpl_capability_1(tlx_cfg_in_rcv_tmpl_capability_1),
   .tlx_cfg_in_rcv_tmpl_capability_2(tlx_cfg_in_rcv_tmpl_capability_2),
   .tlx_cfg_in_rcv_tmpl_capability_3(tlx_cfg_in_rcv_tmpl_capability_3),
   .tlx_cfg_in_rcv_rate_capability_0(tlx_cfg_in_rcv_rate_capability_0),
   .tlx_cfg_in_rcv_rate_capability_1(tlx_cfg_in_rcv_rate_capability_1),
   .tlx_cfg_in_rcv_rate_capability_2(tlx_cfg_in_rcv_rate_capability_2),
   .tlx_cfg_in_rcv_rate_capability_3(tlx_cfg_in_rcv_rate_capability_3),
   .tlx_cfg_oc3_tlx_version(tlx_cfg_oc3_tlx_version)
);

ocx_dlx_top #(.GEMINI_NOT_APOLLO(1)) dl
(
   .dlx_tlx_flit_valid(dlx_tlx_flit_valid),
   .dlx_tlx_flit(dlx_tlx_flit),
   .dlx_tlx_flit_crc_err(dlx_tlx_flit_crc_err),
   .dlx_tlx_link_up(dlx_tlx_link_up),
   .dlx_config_info(dlx_config_info),
   .dlx_tlx_init_flit_depth(dlx_tlx_init_flit_depth),
   .dlx_tlx_flit_credit(dlx_tlx_flit_credit),
   .tlx_dlx_flit_valid(tlx_dlx_flit_valid),
   .tlx_dlx_flit(tlx_dlx_flit),
   .tlx_dlx_debug_encode(tlx_dlx_debug_encode),
   .tlx_dlx_debug_info(tlx_dlx_debug_info),
   .ro_dlx_version(ro_dlx_version),
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
   .opt_gckn(opt_gckn),
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
   .dlx_reset(dlx_reset),

   // wtf generic i/o for various possible real/virt phy's
   //.phy_id(phy_in),
   //.phy_in(phy_in),
   //.phy_out(phy_out)
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
   .send_first(send_first),
   .gtwiz_reset_rx_datapath_out(gtwiz_reset_rx_datapath_out),   // --  > output
   .tsm_state2_to_3(tsm_state2_to_3),
   .tsm_state4_to_5(tsm_state4_to_5),
   .tsm_state6_to_1(tsm_state6_to_1)
);


//Generated...
//vtable cmdseq
assign cmdseq_d[2] =
  (cmdseq_q[2] & cmdseq_q[1] & cmdseq_q[0] & ~tlx_ready) +
  (~cmdseq_q[2] & ~cmdseq_q[1] & cmdseq_q[0] & tlx_wr & ~tlx_cdata_valid) +
  (~cmdseq_q[2] & ~cmdseq_q[1] & cmdseq_q[0] & ~tlx_wr & tlx_cdata_valid) +
  (~cmdseq_q[2] & ~cmdseq_q[1] & cmdseq_q[0] & tlx_wr & tlx_cdata_valid) +
  (cmdseq_q[2] & ~cmdseq_q[1] & ~cmdseq_q[0] & ~tlx_cdata_valid) +
  (cmdseq_q[2] & ~cmdseq_q[1] & ~cmdseq_q[0] & tlx_cdata_valid) +
  (cmdseq_q[2] & ~cmdseq_q[1] & cmdseq_q[0] & ~tlx_wr) +
  (cmdseq_q[2] & ~cmdseq_q[1] & cmdseq_q[0] & tlx_wr) +
  (cmdseq_q[2] & cmdseq_q[1] & ~cmdseq_q[0] & ~rsp_tkn);
assign cmdseq_d[1] =
  (cmdseq_q[2] & cmdseq_q[1] & cmdseq_q[0] & ~tlx_ready) +
  (~cmdseq_q[2] & ~cmdseq_q[1] & cmdseq_q[0] & tlx_rd) +
  (~cmdseq_q[2] & ~cmdseq_q[1] & cmdseq_q[0] & tlx_wr & tlx_cdata_valid) +
  (~cmdseq_q[2] & cmdseq_q[1] & ~cmdseq_q[0] & ~rsp_tkn) +
  (cmdseq_q[2] & ~cmdseq_q[1] & cmdseq_q[0] & tlx_wr) +
  (cmdseq_q[2] & cmdseq_q[1] & ~cmdseq_q[0] & ~rsp_tkn);
assign cmdseq_d[0] =
  (cmdseq_q[2] & cmdseq_q[1] & cmdseq_q[0] & ~tlx_ready) +
  (cmdseq_q[2] & cmdseq_q[1] & cmdseq_q[0] & tlx_ready) +
  (~cmdseq_q[2] & ~cmdseq_q[1] & cmdseq_q[0] & ~tlx_rd & ~tlx_wr & ~tlx_cdata_valid) +
  (~cmdseq_q[2] & ~cmdseq_q[1] & cmdseq_q[0] & ~tlx_wr & tlx_cdata_valid) +
  (~cmdseq_q[2] & cmdseq_q[1] & ~cmdseq_q[0] & rsp_tkn) +
  (cmdseq_q[2] & ~cmdseq_q[1] & ~cmdseq_q[0] & tlx_cdata_valid) +
  (cmdseq_q[2] & ~cmdseq_q[1] & cmdseq_q[0] & ~tlx_wr) +
  (cmdseq_q[2] & cmdseq_q[1] & ~cmdseq_q[0] & rsp_tkn);
assign do_read =
  (~cmdseq_q[2] & cmdseq_q[1] & ~cmdseq_q[0] & ~rsp_tkn) +
  (~cmdseq_q[2] & cmdseq_q[1] & ~cmdseq_q[0] & rsp_tkn);
assign do_write =
  (cmdseq_q[2] & cmdseq_q[1] & ~cmdseq_q[0] & ~rsp_tkn) +
  (cmdseq_q[2] & cmdseq_q[1] & ~cmdseq_q[0] & rsp_tkn);
assign send_credit =
  (~cmdseq_q[2] & cmdseq_q[1] & ~cmdseq_q[0] & rsp_tkn) +
  (cmdseq_q[2] & cmdseq_q[1] & ~cmdseq_q[0] & rsp_tkn);
assign dev_error =
  (~cmdseq_q[2] & ~cmdseq_q[1] & ~cmdseq_q[0]);
//vtable cmdseq

endmodule
