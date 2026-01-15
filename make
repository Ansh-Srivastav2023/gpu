# !/bin/bash

cd ./assembler
python gpu_assembler.py
cd ../src
iverilog -o gpu_sim.v.out gpu_top.v
vvp gpu_sim.v.out
rm -rf *.v.out
cd ../