# my-production-docker-build

This is still a work in progress and is my attempt at a unified build/deployment process for the various projects I'm running on a 
Docker Swarm on my Raspberry Pi farm.

The projects include:

- [developer-portfolio](https://github.com/RatJuggler/developer-portfolio)
- [guinea-bot](https://github.com/RatJuggler/guinea-bot)
- [dinosauria-bot](https://github.com/RatJuggler/dinosauria-bot)
- [sync-gandi-dns](https://github.com/RatJuggler/sync-gandi-dns)
- [f4side-site](https://github.com/RatJuggler/f4rside-site)

Each of the projects has had a docker build added to it with configurations for health checks and metrics added where possible. I 
am using scripts to test how the multi-architecture images I need might be created before looking at the CI/CD process proper. 
There are two varieties of scripts in the `/bin` directory which can be used:

- [One set](https://github.com/RatJuggler/my-production-docker-build/blob/main/bin/README-BUILD.md) using the standard *docker 
  build* and *manifest* commands to build multi-architecture images by doing builds on different architectures and then combining 
  the results.
- [Another set](https://github.com/RatJuggler/my-production-docker-build/blob/main/bin/README-BUILDX.md) using the experimental 
  *docker buildx* command to build multi-architecture images with a single command.

Scripts are also defined to build any golden images required, and an additional ingress proxy image to route requests to project's 
that serve content on request (websites basically). There are two versions of the proxy, a test image without any SSL security and 
without the *upgrade-insecure-requests* CSP setting to make testing the full environment easier, and a production environment 
version which creates the ingress proxy image with SSL security and also upgrades the CSP settings. The SSL certificates can then 
be injected via secrets (see note on security).

After all the images are built, everything is then tied together in this project with a number of docker-compose files to 
orchestrate the applications using stacks. The external facing sites are configured with the test ingress proxy by default which 
can be overridden for production environments. You can run this test using:

    docker-compose -f external-sites.yml -up -d

### Deployed Result

To deploy and run everything into the swarm you need:

    docker stack deploy -c portainer-agent-stack.yml portainer
    docker stack deploy -c monitoring.yml monitoring
    docker stack deploy -c sync-gandi-dns.yml sync-gandi-dns
    docker stack deploy -c dinosauria-bot.yml dinosauria-bot
    docker stack deploy -c guinea-bot.yml guinea-bot
    docker stack deploy -c external-sites.yml -c external-sites-production.yml external-sites

The result should look something like this (ignoring any replicas):

![Image of Architecture](https://github.com/RatJuggler/my-production-docker-build/blob/main/deployed-result.jpg)

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

I created this image for all my Nginx instances, it includes configuration files from my fork of [Nginx Server Configs](https://github.com/RatJuggler/server-configs-nginx)
and has a simple health check and the basic Nginx metrics exposed.

### Future ideas:

In no particular order:

- Build a CI/CD pipeline.
- Set proper replicas and resource limits.
- Push images to my own registry.
- Better image labelling & tagging.
- Implement Anchore analysis and scanning.
- Improve monitoring and health checks.
- Design some permanent Grafana dashboards.
- Build images via Docker Hub or GitHub Actions.
- Test reporting of CSP issues and other errors.
- Use Traefik instead of Nginx.
- Use Kubernetes.
- Configure using Ansible.
- Mirror on AWS/GCP/Azure.

### Note on security

API keys are injected into the required containers using Docker Swarm secrets. Site certificates and private keys are also injected 
into the ingress proxy container using secrets, which is better than having them bundled into the image itself but still comes with 
its own problems. Secrets can't be updated in Docker Swarm so updating the certificate's means creating new secrets and then 
spinning up a new ingress proxy container referencing the new secrets.
