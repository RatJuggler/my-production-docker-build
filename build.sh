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
rm -rf srv
mkdir srv

printf "\nClone and copy files for f4rside.com...\n"
# Checkout a shallow copy of f4rside-site.
git clone --single-branch --depth 1 https://github.com/RatJuggler/f4rside-site.git src/f4rside-site
# Copy f4rside-site distribution files.
cp -r src/f4rside-site/src srv/f4rside.com

printf "\nClone, build and copy files for jurassic-john.site...\n"
# Checkout a shallow copy of developer-portfolio.
git clone --single-branch --depth 1 https://github.com/RatJuggler/developer-portfolio.git src/developer-portfolio
# Build developer-portfolio site.
cd src/developer-portfolio || exit
npm install
node_modules/.bin/gulp build
cd ../..
# Copy developer-portfolio distribution files.
cp -r src/developer-portfolio/dist/public srv/jurassic-john.site

printf "\nClone and copy files for Nginx configuration...\n"
# Checkout a shallow copy of the base Nginx configuration.
git clone --single-branch --depth 1 --branch production https://github.com/RatJuggler/server-configs-nginx.git src/server-config-nginx
# Copy the required files.
cp -r src/server-config-nginx/h5bp config/h5bp
cp -r nginx/conf.d config/conf.d
cp src/server-config-nginx/conf.d/.default.conf config/conf.d
cp src/server-config-nginx/conf.d/no-ssl.default.conf config/conf.d
cp src/server-config-nginx/mime.types config
cp src/server-config-nginx/nginx.conf config

printf "\nCopying certificates...\n"
cp -r nginx/certs srv/certs

printf "\nRemoving sources after build and copy...\n"
rm -rf src

printf "\nRunning Docker build!\n"
docker build -t "$1" .

printf "\nAll Done!\n"
