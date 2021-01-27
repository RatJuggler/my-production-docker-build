#!/bin/bash

printf "My Production Docker Builder\n"
printf "============================\n\n"

ARCH=$(uname -m)
case "$ARCH" in
  x86_64)
    BUILD_TAG="linux-amd64"
    ;;
  arm7l)
    BUILD_TAG="linux-arm"
    ;;
  *)
    printf "Unexpected architecture '%s' encountered!\n" $ARCH
    exit 1
    ;;
esac

printf "Identified architecture: %s\n" $ARCH
printf "Using build tag:         %s\n" $BUILD_TAG

printf "\nClearing down any previous builds...\n"
rm -rf src
mkdir src

# Build for f4rside.com site.

git clone --single-branch --depth 1 https://github.com/RatJuggler/f4rside-site.git src/f4rside-site

cd src/f4rside-site || exit
docker-compose -f docker-compose.yml build --pull --build-arg BUILD_TAG="$BUILD_TAG"
cd ../..

# Build for jurassic-john.site site.

git clone --single-branch --depth 1 https://github.com/RatJuggler/developer-portfolio.git src/developer-portfolio

cd src/developer-portfolio || exit
docker-compose -f docker-compose.yml build --pull --build-arg BUILD_TAG="$BUILD_TAG"
cd ../..

docker-compose -f docker-compose.yml build --pull --build-arg BUILD_TAG="$BUILD_TAG"
docker-compose -f docker-compose-production.yml build --pull --build-arg BUILD_TAG="$BUILD_TAG"

printf "\nAll Done!\n"
