#!/usr/bin/python3

import sys

def main():

   fi = sys.stdin
   fo = sys.stdout

   while True:

      line = fi.readline()       # ends with newline
      if not line:
         return 0

      text = ''
      zeros = 0

      text = line.replace('00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000', '[128*0]')
      text = text.replace('0000000000000000000000000000000000000000000000000000000000000000', '[64*0]')
      text = text.replace('00000000000000000000000000000000', '[32*0]')
      text = text.replace('0000000000000000', '[16*0]')
      text = text.replace('00000000', '[8*0]')

      fo.write(f'?cyan?{text}\n')
      fo.flush()


if __name__ == '__main__':
   sys.exit(main())