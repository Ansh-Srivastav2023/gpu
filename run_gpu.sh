# !/bin/bash

case ${1,,} in 
    verify)
        cd verfication
        make
        cd ..

        ;;

    
    assemble)
        echo "Assembling the Assembly Code..."
        python assembler/gpu_assembler.py program.asm hex/gpu_imem.hex

        echo "Code Assembled..."

        cat /media/anx/New_Volume/Importants/Verilog/modifieable_processor/gpu/hex/gpu_dmem.hex

        ;;

    
    *)
        echo "Assembling the Assembly Code..."
        python assembler/gpu_assembler.py program.asm hex/gpu_imem.hex

        echo "Code Assembled..."

        cd verification
        make
        cd ..
    
        ;;
esac