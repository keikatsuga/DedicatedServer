# This is a script to install and configure basic archlinux on online.net server
# Just install the debian first and then boot into rescue mode
# This is usable as of August 2014, unless online.net or archlinux change something.


# Downloading sfs image from ovh (may need to change for better speed depending on your location, see https://www.archlinux.org/download)
wget http://archlinux.mirrors.ovh.net/archlinux/iso/2014.09.03/arch/x86_64/airootfs.sfs

# unsquash image. Make sure squashfs-tools already installed
unsquashfs -d /squashfs-root airootfs.sfs

# create temp arch system to chroot into
mkdir /arch
mount -o loop /squashfs-root/airootfs.img /arch
mount -t proc none /arch/proc
mount -t sysfs none /arch/sys
mount -o bind /dev /arch/dev
mount -o bind /dev/pts /arch/dev/pts
cp -L /etc/resolv.conf /arch/etc
mkdir /arch/run/shm

# chroot into the temp arch environment
chroot /arch bash

# setup disk configuration. This part assume the partition are already made.
# If haven't already, take a look at https://wiki.archlinux.org/index.php/Partitioning
# The partition is of course depend on you but in this example I will use:
#	/dev/sda1	/	20G-ish, can be lower. 10G or 15 maybe.
#	/dev/sda2	/home   The rest of what available after deducting / and swap
#	/dev/sda3	swap    1 or 2 G. I don't think there's a need for swap anyway when the ram is 8Gb or more.
mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/sda2
mkswap /dev/sda3

# mount the /dev/sda so that we can start install arch on it
mount /dev/sda1 /mnt
mkdir /mnt/home
mount /dev/sda2 /mnt/home
mkswap /dev/sda3

# since this is the first time pacman run, it will need some key
# we use haveged to feed random number generator to pacman so that it will be faster or else it will takes 10-15 minutes to complete it
haveged -w 1024
pacman-key --init
pacman-key --populate archlinux
pkill haveged

# installing archlinux to disk
# you may add your preferred shell (zsh,fish, etc). If unsure, just leave it as it is because it will still install bash.
# openssh is no brainer. if you don't install it, you won't get access to your dedicated box
# syslinux the bootloader. See https://wiki.archlinux/org/index.php/boot_loaders for more info.
pacstrap /mnt base base-devel syslinux openssh

# generate fstab so that we can actually boot it after all this finish
genfstab -U -p /mnt >> /mnt/etc/fstab

# chroot into your newly created system to configure it. chrootception, get it?
arch-chroot /mnt

# hostname, change this to whatever you prefer or you can also just leave it default
echo "onlineServer" >> /etc/hostname

# locale, change it if you want. Just make sure you understand what this is if you want to change it.
# See https://wiki.archlinux.org/index.php/Beginner's_Guide#Locale for more info
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=\"en_US.UTF-8\"" >> /etc/locale.conf
export LANG=en_US.UTF-8
locale-gen

# this is where it set the time for the dedicated server,change however you like it
# I prefer to use the same time as my country time.
# the format is: ln -s  /usr/share/zoneinfo/ZONE/SUBZONE /etc/localtime
# check for list of zone with #ls /usr/share/zoneinfo/
# check for list of subzone with #ls /usr/share/*YOURSELECTEDZONE*/ eg. ls /usr/share/Europe/ 
# See https://wiki.archlinux.org/index.php/Beginner's_Guide#Time_zone for more info
# Line below use the Paris localtime as the server time
ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime

# mkinitcpio, creating initial ramdisk environment. Read https://wiki.archlinux.org/index.php/Mkinitcpio for more info
# tl;dr version: if you're not doing this,server not gonna boot.
mkinitcpio -p linux

# configure the bootloader
# this is dependent on where your / is. mine is at sda1
sed -i -e "s/sda3/sda1/g" /boot/syslinux/syslinux.cfg
syslinux-install_update -iam

# make the root password
passwd

# create main user & password
# /bin/zsh if you install zsh earlier or /bin/whatever for whatever
# onlineUser is the username. change if you dont like it
useradd -g users -m -s /bin/bash onlineUser
passwd onlineUser

# enable openssh or else how the f you want to ssh into the server after it reboot
systemctl enable sshd.service

# enable the network. Not sure if this is required or not but hey, it's not gonna blow up if you're wrong
systemctl enable dhcpcd.service

## TADA.. Fresh new up-to-date unmolested archlinux server unlike on some certain K provider where they install their own kernel on our server, wtf?
## So now you got a bare server with only ssh port open and all other port shut off.
## What to do after this you ask me? see https://wiki.archlinux.org/index.php/General_recommendations for recommendation of course.
