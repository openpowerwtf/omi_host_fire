# Sim

* add in remote DL and try to avoid undocumented training, etc.

```
verilator --cc --exe --trace -Wno-fatal -Wno-Litendian -Isrc -I./src/dl -I./src/tl top.v tb.cpp

cd obj_dir;make -f Vtop.mk;cd ..
obj_dir/Vtop



gtkwave wtf.vcd wtf.gtkw
```

* need dl link up

   * transmitting bits but not advancing yet



