// lfsr doesnt work?
// add 'done' output for dl related to phy_init

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

// OMI GPIO PHY
// Convert 8 DL lanes x n bits to GPIO rx/tx lanes
// DL sends/rcvs 66b flits (except during training, but then it shifts the bits across hdr/data to delete the hdr)
//
// 1. phy runs fast enough to handle hdr+data on rx/tx i/o
//      only makes sense for super-low pincounts
// 2. phy adds dedicated i/o to deliver hdr info (just needs enough i/o to deliver all hdr's in total data cycs)
//       GPIO_RX_TX   Hdr Rx/Tx  DL Cycles
//          1             1        512
//          2             1        256
//          4             1        128
//          8             1         64
//         16             1         32
//         32             1         16
//         64             2          8
//        128             4          4
//        256             8          2
//        512            16          1

// just putting all the bits on the data lines may make more sense; only 66 vs 64 cycles (for 8 data) and
//  don't have to worry about splitting hdr from data



//wtf
// there probably needs to be a 'sample' indicator to qualify when rx sigs should be grabbed - use clk_dl
// what is the bit granularity of slip?
// figured out had to reset slip when going to scrambled; guess it never happens after training?
// either use a sync line (indicates every xfer 0 of n), or actually need to do a 'phy init' when dlx says so
//  to get tx->rx locked (rx knows when cyc 0 of n is arriving); or, does it work if phy_init does nothing here
//  and the slip count is retained?  seems so

// would this ever need different slip counters for each lane?
// believe a sync line is needed for data+header modes.  or are the header bits always ok if they
//  are continuously transmitted (repeat over all data cycles)

// xil ug471 (v1.10), bitslip submodule
// reorders the sequence of parallel data going into fpga fabric
// p 159: bitslip is NOT a barrel shift, though it looks like one in repeating pattern; it adds one bit to the input
//        data stream and loses the nth bit
// so i think this means you need to have extra bits; you are doing a true align
// but i could also avoid this by using a start bit; then i automatically align tx->rx regardless of reset timing, etc.

`timescale 1ns / 10ps

module omi_phygpio #(
        parameter GPIO_RX_TX = 512, parameter GPIO_HDR = 16,
        //parameter GPIO_RX_TX = 8,  parameter GPIO_HDR = 1,
        parameter GPIO_SYNC = 1,
        parameter DL_BITS = 64,
        parameter SLIP_BITS = 66
)
(
        input                             clk,
        input                             clk_dl,
        input                             rst,

        output                            ln0_rx_valid,
        output  [1:0]                     ln0_rx_header,
        output  [DL_BITS-1:0]             ln0_rx_data,
        input                             ln0_rx_slip,
        output                            ln1_rx_valid,
        output  [1:0]                     ln1_rx_header,
        output  [DL_BITS-1:0]             ln1_rx_data,
        input                             ln1_rx_slip,
        output                            ln2_rx_valid,
        output  [1:0]                     ln2_rx_header,
        output  [DL_BITS-1:0]             ln2_rx_data,
        input                             ln2_rx_slip,
        output                            ln3_rx_valid,
        output  [1:0]                     ln3_rx_header,
        output  [DL_BITS-1:0]             ln3_rx_data,
        input                             ln3_rx_slip,
        output                            ln4_rx_valid,
        output  [1:0]                     ln4_rx_header,
        output  [DL_BITS-1:0]             ln4_rx_data,
        input                             ln4_rx_slip,
        output                            ln5_rx_valid,
        output  [1:0]                     ln5_rx_header,
        output  [DL_BITS-1:0]             ln5_rx_data,
        input                             ln5_rx_slip,
        output                            ln6_rx_valid,
        output  [1:0]                     ln6_rx_header,
        output  [DL_BITS-1:0]             ln6_rx_data,
        input                             ln6_rx_slip,
        output                            ln7_rx_valid,
        output  [1:0]                     ln7_rx_header,
        output  [DL_BITS-1:0]             ln7_rx_data,
        input                             ln7_rx_slip,
        input   [1:0]                     ln0_tx_header,
        input   [DL_BITS-1:0]             ln0_tx_data,
        input   [1:0]                     ln1_tx_header,
        input   [DL_BITS-1:0]             ln1_tx_data,
        input   [1:0]                     ln2_tx_header,
        input   [DL_BITS-1:0]             ln2_tx_data,
        input   [1:0]                     ln3_tx_header,
        input   [DL_BITS-1:0]             ln3_tx_data,
        input   [1:0]                     ln4_tx_header,
        input   [DL_BITS-1:0]             ln4_tx_data,
        input   [1:0]                     ln5_tx_header,
        input   [DL_BITS-1:0]             ln5_tx_data,
        input   [1:0]                     ln6_tx_header,
        input   [DL_BITS-1:0]             ln6_tx_data,
        input   [1:0]                     ln7_tx_header,
        input   [DL_BITS-1:0]             ln7_tx_data,
        //input   [1:0]                     dlx_l0_tx_seq,
        //input   [1:0]                     dlx_l1_tx_seq,
        //input   [1:0]                     dlx_l2_tx_seq,
        //input   [1:0]                     dlx_l3_tx_seq,
        //input   [1:0]                     dlx_l4_tx_seq,
        //input   [1:0]                     dlx_l5_tx_seq,
        //input   [1:0]                     dlx_l6_tx_seq,
        //input   [1:0]                     dlx_l7_tx_seq,

        input                             dlx_reset,  // need this to start clock count properly, or a valid to detect transition, or a clk
        input                             phy_init,   // dl is transitioning to scrambled data
        input                             rx_clk,
        input   [GPIO_HDR-1:0]            rx_hdr,
        input   [GPIO_RX_TX-1:0]          rx_dat,
        output                            tx_clk,
        output  [GPIO_HDR-1:0]            tx_hdr,
        output  [GPIO_RX_TX-1:0]          tx_dat

    ) ;

   // data + hdr + maximum slip allowance
   reg    [DL_BITS+1+SLIP_BITS:0]    rx_ln0_q;
   wire   [DL_BITS+1+SLIP_BITS:0]    rx_ln0_d;
   reg    [DL_BITS+1+SLIP_BITS:0]    rx_ln1_q;
   wire   [DL_BITS+1+SLIP_BITS:0]    rx_ln1_d;
   reg    [DL_BITS+1+SLIP_BITS:0]    rx_ln2_q;
   wire   [DL_BITS+1+SLIP_BITS:0]    rx_ln2_d;
   reg    [DL_BITS+1+SLIP_BITS:0]    rx_ln3_q;
   wire   [DL_BITS+1+SLIP_BITS:0]    rx_ln3_d;
   reg    [DL_BITS+1+SLIP_BITS:0]    rx_ln4_q;
   wire   [DL_BITS+1+SLIP_BITS:0]    rx_ln4_d;
   reg    [DL_BITS+1+SLIP_BITS:0]    rx_ln5_q;
   wire   [DL_BITS+1+SLIP_BITS:0]    rx_ln5_d;
   reg    [DL_BITS+1+SLIP_BITS:0]    rx_ln6_q;
   wire   [DL_BITS+1+SLIP_BITS:0]    rx_ln6_d;
   reg    [DL_BITS+1+SLIP_BITS:0]    rx_ln7_q;
   wire   [DL_BITS+1+SLIP_BITS:0]    rx_ln7_d;
   reg    [DL_BITS+1:0]    rx_ln0_dl_q;
   wire   [DL_BITS+1:0]    rx_ln0_dl_d;
   reg    [DL_BITS+1:0]    rx_ln1_dl_q;
   wire   [DL_BITS+1:0]    rx_ln1_dl_d;
   reg    [DL_BITS+1:0]    rx_ln2_dl_q;
   wire   [DL_BITS+1:0]    rx_ln2_dl_d;
   reg    [DL_BITS+1:0]    rx_ln3_dl_q;
   wire   [DL_BITS+1:0]    rx_ln3_dl_d;
   reg    [DL_BITS+1:0]    rx_ln4_dl_q;
   wire   [DL_BITS+1:0]    rx_ln4_dl_d;
   reg    [DL_BITS+1:0]    rx_ln5_dl_q;
   wire   [DL_BITS+1:0]    rx_ln5_dl_d;
   reg    [DL_BITS+1:0]    rx_ln6_dl_q;
   wire   [DL_BITS+1:0]    rx_ln6_dl_d;
   reg    [DL_BITS+1:0]    rx_ln7_dl_q;
   wire   [DL_BITS+1:0]    rx_ln7_dl_d;


   reg    [DL_BITS+1:0]    tx_ln0_q;
   wire   [DL_BITS+1:0]    tx_ln0_d;
   reg    [DL_BITS+1:0]    tx_ln1_q;
   wire   [DL_BITS+1:0]    tx_ln1_d;
   reg    [DL_BITS+1:0]    tx_ln2_q;
   wire   [DL_BITS+1:0]    tx_ln2_d;
   reg    [DL_BITS+1:0]    tx_ln3_q;
   wire   [DL_BITS+1:0]    tx_ln3_d;
   reg    [DL_BITS+1:0]    tx_ln4_q;
   wire   [DL_BITS+1:0]    tx_ln4_d;
   reg    [DL_BITS+1:0]    tx_ln5_q;
   wire   [DL_BITS+1:0]    tx_ln5_d;
   reg    [DL_BITS+1:0]    tx_ln6_q;
   wire   [DL_BITS+1:0]    tx_ln6_d;
   reg    [DL_BITS+1:0]    tx_ln7_q;
   wire   [DL_BITS+1:0]    tx_ln7_d;

   reg    [GPIO_HDR-1:0]   rx_hdr_q;
   reg    [GPIO_RX_TX-1:0] rx_dat_q;

   reg    [9:0]         ratio_counter_q;
   wire   [9:0]         ratio_counter_d;
   reg    [6:0]         slip_q;              // all lanes same if not async serial; but with scrambled data, dl raises individually
   wire   [6:0]         slip_d;
   wire   [9:0]         ratio_max;

// try individuals to see if gets sync'ed lfsr
   reg    [6:0]         slip_0_q;
   wire   [6:0]         slip_0_d;
   reg    [6:0]         slip_1_q;
   wire   [6:0]         slip_1_d;
   reg    [6:0]         slip_2_q;
   wire   [6:0]         slip_2_d;
   reg    [6:0]         slip_3_q;
   wire   [6:0]         slip_3_d;
   reg    [6:0]         slip_4_q;
   wire   [6:0]         slip_4_d;
   reg    [6:0]         slip_5_q;
   wire   [6:0]         slip_5_d;
   reg    [6:0]         slip_6_q;
   wire   [6:0]         slip_6_d;
   reg    [6:0]         slip_7_q;
   wire   [6:0]         slip_7_d;
   reg                  phy_init_q;
   wire                 phy_init_d;
   reg                  sync_dl_0_q;
   wire                 sync_dl_0_d;
   reg                  sync_dl_1_q;
   wire                 sync_dl_1_d;
   reg                  synced_dl_q;
   wire                 synced_dl_d;
   wire                 sync_dl;
   reg    [3:0]         slip_throttle_q[0:7];
   wire   [3:0]         slip_throttle_d[0:7];

   genvar i;

   always @(posedge clk) begin

      if (rst) begin
         ratio_counter_q <= 'h0;
         phy_init_q <= 'b0;
      end else begin
         ratio_counter_q <= ratio_counter_d;
         phy_init_q <= phy_init_d;
         rx_ln0_q <= rx_ln0_d;
         rx_ln1_q <= rx_ln1_d;
         rx_ln2_q <= rx_ln2_d;
         rx_ln3_q <= rx_ln3_d;
         rx_ln4_q <= rx_ln4_d;
         rx_ln5_q <= rx_ln5_d;
         rx_ln6_q <= rx_ln6_d;
         rx_ln7_q <= rx_ln7_d;
         //wtf should tx be using clk_dl??
         tx_ln0_q <= tx_ln0_d;
         tx_ln1_q <= tx_ln1_d;
         tx_ln2_q <= tx_ln2_d;
         tx_ln3_q <= tx_ln3_d;
         tx_ln4_q <= tx_ln4_d;
         tx_ln5_q <= tx_ln5_d;
         tx_ln6_q <= tx_ln6_d;
         tx_ln7_q <= tx_ln7_d;
      end

   end

   // FF DL
   always @(posedge clk_dl) begin
      integer i;

      if (rst) begin  // dont need dlx_reset?
         sync_dl_0_q <= 'b0;
         sync_dl_1_q <= 'b0;
         synced_dl_q <= 'b0;
         slip_q <= 'h0;
         slip_0_q <= 'h0;
         slip_1_q <= 'h0;
         slip_2_q <= 'h0;
         slip_3_q <= 'h0;
         slip_4_q <= 'h0;
         slip_5_q <= 'h0;
         slip_6_q <= 'h0;
         slip_7_q <= 'h0;
         for (i = 0; i < 8; i = i + 1) begin
            slip_throttle_q[i] = 4'h0;
         end
      end else begin
         sync_dl_0_q <= sync_dl_0_d;
         sync_dl_1_q <= sync_dl_1_d;
         synced_dl_q <= synced_dl_d;
         slip_q <= slip_d;
         slip_0_q <= slip_0_d;
         slip_1_q <= slip_1_d;
         slip_2_q <= slip_2_d;
         slip_3_q <= slip_3_d;
         slip_4_q <= slip_4_d;
         slip_5_q <= slip_5_d;
         slip_6_q <= slip_6_d;
         slip_7_q <= slip_7_d;
         for (i = 0; i < 8; i = i + 1) begin
            slip_throttle_q[i] = slip_throttle_d[i];
         end
         rx_ln0_dl_q <= rx_ln0_dl_d;
         rx_ln1_dl_q <= rx_ln1_dl_d;
         rx_ln2_dl_q <= rx_ln2_dl_d;
         rx_ln3_dl_q <= rx_ln3_dl_d;
         rx_ln4_dl_q <= rx_ln4_dl_d;
         rx_ln5_dl_q <= rx_ln5_dl_d;
         rx_ln6_dl_q <= rx_ln6_dl_d;
         rx_ln7_dl_q <= rx_ln7_dl_d;
      end

   end

   // FF PHY
   always @(negedge rx_clk) begin

      if (rst) begin
      end else  begin
         rx_hdr_q <= rx_hdr;
         rx_dat_q <= rx_dat;
         /*
         tx_ln0_q <= tx_ln0_d;
         tx_ln1_q <= tx_ln1_d;
         tx_ln2_q <= tx_ln2_d;
         tx_ln3_q <= tx_ln3_d;
         tx_ln4_q <= tx_ln4_d;
         tx_ln5_q <= tx_ln5_d;
         tx_ln6_q <= tx_ln6_d;
         tx_ln7_q <= tx_ln7_d;
         */
      end

   end


   if ((GPIO_RX_TX == 512) && (GPIO_HDR == 16)) begin        // direct connect for testing

   assign ratio_max = 512/GPIO_RX_TX-1;

   // Deserializer 512d16s (PHY->DL)

   // get header bits
   assign rx_ln0_d[65:64] = rx_hdr_q[1:0];
   assign rx_ln1_d[65:64] = rx_hdr_q[3:2];
   assign rx_ln2_d[65:64] = rx_hdr_q[5:4];
   assign rx_ln3_d[65:64] = rx_hdr_q[7:6];
   assign rx_ln4_d[65:64] = rx_hdr_q[9:8];
   assign rx_ln5_d[65:64] = rx_hdr_q[11:10];
   assign rx_ln6_d[65:64] = rx_hdr_q[13:12];
   assign rx_ln7_d[65:64] = rx_hdr_q[15:14];

   // get data bits
   assign rx_ln0_d[63:0] = rotl64(rx_dat_q[63:0], slip_q);
   assign rx_ln1_d[63:0] = rotl64(rx_dat_q[127:64], slip_q);
   assign rx_ln2_d[63:0] = rotl64(rx_dat_q[191:128], slip_q);
   assign rx_ln3_d[63:0] = rotl64(rx_dat_q[255:192], slip_q);
   assign rx_ln4_d[63:0] = rotl64(rx_dat_q[319:256], slip_q);
   assign rx_ln5_d[63:0] = rotl64(rx_dat_q[383:320], slip_q);
   assign rx_ln6_d[63:0] = rotl64(rx_dat_q[447:384], slip_q);
   assign rx_ln7_d[63:0] = rotl64(rx_dat_q[511:448], slip_q);

   // Serializer 512d16s (DL->PHY)

   // send header bits
   assign tx_hdr[15:0] = {tx_ln7_q[65:64], tx_ln6_q[65:64], tx_ln5_q[65:64], tx_ln4_q[65:64],
                          tx_ln3_q[65:64], tx_ln2_q[65:64], tx_ln1_q[65:64], tx_ln0_q[65:64]};

   // send data bits

   assign tx_dat[63:0] = tx_ln0_q[63:0];
   assign tx_dat[127:64] = tx_ln1_q[63:0];
   assign tx_dat[191:128] = tx_ln2_q[63:0];
   assign tx_dat[255:192] = tx_ln3_q[63:0];
   assign tx_dat[319:256] = tx_ln4_q[63:0];
   assign tx_dat[383:320] = tx_ln5_q[63:0];
   assign tx_dat[447:384] = tx_ln6_q[63:0];
   assign tx_dat[511:448] = tx_ln7_q[63:0];

   end else if ((GPIO_RX_TX == 8) && (GPIO_HDR == 1)) begin  // 8/1/1 x 2 = 20 pins

   assign ratio_max = 512/GPIO_RX_TX-1;

   // Deserializer 8d1s (PHY->DL)
   // data on lanes 0:7
   // hdr on lane 0[0]; others unconnected

   // get header bits
   assign rx_ln0_d[65] = ratio_counter_q == 10'd00 ? rx_hdr_q[0] : rx_ln0_q[65];
   assign rx_ln0_d[64] = ratio_counter_q == 10'd01 ? rx_hdr_q[0] : rx_ln0_q[64];
   assign rx_ln1_d[65] = ratio_counter_q == 10'd02 ? rx_hdr_q[0] : rx_ln1_q[65];
   assign rx_ln1_d[64] = ratio_counter_q == 10'd03 ? rx_hdr_q[0] : rx_ln1_q[64];
   assign rx_ln2_d[65] = ratio_counter_q == 10'd04 ? rx_hdr_q[0] : rx_ln2_q[65];
   assign rx_ln2_d[64] = ratio_counter_q == 10'd05 ? rx_hdr_q[0] : rx_ln2_q[64];
   assign rx_ln3_d[65] = ratio_counter_q == 10'd06 ? rx_hdr_q[0] : rx_ln3_q[65];
   assign rx_ln3_d[64] = ratio_counter_q == 10'd07 ? rx_hdr_q[0] : rx_ln3_q[64];
   assign rx_ln4_d[65] = ratio_counter_q == 10'd08 ? rx_hdr_q[0] : rx_ln4_q[65];
   assign rx_ln4_d[64] = ratio_counter_q == 10'd09 ? rx_hdr_q[0] : rx_ln4_q[64];
   assign rx_ln5_d[65] = ratio_counter_q == 10'd10 ? rx_hdr_q[0] : rx_ln5_q[65];
   assign rx_ln5_d[64] = ratio_counter_q == 10'd11 ? rx_hdr_q[0] : rx_ln5_q[64];
   assign rx_ln6_d[65] = ratio_counter_q == 10'd12 ? rx_hdr_q[0] : rx_ln6_q[65];
   assign rx_ln6_d[64] = ratio_counter_q == 10'd13 ? rx_hdr_q[0] : rx_ln6_q[64];
   assign rx_ln7_d[65] = ratio_counter_q == 10'd14 ? rx_hdr_q[0] : rx_ln7_q[65];
   assign rx_ln7_d[64] = ratio_counter_q == 10'd15 ? rx_hdr_q[0] : rx_ln7_q[64];

   // get data bits
   genvar i;
   // alternating bits by lane
   for (i = 0; i < 63; i++) begin
      assign rx_ln0_d[i] = ratio_counter_q == i ? rx_dat_q[i*8+0] : rx_ln0_q[i];
   end
   for (i = 0; i < 63; i++) begin
      assign rx_ln1_d[i] = ratio_counter_q == i ? rx_dat_q[i*8+1] : rx_ln1_q[i];
   end
   for (i = 0; i < 63; i++) begin
      assign rx_ln2_d[i] = ratio_counter_q == i ? rx_dat_q[i*8+2] : rx_ln2_q[i];
   end
   for (i = 0; i < 63; i++) begin
      assign rx_ln3_d[i] = ratio_counter_q == i ? rx_dat_q[i*8+3] : rx_ln3_q[i];
   end
   for (i = 0; i < 63; i++) begin
      assign rx_ln4_d[i] = ratio_counter_q == i ? rx_dat_q[i*8+4] : rx_ln4_q[i];
   end
   for (i = 0; i < 63; i++) begin
      assign rx_ln5_d[i] = ratio_counter_q == i ? rx_dat_q[i*8+5] : rx_ln5_q[i];
   end
   for (i = 0; i < 63; i++) begin
      assign rx_ln6_d[i] = ratio_counter_q == i ? rx_dat_q[i*8+6] : rx_ln6_q[i];
   end
   for (i = 0; i < 63; i++) begin
      assign rx_ln7_d[i] = ratio_counter_q == i ? rx_dat_q[i*8+7] : rx_ln7_q[i];
   end
   /* if grouped in 64s by lane
      genvar i;
   for (i = 0; i < 8; i++) begin
      assign rx_ln0_d[i*8+7:i*8] = ratio_counter_q == i ? rx_dat_q[i*8+7:i*8] : rx_ln0_q[i*8+7:i*8];
   end
   for (i = 0; i < 8; i++) begin
      assign rx_ln1_d[i*8+7:i*8] = ratio_counter_q == i ? rx_dat_q[64+i*8+7:64+i*8] : rx_ln1_q[i*8+7:i*8];
   end
   for (i = 0; i < 8; i++) begin
      assign rx_ln2_d[i*8+7:i*8] = ratio_counter_q == i ? rx_dat_q[128+i*8+7:128+i*8] : rx_ln2_q[i*8+7:i*8];
   end
   for (i = 0; i < 8; i++) begin
      assign rx_ln3_d[i*8+7:i*8] = ratio_counter_q == i ? rx_dat_q[192+i*8+7:192+i*8] : rx_ln3_q[i*8+7:i*8];
   end
   for (i = 0; i < 8; i++) begin
      assign rx_ln4_d[i*8+7:i*8] = ratio_counter_q == i ? rx_dat_q[256+i*8+7:256+i*8] : rx_ln4_q[i*8+7:i*8];
   end
   for (i = 0; i < 8; i++) begin
      assign rx_ln5_d[i*8+7:i*8] = ratio_counter_q == i ? rx_dat_q[320+i*8+7:320+i*8] : rx_ln5_q[i*8+7:i*8];
   end
   for (i = 0; i < 8; i++) begin
      assign rx_ln6_d[i*8+7:i*8] = ratio_counter_q == i ? rx_dat_q[384+i*8+7:384+i*8] : rx_ln6_q[i*8+7:i*8];
   end
   for (i = 0; i < 8; i++) begin
      assign rx_ln7_d[i*8+7:i*8] = ratio_counter_q == i ? rx_dat_q[448+i*8+7:448+i*8] : rx_ln7_q[i*8+7:i*8];
   end
   */

   // Serializer 8d1s (DL->PHY)
   // data on lanes 0:7
   // hdr on lane 0[0]; others unconnected

   // need rx->tx

   // send header bit
   assign tx_hdr[0] = mux16(ratio_counter_q[3:0],
                            {tx_ln0_q[65:64], tx_ln1_q[65:64], tx_ln2_q[65:64], tx_ln3_q[65:64],
                             tx_ln4_q[65:64], tx_ln5_q[65:64], tx_ln6_q[65:64], tx_ln7_q[65:64]}
                           );

   // send data bits
   assign tx_dat[0] = mux64(ratio_counter_q[5:0], tx_ln0_q[63:0]);
   assign tx_dat[1] = mux64(ratio_counter_q[5:0], tx_ln1_q[63:0]);
   assign tx_dat[2] = mux64(ratio_counter_q[5:0], tx_ln2_q[63:0]);
   assign tx_dat[3] = mux64(ratio_counter_q[5:0], tx_ln3_q[63:0]);
   assign tx_dat[4] = mux64(ratio_counter_q[5:0], tx_ln4_q[63:0]);
   assign tx_dat[5] = mux64(ratio_counter_q[5:0], tx_ln5_q[63:0]);
   assign tx_dat[6] = mux64(ratio_counter_q[5:0], tx_ln6_q[63:0]);
   assign tx_dat[7] = mux64(ratio_counter_q[5:0], tx_ln7_q[63:0]);

//----- 8 BIT MUX ------------------------------------------------------------------------------------------------------

end else if ((GPIO_RX_TX == 8) && (GPIO_HDR == 0)) begin  // 66:1

   assign ratio_max = 65;

   // Deserializer 8d1s (PHY->DL)
   // hdr+data on lanes 0:7

   // get data bits
   // rx_dat_q is clocked by rx_clk
   // rx_lnX_q is clocked by clk
   assign rx_ln0_d = (rx_ln0_q << 1) | rx_dat_q[0];
   assign rx_ln1_d = (rx_ln1_q << 1) | rx_dat_q[1];
   assign rx_ln2_d = (rx_ln2_q << 1) | rx_dat_q[2];
   assign rx_ln3_d = (rx_ln3_q << 1) | rx_dat_q[3];
   assign rx_ln4_d = (rx_ln4_q << 1) | rx_dat_q[4];
   assign rx_ln5_d = (rx_ln5_q << 1) | rx_dat_q[5];
   assign rx_ln6_d = (rx_ln6_q << 1) | rx_dat_q[6];
   assign rx_ln7_d = (rx_ln7_q << 1) | rx_dat_q[7];


   // Serializer 8d1s (DL->PHY)
   // hdr+data on lanes 0:7
   // ratio_counter counts up, so bits are sent 0:65
   // p20 of dl spec has eng. note: patterns are xmit'd left->right (FF00 is sent as 1111 1111 0000 0000)

   // send data bits
   assign tx_dat[0] = mux66(ratio_counter_q[6:0], tx_ln0_q);
   assign tx_dat[1] = mux66(ratio_counter_q[6:0], tx_ln1_q);
   assign tx_dat[2] = mux66(ratio_counter_q[6:0], tx_ln2_q);
   assign tx_dat[3] = mux66(ratio_counter_q[6:0], tx_ln3_q);
   assign tx_dat[4] = mux66(ratio_counter_q[6:0], tx_ln4_q);
   assign tx_dat[5] = mux66(ratio_counter_q[6:0], tx_ln5_q);
   assign tx_dat[6] = mux66(ratio_counter_q[6:0], tx_ln6_q);
   assign tx_dat[7] = mux66(ratio_counter_q[6:0], tx_ln7_q);
//---------------------------------------------------------------------------------------------------------------------

   end  // GPIO_RX_TX/GPIO_HDR

   // if use sync line, it resets this...
   //assign ratio_counter_d = phy_init | (ratio_counter_q == ratio_max) ? 0 :
   //                         ratio_counter_q + 1;
   // count down so send 65->0

   // sync ratio counter to clk_dl cycle
   // a 'start/sync' signal would be used to set ratio_counter instead; needs to work same cycle and also set ratio_counter properly
   assign sync_dl_1_d = ~sync_dl_1_q;
   assign sync_dl_0_d = sync_dl_1_q;
   assign sync_dl = (sync_dl_0_q & ~sync_dl_1_q) & ~synced_dl_q; // 0 always if using sync_in
   assign synced_dl_d = sync_dl | synced_dl_q;

   assign ratio_counter_d = sync_dl                ? ratio_max :
                            ~synced_dl_q           ? 'b0 :
                            ratio_counter_q == 0   ? ratio_max :
                            ratio_counter_q - 1;


   //wtf get rid of this
   // throttle slips
   wire [0:7] lane_rx_slip;
   wire [0:7] lane_slip;
   `define SLIP_THROTTLE 0
   assign lane_rx_slip = {ln0_rx_slip, ln1_rx_slip, ln2_rx_slip, ln3_rx_slip, ln4_rx_slip, ln5_rx_slip, ln6_rx_slip, ln7_rx_slip};
   for (i = 0; i < 8; i = i + 1) begin
      assign slip_throttle_d[i] = slip_throttle_q[i] != 0 ? slip_throttle_q[i] - 1 :
                                  lane_rx_slip[i] ? `SLIP_THROTTLE : 0;
      assign lane_slip[i] = lane_rx_slip[i] & (slip_throttle_q[i] == 0);
   end


   // reset when phy_init - necessary?

   assign phy_init_d = phy_init;

   assign slip_0_d = phy_init_q ? 0 : lane_slip[0] ? incslip(slip_0_q) : slip_0_q;
   assign slip_1_d = phy_init_q ? 0 : lane_slip[1] ? incslip(slip_1_q) : slip_1_q;
   assign slip_2_d = phy_init_q ? 0 : lane_slip[2] ? incslip(slip_2_q) : slip_2_q;
   assign slip_3_d = phy_init_q ? 0 : lane_slip[3] ? incslip(slip_3_q) : slip_3_q;
   assign slip_4_d = phy_init_q ? 0 : lane_slip[4] ? incslip(slip_4_q) : slip_4_q;
   assign slip_5_d = phy_init_q ? 0 : lane_slip[5] ? incslip(slip_5_q) : slip_5_q;
   assign slip_6_d = phy_init_q ? 0 : lane_slip[6] ? incslip(slip_6_q) : slip_6_q;
   assign slip_7_d = phy_init_q ? 0 : lane_slip[7] ? incslip(slip_7_q) : slip_7_q;

//wtf ******** check slips and fail if too many **********************************
// it wraps right now








/*
   // don't reset when phy_init; shouldn't have to (?)

   //assign slip_d = (ln0_rx_slip | ln1_rx_slip | ln2_rx_slip | ln3_rx_slip |
   //                 ln4_rx_slip | ln5_rx_slip | ln6_rx_slip | ln7_rx_slip)   ? slip_q + 1 : slip_q;
   //
   assign slip_0_d = ln0_rx_slip ? slip_0_q + 1 : slip_0_q;
   assign slip_1_d = ln1_rx_slip ? slip_1_q + 1 : slip_1_q;
   assign slip_2_d = ln2_rx_slip ? slip_2_q + 1 : slip_2_q;
   assign slip_3_d = ln3_rx_slip ? slip_3_q + 1 : slip_3_q;
   assign slip_4_d = ln4_rx_slip ? slip_4_q + 1 : slip_4_q;
   assign slip_5_d = ln5_rx_slip ? slip_5_q + 1 : slip_5_q;
   assign slip_6_d = ln6_rx_slip ? slip_6_q + 1 : slip_6_q;
   assign slip_7_d = ln7_rx_slip ? slip_7_q + 1 : slip_7_q;
*/
   assign tx_clk = clk;

   // get from DL
   /* version 1 */
   assign tx_ln0_d[65:64] = ln0_tx_header;
   assign tx_ln0_d[63:0] = ln0_tx_data;
   assign tx_ln1_d[65:64] = ln1_tx_header;
   assign tx_ln1_d[63:0] = ln1_tx_data;
   assign tx_ln2_d[65:64] = ln2_tx_header;
   assign tx_ln2_d[63:0] = ln2_tx_data;
   assign tx_ln3_d[65:64] = ln3_tx_header;
   assign tx_ln3_d[63:0] = ln3_tx_data;
   assign tx_ln4_d[65:64] = ln4_tx_header;
   assign tx_ln4_d[63:0] = ln4_tx_data;
   assign tx_ln5_d[65:64] = ln5_tx_header;
   assign tx_ln5_d[63:0] = ln5_tx_data;
   assign tx_ln6_d[65:64] = ln6_tx_header;
   assign tx_ln6_d[63:0] = ln6_tx_data;
   assign tx_ln7_d[65:64] = ln7_tx_header;
   assign tx_ln7_d[63:0] = ln7_tx_data;

   /* version 2
     send like spec: send h0,h1,d0,...,d63
    tx_lnx_q is sent 65:0

   assign tx_ln0_d[65:64] = {ln0_tx_header[0], ln0_tx_header[1]};
   assign tx_ln0_d[63:0] = rev64(ln0_tx_data);
   assign tx_ln1_d[65:64] = {ln1_tx_header[0], ln1_tx_header[1]};
   assign tx_ln1_d[63:0] = rev64(ln1_tx_data);
   assign tx_ln2_d[65:64] = {ln2_tx_header[0], ln2_tx_header[1]};
   assign tx_ln2_d[63:0] = rev64(ln2_tx_data);
   assign tx_ln3_d[65:64] = {ln3_tx_header[0], ln3_tx_header[1]};
   assign tx_ln3_d[63:0] = rev64(ln3_tx_data);
   assign tx_ln4_d[65:64] = {ln4_tx_header[0], ln4_tx_header[1]};
   assign tx_ln4_d[63:0] = rev64(ln4_tx_data);
   assign tx_ln5_d[65:64] = {ln5_tx_header[0], ln5_tx_header[1]};
   assign tx_ln5_d[63:0] = rev64(ln5_tx_data);
   assign tx_ln6_d[65:64] = {ln6_tx_header[0], ln6_tx_header[1]};
   assign tx_ln6_d[63:0] = rev64(ln6_tx_data);
   assign tx_ln7_d[65:64] = {ln7_tx_header[0], ln7_tx_header[1]};
   assign tx_ln7_d[63:0] = rev64(ln7_tx_data);
   */

   // send to DL
   /* was like this when tested 512+16 mode
   assign ln0_rx_valid = 1'b1;
   assign ln0_rx_header = rx_ln0_q[65:64];
   assign ln0_rx_data = rx_ln0_q[63:0];
   assign ln1_rx_valid = 1'b1;
   assign ln1_rx_header = rx_ln1_q[65:64];
   assign ln1_rx_data = rx_ln1_q[63:0];
   assign ln2_rx_valid = 1'b1;
   assign ln2_rx_header = rx_ln2_q[65:64];
   assign ln2_rx_data = rx_ln2_q[63:0];
   assign ln3_rx_valid = 1'b1;
   assign ln3_rx_header = rx_ln3_q[65:64];
   assign ln3_rx_data = rx_ln3_q[63:0];
   assign ln4_rx_valid = 1'b1;
   assign ln4_rx_header = rx_ln4_q[65:64];
   assign ln4_rx_data = rx_ln4_q[63:0];
   assign ln5_rx_valid = 1'b1;
   assign ln5_rx_header = rx_ln5_q[65:64];
   assign ln5_rx_data = rx_ln5_q[63:0];
   assign ln6_rx_valid = 1'b1;
   assign ln6_rx_header = rx_ln6_q[65:64];
   assign ln6_rx_data = rx_ln6_q[63:0];
   assign ln7_rx_valid = 1'b1;
   assign ln7_rx_header = rx_ln7_q[65:64];
   assign ln7_rx_data = rx_ln7_q[63:0];
   */

   wire [DL_BITS+1:0] rx_ln0_slip;
   wire [DL_BITS+1:0] rx_ln1_slip;
   wire [DL_BITS+1:0] rx_ln2_slip;
   wire [DL_BITS+1:0] rx_ln3_slip;
   wire [DL_BITS+1:0] rx_ln4_slip;
   wire [DL_BITS+1:0] rx_ln5_slip;
   wire [DL_BITS+1:0] rx_ln6_slip;
   wire [DL_BITS+1:0] rx_ln7_slip;

   //wtf adding ~slip fixed one of the random reset cases
   //wtf if phy doesn't block valid, does it somehow cause some cases (that would be good) to be missed????
   assign ln0_rx_valid = synced_dl_q & ~ln0_rx_slip;
   assign ln1_rx_valid = synced_dl_q & ~ln1_rx_slip;
   assign ln2_rx_valid = synced_dl_q & ~ln2_rx_slip;
   assign ln3_rx_valid = synced_dl_q & ~ln3_rx_slip;
   assign ln4_rx_valid = synced_dl_q & ~ln4_rx_slip;
   assign ln5_rx_valid = synced_dl_q & ~ln5_rx_slip;
   assign ln6_rx_valid = synced_dl_q & ~ln6_rx_slip;
   assign ln7_rx_valid = synced_dl_q & ~ln7_rx_slip;

// when ratio_counter
/* version 1 */
/* but also use intermediate clk_dl latch

   assign rx_ln0_slip = bitslip132(rx_ln0_q, slip_0_q);
   assign rx_ln1_slip = bitslip132(rx_ln1_q, slip_1_q);
   assign rx_ln2_slip = bitslip132(rx_ln2_q, slip_2_q);
   assign rx_ln3_slip = bitslip132(rx_ln3_q, slip_3_q);
   assign rx_ln4_slip = bitslip132(rx_ln4_q, slip_4_q);
   assign rx_ln5_slip = bitslip132(rx_ln5_q, slip_5_q);
   assign rx_ln6_slip = bitslip132(rx_ln6_q, slip_6_q);
   assign rx_ln7_slip = bitslip132(rx_ln7_q, slip_7_q);

   assign ln0_rx_header = rx_ln0_slip[65:64];
   assign ln0_rx_data = rx_ln0_slip[63:0];
   assign ln1_rx_header = rx_ln1_slip[65:64];
   assign ln1_rx_data = rx_ln1_slip[63:0];
   assign ln2_rx_header = rx_ln2_slip[65:64];
   assign ln2_rx_data = rx_ln2_slip[63:0];
   assign ln3_rx_header = rx_ln3_slip[65:64];
   assign ln3_rx_data = rx_ln3_slip[63:0];
   assign ln4_rx_header = rx_ln4_slip[65:64];
   assign ln4_rx_data = rx_ln4_slip[63:0];
   assign ln5_rx_header = rx_ln5_slip[65:64];
   assign ln5_rx_data = rx_ln5_slip[63:0];
   assign ln6_rx_header = rx_ln6_slip[65:64];
   assign ln6_rx_data = rx_ln6_slip[63:0];
   assign ln7_rx_header = rx_ln7_slip[65:64];
   assign ln7_rx_data = rx_ln7_slip[63:0];
 */

   // slip - when ratio_counter=0, _d data is final beat; slip and latch in clk_dl regs for sending to dl
   assign rx_ln0_slip = bitslip132(rx_ln0_d, slip_0_q);
   assign rx_ln1_slip = bitslip132(rx_ln1_d, slip_1_q);
   assign rx_ln2_slip = bitslip132(rx_ln2_d, slip_2_q);
   assign rx_ln3_slip = bitslip132(rx_ln3_d, slip_3_q);
   assign rx_ln4_slip = bitslip132(rx_ln4_d, slip_4_q);
   assign rx_ln5_slip = bitslip132(rx_ln5_d, slip_5_q);
   assign rx_ln6_slip = bitslip132(rx_ln6_d, slip_6_q);
   assign rx_ln7_slip = bitslip132(rx_ln7_d, slip_7_q);

   // clk_dl latch slipped data
   assign rx_ln0_dl_d = rx_ln0_slip;
   assign rx_ln1_dl_d = rx_ln1_slip;
   assign rx_ln2_dl_d = rx_ln2_slip;
   assign rx_ln3_dl_d = rx_ln3_slip;
   assign rx_ln4_dl_d = rx_ln4_slip;
   assign rx_ln5_dl_d = rx_ln5_slip;
   assign rx_ln6_dl_d = rx_ln6_slip;
   assign rx_ln7_dl_d = rx_ln7_slip;

   // to dl
   assign ln0_rx_header = rx_ln0_dl_q[65:64];
   assign ln0_rx_data = rx_ln0_dl_q[63:0];
   assign ln1_rx_header = rx_ln1_dl_q[65:64];
   assign ln1_rx_data = rx_ln1_dl_q[63:0];
   assign ln2_rx_header = rx_ln2_dl_q[65:64];
   assign ln2_rx_data = rx_ln2_dl_q[63:0];
   assign ln3_rx_header = rx_ln3_dl_q[65:64];
   assign ln3_rx_data = rx_ln3_dl_q[63:0];
   assign ln4_rx_header = rx_ln4_dl_q[65:64];
   assign ln4_rx_data = rx_ln4_dl_q[63:0];
   assign ln5_rx_header = rx_ln5_dl_q[65:64];
   assign ln5_rx_data = rx_ln5_dl_q[63:0];
   assign ln6_rx_header = rx_ln6_dl_q[65:64];
   assign ln6_rx_data = rx_ln6_dl_q[63:0];
   assign ln7_rx_header = rx_ln7_dl_q[65:64];
   assign ln7_rx_data = rx_ln7_dl_q[63:0];


/* version 2
// slip provides 65:0 in order sent (h0,h1,d0,..d63)
   assign ln0_rx_header = {rx_ln0_slip[64], rx_ln0_slip[65]};
   assign ln0_rx_data = rev64(rx_ln0_slip[63:0]);
   assign ln1_rx_header = {rx_ln1_slip[64], rx_ln1_slip[65]};
   assign ln1_rx_data = rev64(rx_ln1_slip[63:0]);
   assign ln2_rx_header = {rx_ln2_slip[64], rx_ln2_slip[65]};
   assign ln2_rx_data = rev64(rx_ln2_slip[63:0]);
   assign ln3_rx_header = {rx_ln3_slip[64], rx_ln3_slip[65]};
   assign ln3_rx_data = rev64(rx_ln3_slip[63:0]);
   assign ln4_rx_header = {rx_ln4_slip[64], rx_ln4_slip[65]};
   assign ln4_rx_data = rev64(rx_ln4_slip[63:0]);
   assign ln5_rx_header = {rx_ln5_slip[64], rx_ln5_slip[65]};
   assign ln5_rx_data = rev64(rx_ln5_slip[63:0]);
   assign ln6_rx_header = {rx_ln6_slip[64], rx_ln6_slip[65]};
   assign ln6_rx_data = rev64(rx_ln6_slip[63:0]);
   assign ln7_rx_header = {rx_ln7_slip[64], rx_ln7_slip[65]};
   assign ln7_rx_data = rev64(rx_ln7_slip[63:0]);
*/

endmodule


function mux16;
   input [3:0]  sel;
   input [15:0] dat;
   begin
      assign mux16 =
                    ((sel == 4'd00) & dat[00]) |
                    ((sel == 4'd01) & dat[01]) |
                    ((sel == 4'd02) & dat[02]) |
                    ((sel == 4'd03) & dat[03]) |
                    ((sel == 4'd04) & dat[04]) |
                    ((sel == 4'd05) & dat[05]) |
                    ((sel == 4'd06) & dat[06]) |
                    ((sel == 4'd07) & dat[07]) |
                    ((sel == 4'd08) & dat[08]) |
                    ((sel == 4'd09) & dat[09]) |
                    ((sel == 4'd10) & dat[10]) |
                    ((sel == 4'd11) & dat[11]) |
                    ((sel == 4'd12) & dat[12]) |
                    ((sel == 4'd13) & dat[13]) |
                    ((sel == 4'd14) & dat[14]) |
                    ((sel == 4'd15) & dat[15]);
   end
endfunction

function mux64;
   input [5:0]  sel;
   input [63:0] dat;
   begin
      assign mux64 =
                    ((sel == 6'd00) & dat[00]) |
                    ((sel == 6'd01) & dat[01]) |
                    ((sel == 6'd02) & dat[02]) |
                    ((sel == 6'd03) & dat[03]) |
                    ((sel == 6'd04) & dat[04]) |
                    ((sel == 6'd05) & dat[05]) |
                    ((sel == 6'd06) & dat[06]) |
                    ((sel == 6'd07) & dat[07]) |
                    ((sel == 6'd08) & dat[08]) |
                    ((sel == 6'd09) & dat[09]) |
                    ((sel == 6'd10) & dat[10]) |
                    ((sel == 6'd11) & dat[11]) |
                    ((sel == 6'd12) & dat[12]) |
                    ((sel == 6'd13) & dat[13]) |
                    ((sel == 6'd14) & dat[14]) |
                    ((sel == 6'd15) & dat[15]) |
                    ((sel == 6'd16) & dat[16]) |
                    ((sel == 6'd17) & dat[17]) |
                    ((sel == 6'd18) & dat[18]) |
                    ((sel == 6'd19) & dat[19]) |
                    ((sel == 6'd20) & dat[20]) |
                    ((sel == 6'd21) & dat[21]) |
                    ((sel == 6'd22) & dat[22]) |
                    ((sel == 6'd23) & dat[23]) |
                    ((sel == 6'd24) & dat[24]) |
                    ((sel == 6'd25) & dat[25]) |
                    ((sel == 6'd26) & dat[26]) |
                    ((sel == 6'd27) & dat[27]) |
                    ((sel == 6'd28) & dat[28]) |
                    ((sel == 6'd29) & dat[29]) |
                    ((sel == 6'd30) & dat[30]) |
                    ((sel == 6'd31) & dat[31]) |
                    ((sel == 6'd32) & dat[32]) |
                    ((sel == 6'd33) & dat[33]) |
                    ((sel == 6'd34) & dat[34]) |
                    ((sel == 6'd35) & dat[35]) |
                    ((sel == 6'd36) & dat[36]) |
                    ((sel == 6'd37) & dat[37]) |
                    ((sel == 6'd38) & dat[38]) |
                    ((sel == 6'd39) & dat[39]) |
                    ((sel == 6'd40) & dat[40]) |
                    ((sel == 6'd41) & dat[41]) |
                    ((sel == 6'd42) & dat[42]) |
                    ((sel == 6'd43) & dat[43]) |
                    ((sel == 6'd44) & dat[44]) |
                    ((sel == 6'd45) & dat[45]) |
                    ((sel == 6'd46) & dat[46]) |
                    ((sel == 6'd47) & dat[47]) |
                    ((sel == 6'd48) & dat[48]) |
                    ((sel == 6'd49) & dat[49]) |
                    ((sel == 6'd50) & dat[50]) |
                    ((sel == 6'd51) & dat[51]) |
                    ((sel == 6'd52) & dat[52]) |
                    ((sel == 6'd53) & dat[53]) |
                    ((sel == 6'd54) & dat[54]) |
                    ((sel == 6'd55) & dat[55]) |
                    ((sel == 6'd56) & dat[56]) |
                    ((sel == 6'd57) & dat[57]) |
                    ((sel == 6'd58) & dat[58]) |
                    ((sel == 6'd59) & dat[59]) |
                    ((sel == 6'd60) & dat[60]) |
                    ((sel == 6'd61) & dat[61]) |
                    ((sel == 6'd62) & dat[62]) |
                    ((sel == 6'd63) & dat[63]);
   end
endfunction

function mux66;
   input [6:0]  sel;
   input [65:0] dat;
   begin
      assign mux66 =
                    ((sel == 7'd00) & dat[00]) |
                    ((sel == 7'd01) & dat[01]) |
                    ((sel == 7'd02) & dat[02]) |
                    ((sel == 7'd03) & dat[03]) |
                    ((sel == 7'd04) & dat[04]) |
                    ((sel == 7'd05) & dat[05]) |
                    ((sel == 7'd06) & dat[06]) |
                    ((sel == 7'd07) & dat[07]) |
                    ((sel == 7'd08) & dat[08]) |
                    ((sel == 7'd09) & dat[09]) |
                    ((sel == 7'd10) & dat[10]) |
                    ((sel == 7'd11) & dat[11]) |
                    ((sel == 7'd12) & dat[12]) |
                    ((sel == 7'd13) & dat[13]) |
                    ((sel == 7'd14) & dat[14]) |
                    ((sel == 7'd15) & dat[15]) |
                    ((sel == 7'd16) & dat[16]) |
                    ((sel == 7'd17) & dat[17]) |
                    ((sel == 7'd18) & dat[18]) |
                    ((sel == 7'd19) & dat[19]) |
                    ((sel == 7'd20) & dat[20]) |
                    ((sel == 7'd21) & dat[21]) |
                    ((sel == 7'd22) & dat[22]) |
                    ((sel == 7'd23) & dat[23]) |
                    ((sel == 7'd24) & dat[24]) |
                    ((sel == 7'd25) & dat[25]) |
                    ((sel == 7'd26) & dat[26]) |
                    ((sel == 7'd27) & dat[27]) |
                    ((sel == 7'd28) & dat[28]) |
                    ((sel == 7'd29) & dat[29]) |
                    ((sel == 7'd30) & dat[30]) |
                    ((sel == 7'd31) & dat[31]) |
                    ((sel == 7'd32) & dat[32]) |
                    ((sel == 7'd33) & dat[33]) |
                    ((sel == 7'd34) & dat[34]) |
                    ((sel == 7'd35) & dat[35]) |
                    ((sel == 7'd36) & dat[36]) |
                    ((sel == 7'd37) & dat[37]) |
                    ((sel == 7'd38) & dat[38]) |
                    ((sel == 7'd39) & dat[39]) |
                    ((sel == 7'd40) & dat[40]) |
                    ((sel == 7'd41) & dat[41]) |
                    ((sel == 7'd42) & dat[42]) |
                    ((sel == 7'd43) & dat[43]) |
                    ((sel == 7'd44) & dat[44]) |
                    ((sel == 7'd45) & dat[45]) |
                    ((sel == 7'd46) & dat[46]) |
                    ((sel == 7'd47) & dat[47]) |
                    ((sel == 7'd48) & dat[48]) |
                    ((sel == 7'd49) & dat[49]) |
                    ((sel == 7'd50) & dat[50]) |
                    ((sel == 7'd51) & dat[51]) |
                    ((sel == 7'd52) & dat[52]) |
                    ((sel == 7'd53) & dat[53]) |
                    ((sel == 7'd54) & dat[54]) |
                    ((sel == 7'd55) & dat[55]) |
                    ((sel == 7'd56) & dat[56]) |
                    ((sel == 7'd57) & dat[57]) |
                    ((sel == 7'd58) & dat[58]) |
                    ((sel == 7'd59) & dat[59]) |
                    ((sel == 7'd60) & dat[60]) |
                    ((sel == 7'd61) & dat[61]) |
                    ((sel == 7'd62) & dat[62]) |
                    ((sel == 7'd63) & dat[63]) |
                    ((sel == 7'd64) & dat[64]) |
                    ((sel == 7'd65) & dat[65]);
   end
endfunction

function [63:0] rotl64;
   input [63:0] dat;
   input [5:0]  amt;
   begin
      assign rotl64 = (dat << amt) | (dat >> (64 - amt));
   end
endfunction


// dont need to do this
// bit slip can be directly used when loading rx data
// it means do a throw-away and extra shift left when loading; could also do it
//  with fewer slip bits and when they get filled, do the multibit shift in data
// and even with this impl, you can never do more than 66 bit shift
function [65:0] bitslip132;
   input [131:0] dat;
   input [6:0]   amt;
   begin
      case (amt)
         'd000 : assign bitslip132 = dat[131:66];
         'd001 : assign bitslip132 = dat[130:65];
         'd002 : assign bitslip132 = dat[129:64];
         'd003 : assign bitslip132 = dat[128:63];
         'd004 : assign bitslip132 = dat[127:62];
         'd005 : assign bitslip132 = dat[126:61];
         'd006 : assign bitslip132 = dat[125:60];
         'd007 : assign bitslip132 = dat[124:59];
         'd008 : assign bitslip132 = dat[123:58];
         'd009 : assign bitslip132 = dat[122:57];
         'd010 : assign bitslip132 = dat[121:56];
         'd011 : assign bitslip132 = dat[120:55];
         'd012 : assign bitslip132 = dat[119:54];
         'd013 : assign bitslip132 = dat[118:53];
         'd014 : assign bitslip132 = dat[117:52];
         'd015 : assign bitslip132 = dat[116:51];
         'd016 : assign bitslip132 = dat[115:50];
         'd017 : assign bitslip132 = dat[114:49];
         'd018 : assign bitslip132 = dat[113:48];
         'd019 : assign bitslip132 = dat[112:47];
         'd020 : assign bitslip132 = dat[111:46];
         'd021 : assign bitslip132 = dat[110:45];
         'd022 : assign bitslip132 = dat[109:44];
         'd023 : assign bitslip132 = dat[108:43];
         'd024 : assign bitslip132 = dat[107:42];
         'd025 : assign bitslip132 = dat[106:41];
         'd026 : assign bitslip132 = dat[105:40];
         'd027 : assign bitslip132 = dat[104:39];
         'd028 : assign bitslip132 = dat[103:38];
         'd029 : assign bitslip132 = dat[102:37];
         'd030 : assign bitslip132 = dat[101:36];
         'd031 : assign bitslip132 = dat[100:35];
         'd032 : assign bitslip132 = dat[ 99:34];
         'd033 : assign bitslip132 = dat[ 98:33];
         'd034 : assign bitslip132 = dat[ 97:32];
         'd035 : assign bitslip132 = dat[ 96:31];
         'd036 : assign bitslip132 = dat[ 95:30];
         'd037 : assign bitslip132 = dat[ 94:29];
         'd038 : assign bitslip132 = dat[ 93:28];
         'd039 : assign bitslip132 = dat[ 92:27];
         'd040 : assign bitslip132 = dat[ 91:26];
         'd041 : assign bitslip132 = dat[ 90:25];
         'd042 : assign bitslip132 = dat[ 89:24];
         'd043 : assign bitslip132 = dat[ 88:23];
         'd044 : assign bitslip132 = dat[ 87:22];
         'd045 : assign bitslip132 = dat[ 86:21];
         'd046 : assign bitslip132 = dat[ 85:20];
         'd047 : assign bitslip132 = dat[ 84:19];
         'd048 : assign bitslip132 = dat[ 83:18];
         'd049 : assign bitslip132 = dat[ 82:17];
         'd050 : assign bitslip132 = dat[ 81:16];
         'd051 : assign bitslip132 = dat[ 80:15];
         'd052 : assign bitslip132 = dat[ 79:14];
         'd053 : assign bitslip132 = dat[ 78:13];
         'd054 : assign bitslip132 = dat[ 77:12];
         'd055 : assign bitslip132 = dat[ 76:11];
         'd056 : assign bitslip132 = dat[ 75:10];
         'd057 : assign bitslip132 = dat[ 74:09];
         'd058 : assign bitslip132 = dat[ 73:08];
         'd059 : assign bitslip132 = dat[ 72:07];
         'd060 : assign bitslip132 = dat[ 71:06];
         'd061 : assign bitslip132 = dat[ 70:05];
         'd062 : assign bitslip132 = dat[ 69:04];
         'd063 : assign bitslip132 = dat[ 68:03];
         'd064 : assign bitslip132 = dat[ 67:02];
         'd065 : assign bitslip132 = dat[ 66:01];
         'd066 : assign bitslip132 = dat[ 65:00];
      endcase
   end
endfunction

function [63:0] rev64;
input [63:0] dat;
integer i;
begin
   for (i = 0; i < 64; i = i + 1) begin
      assign rev64[63-i] = dat[i];
   end
end
endfunction

`define MAXSLIP 65
function [6:0] incslip;
input [6:0] slip;
begin
   assign incslip = slip == `MAXSLIP ? 0 : slip + 1;
end
endfunction