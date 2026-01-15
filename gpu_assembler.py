import re

VARS = { 
    "NOP" :     "0000", "nop" :     "0000",
    "ADD" :     "0001", "add" :     "0001",
    "SUB" :     "0010", "sub" :     "0010",
    "MUL" :     "0011", "mul" :     "0011",
    "DIV" :     "0100", "div" :     "0100",
    "ADDI" :    "0101", "addi":     "0101",
    "MOV" :     "0110", "mov" :     "0110",
    "LD":       "0111", "ld":       "0111", # rs2 = 0001
    "LI":       "0111", "li":       "0111", # rs2 = 0010
    "STO":      "1000", "sto"  :    "1000",
    "STORE":    "1000", "store":    "1000",
    "CMP_LT":   "1001", "cmp_lt":   "1001", # rd = 0001
    "CMP_EQ":   "1001", "cmp_eq":   "1001", # rd = 0010
    "BRA":      "1010", "bra"  :    "1010",
    "EXIT":     "1011", "exit" :    "1011",
    "END":      "1100", "end"  :    "1100",
    "MASKRST":  "1101", "maskrst":  "1101",
    "MASK":     "1110", "mask":     "1110",
    "R0":       "0000", "r0"   :    "0000",
    "R1":       "0001", "r1"   :    "0001",
    "R2":       "0010", "r2"   :    "0010",
    "R3":       "0011", "r3"   :    "0011",
    "R4":       "0100", "r4"   :    "0100",
    "R5":       "0101", "r5"   :    "0101",
    "R6":       "0110", "r6"   :    "0110",
    "R7":       "0111", "r7"   :    "0111"
}

CLASSES = ["IMM_INSTR", "SNGL", "OTHR"]

IMM_INSTR = ["ADDI", "LD", "LI", "STO", "STORE", "BRA", "CMP_LT", "CMP_EQ", "addi", "ld", "li", "sto", "store", "bra", "cmp_lt", "cmp_eq"]
SNGL = ["EXIT", "END", "MASKRST", "exit", "end", "maskrst"]
OTHR = ["NOP", "ADD", "SUB", "MUL", "DIV", "MOV", "MASK", "nop", "add", "sub", "mul", "div", "mov", "mask"]


hex_codes = []

with open('program.asm', 'r') as file:
    for line in file:
        clean_line = line.split(';')[0].split('#')[0].strip()
        
        parts = [part for part in re.split(r'[,\s]+', clean_line) if part]
        
        if not parts:
            continue

        bin_code = ""
        mnemonic = parts[0]

        if mnemonic not in VARS:
            print(f"Warning: Unknown instruction '{mnemonic}' in line: {line.strip()}")
            continue

        if mnemonic in IMM_INSTR:
            class_ = CLASSES[0]

            if mnemonic.upper() in ["ADDI", "LD", "LI"]:
                if mnemonic.upper() == "LI":
                    bin_code = VARS[mnemonic] + VARS[parts[1]] + "0000" + "0010"
                
                elif mnemonic.upper() == "LD":
                    bin_code = VARS[mnemonic] + VARS[parts[1]] + VARS[parts[2]] + "0001"
                    
                else :
                    for i in parts[0:3]:
                        bin_code += VARS.get(i, "0000") # Safe get
                  
                instr_val = int(bin_code, 2)
                imm_val = int(parts[-1], 16) if parts[-1].startswith("0x") else int(parts[-1])
                if imm_val < 0:
                    imm_val = imm_val + (1 << 16) if mnemonic.upper() not in ["LI", "LD"] else (1<<12)
                instr_val = ((instr_val << 20) if mnemonic.upper() not in ["LI", "LD"] else (instr_val<<16)) + imm_val
                hex_codes.append(hex(instr_val))

            elif mnemonic.upper() in ["STO", "STORE"]:
                bin_code = VARS[parts[0]] + "0000" + VARS[parts[2]] + VARS[parts[1]]
                instr_val = int(bin_code, 2)
                imm_val = int(parts[3], 16) if parts[3].startswith("0x") else int(parts[3])
                if imm_val < 0:
                    imm_val = imm_val + (1 << 16)
                instr_val = (instr_val << 16) + imm_val
                hex_codes.append(hex(instr_val))

            elif mnemonic.upper() == "BRA":
                bin_code = VARS[mnemonic] + 3*"0000"
                instr_val = int(bin_code, 2)
                imm_val = int(parts[1], 16) if parts[1].startswith("0x") else int(parts[1])
                if imm_val < 0:
                    imm_val = imm_val + (1 << 16)
                instr_val = (instr_val << 16) + imm_val
                hex_codes.append(hex(instr_val))

            elif mnemonic.upper() == "CMP_LT":
                bin_code = VARS[parts[0]] + "0001" + VARS[parts[1]]
                instr_val = int(bin_code, 2)
                imm_val = int(parts[2], 16) if parts[2].startswith("0x") else int(parts[2])
                if imm_val < 0:
                    imm_val = imm_val + (1 << 16)
                instr_val = (instr_val << 20) + imm_val
                hex_codes.append(hex(instr_val))
            
            elif mnemonic.upper() == "CMP_EQ":
                bin_code = VARS[parts[0]] + "0010" + VARS[parts[1]]
                instr_val = int(bin_code, 2)
                imm_val = int(parts[2], 16) if parts[2].startswith("0x") else int(parts[2])
                if imm_val < 0:
                    imm_val = imm_val + (1 << 16)
                instr_val = (instr_val << 20) + imm_val
                hex_codes.append(hex(instr_val))
            
        elif mnemonic in SNGL:
            class_ = CLASSES[1]
            bin_code = VARS[parts[0]] + 7*"0000"
            instr_val = int(bin_code, 2)
            hex_codes.append(hex(instr_val))

        else:
            class_ = CLASSES[2]
            if mnemonic.upper() == "NOP":
                hex_codes.append(0)

            elif mnemonic.upper() == "MASK":
                mask_val = int(parts[1])
                try:
                    if mask_val not in range(0, 16):
                        raise ValueError
                except (IndexError, ValueError):
                    print("MASK must be in the range of 1 to 15...")

                bin_code = VARS[mnemonic]
                instr_val = int(bin_code, 2)
                instr_val = (instr_val << 28) + mask_val
                hex_codes.append(hex(instr_val))

            else:
                for i in parts:
                    bin_code += VARS.get(i, "0000") # Safe get
                bin_code += "0000000000000000"
                if mnemonic.upper() == "MOV":
                    bin_code += "0000"
                hex_codes.append(hex(int(bin_code, 2)))

with open('gpu_imem.hex', 'w') as imem:
    imem.write("@00000000\n")

    for line in hex_codes:
        imem.write(f"{str(line)}\n")