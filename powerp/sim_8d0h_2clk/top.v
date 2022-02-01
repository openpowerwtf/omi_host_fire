
/* NEED TO CHECK THIS!

                top.v:411:1: ... note: In file included from top.v
%Warning-UNOPTFLAT: src/omi_dev.v:219:25: Signal unoptimizable: Feedback to clock or circular logic: 'top.dev.rsp_valid'
                                        : ... In instance top.dev
  219 |    wire                 rsp_valid;


*/






// wb_omi_host <-> omi_phygpio <-> omi_phygpio <-> omi_dev

`timescale 1 ns / 1 ns

module top #(
   parameter PHY_BITS = 64,
   //parameter GPIO_RX_TX = 512, GPIO_HDR = 16     // phy = 1:1 OMI
   //parameter GPIO_RX_TX = 8, GPIO_HDR = 1        // phy = 64:1 OMI
   parameter GPIO_RX_TX = 8, GPIO_HDR = 0,         // phy = 66:1 OMI
   parameter OMI_CLK_RATIO = 66
) (
   input                       clk_wb,
   input                       clk_omi,
   input                       clk_phy,
   input                       rst_host,
   input                       rst_dev,
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
      output host_gtwiz_reset_rx_datapath_out,   // --  > output
      output dev_gtwiz_reset_rx_datapath_out,   // --  > output
   input ocde
);

//wtf if these are exposed they should be tied to csr bits (along with reset, config bits, etc.)
// 6_to_1 needs to be reset before the link trains!  or start it at 0 and set tsm=0 on reset;
wire host_tsm_state2_to_3 = 1;
wire host_tsm_state4_to_5 = 1;
//wire host_tsm_state6_to_1 = 1;
wire dev_tsm_state2_to_3 = 1;
wire dev_tsm_state4_to_5 = 1;
//wire dev_tsm_state6_to_1 = 1;

wire                    host_dlx_reset;
wire                    phy_host_tx_clk;
if (GPIO_HDR > 0)
   wire   [GPIO_HDR-1:0]   phy_host_tx_hdr;
else
   wire                    phy_host_tx_hdr; // unused

wire   [GPIO_RX_TX-1:0] phy_host_tx_dat;
wire          ln0_rx_valid;
wire          ln1_rx_valid;
wire          ln2_rx_valid;
wire          ln3_rx_valid;
wire          ln4_rx_valid;
wire          ln5_rx_valid;
wire          ln6_rx_valid;
wire          ln7_rx_valid;
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
wire          ln0_rx_slip;
wire          ln1_rx_slip;
wire          ln2_rx_slip;
wire          ln3_rx_slip;
wire          ln4_rx_slip;
wire          ln5_rx_slip;
wire          ln6_rx_slip;
wire          ln7_rx_slip;
wire   [1:0]  ln0_tx_header;
wire   [1:0]  ln1_tx_header;
wire   [1:0]  ln2_tx_header;
wire   [1:0]  ln3_tx_header;
wire   [1:0]  ln4_tx_header;
wire   [1:0]  ln5_tx_header;
wire   [1:0]  ln6_tx_header;
wire   [1:0]  ln7_tx_header;
wire   [1:0]  ln0_tx_hdr;
wire   [1:0]  ln1_tx_hdr;
wire   [1:0]  ln2_tx_hdr;
wire   [1:0]  ln3_tx_hdr;
wire   [1:0]  ln4_tx_hdr;
wire   [1:0]  ln5_tx_hdr;
wire   [1:0]  ln6_tx_hdr;
wire   [1:0]  ln7_tx_hdr;
wire   [63:0] ln0_tx_data;
wire   [63:0] ln1_tx_data;
wire   [63:0] ln2_tx_data;
wire   [63:0] ln3_tx_data;
wire   [63:0] ln4_tx_data;
wire   [63:0] ln5_tx_data;
wire   [63:0] ln6_tx_data;
wire   [63:0] ln7_tx_data;

wire                     dev_dlx_reset;
wire          dev_ln0_rx_valid;
wire          dev_ln1_rx_valid;
wire          dev_ln2_rx_valid;
wire          dev_ln3_rx_valid;
wire          dev_ln4_rx_valid;
wire          dev_ln5_rx_valid;
wire          dev_ln6_rx_valid;
wire          dev_ln7_rx_valid;
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
wire          dev_ln0_rx_slip;
wire          dev_ln1_rx_slip;
wire          dev_ln2_rx_slip;
wire          dev_ln3_rx_slip;
wire          dev_ln4_rx_slip;
wire          dev_ln5_rx_slip;
wire          dev_ln6_rx_slip;
wire          dev_ln7_rx_slip;
wire   [1:0]  dev_ln0_tx_header;
wire   [1:0]  dev_ln1_tx_header;
wire   [1:0]  dev_ln2_tx_header;
wire   [1:0]  dev_ln3_tx_header;
wire   [1:0]  dev_ln4_tx_header;
wire   [1:0]  dev_ln5_tx_header;
wire   [1:0]  dev_ln6_tx_header;
wire   [1:0]  dev_ln7_tx_header;
wire   [1:0]  dev_ln0_tx_hdr;
wire   [1:0]  dev_ln1_tx_hdr;
wire   [1:0]  dev_ln2_tx_hdr;
wire   [1:0]  dev_ln3_tx_hdr;
wire   [1:0]  dev_ln4_tx_hdr;
wire   [1:0]  dev_ln5_tx_hdr;
wire   [1:0]  dev_ln6_tx_hdr;
wire   [1:0]  dev_ln7_tx_hdr;
wire   [63:0] dev_ln0_tx_data;
wire   [63:0] dev_ln1_tx_data;
wire   [63:0] dev_ln2_tx_data;
wire   [63:0] dev_ln3_tx_data;
wire   [63:0] dev_ln4_tx_data;
wire   [63:0] dev_ln5_tx_data;
wire   [63:0] dev_ln6_tx_data;
wire   [63:0] dev_ln7_tx_data;
wire                    phy_dev_tx_clk;
wire   [GPIO_HDR-1:0]   phy_dev_tx_hdr;
wire   [GPIO_RX_TX-1:0] phy_dev_tx_dat;

wb_omi_host #(
   .PHY_BITS(PHY_BITS),
   .OMI_CLK_RATIO(OMI_CLK_RATIO)
) host (
   .clk(clk_wb),
   .clk_omi(clk_omi),
   .rst(rst_host),
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
   .dlx_l0_tx_seq(),
   .dlx_l1_tx_seq(),
   .dlx_l2_tx_seq(),
   .dlx_l3_tx_seq(),
   .dlx_l4_tx_seq(),
   .dlx_l5_tx_seq(),
   .dlx_l6_tx_seq(),
   .dlx_l7_tx_seq(),
   .dlx_reset(host_dlx_reset),
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
   .gtwiz_reset_rx_datapath_out(host_gtwiz_reset_rx_datapath_out),   // --  > output
   .tsm_state2_to_3(host_tsm_state2_to_3),
   .tsm_state4_to_5(host_tsm_state4_to_5),
   .tsm_state6_to_1(host_tsm_state6_to_1)
);

omi_phygpio #(
   .GPIO_RX_TX(GPIO_RX_TX),
   .GPIO_HDR(GPIO_HDR)
) host_phy (
   .clk(clk_phy),
   .clk_dl(clk_omi),
   .rst(rst_host),
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
   .ln0_tx_data(ln0_tx_data),
   .ln1_tx_data(ln1_tx_data),
   .ln2_tx_data(ln2_tx_data),
   .ln3_tx_data(ln3_tx_data),
   .ln4_tx_data(ln4_tx_data),
   .ln5_tx_data(ln5_tx_data),
   .ln6_tx_data(ln6_tx_data),
   .ln7_tx_data(ln7_tx_data),
   .ln0_tx_header(ln0_tx_header),
   .ln1_tx_header(ln1_tx_header),
   .ln2_tx_header(ln2_tx_header),
   .ln3_tx_header(ln3_tx_header),
   .ln4_tx_header(ln4_tx_header),
   .ln5_tx_header(ln5_tx_header),
   .ln6_tx_header(ln6_tx_header),
   .ln7_tx_header(ln7_tx_header),
   //.dlx_l0_tx_seq(ln0_tx_seq),
   //.dlx_l1_tx_seq(ln1_tx_seq),
   //.dlx_l2_tx_seq(ln2_tx_seq),
   //.dlx_l3_tx_seq(ln3_tx_seq),
   //.dlx_l4_tx_seq(ln4_tx_seq),
   //.dlx_l5_tx_seq(ln5_tx_seq),
   //.dlx_l6_tx_seq(ln6_tx_seq),
   //.dlx_l7_tx_seq(ln7_tx_seq),
   .dlx_reset(host_dlx_reset),
   .phy_init(host_gtwiz_reset_rx_datapath_out),
   .rx_clk(phy_dev_tx_clk),
   .rx_hdr(phy_dev_tx_hdr),
   .rx_dat(phy_dev_tx_dat),
   .tx_clk(phy_host_tx_clk),
   .tx_hdr(phy_host_tx_hdr),
   .tx_dat(phy_host_tx_dat)
);

omi_phygpio #(
   .GPIO_RX_TX(GPIO_RX_TX), .GPIO_HDR(GPIO_HDR)
) dev_phy (
   .clk(clk_phy),
   .clk_dl(clk_omi),
   .rst(rst_dev),
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
   .ln0_tx_data(dev_ln0_tx_data),
   .ln1_tx_data(dev_ln1_tx_data),
   .ln2_tx_data(dev_ln2_tx_data),
   .ln3_tx_data(dev_ln3_tx_data),
   .ln4_tx_data(dev_ln4_tx_data),
   .ln5_tx_data(dev_ln5_tx_data),
   .ln6_tx_data(dev_ln6_tx_data),
   .ln7_tx_data(dev_ln7_tx_data),
   .ln0_tx_header(dev_ln0_tx_header),
   .ln1_tx_header(dev_ln1_tx_header),
   .ln2_tx_header(dev_ln2_tx_header),
   .ln3_tx_header(dev_ln3_tx_header),
   .ln4_tx_header(dev_ln4_tx_header),
   .ln5_tx_header(dev_ln5_tx_header),
   .ln6_tx_header(dev_ln6_tx_header),
   .ln7_tx_header(dev_ln7_tx_header),
   //.dlx_l0_tx_seq(dev_ln0_tx_seq),
   //.dlx_l1_tx_seq(dev_ln1_tx_seq),
   //.dlx_l2_tx_seq(dev_ln2_tx_seq),
   //.dlx_l3_tx_seq(dev_ln3_tx_seq),
   //.dlx_l4_tx_seq(dev_ln4_tx_seq),
   //.dlx_l5_tx_seq(dev_ln5_tx_seq),
   //.dlx_l6_tx_seq(dev_ln6_tx_seq),
   //.dlx_l7_tx_seq(dev_ln7_tx_seq),
   .dlx_reset(dev_dlx_reset),
   .phy_init(dev_gtwiz_reset_rx_datapath_out),
   .rx_clk(phy_host_tx_clk),
   .rx_hdr(phy_host_tx_hdr),
   .rx_dat(phy_host_tx_dat),
   .tx_clk(phy_dev_tx_clk),
   .tx_hdr(phy_dev_tx_hdr),
   .tx_dat(phy_dev_tx_dat)
);

omi_dev #() dev (
   .clk(clk_omi),
   .opt_gckn(clk_omi),
   .rst(rst_dev),
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
   .dlx_l0_tx_seq(),
   .dlx_l1_tx_seq(),
   .dlx_l2_tx_seq(),
   .dlx_l3_tx_seq(),
   .dlx_l4_tx_seq(),
   .dlx_l5_tx_seq(),
   .dlx_l6_tx_seq(),
   .dlx_l7_tx_seq(),
   .ocde(ocde),
   .reg_04_val(),
   .reg_04_hwwe(),
   .reg_04_update(),
   .reg_05_hwwe(),
   .reg_05_update(),
   .reg_06_hwwe(),
   .reg_06_update(),
   .reg_07_hwwe(),
   .reg_07_update(),
   .dlx_reset(dev_dlx_reset),
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
   .gtwiz_reset_rx_datapath_out(dev_gtwiz_reset_rx_datapath_out),   // --  > output
   .tsm_state2_to_3(dev_tsm_state2_to_3),
   .tsm_state4_to_5(dev_tsm_state4_to_5),
   .tsm_state6_to_1(dev_tsm_state6_to_1)
);



endmodule