// gcc gtkwave_filter_dlx_flit.c -o gtkwave_filter_dlx_flit
//
// parse dl flits
// 64B

// will have to be a transaction filter?  do they go over multiple cycles?

#include <stdio.h>

int main(int argc, char **argv) {

   while (!feof(stdin)) {

      char buf[130];
      buf[0] = 0;

      fgets(buf, 130, stdin); // get value inc. \n
      if (buf[0]) {


         printf("?cyan?wtf:%128s", buf);


         fflush(stdout);            // reqd!
      }


   }

   return(0);

}