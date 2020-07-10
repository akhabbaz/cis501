#  (a & b, a | b)
from random import seed
from random import randint
from readIntegers import readFileIntegers
import random
#test file for gin"
testfile =  "gInTest.txt"
#test file for pin"
testfile =  "pInTest.txt"
#test file for intermediatTest"
testfile =  "cIntTest.txt"
#df  makeGP takes binary inputs a, b and returns
def  makeGP(a, b):
     g = a & b;
     p = a | b;
     return (g, p)
#   merges two gps
#   returns (gCurr| pCurr& gPrior,  pCurr& pPrior)
#   Each bit is independent
def mergeGP( gpCurr, gpPrior):
#     gpCurr  = (gpCurr[0] & 1, gpCurr[1] & 1);
#     gpPrior = (gpPrior[0] & 1, gpPrior[1] & 1)
     if (len(gpCurr) == 0):
         return gpPrior
     gnew = gpCurr[0] | gpCurr[1]& gpPrior[0]
     pnew = gpCurr[1] & gpPrior[1]
    # print('prior (%d, %d);'% gpPrior,'Current (%d, %d) : '%gpCurr, 
    #		'Combined (%d, %d) '%  (gnew, pnew))
     return (gnew, pnew)

# shiftGP will shift the digits of GP to the right by n places and 
# return that one bit
def shiftGP(GP, n):
       gnew = (GP[0] >> n) & 1
       pnew = (GP[1] >> n) & 1
       return (gnew, pnew)
#shift4GP will select 4 bits, starting at bit n
def shift4GP(GP, n):
       gnew = (GP[0] >> n) & 15
       pnew = (GP[1] >> n) & 15
       return (gnew, pnew)
#shift5GP will select 5 bits, starting at bit n
def shift5GP(a, n):
       return  (a >> n) & 31
#Take_Shift will take x bits, starting at bit n
def take_shift(a, x,  n):
       return  (a >> n) & (pow(2, x) -1)
# compute the carry of one bit    
def computeCarryOneBit(gp, cin):
        return gp[0] | gp[1] & cin
# computes the sum or all bits assuming g, p and carry where each bit represents
# the value for that digit
def computeSum(gp, carry):
    return gp[0] ^ gp[1] ^ carry;
def gln(gpin,  cin, n = 4):
#  compute gout, pout, and cout
#   (gin, pin)   product or or of inputs, g  has LSB is gin(0, 0), and MSB is
#   		g(n-1, n-1), and same for p.
#         
#   n          number of digits in input, say 4
#  cin         cin say corresponds to index k
#  return a tuple ((g(k + n -1, k), p(k + n -1, k)), ((cout(k),... cout(k+n-1)))
#   gout, pout   one bit that would be g,p(n-1, 0)
#   cout         the output of the lowest n-1 bits, output of bit 0 is
#                input to bit 1; These are the carries of bits of inputs 
#                1:n-1 
#   gpout        the sum gps (gp0, gp1, gp2 ... gp(n-1)) where each gp is (g,p)
       cin = cin & 1;
       gpout = (shiftGP(gpin, 0),);
       # print(gpString(gpout))       
       cout = ();
       for i in range(1, n):
           gpi = shiftGP(gpin, i);
           lastgp= gpout[-1]
           # cout for bit i -i or cin for i
           cini = computeCarryOneBit(lastgp, cin)
           cout += (cini,)
           gpcombined = mergeGP(gpi, gpout[-1])
           gpout = gpout + (gpcombined,)
       return (gpout[-1], cout, gpout)

# combine digits in a tuple (LSB first element) and join into one number 
# assuming the first entry, digits[0],  represents 2^0.
def combineDigits(digits):

     sum = 0;
     mult = 1;
     for digit in digits:
          sum += mult * digit;
          mult *= 2
     return sum
# gpTupToNum takes a tuple of the form ((0, 1), (1, 1) ...) and turns it into
# two numbers in a tuple (g, p) where g corresponds to the 0th index and p to
# the 1 index. 
def gpTupToNum(gpsums):      
     gSC = [row[0] for row in gpsums]
     pSC = [row[1] for row in gpsums]
     return  (combineDigits(gSC), combineDigits( pSC))
# 16 bit cla using gln 4
# input is two numbers and a carry, 16 bit numbers
# output is (sum, carry);  sum is a + b+ cin mod 2^16; 
#  carry is carry bit 
def cla16(a, b, cin):
      N = 4
      gp = makeGP(a,b);
      #print(gpStrBin(gp));
      # This is the input carries
      c = [0] * 16;
      c[0]  = cin;
      # intermediate gps gp(3,0), gp(7, 4) .. gp(15, 12)
      gpsum = [(0,0)] * 5
      allgpsums = [(0,0)] *16
      # first time to get gpsums correct
      for i in range(4):
              thisgp = shift4GP(gp, i *N); 
              (gpsum[i], c[N*i +1 :N * (i + 1)], allgpsums[N*i:N*(i+1)]) = gln(thisgp, c[N*i]);
      # now use those gpsums to get c[4, 8, 12]
      # test 
      gcComb = gpTupToNum(allgpsums)
      #print(gpSumStrBin(gcComb));
      #print(cStrBin(combineDigits(c)))
      # convert gpsum from several tuples to one
      # combine digites for g and p
      gsum = combineDigits((gpsum[0][0], gpsum[1][0], gpsum[2][0], gpsum[3][0]));
      psum = combineDigits((gpsum[0][1], gpsum[1][1], gpsum[2][1], gpsum[3][1]));
      allgpsums = [(0,0)] *4
      #print(gpStrBin((gsum,psum)))
      (gpsum[4], c[N:16:N], allgpsumsS) = gln((gsum, psum), c[0]);
      gcComb = gpTupToNum(allgpsumsS)
      #print(gpSumStrBin(gcComb));
      #print(cStrBin(combineDigits(c)))
      # now go back and update the other Cs  because c 4, 8, 12 are correct
      for i in range(4):
              thisgp = shift4GP(gp, i *N); 
              (gpsum[i], c[N*i +1 :N * (i + 1)], allgpsums[N*i:N*(i+1)]) =gln(thisgp, c[N*i]);
      # the carry is gotten from the output of the summing gln
      gcComb = gpTupToNum(allgpsums)
      #print(gpSumStrBin(gcComb));
      print("output of cla16 c final")
      print(cStrBin(combineDigits(c)))
      carry = computeCarryOneBit(gpsum[4], cin)
      carryAll = combineDigits(c);
      sum = computeSum(gp, carryAll) ;
      return (sum, carry);

# 16 bit cla using gln 4
# input is two numbers and a carry, 16 bit numbers
# output is (sum, carry);  sum is a + b+ cin mod 2^16; 
def cla16_cinOnly(a, b, cin):
      N = 4
      gp = makeGP(a,b);
      # This is the input carries
      c = [0] * 16;
      c[0]  = cin;
      # intermediate gps gp(3,0), gp(7, 4) .. gp(15, 12)
      gpsum = [(0,0)] * 5
      allgpsums = [(0,0)] *16
      # first time to get gpsums correct
      for i in range(4):
              thisgp = shift4GP(gp, i *N); 
              (gpsum[i], c[N*i +1 :N * (i + 1)], allgpsums[N* i: N * i  + N
				-1]) = gln(thisgp, c[N*i]);
      # now use those gpsums to get c[4, 8, 12]
      # convert gpsum from several tuples to one
      # combine digites for g and p
      gsum = combineDigits((gpsum[0][0], gpsum[1][0], gpsum[2][0], gpsum[3][0]));
      psum = combineDigits((gpsum[0][1], gpsum[1][1], gpsum[2][1], gpsum[3][1]));
      allgpsums2 = [(0,0)] * 4
      (gpsum[4], c[N:16:N], allgpsums2) = gln((gsum, psum), c[0]);
      ## now go back and update the other Cs  because c 4, 8, 12 are correct
      #for i in range(4):
      #        thisgp = shift4GP(gp, i *N); 
      #        (gpsum[i], c[N*i +1 :N * (i + 1)]) =gln(thisgp, c[N*i]);
      ## the carry is gotten from the output of the summing gln
      carry = computeCarryOneBit(gpsum[4], cin)
      carryAll = combineDigits(c);
      sum = computeSum(gp, carryAll) ;
      # test gin,pin
      #carryAll = gp[1]
      #return (carryAll, carry);
      #cint test combine digits
      cint =[0] * 15
      for i in range(5):
           cint[i] = gpsum[i][1];
           cint[i+5] = gpsum[i][0];
      cint[10:12] = c[N:16:N]
      cintCombined = combineDigits(cint)   
      return (cintCombined, carryAll);

#  calcGPSums(gp, cin, N = 4, digits = 16) calculates gpsums and resultsing cins; 
#  gp a (g,p) tuple where g is  number representing g (ands of inputs a, b) and
#  p (ors).  cin is a set of bits, the input to each gln LSB of cin is LS adder.
# N is the group that are
#  summed together (4 bits say) and digits is the number of digits in gp.  
#  output is( gp (gp0, gp1, gp2, .., gp(digits)), c (cin0, cin1, cindigits).
#  c (N, 2N, 3N is set to the corresponding bit of cin, gpsum is
#  the gpsum  values only at the  gp(N,0) , gp(2N, N), gp(3N, 2N) digits.
def calcGPSums(gp,  cin, N = 4, digits = 16):
      # ceil function get max digit if digits is 13, N =4
      digits = ((digits+ N-1)//N) * N;
      loops = digits//N;
      # This is the input carries
      c = [0] * digits;
      # intermediate gps gp(3,0), gp(7, 4) .. gp(15, 12)
      allgpsums = [(0,0)] *digits
      gpsum = [(0, 0)] * loops
      # first time to get gpsums correct
      for i in range(loops):
              c[N*i] = take_shift(cin, 1, i)
              thisgp = (take_shift(gp[0], N, i*N), take_shift(gp[1], N, i * N));
              (gpsum[i], c[N*i +1 :N * (i + 1)], allgpsums[N* i: N *(i+1)]) = gln(thisgp, c[N*i]);
      return (allgpsums, c, gpsum);
# CGPString produces a string holding a comparison of pin vivado, gin vivado,
# assuming a format for vivado and python strings of 3 bits c, 5 bits g, 5 bits
# p (from MSB to LSB).
def CGPString(vN, pN):
      vivado = take_shift(vN, 5, 0);
      python = take_shift(pN, 5, 0);
      str = "PV:{viv:5x}; PP:{pyth:5x}".format(viv = vivado, pyth= python)
      vivado = take_shift(vN, 5, 5);
      python = take_shift(pN, 5, 5);
      str = str + "; GV:{viv:5x}; GP:{pyth:5x}".format(viv = vivado, pyth= python)
      vivado = take_shift(vN, 3, 10);
      python = take_shift(pN, 3, 10);
      str = str + "; cV:{viv:3x}; cP:{pyth:3x}".format(viv = vivado, pyth= python)
      return str
#One string shows the GP values      
def gpString(gp):
      str = "  G:{viv:5x};  P:{pyth:5x}".format(viv = gp[0], pyth= gp[1])
      return str
#One string shows abCin string
def abCinStr(a, b, cin):
      str = "  a:{viv:5x};  b:{pyth:5x}; cin:{cstr:5x}".format(viv = a,
pyth=b, cstr= cin)
      return str
#One string shows abCin string now in binary
def abCinStrBin(a, b, cin):
      str1 = "  a:{astr}:   a:{astr}: cin:{cstr}\n".format( astr = bStr(a), 
                                                          cstr = bStr(cin))
      str2 = "  b:{astr}:   b:{astr}: cin:{cstr}".format( astr = bStr(b), 
                                                          cstr = bStr(cin))
      return str1+str2
#  gp is a tuple (g, p) and this produces one string g, and p formated in binary
def gpStrBin(gp):
      str1 = "  g:{gstr}:   p:{pstr}".format( gstr = bStr(gp[0]), 
                                                          pstr = bStr(gp[1]))
      return str1
#  gpSum is a tuple (g, p) and this produces one string g, and p formated in binary
def gpSumStrBin(gp):
      str1 = "4gs:{gstr}: 4ps:{pstr}".format( gstr = bStr(gp[0]), 
                                                          pstr = bStr(gp[1]))
      return str1
#  c is number and this produces one binary formatted version of the number
def cStrBin(cin):
      str1 = "cin:{gstr}".format( gstr = bStr(cin))
      return str1
#  c is number and this produces one binary formatted version of the number
def cString(cin):
      str1 = "cin:{gstr:5x}".format( gstr = cin)
      return str1
#format a string in binary with 4 digits separated by a space
def bStr(a):
   str = ""
   while a > 0: 
     last4 = a&0xF;
     str = " {last:04b}".format(last = last4) + str;
     a = a >>4;
   return str 
     

def glnOutString(gp, out):
      str = "{gpstr}\ncout:{output:5x}".format(gpstr = gpString(gp), output =
		out)
      return str;
#print calculation steps to get g and p from ab and cin

def calcSumSteps(a, b, cin):
      N = 4 # number of partitions
      # print input
      print(abCinStrBin(a,b,cin));
      gp = makeGP(a,b);
      #print gp
      print("gpSums Cin original")
      print(gpStrBin(gp));
      (gpsums, c1, gpNsum) = calcGPSums(gp, cin, 4, 16)
      # combine digits
      gcComb = gpTupToNum(gpsums)
      print(gpSumStrBin(gcComb));
      print(cStrBin(combineDigits(c1)))
      assert gpNsum == gpsums[3:16:4]
      #combine  digits
      # gp of output of gln.
      gpNsumx = gpTupToNum(gpNsum) 
      (gpsumsX, cSums, gpNsumLast) = calcGPSums(gpNsumx, cin, 4, 4)
      # combine digits
      gcComb = gpTupToNum(gpsumsX)
      assert gpNsumLast == gpsumsX[3:16:4]
      print("Second Level of sums")
      print(gpStrBin(gpNsumx));
      print(gpSumStrBin(gcComb));
      # now can update cin because we have the sums of intermediate digits c4,
      # c8, c12
      cin_full = combineDigits(cSums);
      print(cStrBin(cin_full));
      # No redo the sums with the correct Cin
      print("gpSums Cin Updated")
      print(gpStrBin(gp));
      (gpsums, c1, gpNsum) = calcGPSums(gp, cin_full, 4, 16)
      # combine digits
      gcComb = gpTupToNum(gpsums)
      print(gpSumStrBin(gcComb));
      c1final = combineDigits(c1);
      print(cStrBin(c1final))
      # C1 now should be correct.
      # produce the 5 bit gp and cint to compare with Vivado
      gpNsum += gpNsumLast
      print("gp 5bit: ", end ='')
      gcComb5 = gpTupToNum(gpNsum)
      print(gpString(gcComb5), end = '');
      print("; ", end = '')
      print(cString(combineDigits(c1[N:16:N])))
      # check that our cin actually calculates the correct sum:
      sum = computeSum(gp, c1final)
      carry = computeCarryOneBit(gpNsumLast[-1], take_shift(cin, 1, 0))
      sum = sum + pow(2, 16) * carry
      # (sum, carry) = cla16(a, b, cin)
      assert sum  == a + b +take_shift(cin, 1, 0)
      print("Sum {sumx:d} computed with Cin matches".format( sumx = sum)) 


random.seed(132)
for _ in range(0):
      a = randint(0, 65535);
      b = randint(0, 65535);
      c = makeGP(a, b);
      print('a:  %6d;'% a, 'b%6d:'% b, '&: %6d; |: %6d' % c )

for _ in range(0):
      a = randint(0, 65535);
      b = randint(0, 65535);
      c = makeGP(a, b);
      print('a:  %6d;'% a, 'b%6d:'% b, '&: %6d; |: %6d' % c )
      a = randint(0, 65535);
      b = randint(0, 65535);
      cp = makeGP(a, b);
      print('c:  %6d;'% a, 'd%6d:'% b, '&: %6d; |: %6d' % cp )
      m = mergeGP(c, cp);
      print('Merged  g: %6d; p: %6d' % m)

# test shiftGP      
for _ in range(0):
      a = randint(0, 64);
      b = randint(0, 64);
      c = makeGP(a, b);
      print('a:  %6d;'% a, 'b%6d:'% b, '&: %6d; |: %6d' % c )
      n = randint(0, 3)
      d = shiftGP(c, n)
      print('shift :  %6d;'% n, '&: %6d; |: %6d' % d )

# test GLN
for i in range (0):
    n = 16
    max = pow(2, n) -1
    a = randint(0, max)
    b = randint(0, max)
    cin = randint(0, 1)
    print('a:  %6d;'% a, 'b%6d:'% b, 'carry in %2d'%cin )
    gp = makeGP(a, b);
   # print(gp)
    outT = gln(gp, cin, n);
    # print(outT)
    carry = computeCarryOneBit(outT[0], cin)
    allin = (cin,) + outT[1]
    # print('all carries:', end ='')
    #print(allin, end = '')
    carryAll = combineDigits(allin);
    # print ('or: %d '% carryAll)
    thisSum = computeSum(gp, carryAll) + carry * pow(2, n)
    ActualSum = a + b + cin
    print('actualSum: %6d;'% ActualSum, ' CalcSum %6d:'% thisSum, end ='')
    if  ActualSum == thisSum:
        print(' Success')
    else: 
        print(' Failure %d', i)

     
# test cla
for i in range (0):
    n = 16
    max = pow(2, n) -1
    a = randint(0, max)
    b = randint(0, max)
    cin = randint(0, 1)
    print('a:  %6d;'% a, 'b%6d:'% b, 'carry in %2d'%cin )
    (sum, carry) = cla16(a, b, cin); 
    thisSum = sum + carry * pow(2, n)
    ActualSum = a + b + cin
    print('actualSum: %6d;'% ActualSum, ' CalcSum %6d:'% thisSum, end ='')
    if  ActualSum == thisSum:
        print(' Success')
    else: 
        print(' Failure %d', i)

alist = readFileIntegers(testfile)
# test cla
success  = 0;
failure = 0;
for onelist in alist:
    n = 16
    max = pow(2, n) -1
    a = onelist[0]
    b = onelist[1]
    cin =onelist[2]
    print('a:  %6d;'% a, 'b%6d:'% b, 'carry in %2d'%cin )
    (sum, carry) = cla16_cinOnly(a, b, cin); 
    thisSum = sum # + carry * pow(2, n)
    ActualSum = a + b + cin
    print('Vivado Sum: %6s;'% hex(onelist[3]), 
            ' CalcSum %6s:'% hex(thisSum), end ='')
    if  onelist[3] == thisSum:
        print("success %d"%success)
        print(CGPString(onelist[3], thisSum));
        success+=1
    else: 
        print(' Fail  %d'%failure)
        print(abCinStr(a,b,cin));
        print(gpString(makeGP(a,b)))
        print(CGPString(onelist[3], thisSum));
        calcSumSteps(a, b, cin) 
        failure +=1;
        if failure == 6:
              break
print("\nsuccesses %d: "%success, "failures %d"%failure)



