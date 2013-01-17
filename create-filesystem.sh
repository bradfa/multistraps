#!/bin/bash
# create-filesystem.sh

# MUST BE RUN AS ROOT, using sudo is OK.

# Create a Debian root file system and copy all required files
# into it from the ./rootfs directory.  Resulting file system will be
# owned by root.

# If a second argument is provided, copy the created file system there.
# This is useful for outputting the created file system directly
# onto an SD card.  If output dir is not provided, the resulting file
# system will be located in ./debian-armel

# If you're just creating a chroot, DON'T USE THIS!
# Just use multistrap directly as it'll do what you want.

# Make sure root is running us
ROOT_UID=0
E_NOTROOT=87
if [ "$UID" -ne "$ROOT_UID" ]
then
  echo "Must be root to run this script."
  exit $E_NOTROOT
fi

# Expect at least 1 param of what to use as mutlistrap config
if [ $# -lt 1 ]
then
	echo "Usage: $0 <multistrap.config> [outputdir]"
	exit $E_INVAL
fi

# Find the directory where this script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo Script is located at $DIR

# Create a dir in /tmp to build temporarily, before copying to destination
TMPDIR="/tmp/multistrap-$(date +%s)"
mkdir -pv ${TMPDIR}

# Create file system with multistrap
MULTISTRAP_CONF=$1
multistrap -f $MULTISTRAP_CONF -d ${TMPDIR}

# Copy files from ./rootfs to file system
cp -vr $DIR/rootfs/* ${TMPDIR}/

# Make sure sbin/firstboot.sh is executable since dpkg --configure needs to
# be run on first boot.
chmod +x ${TMPDIR}/sbin/firstboot.sh

# Copy resulting file system somewhere?
if [ $# == 2 ]
then
  OUTPUTDIR=$2
  if [ "/" == "$OUTPUTDIR" ]
  then
    echo Copying file system to / is a BAD IDEA!
    exit 1
  fi
  echo Copying resulting file system to $OUTPUTDIR
  cp -rp ${TMPDIR}/* $OUTPUTDIR/
  # Delete $TMPDIR
  rm -rf ${TMPDIR}
  sync
else
  echo File system is located in ${TMPDIR}
fi

