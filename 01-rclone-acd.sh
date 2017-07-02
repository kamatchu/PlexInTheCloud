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
apt-get install -y git unionfs-fuse unzip

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
    1       # Choose "Google Drive"
            # press enter, leave blank for Client Id
            # press enter, leave blank for Client Secret
    n       # press n for headless setup
            # On your personal computer with rclone installed, type: rclone authorize "amazon cloud drive" (at a terminal prompt, quotes included in the command)
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

#######################
# Structure
#######################
mkdir -p /home/$username/$remote
mkdir -p /home/$username/$local
mkdir -p /home/$username/$overlayfuse
mkdir -p /home/$username/scripts

#######################
# Helper Scripts
#######################
tee "/home/$username/scripts/rcloneMount.sh" > /dev/null <<EOF
#!/bin/bash
rclone mount \
    --read-only \
    --allow-non-empty \
    --dir-cache-time 1m \
    --acd-templink-threshold 0\
    --checkers 16 \
    --no-check-certificate \
    --quiet \
    --stats 0 \
    $remote: /home/$username/$remote/ & 

sleep 3s
unionfs-fuse -o cow,max_readahead=2000000000 /home/$username/$local=RW:/home/$username/$remote=RO /home/$username/$overlayfuse 
EOF

#######################
# Systemd Service File
#######################
tee "/etc/systemd/system/rcloneMount.service" > /dev/null <<EOF
[Unit]
Description=Mount Google Drive 
Documentation=https://acd-cli.readthedocs.org/en/latest/
After=network-online.target

[Service]
Type=forking
User=$username
ExecStart=/bin/bash /home/$username/scripts/rcloneMount.sh
ExecStop=/bin/umount /home/$username/$remote 
ExecStop=/bin/umount /home/$username/$overlayfuse
Restart=on-abort

[Install]
WantedBy=default.target
EOF

#######################
# Permissions
#######################
chmod +x /home/$username/scripts
chown -R $username:$username /home/$username/scripts
chown -R $username:$username /home/$username/$local
chown -R $username:$username /home/$username/$remote
chown -R $username:$username /home/$username/$overlayfuse


#######################
# Autostart
#######################
systemctl daemon-reload
systemctl start rcloneMount.service
systemctl enable rcloneMount.service
