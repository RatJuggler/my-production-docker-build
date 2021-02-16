#!/bin/bash

./bin/build-manifest.sh -g docker.io -p johnchase -i sync-gandi-dns
./bin/build-manifest.sh -g docker.io -p johnchase -i guinea-bot
./bin/build-manifest.sh -g docker.io -p johnchase -i dinosauria-bot
./bin/build-manifest.sh -g docker.io -p johnchase -i f4rside-site

./bin/build-manifest.sh -g docker.io -p johnchase -i builder-shared-resources
./bin/build-manifest.sh -g docker.io -p johnchase -i builder-portfolio-simple
./bin/build-manifest.sh -g docker.io -p johnchase -i portfolio-simple
./bin/build-manifest.sh -g docker.io -p johnchase -i builder-portfolio-sql
./bin/build-manifest.sh -g docker.io -p johnchase -i portfolio-sql
./bin/build-manifest.sh -g docker.io -p johnchase -i builder-portfolio-combined
./bin/build-manifest.sh -g docker.io -p johnchase -i portfolio-template
./bin/build-manifest.sh -g docker.io -p johnchase -i portfolio-static
./bin/build-manifest.sh -g docker.io -p johnchase -i portfolio-site
