#include "main.h"

int main(){
	usleep(5000000);
//	setup_i2c();
	IOWR_16DIRECT(LEDS_PIO_BASE,0,0x130);
return 0;
}
