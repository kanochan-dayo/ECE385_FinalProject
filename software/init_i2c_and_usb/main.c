#include "main.h"

int main(){
	setup_i2c();
	setLED(10);
	setLED(9);
	for (int i=0;i<=5;i++){
	usleep(2000000);
	}

	setLED(8);
	setLED(7);
	usb_set();
//	while(1)
//	{
//		usleep(1000000);
//		printf("hahahaha\n");
//	}
return 0;
}
