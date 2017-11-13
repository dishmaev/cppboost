#!/bin/sh

###header

VAR_PARAMETERS='$1 script name without extenstion, $2 suite, $3 build file name'

if [ "$#" != "3" ]; then echo "Call syntax: $(basename "$0") $VAR_PARAMETERS"; exit 1; fi
if [ -f ${1}.ok ]; then rm ${1}.ok; fi
exec 1>${1}.log
exec 2>${1}.err

###function

checkRetVal(){
  if [ "$?" != "0" ]; then exit 1; fi
}

###body

echo "Current deploy suite: $2"

uname -a

suto apt -y update
sudo dpkg -i $3
#checkRetVal
sudo apt -y install -f
checkRetVal
#sudo apt update
#checkRetVal
#sudo apt -y install cppboost
#checkRetVal

##test

cppboost
checkRetVal

###finish

echo 1 > ${1}.ok
exit 0
