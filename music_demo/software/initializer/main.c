#include "main.h"

int main(){
	setup_i2c();
	*(volatile unsigned int*)LEDS_PIO_BASE=0xFFFF;
//	while(1)
	int usb_init();
//	{
//		usleep(1000000);
//		printf("hahahaha\n");
//	}
return 0;
}
