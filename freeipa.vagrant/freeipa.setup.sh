sudo sed -e 's|^mirrorlist=|#mirrorlist=|g' \
     -e 's|^#baseurl=http://mirror.centos.org|baseurl=https://mirrors.tuna.tsinghua.edu.cn|g' \
     -i.bak \
     /etc/yum.repos.d/CentOS-*.repo
sudo yum update -y

#yum -y install epel-release
#yum -y install rng-tools
#systemctl start rngd
#systemctl enable rngd

echo "192.168.122.122 ipa.ict-group.cn" | sudo tee -a /etc/hosts
sudo hostnamectl set-hostname ipa.ict-group.cn

#at docker host, enable ipv6
#echo "net.ipv6.conf.lo.disable_ipv6 = 0" | tee -a /etc/sysctl.conf
#echo "net.ipv6.conf.all.disable_ipv6 = 0" | tee -a /etc/sysctl.conf
#echo "net.ipv6.conf.default.disable_ipv6 = 0" | tee -a /etc/sysctl.conf
#sysctl -p
#echo 0 >/proc/sys/net/ipv6/conf/all/disable_ipv6
#echo 0 >/proc/sys/net/ipv6/conf/default/disable_ipv6
#echo 0 >/proc/sys/net/ipv6/conf/lo/disable_ipv6

sudo yum -y install dnf 
sudo dnf module enable idm:DL1 -y
sudo dnf distro-sync
sudo dnf install ipa-server -y

#sudo ipa-server-install --allow-zone-overlap --no-ntp -U --realm=ICT-GROUP.CN --ds-password=12345678 --admin-password=12345678
sudo ipa-server-install --allow-zone-overlap
