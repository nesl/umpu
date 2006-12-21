#include <stdio.h>
#include <strings.h>

main(int argc, char *argv[])
{
  FILE *f;
  FILE *rom_file;
  char aline[1025];
  int p,i,len,totallen,base,tmp,addr;
  unsigned char checksum;
  char hex[16];

  if (argc!=2) {
    printf("Usage: hex2vhd <program.ihex>\n");
    exit(-1);
  }

  f=fopen(argv[1],"r");
  rom_file=fopen("programToLoad.vhd","w");
  if (f==NULL) {
    printf("Cannot open %s\n",argv[1]);
    exit(-1);
  }
  if (rom_file==NULL) {
    printf("Cannot open %s\n","programToLoad.vhd");
    exit(-1);
  }

  fprintf(rom_file,"-- Input HEX file name : %s\n",argv[1]);
  fprintf(rom_file,"library IEEE;\n");
  fprintf(rom_file,"use IEEE.std_logic_1164.all;\n");
  fprintf(rom_file,"use IEEE.std_logic_unsigned.all;\n");
  fprintf(rom_file,"\n");
  fprintf(rom_file,"entity programToLoad is port (\n");
  fprintf(rom_file,"address_in : in  std_logic_vector (15 downto 0);\n");
  fprintf(rom_file,"data_out   : out std_logic_vector (15 downto 0));\n");
  fprintf(rom_file,"end programToLoad;\n");
  fprintf(rom_file,"\n");
  fprintf(rom_file,"architecture rtl of programToLoad is\n");
  fprintf(rom_file,"begin\n");
  fprintf(rom_file,"data_out <=\n");
  printf("Generating PROM File ...\n");
  printf("Writing to address: ");
  while(fgets(aline,1024,f)!=NULL) {
    if (aline[0]!=':') continue;
    p=1;
    hex[0]=aline[1];
    hex[1]=aline[2];
    hex[2]=0;
    sscanf(hex,"%x",&len);
    hex[0]=aline[3];
    hex[1]=aline[4];
    hex[2]=aline[5];
    hex[3]=aline[6];
    hex[4]=0;
    sscanf(hex,"%x",&base);
    hex[0]=aline[7];
    hex[1]=aline[8];
    hex[2]=0;
    sscanf(hex,"%x",&tmp);
    if (tmp==1) break;

    p=9;
    addr=base/2;
    for(i=0;i<len/2;i++) {
      fprintf(rom_file,"\t\tx\"%c%c%c%c\" when address_in = 16#%04X# else\n",
	      aline[p+2],aline[p+3],aline[p+0],aline[p+1],addr);
      /* aline[p],aline[p+1],aline[p+2],aline[p+3],addr); */
      p=p+4;
      addr=addr+1;
    }

    totallen=5+len;

    checksum=0;
    for(i=0;i<totallen;i++) {
      hex[0]=aline[1+i*2+0];
      hex[1]=aline[1+i*2+1];
      hex[2]=0;
      sscanf(hex,"%x",&tmp);
      checksum=checksum+tmp;
    }
    if(checksum!=0) {
      printf("checksum error\n");
      exit(1);
    }
  }
  fprintf(rom_file,"\t\tx\"ffff\";\n");
  fprintf(rom_file,"end rtl;\n");
  printf("\n Done \n");
  fclose(f);
}
