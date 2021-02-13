# my-production-docker-build

This is still a work in progress and is my attempt at a unified build/deployment process for the various projects I'm running on my 
Raspberry Pi farm.

The projects include:

- [developer-portfolio](https://github.com/RatJuggler/developer-portfolio)
- [guinea-bot](https://github.com/RatJuggler/guinea-bot)
- [dinosauria-bot](https://github.com/RatJuggler/dinosauria-bot)
- [sync-gandi-dns](https://github.com/RatJuggler/sync-gandi-dns)
- [f4side-site](https://github.com/RatJuggler/f4rside-site)

Each of the projects has had a docker build added to it, and I am using a build script to test how the images might be created 
before looking at the CI/CD process proper: 

    ./build.sh

The script clones only the minimum source code required (no history) for each project and then uses the projects compose file to 
create the images for that project. Options are available to set the registry, docker id (repository) and tag for the generated 
images. If a registry and repository are set the script will attempt to push the images to that repository. It will not default
the registry to Docker Hub you have to explicitly set it:

    ./build.sh -r docker.io -i johnchase

Note: Environment variables must be exported for use in the compose file but can be injected directly into the build files via the 
build-arg option.

After the images are built everything is then tied together in this project, with a docker-compose file to orchestrate the 
containers. This file also includes an additional ingress proxy image to route requests to project's that serve content on request 
(websites basically). The base file creates this image without any SSL security and without the *upgrade-insecure-requests* CSP 
setting to make testing the full environment easier. An override file is then available for the live environment which creates the 
ingress proxy image with the SSL certificates included (see Note on security below) and also upgrades the CSP settings.

You can see how the override file will be applied using:

    docker-compose -f docker-compose.yml -f docker-compose-production.yml config

To run the test environment just use:

    docker-compose up -d

For the production environment use:

    docker-compose -f docker-compose.yml -f docker-compose-production.yml up -d

### ARM Images

A key part of making this all work on Raspberry Pi's is picking multi-architecture base images which have good 32-bit ARM 
(arm32v7, armv7, armhf) support, so that I can try to keep the docker files for each project as simple as possible.

I am using images based on [alpine](https://hub.docker.com/_/alpine) 3.11 for stability and consistency, and I was trying to avoid 
[issues](https://wiki.alpinelinux.org/wiki/Release_Notes_for_Alpine_3.13.0#time64_requirements) with an out-of-date *libseccomp2* 
on the Raspberry Pi OS (32-bit/Raspbian/Buster) that I'm running:

- [alpine:3.11](https://hub.docker.com/layers/alpine/library/alpine/3.11/images/sha256-379fd3ade18c4ff1e12eeae9fafd3378fa039eb023ed534311c246d2d63f8c84)
- [nginx:stable-alpine](https://hub.docker.com/layers/nginx/library/nginx/stable-alpine/images/sha256-da3716611fb965f3fda1f3281882baeb2760ca8bb7317f1d22ed45e75570827b)
- [node:lts-alpine3.11](https://hub.docker.com/layers/node/library/node/lts-alpine3.11/images/sha256-7c2d9dda61b89fd414371c14d6b87973925c66ebd4ca59f3a539821e88cdeb8f)
- [python:3.7-alpine3.11](https://hub.docker.com/layers/python/library/python/3.7-alpine3.11/images/sha256-1724b17cbf37548616325811484dd5a60351ab06bca4c5367b5c297c5e193e01)

For Java, I want to use version 11 and [AdoptOpenJDK](https://hub.docker.com/_/adoptopenjdk) has better support for 32-bit ARM than 
[OpenJDK](https://hub.docker.com/_/openjdk). However, the latest official [Maven image](https://hub.docker.com/_/maven) for 
AdoptOpenJDK is [based on](https://github.com/carlossg/docker-maven/blob/master/adoptopenjdk-11/Dockerfile) 
`adoptopenjdk:11-jdk-hotspot` which in turn uses Ubuntu 20.04 (Focal Fossa) and has the same issue with *libseccomp2* when run on 
Raspberry Pi OS as mentioned earlier. Researching the issue further the simplest solution looks to be to just install an updated
backport of *libseccomp2* using the following commands:

    wget http://ftp.uk.debian.org/debian/pool/main/libs/libseccomp/libseccomp2_2.4.4-1~bpo10+1_armhf.deb
    sudo dpkg -i libseccomp2_2.4.4-1~bpo10+1_armhf.deb

I would rather use these standard images than have to find or build a custom image, so I will be using this solution. 

### Golden Images

I have started to define golden images for re-use and as best practice.

#### golden-nginx

This image includes my mock production configuration files from [Nginx HTTP server boilerplate configs](https://github.com/RatJuggler/server-configs-nginx/tree/my-production).

To build a multi-architecture image I first ran the following on an intel linux machine:

    docker image build -t johnchase/golden-nginx:linux-amd64 -f docker/nginx/Golden.dockerfile .

    docker image push johnchase/golden-nginx:linux-amd64

And then the following on a Raspberry Pi:

    docker image build -t johnchase/golden-nginx:linux-arm -f docker/nginx/Golden.dockerfile .

    docker image push johnchase/golden-nginx:linux-arm

Then to make the multi-architecture image show up on docker hub I first pulled the ARM image down to the intel machine and then 
created and pushed a manifest:

    docker image pull johnchase/golden-nginx:linux-arm

    docker manifest create johnchase/golden-nginx johnchase/golden-nginx:linux-amd64 johnchase/golden-nginx:linux-arm

    docker manifest push johnchase/golden-nginx

Docker hub now shows *johnchase/golden-nginx:latest* as being a multi-architecture image.

### Deployed Result

When everything is built and deployed the result should look something like this (ignoring replicas):

![Image of Architecture](https://github.com/RatJuggler/my-production-docker-build/blob/main/deployed-result.jpg)

### Future ideas:

In no particular order:

- Use buildx for multi-architecture.
- Build a CI/CD pipeline.
- Push images to my own registry.
- Deployment to a docker swarm across several Raspberry Pi's.
- Better image tagging.
- Add Portainer as a management dashboard.
- Implement Anchore analysis and scanning.
- Add monitoring and health checks.
- Build images via Docker Hub or GitHub Actions.
- Test reporting of CSP issues and other errors.
- Use Traefik instead of Nginx.
- Use Kubernetes.
- Configure using Ansible.
- Mirror on AWS/GCP/Azure.

### Note on security

The site certificates and private keys are bundled with the Nginx ingress proxy image so this is not an ideal solution from a 
security perspective. Anyone with access to the generated Docker image can retrieve them. This also makes updating the certificates 
automatically harder as the Docker image must be re-created to include the updates and any running containers then restarted with 
the new image.
