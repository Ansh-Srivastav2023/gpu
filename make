# !/bin/bash

python assembler/gpu_assembler.py program.asm hex/gpu_imem.hex
cd src
iverilog -o gpu_sim.v.out gpu_top.v
vvp gpu_sim.v.out
rm -rf *.v.out
cd ../