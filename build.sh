#!/bin/bash

echo "My Nginx Static Site Docker Builder"
# Clear previous build.
echo "Clearing down..."
rm -rf src
# Pull down resources required for build.
echo "Resource pull..."
# Checkout a shallow copy of the base Nginx configuration.
git clone --single-branch --branch production --depth 1 https://github.com/RatJuggler/server-configs-nginx.git src/config
# Checkout a shallow copy of f4rside-site.
git clone --single-branch --depth 1 https://github.com/RatJuggler/f4rside-site.git src/f4rside.com
# Checkout a shallow copy of developer-portfolio.
git clone --single-branch --depth 1 https://github.com/RatJuggler/developer-portfolio.git src/jurassic-john.site
