#!/bin/bash

set -e -u

# Locale
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "LC_COLLATE=C" >> /etc/locale.conf

# virtual console
echo "KEYMAP=us" > /etc/vconsole.conf

# Time and clock
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc --utc

# virtual console
echo "KEYMAP=us" > /etc/vconsole.conf

# hostname
echo "peux-os" > /etc/hostname

# root and live user
usermod -s /bin/fish root

cp -aT /etc/skel/ /root/

useradd -m -p "" -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /bin/fish liveuser
#chmod 750 /etc/sudoers.d
chmod 440 /etc/sudoers.d/g_wheel
chown -R liveuser:users /home/liveuser

# Uncomment mirrors and amend journald
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf


## repo update

rm -rf /etc/pacman.d/gnupg
pacman-key --init
pacman-key --populate archlinux



sudo pacman -Sy

freshclam
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal xfce4-terminal


# Enable services
systemctl enable choose-mirror.service
#systemctl set-default multi-user.target
systemctl enable sddm-plymouth.service
systemctl enable NetworkManager.service
systemctl enable wpa_supplicant.service
systemctl start NetworkManager.service

# will not take effect during live-installation
plymouth-set-default-theme -R bgrt-liquid
