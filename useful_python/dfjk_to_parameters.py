import sys
imput_file = "dfjk_keys.txt"
output_files=["key_d.sv","key_f.sv","key_j.sv","key_k.sv"]
for output_file in output_files:
    out=open(output_file, "w")
    out.write("module key_"+output_file[4]+"(input [7:0] addr, \noutput [15:0] key_1, \noutput [15:0] key_2, \noutput [15:0] key_3, \noutput [15:0] key_4);\n")
    out.write("parameter [0:255][15:0] mem={\n")
    out.close()

d_pre="00"
f_pre="00"
j_pre="00"
k_pre="00"

with open(imput_file) as f:
    for line in f:
        if not line:
            continue
        line = line.strip()
        line = line.upper()
        Key_type = line[0]
        if Key_type == "D":
            if (d_pre == "01" and line[1:3] != "10") or (d_pre != "01" and line[1:3] == "10"):
                print("Error: D key is error in line: "+line+"at index: "+str(f.tell()))
                sys.exit()
            d_pre = line[1:3]
            number = line[3:]
            number=float(number)
            number=round(number*1250/21)
            number=str(bin(number))[2:]
            number=number.zfill(14)
            out=open(output_files[0], "a")
            out.write("16'b"+line[1:3]+number+",\n")
            out.close()
            continue
        if Key_type == "F":
            if (f_pre == "01" and line[1:3] != "10") or (f_pre != "01" and line[1:3] == "10"):
                print("Error: F key is error in line: "+line+"at index: "+str(f.tell()))
                sys.exit()
            f_pre = line[1:3]
            number = line[3:]
            number=float(number)
            number=round(number*1250/21)
            number=str(bin(number))[2:]
            number=number.zfill(14)
            out=open(output_files[1], "a")
            out.write("16'b"+line[1:3]+number+",\n")
            out.close()
            continue
        if Key_type == "J":
            if (j_pre == "01" and line[1:3] != "10") or (j_pre != "01" and line[1:3] == "10"):
                print("Error: J key is error in line: "+line+"at index: "+str(f.tell()))
                sys.exit()
            j_pre = line[1:3]
            number = line[3:]
            number=float(number)
            number=round(number*1250/21)
            number=str(bin(number))[2:]
            number=number.zfill(14)
            out=open(output_files[2], "a")
            out.write("16'b"+line[1:3]+number+",\n")
            out.close()
            continue
        if Key_type == "K":
            if (k_pre == "01" and line[1:3] != "10") or (k_pre != "01" and line[1:3] == "10"):
                print("Error: K key is error in line: "+line+"at index: "+str(f.tell()))
                sys.exit()
            k_pre = line[1:3]
            number = line[3:]
            number=float(number)
            number=round(number*1250/21)
            number=str(bin(number))[2:]
            number=number.zfill(14)
            out=open(output_files[3], "a")
            out.write("16'b"+line[1:3]+number+",\n")
            out.close()
            continue
        print("Error: Key type is error in line: "+line+"at index: "+str(f.tell()))
        sys.exit()
        
        

for output_file in output_files:
    out=open(output_file, "a")
    out.write("};\n\nassign	key_1 = mem[addr];\nassign	key_2 = mem[addr+1];\nassign	key_3 = mem[addr+2];\nassign	key_4 = mem[addr+3];\n\nendmodule\n")
    out.close()