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

printf "\nPulling resources required...\n"
# Checkout a shallow copy of f4rside-site.
git clone --single-branch --depth 1 https://github.com/RatJuggler/f4rside-site.git src/f4rside-site
# Checkout a shallow copy of developer-portfolio.
git clone --single-branch --depth 1 https://github.com/RatJuggler/developer-portfolio.git src/developer-portfolio
# Checkout a shallow copy of the base Nginx configuration.
git clone --single-branch --branch production --depth 1 https://github.com/RatJuggler/server-configs-nginx.git src/server-config-nginx

printf "\nBuilding/copying sites to serve...\n"
# Copy f4rside-site files.
cp -r src/f4rside-site/src srv/f4rside.com
# Build and copy developer-portfolio site.
cd src/developer-portfolio || exit
npm install
node_modules/.bin/gulp build
cd ../..
cp -r src/developer-portfolio/dist srv/jurassic-john.site

printf "\nCopying Nginx configuration...\n"
cp -r src/server-config-nginx/h5bp config/h5bp
cp -r nginx/conf.d config/conf.d
cp src/server-config-nginx/conf.d/.default.conf config/conf.d
cp src/server-config-nginx/conf.d/no-ssl.default.conf config/conf.d
cp src/server-config-nginx/mime.types config
cp src/server-config-nginx/nginx.conf config

printf "\nRemoving sources after build and copy...\n"
rm -rf src

printf "\nRunning Docker build!\n"
docker build -t "$1" .

printf "\nAll Done!\n"
