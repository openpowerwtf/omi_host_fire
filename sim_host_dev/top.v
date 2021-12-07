// wb_omi_host <-> omi_dev

`timescale 1 ns / 1 ns

module top #(
   parameter PHY_BITS = 64
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
   //wtf may need 2x dl stuff
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
   input host_tsm_state2_to_3,
   input host_tsm_state4_to_5,
   input host_tsm_state6_to_1,
   input dev_tsm_state2_to_3,
   input dev_tsm_state4_to_5,
   input dev_tsm_state6_to_1
);

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
   .tsm_state2_to_3(host_tsm_state2_to_3),
   .tsm_state4_to_5(host_tsm_state4_to_5),
   .tsm_state6_to_1(host_tsm_state6_to_1)
);

// phy
wire   [1:0]  ln0_rx_header;
wire   [1:0]  ln1_rx_header;
wire   [1:0]  ln2_rx_header;
wire   [1:0]  ln3_rx_header;
wire   [1:0]  ln4_rx_header;
wire   [1:0]  ln5_rx_header;
wire   [1:0]  ln6_rx_header;
wire   [1:0]  ln7_rx_header;
wire   [63:0] ln0_rx_data;
wire   [63:0] ln1_rx_data;
wire   [63:0] ln2_rx_data;
wire   [63:0] ln3_rx_data;
wire   [63:0] ln4_rx_data;
wire   [63:0] ln5_rx_data;
wire   [63:0] ln6_rx_data;
wire   [63:0] ln7_rx_data;
wire   [1:0]  ln0_tx_header;
wire   [1:0]  ln1_tx_header;
wire   [1:0]  ln2_tx_header;
wire   [1:0]  ln3_tx_header;
wire   [1:0]  ln4_tx_header;
wire   [1:0]  ln5_tx_header;
wire   [1:0]  ln6_tx_header;
wire   [1:0]  ln7_tx_header;
wire   [1:0]  ln0_tx_seq;
wire   [1:0]  ln1_tx_seq;
wire   [1:0]  ln2_tx_seq;
wire   [1:0]  ln3_tx_seq;
wire   [1:0]  ln4_tx_seq;
wire   [1:0]  ln5_tx_seq;
wire   [1:0]  ln6_tx_seq;
wire   [1:0]  ln7_tx_seq;
wire   [63:0] ln0_tx_data;
wire   [63:0] ln1_tx_data;
wire   [63:0] ln2_tx_data;
wire   [63:0] ln3_tx_data;
wire   [63:0] ln4_tx_data;
wire   [63:0] ln5_tx_data;
wire   [63:0] ln6_tx_data;
wire   [63:0] ln7_tx_data;


wire   [1:0]  dev_ln0_rx_header;
wire   [1:0]  dev_ln1_rx_header;
wire   [1:0]  dev_ln2_rx_header;
wire   [1:0]  dev_ln3_rx_header;
wire   [1:0]  dev_ln4_rx_header;
wire   [1:0]  dev_ln5_rx_header;
wire   [1:0]  dev_ln6_rx_header;
wire   [1:0]  dev_ln7_rx_header;
wire   [63:0] dev_ln0_rx_data;
wire   [63:0] dev_ln1_rx_data;
wire   [63:0] dev_ln2_rx_data;
wire   [63:0] dev_ln3_rx_data;
wire   [63:0] dev_ln4_rx_data;
wire   [63:0] dev_ln5_rx_data;
wire   [63:0] dev_ln6_rx_data;
wire   [63:0] dev_ln7_rx_data;
wire   [1:0]  dev_ln0_tx_header;
wire   [1:0]  dev_ln1_tx_header;
wire   [1:0]  dev_ln2_tx_header;
wire   [1:0]  dev_ln3_tx_header;
wire   [1:0]  dev_ln4_tx_header;
wire   [1:0]  dev_ln5_tx_header;
wire   [1:0]  dev_ln6_tx_header;
wire   [1:0]  dev_ln7_tx_header;
wire   [1:0]  dev_ln0_tx_seq;
wire   [1:0]  dev_ln1_tx_seq;
wire   [1:0]  dev_ln2_tx_seq;
wire   [1:0]  dev_ln3_tx_seq;
wire   [1:0]  dev_ln4_tx_seq;
wire   [1:0]  dev_ln5_tx_seq;
wire   [1:0]  dev_ln6_tx_seq;
wire   [1:0]  dev_ln7_tx_seq;
wire   [63:0] dev_ln0_tx_data;
wire   [63:0] dev_ln1_tx_data;
wire   [63:0] dev_ln2_tx_data;
wire   [63:0] dev_ln3_tx_data;
wire   [63:0] dev_ln4_tx_data;
wire   [63:0] dev_ln5_tx_data;
wire   [63:0] dev_ln6_tx_data;
wire   [63:0] dev_ln7_tx_data;

assign ln0_rx_valid = 1'b1;
assign ln0_rx_header = dev_ln0_tx_header;
assign ln0_rx_data = dev_ln0_tx_data;
assign ln0_rx_slip = 1'b0;
assign ln1_rx_valid = 1'b1;
assign ln1_rx_header = dev_ln1_tx_header;
assign ln1_rx_data = dev_ln1_tx_data;
assign ln1_rx_slip = 1'b0;
assign ln2_rx_valid = 1'b1;
assign ln2_rx_header = dev_ln2_tx_header;
assign ln2_rx_data = dev_ln2_tx_data;
assign ln2_rx_slip = 1'b0;
assign ln3_rx_valid = 1'b1;
assign ln3_rx_header = dev_ln3_tx_header;
assign ln3_rx_data = dev_ln3_tx_data;
assign ln3_rx_slip = 1'b0;
assign ln4_rx_valid = 1'b1;
assign ln4_rx_header = dev_ln4_tx_header;
assign ln4_rx_data = dev_ln4_tx_data;
assign ln4_rx_slip = 1'b0;
assign ln5_rx_valid = 1'b1;
assign ln5_rx_header = dev_ln5_tx_header;
assign ln5_rx_data = dev_ln5_tx_data;
assign ln5_rx_slip = 1'b0;
assign ln6_rx_valid = 1'b1;
assign ln6_rx_header = dev_ln6_tx_header;
assign ln6_rx_data = dev_ln6_tx_data;
assign ln6_rx_slip = 1'b0;
assign ln7_rx_valid = 1'b1;
assign ln7_rx_header = dev_ln7_tx_header;
assign ln7_rx_data = dev_ln7_tx_data;
assign ln7_rx_slip = 1'b0;

// phy

assign dev_ln0_rx_valid = 1'b1;
assign dev_ln0_rx_header = ln0_tx_header;
assign dev_ln0_rx_data = ln0_tx_data;
assign dev_ln0_rx_slip = 1'b0;
assign dev_ln1_rx_valid = 1'b1;
assign dev_ln1_rx_header = ln1_tx_header;
assign dev_ln1_rx_data = ln1_tx_data;
assign dev_ln1_rx_slip = 1'b0;
assign dev_ln2_rx_valid = 1'b1;
assign dev_ln2_rx_header = ln2_tx_header;
assign dev_ln2_rx_data = ln2_tx_data;
assign dev_ln2_rx_slip = 1'b0;
assign dev_ln3_rx_valid = 1'b1;
assign dev_ln3_rx_header = ln3_tx_header;
assign dev_ln3_rx_data = ln3_tx_data;
assign dev_ln3_rx_slip = 1'b0;
assign dev_ln4_rx_valid = 1'b1;
assign dev_ln4_rx_header = ln4_tx_header;
assign dev_ln4_rx_data = ln4_tx_data;
assign dev_ln4_rx_slip = 1'b0;
assign dev_ln5_rx_valid = 1'b1;
assign dev_ln5_rx_header = ln5_tx_header;
assign dev_ln5_rx_data = ln5_tx_data;
assign dev_ln5_rx_slip = 1'b0;
assign dev_ln6_rx_valid = 1'b1;
assign dev_ln6_rx_header = ln6_tx_header;
assign dev_ln6_rx_data = ln6_tx_data;
assign dev_ln6_rx_slip = 1'b0;
assign dev_ln7_rx_valid = 1'b1;
assign dev_ln7_rx_header = ln7_tx_header;
assign dev_ln7_rx_data = ln7_tx_data;
assign dev_ln7_rx_slip = 1'b0;


omi_dev #() dev (
   .clk(clk),
   .rst(rst),
   .ln0_rx_valid(dev_ln0_rx_valid),
   .ln0_rx_header(dev_ln0_rx_header),
   .ln0_rx_data(dev_ln0_rx_data),
   .ln0_rx_slip(dev_ln0_rx_slip),
   .ln1_rx_valid(dev_ln1_rx_valid),
   .ln1_rx_header(dev_ln1_rx_header),
   .ln1_rx_data(dev_ln1_rx_data),
   .ln1_rx_slip(dev_ln1_rx_slip),
   .ln2_rx_valid(dev_ln2_rx_valid),
   .ln2_rx_header(dev_ln2_rx_header),
   .ln2_rx_data(dev_ln2_rx_data),
   .ln2_rx_slip(dev_ln2_rx_slip),
   .ln3_rx_valid(dev_ln3_rx_valid),
   .ln3_rx_header(dev_ln3_rx_header),
   .ln3_rx_data(dev_ln3_rx_data),
   .ln3_rx_slip(dev_ln3_rx_slip),
   .ln4_rx_valid(dev_ln4_rx_valid),
   .ln4_rx_header(dev_ln4_rx_header),
   .ln4_rx_data(dev_ln4_rx_data),
   .ln4_rx_slip(dev_ln4_rx_slip),
   .ln5_rx_valid(dev_ln5_rx_valid),
   .ln5_rx_header(dev_ln5_rx_header),
   .ln5_rx_data(dev_ln5_rx_data),
   .ln5_rx_slip(dev_ln5_rx_slip),
   .ln6_rx_valid(dev_ln6_rx_valid),
   .ln6_rx_header(dev_ln6_rx_header),
   .ln6_rx_data(dev_ln6_rx_data),
   .ln6_rx_slip(dev_ln6_rx_slip),
   .ln7_rx_valid(dev_ln7_rx_valid),
   .ln7_rx_header(dev_ln7_rx_header),
   .ln7_rx_data(dev_ln7_rx_data),
   .ln7_rx_slip(dev_ln7_rx_slip),
   .dlx_l0_tx_data(dev_ln0_tx_data),
   .dlx_l1_tx_data(dev_ln1_tx_data),
   .dlx_l2_tx_data(dev_ln2_tx_data),
   .dlx_l3_tx_data(dev_ln3_tx_data),
   .dlx_l4_tx_data(dev_ln4_tx_data),
   .dlx_l5_tx_data(dev_ln5_tx_data),
   .dlx_l6_tx_data(dev_ln6_tx_data),
   .dlx_l7_tx_data(dev_ln7_tx_data),
   .dlx_l0_tx_header(dev_ln0_tx_header),
   .dlx_l1_tx_header(dev_ln1_tx_header),
   .dlx_l2_tx_header(dev_ln2_tx_header),
   .dlx_l3_tx_header(dev_ln3_tx_header),
   .dlx_l4_tx_header(dev_ln4_tx_header),
   .dlx_l5_tx_header(dev_ln5_tx_header),
   .dlx_l6_tx_header(dev_ln6_tx_header),
   .dlx_l7_tx_header(dev_ln7_tx_header),
   .dlx_l0_tx_seq(dev_ln0_tx_seq),
   .dlx_l1_tx_seq(dev_ln1_tx_seq),
   .dlx_l2_tx_seq(dev_ln2_tx_seq),
   .dlx_l3_tx_seq(dev_ln3_tx_seq),
   .dlx_l4_tx_seq(dev_ln4_tx_seq),
   .dlx_l5_tx_seq(dev_ln5_tx_seq),
   .dlx_l6_tx_seq(dev_ln6_tx_seq),
   .dlx_l7_tx_seq(ln7_tx_seq),
   .opt_gckn(~clk),
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
   .send_first(~send_first),
   .gtwiz_reset_rx_datapath_out(gtwiz_reset_rx_datapath_out),   // --  > output
   .tsm_state2_to_3(dev_tsm_state2_to_3),
   .tsm_state4_to_5(dev_tsm_state4_to_5),
   .tsm_state6_to_1(dev_tsm_state6_to_1)
);



endmodule