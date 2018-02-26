#!/bin/sh
# Moves small OS into place and reboots from chroot envrionment
# by Michael Whtitis - University of Utah, Student Computing Labratories
# michael@scl.utah.edu
#
/usr/bin/ulimit -n 2048

# set up links for chroot envitonment

ln -s /private/var/tmp /tmp
ln -s /private/var /var

rm -rf /mount/System/Library/Launch*
rm -rf /mount/System/Library/Extensions/ATI*
rm -rf /mount/System/Library/Caches/*
rm -rf /mount/System/Library/Perl/*

rm -rf /mount/Library/Xhooks/*

#rm -rfv /mount/Library /mount/usr

cd /mount/var/radmind/upgrade

# move small 10.6 OS into root using tar

tar cf - * | ( cd /mount; tar xvfp -)

#rm -rf /mount/var/radmind/upgrade

#echo "Running lapply..."
#/usr/local/bin/fsdiff -IAK /var/radmind/client/command.K  ./ | /usr/local/bin/lapply -%ICFh155.97.17.135 

#/var/lapply_input_1
#/usr/local/bin/lapply -%ICFh155.97.17.135 /var/lapply_input_2


date > /mount/var/log/ps.log
ps -fe >> /mount/var/log/ps.log


# clean up update weirdness

cp /mount/Library/Xhooks/Modules/xhooks/bin/runhooks_upgrade.sh /mount/Library/Xhooks/Modules/xhooks/bin/startuplate.hook

rm /mount/System/Library/CoreServices/coreservicesd
cd /mount/System/Library/CoreServices/
ln -s ../Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework/Support/coreservicesd coreservicesd

cd /mount/System/Library/Perl/lib/5.10 
rm libperl.dylib
ln -s ../../5.10.0/darwin-thread-multi-2level/CORE/libperl.dylib libperl.dylib

cd /mount/System/Library/Perl/lib/5.8 
rm libperl.dylib
ln -s ../../5.8.9/darwin-thread-multi-2level/CORE/libperl.dylib libperl.dylib

cd /mount/Library/Xhooks/Modules/xhooks/hooks
rm *
ln -s ../../edu.utah.scl.radmind/SEE_1_radmind.pl SEE_1_radmind.pl SEE_1_radmind.pl SEE_1_radmind.pl
ln -s ../../edu.utah.scl.radmind/SEE_2_run_postmaintenance.pl SEE_2_run_postmaintenance.pl 
ln -s ../../edu.utah.scl.status/SED_find_errors.pl SED_find_errors.pl

chown root:wheel /mount/usr/standalone/bootcaches.plist

rm -rf /mount/var/db/dyld/dyld*
#/usr/bin/update_dyld_shared_cache -force -root /mount 

#kextcache -a i386 -K /mount/mach_kernel -m /mount/System/Library/Extensions.mkext /mount/System/Library/Extensions

cd /mount/System/Library/LaunchDaemons
ls -1 |  grep -v loginwindow | while read i; do /bin/launchctl unload -w /mount/System/Library/LaunchDaemons/$i ; done



touch /mount/var/log/OS_10.6_update_finish
rm /mount/Library/Preferences/Xhooks/triggerfiles/*
touch /mount/Library/Preferences/Xhooks/triggerfiles/run_maintenance

cp -rp /var/log/* /mount/var/log/
rm -rf /mount/System/Library/Caches/*


/sbin/umount -f /mount

killall kextcache

#cd /mount/System/Library/LaunchDaemons
#ls -1 |  grep -v loginwindow | grep -v UserNotificationCenter | while read i; do /bin/launchctl unload -w /mount/System/Library/LaunchDaemons/$i ; done


echo "Rebooting..."

/sbin/reboot -lq

#/bin/sleep 900

#/mount/sbin/mount_smbfs //155.97.17.164/classes/vmware /mount/Volumes/mount

date >> /mount/var/log/ps.log
ps -fe >> /mount/var/log/ps.log

/sbin/reboot -ln


#/bin/sleep 10

#/bin/kill -9 -1
