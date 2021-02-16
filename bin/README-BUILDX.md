# buildx

This outlines the scripts used to build multi-architecture images with the experimental [Buildx](https://docs.docker.com/engine/reference/commandline/buildx/) 
command using BuildKit. This allows multi-architectural images to be built with a single command. It can be used in place of the
*build* command but must be enabled first.

For this build to work I had to configure a *buildx* builder.

On my main Intel Linux machine I entered:

    docker context create linux-amd64 --docker "host=unix:///var/run/docker.sock"
    docker context create linux-arm --docker "host=ssh://pi@paspberyypi"

With *pi@raspberrypi* referencing an Arm machine running docker.

Then to create the builder I used:

    docker buildx create --use --name my-builder --platform linux/amd64 linux-amd64
    docker buildx create --append --name my-builder --platform linux/arm linux-arm

The builder was then available for use:
```
$ docker buildx ls
NAME/NODE     DRIVER/ENDPOINT  STATUS  PLATFORMS
my-builder *  docker-container         
my-builder0 linux-amd64      running linux/amd64*, linux/386
my-builder1 linux-arm        running linux/arm/v7*, linux/arm/v6
linux-amd64   docker                   
linux-amd64 linux-amd64      running linux/amd64, linux/386
linux-arm     docker                   
linux-arm   linux-arm        running linux/arm/v7, linux/arm/v6
default       docker                   
default     default          running linux/amd64, linux/386
```
The scripts in the `/bin` directory that use this builder are as follows:

- `buildx.sh` : generic script to build and push images for a given project.
- `buildx-project-images.sh` : convenience script to build images for all the projects I want.
- `buildx-ingress-proxy.sh` : standalone build for the ingress proxy.
- `buildx-golden.sh` : standalone build for my golden images.

The `build.sh` script clones only the minimum source code required (no history) for each project and then uses the projects compose
file to create multi-architectural images for that project using the experimental *build bake* command. The script has options to 
set the registry, repository (docker id) and tag for the generated images. Everything will be pushed to the registry.
```
My Project Multi-Arch Docker Image Builder

Usage: buildx [-h] [-g GIT_REPO] [-r REGISTRY] [-p REPOSITORY] [-t IMAGE_TAG]

Options:
  -h             display this help and exit
  -u GIT_URL     the URL of the git repo to run a build for, required
  -g REGISTRY    set the docker registry to use, defaults to 'docker.io'
  -p REPOSITORY  set the docker repository (id) to use, required
  -t IMAGE_TAG   set the image tag to use, defaults to 'latest'
```
Note: Environment variables must be exported for use in the compose and build files.
