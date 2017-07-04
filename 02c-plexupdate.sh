#!/bin/bash
source vars

## INFO
# This script installs plexrequests
##

#######################
# Pre-Install
#######################
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Execute 'sudo su' to swap to the root user." 
   exit 1
fi

#######################
# Install
#######################
here="$(pwd)"
mkdir /home/$username/scripts/plexupdate
cd /home/$username/scripts/plexupdate
git init
git remote add origin https://github.com/mrworf/plexupdate.git
git pull origin master
cd "$here"

#######################
# Systemd Service File
#######################
tee "/etc/systemd/system/plexupdate.service" > /dev/null <<EOF
[Unit]
Description=PlexUpdate
After=plexmediaserver.service

[Service]
ExecStart=/home/$username/scripts/plexupdate/plexupdate.sh -a -d -p -s -U
EOF

# Systemd timer file
tee "/etc/systemd/system/plexupdate.timer" > /dev/null <<EOF
[Unit]
Description=Run the plex updater daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF

#######################
# Autostart
#######################
systemctl daemon-reload
systemctl start plexupdate.timer
systemctl enable plexupdate.timer
systemctl start plexupdate.service
