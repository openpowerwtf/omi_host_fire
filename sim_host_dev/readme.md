# Sim

* add remote DL to new top and try to train

```
verilator --cc --exe --trace -Wno-fatal -Wno-Litendian -Isrc -I./src/dl -I./src/tl top.v tb.cpp

cd obj_dir;make -f Vtop.mk;cd ..
obj_dir/Vtop

gtkwave wtf.vcd wtf.gtkw

# optional - looks like it creats 'aet'-like file, which is wayyy smaller
#-rw-rw-r--  1 wtf wtf    6000182 Dec  6 17:54 wtf.fst
#-rw-rw-r--  1 wtf wtf       4028 Dec  6 17:51 wtf.gtkw
#-rw-rw-r--  1 wtf wtf 1434765012 Dec  6 17:53 wtf.vcd
vcd2fst wtf.vcd wtf.fst
```

* need dl link up

   * transmitting bits but not advancing yet

   * ocx_dlx_xlx_if.v is specific logic for xilinx phy; this is what should be exposed to external phy logic if want to use multiple
     'phy'; eventually remove it from dl (can use for Xil PHY logic)


* changed tsm_q reset value so don't have to step training manually ('fire' change for xil phy)

* pattern_a (bits) completes but pattern_b (alignment) not being detected

<img width=800px src="./pattern_b.png">

* during pattern a, b, sync, there is no header data; so the 64b shifts over the 66b hdr+data

* link up

   * took several changes to counters - because they assume a minimum wire length?  need to be configurable

   * removed 2-flit forced hiccup - tuning req'd for specific fire implementation on xil?

<img width=800px src="./trained.png">

## device tl

   * host tl (..tlx..v) can't be used w/o modification because crediting is built into
   tl logic (rtl above tl can't send a credit return rsp since it's not detected as special (credit-ignore)), but there is dedicated logic to do framer/parser credit tx/rx

      * added GEMINI_NOT_APOLLO to tl and swap 01/08 opcodes based on that (rx and tx)

      * so far 1/4 vc (vc0, tl) got credits :( or :)








