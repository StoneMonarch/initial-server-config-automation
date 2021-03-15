#!/bin/bash

sshd_text = "Include /etc/ssh/sshd_config.d/*.conf
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
PermitRootLogin no
AuthenticationMethods publickey
PubkeyAuthentication yes
AllowUsers stone-monarch
HostbasedAuthentication no
IgnoreRhosts yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM no
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp	/usr/lib/openssh/sftp-server
PasswordAuthentication no"

upgrades_text = "Unattended-Upgrade::Allowed-Origins {
	\"\${distro_id}:\${distro_codename}\";
	\"\${distro_id}:\${distro_codename}-security\";
	\"\${distro_id}ESMApps:\${distro_codename}-apps-security\";
	\"\${distro_id}ESM:\${distro_codename}-infra-security\";
	\"\${distro_id}:\${distro_codename}-updates\";
};
Unattended-Upgrade::Package-Blacklist {
};
Unattended-Upgrade::DevRelease \"auto\";
Unattended-Upgrade::Remove-Unused-Kernel-Packages \"true\";
Unattended-Upgrade::Remove-Unused-Dependencies \"true\";
Unattended-Upgrade::Automatic-Reboot \"true\";
Unattended-Upgrade::Automatic-Reboot-Time \"03:00\";"

echo "This install script is meant for Stone Monarch and will cause you to loose access"
echo "to your server if you are not them."
echo ""
echo "Do you wish to continue?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done

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

echo "Config sshd"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
echo $sshd_text > /etc/ssh/sshd_config
sshd -t

echo "Setting auto updates for all"
cp /etc/apt/apt.conf.d/50unattended-upgrades /etc/apt/apt.conf.d/upgrades.bak
echo $upgrades_text > /etc/apt/apt.conf.d/50unattended-upgrades

echo "Updating apt for sanity"
apt update
apt upgrade -y

echo "Reboot now?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) shutdown -r now;;
        No ) exit;;
    esac
done