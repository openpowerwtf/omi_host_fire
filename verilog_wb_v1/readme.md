# Convert to WB OMI Host and virtual PHY

* peel away a single OMI host stack (TL+DL)

* vhdl/ocx_tlx_wrap.vhdl is above ocx_tlx_top; it doesn't include dl:

```
    ---------------------------------------------------------------------------
    -- DLX to TLX Parser Interface
    ---------------------------------------------------------------------------
    dlx_tlx_flit_valid   : in std_ulogic;
    dlx_tlx_flit         : in std_ulogic_vector(511 downto 0);
    dlx_tlx_flit_crc_err : in std_ulogic;
    dlx_tlx_link_up      : in std_ulogic;

    -----------------------------------------------------------------------
    -- TLX Framer to DLX Interface
    -----------------------------------------------------------------------
    dlx_tlx_init_flit_depth : in  std_ulogic_vector(2 downto 0);
    dlx_tlx_flit_credit     : in  std_ulogic;
    tlx_dlx_flit_valid      : out std_ulogic;
    tlx_dlx_flit            : out std_ulogic_vector(511 downto 0);
    tlx_dlx_debug_encode    : out std_ulogic_vector(3 downto 0);
    tlx_dlx_debug_info      : out std_ulogic_vector(31 downto 0);
    dlx_tlx_dlx_config_info : in  std_ulogic_vector(31 downto 0);
```

###  ocx_tlx_top.v

```
verilator --lint-only ocx_tlx_top.v -Wno-fatal
%Warning-UNSIGNED: ocx_tlx_framer.v:1919:104: Comparison is constant due to unsigned arithmetic
                                            : ... In instance ocx_tlx_top.OCX_TLX_FRAMER
 1919 |     assign  there_are_enough_dcp0_credits  =   (vc0_dsegs_lookahead == 2'b00)  ?  (dcp0_tlxcrd_counter >= 16'h0000)  :
      |                                                                                                        ^~
                   ocx_tlx_top.v:537:1: ... note: In file included from ocx_tlx_top.v
                   ... For warning description see https://verilator.org/warn/UNSIGNED?v=4.215
                   ... Use "/* verilator lint_off UNSIGNED */" and lint_on around source to disable this message.
%Warning-UNSIGNED: ocx_tlx_framer.v:1923:104: Comparison is constant due to unsigned arithmetic
                                            : ... In instance ocx_tlx_top.OCX_TLX_FRAMER
 1923 |     assign  there_are_enough_dcp3_credits  =   (vc3_dsegs_lookahead == 2'b00)  ?  (dcp3_tlxcrd_counter >= 16'h0000)  :
      |                                                                                                        ^~
                   ocx_tlx_top.v:537:1: ... note: In file included from ocx_tlx_top.v
%Warning-CASEOVERLAP: ocx_tlx_parser_err_mac.v:136:18: Case values overlap (example pattern 0x8)
  136 |                  8'h08: err_resv_opcode_reg <= 1'b0;
      |                  ^~~~~
                      ocx_tlx_rcv_top.v:283:1: ... note: In file included from ocx_tlx_rcv_top.v
                      ocx_tlx_top.v:420:1: ... note: In file included from ocx_tlx_top.v
%Warning-CASEX: ocx_tlx_framer.v:1338:9: Suggest casez (with ?'s) in place of casex (with X's)
 1338 |         casex (afu_reg_cmd_opcode)
      |         ^~~~~
                ocx_tlx_top.v:537:1: ... note: In file included from ocx_tlx_top.v
%Warning-CASEX: ocx_tlx_framer.v:3421:9: Suggest casez (with ?'s) in place of casex (with X's)
 3421 |         casex (detected_error_vector)
      |         ^~~~~
                ocx_tlx_top.v:537:1: ... note: In file included from ocx_tlx_top.v
%Error-BLKLOOPINIT: ocx_tlx_bdi_mac.v:131:28: Unsupported: Delayed assignment to array inside for loops (non-delayed is ok - see docs)
  131 |             vc1_bdi_reg[j] <= 1'b0;
      |                            ^~
                    ocx_tlx_data_fifo_mac.v:234:1: ... note: In file included from ocx_tlx_data_fifo_mac.v
                    ocx_tlx_rcv_mac.v:209:1: ... note: In file included from ocx_tlx_rcv_mac.v
                    ocx_tlx_rcv_top.v:194:1: ... note: In file included from ocx_tlx_rcv_top.v
                    ocx_tlx_top.v:420:1: ... note: In file included from ocx_tlx_top.v
%Error-BLKLOOPINIT: ocx_tlx_bdi_mac.v:136:28: Unsupported: Delayed assignment to array inside for loops (non-delayed is ok - see docs)
  136 |             vc0_bdi_reg[i] <= 1'b0;
      |                            ^~
                    ocx_tlx_data_fifo_mac.v:234:1: ... note: In file included from ocx_tlx_data_fifo_mac.v
                    ocx_tlx_rcv_mac.v:209:1: ... note: In file included from ocx_tlx_rcv_mac.v
                    ocx_tlx_rcv_top.v:194:1: ... note: In file included from ocx_tlx_rcv_top.v
                    ocx_tlx_top.v:420:1: ... note: In file included from ocx_tlx_top.v
%Error: Exiting due to 2 error(s)
```

* comment out the error lines for now

## ocx_dlx_top

```
verilator --lint-only ocx_dlx_top.v -Wno-fatal -Wno-Litendian
%Warning-IMPLICIT: ocx_dlx_tx_flt.v:950:8: Signal definition not found, creating implicitly: 'fsm_rpl_start'
  950 | assign fsm_rpl_start = o[0];
      |        ^~~~~~~~~~~~~
                   ocx_dlx_txdf.v:405:1: ... note: In file included from ocx_dlx_txdf.v
                   ocx_dlx_top.v:437:1: ... note: In file included from ocx_dlx_top.v
                   ... For warning description see https://verilator.org/warn/IMPLICIT?v=4.215
                   ... Use "/* verilator lint_off IMPLICIT */" and lint_on around source to disable this message.
%Warning-IMPLICIT: ocx_dlx_rx_lane.v:871:8: Signal definition not found, creating implicitly: 'EDPL_pchk'
  871 | assign EDPL_pchk = ~(^{deskew_sync_hdr_q[1:0],chk_data_q[63:0]});
      |        ^~~~~~~~~
                   ocx_dlx_rxdf.v:424:1: ... note: In file included from ocx_dlx_rxdf.v
                   ocx_dlx_top.v:353:1: ... note: In file included from ocx_dlx_top.v
%Warning-WIDTH: ocx_dlx_tx_flt.v:756:40: Operator COND expects 12 bits on the Conditional True, but Conditional True's CONST '7'h0' generates 7 bits.
                                       : ... In instance ocx_dlx_top.tx.flt
  756 | assign rx_ack_ptr_din[11:0] = reset_q  ? 7'b0000000:
      |                                        ^
                ocx_dlx_txdf.v:405:1: ... note: In file included from ocx_dlx_txdf.v
                ocx_dlx_top.v:437:1: ... note: In file included from ocx_dlx_top.v
%Warning-WIDTH: ocx_dlx_tx_flt.v:781:52: Operator COND expects 12 bits on the Conditional True, but Conditional True's CONST '7'h0' generates 7 bits.
                                       : ... In instance ocx_dlx_top.tx.flt
  781 | assign tx_ack_ptr_din[11:0] = reset_q              ? 7'b0000000:
      |                                                    ^
                ocx_dlx_txdf.v:405:1: ... note: In file included from ocx_dlx_txdf.v
                ocx_dlx_top.v:437:1: ... note: In file included from ocx_dlx_top.v
%Warning-WIDTH: ocx_dlx_rx_main.v:480:28: Operator ASSIGNW expects 1 bits on the Assign RHS, but Assign RHS's CONST '2'h0' generates 2 bits.
                                        : ... In instance ocx_dlx_top.rx.main
  480 | assign x2_inside_write[2]  = 2'b0;
      |                            ^
                ocx_dlx_rxdf.v:342:1: ... note: In file included from ocx_dlx_rxdf.v
                ocx_dlx_top.v:353:1: ... note: In file included from ocx_dlx_top.v
%Warning-WIDTH: ocx_dlx_top.v:347:22: Operator ASSIGNW expects 32 bits on the Assign RHS, but Assign RHS's SEL generates 8 bits.
                                    : ... In instance ocx_dlx_top
  347 | assign reg_07_update = reg_EDPL_error[7:0];
```

## create wb_omi_host

```
verilator --lint-only -Wno-fatal -Wno-Litendian -I./dl -I./tl  omi_host.v >& verilator.txt
```

```
yosys synth.ys > yosys.txt

# check these...
#Removing unused module `\ocx_dlx_txdf'.
#Removing unused module `\ocx_dlx_tx_ctl'.
#Removing unused module `\ocx_dlx_rxdf'.
#Removing unused module `\ocx_dlx_rx_main'.
#Removing unused module `\ocx_tlx_vc1_fifo_ctl'.
#Removing unused module `\ocx_tlx_vc0_fifo_ctl'.
#Removing unused module `\ocx_tlx_resp_fifo_mac'.
#Removing unused module `\ocx_tlx_fifo_cntlr'.
#Removing unused module `\ocx_tlx_dcp_fifo_ctl'.
#Removing unused module `\ocx_tlx_data_fifo_mac'.
#Removing unused module `\ocx_tlx_cmd_fifo_mac'.
#Removing unused module `\ocx_tlx_cfg_mac'.
#Removing unused module `\ocx_tlx_bdi_mac'.
#Removing unused module `\ocx_leaf_inferd_regfile'.
#Removing unused module `\dram_syn_test'.
#Removing unused module `\bram_syn_test'.

```
