#!/bin/sh

###header

readonly VAR_PARAMETERS='$1 script name without extenstion, $2 suite, $3 build tar.gz file name'

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

mkdir deploy
checkRetVal
tar -xvf $3 -C deploy/
checkRetVal
cd deploy
checkRetVal

#manually install packages
sudo yum -y install boost-regex
for VAR_CUR_PACKAGE in ./*.rpm; do
  if [ ! -r "$VAR_CUR_PACKAGE" ]; then continue; fi
  sudo rpm -i $VAR_CUR_PACKAGE
  checkRetVal
done

cd $HOME

##test

cppboost
checkRetVal

###finish

echo 1 > ${1}.ok
exit 0