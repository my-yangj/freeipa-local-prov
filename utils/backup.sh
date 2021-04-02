#!/usr/bin/bash

#mount
sudo cryptsetup open --type luks /dev/disk/by-uuid/a0dbe98e-1cf1-4e81-8974-62211febd0ac sda_crypt --key-file=/etc/keys/sda.luks  #/etc/crypttab
sudo vgchange -a y vg02
sudo mount /dev/mapper/vg02-backup /home/.backup #/etc/fstab
 
#deja-dup with existing setting currently home dir
deja-dup --backup

# backup /proj
ostree --repo=/proj/amd/.ostree summary -u
ostree --repo=/home/.backup/backup-proj_amd.ostree pull --mirror proj_amd

#unmount
sudo umount /home/.backup
sudo vgchange -a n vg02
sudo cryptsetup close sda_crypt
