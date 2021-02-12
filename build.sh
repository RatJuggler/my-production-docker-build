#!/bin/bash

printf "My Production Docker Builder\n"
printf "============================\n\n"

ARCH=$(uname -m)
case "$ARCH" in
  x86_64)
    export BUILD_TAG="latest"
    ;;
  armv7l)
    export BUILD_TAG="latest"
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

# Build for sync-gandi-dns site.

git clone --single-branch --no-tags --depth 1 https://github.com/RatJuggler/sync-gandi-dns.git src/sync-gandi-dns

cd src/sync-gandi-dns || exit
docker-compose -f docker-compose.yml build --pull --build-arg BUILD_TAG="$BUILD_TAG"
docker-compose -f docker-compose.yml push
cd ../.. || exit

# Build for guinea-bot site.

git clone --single-branch --no-tags --depth 1 https://github.com/RatJuggler/guinea-bot.git src/guinea-bot

cd src/guinea-bot || exit
docker-compose -f docker-compose.yml build --pull --build-arg BUILD_TAG="$BUILD_TAG"
docker-compose -f docker-compose.yml push
cd ../.. || exit

# Build for dinosauria-bot site.

git clone --single-branch --no-tags --depth 1 https://github.com/RatJuggler/dinosauria-bot.git src/dinosauria-bot

cd src/dinosauria-bot || exit
docker-compose -f docker-compose.yml build --pull --build-arg BUILD_TAG="$BUILD_TAG"
docker-compose -f docker-compose.yml push
cd ../.. || exit

# Build for f4rside.com site.

git clone --single-branch --no-tags --depth 1 https://github.com/RatJuggler/f4rside-site.git src/f4rside-site

cd src/f4rside-site || exit
docker-compose -f docker-compose.yml build --pull --build-arg BUILD_TAG="$BUILD_TAG"
docker-compose -f docker-compose.yml push
cd ../.. || exit

# Build for jurassic-john.site site.

git clone --single-branch --no-tags --depth 1 https://github.com/RatJuggler/developer-portfolio.git src/developer-portfolio

cd src/developer-portfolio || exit
docker-compose -f docker-compose.yml build --pull --build-arg BUILD_TAG="$BUILD_TAG"
docker-compose -f docker-compose.yml push
cd ../.. || exit

# Build for the ingress proxy.
# IMPORTANT: We must *NOT* push the ingress proxy image to a public repository whilst it contains our certificate keys!

docker-compose -f docker-compose.yml build --pull --build-arg BUILD_TAG="$BUILD_TAG"
docker-compose -f docker-compose-production.yml build --pull --build-arg BUILD_TAG="$BUILD_TAG"

printf "\nAll Done!\n"
