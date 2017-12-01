#!/bin/bash -x

# Macros
CND_CONF="${1}"
OUTPUT_BASENAME="${2}"

TOP=`pwd`
CND_DLIB_EXT=so
TMPDIRNAME=tmp-packaging
NBTMPDIR=${CND_CONF}/${TMPDIRNAME}
OUTPUT_PATH=${CND_CONF}/${OUTPUT_BASENAME}
PACKAGE_TOP_DIR=/usr/
PACKAGE_VERSION=package-version

# Functions
function checkPackageVersion
{
  if [ ! -r ${PACKAGE_VERSION} ]
  then
    exit 1
  fi
}

function checkReturnCode
{
    rc=$?
    if [ $rc != 0 ]
    then
        exit $rc
    fi
}
function makeDirectory
# $1 directory path
# $2 permission (optional)
{
    mkdir -p "$1"
    checkReturnCode
    if [ "$2" != "" ]
    then
      chmod $2 "$1"
      checkReturnCode
    fi
}
function copyFileToTmpDir
# $1 from-file path
# $2 to-file path
# $3 permission
{
    cp "$1" "$2"
    checkReturnCode
    if [ "$3" != "" ]
    then
        chmod $3 "$2"
        checkReturnCode
    fi
}

# Setup
cd "${TOP}"
checkPackageVersion
rm -rf ${NBTMPDIR}
mkdir -p ${NBTMPDIR}

# Copy files and create directories and links
cd "${TOP}"
makeDirectory "${NBTMPDIR}/usr/bin"
copyFileToTmpDir "${OUTPUT_PATH}" "${NBTMPDIR}${PACKAGE_TOP_DIR}bin/${OUTPUT_BASENAME}" 0755


# Create control file
cd "${TOP}"
CONTROL_FILE=${NBTMPDIR}/DEBIAN/control
rm -f ${CONTROL_FILE}
mkdir -p ${NBTMPDIR}/DEBIAN

cd "${TOP}"
echo "Package: $OUTPUT_BASENAME" >> ${CONTROL_FILE}
cat $PACKAGE_VERSION | sed 's/^/Version: /' >> ${CONTROL_FILE}
echo 'Architecture: amd64' >> ${CONTROL_FILE}
echo 'Maintainer: dishmaev <idax@rambler.ru>' >> ${CONTROL_FILE}
echo 'Description: Sample application for test automation build deb and rpm packages' >> ${CONTROL_FILE}
echo 'Section: misc' >> ${CONTROL_FILE}
echo 'Priority: optional' >> ${CONTROL_FILE}
#echo 'Depends: libqt5widgets5' >> ${CONTROL_FILE}
echo 'Depends: libboost-regex1.62.0' >> ${CONTROL_FILE}

# Create Debian Package
cd "${TOP}"
cd "${NBTMPDIR}/.."
dpkg-deb  --build ${TMPDIRNAME}
checkReturnCode
cd "${TOP}"
mkdir -p ${CND_CONF}/package
mv ${NBTMPDIR}.deb ${CND_CONF}/package/${OUTPUT_BASENAME}-`cat $PACKAGE_VERSION`.deb
checkReturnCode
echo Debian: ${CND_CONF}/package/${OUTPUT_BASENAME}-`cat $PACKAGE_VERSION`.deb

# Cleanup
cd "${TOP}"
rm -rf ${NBTMPDIR}
