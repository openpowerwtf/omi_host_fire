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


`timescale 1ns / 10ps

module omi_host #()
(
        input                       clk,
        input                       rst,

        output                      tlx_afu_ready,
        input   [6:0]                    afu_tlx_cmd_initial_credit,
        input                       afu_tlx_cmd_credit,
        output                      tlx_afu_cmd_valid,
        output  [7:0]                    tlx_afu_cmd_opcode,
        output  [1:0]                    tlx_afu_cmd_dl                    ,
        output                      tlx_afu_cmd_end                   ,
        output  [63:0]                    tlx_afu_cmd_pa                    ,
        output  [3:0]                    tlx_afu_cmd_flag                  ,
        output                      tlx_afu_cmd_os                    ,
        output  [15:0]                    tlx_afu_cmd_capptag               ,
        output  [2:0]                    tlx_afu_cmd_pl                    ,
        output  [63:0]                    tlx_afu_cmd_be                    ,

        // Config Command interface to AFU
        input   [3:0]                    cfg_tlx_initial_credit            ,
        input                       cfg_tlx_credit_return             ,
        output                      tlx_cfg_valid                     ,
        output  [7:0]                    tlx_cfg_opcode                    ,
        output  [63:0]                    tlx_cfg_pa                        ,
        output                      tlx_cfg_t                         ,
        output  [2:0]                   tlx_cfg_pl                        ,
        output  [15:0]                    tlx_cfg_capptag                   ,
        output  [31:0]                    tlx_cfg_data_bus                  ,
        output                      tlx_cfg_data_bdi                  ,

        // Response interface to AFU
        input   [6:0]                    afu_tlx_resp_initial_credit       ,
        input                       afu_tlx_resp_credit               ,
        output                      tlx_afu_resp_valid                ,
        output  [7:0]                    tlx_afu_resp_opcode               ,
        output  [15:0]                    tlx_afu_resp_afutag               ,
        output  [3:0]                    tlx_afu_resp_code                 ,
        output  [5:0]                    tlx_afu_resp_pg_size              ,
        output  [1:0]                    tlx_afu_resp_dl                   ,
        output  [1:0]                    tlx_afu_resp_dp                   ,
        output  [23:0]                    tlx_afu_resp_host_tag             ,
        output  [3:0]                    tlx_afu_resp_cache_state          ,
        output  [17:0]                    tlx_afu_resp_addr_tag             ,

        // Command data interface to AFU
        input                       afu_tlx_cmd_rd_req                ,
        input   [2:0]                    afu_tlx_cmd_rd_cnt                ,
        output                      tlx_afu_cmd_data_valid            ,
        output  [511:0]                    tlx_afu_cmd_data_bus              ,
        output                      tlx_afu_cmd_data_bdi              ,

        // Response data interface to AFU
        input                       afu_tlx_resp_rd_req               ,
        input    [2:0]                   afu_tlx_resp_rd_cnt               ,
        output                      tlx_afu_resp_data_valid           ,
        output  [511:0]                    tlx_afu_resp_data_bus             ,
        output                      tlx_afu_resp_data_bdi             ,

        // -----------------------------------
        // AFU to TLX Framer Transmit Interface
        // -----------------------------------

        // --- Commands from AFU
        output  [3:0]                    tlx_afu_cmd_initial_credit        ,
        output                      tlx_afu_cmd_credit                ,
        input                       afu_tlx_cmd_valid                 ,
        input   [7:0]                     afu_tlx_cmd_opcode                ,
        input   [63:0]                    afu_tlx_cmd_pa_or_obj             ,
        input   [15:0]                    afu_tlx_cmd_afutag                ,
        input   [1:0]                    afu_tlx_cmd_dl                    ,
        input   [2:0]                    afu_tlx_cmd_pl                    ,
        input   [63:0]                    afu_tlx_cmd_be                    ,
        input   [3:0]                    afu_tlx_cmd_flag                  ,
        input   [15:0]                    afu_tlx_cmd_bdf                   ,
        input   [3:0]                    afu_tlx_cmd_resp_code             ,
        input   [15:0]                    afu_tlx_cmd_capptag               ,

        // --- Command data from AFU
        output  [5:0]                    tlx_afu_cmd_data_initial_credit   ,
        output                      tlx_afu_cmd_data_credit           ,
        input                       afu_tlx_cdata_valid               ,
        input   [511:0]                    afu_tlx_cdata_bus                 ,
        input                       afu_tlx_cdata_bdi                 ,

        // --- Responses from AFU
        output  [3:0]                    tlx_afu_resp_initial_credit       ,
        output                      tlx_afu_resp_credit               ,
        input                       afu_tlx_resp_valid                ,
        input   [7:0]                    afu_tlx_resp_opcode               ,
        input   [1:0]                    afu_tlx_resp_dl                   ,
        input   [15:0]                    afu_tlx_resp_capptag              ,
        input   [1:0]                    afu_tlx_resp_dp                   ,
        input   [3:0]                    afu_tlx_resp_code                 ,

        // --- Response data from AFU
        output  [5:0]                   tlx_afu_resp_data_initial_credit  ,
        output                      tlx_afu_resp_data_credit          ,
        input                       afu_tlx_rdata_valid               ,
        input   [511:0]                    afu_tlx_rdata_bus                 ,
        input                       afu_tlx_rdata_bdi                 ,

        // --- Config Responses from AFU
        input                       cfg_tlx_resp_valid                ,
        input   [7:0]                    cfg_tlx_resp_opcode               ,
        input   [15:0]                    cfg_tlx_resp_capptag              ,
        input   [3:0]                    cfg_tlx_resp_code                 ,
        output                      tlx_cfg_resp_ack                  ,

        // --- Config Response data from AFU
        input   [3:0]                    cfg_tlx_rdata_offset              ,
        input   [31:0]                    cfg_tlx_rdata_bus                 ,
        input                       cfg_tlx_rdata_bdi                 ,

        // -----------------------------------
        // Configuration Ports
        // -----------------------------------
        input                       cfg_tlx_xmit_tmpl_config_0        ,
        input                       cfg_tlx_xmit_tmpl_config_1        ,
        input                       cfg_tlx_xmit_tmpl_config_2        ,
        input                       cfg_tlx_xmit_tmpl_config_3        ,
        input   [3:0]                    cfg_tlx_xmit_rate_config_0        ,
        input   [3:0]                    cfg_tlx_xmit_rate_config_1        ,
        input   [3:0]                    cfg_tlx_xmit_rate_config_2        ,
        input   [3:0]                    cfg_tlx_xmit_rate_config_3        ,

        output                      tlx_cfg_in_rcv_tmpl_capability_0  ,
        output                      tlx_cfg_in_rcv_tmpl_capability_1  ,
        output                      tlx_cfg_in_rcv_tmpl_capability_2  ,
        output                      tlx_cfg_in_rcv_tmpl_capability_3  ,
        output  [3:0]                    tlx_cfg_in_rcv_rate_capability_0  ,
        output  [3:0]                    tlx_cfg_in_rcv_rate_capability_1  ,
        output  [3:0]                    tlx_cfg_in_rcv_rate_capability_2  ,
        output  [3:0]                    tlx_cfg_in_rcv_rate_capability_3  ,

        output  [31:0]                    tlx_cfg_oc3_tlx_version,

        output  [31:0]                    ro_dlx_version,                // --  > output [31:0]
        input                       ln0_rx_valid,               // --  < input
        input   [1:0]                    ln0_rx_header,              // --  < input  [1:0]
        input   [63:0]                    ln0_rx_data,             // --  < input  [63:0]
        output                      ln0_rx_slip,            // --  < output
        input                       ln1_rx_valid,           // --  < input
        input   [1:0]                    ln1_rx_header,          // --  < input  [1:0]
        input   [63:0]                    ln1_rx_data,         // --  < input  [63:0]
        output                      ln1_rx_slip,        // --  < output
        input                       ln2_rx_valid,       // --  < input
        input   [1:0]                    ln2_rx_header,      // --  < input  [1:0]
        input   [63:0]                    ln2_rx_data,     // --  < input  [63:0]
        output                      ln2_rx_slip,    // --  < output
        input                       ln3_rx_valid,   // --  < input
        input   [1:0]                    ln3_rx_header,  // --  < input  [1:0]
        input   [63:0]                    ln3_rx_data,                   // --  < input  [63:0]
        output                      ln3_rx_slip,                  // --  < output
        input                       ln4_rx_valid,                 // --  < input
        input   [1:0]                    ln4_rx_header,                // --  < input  [1:0]
        input   [63:0]                    ln4_rx_data,               // --  < input  [63:0]
        output                      ln4_rx_slip,              // --  < output
        input                       ln5_rx_valid,             // --  < input
        input   [1:0]                    ln5_rx_header,            // --  < input  [1:0]
        input   [63:0]                    ln5_rx_data,           // --  < input  [63:0]
        output                      ln5_rx_slip,          // --  < output
        input                       ln6_rx_valid,         // --  < input
        input   [1:0]                    ln6_rx_header,        // --  < input  [1:0]
        input   [63:0]                    ln6_rx_data,       // --  < input  [63:0]
        output                      ln6_rx_slip,      // --  < output
        input                       ln7_rx_valid,     // --  < input
        input   [1:0]                    ln7_rx_header,    // --  < input  [1:0]
        input   [63:0]                    ln7_rx_data,   // --  < input  [63:0]
        output                      ln7_rx_slip,  // --  < output
        output  [63:0]                    dlx_l0_tx_data,                // --  > output [63:0]
        output  [63:0]                    dlx_l1_tx_data,                // --  > output [63:0]
        output  [63:0]                    dlx_l2_tx_data,                // --  > output [63:0]
        output  [63:0]                    dlx_l3_tx_data,                // --  > output [63:0]
        output  [63:0]                    dlx_l4_tx_data,                // --  > output [63:0]
        output  [63:0]                    dlx_l5_tx_data,                // --  > output [63:0]
        output  [63:0]                    dlx_l6_tx_data,                // --  > output [63:0]
        output  [63:0]                    dlx_l7_tx_data,                // --  > output [63:0]
        output  [1:0]                    dlx_l0_tx_header,              // --  > output [1:0]
        output  [1:0]                    dlx_l1_tx_header,              // --  > output [1:0]
        output  [1:0]                    dlx_l2_tx_header,              // --  > output [1:0]
        output  [1:0]                    dlx_l3_tx_header,              // --  > output [1:0]
        output  [1:0]                    dlx_l4_tx_header,              // --  > output [1:0]
        output  [1:0]                    dlx_l5_tx_header,              // --  > output [1:0]
        output  [1:0]                    dlx_l6_tx_header,              // --  > output [1:0]
        output  [1:0]                    dlx_l7_tx_header,              // --  > output [1:0]
        output  [1:0]                    dlx_l0_tx_seq,                 // --  > output [5:0]
        output  [1:0]                    dlx_l1_tx_seq,                 // --  > output [5:0]
        output  [1:0]                    dlx_l2_tx_seq,                 // --  > output [5:0]
        output  [1:0]                    dlx_l3_tx_seq,                 // --  > output [5:0]
        output  [1:0]                    dlx_l4_tx_seq,                 // --  > output [5:0]
        output  [1:0]                    dlx_l5_tx_seq,                 // --  > output [5:0]
        output  [1:0]                    dlx_l6_tx_seq,                 // --  > output [5:0]
        output  [1:0]                    dlx_l7_tx_seq,                 // --  > output [5:0]

        input                       opt_gckn,
        input                       ocde,
        input                       reg_04_val,
        output                      reg_04_hwwe,                      // -- output
        output  [31:0]                    reg_04_update,                    // -- output [31:0]
        output                      reg_05_hwwe,                   // -- output
        output  [31:0]                    reg_05_update,                 // -- output [31:0]
        output                      reg_06_hwwe,                   // -- output
        output  [31:0]                    reg_06_update,                 // -- output [31:0]
        output                      reg_07_hwwe,                   // -- output
        output  [31:0]                    reg_07_update,                 // -- output [31:0]
        output                      dlx_reset,                     // -- output

        // wtf generic i/o for various possible real/virt phy's
        input   [3:0]                phy_id,
        input   [31:0]               phy_in,
        output  [31:0]               phy_out

    ) ;


wire   [511:0]    dlx_tlx_flit;
wire   [511:0]    tlx_dlx_flit;
wire              tlx_dlx_flit_valid;
wire   [3:0]      tlx_dlx_debug_encode;
wire   [31:0]     tlx_dlx_debug_info;
wire              dlx_tlx_flit_valid;
wire              dlx_tlx_flit_crc_err;
wire              dlx_tlx_link_up;
wire              dlx_tlx_flit_credit;
wire   [2:0]      dlx_tlx_init_flit_depth;
wire   [31:0]     dlx_tlx_dlx_config_info;
wire   [31:0]     dlx_config_info;

ocx_tlx_top #() tl
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
   .dlx_tlx_dlx_config_info(dlx_tlx_dlx_config_info),
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

ocx_dlx_top #() dl
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
   .dlx_reset(dlx_reset)

   // wtf generic i/o for various possible real/virt phy's
   //.phy_id(phy_in),
   //.phy_in(phy_in),
   //.phy_out(phy_out)
);

endmodule
