# open 256data.txt
# read all lines

# for each line
#   split line into 3 values
#   convert each value to hex
#   print hex value

# close 256data.txt




input_file = "256data.txt"
output_file = "256palette.txt"
out=open(output_file, "w")
out.write("palette_hex = [")
with open(input_file) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            line = line[line.index('#')+1:line.index('#')+7]
            line = line.upper()
            out.write("'"+"0x"+line+"', " )
            continue
        except ValueError:
            pass
