# Convert to WB OMI Host and virtual PHY

## Secret Decoder Ring for TL (discovered so far)

* GEMINI_NOT_APOLLO = 0: host
* tlx_afu = tl_host
* afu_tlx = host_tl
* vc3 = vc1
* dcp3 = dcp1

## Continue...

* remove GEMINI_NOT_APOLLO=1 logic (minor diffs)

```
./dl/ocx_dlx_rxdf.v:parameter  GEMINI_NOT_APOLLO = 0
./dl/ocx_dlx_rxdf.v:ocx_dlx_rx_main #(.GEMINI_NOT_APOLLO(GEMINI_NOT_APOLLO)) main (
./dl/ocx_dlx_tx_ctl.v:parameter GEMINI_NOT_APOLLO = 0
./dl/ocx_dlx_tx_ctl.v:      if (GEMINI_NOT_APOLLO == 1) begin
./dl/ocx_dlx_tx_ctl.v:                                         dl_deskew_version,  //--13:8  (version number, Gemini Sends x8)
./dl/ocx_dlx_rx_main.v:parameter  GEMINI_NOT_APOLLO = 0
./dl/ocx_dlx_rx_main.v:  if (GEMINI_NOT_APOLLO == 0) begin
./dl/ocx_dlx_top.v:parameter  GEMINI_NOT_APOLLO = 0
./dl/ocx_dlx_top.v:ocx_dlx_rxdf #(.GEMINI_NOT_APOLLO(GEMINI_NOT_APOLLO)) rx (
./dl/ocx_dlx_top.v:ocx_dlx_txdf #(.GEMINI_NOT_APOLLO(GEMINI_NOT_APOLLO)) tx (
./dl/ocx_dlx_txdf.v:parameter GEMINI_NOT_APOLLO = 0
./dl/ocx_dlx_txdf.v:ocx_dlx_tx_ctl #(.GEMINI_NOT_APOLLO(GEMINI_NOT_APOLLO)) ctl (
```

* create wb_omi_host.v

```
verilator --lint-only -Wno-fatal -Wno-Litendian -I./dl -I./tl  omi_host.v >& verilator.txt
yosys synth.ys > yosys.txt

verilator --lint-only -Wno-fatal -Wno-Litendian -I./dl -I./tl  wb_omi_host.v >& verilator.txt
yosys synth_wb.ys > yosys.txt

```


### What is required for a minimal implementation?

* From OC 3.1 Spec:

   * 64b address

   * TL cmds: config_read, config_write, nop, pr_rd_mem, pr_wr_mem, rd_mem, rd_pf, write_mem, write_mem.be

   * TLx cmds: assign_actag, intrp_req, intrp_req.d, nop

   * TL rsps: nop, return_tlx_credits

   * TLx rsps: mem_rd_fail, mem_rd_response, mem_wr_fail, mem_wr_response, nop, return_tl_credits

* A simple implementation would require:

   * TL cmds: nop, pr_rd_mem, pr_wr_mem (supports 1,2,4 B, but NO be, and also 32B)/write_mem.be (be, but requires 64B)

      * pr_wr_mem: there's tons of room in it because of 64b address; i assume it's not illegal to use the upper bits for my
        own purposes; then can put the be there and not break up 4B writes when noncontiguous bytes written; spec only yells at you
        if you use capptag bits illicitly; so could always send pr_wr_mem 4B, with pa(63:60)=be

   * TLx cmds: nop

   * TL rsps: nop, return_tlx_credits

   * TLx rsps: mem_rd_fail, mem_rd_response, mem_wr_fail, mem_wr_response, nop, return_tl_credits



