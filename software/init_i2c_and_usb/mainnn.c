//ECE 385 USB Host Shield code
//based on Circuits-at-home USB Host code 1.x
//to be used for ECE 385 course materials
//Revised October 2020 - Zuofu Cheng

#include <stdio.h>
#include "system.h"
#include "altera_avalon_spi.h"
#include "altera_avalon_spi_regs.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"
#include "usb_kb/GenericMacros.h"
#include "usb_kb/GenericTypeDefs.h"
#include "usb_kb/HID.h"
#include "usb_kb/MAX3421E.h"
#include "usb_kb/transfer.h"
#include "usb_kb/usb_ch9.h"
#include "usb_kb/USB.h"

extern HID_DEVICE hid_device;

static BYTE addr = 1; 				//hard-wired USB address
const char* const devclasses[] = { " Uninitialized", " HID Keyboard", " HID Mouse", " Mass storage" };

BYTE GetDriverandReport() {
	BYTE i;
	BYTE rcode;
	BYTE device = 0xFF;
	BYTE tmpbyte;

	DEV_RECORD* tpl_ptr;
	printf("Reached USB_STATE_RUNNING (0x40)\n");
	for (i = 1; i < USB_NUMDEVICES; i++) {
		tpl_ptr = GetDevtable(i);
		if (tpl_ptr->epinfo != NULL) {
			printf("Device: %d", i);
			printf("%s \n", devclasses[tpl_ptr->devclass]);
			device = tpl_ptr->devclass;
		}
	}
	//Query rate and protocol
	rcode = XferGetIdle(addr, 0, hid_device.interface, 0, &tmpbyte);
	if (rcode) {   //error handling
		printf("GetIdle Error. Error code: ");
		printf("%x \n", rcode);
	} else {
		printf("Update rate: ");
		printf("%x \n", tmpbyte);
	}
	printf("Protocol: ");
	rcode = XferGetProto(addr, 0, hid_device.interface, &tmpbyte);
	if (rcode) {   //error handling
		printf("GetProto Error. Error code ");
		printf("%x \n", rcode);
	} else {
		printf("%d \n", tmpbyte);
	}
	return device;
}

void setKeycode(WORD keycode)
{
	IOWR_ALTERA_AVALON_PIO_DATA(KEYCODE_BASE, keycode);
}
void setdfjk(BYTE keycode)
{
	IOWR_ALTERA_AVALON_PIO_DATA(DFJK_BASE, keycode);
}
BYTE calc_autoflag(BYTE flag,BYTE keycode){

	switch(flag)
	{
	case 4:
	return 4;
	break;
	case 0:
		if(keycode==4)
			return 1;
		else
			return 0;
		break;
	case 1:
		if(keycode==24||keycode==4)
			return 2;
		else if(keycode==0)
			return 1;
		else
			return 0;
		break;
	case 2:
		if(keycode==23)
			return 3;
		else if(keycode==0||keycode==24)
			return 2;
		else
			return 0;
		break;
	case 3:
		if (keycode == 18)
			return 4;
		else if (keycode ==0||keycode==23)
			return 3;
		else
			return 0;
		break;
	}
	return 0;
}
int usb_set() {
	BYTE rcode;
	BOOT_MOUSE_REPORT buf;		//USB mouse report
	BOOT_KBD_REPORT kbdbuf;

	BYTE runningdebugflag = 0;//flag to dump out a bunch of information when we first get to USB_STATE_RUNNING
	BYTE errorflag = 0; //flag once we get an error device so we don't keep dumping out state info
	BYTE device;
	BYTE dfjk;
	WORD temp_keycode=0;
//	printf("initializing MAX3421E...\n");
	MAX3421E_init();
//	printf("initializing USB...\n");
	USB_init();
	BYTE auto_flag=0;
	while (1) {
		MAX3421E_Task();
		USB_Task();
		//usleep (500000);
		if (GetUsbTaskState() == USB_STATE_RUNNING) {
			if (!runningdebugflag) {
				runningdebugflag = 1;
				setLED(9);
				device = GetDriverandReport();
			} else if (device == 1) {
				//run keyboard debug polling
				rcode = kbdPoll(&kbdbuf);
//		printf(".");
				if (rcode == hrNAK) {
					continue; //NAK means no new data
				} else if (rcode) {
//					printf("Rcode: ");
//					printf("%x \n", rcode);
					continue;
				}
//				printf("dfjk: ");
				if(auto_flag==4)
					dfjk=1<<4;
				else
					dfjk = 0;
				for (int i = 0; i < 6; i++) {
					if (kbdbuf.keycode[i] == 0x7 )
					{
						dfjk |= 1<<3;
					}
					else if (kbdbuf.keycode[i] == 0x9)
					{
						dfjk |= 1<<2;

					}
					else if(kbdbuf.keycode[i] == 0xD)
					{
						dfjk |= 1<<1;
						
					}
					else if(kbdbuf.keycode[i] == 0xE)
					{
						dfjk |= 1;
					}
					else if(kbdbuf.keycode[i]!=0)
					{
						temp_keycode = kbdbuf.keycode[i];
					}
				}
				setdfjk(dfjk);
//				printf("%x \n", dfjk);
				setKeycode(temp_keycode);
				auto_flag=calc_autoflag(auto_flag,temp_keycode);
//				if(kbdbuf.keycode[0])
//				printSignedHex0(kbdbuf.keycode[0]);
//				printSignedHex1(kbdbuf.keycode[1]);
//				printf("\n");
			}

//			else if (device == 2) {
//				rcode = mousePoll(&buf);
//				if (rcode == hrNAK) {
//					//NAK means no new data
//					continue;
//				} else if (rcode) {
//					printf("Rcode: ");
//					printf("%x \n", rcode);
//					continue;
//				}
//				printf("X displacement: ");
//				printf("%d ", (signed char) buf.Xdispl);
//				printSignedHex0((signed char) buf.Xdispl);
//				printf("Y displacement: ");
//				printf("%d ", (signed char) buf.Ydispl);
//				printSignedHex1((signed char) buf.Ydispl);
//				printf("Buttons: ");
//				printf("%x\n", buf.button);
//				if (buf.button & 0x04)
//					setLED(2);
//				else
//					clearLED(2);
//				if (buf.button & 0x02)
//					setLED(1);
//				else
//					clearLED(1);
//				if (buf.button & 0x01)
//					setLED(0);
//				else
//					clearLED(0);
//			}
//		} else if (GetUsbTaskState() == USB_STATE_ERROR) {
			if (!errorflag) {
//				errorflag = 1;
//				clearLED(9);
//				printf("USB Error State\n");
				//print out string descriptor here
			}
		} else //not in USB running state
		{

//			printf("USB task state: ");
//			printf("%x\n", GetUsbTaskState());
			if (runningdebugflag) {	//previously running, reset USB hardware just to clear out any funky state, HS/FS etc
				runningdebugflag = 0;
				MAX3421E_init();
				USB_init();
			}
			errorflag = 0;
			clearLED(9);
		}

	}
	return 0;
}
