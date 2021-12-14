# yosys synth.ys

read_verilog tl/*
read_verilog dl/*
read_verilog omi_host.v
hierarchy -top omi_host