#!/bin/bash
source vars

## INFO
# This script installs and configures rclone.
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
apt-get install -y git unionfs-fuse unzip curl

#######################
# Install
#######################
wget https://downloads.rclone.org/rclone-current-linux-amd64.zip
unzip rclone-current-linux-amd64.zip
cd rclone-*-linux-amd64
cp rclone /usr/sbin/
chown root:root /usr/sbin/rclone
chmod 755 /usr/sbin/rclone

#######################
# Configure
#######################
cat << EOF
rclone config

    n       # New remote
    GDRIVE  # name
    7       # Choose "Google Drive"
            # press enter, leave blank for Client Id
            # press enter, leave blank for Client Secret
    n       # press n for headless setup
            # Sign in to your Google account using the browser that rclone opened on your personal computer.
            # Copy & paste the code that appears on the screen to your remote server.
    y       # to accept everything, "Yes this is OK"
    q       # Quit
EOF

echo ''
echo "Did you add your rclone GDRIVE mount in previous step?"
echo ''
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) echo 'You need to do that before we can move on, exiting.'; exit;;
    esac
done
