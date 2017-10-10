#!/bin/bash
source vars

## INFO
# This script installs and configures plexdrive5.
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
wget https://github.com/dweidenfeld/plexdrive/releases/download/5.0.0/plexdrive-linux-amd64
mv plexdrive-linux-amd64 /usr/bin/plexdrive5

#######################
# Structure
#######################
mkdir -p /home/$username/$remote
mkdir -p /home/$username/$local
mkdir -p /home/$username/$overlayfuse
mkdir -p /home/$username/scripts

#######################
# Systemd Service File
#######################
tee "/etc/systemd/system/plexdrive5.service" > /dev/null <<EOF
[Unit]
Description=Plexdrive mount
AssertPathIsDirectory=/home/$username/$remote
After=network-online.target

[Service]
Type=simple
User=chrisanthropic
ExecStart=/usr/bin/plexdrive5 mount --fuse-options=allow_other /home/$username/$remote
ExecStop=/bin/fusermount -uz /home/$username/$remote
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

#######################
# Permissions
#######################
chown root:root /usr/bin/plexdrive5
chmod 755 /usr/bin/plexdrive5

#######################
# Autostart
#######################
systemctl daemon-reload
systemctl enable plexdrive5.service
