VOUT  = *.v.out
ASSM  = gpu_assembler.py
NAME  = gpu_top
TOP   = $(NAME).v
SIM   = $(NAME).v.out

all: assemble synth

assemble:
	python $(ASSM)

synth:
	iverilog -o $(SIM) $(TOP)
	vvp $(SIM)


clean: 
	rm -rf $(VOUT)