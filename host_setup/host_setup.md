## disk
```bash
# Disk 
# /etc/crypttab
nvme0n1p3_crypt UUID=a75f363c-6c38-49d1-b38a-651cbccef2dc none luks,discard
nvme1n1_crypt   UUID=b8065912-7567-4b21-a07a-fa9da28eb990 /etc/keys/nvme1n1.luks luks
# nvme0n1p3 is passwd protected.
# nvme1n1_crypt has passwd and key (/etc/keys/nvme1n1.luks)
# -tt- sda is sata disk which is noisy, mount it when necessary and comment off below line
# -tt- sda_crypt       UUID=a0dbe98e-1cf1-4e81-8974-62211febd0ac /etc/keys/sda.luks luks


# below setup /dev/sda as backup vol, it has passwd and key (/etc/keys/sda.luks)
cryptsetup luksFormat /dev/sda
dd if=/dev/urandom of=/etc/keys/sda.luks bs=4k count=1
cryptsetup luksAddKey /dev/sda /etc/keys/sda.luks   
# -tt- open sda when necessary
# -tt- cryptsetup open --type luks /dev/sda disk8t --key-file=/etc/keys/sda.luks  #added into /etc/crypttab

# below create pv/vg/lv 
pvcreate /dev/mapper/sda_crypt
vgcreate vg02 /dev/mapper/sda_crypt
lvcreate -L 2000g --thinpool tp01 vg02
lvcreate -V 2000g --thin -n backup vg02/tp01
mkfs.ext4 /dev/mapper/vg02-backup

# fstab
# -tt-noauto /dev/mapper/vg02-backup /home/.backup auto defaults,nofail,x-systemd.device-timeout=9
```

## docker
```bash
#0. install docker 

#1. https://github.com/containers/docker-lvm-plugin
apt-get install golang go-md2man
go env -w GOPROXY=https://goproxy.cn,direct
make
sudo apt-get install xfsprogs  #it use xfs
sudo systemctl start docker-lvm-plugin
# e.g. docker volume create -d lvm --opt size=0.2G --opt thinpool=mythinpool --name thin_vol

#2. podman
. /etc/os-release
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key | sudo apt-key add -
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install podman
# (Ubuntu 18.04) Restart dbus for rootless podman
systemctl --user restart dbus
sudo apt-get -y install buildah skopeo

#3. install gh cli: https://github.com/cli/cli/blob/trunk/docs/install_linux.md
```
