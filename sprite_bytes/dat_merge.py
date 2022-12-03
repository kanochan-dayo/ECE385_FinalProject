import os
dat_files = [f for f in os.listdir('.') if (f.endswith('.dat') and (not f.endswith('merged.dat')) and (not f.startswith('background')))]
merged_file = 'merged.dat'
output_file = open(merged_file, "wb")
for input_file in dat_files:
    with open(input_file, "rb") as f:
        output_file.write(f.read())
output_file.close()