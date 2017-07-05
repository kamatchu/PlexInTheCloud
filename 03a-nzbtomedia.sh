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

# Turn on nzbToMedia auto_update
sed -i '/\[General\]/,/^$/ s/auto_update = .*/auto_update = 1/' /home/$username/nzbget/scripts/autoProcessMedia.cfg

# nzbToCouchPotato Post-Processing Settings
## Change the default category from movie to movies
sed -i '/\[CouchPotato\]/,/^$/ s/\[\[movie\]\]/\[\[movies\]\]/' /home/$username/nzbget/scripts/autoProcessMedia.cfg

## Enable CouchPotato post-processing
sed -i '/\[\[movies\]\]/,/^$/ s/enabled = .*/enabled = 1/' /home/$username/nzbget/scripts/autoProcessMedia.cfg

## Add your CouchPotato API key
### Copy the api key from the CP config file
cpAPI=$(cat /home/$username/.couchpotato/settings.conf | grep "api_key = ................................" | cut -d= -f 2)

### This is some crazy bash black magic that will return only the first string of our variable
### It's needed since my creation of the cpAPI var isn't perfect and returns too much cruft
set -- $cpAPI

### Write the API key to nzbget.conf
sed -i "/\[\[movies\]\]/,/^$/ s/apikey = .*/apikey = $1/" /home/$username/nzbget/scripts/autoProcessMedia.cfg

### More bash black magic to unset the earlier black magic stuff
shift && shift && shift

## Delete Failed
sed -i '/\[\[movies\]\]/,/^$/ s/delete_failed = .*/delete_failed = 1/' /home/$username/nzbget/scripts/autoProcessMedia.cfg

## Set the watch directory
sed -i "
   /^\[CouchPotato]$/,/^$/!b
   /^[[:blank:]]\{4\}\[\[movies]]/,/^$/s|^\([[:blank:]]\{8\}watch_dir\) = .*|\1 = /home/$username/nzbget/completed/movies|
" /home/$username/nzbget/scripts/autoProcessMedia.cfg


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
