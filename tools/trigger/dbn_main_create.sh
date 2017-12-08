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
  sudo sed '1s/^/# /' -i /etc/apt/sources.list.d/public-apt-dishmaev.list
  checkRetValOK
  #activate required repository
  if [ "$1" = "rel" ]; then
    cat /etc/apt/sources.list.d/public-apt-dishmaev.list | grep 'apt stable main' | sed 's/# //' | sudo tee /etc/apt/sources.list.d/public-apt-dishmaev-stable.list
    checkRetValOK
  elif [ "$1" = "tst" ]; then
    cat /etc/apt/sources.list.d/public-apt-dishmaev.list | grep 'apt testing main' | sed 's/# //' | sudo tee /etc/apt/sources.list.d/public-apt-dishmaev-testing.list
    checkRetValOK
  elif [ "$1" = "dev" ]; then
    cat /etc/apt/sources.list.d/public-apt-dishmaev.list | grep 'apt unstable main' | sed 's/# //' | sudo tee /etc/apt/sources.list.d/public-apt-dishmaev-unstable.list
    checkRetValOK
  else #run suite
    return
  fi
}

checkDpkgUnlock(){
  local CONST_LOCK_FILE='/var/lib/dpkg/lock'
  local CONST_TRY_NUM=3 #try num for long operation
  local CONST_TRY_LONG=30 #one try long
  local CONST_SLEEP_LONG=5 #sleep long
  local VAR_COUNT=$CONST_TRY_LONG
  local VAR_TRY=$CONST_TRY_NUM
  echo "Check /var/lib/dpkg/lock"
  while sudo fuser $CONST_LOCK_FILE >/dev/null 2>&1; do
    echo -n '.'
    sleep $CONST_SLEEP_LONG
    VAR_COUNT=$((VAR_COUNT-1))
    if [ $VAR_COUNT -eq 0 ]; then
      VAR_TRY=$((VAR_TRY-1))
      if [ $VAR_TRY -eq 0 ]; then  #still not powered on, force kill vm
        echo "failed wait while unlock $CONST_LOCK_FILE. Check another long process using it"
        exit 1
      else
        echo ''
        echo "Still locked $CONST_LOCK_FILE, left $VAR_TRY attempts"
      fi;
      VAR_COUNT=$CONST_TRY_LONG
    fi
  done
  echo ''
  return 0
}

###body

echo "Current create suite: $2"

uname -a

#install packages
if [ "$2" = "run" ]; then
  checkDpkgUnlock
  sudo apt -y install build-essential
  checkRetValOK
  sudo apt -y install libboost-all-dev
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
  dpkg-deb --version >&3
  checkRetValOK
fi

###finish

echo 1 > ${1}.ok
exit 0
