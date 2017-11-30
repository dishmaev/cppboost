#!/bin/sh

###header

readonly VAR_PARAMETERS='$1 script name without extenstion, $2 suite, $3 build tar.gz file name'

if [ "$#" != "3" ]; then echo "Call syntax: $(basename "$0") $VAR_PARAMETERS"; exit 1; fi
if [ -r ${1}.ok ]; then rm ${1}.ok; fi
exec 1>${1}.log
exec 2>${1}.err

###function

checkRetValOK(){
  if [ "$?" != "0" ]; then exit 1; fi
}

###body

echo "Current deploy suite: $2"

uname -a

sudo apt -y update
checkRetValOK

if [ "$1" = "rel" ]; then
  #install packages from personal repository
  sudo apt -y install cppboost
  checkRetValOK
else # tst,dev
  mkdir deploy
  checkRetValOK
  tar -xvf $3 -C deploy/
  checkRetValOK
  cd deploy
  checkRetValOK
  #manually install packages
  for VAR_CUR_PACKAGE in ./*.deb; do
    if [ ! -r "$VAR_CUR_PACKAGE" ]; then continue; fi
    sudo apt -y install $VAR_CUR_PACKAGE
#    checkRetValOK
  done
  #check all dependences
  sudo apt -y install -f
  checkRetValOK

  cd $HOME
fi

##test

cppboost
checkRetValOK

###finish

echo 1 > ${1}.ok
exit 0
