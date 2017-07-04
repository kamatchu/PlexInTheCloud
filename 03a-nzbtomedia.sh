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

## CouchPotato
## Write CouchPotato API to nzbget.conf so it can send post-processing requests
### Copy the api key from the CP config file
cpAPI=$(cat /home/$username/.couchpotato/settings.conf | grep "api_key = ................................" | cut -d= -f 2)

### Cut the single blank space that always gets added to the front of $cpAPI
cpAPInew="$(sed -e 's/[[:space:]]*$//' <<<${cpAPI})"

### Write the API key to nzbget.conf
sed -i "s/^#cpsapikey=.*/cpsapikey=$cpAPInew/g" /home/$username/nzbget/scripts/nzbToCouchPotato.py

# Basic defaults to get post-processing working
sed -i 's/^#auto_update=.*/auto_update=1/g' /home/$username/nzbget/scripts/nzbToCouchPotato.py
sed -i 's/^#cpsCategory=.*/cpsCategory=movies/g' /home/$username/nzbget/scripts/nzbToCouchPotato.py
sed -i 's/^#cpsdelete_failed=.*/cpsdelete_failed=1/g' /home/$username/nzbget/scripts/nzbToCouchPotato.py
sed -i 's/^#getSubs=.*/getSubs=1/g' /home/$username/nzbget/scripts/nzbToCouchPotato.py
sed -i "s/^#subLanguages=.*/subLanguages=$openSubtitlesLang/g" /home/$username/nzbget/scripts/nzbToCouchPotato.py
sed -i "s|^#cpswatch_dir=.*|cpswatch_dir=/home/$username/nzbget/completed/movies|g" /home/$username/nzbget/scripts/nzbToCouchPotato.py

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
