#!/bin/bash

function checkout_and_build() {
  REPO=$1
  # Checkout the bare source from repo, no history
  git clone --single-branch --no-tags --depth 1 https://github.com/RatJuggler/$REPO.git src/$REPO
  # Make repo the CWD.
  cd src/$REPO || exit
  # env_file entries must exist for the compose file to be validated so we create a dummy one for building.
  touch $REPO.env
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
  # Make sure we have an env_file here for the local compose file.
  touch $REPO.env
}

printf "My Production Docker Builder\n"
printf "============================\n\n"

while getopts :i:r:t: OPTION
do
  case "${OPTION}" in
    i)
      export DOCKER_ID=${OPTARG}
      ;;
    r)
      export DOCKER_REGISTRY=${OPTARG}
      ;;
    t)
      export IMAGE_TAG=${OPTARG}
      ;;
    ?)
      printf "Usage: %s -i DOCKER_ID -r DOCKER_REGISTRY -t IMAGE_TAG\n" "$0"
      exit 1
      ;;
  esac
done

if [[ -n "$DOCKER_REGISTRY" && -z "$DOCKER_ID" ]]; then
  printf "Error: Docker Id must also be set when specifying a registry!\n"
  exit 1
fi

if [[ -z "$DOCKER_REGISTRY" ]]; then
  printf -v REGISTRY_USED "<Not set, local image only>"
else
  printf -v REGISTRY_USED "%s" "$DOCKER_REGISTRY"
fi

if [[ -z "$DOCKER_ID" ]]; then
  printf -v ID_USED "<Not set, local image only>"
else
  printf -v ID_USED "%s" "$DOCKER_ID"
fi

if [[ -z "$IMAGE_TAG" ]]; then
  printf -v TAG_USED "<Not set, will default to 'latest'>"
else
  printf -v TAG_USED "%s" "$IMAGE_TAG"
fi

printf "Docker Registry         : %s\n" "$REGISTRY_USED"
printf "Docker Id               : %s\n" "$ID_USED"
printf "Image Tag               : %s\n" "$TAG_USED"

ARCH=$(uname -m)
case "$ARCH" in
  x86_64)
    export BUILD_TAG="local"
    ;;
  armv7l)
    export BUILD_TAG="local"
    ;;
  *)
    printf "Unexpected architecture '%s' found!\n" "$ARCH"
    exit 1
    ;;
esac

printf "Architecture Identified : %s\n" "$ARCH"
printf "Using Build Tag         : %s\n" "$BUILD_TAG"

printf "\nClearing down any previous builds...\n"
rm -rf src
mkdir src

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

printf "\nAll Done!\n"
