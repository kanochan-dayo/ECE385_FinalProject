1. Use Platform designer to generate rhythm_soc and sdram_controller.
2. Compile the hardware part.
3. Follow the instructions from https://www.youtube.com/watch?v=0k4AZmdW9Sk, to generate the correct bsp, the on-chip flash hex file, and the pof file.
4. prepare an SDHC tf card, copy the CHASE.dat to the tf card using direct data format, and install it to the fpga board.
5. program the fpga using the pof file, and it will start initializing the sdram. If it stuck at 3F, try to press key0, if not work, then cut off it's power and connect the power again.