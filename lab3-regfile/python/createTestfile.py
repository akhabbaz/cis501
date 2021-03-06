from random import seed
from random import randint
import random
import sys

testfile =  "decoder.txt"
s = 4  # l = 2**s is the number of choices
dataWidth = 16 # width of data 
datalines = 1200 # number of data rows
seedNumber = 145 # seed the random number generator
#randomDataWidth will create a random integer n bits wide
def randomDataWidth(n):
     maxVal = pow(2, n);
     randval = random.randint(0, maxVal -1);
     return randval 

# createDecoderTester will create a multiplex decoder tester file.   for a decoder with s
# bits, that is 2**s choices of inputs , where each input is n bits wide.  The
# filename given above, and it has  datalines of tests.  
# s is the bitwidth of the selector, n is dataBitWidth.  
#    The file format is all in hex.  The first line specifies s, and n. The
# following lines have the selector, a number from 0 to 2**s -1, the hotwire a
# power of two that indicates which bit is selected, then all the random data,
# ech n bits wide, and finally the selected data.

def  createDecoderTester (s, n, filename, lines):
     f = open(filename, "w");
     original_stdout = sys.stdout
     sys.stdout = f
     maxVal = pow(2, s);
     print("%2s %2s"%(hex(s)[2:], hex(n)[2:]));
     for i in range (0, lines):
          val = random.randint(0, maxVal -1)
          selectedVal = -1;
          print("%2s %4s"%(hex(val)[2:], hex(pow(2, val))[2:]), end = " ")
          for j in range (0, maxVal):
               thisRandomNumber = randomDataWidth(n);
               print("%8s"%hex(thisRandomNumber)[2:],  end = " ")
               if j == val:
                    selectedVal = thisRandomNumber;
          print("%8s"%hex(selectedVal)[2:])
     sys.stdout = original_stdout
     f.close()

random.seed(seedNumber)
createDecoderTester(s, dataWidth, testfile, datalines)
