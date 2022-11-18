# open 256data.txt
# read all lines

# for each line
#   split line into 3 values
#   convert each value to hex
#   print hex value

# close 256data.txt




input_file = "256data.txt"
output_file = "256palette_rom.txt"
out=open(output_file, "w")
with open(input_file) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            line = line[line.index('#')+1:line.index('#')+7]
            line = line.upper()
            out.writelines("24'h"+line+',\n')
            continue
        except ValueError:
            pass
