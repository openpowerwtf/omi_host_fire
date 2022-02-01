// BROKEN - HANGS!!!

/*
gcc gtkwave_filter_dlx_flit.c -o gtkwave_filter_dlx_flit
echo "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" | gtkwave_filter_dlx_flit
echo "00000001000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000" | gtkwave_filter_dlx_flit


*/

// accept one line in from stdin and return with data on stdout; must fflush(stdout); in and out end with /n
//
// parse dl flits
// 64B

// will have to be a transaction filter?  do they go over multiple cycles?

#include <stdio.h>

int main(int argc, char **argv) {

   char buf[130];   // includes /n
   char text[129];
   int i, j, zeros, p;

   while (1) {

      buf[0] = 0;
      text[0] = 0;
      p = 0;
      zeros = 0;
      fgets(buf, 130, stdin); // get value inc. \n

      //if (buf[0]) {

         for (i = 0; i < 128; i++) {

            if ((buf[i] == 0) || (buf[i] == '\n')) {
               break;
            }

            if ((buf[i] == '0') && (zeros == 0)) {    // start '0' string
               zeros = 1;
            } else if (buf[i] == '0') {               // continue '0' string
               zeros++;
            } else if (zeros > 0) {                   // end '0' string
               if (zeros < 8) {
                  for (j = 0; j < zeros; j++) {
                     text[p++] = '0';
                  }
                  zeros = 0;
                  text[p++] = buf[i];
               } else if (zeros < 16) {
                  text[p++] = '[';
                  text[p++] = '8';
                  text[p++] = '*';
                  text[p++] = '0';
                  text[p++] = ']';
                  zeros = zeros - 8;
                  for (j = 0; j < zeros; j++) {
                     text[p++] = '0';
                  }
                  zeros = 0;
                  text[p++] = buf[i];
               } else if (zeros < 32) {
                  text[p++] = '[';
                  text[p++] = '1';
                  text[p++] = '6';
                  text[p++] = '*';
                  text[p++] = '0';
                  text[p++] = ']';
                  zeros = zeros - 16;
                  for (j = 0; j < zeros; j++) {
                     text[p++] = '0';
                  }
                  zeros = 0;
                  text[p++] = buf[i];
               } else if (zeros < 64) {
                  text[p++] = '[';
                  text[p++] = '3';
                  text[p++] = '2';
                  text[p++] = '*';
                  text[p++] = '0';
                  text[p++] = ']';
                  zeros = zeros - 32;
                  for (j = 0; j < zeros; j++) {
                     text[p++] = '0';
                  }
                  zeros = 0;
                  text[p++] = buf[i];
               } else if (zeros < 128) {
                  text[p++] = '[';
                  text[p++] = '6';
                  text[p++] = '4';
                  text[p++] = '*';
                  text[p++] = '0';
                  text[p++] = ']';
                  printf("[[[%d]]]",zeros);
                  zeros = zeros - 64;
                  for (j = 0; j < zeros; j++) {
                     text[p++] = '0';
                  }
                  zeros = 0;
                  text[p++] = buf[i];
               } else if (zeros == 128) {
                  text[p++] = '[';
                  text[p++] = '1';
                  text[p++] = '2';
                  text[p++] = '8';
                  text[p++] = '*';
                  text[p++] = '0';
                  text[p++] = ']';
                  zeros = 0;
                  text[p++] = buf[i];
               }
            } else {
               text[p++] = buf[i];
            }

         }
         if (zeros > 0) {                   // end '0' string
               if (zeros < 8) {
                  for (j = 0; j < zeros; j++) {
                     text[p++] = '0';
                  }
                  zeros = 0;
               } else if (zeros < 16) {
                  text[p++] = '[';
                  text[p++] = '8';
                  text[p++] = '*';
                  text[p++] = '0';
                  text[p++] = ']';
                  zeros = zeros - 8;
                  for (j = 0; j < zeros; j++) {
                     text[p++] = '0';
                  }
                  zeros = 0;
               } else if (zeros < 32) {
                  text[p++] = '[';
                  text[p++] = '1';
                  text[p++] = '6';
                  text[p++] = '*';
                  text[p++] = '0';
                  text[p++] = ']';
                  zeros = zeros - 16;
                  for (j = 0; j < zeros; j++) {
                     text[p++] = '0';
                  }
                  zeros = 0;
               } else if (zeros < 64) {
                  text[p++] = '[';
                  text[p++] = '3';
                  text[p++] = '2';
                  text[p++] = '*';
                  text[p++] = '0';
                  text[p++] = ']';
                  zeros = zeros - 32;
                  for (j = 0; j < zeros; j++) {
                     text[p++] = '0';
                  }
                  zeros = 0;
               } else if (zeros < 128) {
                  text[p++] = '[';
                  text[p++] = '6';
                  text[p++] = '4';
                  text[p++] = '*';
                  text[p++] = '0';
                  text[p++] = ']';
                  zeros = zeros - 64;
                  for (j = 0; j < zeros; j++) {
                     text[p++] = '0';
                  }
                  zeros = 0;
               } else if (zeros == 128) {
                  text[p++] = '[';
                  text[p++] = '1';
                  text[p++] = '2';
                  text[p++] = '8';
                  text[p++] = '*';
                  text[p++] = '0';
                  text[p++] = ']';
                  zeros = 0;
               }
         }
         text[p] = 0;
      //}
      printf("?cyan?%s\n", text);
      fflush(stdout);
      return(0);
   }

}