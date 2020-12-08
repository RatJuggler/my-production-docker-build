#!/bin/bash

printf "My Nginx Static Site Docker Builder\n"
printf "===================================\n"

if [[ -z "$1" ]]; then
  printf "Please supply a docker image name!\n"
  exit 1
fi

printf "\nClearing down any previous build...\n"
rm -rf src
mkdir src

printf "\nCloning the project for f4rside.com...\n"
git clone --single-branch --depth 1 https://github.com/RatJuggler/f4rside-site.git src/f4rside-site

printf "\nCloning the project for jurassic-john.site...\n"
git clone --single-branch --depth 1 https://github.com/RatJuggler/developer-portfolio.git src/developer-portfolio

printf "\nCloning the project for the Nginx configuration...\n"
git clone --single-branch --depth 1 --branch production https://github.com/RatJuggler/server-configs-nginx.git src/server-config-nginx

printf "\nRunning the Docker build...!\n"
docker build -t "$1" .

printf "\nAll Done!\n"
