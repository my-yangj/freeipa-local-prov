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
- podman/docker/vagrant run on computing nodes

## dockerfiles: 
these dockerfiles below are used to generate local maintained container images, if image with same functionality are available from public docker image registry, those image could be used and retire or simply the local dockerfiles.

- centosDockerfile: 
this container run on terminal server, mount the data-volume, create a vnc for user to connect. it is an alternative if a user dont like the default vnc-server on the terminal server directly.  the user can create container by using podman, and connect into it through vnc. otherwise user could start vnc service on terminal server directly if the default desktop gui works for them.  
  
      ```bash
        docker run --volume /data:/data:rw -v /tmp/.X11-unix:/tmp/.X11-unix --env DISPLAY=unix$DISPLAY -it ubuntu bash
      ```
the terminal servers are DMZ computers which have two network interfaces, with one connected with cluster and another open to outside world. user can only connect from outside. firewall/port-forwarding could be enforced on termal server e.g.
   -- external nic has public ip and domain name
   -- vpn connect is supported through wireguard 
   -- user connect through vnc to vnc-server run on terminal server
   -- on terminal server, user can use resources inside the cluster
  
- freeipaDockerfile: 
provide directory/authentication service (I got its dns conflict with ubuntu host, thus dns is not in docker but using dnsmasq in host.)
it should be only one instance in the pool. see: https://github.com/freeipa/freeipa-container
prefer to use the official image freeipa/freeipa-server:centos-?

- jenkinsDockerfile: 
provide jenkins service; jenkins can use docker daemon at a node thus can distribute workload to cluster. Jenkins also supports distribute workload with ssh (ssh agent).
      ```bash
        docker run -d \
       -v <your_jenkins_home_in_host>:/var/jenkins_home \
       -v /var/run/docker.sock:/var/run/docker.sock \
       -v /usr/local/bin/docker:/bin/docker \
       -p 8080:8080 -p 50000:50000 \
       --name <my_jenkins> jenkins/jenkins:lts
     ```
- mysqlDockerfile
mysql is required by gitea see: https://github.com/docker-library/mysql/tree/master/8.0

- giteaDockerfile
  gitea see: https://docs.gitea.io/en-us/install-with-docker/
  gitea backup/restore see: https://gist.github.com/sinbad/4bb771b916fa8facaf340af3fc49ee43
  also ref https://github.com/go-gitea/gitea/tree/master/docker
  
## podman instead of docker
master node has the pre-installed tools exports to work nodes with nfs. when a user wants extra tool or need different work enviornment (all nodes are ubuntu20.04), they could create rootless container with podman.
support rootless container so that non-privilege  it specifies the image location as below, (location must be host disk). otherwise container/images are under user's home.
  ```toml
    [storage]
    driver = "overlay"
    runroot = "/mnt/backup/"
    graphroot = "/mnt/backup/"
    rootless_storage_path = "/mnt/backup/"
  ```
  
- skopeo can used to inspect the image, manipunate its storage
  
## dnsmasq: to support dhcp and pxe and automatically deploy the computing node (-tbd-) 
  (it is desired to wake up the backup server; run a backup and log a report; and power off the backup server).
  tbd https://stackoverflow.com/questions/38816077/run-dnsmasq-as-dhcp-server-from-inside-a-docker-container
  
# setup
1. master node setup see: [host_setup.md](host_setup.md)
  - tools installed on host
    - docker install w/ docker-volumn plugin
    - podman
    - site tools 
    - conda
  - docker_compose file
    - docker compose can start as daemon, the generated image has special signiture so that it doesn't rebuild the image each time. 
    
2. compute node setup,
  - docker/podman install w/ nfs volume
  - nextflow 
    local job is dispatched with nextflow pipeline (could use podman rootless) on the node
  - compute nodes take workload from jenkins
    
3. work flow
  - user connects to the terminal server
  - user runs their job through nf pipeline at local node, which could creates more container locally or remotely(with podman remote).
  - or user submits their job/pipeline into jenkins which delivers jobs to cluster
  - common dir (nfs exported from master node) for tools / projects data;
