# my-production-docker-build

This is still a work in progress and is my attempt at a unified build/deployment process for the various projects I'm running on my 
Raspberry Pi farm.

Building of application/website images is done in the respective projects and this project only builds an ingress proxy using my 
production Nginx configuration files from [Nginx HTTP server boilerplate configs](https://github.com/RatJuggler/server-configs-nginx/tree/production).

Everything is then tied together with a base docker-compose file for testing supplemented by an override file for production.

You can test how the override file will be applied using:

    docker-compose -f ./docker-compose.yml -f ./docker-compose-production.yml config

### Golden Images

I've started to define golden images for re-use and as best practice.

#### golden-nginx

Includes my production Nginx configuration files from [Nginx HTTP server boilerplate configs](https://github.com/RatJuggler/server-configs-nginx/tree/production).

    docker image build -t johnchase/golden-nginx:latest -f ./Golden.dockerfile .

### Future goals:

- push images to my own registry.
- deployment to a docker swarm across several Raspberry Pi's.
- full image tagging including major, minor, patch and latest.
- add Portainer as a management dashboard.
- add monitoring and health checks.

### Note

The site certificates and private keys are bundled with the Nginx ingress proxy image so this is not an ideal solution from a 
security perspective. Anyone with access to the generated Docker image can retrieve them. This also makes updating the certificates 
automatically harder as the Docker image must be re-created to include the updates and any running containers then restarted with 
the new image.
