# Sim

```
verilator --cc --exe --trace -Wno-fatal -Wno-Litendian -Isrc -I./src/dl -I./src/tl top.v tb.cpp

cd obj_dir;make -f Vtop.mk;cd ..
obj_dir/Vtop

Seed=08675309
Resetting...
Go!
cyc=00000006 Write @00000030 sel=6 data=79471d3a mem=00000000->00471d00
cyc=00000100
cyc=00000200
cyc=00000300
cyc=00000400
cyc=00000500
cyc=00000600
cyc=00000700
cyc=00000800
cyc=00000900
cyc=00001000
Quiescing...
Quiescing...
Request is outstanding!
Done.

You are worthless and weak!

Seed=08675309

gtkwave wtf.vcd wtf.gtkw
```

* need dl link up

   * from Fire spec:

      * (gateware) set DL0.CONFIG0.CFG_DL0_ENABLE to start DL calibration
      * (emulation) hold DL in reset and set '7 signals' from PHY to start calibration; 7 signals are tied into 1, 'gtwiz_done'; and 'cal complete' is not accessible in reg - check DLX_TLX_LINK_UP



* create verilator publics from xil debug sigs; - somehow works...

```
sed -Ei 's/(.*\(\s*\*mark_debug = "true"\s*\*\).*?)(\/\*verilator public\*\/)?;/\1 \t\t\/\*verilator public\*\/;/g' src/dl/*.v

# but breaks this; manually fix up...
#   (*mark_debug = "true"*) (*keep = "true"*)reg  [2:0]   tsm_q  /*verilator public*/ = 3'b110;
```


