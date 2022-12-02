# open 256data.txt
# read all lines

# for each line
#   split line into 3 values
#   convert each value to hex
#   print hex value

# close 256data.txt




# input_file = "./useful_python/256data.txt"
output_file = "./useful_python/256palette.txt"
output_file_rom = "./useful_python/256palette_rom.txt"
redcolors = ["00","20","50","70","90","B0","E0","FF"]
greencolors = ["00","20","50","70","90","B0","E0","FF"]
bluecolors = ["00","50","B0","FF"]
out=open(output_file, "w")
out.write("palette_hex = [")
for red in redcolors:
    for green in greencolors:
        for blue in bluecolors:
            out.write("'0x"+red+green+blue+"', ")
out.write("]")
out.close()
out=open(output_file_rom, "w")
for red in redcolors:
    for green in greencolors:
        for blue in bluecolors:
            out.write("24'h"+red+green+blue+", \n")
