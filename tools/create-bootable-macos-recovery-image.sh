########################################################################################################################
#                                                bootableinstaller.com                                                 #
########################################################################################################################
osx_version_iso_filename="el-capitan-rescue.iso"
my_installesd="./ElCapitanInstallESD.img"

# Put bash in "strict mode"
set -u
set -e
set -x

if [ -f "./$osx_version_iso_filename" ]; then
  echo "'$osx_version_iso_filename' already exists"
  exit 0
fi

# Show commands as they are executed

if ! [ -f "./InstallESD.img" ]; then
    my_installesd="./InstallESD.img"
fi

if ! [ -f "$my_installesd" ]; then
        if ! [ -f "./InstallMacOSX/InstallMacOSX.pkg/InstallESD.dmg" ]; then
                if ! [ -f "./InstallMacOSX.img" ]; then
                        if ! [ -f "./InstallMacOSX.dmg" ]; then
                                echo "Error: 'InstallMacOSX.dmg' doest not exist."
                                echo "    Go to https://support.apple.com/en-us/HT206886"
                                echo "    In step 4 click 'Download OS X El Capitan'"
                        fi

                        # decompresses into a dd-like image
                        dmg2img InstallMacOSX.dmg -o ./InstallMacOSX.img
                        chmod a-w ./InstallMacOSX.img
                        # rm InstallMacOSX.dmg
                fi

		my_fullosx=$(sudo losetup --list | (grep InstallMacOSX.img || true))
                if ! [ -f "/mnt/InstallMacOSX/InstallMacOSX.pkg" ]; then
                        my_fullosx=$(sudo losetup --partscan --show --find InstallMacOSX.img)
                        echo "$my_fullosx"
                        sudo fdisk -l "$my_fullosx"
                        ls -l "$my_fullosx"p*

                        sudo partprobe $my_fullosx
                        sudo mkdir -p /mnt/InstallMacOSX
                        sudo mount "$my_fullosx"p2 -o ro,noatime /mnt/InstallMacOSX
                fi

                echo "Extracting /mnt/InstallMacOSX/InstallMacOSX.pkg"
                mkdir -p ./InstallMacOSX.tmp.d/
                pushd ./InstallMacOSX.tmp.d/
                        #LD_LIBRARY_PATH=../xar/xar/lib ../xar/xar/src/xar -xvf /mnt/InstallMacOSX/InstallMacOSX.pkg
			# TODO maybe use pzip / 7zip instead?
                        xar -xvf /mnt/InstallMacOSX/InstallMacOSX.pkg
                popd
                mv ./InstallMacOSX.tmp.d ./InstallMacOSX

                sudo umount /mnt/InstallMacOSX
                sudo losetup -d "$my_fullosx"
        fi

	if ! [ -f "./ElCapitanInstallESD.img" ]; then
		dmg2img ./InstallMacOSX/InstallMacOSX.pkg/InstallESD.dmg -o ./ElCapitanInstallESD.img
		chmod a-w ./ElCapitanInstallESD.img
	fi
        my_installesd=./ElCapitanInstallESD.img

        # TODO it's now safe to remove the big fat InstallMacOSX.*mg and ./InstallMacOSX/
fi

my_esd=$(sudo losetup --list | (grep InstallESD.img || true) | cut -d' ' -f1)
if ! [ -f "/mnt/InstallESD/BaseSystem.dmg" ]; then
        my_esd=$(sudo losetup --partscan --show --find "$my_installesd")
        echo "$my_esd"
        sudo fdisk -l "$my_esd"
        ls -l "$my_esd"p*

        sudo partprobe $my_esd
        sudo mkdir -p /mnt/InstallESD
        sudo mount "$my_esd"p2 -o ro,noatime /mnt/InstallESD
fi

if ! [ -f "./BaseSystem.img" ]; then
        dmg2img /mnt/InstallESD/BaseSystem.dmg -o ./BaseSystem.img
        chmod a-w ./BaseSystem.img
fi

my_base=$(sudo losetup --list | grep BaseSystem.img | cut -d' ' -f1)
if [ -z "$my_base" ]; then
        my_base=$(sudo losetup --partscan --show --find ./BaseSystem.img)
        echo "$my_base"
        sudo fdisk -l "$my_base"
        ls -l "$my_base"p*

        sudo partprobe $my_base
fi

my_empty=$(ls empty*img.bz2 | sort | head -1)
cp -rp "$my_empty" el-capitan-rescue.dd.img.bz2
bunzip2 el-capitan-rescue.dd.img.bz2

my_dd=$(sudo losetup --partscan --show --find el-capitan-rescue.dd.img)
echo "$my_dd"
sudo mac-fdisk -l "$my_dd"
ls -l "$my_dd"p*

sudo dd if="$my_base"p1 of="$my_dd"p2 bs=128M status=progress

sudo losetup -d "$my_dd"
mv el-capitan-rescue.dd.img el-capitan-rescue.iso

sudo umount /mnt/InstallESD
sudo losetup -d "$my_esd"

chmod a-w ./el-capitan-rescue.iso
echo "el-capitan-rescue.iso"