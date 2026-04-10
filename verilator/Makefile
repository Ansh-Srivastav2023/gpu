TOP = gpu_top		# name of the top module
SRC = /media/anx/New_Volume/Importants/Verilog/modifieable_processor/gpu/src/*.v	# clname of the file

all: slang_test build

slang_test:
	slang $(SRC)

build:
	verilator --sv --binary $(SRC) --trace --quiet
	./obj_dir/V$(TOP) +trace --quiet

clean:
	rm -rf obj_dir logs *.log
	clear
