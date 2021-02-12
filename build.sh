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
  docker-compose -f docker-compose.yml build --pull --build-arg BUILD_TAG="$BUILD_TAG"
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

export DOCKER_REGISTRY=""
export DOCKER_ID=""
export IMAGE_TAG="latest"

ARCH=$(uname -m)
case "$ARCH" in
  x86_64)
    export BUILD_TAG="local"
    ;;
  armv7l)
    export BUILD_TAG="local"
    ;;
  *)
    printf "Unexpected architecture '%s' encountered!\n" "$ARCH"
    exit 1
    ;;
esac

printf "Identified architecture: %s\n" "$ARCH"
printf "Using build tag:         %s\n" "$BUILD_TAG"

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

docker-compose -f docker-compose.yml build --pull --build-arg BUILD_TAG="$BUILD_TAG"
docker-compose -f docker-compose-production.yml build --pull --build-arg BUILD_TAG="$BUILD_TAG"

printf "\nAll Done!\n"
