hardware_dir="../hardwares/yosemite"
my_installesd="$hardware_dir/InstallESD.img"
my_esd=$(sudo losetup --list | (grep InstallESD.img || true) | cut -d' ' -f1)
if ! [ -f "/mnt/InstallESD/BaseSystem.dmg" ]; then
        my_esd=$(sudo losetup --partscan --show --find "$my_installesd")
        echo "$my_esd"
        sudo fdisk -l "$my_esd"
        ls -l "$my_esd"p*
cd
        sudo partprobe $my_esd
        sudo mkdir -p /mnt/InstallESD
        sudo mount "$my_esd"p2 -o ro,noatime /mnt/InstallESD
fi

if ! [ -f "./$hardware_dir/BaseSystem.img" ]; then
        dmg2img /mnt/InstallESD/BaseSystem.dmg -o "./$hardware_dir/BaseSystem.img"
        chmod a-w "./$hardware_dir/BaseSystem.img"
fi