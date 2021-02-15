# my-production-docker-build

This is still a work in progress and is my attempt at a unified build/deployment process for the various projects I'm running on my 
Raspberry Pi farm.

The projects include:

- [developer-portfolio](https://github.com/RatJuggler/developer-portfolio)
- [guinea-bot](https://github.com/RatJuggler/guinea-bot)
- [dinosauria-bot](https://github.com/RatJuggler/dinosauria-bot)
- [sync-gandi-dns](https://github.com/RatJuggler/sync-gandi-dns)
- [f4side-site](https://github.com/RatJuggler/f4rside-site)

Each of the projects has had a docker build added to it. I am using scripts to test how the multi-architecture images I need might 
be created before looking at the CI/CD process proper. The scripts in the `/bin` are as follows:

- build.sh: generic script to build and push images for a given project.
- build-project-images.sh: convenience script to build all the projects I want.
- push-manifest.sh; generic script to create a multi-architecture image from existing tagged images.
- create-multi-arch-manifests.sh: convenience script to create all the multi-architecture images I want.
- build-ingress-proxy.sh: standalone build for the ingress proxy (see below).
- build-golden.sh: standalone build for my [golden images](#golden-images).

The build script clones only the minimum source code required (no history) for each project and then uses the projects compose file 
to create the images for that project. Options are available to set the registry, docker id (repository) and tag for the generated 
images, with an additional multi-architecture option to set the image tag according to the local architecture. If a registry and 
repository are set the script will attempt to push the images to that registry. It will not default the registry to Docker Hub, 
you have to explicitly set it:
```
My Project Docker Image Builder

Usage: build [-h] [-g GIT_REPO] [-m] [-r REGISTRY] [-p REPOSITORY] [-t IMAGE_TAG]

Options:
-h             display this help and exit
-u GIT_URL     the URL of the git repo to run a build for, required
-m             set the image tag according to the local architecture, overrides '-t'
-g REGISTRY    set the docker registry to use, does NOT default to 'docker.io'
-p REPOSITORY  set the docker repository (id) to use
-t IMAGE_TAG   set the image tag to use, defaults to 'latest', overridden by '-m'
```
Note: Environment variables must be exported for use in the compose file but can be injected directly into the build files via the 
build-arg option.

The push manifest script expects images to have already been built for the two architectures I need (intel and arm) and then ties 
these together into a multi-architecture image manifest and pushes that to the supplied registry. The push uses the `--purge` 
option to remove the local version of the manifest after pushing. When the images are updated the manifest can then be updated by 
rerunning this script which re-creates and re-pushes it.
```
My Docker Multi-Architecture Manifest Builder

'linux-amd' and 'linux-arm' images must have already been created and tagged.

Usage: push-manifest [-h] [-i IMAGE_NAME] [-g REGISTRY] [-p REPOSITORY] [-t IMAGE_TAG]

Options:
-h             display this help and exit
-i IMAGE_NAME  name of the image to make multi-architecture, required
-g REGISTRY    set the docker registry to use, does NOT default to 'docker.io', required
-p REPOSITORY  set the docker repository (id) to use, required
-t IMAGE_TAG   set the manifest image tag to use, defaults to 'latest'
```
The proxy build convenience script builds an additional ingress proxy image to route requests to project's that serve content on 
request (websites basically). There are two versions of the proxy, a test image without any SSL security and without the 
*upgrade-insecure-requests* CSP setting to make testing the full environment easier, and a production environment version which 
creates the ingress proxy image with the SSL certificates included (see Note on security below) and also upgrades the CSP settings.

After the images are built, everything is then tied together in this project with a docker-compose file to orchestrate the 
containers. This is configured with the test ingress proxy by default which can be overridden for production environments. You can 
see how the override file will be applied using:

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

To build this multi-architecture image I ran the `build-golden.sh` script on an intel linux machine after first setting
the IMAGE_TAG to *linux-amd64*. I then ran the same script on a Raspberry Pi with the IMAGE_TAG set to *linux-arm*.

Then to make the multi-architecture image show up on docker hub I used the `push-manifest.sh` script from the intel linux machine:

    ./bin/push-manifest.sh -g docker.io -p johnchase -i golden-nginx

Looking in Docker hub it then shows *johnchase/golden-nginx:latest* as being a multi-architecture image.

### Deployed Result

When everything is built and deployed the result should look something like this (ignoring any replicas):

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
