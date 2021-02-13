#!/bin/bash

function show_usage() {
   printf "My Docker Builder\n\n"
   printf "Usage: build [-h] [-i DOCKER_ID] [-m] [-r DOCKER_REGISTRY] [-t IMAGE_TAG]\n\n"
   printf "Options:\n"
   printf "  -h                  display this help and exit\n"
   printf "  -i DOCKER_ID        set the docker id (repository) to use\n"
   printf "  -m                  set the image tag according to the architecture,\n"
   printf "                        overrides '-t'\n"
   printf "  -r DOCKER_REGISTRY  set the docker registry to use,\n"
   printf "                        does NOT default to 'docker.io'\n"
   printf "  -t IMAGE_TAG        set the image tag to use, defaults to 'latest',\n"
   printf "                        overridden by '-m'\n"
}

function checkout_and_build() {
  REPO=$1
  # Checkout the bare source from repo, no history
  git clone --single-branch --no-tags --depth 1 https://github.com/RatJuggler/"$REPO".git src/"$REPO"
  # Make repo the CWD.
  cd src/"$REPO" || exit
  # env_file entries must exist for the compose file to be validated so we create a dummy one for building.
  touch "$REPO".env
  # Do the build.
  docker-compose -f docker-compose.yml --profile="builders" build \
    --build-arg DOCKER_REGISTRY="$DOCKER_REGISTRY" \
    --build-arg DOCKER_ID="$DOCKER_ID" \
    --build-arg BUILD_TAG="$BUILD_TAG"
  # Only do a push if a registry and an id have been set.
  if [[ -n "$DOCKER_REGISTRY" && -n "$DOCKER_ID" ]]; then
    docker-compose -f docker-compose.yml push
  fi
  # Restore previous CWD.
  cd ../.. || exit
  # Make sure we have an env_file here to allow the local compose file to validate.
  touch "$REPO".env
}

# ======================
# Main code starts here.
# ======================

# Process options and validate combinations.

while getopts :hi:mr:t: OPTION
do
  case "${OPTION}" in
    h)
      show_usage
      exit 0
      ;;
    i)
      export DOCKER_ID=${OPTARG}
      ;;
    m)
      MULTI_ARCH=true
      ;;
    r)
      export DOCKER_REGISTRY=${OPTARG}
      ;;
    t)
      export IMAGE_TAG=${OPTARG}
      ;;
    ?)
      printf "build: invalid option -- '%s'\n" "${OPTARG}"
      printf "Try 'build -h' for more information.\n"
      exit 1
      ;;
  esac
done

if [[ -n "$MULTI_ARCH" && -n "$IMAGE_TAG" ]]; then
  printf "\nError: Image tag cannot be set when multi-architecture option selected!\n"
  exit 1
fi

if [[ -n "$DOCKER_REGISTRY" && -z "$DOCKER_ID" ]]; then
  printf "\nError: Docker Id (repository) must also be set when specifying a registry!\n"
  exit 1
fi

# Processing started.

printf "My Docker Builder\n"
printf "=================\n\n"

# Determine architecture for build tag and use in multi-architecture builds.

ARCH=$(uname -m)
case "$ARCH" in
  x86_64)
    export BUILD_TAG="linux-amd64"
    ;;
  armv7l)
    export BUILD_TAG="linux-arm"
    ;;
  *)
    printf "Unexpected architecture '%s' found!\n" "$ARCH"
    exit 1
    ;;
esac

printf "Architecture Identified : %s\n" "$ARCH"
printf "Using Build Tag         : %s\n" "$BUILD_TAG"

if [[ -n "$MULTI_ARCH" ]]; then
  export IMAGE_TAG=$BUILD_TAG
fi

# Show how options will be used.

if [[ -z "$DOCKER_REGISTRY" ]]; then
  printf -v REGISTRY_USED "Not set, local image only"
else
  printf -v REGISTRY_USED "Images will be pushed to registry '%s'" "$DOCKER_REGISTRY"
fi

if [[ -z "$DOCKER_ID" ]]; then
  printf -v ID_USED "Not set, local image only"
else
  printf -v ID_USED "Images will be tagged with repository '%s'" "$DOCKER_ID"
fi

if [[ -n "$MULTI_ARCH" ]]; then
  printf -v TAG_USED "Multi-architecture selected, images will be tagged with '%s'" "$IMAGE_TAG"
elif [[ -z "$IMAGE_TAG" ]]; then
  printf -v TAG_USED "Not set, default image tag will be used"
else
  printf -v TAG_USED "Images will be tagged with '%s'" "$IMAGE_TAG"
fi

printf "Docker Registry         : %s\n" "$REGISTRY_USED"
printf "Docker Id               : %s\n" "$ID_USED"
printf "Image Tag               : %s\n" "$TAG_USED"

# Pre-builds processing.

printf "\nClearing down any previous builds...\n"
rm -rf src
mkdir src

# Build project images.

checkout_and_build sync-gandi-dns
checkout_and_build guinea-bot
checkout_and_build dinosauria-bot
checkout_and_build f4rside-site
checkout_and_build developer-portfolio

# Build for the ingress proxy.
# IMPORTANT: We must *NOT* push the ingress proxy image to a public repository whilst it contains our certificate keys!

docker-compose -f docker-compose.yml build \
  --build-arg DOCKER_REGISTRY="$DOCKER_REGISTRY" \
  --build-arg DOCKER_ID="$DOCKER_ID" \
  --build-arg BUILD_TAG="$BUILD_TAG"
docker-compose -f docker-compose-production.yml build \
  --build-arg DOCKER_REGISTRY="$DOCKER_REGISTRY" \
  --build-arg DOCKER_ID="$DOCKER_ID" \
  --build-arg BUILD_TAG="$BUILD_TAG"

# Post builds processing and exit.

printf "\nAll Done!\n"

exit 0
