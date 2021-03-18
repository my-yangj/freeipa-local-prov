# container image build
  with spec in docker_compose.yml, the below are the steps to build container images.

## start local docker registry
   - using named volume in docker-compose.yml "docker_registry:/var/lib/registry"
     ```
     docker volume create -d lvm --name docker_registry --opt thinpool=tp03 --opt size=50G #registry
     docker volume create -d lvm --name ipa-data --opt  thinpool=tp03 --opt size=1G  #freeipa 
     ```

   - if no cert setup, then add {"insecure-registries":["localhost:5000"]} to daemon.json (skopeo refuse connecting such a registry)
     ```
     docker-compose up --build registry #build and run docker registry
     ```

   - copy docker image from remote registry to local registry using docker
     ```
     docker pull registry.centos.org/centos:7 && docker tag registry.centos.org/centos:7 localhost:5000/centos:7 && docker push localhost:5000/centos:7
     ```

   - setup certification-enabled registry
     ```
     openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key -x509 -days 365 -out certs/domain.crt
     cp domain.crt /usr/local/share/ca-certificates/localhost.crt && update-ca-certificates     

     # enable enbironment REGISTRY_HTTP_TLS_CERTIFICATE and REGISTRY_HTTP_TLS_KEY docker_compose.yml
     # here 'localhost' is used as CN and get x509: certificate relies on legacy Common Name field which requires
     #see https://docs.docker.com/registry/insecure/

     export GODEBUG="x509ignoreCN=0 
     ```
     
## pull required image to local, and manipunite local registry
   - skopeo copy docker://ubuntu docker://localhost:5000/ubuntu

   - skopeo can not list images in registry, using curl instead see https://stackoverflow.com/questions/31251356/how-to-get-a-list-of-images-on-docker-registry-v2
     ```
     curl --cacert domain.crt https://myregistry:5000/v2/_catalog
     curl -X GET https://myregistry:5000/v2/_catalog 
     curl -X GET https://myregistry:5000/v2/ubuntu/tags/list
     ```

   - delete the unused images with curl (correct the cmdline-tbd-) or skopeo
     ```
     # env REGISTRY_STORAGE_DELETE_ENABLED: "true" should be in docker-compose:registry
     # curl -X DELETE localhost:5000/v1/repositories/ubuntu/tags/latest  #incorrect
     skopeo delete docker://localhost:5000/imagename:latest 

     #it still cannot remove the image directory and imagename still appear even all tags has been removed 
     docker exec -it registry bash && cd /var/lib/registry/docker/registry/v2/ && delete unused_dir
     ```
   
   - podman/docker using local image 
     podman run docker://localhost:5000/centos:7 bash

## install build freeipa client
   - hostnamectl set-hostname client1.host.cn
   - vim /etc/hosts for local name lookup for both ipa server and client
   - apt install freeipa-client oddjob-mkhomedir && ipa-client-install --mkhomedir --no-ntp
   
## build and push generated images to local
   - using the github freeipa/freeipa-server directly
     docker run --sysctl net.ipv6.conf.all.disable_ipv6=0 -it -e IPA_SERVER_IP=172.17.0.2 -h ipa.ict-group.cn --read-only \
            -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v ipa-data:/data:Z  \
            -p 80:80 -p 443:443 -p 389:389 -p 636:636 -p 88:88 -p 464:464 -p 88:88/udp -p 464:464/udp -p 123:123/udp \
            freeipa/freeipa-server ipa-server-install
       #localhost:5000/freeipa:7 ipa-server-install 
   
## create named/persistent volumes with docker_lvm_plugin

## refine docker-compose.yml to docker-compose-deploy.yml and test the image built on new hosts
   - update yml to use local images and docker-compose up -d #docker bypasses image build for second run, may not need to change yml in local
