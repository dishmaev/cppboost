#!/bin/sh

###header

readonly VAR_PARAMETERS='$1 script name without extenstion, $2 suite, $3 target, $4 build tar.gz file name'

if [ -r ${1}.ok ]; then rm ${1}.ok; fi
exec 1>${1}.log
exec 2>${1}.err
exec 3>${1}.tst
if [ "$#" != "4" ]; then echo "Call syntax: $(basename "$0") $VAR_PARAMETERS"; exit 1; fi

###function

checkRetValOK(){
  if [ "$?" != "0" ]; then exit 1; fi
}

###body

echo "Current deploy suite: $2"

uname -a

sudo tdnf -y makecache
checkRetValOK

if [ "$1" = "rel" ]; then
  install packages from personal repository
  sudo tndf -y install $3
  checkRetValOK
else # tst,dev
  mkdir deploy
  checkRetValOK
  tar -xvf $4 -C deploy/
  checkRetValOK
  cd deploy
  checkRetValOK
  #manually install packages
  for VAR_CUR_PACKAGE in ./*.rpm; do
    if [ ! -r "$VAR_CUR_PACKAGE" ]; then continue; fi
    sudo rpm -i $VAR_CUR_PACKAGE
    checkRetValOK
  done
#  TO-DO check dependences
#  sudo apt -y install -f
#  checkRetValOK

  cd $HOME
fi

##test

$3 --version >&3
checkRetValOK

###finish

echo 1 > ${1}.ok
exit 0
