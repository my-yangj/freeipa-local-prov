Services provided from docker container are all specified from docker_compose.yml. The below is the steps to setup from scratch (tbd)

1. start local docker registry
2. pull required image to local
3. build and push generated images to local
4. create persistent volumes
5. refine docker-compose.yml to use the local images and docker-compose up -d
   (not sure if docker could bypass image build procedure, thus just create a docker-compose-deploy.yml file)