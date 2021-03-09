# my dockerfiles

This repository contains scripts to setup a devops environment based on freeipa and docker. It's aimed to work on a small cluster of computers, and a single node should work fine. The env is composed of a management node and a number of computing nodes. The management node works as a computer node in a single node env. 
- The management node provides services of networking/storage, user authertication, job-dispatch and etc. ???Fail-over redundance??? 
- The computing nodes provide the computing power based on docker/vagrant.
The environment could be deployed on either a local cluster or a cloud-based cluster. A mix-mode cluster(with both local and cloud machines) may or may not work.

In the below is the key software/technology being used, and ubuntu 20.04 is the bassOS on both the management node and computing nodes.
- linux/lvm2/nfs
- docker-compose for freeipa/mysql/gitea/jenkins
- dnsmasq w/pxe to bootup computing nodes
- docker/vagrant images/boxes to run on computing nodes

centosDockerfile:     serve user terminal
freeipa.Dockerfile:   directory service (I got its dns conflict with ubuntu host, thus dns is not in docker but using dnsmasq in host.

