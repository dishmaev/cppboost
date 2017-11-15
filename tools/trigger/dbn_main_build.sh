#!/bin/sh

###header

readonly VAR_PARAMETERS='$1 script name without extenstion, $2 suite, $3 build version, $4 output tar.gz file name'

if [ "$#" != "4" ]; then echo "Call syntax: $(basename "$0") $VAR_PARAMETERS"; exit 1; fi
if [ -r ${1}.ok ]; then rm ${1}.ok; fi
exec 1>${1}.log
exec 2>${1}.err

###function

checkRetVal(){
  if [ "$?" != "0" ]; then exit 1; fi
}

#$1 suite
getConfigName(){
    if [ "$1" = "dev" ] || [ "$1" = "tst" ]; then
      echo 'Debug'
    elif [ "$1" = "rel" ]; then
      echo 'Release'
    else #error
      exit 1
    fi
}

###body

echo "Current build suite: $2"

uname -a

VAR_SUITE=$(getConfigName "$2") || exit 1
mkdir build
checkRetVal
tar -xvf *.tar.gz -C build/
checkRetVal
cd build
checkRetVal
make -f Makefile CONF=${VAR_SUITE}_APT clean
checkRetVal
make -f Makefile CONF=${VAR_SUITE}_APT
checkRetVal
bash -x nbproject/Package-${VAR_SUITE}_APT.bash
checkRetVal
tar -cvf $HOME/$4 -C dist/${VAR_SUITE}_APT/GNU-Linux/package .
checkRetVal

cd $HOME

##test

if [ ! -f "$4" ]; then echo "Output file $4 not found"; exit 1; fi

for VAR_CUR_PACKAGE in $HOME/build/dist/${VAR_SUITE}_APT/GNU-Linux/package/*.deb; do
  if [ ! -r "$VAR_CUR_PACKAGE" ]; then continue; fi
  dpkg-deb -I $VAR_CUR_PACKAGE
  checkRetVal
done

###finish

echo 1 > ${1}.ok
exit 0
