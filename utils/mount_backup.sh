sudo cryptsetup open --type luks /dev/disk/by-uuid/a0dbe98e-1cf1-4e81-8974-62211febd0ac sda_crypt --key-file=/etc/keys/sda.luks  #added into /etc/crypttab
sudo vgchange -a y vg02
sudo mount /dev/mapper/vg02-backup /home/.backup
