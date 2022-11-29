#include "main.h"

int main(){
	setup_i2c();
	setLED(9);
	setLED(8);

	usleep(10000000);
	setLED(7);
	setLED(6);
	usb_init();

return 0;
}
