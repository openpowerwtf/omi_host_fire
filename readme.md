# Convert OMI Host RTL to WB (+Litex) Memory Controller

* new top-level verilog for WB/CSR interfaces

* 'virtual' PHY interface

   * I/O can be GPIO(s) or SERDES

   * bit frequency matching with DL


## Updates

### /verilog_wb_v1

* copy all necessary rtl

* create omi_host.v

### /verilog_wb_2

* get rid of Gemini-specific stuff (GEMINI_NOT_APOLLO=0) - not much stuff

* create wb_omi_host to start connecting minimal interfaces to omi_host to execute wb rd/wr

* init verilator tb

* train link; dl/dlx yapping, woke up tl/tlx, tl are ready for host/dev owners

## ToDo

* get some packets going

### /verilog_wb_3

* module/signal renames (host-side)

* clean out modules that will never be used in this version (cmd fifo's etc. - see yosys.txt)

* create litex wrapper


