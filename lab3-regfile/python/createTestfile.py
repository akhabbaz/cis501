from random import seed
from random import randint
import random
import sys

testfile =  "decoder.txt"

# createDecoderTester will create a decoder tester file for a decoder with n
# bits, in filename, with lines of test.  The format is n bits, decoded wire.

def  createDecoderTester (n, filename, lines):
     f = open(filename, "w");
     original_stdout = sys.stdout
     sys.stdout = f
     maxVal = pow(2, n) -1; 
     for i in range (1, lines):
           val = random.randint(0, maxVal)
           print("%d %d"%(val, pow(2, val)))
     sys.stdout = original_stdout
     f.close()

random.seed(132)
createDecoderTester(3, testfile, 50)
