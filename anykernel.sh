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

split_boot;
unpack_ramdisk;

# Replace existing ramdisk modules with modules shipped in the AnyKernel zip.
find "$RAMDISK" -type f -name '*.ko' -exec rm -f {} \;
mkdir -p "$RAMDISK/modules" || abort "Failed to create ramdisk module directory";
for module in $(find "$AKHOME/modules" -type f -name '*.ko'); do
    module_name=${module##*/}
    cp -f "$module" "$RAMDISK/modules/$module_name" || abort "Failed to add module to ramdisk";
    chmod 0644 "$RAMDISK/modules/$module_name" || abort "Failed to set module permissions";
    ui_print "- Added ramdisk module: /modules/$module_name";
done;

ui_print "- Installing Kernel";
write_boot;

ui_print "- Installation finished successfully";
