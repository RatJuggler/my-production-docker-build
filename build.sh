#!/bin/bash

echo "My Nginx Static Site Docker Builder"

echo "Clear down any previous build..."
rm -rf src
mkdir src
rm -rf config
mkdir config

echo "Pull resource required..."
# Checkout a shallow copy of f4rside-site.
git clone --single-branch --depth 1 https://github.com/RatJuggler/f4rside-site.git src/f4rside-site
# Checkout a shallow copy of developer-portfolio.
git clone --single-branch --depth 1 https://github.com/RatJuggler/developer-portfolio.git src/developer-portfolio
# Checkout a shallow copy of the base Nginx configuration.
git clone --single-branch --branch production --depth 1 https://github.com/RatJuggler/server-configs-nginx.git src/server-config-nginx

echo "Build/copy sites to serve..."
# Copy f4rside-site files.
cp -r src/f4rside-site/src srv/f4rside.com
# Build and copy developer-portfolio site.
cd src/developer-portfolio || exit
npm install
node_modules/.bin/gulp build
cd ../..
cp -r src/developer-portfolio/dist srv/jurassic-john.site

echo "Copy Nginx configuration..."
cp -r src/server-config-nginx/h5bp config/h5bp
cp -r nginx/conf.d config/conf.d
cp src/server-config-nginx/conf.d/.default.conf config/conf.d
cp src/server-config-nginx/conf.d/no-ssl.default.conf config/conf.d
cp src/server-config-nginx/mime.types config
cp src/server-config-nginx/nginx.conf config

echo "Remove sources after build and copy..."
rm -rf src

echo "Running Docker build!"
docker build -t "$1" .
