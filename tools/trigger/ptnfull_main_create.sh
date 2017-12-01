#!/bin/sh

###header

readonly VAR_PARAMETERS='$1 script name without extenstion, $2 suite'

if [ -r ${1}.ok ]; then rm ${1}.ok; fi
exec 1>${1}.log
exec 2>${1}.err
exec 3>${1}.tst
if [ "$#" != "2" ]; then echo "Call syntax: $(basename "$0") $VAR_PARAMETERS"; exit 1; fi

###function

checkRetValOK(){
  if [ "$?" != "0" ]; then exit 1; fi
}

#$1 suite
activeSuiteRepository(){
  #deactivate default repository
  sudo sed 's/enabled=1/enabled=0/' -i /etc/yum.repos.d/public-yum-dishmaev-release.repo
  checkRetValOK
  #activate required repository
  if [ "$1" = "rel" ]; then
    sudo sed 's/enabled=0/enabled=1/' -i /etc/yum.repos.d/public-yum-dishmaev-release.repo
    checkRetValOK
  elif [ "$1" = "tst" ]; then
    sudo sed 's/enabled=0/enabled=1/' -i /etc/yum.repos.d/public-yum-dishmaev-test.repo
    checkRetValOK
  elif [ "$1" = "dev" ]; then
    sudo sed 's/enabled=0/enabled=1/' -i /etc/yum.repos.d/public-yum-dishmaev-develop.repo
    checkRetValOK
  else #run suite
    return
  fi
}

###body

echo "Current create suite: $2"

uname -a

#install packages
if [ "$2" = "run" ]; then
  sudo tdnf -y install boost-devel
  checkRetValOK
fi

#active suite repository
activeSuiteRepository "$2"

##test

if [ "$2" = "run" ]; then
  make --version >&3
  checkRetValOK
  gcc --version >&3
  checkRetValOK
  c++ --version >&3
  checkRetValOK
  rpmbuild --version >&3
  checkRetValOK
fi

###finish

echo 1 > ${1}.ok
exit 0
