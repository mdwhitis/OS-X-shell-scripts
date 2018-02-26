#!/bin/sh

# Set up for Chroot Environment
# by Michael Whtitis - University of Utah, Student Computing Labratories
# michael@scl.utah.edu

# Declarations

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"
toolList="/bin/sh /bin/ps /sbin/reboot /bin/cp /usr/bin/cd /bin/ls /bin/sleep /bin/test /bin/kill \
/bin/pwd /usr/bin/grep /usr/bin/touch /usr/local/bin/fsdiff /usr/local/bin/lapply /usr/bin/ulimit \
/bin/rm /usr/bin/scp /usr/local/bin/ktcheck /usr/sbin/chown /bin/launchctl \
/bin/expr /bin/cat /bin/ln /usr/sbin/chroot /usr/bin/tar /sbin/halt /bin/date /sbin/umount \
/usr/bin/killall /sbin/kextunload"
dependencyList="/usr/lib/dyld /usr/lib/system/libmathCommon.A.dylib /usr/lib/libSystem.B.dylib /usr/lib/libiconv.2.dylib \
/usr/local/lib/libfuse_ino64.2.dylib /usr/lib/libicucore.A.dylib /usr/lib/libobjc.A.dylib /usr/lib/libxml2.2.dylib \
/usr/lib/libauto.dylib /usr/lib/libstdc++.6.dylib"
markerFile="/tmp/.chrootlogicneeded"
searchList="/mach_kernel"
chrootJailLocation="/tmp/chrootjail"
PARPID="`ps -fe | grep Library/Xhooks/Modules/edu.utah.scl.radmind/run_radmind.pl | grep -v grep | awk '{print $2}'`"


# Turn off Daemons & Background Processes

kextunload -b com.apple.BootCache

/usr/bin/ulimit -n 2048

mkdir /Volumes/mount

rm /var/log/lapply_output.log
touch /var/log/lapply_output.log

# turn off spotlight indexing, softwareupdate, and fontserver, crashreport:
/usr/bin/mdutil -ai off
softwareupdate --schedule off
atsutil server -shutdown
defaults write com.apple.CrashReporter DialogType none

#stop lsregister
rm /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister

# Set up Chroot Envrionment

echo "Setting Up Chroot Envrionment. Copying Files..."

for x in ${toolList}; do 
	for y in `otool -LX $x | awk '{ print $1 }'`; do 
		dependencyList="${dependencyList} $y"; 
		
	done; 
done


for x in `for y in ${toolList} ${dependencyList}; do echo $y; done | sort -fu`; 
do 
   searchList="${searchList} $x"; 
done

for x in ${searchList}; do
   touch "${markerFile}"; 

   mkdir -p ${chrootJailLocation}/usr/lib/system
   mkdir -p ${chrootJailLocation}/bin
   mkdir -p ${chrootJailLocation}/sbin
   mkdir -p ${chrootJailLocation}/usr/bin
   mkdir -p ${chrootJailLocation}/usr/local/lib
   mkdir -p ${chrootJailLocation}/Library
   mkdir -p ${chrootJailLocation}/var/log
   mkdir -p ${chrootJailLocation}/var/radmind/client/10.6_os/
   mkdir -p ${chrootJailLocation}/mount
   mkdir -p ${chrootJailLocation}/private/var/tmp
   

   for x in ${searchList}; do
      ditto $x ${chrootJailLocation}$x
   done
done


# relink libraries for chroot
linklist="/usr/local/bin/loopback"
for x in ${linklist}; do 
	cp $x ${chrootJailLocation}$x.linked
	for y in `otool -LX $x | awk '{ print $1 }'`; do 
	     #echo $x $y
		/usr/bin/install_name_tool -change $y ${chrootJailLocation}$y ${chrootJailLocation}$x.linked;
	done; 
done

ditto  /Library/Xhooks/Modules/edu.utah.scl.radmind/update-reboot.sh ${chrootJailLocation}/usr/bin/

#ditto /var/radmind/client ${chrootJailLocation}/var/radmind/client

# create small transcript
cp /var/radmind/client/command.K /var/radmind/client/command.O

echo "k tech/michael/sync/01_os_10.6.K
k tech/michael/sync/03_xhooks_10.6.K

" > /var/radmind/client/command.K

##cd /
#/usr/local/bin/fsdiff -IA  ./ > /tmp/command.4
#grep +\ f /tmp/command.1  >  /tmp/command.2
#grep d\ ./ /tmp/command.1  | grep -v [-]\ d\ ./ >>  /tmp/command.2
#grep h\ ./ /tmp/command.1  | grep -v [-]\ h\ ./ >>  /tmp/command.2
#grep l\ ./ /tmp/command.1  | grep -v [-]\ l\ ./ >>  /tmp/command.2

#/usr/local/bin/lsort -I /tmp/command.2 > /tmp/command.3

#sed '1i\
#10.6_os/10.6.2.1_os_only_2010.02.19_bdm.T:
#' /tmp/command.3 > /tmp/command.4
#
#cp /tmp/command.4 ${chrootJailLocation}/var/lapply_input_1

#transcript 2



#/usr/local/bin/fsdiff -IA  ./ > /tmp/command.4
#grep +\ f /tmp/command.1  >  /tmp/command.2
#grep d\ ./ /tmp/command.1  | grep -v [-]\ d\ ./ >>  /tmp/command.2
#grep h\ ./ /tmp/command.1  | grep -v [-]\ h\ ./ >>  /tmp/command.2
#grep l\ ./ /tmp/command.1  | grep -v [-]\ l\ ./ >>  /tmp/command.2
#
#/usr/local/bin/lsort -I /tmp/command.2 > /tmp/command.3

#sed '1i\
#10.6_os/10.6.2.1_first_boot_2010.02.23_bdm.T:
#' /tmp/command.3 > /tmp/command.4

#cp /tmp/command.4 ${chrootJailLocation}/var/lapply_input_2

#cp /var/radmind/client/command.K ${chrootJailLocation}/var/radmind/client/command.K

# Make seprate directory tree and run basic OS update

mkdir /var/radmind/upgrade

cd /var/radmind/upgrade

echo "Running fsdiff/lapply..."
/usr/local/bin/fsdiff -IA ./ | /usr/local/bin/lapply -%ICFh155.97.17.135 

cp /var/radmind/client/command.O /var/radmind/client/command.K

cp /Library/Preferences/SystemConfiguration/preferences.plist /var/radmind/upgrade/Library/Preferences/SystemConfiguration/
cp /etc/sudoers  /var/radmind/upgrade/etc/sudoers

chmod -R 755 /var/radmind/upgrade/usr/local/bin/iHook.app

# mount root filesystem in chroot envrinoment usng loopbackfs

${chrootJailLocation}/usr/local/bin/loopback.linked  ${chrootJailLocation}/mount -omodules=threadid:subdir,subdir=/  -oallow_other,native_xattr,volname=LoopbackFS

sleep 5

# launch chroot envrionment 

/usr/sbin/chroot ${chrootJailLocation} /usr/bin/update-reboot.sh 2>&1 /var/log/run_radmind_update.log
#| /usr/bin/tee

/sbin/reboot -ln




