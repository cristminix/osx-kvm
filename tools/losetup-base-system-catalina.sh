my_base=$(sudo losetup --list | grep BaseSystem.img | cut -d' ' -f1)
if [ -z "$my_base" ]; then
        my_base=$(sudo losetup --partscan --show --find ./BaseSystem.img)
        echo "$my_base"
        sudo fdisk -l "$my_base"
        ls -l "$my_base"p*

        sudo partprobe $my_base
fi

my_dd=catalina-rescue.dd.img
echo "$my_dd"
sudo fdisk -l "$my_dd"
ls -l "$my_dd"p*

sudo dd if="$my_base"p1 of="$my_dd" bs=128M status=progress