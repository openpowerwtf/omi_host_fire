# Notes

```
ghdl-build

Import libraries...

Import TL...

Make...
get_base_type: cannot handle IIR_KIND_OVERLOAD_LIST (??:??:??)

******************** GHDL Bug occurred ***************************
Please report this bug on https://github.com/ghdl/ghdl/issues
GHDL release: 2.0.0-dev (1.0.0.r996.g81441654) [Dunoon edition]
Compiled with GNAT Version: Community 2021 (20210519-103)
Target: x86_64-pc-linux-gnu
/home/wtf/projects/omi_host_fire/asic_host/ghdl/
Command line:
ghdl -m --std=08 --workdir=work -Pwork omi
Exception TYPES.INTERNAL_ERROR raised
Exception information:
raised TYPES.INTERNAL_ERROR : vhdl-errors.adb:30
Call stack traceback locations:
0x5ad456 0x5aa9db 0x656f3c 0x656f8c 0x6573c2 0x65752f 0x6579dc 0x6582e4 0x658d23 0x68ed2e 0x68ee36 0x68ef93 0x650323 0x656e3c 0x63e9b5 0x63f782 0x63f9de 0x690e32 0x690f40 0x690a54 0x690b54 0x690800 0x690631 0x690ead 0x690f40 0x690a54 0x690b54 0x690800 0x690631 0x690ead 0x690f40 0x690a54 0x690b54 0x690800 0x690631 0x691f7e 0x6ece9c 0x6f46ce 0x63c03a 0x7acdb9 0x408ab7 0x7ff11ba350b1 0x4071bc 0xfffffffffffffffe
******************************************************************
```