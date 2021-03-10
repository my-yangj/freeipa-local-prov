# my dockerfiles

This repository contains scripts to setup a devops environment based on freeipa and docker. It's target to a small cluster of computers, though a single node should work fine. The env contains a management node and a number of computing nodes. The management node also works as a computer node in a single node env. 
- The management node:
  provides services of networking/storage, user authertication, job-dispatch and etc.  -tbd-Failover redundance. 
- The computing nodes 
  provide the computing power based on docker/podman.

In the below is the key software/technology being used, and ubuntu 20.04 is the bassOS on both the management node and computing nodes.
- linux/lvm2/nfs
- docker-compose for freeipa/mysql/gitea/jenkins
- dnsmasq w/pxe to bootup computing nodes -tbd-
- podman/docker/vagrant images/boxes to run on computing nodes

dockerfile: 
- centosDockerfile
  user terminal service

- freeipaDockerfile:   
  directory service (I got its dns conflict with ubuntu host, thus dns is not in docker but using dnsmasq in host.
  see: https://github.com/freeipa/freeipa-container
  
- mysqlDockerfile
  mysql see: https://github.com/docker-library/mysql/tree/master/8.0

- giteaDockerfile
  gitea see: https://docs.gitea.io/en-us/install-with-docker/
  gitea backup/restore see: https://gist.github.com/sinbad/4bb771b916fa8facaf340af3fc49ee43

- bkupDockerfile
  a podman container is used for data backup. data is backup into the container's images.
  a backup user is created to run the backup container at user mode. 
  the container configure file specifies the backup location, and it can be a backup disk or network disk.
  ```toml
    [storage]
    driver = "overlay"
    runroot = "/mnt/backup/"
    graphroot = "/mnt/backup/"
    rootless_storage_path = "/mnt/backup/"
  ````
  - the dockerfile mount host volumes to be backup
  - a. create a container; b. stop the container and commit the image c. start the container
  - skopeo can used to inspect the image.
  
- dnsmasq:
  tbd https://stackoverflow.com/questions/38816077/run-dnsmasq-as-dhcp-server-from-inside-a-docker-container

host setup,
1. docker install w/ docker-volumn plugin
2. podman
3. misc tools

