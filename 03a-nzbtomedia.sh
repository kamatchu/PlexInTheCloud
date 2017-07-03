#!/bin/bash
source vars

## INFO
# This script installs and configures nzbToMedia post-processing scripts
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
apt-get install -y unrar unzip tar p7zip ffmpeg

#######################
# Install
#######################
here="$(pwd)"
cd /home/$username/nzbget/scripts
git init
git remote add origin https://github.com/clinton-hall/nzbToMedia.git
git pull origin master
cd "$here"

#######################
# Configure
#######################
cp /opt/nzbget/scripts/* /home/$username/nzbget/scripts/
cp /home/$username/nzbget/scripts/autoProcessMedia.cfg.spec /home/$username/nzbget/scripts/autoProcessMedia.cfg

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
