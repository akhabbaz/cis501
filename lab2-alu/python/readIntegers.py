
# will find the first number in a string.  It will ignore leading and trailing
# not digits.
def findfirstNumber(x):
     indx =0
     for dig in x:
         if dig.isdigit():
             substr = x[indx:]
             lastindx = 0
             for let in substr:
                 if not let.isdigit():
                      return substr[:lastindx]
                 lastindx +=1;
             return substr[:lastindx];
         indx+=1
     return ''


# read file of integers.  Each line is a text file and it first separates the
# line by spaces.  It converts up to one number in each word, where a number is
# a contiguous set of integers (and possibly the sign).  This returns one list
# of integers for every row in the file. Returns a list of lists. 
def readFileIntegers(filename = "testAnswers2.txt"):
  with open(filename, 'r') as reader:
      line = reader.readline()
      a = []
      while line !='':
          token = line.split();
          #print(token)
          thislist= [int(findfirstNumber(word)) for word in token if
			len(findfirstNumber(word)) != 0]
          a.append(thislist)
          line = reader.readline()
      return a;  
  
#print(findfirstNumber("hello123"))
#print(findfirstNumber("124"))
#print(findfirstNumber("my test"))

