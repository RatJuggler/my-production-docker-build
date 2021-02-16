# build

This outlines the scripts used to build multi-architecture images using the standard [Build](https://docs.docker.com/engine/reference/commandline/build/) 
command. There are three stages to this process which must each be actioned manually.

- Build and push images for Intel *linux/amd64* on an appropriate machine.
- Build and push images for Arm *linux/arm* on an appropriate machine.
- Create a single image manifest entry for both versions of each image.

The scripts in the `/bin` directory to help with these steps are as follows:

- `build.sh` : generic script to build and push images for a given project.
- `build-project-images.sh` : convenience script to build images for all the projects I want.
- `build-manifest.sh` : generic script to build a multi-architecture image from existing tagged images.
- `build-multi-arch-manifests.sh` : convenience script to create all the multi-architecture images I want.
- `build-ingress-proxy.sh` : standalone build for the ingress proxy.
- `build-golden.sh` : standalone build for my golden images.

The `build.sh` script clones only the minimum source code required (no history) for each project and then uses the projects compose 
file to create the images for that project using the standard *build* command. The script has options to set the registry, 
repository (docker id) and tag for the generated images, with an additional multi-architecture option to set the image tag 
according to the local architecture. If a registry and repository are set the script will attempt to push the images to that 
registry. It will not default the registry to Docker Hub, you have to explicitly set it:
```
My Project Docker Image Builder

Usage: build [-h] [-g GIT_REPO]  [-c COMPOSE] [-m] [-r REGISTRY] [-p REPOSITORY] [-t IMAGE_TAG]

Options:
  -h             display this help and exit
  -u GIT_URL     the URL of the git repo to run a build for, required
  -c COMPOSE     the docker-compose file to build from, defaults to 'docker-compose.yml'
  -m             set the image tag according to the local architecture, overrides '-t'
  -g REGISTRY    set the docker registry to use, defaults to 'docker.io'
  -p REPOSITORY  set the docker repository (id) to use, images will be pushed if set
  -t IMAGE_TAG   set the image tag to use, defaults to 'latest', overridden by '-m'
```
Note: Environment variables must be exported for use in the compose file but can be injected directly into the build files via the
build-arg option.

The push manifest script expects images to have already been built for the two architectures and then ties these together into a 
multi-architecture image manifest and pushes that to the supplied registry. The push uses the `--purge` option to remove the local 
version of the manifest after pushing. When the images are updated the manifest can then be updated by rerunning this script which 
re-creates and re-pushes it.
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
