sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://mirror.centos.org|baseurl=https://mirrors.tuna.tsinghua.edu.cn|g' \
    -i.bak \
    /etc/yum.repos.d/CentOS-*.repo
#yum -y install epel-release
yum update -y
#yum -y install rng-tools
#systemctl start rngd
#systemctl enable rngd

echo "172.17.0.2  ipa.ict-group.cn" | tee -a /etc/hosts
#echo "::1         localhost localhost6"  | tee -a /etc/hosts
echo "ipa.ict-group.cn" | tee -a /etc/hostname

#at docker host, enable ipv6
#echo "net.ipv6.conf.lo.disable_ipv6 = 0" | tee -a /etc/sysctl.conf
#echo "net.ipv6.conf.all.disable_ipv6 = 0" | tee -a /etc/sysctl.conf
#echo "net.ipv6.conf.default.disable_ipv6 = 0" | tee -a /etc/sysctl.conf
#sysctl -p
#echo 0 >/proc/sys/net/ipv6/conf/all/disable_ipv6
#echo 0 >/proc/sys/net/ipv6/conf/default/disable_ipv6
#echo 0 >/proc/sys/net/ipv6/conf/lo/disable_ipv6

dnf module enable idm:DL1 -y
dnf distro-sync
dnf install ipa-server -y

#yum -y install ipa-server 
#--tt-ipa-server-install --allow-zone-overlap --no-ntp -U --realm=ICT-GROUP.CN --ds-password=12345678 --admin-password=12345678

#using 'docker-compose run freeipa bash' to debug
