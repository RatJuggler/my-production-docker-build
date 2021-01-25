#!/bin/bash

printf "My Production Docker Builder\n"
printf "============================\n"

if [[ -z "$1" ]]; then
  printf "Please supply an image tag!\n"
  exit 1
fi

printf "\nClearing down any previous build...\n"
rm -rf src
mkdir src

printf "\nCloning the project for f4rside.com...\n"
git clone --single-branch --depth 1 https://github.com/RatJuggler/f4rside-site.git src/f4rside-site

printf "\nCloning the project for jurassic-john.site...\n"
git clone --single-branch --depth 1 https://github.com/RatJuggler/developer-portfolio.git src/developer-portfolio

printf "\nBuilding images...\n"
docker-compose -f docker-compose.yml build --build-arg BUILD_TAG="$1"

printf "\nAll Done!\n"
