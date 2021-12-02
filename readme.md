# Convert OMI Host RTL to WB (+Litex) Memory Controller

* new top-level verilog for WB/CSR interfaces

* 'virtual' PHY interface for various potential usages

   * I/O can be GPIO(s) or SERDES

   * bit frequency matching with DL


## Updates

### /verilog_wb_v1

* copy all necessary rtl

* create omi_host.v


## ToDo

### /verilog_wb_2

* get rid of Fire-specific stuff (extra interfaces/logic in TL?)

* module/signal renames (host-side)

* signal resizing for 32b


### /verilog_wb_3

* buffer, credits, etc. removal for simple WB-type bus

* create wb_omi_host.v

* create litex wrapper

* init verilator tb



