########################################################################################################################
#                                                bootableinstaller.com                                                 #
########################################################################################################################

set -e
set -u
set -x

# Install HFS+ and dmg dependencies
if ! [ $(command -v mkfs.hfsplus) ] || ! [ $(command -v dmg2img) ]; then
	# Note: hfsplus and hfsutils are old and not necessary
	# Note: mac-fdisk (mac-fdisk-cross) is useful for debugging, but not required
	sudo apt install -y hfsprogs dmg2img
fi

# Install xar
if ! [ -f "xar/xar/src/xar" ]; then
        echo "Installing XAR from https://github.com/mackyle/xar.."

        sudo apt install -y build-essential autoconf
        sudo apt install -y libxml2-dev libssl-dev git
        rm -rf xar/
        git clone https://github.com/mackyle/xar
        pushd xar/xar
                sed -i.bak 's/OpenSSL_add_all_ciphers/OPENSSL_init_crypto/g' configure.ac
                ./autogen.sh --prefix=/usr/local
		make
		sudo make install
        popd
fi