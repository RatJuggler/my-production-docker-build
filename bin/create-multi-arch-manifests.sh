#!/bin/bash

./bin/push-manifest.sh -g docker.io -p johnchase -i sync-gandi-dns
./bin/push-manifest.sh -g docker.io -p johnchase -i guinea-bot
./bin/push-manifest.sh -g docker.io -p johnchase -i dinosauria-bot
./bin/push-manifest.sh -g docker.io -p johnchase -i f4rside-site

./bin/push-manifest.sh -g docker.io -p johnchase -i builder-share-resources
./bin/push-manifest.sh -g docker.io -p johnchase -i builder-portfolio-simple
./bin/push-manifest.sh -g docker.io -p johnchase -i portfolio-simple
./bin/push-manifest.sh -g docker.io -p johnchase -i builder-portfolio-sql
./bin/push-manifest.sh -g docker.io -p johnchase -i portfolio-sql
./bin/push-manifest.sh -g docker.io -p johnchase -i builder-portfolio-combined
./bin/push-manifest.sh -g docker.io -p johnchase -i portfolio-template
./bin/push-manifest.sh -g docker.io -p johnchase -i portfolio-static
./bin/push-manifest.sh -g docker.io -p johnchase -i portfolio-site
