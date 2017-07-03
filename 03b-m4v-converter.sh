#!/bin/bash
source vars

## INFO
# This script installs and configures Digiex's https://github.com/Digiex/M4V-Converter scripts
##

#######################
# Pre-Install
#######################
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Execute 'sudo su' to swap to the root user." 
   exit 1
fi

#######################
# Dependencies
#######################
apt-get remove -y ffmpeg

apt-get install -y autoconf automake build-essential libass-dev libfdk-aac-dev libmp3lame-dev libx264-dev libfreetype6-dev libtheora-dev libtool libvorbis-dev pkg-config texinfo wget yasm zlib1g-dev

# We have to compile ffmpeg since the default Ubuntu version leaves out some important/good quality codecs
mkdir /root/ffmpeg_sources
cd /root/ffmpeg_sources
wget http://www.nasm.us/pub/nasm/releasebuilds/2.13.01/nasm-2.13.01.tar.bz2
tar xjvf nasm-2.13.01.tar.bz2
cd nasm-2.13.01
./autogen.sh
PATH="/root/bin:$PATH" ./configure --prefix="/root/ffmpeg_build" --bindir="/root/bin"
PATH="/root/bin:$PATH" make
make install

cd /root/ffmpeg_sources
wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2
cd ffmpeg
PATH="/root/bin:$PATH" PKG_CONFIG_PATH="/root/ffmpeg_build/lib/pkgconfig" ./configure \
--prefix="/root/ffmpeg_build" \
--pkg-config-flags="--static" \
--extra-cflags="-I/root/ffmpeg_build/include" \
--extra-ldflags="-L/root/ffmpeg_build/lib" \
--bindir="/root/bin" \
--enable-gpl \
--enable-libass \
--enable-libfdk-aac \
--enable-libfreetype \
--enable-libmp3lame \
--enable-libtheora \
--enable-libvorbis \
--enable-libx264 \
--enable-nonfree
PATH="/root/bin:$PATH" make
make install
hash -r

sudo apt autoremove

## move the fucking binaries to /usr/bin/


#######################
# Install
#######################
here="$(pwd)"
mkdir /home/$username/nzbget/scripts/m4v-converter
cd /home/$username/nzbget/scripts/m4v-converter
git init
git remote add origin https://github.com/Digiex/M4V-Converter.git
git pull origin master
cd "$here"

#######################
# Configure
#######################

#######################
# Permissions
#######################
chown -R $username:$username /home/$username/nzbget/scripts

#######################
# Misc.
#######################
# Restart NZBget
systemctl stop nzbget
systemctl start nzbget
