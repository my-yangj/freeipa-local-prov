docker-compose up
docker-compose run --rm -u centos centos bash

# install rh toolset to mounted /opt
# https://www.softwarecollections.org/en/scls/rhscl/go-toolset-7/
# sudo yum install centos-release-scl
# sudo yum install rh-ruby26 -y
# sudo yum install llvm-toolset-7 -y
# sudo yum install rh-git218 -y
# sudo yum install devtoolset-7 -y
# sudo yum install rh-perl526 -y
# sudo yum install rh-python36 -y
# sudo yum install devtoolset-8 -y
# sudo yum install rust-toolset-7 -y
# sudo yum install go-toolset-7 -y

# cmake-3.19.5  gh-cli  go-1.16  python-3.6.13  sbt-1.4.7-0

# pip3 install --upgrade pip -i http://mirrors.aliyun.com/pypi/simple --trusted-host mirrors.aliyun.com
# pip3 install numpy scipy matplotlib ipython jupyter pandas sympy nose -i http://mirrors.aliyun.com/pypi/simple --trusted-host mirrors.aliyun.com
# pip3 install scikit-learn -i http://mirrors.aliyun.com/pypi/simple --trusted-host mirrors.aliyun.com
