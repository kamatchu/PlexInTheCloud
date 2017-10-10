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
#sed -i '/\[CouchPotato\]/,/^$/ s/\[\[movie\]\]/\[\[movies\]\]/' /home/$username/nzbget/scripts/autoProcessMedia.cfg

## Enable CouchPotato post-processing
sed -i '/\[\[movie\]\]/,/^$/ s/enabled = .*/enabled = 1/' /home/$username/nzbget/scripts/autoProcessMedia.cfg

## Add your CouchPotato API key
### Copy the api key from the CP config file
cpAPI=$(cat /home/$username/.couchpotato/settings.conf | grep "api_key = ................................" | cut -d, -f2 | grep "api_key = ................................" | cut -d= -f2)

### Write the API key to nzbget.conf
sed -i "/\[\[movie\]\]/,/^$/ s/apikey = .*/apikey = $cpAPI/" /home/$username/nzbget/scripts/autoProcessMedia.cfg

## Delete Failed
sed -i '/\[\[movie\]\]/,/^$/ s/delete_failed = .*/delete_failed = 1/' /home/$username/nzbget/scripts/autoProcessMedia.cfg

## Set the watch directory
sed -i "
   /^\[CouchPotato]$/,/^$/!b
   /^[[:blank:]]\{4\}\[\[movie]]/,/^$/s|^\([[:blank:]]\{8\}watch_dir\) = .*|\1 = /home/$username/nzbget/completed/movies|
" /home/$username/nzbget/scripts/autoProcessMedia.cfg


# nzbToSickbeard Post-Processing Settings
## Enable CouchPotato post-processing
sed -i '/\[\[tv\]\]/,/^$/ s/enabled = .*/enabled = 1/' /home/$username/nzbget/scripts/autoProcessMedia.cfg

## Set Username
sed -i "/\[\[tv\]\]/,/^$/ s/username = .*/username = $username/" /home/$username/nzbget/scripts/autoProcessMedia.cfg

## Set Password
sed -i "/\[\[tv\]\]/,/^$/ s/password = .*/password = $passwd/" /home/$username/nzbget/scripts/autoProcessMedia.cfg

## Delete Failed
sed -i '/\[\[tv\]\]/,/^$/ s/delete_failed = .*/delete_failed = 1/' /home/$username/nzbget/scripts/autoProcessMedia.cfg

## Set the watch directory
sed -i "
   /^\[SickBeard]$/,/^$/!b
   /^[[:blank:]]\{4\}\[\[tv]]/,/^$/s|^\([[:blank:]]\{8\}watch_dir\) = .*|\1 = /home/$username/nzbget/completed/tv|
" /home/$username/nzbget/scripts/autoProcessMedia.cfg


# nzbToMylar Post-Processing Settings
## Enable Mylar post-processing
sed -i '/\[\[comics\]\]/,/^$/ s/enabled = .*/enabled = 1/' /home/$username/nzbget/scripts/autoProcessMedia.cfg

## Set Username
sed -i "/\[\[comics\]\]/,/^$/ s/username = .*/username = $username/" /home/$username/nzbget/scripts/autoProcessMedia.cfg

## Set Password
sed -i "/\[\[comics\]\]/,/^$/ s/password = .*/password = $passwd/" /home/$username/nzbget/scripts/autoProcessMedia.cfg

## Set the watch directory
sed -i "
   /^\[Mylar]$/,/^$/!b
   /^[[:blank:]]\{4\}\[\[comics]]/,/^$/s|^\([[:blank:]]\{8\}watch_dir\) = .*|\1 = /home/$username/nzbget/completed/comics|
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
