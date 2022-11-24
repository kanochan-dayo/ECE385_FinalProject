#include <system.h>
#include <stdio.h>
#include "GenericTypeDefs.h"
#include <io.h>


void write_to_external_bus(DWORD address, WORD data){
	IOWR_16DIRECT(TO_EXTERNAL_BUS_BRIDGE_0_BASE, address, data);
}

int main(){
FILE *fp=scanf("ug_embedded_ip.bin");
	if(fp==NULL){
		printf("File not found");
		return 0;
	}
	int i=0;
	while(!feof(fp)){
		WORD data=fgetc(fp);
		write_to_external_bus(i,data);
		i++;
	}
	return 0;

}
