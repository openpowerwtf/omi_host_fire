`timescale 1 ns / 1 ns

module top #(
   parameter PHY_BITS = 8
) (
   input                       clk,
   input                       rst,
   input                       wb_stb,
   input                       wb_cyc,
   input  [31:0]               wb_adr,
   input                       wb_we,
   input  [3:0]                wb_sel,
   input  [31:0]               wb_dat_i,
   output                      wb_ack,
   output [31:0]               wb_dat_o,
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
   output  [PHY_BITS-1:0]      ln0_tx_data,
   output  [PHY_BITS-1:0]      ln1_tx_data,
   output  [PHY_BITS-1:0]      ln2_tx_data,
   output  [PHY_BITS-1:0]      ln3_tx_data,
   output  [PHY_BITS-1:0]      ln4_tx_data,
   output  [PHY_BITS-1:0]      ln5_tx_data,
   output  [PHY_BITS-1:0]      ln6_tx_data,
   output  [PHY_BITS-1:0]      ln7_tx_data,
   output  [1:0]               ln0_tx_header,
   output  [1:0]               ln1_tx_header,
   output  [1:0]               ln2_tx_header,
   output  [1:0]               ln3_tx_header,
   output  [1:0]               ln4_tx_header,
   output  [1:0]               ln5_tx_header,
   output  [1:0]               ln6_tx_header,
   output  [1:0]               ln7_tx_header,
   output  [1:0]               ln0_tx_seq,
   output  [1:0]               ln1_tx_seq,
   output  [1:0]               ln2_tx_seq,
   output  [1:0]               ln3_tx_seq,
   output  [1:0]               ln4_tx_seq,
   output  [1:0]               ln5_tx_seq,
   output  [1:0]               ln6_tx_seq,
   output  [1:0]               ln7_tx_seq,
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
   input   [3:0]               phy_id,
   input   [31:0]              phy_in,
   output  [31:0]              phy_out,
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
      output tsm_state2_to_3,
      output tsm_state4_to_5,
      output tsm_state6_to_1
);

//wire phy_clk;
//wire [7:0] phy_tx_data /* verilator public */;
//wire [7:0] phy_rx_data /* verilator public */;

wb_omi_host #(.PHY_BITS(PHY_BITS)) host (
   .clk(clk),
   .rst(rst),
   .wb_stb(wb_stb),
   .wb_cyc(wb_cyc),
   .wb_adr(wb_adr),
   .wb_we(wb_we),
   .wb_sel(wb_sel),
   .wb_dat_i(wb_dat_i),
   .wb_ack(wb_ack),
   .wb_dat_o(wb_dat_o),
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
   .dlx_l0_tx_data(ln0_tx_data),
   .dlx_l1_tx_data(ln1_tx_data),
   .dlx_l2_tx_data(ln2_tx_data),
   .dlx_l3_tx_data(ln3_tx_data),
   .dlx_l4_tx_data(ln4_tx_data),
   .dlx_l5_tx_data(ln5_tx_data),
   .dlx_l6_tx_data(ln6_tx_data),
   .dlx_l7_tx_data(ln7_tx_data),
   .dlx_l0_tx_header(ln0_tx_header),
   .dlx_l1_tx_header(ln1_tx_header),
   .dlx_l2_tx_header(ln2_tx_header),
   .dlx_l3_tx_header(ln3_tx_header),
   .dlx_l4_tx_header(ln4_tx_header),
   .dlx_l5_tx_header(ln5_tx_header),
   .dlx_l6_tx_header(ln6_tx_header),
   .dlx_l7_tx_header(ln7_tx_header),
   .dlx_l0_tx_seq(ln0_tx_seq),
   .dlx_l1_tx_seq(ln1_tx_seq),
   .dlx_l2_tx_seq(ln2_tx_seq),
   .dlx_l3_tx_seq(ln3_tx_seq),
   .dlx_l4_tx_seq(ln4_tx_seq),
   .dlx_l5_tx_seq(ln5_tx_seq),
   .dlx_l6_tx_seq(ln6_tx_seq),
   .dlx_l7_tx_seq(ln7_tx_seq),
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

// phy

// phy

// wb_omi_dev

endmodule