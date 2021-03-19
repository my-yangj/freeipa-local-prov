with spec in docker_compose.yml, the below are the steps to build container images and run docker_compose

# local docker registry
## start local docker registry
   - using named volumes in docker-compose.yml "docker_registry:/var/lib/registry", they has to be external managed.
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

   - certification-enabled registry is required to user skopeo (podman?)
     ```
     openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key -x509 -days 365 -out certs/domain.crt
     cp domain.crt /usr/local/share/ca-certificates/localhost.crt && update-ca-certificates     

     # enable enbironment REGISTRY_HTTP_TLS_CERTIFICATE and REGISTRY_HTTP_TLS_KEY docker_compose.yml
     # here 'localhost' is used as CN and get x509: certificate relies on legacy Common Name field which requires
     #see https://docs.docker.com/registry/insecure/

     export GODEBUG="x509ignoreCN=0 
     ```
     
## or use skopeo to manipulate local registry
   - skopeo can not list images in registry, using curl instead see https://stackoverflow.com/questions/31251356/how-to-get-a-list-of-images-on-docker-registry-v2
     ```
     skopeo copy docker://ubuntu docker://localhost:5000/ubuntu
     curl --cacert domain.crt https://myregistry:5000/v2/_catalog
     curl -X GET https://myregistry:5000/v2/_catalog 
     curl -X GET https://myregistry:5000/v2/ubuntu/tags/list
     ```

   - delete the unused images with curl (correct the cmdline-tbd-) or skopeo
     ```
     # env REGISTRY_STORAGE_DELETE_ENABLED: "true" should be added in docker-compose:registry
     # curl -X DELETE localhost:5000/v1/repositories/ubuntu/tags/latest  #incorrect
     skopeo delete docker://localhost:5000/imagename:latest 

     #it still cannot remove the image directory and imagename still appear even all tags has been removed 
     docker exec -it registry bash && cd /var/lib/registry/docker/registry/v2/ && delete unused_dir
     ```
## using docker registry from podman
   - podman/docker using local image 
     podman run docker://localhost:5000/centos:7 bash

# freeipa
## server
   - try it with docker
     ```bash
     docker run --sysctl net.ipv6.conf.all.disable_ipv6=0 -it -e IPA_SERVER_IP=172.17.0.2 -h ipa.ict-group.cn --read-only \
            -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v ipa-data:/data:Z  \
            -p 80:80 -p 443:443 -p 389:389 -p 636:636 -p 88:88 -p 464:464 -p 88:88/udp -p 464:464/udp -p 123:123/udp \
            freeipa/freeipa-server ipa-server-install
       #localhost:5000/freeipa:7 ipa-server-install 
     ```
   - tune docker_compose.yml file
     (will use hostnet as it have better performance).

## client in each node
   ```bash
   #-tt- --hostnamectl set-hostname client1.host.cn--
   # vim /etc/hosts for lookuping up ipa server. #dns setup -tbd-
   apt install freeipa-client oddjob-mkhomedir && ipa-client-install --mkhomedir --no-ntp
   ```
   
# refine docker-compose.yml
   - update yml to use and maintain local images (-tbd-)
