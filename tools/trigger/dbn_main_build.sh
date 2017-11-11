#!/bin/sh

###header

VAR_PARAMETERS='$1 script name without extenstion, $2 suite, $3 project repository, $4 build version, $5 output package file name'

if [ "$#" != "5" ]; then echo "Call syntax: $(basename "$0") $VAR_PARAMETERS"; exit 1; fi
if [ -f ${1}.ok ]; then rm ${1}.ok; fi
exec 1>${1}.log
exec 2>${1}.err

###function

checkRetVal(){
  if [ "$?" != "0" ]; then exit 1; fi
}

###body

echo "Current build suite: $2"

uname -a

mkdir build
checkRetVal
git clone $3 build
checkRetVal

echo 'for test' > $5

##test

if [ ! -f "$5" ]; then echo "Output file $5 not found"; exit 1; fi

###finish

echo 1 > ${1}.ok
exit 0
