
// 1 slip bit; do the slip like a real phy
// add 'done' output for dl related to phy_init
// do bit ordering on 'wire' like spec says (h0,h1,do..d63)

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
// xil ug471 (v1.10), bitslip submodule
// reorders the sequence of parallel data going into fpga fabric
// p 159: bitslip is NOT a barrel shift, though it looks like one in repeating pattern; it adds one bit to the input
//        data stream and loses the nth bit
// so i think this means you need to have extra bits; you are doing a true align
// but i could also avoid this by using a start bit; then i automatically align tx->rx regardless of reset timing, etc.

`timescale 1ns / 10ps


`define SLIP_BITS 66

module omi_phygpio #(
        parameter GPIO_RX_TX = 512, parameter GPIO_HDR = 16,
        //parameter GPIO_RX_TX = 8,  parameter GPIO_HDR = 1,
        parameter GPIO_SYNC = 1,
        parameter DL_BITS = 64,
        parameter SLIP_BITS = `SLIP_BITS
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
        input   [GPIO_HDR-1:0]            rx_hdr,  // if separate hdr bits
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
   reg                     rx_ln0_val_dl_q;
   wire                    rx_ln0_val_dl_d;
   reg    [DL_BITS+1:0]    rx_ln0_dl_q;
   wire   [DL_BITS+1:0]    rx_ln0_dl_d;
   reg                     rx_ln1_val_dl_q;
   wire                    rx_ln1_val_dl_d;
   reg    [DL_BITS+1:0]    rx_ln1_dl_q;
   wire   [DL_BITS+1:0]    rx_ln1_dl_d;
   reg                     rx_ln2_val_dl_q;
   wire                    rx_ln2_val_dl_d;
   reg    [DL_BITS+1:0]    rx_ln2_dl_q;
   wire   [DL_BITS+1:0]    rx_ln2_dl_d;
   reg                     rx_ln3_val_dl_q;
   wire                    rx_ln3_val_dl_d;
   reg    [DL_BITS+1:0]    rx_ln3_dl_q;
   wire   [DL_BITS+1:0]    rx_ln3_dl_d;
   reg                     rx_ln4_val_dl_q;
   wire                    rx_ln4_val_dl_d;
   reg    [DL_BITS+1:0]    rx_ln4_dl_q;
   wire   [DL_BITS+1:0]    rx_ln4_dl_d;
   reg                     rx_ln5_val_dl_q;
   wire                    rx_ln5_val_dl_d;
   reg    [DL_BITS+1:0]    rx_ln5_dl_q;
   wire   [DL_BITS+1:0]    rx_ln5_dl_d;
   reg                     rx_ln6_val_dl_q;
   wire                    rx_ln6_val_dl_d;
   reg    [DL_BITS+1:0]    rx_ln6_dl_q;
   wire   [DL_BITS+1:0]    rx_ln6_dl_d;
   reg                     rx_ln7_val_dl_q;
   wire                    rx_ln7_val_dl_d;
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
   wire   [9:0]         ratio_max;

// try individuals to see if gets sync'ed lfsr
   reg    [7:0]         bits_0_q;
   wire   [7:0]         bits_0_d;
   reg    [7:0]         bits_1_q;
   wire   [7:0]         bits_1_d;
   reg    [7:0]         bits_2_q;
   wire   [7:0]         bits_2_d;
   reg    [7:0]         bits_3_q;
   wire   [7:0]         bits_3_d;
   reg    [7:0]         bits_4_q;
   wire   [7:0]         bits_4_d;
   reg    [7:0]         bits_5_q;
   wire   [7:0]         bits_5_d;
   reg    [7:0]         bits_6_q;
   wire   [7:0]         bits_6_d;
   reg    [7:0]         bits_7_q;
   wire   [7:0]         bits_7_d;
   reg                  phy_init_q;
   wire                 phy_init_d;
   reg                  sync_dl_0_q;
   wire                 sync_dl_0_d;
   reg                  sync_dl_1_q;
   wire                 sync_dl_1_d;
   reg                  synced_dl_q;
   wire                 synced_dl_d;
   wire                 sync_dl;
   wire                 data_cycle;
   wire                 bits_low_0;
   wire                 bits_low_slip_0;
   wire                 bits_low_1;
   wire                 bits_low_slip_1;
   wire                 bits_low_2;
   wire                 bits_low_slip_2;
   wire                 bits_low_3;
   wire                 bits_low_slip_3;
   wire                 bits_low_4;
   wire                 bits_low_slip_4;
   wire                 bits_low_5;
   wire                 bits_low_slip_5;
   wire                 bits_low_6;
   wire                 bits_low_slip_6;
   wire                 bits_low_7;
   wire                 bits_low_slip_7;
   wire [DL_BITS+1:0]   rx_ln0_slip;
   wire [DL_BITS+1:0]   rx_ln1_slip;
   wire [DL_BITS+1:0]   rx_ln2_slip;
   wire [DL_BITS+1:0]   rx_ln3_slip;
   wire [DL_BITS+1:0]   rx_ln4_slip;
   wire [DL_BITS+1:0]   rx_ln5_slip;
   wire [DL_BITS+1:0]   rx_ln6_slip;
   wire [DL_BITS+1:0]   rx_ln7_slip;

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
         bits_0_q <= bits_0_d;
         bits_1_q <= bits_1_d;
         bits_2_q <= bits_2_d;
         bits_3_q <= bits_3_d;
         bits_4_q <= bits_4_d;
         bits_5_q <= bits_5_d;
         bits_6_q <= bits_6_d;
         bits_7_q <= bits_7_d;
      end

   end

   // FF DL
   always @(posedge clk_dl) begin
      integer i;

      if (rst) begin  //wtf dont need dlx_reset or phy_init?
         sync_dl_0_q <= 'b0;
         sync_dl_1_q <= 'b0;
         synced_dl_q <= 'b0;
         rx_ln0_val_dl_q <= 'b0;
         rx_ln1_val_dl_q <= 'b0;
         rx_ln2_val_dl_q <= 'b0;
         rx_ln3_val_dl_q <= 'b0;
         rx_ln4_val_dl_q <= 'b0;
         rx_ln5_val_dl_q <= 'b0;
         rx_ln6_val_dl_q <= 'b0;
         rx_ln7_val_dl_q <= 'b0;
      end else begin
         sync_dl_0_q <= sync_dl_0_d;
         sync_dl_1_q <= sync_dl_1_d;
         synced_dl_q <= synced_dl_d;
         rx_ln0_val_dl_q <= rx_ln0_val_dl_d;
         rx_ln1_val_dl_q <= rx_ln1_val_dl_d;
         rx_ln2_val_dl_q <= rx_ln2_val_dl_d;
         rx_ln3_val_dl_q <= rx_ln3_val_dl_d;
         rx_ln4_val_dl_q <= rx_ln4_val_dl_d;
         rx_ln5_val_dl_q <= rx_ln5_val_dl_d;
         rx_ln6_val_dl_q <= rx_ln6_val_dl_d;
         rx_ln7_val_dl_q <= rx_ln7_val_dl_d;
         rx_ln0_dl_q <= rx_ln0_dl_d;
         rx_ln1_dl_q <= rx_ln1_dl_d;
         rx_ln2_dl_q <= rx_ln2_dl_d;
         rx_ln3_dl_q <= rx_ln3_dl_d;
         rx_ln4_dl_q <= rx_ln4_dl_d;
         rx_ln5_dl_q <= rx_ln5_dl_d;
         rx_ln6_dl_q <= rx_ln6_dl_d;
         rx_ln7_dl_q <= rx_ln7_dl_d;
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

   // FF PHY
   always @(negedge rx_clk) begin

      if (rst) begin
      end else  begin
         rx_hdr_q <= rx_hdr;
         rx_dat_q <= rx_dat;
      end

   end


//----- 66 BIT MUX -----------------------------------------------------------------------------------------------------

if ((GPIO_RX_TX == 8) && (GPIO_HDR == 0)) begin

   assign ratio_max = 65;

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

   // Deserializer - hdr+data on lanes 0:7

   // there will be 66 'new' bits arriving if rxvalid=0;  worst-case is 66 'old' bits plus 66 'new' bits, to
   //  not drop any bits before next send to dl
   //
   // when ratio_counter=0 (data cycle that will be latched by dl):
   // 1. clk_dl data reg latches either:
   //    66 normal bits, rxval=1       - slip=0; bitcount -= 66 + 1 arriving
   //    66 slipped bits, rxval=1      - slip=1 and bitcount > 66; bitcount -= 66 + 1 arriving
   //    invalid bits caused by slip, rxval=0  - slip=1 and bitcount < 67; bitcount += 1
   //    invalid bits, rxval=0         - slip=1 and bitcount < 66; bitcount += 1

   // bits_n_q is the number of valid bits (rcvd but not taken by dl); there is one more arriving this cycle, and
   //  66 (slip=0) or 67 (slip=1) are removed in data cycle
   // arriving bit shifts in from the right (left shift)
   // bits clocked by clk_dl are [bits_n_q-1: bits_n_q-66] (no slip) or [bits_n_q-2: bits_n_q-67] (slip), if sufficient bits
   // if not sufficient bits, rxval=0 and 66 more bits will be added before next dl data cycle
   //
   // 66 bits, slip=1: need 67, so rxval=0; new count is 66;

   assign phy_init_d = phy_init;
   assign data_cycle = ratio_counter_q == 0;

   assign bits_low_0 = bits_0_q < 66;
   assign bits_low_slip_0 = bits_0_q < 67;
   assign bits_0_d = ~synced_dl_q | phy_init_q                    ? 0 :
                     data_cycle & ~ln0_rx_slip & ~bits_low_0      ? bits_0_q - 66 + 1 :     // no slip, got bits
                     data_cycle & ~ln0_rx_slip                    ? incbits(bits_0_q) :     // no slip, no bits
                     data_cycle & ln0_rx_slip & ~bits_low_slip_0  ? bits_0_q - 67 + 1 :     // slip, got bits
                     data_cycle & ln0_rx_slip                     ? bits_0_q - 1 + 1  :     // slip, no bits
                                                                    incbits(bits_0_q);      // not data cycle

   assign bits_low_1 = bits_1_q < 66;
   assign bits_low_slip_1 = bits_1_q < 67;
   assign bits_1_d = ~synced_dl_q | phy_init_q                    ? 0 :
                     data_cycle & ~ln1_rx_slip & ~bits_low_1      ? bits_1_q - 66 + 1 :     // no slip, got bits
                     data_cycle & ~ln1_rx_slip                    ? incbits(bits_1_q) :     // no slip, no bits
                     data_cycle & ln1_rx_slip & ~bits_low_slip_1  ? bits_1_q - 67 + 1 :     // slip, got bits
                     data_cycle & ln1_rx_slip                     ? bits_1_q - 1 + 1  :     // slip, no bits
                                                                    incbits(bits_1_q);      // not data cycle
   assign bits_low_2 = bits_2_q < 66;
   assign bits_low_slip_2 = bits_2_q < 67;
   assign bits_2_d = ~synced_dl_q | phy_init_q                    ? 0 :
                     data_cycle & ~ln2_rx_slip & ~bits_low_2      ? bits_2_q - 66 + 1 :     // no slip, got bits
                     data_cycle & ~ln2_rx_slip                    ? incbits(bits_2_q) :     // no slip, no bits
                     data_cycle & ln2_rx_slip & ~bits_low_slip_2  ? bits_2_q - 67 + 1 :     // slip, got bits
                     data_cycle & ln2_rx_slip                     ? bits_2_q - 1 + 1  :     // slip, no bits
                                                                    incbits(bits_2_q);      // not data cycle
   assign bits_low_3 = bits_3_q < 66;
   assign bits_low_slip_3 = bits_3_q < 67;
   assign bits_3_d = ~synced_dl_q | phy_init_q                    ? 0 :
                     data_cycle & ~ln3_rx_slip & ~bits_low_3      ? bits_3_q - 66 + 1 :     // no slip, got bits
                     data_cycle & ~ln3_rx_slip                    ? incbits(bits_3_q) :     // no slip, no bits
                     data_cycle & ln3_rx_slip & ~bits_low_slip_3  ? bits_3_q - 67 + 1 :     // slip, got bits
                     data_cycle & ln3_rx_slip                     ? bits_3_q - 1 + 1  :     // slip, no bits
                                                                    incbits(bits_3_q);      // not data cycle
   assign bits_low_4 = bits_4_q < 66;
   assign bits_low_slip_4 = bits_4_q < 67;
   assign bits_4_d = ~synced_dl_q | phy_init_q                    ? 0 :
                     data_cycle & ~ln4_rx_slip & ~bits_low_4      ? bits_4_q - 66 + 1 :     // no slip, got bits
                     data_cycle & ~ln4_rx_slip                    ? incbits(bits_4_q) :     // no slip, no bits
                     data_cycle & ln4_rx_slip & ~bits_low_slip_4  ? bits_4_q - 67 + 1 :     // slip, got bits
                     data_cycle & ln4_rx_slip                     ? bits_4_q - 1 + 1  :     // slip, no bits
                                                                    incbits(bits_4_q);      // not data cycle
   assign bits_low_5 = bits_5_q < 66;
   assign bits_low_slip_5 = bits_5_q < 67;
   assign bits_5_d = ~synced_dl_q | phy_init_q                    ? 0 :
                     data_cycle & ~ln5_rx_slip & ~bits_low_5      ? bits_5_q - 66 + 1 :     // no slip, got bits
                     data_cycle & ~ln5_rx_slip                    ? incbits(bits_5_q) :     // no slip, no bits
                     data_cycle & ln5_rx_slip & ~bits_low_slip_5  ? bits_5_q - 67 + 1 :     // slip, got bits
                     data_cycle & ln5_rx_slip                     ? bits_5_q - 1 + 1  :     // slip, no bits
                                                                    incbits(bits_5_q);      // not data cycle
   assign bits_low_6 = bits_6_q < 66;
   assign bits_low_slip_6 = bits_6_q < 67;
   assign bits_6_d = ~synced_dl_q | phy_init_q                    ? 0 :
                     data_cycle & ~ln6_rx_slip & ~bits_low_6      ? bits_6_q - 66 + 1 :     // no slip, got bits
                     data_cycle & ~ln6_rx_slip                    ? incbits(bits_6_q) :     // no slip, no bits
                     data_cycle & ln6_rx_slip & ~bits_low_slip_6  ? bits_6_q - 67 + 1 :     // slip, got bits
                     data_cycle & ln6_rx_slip                     ? bits_6_q - 1 + 1  :     // slip, no bits
                                                                    incbits(bits_6_q);      // not data cycle
   assign bits_low_7 = bits_7_q < 66;
   assign bits_low_slip_7 = bits_7_q < 67;
   assign bits_7_d = ~synced_dl_q | phy_init_q                    ? 0 :
                     data_cycle & ~ln7_rx_slip & ~bits_low_7      ? bits_7_q - 66 + 1 :     // no slip, got bits
                     data_cycle & ~ln7_rx_slip                    ? incbits(bits_7_q) :     // no slip, no bits
                     data_cycle & ln7_rx_slip & ~bits_low_slip_7  ? bits_7_q - 67 + 1 :     // slip, got bits
                     data_cycle & ln7_rx_slip                     ? bits_7_q - 1 + 1  :     // slip, no bits
                                                                    incbits(bits_7_q);      // not data cycle
   always @(*) begin
   if (bits_0_d == 132) begin
      $display("%0t: PHY bit overrun! Lane 0 %d bits exceeded.", $time, 132);
      $stop;
   end
   if (bits_1_d == 132) begin
      $display("%0t: PHY bit overrun! Lane 1 %d bits exceeded.", $time, 132);
      $stop;
   end
   if (bits_2_d == 132) begin
      $display("%0t: PHY bit overrun! Lane 2 %d bits exceeded.", $time, 132);
      $stop;
   end
   if (bits_3_d == 132) begin
      $display("%0t: PHY bit overrun! Lane 3 %d bits exceeded.", $time, 132);
      $stop;
   end
   if (bits_4_d == 132) begin
      $display("%0t: PHY bit overrun! Lane 4 %d bits exceeded.", $time, 132);
      $stop;
   end
   if (bits_5_d == 132) begin
      $display("%0t: PHY bit overrun! Lane 5 %d bits exceeded.", $time, 132);
      $stop;
   end
   if (bits_6_d == 132) begin
      $display("%0t: PHY bit overrun! Lane 6 %d bits exceeded.", $time, 132);
      $stop;
   end
   if (bits_7_d == 132) begin
      $display("%0t: PHY bit overrun! Lane 7 %d bits exceeded.", $time, 132);
      $stop;
   end
   end


   // get data bits

   assign rx_ln0_d = (rx_ln0_q << 1) | rx_dat_q[0];
   assign rx_ln1_d = (rx_ln1_q << 1) | rx_dat_q[1];
   assign rx_ln2_d = (rx_ln2_q << 1) | rx_dat_q[2];
   assign rx_ln3_d = (rx_ln3_q << 1) | rx_dat_q[3];
   assign rx_ln4_d = (rx_ln4_q << 1) | rx_dat_q[4];
   assign rx_ln5_d = (rx_ln5_q << 1) | rx_dat_q[5];
   assign rx_ln6_d = (rx_ln6_q << 1) | rx_dat_q[6];
   assign rx_ln7_d = (rx_ln7_q << 1) | rx_dat_q[7];

   assign data_avail_0 = ~bits_low_0 & ~(ln0_rx_slip & bits_low_slip_0);
   assign data_avail_1 = ~bits_low_1 & ~(ln1_rx_slip & bits_low_slip_1);
   assign data_avail_2 = ~bits_low_2 & ~(ln2_rx_slip & bits_low_slip_2);
   assign data_avail_3 = ~bits_low_3 & ~(ln3_rx_slip & bits_low_slip_3);
   assign data_avail_4 = ~bits_low_4 & ~(ln4_rx_slip & bits_low_slip_4);
   assign data_avail_5 = ~bits_low_5 & ~(ln5_rx_slip & bits_low_slip_5);
   assign data_avail_6 = ~bits_low_6 & ~(ln6_rx_slip & bits_low_slip_6);
   assign data_avail_7 = ~bits_low_7 & ~(ln7_rx_slip & bits_low_slip_7);

   assign tx_clk = clk;

   // get from DL
   /* version 1 - sends h,d, but bit 0 last */
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

   /* version 1 */

   assign rx_ln0_val_dl_d = data_avail_0;
   assign rx_ln1_val_dl_d = data_avail_1;
   assign rx_ln2_val_dl_d = data_avail_2;
   assign rx_ln3_val_dl_d = data_avail_3;
   assign rx_ln4_val_dl_d = data_avail_4;
   assign rx_ln5_val_dl_d = data_avail_5;
   assign rx_ln6_val_dl_d = data_avail_6;
   assign rx_ln7_val_dl_d = data_avail_7;

   assign rx_ln0_slip = bitextract(rx_ln0_q, bits_0_q, ln0_rx_slip);
   assign rx_ln1_slip = bitextract(rx_ln1_q, bits_1_q, ln1_rx_slip);
   assign rx_ln2_slip = bitextract(rx_ln2_q, bits_2_q, ln2_rx_slip);
   assign rx_ln3_slip = bitextract(rx_ln3_q, bits_3_q, ln3_rx_slip);
   assign rx_ln4_slip = bitextract(rx_ln4_q, bits_4_q, ln4_rx_slip);
   assign rx_ln5_slip = bitextract(rx_ln5_q, bits_5_q, ln5_rx_slip);
   assign rx_ln6_slip = bitextract(rx_ln6_q, bits_6_q, ln6_rx_slip);
   assign rx_ln7_slip = bitextract(rx_ln7_q, bits_7_q, ln7_rx_slip);

   // clk_dl latch data
   assign rx_ln0_dl_d = rx_ln0_slip;
   assign rx_ln1_dl_d = rx_ln1_slip;
   assign rx_ln2_dl_d = rx_ln2_slip;
   assign rx_ln3_dl_d = rx_ln3_slip;
   assign rx_ln4_dl_d = rx_ln4_slip;
   assign rx_ln5_dl_d = rx_ln5_slip;
   assign rx_ln6_dl_d = rx_ln6_slip;
   assign rx_ln7_dl_d = rx_ln7_slip;

   // to dl
   assign ln0_rx_valid = rx_ln0_val_dl_q;
   assign ln0_rx_header = rx_ln0_dl_q[65:64];
   assign ln0_rx_data = rx_ln0_dl_q[63:0];
   assign ln1_rx_valid = rx_ln1_val_dl_q;
   assign ln1_rx_header = rx_ln1_dl_q[65:64];
   assign ln1_rx_data = rx_ln1_dl_q[63:0];
   assign ln2_rx_valid = rx_ln2_val_dl_q;
   assign ln2_rx_header = rx_ln2_dl_q[65:64];
   assign ln2_rx_data = rx_ln2_dl_q[63:0];
   assign ln3_rx_valid = rx_ln3_val_dl_q;
   assign ln3_rx_header = rx_ln3_dl_q[65:64];
   assign ln3_rx_data = rx_ln3_dl_q[63:0];
   assign ln4_rx_valid = rx_ln4_val_dl_q;
   assign ln4_rx_header = rx_ln4_dl_q[65:64];
   assign ln4_rx_data = rx_ln4_dl_q[63:0];
   assign ln5_rx_valid = rx_ln5_val_dl_q;
   assign ln5_rx_header = rx_ln5_dl_q[65:64];
   assign ln5_rx_data = rx_ln5_dl_q[63:0];
   assign ln6_rx_valid = rx_ln6_val_dl_q;
   assign ln6_rx_header = rx_ln6_dl_q[65:64];
   assign ln6_rx_data = rx_ln6_dl_q[63:0];
   assign ln7_rx_valid = rx_ln7_val_dl_q;
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

// select the next 66 bits to deliver to dl
// slip=1 causes the leading bit to be dropped
function [65:0] bitextract;
   input [65+`SLIP_BITS:0]  dat;
   input [7:0]                   amt;
   input                         slip;
   begin
      if (slip) amt = amt - 1;
      case (amt)
         'd132 : assign bitextract = dat[131:66];
         'd131 : assign bitextract = dat[130:65];
         'd130 : assign bitextract = dat[129:64];
         'd129 : assign bitextract = dat[128:63];
         'd128 : assign bitextract = dat[127:62];
         'd127 : assign bitextract = dat[126:61];
         'd126 : assign bitextract = dat[125:60];
         'd125 : assign bitextract = dat[124:59];
         'd124 : assign bitextract = dat[123:58];
         'd123 : assign bitextract = dat[122:57];
         'd122 : assign bitextract = dat[121:56];
         'd121 : assign bitextract = dat[120:55];
         'd120 : assign bitextract = dat[119:54];
         'd119 : assign bitextract = dat[118:53];
         'd118 : assign bitextract = dat[117:52];
         'd117 : assign bitextract = dat[116:51];
         'd116 : assign bitextract = dat[115:50];
         'd115 : assign bitextract = dat[114:49];
         'd114 : assign bitextract = dat[113:48];
         'd113 : assign bitextract = dat[112:47];
         'd112 : assign bitextract = dat[111:46];
         'd111 : assign bitextract = dat[110:45];
         'd110 : assign bitextract = dat[109:44];
         'd109 : assign bitextract = dat[108:43];
         'd108 : assign bitextract = dat[107:42];
         'd107 : assign bitextract = dat[106:41];
         'd106 : assign bitextract = dat[105:40];
         'd105 : assign bitextract = dat[104:39];
         'd104 : assign bitextract = dat[103:38];
         'd103 : assign bitextract = dat[102:37];
         'd102 : assign bitextract = dat[101:36];
         'd101 : assign bitextract = dat[100:35];
         'd100 : assign bitextract = dat[ 99:34];
         'd099 : assign bitextract = dat[ 98:33];
         'd098 : assign bitextract = dat[ 97:32];
         'd097 : assign bitextract = dat[ 96:31];
         'd096 : assign bitextract = dat[ 95:30];
         'd095 : assign bitextract = dat[ 94:29];
         'd094 : assign bitextract = dat[ 93:28];
         'd093 : assign bitextract = dat[ 92:27];
         'd092 : assign bitextract = dat[ 91:26];
         'd091 : assign bitextract = dat[ 90:25];
         'd090 : assign bitextract = dat[ 89:24];
         'd089 : assign bitextract = dat[ 88:23];
         'd088 : assign bitextract = dat[ 87:22];
         'd087 : assign bitextract = dat[ 86:21];
         'd086 : assign bitextract = dat[ 85:20];
         'd085 : assign bitextract = dat[ 84:19];
         'd084 : assign bitextract = dat[ 83:18];
         'd083 : assign bitextract = dat[ 82:17];
         'd082 : assign bitextract = dat[ 81:16];
         'd081 : assign bitextract = dat[ 80:15];
         'd080 : assign bitextract = dat[ 79:14];
         'd079 : assign bitextract = dat[ 78:13];
         'd078 : assign bitextract = dat[ 77:12];
         'd077 : assign bitextract = dat[ 76:11];
         'd076 : assign bitextract = dat[ 75:10];
         'd075 : assign bitextract = dat[ 74:09];
         'd074 : assign bitextract = dat[ 73:08];
         'd073 : assign bitextract = dat[ 72:07];
         'd072 : assign bitextract = dat[ 71:06];
         'd071 : assign bitextract = dat[ 70:05];
         'd070 : assign bitextract = dat[ 69:04];
         'd069 : assign bitextract = dat[ 68:03];
         'd068 : assign bitextract = dat[ 67:02];
         'd067 : assign bitextract = dat[ 66:01];
         'd066 : assign bitextract = dat[ 65:00];
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

`define MAXBITS 66+`SLIP_BITS
function [7:0] incbits;
input [7:0] bits;
begin
   //wtf think it is getting called even though not selected as next value; at least check if it's already too big
   if (bits == 132) begin
      $display("%0t: PHY bit overrun! %d bits exceeded.", $time, bits);
      //$stop; 23700 dev
   end
   assign incbits = bits + 1;
end
endfunction