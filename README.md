# my dockerfiles

## overview
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

## dockerfiles: 
- centosDockerfile: container run on terminal server; mount the data-volume, create a vnc for user to connect.
  (user can create container using podman, and connect into it through vnc. script for freeipa client install).
  
      ```bash
        docker run --volume /data:/data:rw -v /tmp/.X11-unix:/tmp/.X11-unix --env DISPLAY=unix$DISPLAY -it ubuntu bash
      ```
  
- freeipaDockerfile: provide directory/authentication service (I got its dns conflict with ubuntu host, thus dns is not in docker but using dnsmasq in host.)
  it should be only one instance in the pool.
  see: https://github.com/freeipa/freeipa-container
  
- jenkinsDockerfile: provide jenkins service; jenkins can start docker at host.

      ```bash
        docker run -d \
       -v <your_jenkins_home_in_host>:/var/jenkins_home \
       -v /var/run/docker.sock:/var/run/docker.sock \
       -v /usr/local/bin/docker:/bin/docker \
       -p 8080:8080 -p 50000:50000 \
       --name <my_jenkins> jenkins/jenkins:lts
     ```
- mysqlDockerfile
  mysql see: https://github.com/docker-library/mysql/tree/master/8.0

- giteaDockerfile
  gitea see: https://docs.gitea.io/en-us/install-with-docker/
  gitea backup/restore see: https://gist.github.com/sinbad/4bb771b916fa8facaf340af3fc49ee43
  also refhttps://github.com/go-gitea/gitea/tree/master/docker
  
- podman & skopeo
- podman support rootless container so that non-privilege  it specifies the image location as below, (location must be host disk). otherwise container/images are under user's home.
  ```toml
    [storage]
    driver = "overlay"
    runroot = "/mnt/backup/"
    graphroot = "/mnt/backup/"
    rootless_storage_path = "/mnt/backup/"
  ```
- skopeo can used to inspect the image, manipunate its storage
  
- dnsmasq: to support dhcp and pxe, and automatically deploy the computing node. 
  (it is desired to wake up the backup server; run a backup and log a report; and power off the backup server).
  tbd https://stackoverflow.com/questions/38816077/run-dnsmasq-as-dhcp-server-from-inside-a-docker-container
  
## setup
1. management node setup see: [host_setup.md](host_setup.md)
  - tools installed on host
    - docker install w/ docker-volumn plugin
    - podman
    - misc tools
  - docker_compose file
    - docker compose can start as daemon, the generated image has special signiture so that it doesn't rebuild the image each time. 
    
2. compute node setup,
  - docker/podman install w/ nfs volume
  - nextflow 
    local job is dispatched with nextflow pipeline (use podman rootless or docker container);  
    
3. job dispatch
  - user connected to the terminal server (terminal service container run inside cluster)
  - user run their job through nf pipeline at local node, which creates more containers
  - user submit their job/pipeline through jenkins and jenkins distribute the jobs to more nodes


