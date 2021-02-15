#!/bin/bash

./push-manifest.sh -g docker.io -p johnchase -i sync-gandi-dns
./push-manifest.sh -g docker.io -p johnchase -i guinea-bot
./push-manifest.sh -g docker.io -p johnchase -i dinosauria-bot
./push-manifest.sh -g docker.io -p johnchase -i f4rside-site

./push-manifest.sh -g docker.io -p johnchase -i portfolio-simple
./push-manifest.sh -g docker.io -p johnchase -i portfolio-sql
./push-manifest.sh -g docker.io -p johnchase -i portfolio-template
./push-manifest.sh -g docker.io -p johnchase -i portfolio-static
./push-manifest.sh -g docker.io -p johnchase -i portfolio-site
