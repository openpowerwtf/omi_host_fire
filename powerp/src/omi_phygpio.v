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



//wtf
// there probably needs to be a 'sample' indicator to qualify when rx sigs should be grabbed
// what is the bit granularity of slip?
// figured out had to reset slip when going to scrambled; guess it never happens after training?

`timescale 1ns / 10ps

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
                    ((sel == 6'd60) & dat[61]) |
                    ((sel == 6'd61) & dat[61]) |
                    ((sel == 6'd62) & dat[61]) |
                    ((sel == 6'd63) & dat[63]);
   end
endfunction

function [63:0] rotl64;
   input [63:0] dat;
   input [5:0]  amt;
   begin
      assign rotl64 = (dat << amt) | (dat >> (64 - amt));
   end
endfunction

module omi_phygpio #(
        parameter GPIO_RX_TX = 512, parameter GPIO_HDR = 16,
      //parameter GPIO_RX_TX = 8,   parameter GPIO_HDR = 1,
        parameter DL_BITS = 64
)
(
        input                             clk,
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

   reg    [DL_BITS+1:0]    rx_ln0_q;
   wire   [DL_BITS+1:0]    rx_ln0_d;
   reg    [DL_BITS+1:0]    rx_ln1_q;
   wire   [DL_BITS+1:0]    rx_ln1_d;
   reg    [DL_BITS+1:0]    rx_ln2_q;
   wire   [DL_BITS+1:0]    rx_ln2_d;
   reg    [DL_BITS+1:0]    rx_ln3_q;
   wire   [DL_BITS+1:0]    rx_ln3_d;
   reg    [DL_BITS+1:0]    rx_ln4_q;
   wire   [DL_BITS+1:0]    rx_ln4_d;
   reg    [DL_BITS+1:0]    rx_ln5_q;
   wire   [DL_BITS+1:0]    rx_ln5_d;
   reg    [DL_BITS+1:0]    rx_ln6_q;
   wire   [DL_BITS+1:0]    rx_ln6_d;
   reg    [DL_BITS+1:0]    rx_ln7_q;
   wire   [DL_BITS+1:0]    rx_ln7_d;

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
   reg    [5:0]         slip_q;              // all lanes same if not async serial
   wire   [5:0]         slip_d;

   // FF DL
   always @(posedge clk) begin

      if (dlx_reset) begin
         ratio_counter_q <= 'h0;
      end else begin
         ratio_counter_q <= ratio_counter_d;
      end

      if (rst) begin
         slip_q <= 'h0;
      end else begin
         rx_ln0_q <= rx_ln0_d;
         rx_ln1_q <= rx_ln1_d;
         rx_ln2_q <= rx_ln2_d;
         rx_ln3_q <= rx_ln3_d;
         rx_ln4_q <= rx_ln4_d;
         rx_ln5_q <= rx_ln5_d;
         rx_ln6_q <= rx_ln6_d;
         rx_ln7_q <= rx_ln7_d;
         tx_ln0_q <= tx_ln0_d;
         tx_ln1_q <= tx_ln1_d;
         tx_ln2_q <= tx_ln2_d;
         tx_ln3_q <= tx_ln3_d;
         tx_ln4_q <= tx_ln4_d;
         tx_ln5_q <= tx_ln5_d;
         tx_ln6_q <= tx_ln6_d;
         tx_ln7_q <= tx_ln7_d;
         slip_q <= slip_d;
      end

   end

   // FF PHY
   always @(negedge rx_clk) begin

      if (~rst) begin
         rx_hdr_q <= rx_hdr;
         rx_dat_q <= rx_dat;
      end

   end


   if ((GPIO_RX_TX == 512) && (GPIO_HDR == 16)) begin        // direct connect for testing

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
   for (i = 63; i >= 0; i--) begin
      assign rx_ln0_d[i] = ratio_counter_q == i ? rx_dat_q[0] : rx_ln0_q[i];
   end
   for (i = 63; i >= 0; i--) begin
      assign rx_ln1_d[i] = ratio_counter_q == i ? rx_dat_q[1] : rx_ln1_q[i];
   end
   for (i = 63; i >= 0; i--) begin
      assign rx_ln2_d[i] = ratio_counter_q == i ? rx_dat_q[2] : rx_ln2_q[i];
   end
   for (i = 63; i >= 0; i--) begin
      assign rx_ln3_d[i] = ratio_counter_q == i ? rx_dat_q[3] : rx_ln3_q[i];
   end
   for (i = 63; i >= 0; i--) begin
      assign rx_ln4_d[i] = ratio_counter_q == i ? rx_dat_q[4] : rx_ln4_q[i];
   end
   for (i = 63; i >= 0; i--) begin
      assign rx_ln5_d[i] = ratio_counter_q == i ? rx_dat_q[5] : rx_ln5_q[i];
   end
   for (i = 63; i >= 0; i--) begin
      assign rx_ln6_d[i] = ratio_counter_q == i ? rx_dat_q[6] : rx_ln6_q[i];
   end
   for (i = 63; i >= 0; i--) begin
      assign rx_ln7_d[i] = ratio_counter_q == i ? rx_dat_q[7] : rx_ln7_q[i];
   end

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

   end  // GPIO_RX_TX/GPIO_HDR

   assign slip_d = phy_init ? 0 :
                   ln0_rx_slip ? slip_q +1 : slip_q;
   assign tx_clk = clk;

   // get from DL
   // do these to be qualified by counter?
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

   // send to DL
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


endmodule
