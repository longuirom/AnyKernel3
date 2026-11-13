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

# Add the SELinux mode selector to the boot ramdisk without changing the
# existing module installation or kernel flashing flow.
SELINUX_PROP_DIR="$RAMDISK/system/etc/ramdisk"
SELINUX_PROP_FILE="$SELINUX_PROP_DIR/build.prop"
mkdir -p "$SELINUX_PROP_DIR" || abort "Failed to create SELinux property directory";
[ -f "$SELINUX_PROP_FILE" ] || : > "$SELINUX_PROP_FILE" || abort "Failed to create SELinux property file";
command -v getevent >/dev/null 2>&1 || abort "getevent is unavailable; cannot read volume keys";

current_mode=$(file_getprop "$SELINUX_PROP_FILE" ro.bootimage.permissive);
if [ "$current_mode" = "1" ]; then
    current_mode=Permissive;
else
    current_mode=Enforcing;
fi
ui_print "- Current SELinux mode: $current_mode";
ui_print "- Volume Up: Permissive";
ui_print "- Volume Down: Enforcing";
while :; do
    event=$(getevent -lc 1 2>/dev/null);
    case "$event" in
        *KEY_VOLUMEUP*DOWN*) mode=1; mode_name=Permissive; break;;
        *KEY_VOLUMEDOWN*DOWN*) mode=0; mode_name=Enforcing; break;;
    esac
done
patch_prop "$SELINUX_PROP_FILE" ro.bootimage.permissive "$mode";
ui_print "- Selected SELinux mode: $mode_name";

rm -f "$SPLITIMG/kernel_dtb";

ui_print "- Installing Kernel";
write_boot;

ui_print "- Installation finished successfully";
