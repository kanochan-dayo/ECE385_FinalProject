#include <system.h>
#include <stdio.h>
#include "GenericTypeDefs.h"
#include <io.h>




int main(){
FILE *fp=scanf("ug_embedded_ip.bin");
	if(fp==NULL){
		printf("File not found");
		return 0;
	}
	int i=0;
	while(!feof(fp)){
		WORD data=fgetc(fp);
		i++;
	}
	return 0;

}
