#!/bin/bash

echo "My Nginx Static Site Docker Builder"
# Checkout a shallow copy of the base Nginx configuration.
git clone --depth 1 https://github.com/RatJuggler/server-configs-nginx.git config
