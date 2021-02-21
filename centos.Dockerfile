FROM centos:7
RUN yum install epel-release -y && yum update -y
RUN yum install tigervnc-server net-tools openbox xterm xfce4-terminal tint2 sudo which wget curl emacs sudo java-1.8.0-openjdk-devel zlib-devel -y
RUN yum groupinstall "Development Tools"  -y
RUN (adduser ubu) && (usermod -G wheel ubu) && (echo '123456' | passwd --stdin ubu)

