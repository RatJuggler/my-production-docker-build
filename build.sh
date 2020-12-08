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
rm -rf config
mkdir config

printf "\nClone files for f4rside.com...\n"
git clone --single-branch --depth 1 https://github.com/RatJuggler/f4rside-site.git src/f4rside-site

printf "\nClone files for jurassic-john.site...\n"
git clone --single-branch --depth 1 https://github.com/RatJuggler/developer-portfolio.git src/developer-portfolio

printf "\nClone and copy files for Nginx configuration...\n"
git clone --single-branch --depth 1 --branch production https://github.com/RatJuggler/server-configs-nginx.git src/server-config-nginx
cp -r src/server-config-nginx/h5bp config/h5bp
cp -r nginx/conf.d config/conf.d
cp src/server-config-nginx/conf.d/.default.conf config/conf.d
cp src/server-config-nginx/conf.d/no-ssl.default.conf config/conf.d
cp src/server-config-nginx/mime.types config
cp src/server-config-nginx/nginx.conf config

printf "\nRunning Docker build!\n"
docker build -t "$1" .

printf "\nAll Done!\n"
