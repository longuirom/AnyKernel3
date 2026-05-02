### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=
do.devicecheck=0
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
'; } # end properties

# shell variables
if [ -e /dev/block/platform/13520000.ufs/by-name/BOOT ]; then
	block=/dev/block/platform/13520000.ufs/by-name/BOOT;
elif [ -e /dev/block/platform/13520000.ufs/by-name/boot ]; then
	block=/dev/block/platform/13520000.ufs/by-name/boot;
fi

. tools/ak3-core.sh;

AK_FOLDER=/tmp/anykernel
mount -o rw,remount -t auto /system_root > /dev/null

rm /data/adb/ksud

split_boot;
ui_print "- Installing Kernel";
flash_boot;

ui_print "- Installation finished successfully";
