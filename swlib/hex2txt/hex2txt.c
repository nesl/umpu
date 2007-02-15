#include <stdio.h>
#include <strings.h>

int main(int argc, char *argv[])
{
  FILE *r_file;
  FILE *w_file;
  int ch;
  int counter = 0;

  // Checking for correct number of args
  if (argc != 3) {
    printf("Usage: hex2vhd <binary file> <txt file>\n");
    exit(-1);
  }

  // Opening the files and checking for errors
  r_file=fopen(argv[1],"r");
  w_file=fopen(argv[2],"w");
  if (r_file == NULL || w_file == NULL) {
    printf("Unable to open a file\n");
    exit(-1);
  }

  // Printing the header
  fprintf(w_file, "Time\tValue\n\n");

  // While not end of read file
  while(!feof(r_file)){
    // Using fread to read a binary file
    fread(&ch, sizeof(int), 1, r_file);
    // For the time_stamp
    if (counter == 0) {
      // Checking for pairs of time_stamp and value
      if(feof(r_file))
	break;
      counter++;
      fprintf(w_file, "%d\t", ch);
    }
    // For the value
    else {
      counter--;
      fprintf(w_file, "%d\n", ch);
    }
  }

  // Close the files
  fclose(r_file);
  fclose(w_file);
  return 0;
}
