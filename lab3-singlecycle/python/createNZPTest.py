#createNZPtest will create a testfile that produces a random integer of 16 bits 
# that is equally likely to be positive, zero, or negative, and produces an nzp
# result: 4 for negative, 2 for zero, 1 for positive.

from random import seed
from random import randint
import random
import sys

testfile =  "lc4_nzp.txt"
s = 4  # l = 2**s is the number of choices
dataWidth = 16 # width of data 
datalines = 5000 # number of data rows
seedNumber = 14 # seed the random number generator
#randomPositive will create a random positive integer for 2^n bits
# wide integers.
def randomPositive(n):
     maxVal = pow(2, n -1);
     randval = random.randint(1, maxVal -1);
     return randval 

#randomNegative will create a random negative integer for 2^n bits
# wide integers.
def randomNegative(n):
     minVal = -pow(2, n -1);
     randval = random.randint(minVal, -1);
     return randval
# randomIntEqualWeight will produce a randominteger with n binary digits that
# is equally likely to be positive, zero or negative.  EqualWeight produces far
# more zeros than the randomInt function would over the entire range.
def  randomIntEqualWeight(n):
      case = random.randint(-1, 1); # pick the case
      val = 0; 
      if (case == -1):
            val = randomNegative(n)
      elif (case == +1):
            val = randomPositive(n);
      return val;
# nzpOutput will produce the nzp code that classifies numbers: negative(4),
# zero(2), and positive (1)
def nzpOutput(randomInt):
	
      output = 2;
      if (randomInt > 0):
          output = 1;
      elif ( randomInt < 0):
          output = 4;
      return output;

# createDecoderTester will create a multiplex decoder tester file.   for a decoder with s
# bits, that is 2**s choices of inputs , where each input is n bits wide.  The
# filename given above, and it has  datalines of tests.  
# s is the bitwidth of the selector, n is dataBitWidth.  
#    The file format is all in hex.  The first line specifies s, and n. The
# following lines have the selector, a number from 0 to 2**s -1, the hotwire a
# power of two that indicates which bit is selected, then all the random data,
# ech n bits wide, and finally the selected data.

def  createNZPTester (n, filename, lines):
     f = open(filename, "w");
     original_stdout = sys.stdout
     sys.stdout = f
     for i in range (0, lines):
          val = randomIntEqualWeight(n);
          valType = nzpOutput(val);
          print("%6d %2d"%(val, valType))
     sys.stdout = original_stdout
     f.close()

random.seed(seedNumber)
createNZPTester(dataWidth, testfile, datalines)
