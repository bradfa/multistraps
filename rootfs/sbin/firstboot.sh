#!/bin/sh
# /sbin/firstboot.sh

# On first boot up, run dpkg --configure -a, delete the /boot/firstboot file,
# remount the file system as read-only, and exec init.

# Default languages
export LC_ALL=C LANGUAGE=C LANG=C

# No human interaction
export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

# Remount root filesystem as rw, ensure /proc mounted
mount -o remount,rw /
mount /proc

# Must do this before dpkg --configure -a or else dash and bash conflict
/var/lib/dpkg/info/dash.preinst install

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# dpkg --configure -a runs twice as ifconfig doesn't configure correctly
# the first time through
dpkg --configure -a
mount proc -t proc /proc
dpkg --configure -a

# Delete /boot/firstboot and multistrap provided sources.list files
rm -v /boot/firstboot

# Reboot!
sync
sync
exec reboot
