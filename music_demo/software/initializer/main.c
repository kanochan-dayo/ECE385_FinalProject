#include "main.h"

int main(){
	setup_i2c();
<<<<<<< HEAD
	setLED(9);
	setLED(8);

	usleep(10000000);
	setLED(7);
	setLED(6);
	usb_init();

=======
	*(volatile unsigned int*)LEDS_PIO_BASE=0xFFFF;
//	while(1)
//	{
//		usleep(1000000);
//		printf("hahahaha\n");
//	}
>>>>>>> parent of 4f0f269 (huhu)
return 0;
}
