# my-production-docker-build

This is still a work in progress and is my attempt at a unified build/deployment process for the various projects I'm running on my 
Raspberry Pi farm.

At the moment I have a build script which can be run to create all the images required: 

    ./build.sh

The script clones only the minimum source code required (no history) for each project and then uses the projects compose file to 
create the images for that project. Environment variables must be exported for use in the compose file but can be injected directly
into the build files via the build-arg option.

Everything is then tied together in this project with a base docker-compose file to orchestrate the images. This file also includes 
an additional ingress proxy image to route requests to each project. The base file creates this image without any SSL/CSP security 
for testing with an override file available for production. The production override file creates the ingress proxy image with the 
SSL certificates and CSP settings included (see Note on security below).

You can see how the override file will be applied using:

    docker-compose -f docker-compose.yml -f docker-compose-production.yml config

### Golden Images

I've started to define golden images for re-use and as best practice.

#### golden-nginx

This includes my production Nginx configuration files from [Nginx HTTP server boilerplate configs](https://github.com/RatJuggler/server-configs-nginx/tree/production).

I needed to make this a multi-architecture image so that I can use it on the Pi farm. The build uses `git` to clone the Nginx 
configuration files, so I looked at using [alpine/git](https://hub.docker.com/r/alpine/git) but that doesn't have strong support 
for 32-bit ARM (arm32v7, armv7, armhf) so I've used a base [alpine](https://hub.docker.com/_/alpine) image and then installed `git` 
on top of that. An additional caveat was that I then had to use *alpine* 3.12 as there is an [issue](https://wiki.alpinelinux.org/wiki/Release_Notes_for_Alpine_3.13.0#time64_requirements) 
with an out-of-date *libseccomp* on Raspberry Pi OS when trying to use the latest (3.13) version.

For the final [Nginx](https://hub.docker.com/_/nginx) image I'm using the *stable-alpine* version which is [based on](https://github.com/nginxinc/docker-nginx/blob/master/stable/alpine/Dockerfile)
*alpine* 3.11.

To build the images I ran the following on an intel linux machine:

    docker image build -t johnchase/golden-nginx:linux-amd64 -f docker/nginx/Golden.dockerfile .

    docker image push johnchase/golden-nginx:linux-amd64

And the following on a Raspberry Pi:

    docker image build -t johnchase/golden-nginx:linux-arm -f docker/nginx/Golden.dockerfile .

    docker image push johnchase/golden-nginx:linux-arm

Then to make a multi-arch image show up on docker hub I first pulled the ARM image down to the intel machine and then created and 
pushed a manifest:

    docker image pull johnchase/golden-nginx:linux-arm

    docker manifest create johnchase/golden-nginx johnchase/golden-nginx:linux-amd64 johnchase/golden-nginx:linux-arm

    docker manifest push johnchase/golden-nginx

Docker hub now shows *johnchase/golden-nginx:latest* as being a multi-arch image.

### Future goals:

- push images to my own registry.
- deployment to a docker swarm across several Raspberry Pi's.
- full image tagging including major, minor, patch and latest.
- add Portainer as a management dashboard.
- add monitoring and health checks.

### Note on security

The site certificates and private keys are bundled with the Nginx ingress proxy image so this is not an ideal solution from a 
security perspective. Anyone with access to the generated Docker image can retrieve them. This also makes updating the certificates 
automatically harder as the Docker image must be re-created to include the updates and any running containers then restarted with 
the new image.
