sudo umount /home/.backup
sudo vgchange -a n vg02
sudo cryptsetup close sda_crypt
