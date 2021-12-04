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
// Wishbone 32b
// PHY
//   PHY lane usage handled by configuring DL (1/2/4/8)
//   PHY bits configured here (1/2/4/8/16/32/64 bits per lane per cycle)
//
// Transactions used:
//   pr_read_mem, 4B (32B with prefetch option)
//   > mem_rd_fail, mem_rd_response
//   pr_write_mem, 4B (with PABE extension to OC)
//   > mem_wr_fail, mem_wr_response
//  Plus:
//   nop
//   return_tl_credits (TL rsp)
//   return_tlx_credits (TLx rsp)
//
// Prefetch Option:
//   Convert all WB reads to 32B reads
//   Cache one line to service subsequent reads until write-hit or read-miss
//   TLx returns all data at once so no need to worry about critical-first

`timescale 1ns / 10ps

module wb_omi_host #(
        parameter PHY_BITS = 8
)
(
        input                       clk,
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
        //input                       opt_gckn,
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
        output  [31:0]               phy_out

    ) ;

// --------------------------------------------------------------------------------------------------------
// Wishbone Interface

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
// Handle credits normally, but there will never be multiple outstanding for any vc

// TLx Response
//
// omizer_rx creates wb response from tl response
// mem_rd_response, mem_wr_respone
// Without prefetch, no data storage here


// PHY Interface
//
// How to handle in an extendable way (usable by FPGA GPIO and GTP of various widths)?
// Assume it's a separate component built into SOC and configured to match wb_omi_host for a given platform
//
// should convert from 64b -> PHY_BITS here and then pass on to PHY component?


omi_host #() omi_host
(
   .clk(clk),
   .rst(rst),
   .tlx_afu_ready(tlx_afu_ready),
   .afu_tlx_cmd_initial_credit(afu_tlx_cmd_initial_credit),
   .afu_tlx_cmd_credit(afu_tlx_cmd_credit),
   .tlx_afu_cmd_valid(tlx_afu_cmd_valid),
   .tlx_afu_cmd_opcode(tlx_afu_cmd_opcode),
   .tlx_afu_cmd_dl(tlx_afu_cmd_dl),
   .tlx_afu_cmd_end(tlx_afu_cmd_end),
   .tlx_afu_cmd_pa(tlx_afu_cmd_pa),
   .tlx_afu_cmd_flag(tlx_afu_cmd_flag),
   .tlx_afu_cmd_os(tlx_afu_cmd_os),
   .tlx_afu_cmd_capptag(tlx_afu_cmd_capptag),
   .tlx_afu_cmd_pl(tlx_afu_cmd_pl),
   .tlx_afu_cmd_be(tlx_afu_cmd_be),
   .cfg_tlx_initial_credit(cfg_tlx_initial_credit),
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
   .afu_tlx_cmd_rd_req(afu_tlx_cmd_rd_req),
   .afu_tlx_cmd_rd_cnt(afu_tlx_cmd_rd_cnt),
   .tlx_afu_cmd_data_valid(tlx_afu_cmd_data_valid),
   .tlx_afu_cmd_data_bus(tlx_afu_cmd_data_bus),
   .tlx_afu_cmd_data_bdi(tlx_afu_cmd_data_bdi),
   .afu_tlx_resp_rd_req(afu_tlx_resp_rd_req),
   .afu_tlx_resp_rd_cnt(afu_tlx_resp_rd_cnt),
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
   .tlx_afu_resp_initial_credit(tlx_afu_resp_initial_credit),
   .tlx_afu_resp_credit(tlx_afu_resp_credit),
   .afu_tlx_resp_valid(afu_tlx_resp_valid),
   .afu_tlx_resp_opcode(afu_tlx_resp_opcode),
   .afu_tlx_resp_dl(afu_tlx_resp_dl),
   .afu_tlx_resp_capptag(afu_tlx_resp_capptag),
   .afu_tlx_resp_dp(afu_tlx_resp_dp),
   .afu_tlx_resp_code(afu_tlx_resp_code),
   .tlx_afu_resp_data_initial_credit(tlx_afu_resp_data_initial_credit),
   .tlx_afu_resp_data_credit(tlx_afu_resp_data_credit),
   .afu_tlx_rdata_valid(afu_tlx_rdata_valid),
   .afu_tlx_rdata_bus(afu_tlx_rdata_bus),
   .afu_tlx_rdata_bdi(afu_tlx_rdata_bdi),
   .cfg_tlx_resp_valid(cfg_tlx_resp_valid),
   .cfg_tlx_resp_opcode(cfg_tlx_resp_opcode),
   .cfg_tlx_resp_capptag(cfg_tlx_resp_capptag),
   .cfg_tlx_resp_code(cfg_tlx_resp_code),
   .tlx_cfg_resp_ack(tlx_cfg_resp_ack),
   .cfg_tlx_rdata_offset(cfg_tlx_rdata_offset),
   .cfg_tlx_rdata_bus(cfg_tlx_rdata_bus),
   .cfg_tlx_rdata_bdi(cfg_tlx_rdata_bdi),
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
   .tlx_cfg_oc3_tlx_version(tlx_cfg_oc3_tlx_version),
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
   .dlx_reset(dlx_reset)
   // wtf generic i/o for various possible real/virt phy's
   //.phy_id(phy_in),
   //.phy_in(phy_in),
   //.phy_out(phy_out)
);

endmodule
