#!/bin/bash

echo "This install script is meant for Stone Monarch and will cause you to loose access"
echo "to your server if you are not them."
echo ""
echo ""
echo ""
echo "Do you wish to continue?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done

echo "Setting time so to EST"
timedatectl set-timezone America/Toronto

echo "Install XCP-ng Tools? (This requires user input)"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) mount /dev/cdrom /mnt; /mnt/Linux/install.sh; break;;
        No ) break;;
    esac
done

echo "Updating apt"
apt update
apt upgrade -y
apt install -y mosh apt-listchanges bsd-mailx libpam-google-authenticator

echo "Config sshd"
# mv /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
cp sshd_config /etc/ssh/sshd_config
sshd -t

echo "Setting auto updates for all"
# mv /etc/apt/apt.conf.d/50unattended-upgrades /etc/apt/apt.conf.d/upgrades.bak
cp 50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades

echo "Setting up PAM for 2FA"
# mv /etc/pam.d/sshd /etc/pam.d/sshd.bak
cp sshd /etc/pam.d/sshd

echo "Updating apt for sanity"
apt update
apt upgrade -y

echo "Please run 'google-authenticator' and reboot after"
