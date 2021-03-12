#!/bin/bash

# Run these builds on linux-amd32 and linux-arm:
#./bin/build.sh -m -p johnchase -u https://github.com/RatJuggler/sync-gandi-dns
#./bin/build.sh -m -p johnchase -u https://github.com/RatJuggler/guinea-bot
#./bin/build.sh -m -p johnchase -u https://github.com/RatJuggler/dinosauria-bot
#./bin/build.sh -m -p johnchase -u https://github.com/RatJuggler/f4rside-site

# Then create manifests with:
#./bin/build-manifest.sh -g docker.io -p johnchase -i sync-gandi-dns
#./bin/build-manifest.sh -g docker.io -p johnchase -i guinea-bot
#./bin/build-manifest.sh -g docker.io -p johnchase -i dinosauria-bot
#./bin/build-manifest.sh -g docker.io -p johnchase -i f4rside-site

# Run this build on linux-amd32 and linux-arm:
#./bin/build.sh -m -p johnchase -u https://github.com/RatJuggler/developer-portfolio -c docker-compose-shared.yml

# Then create the manifest with:
#./bin/build-manifest.sh -g docker.io -p johnchase -i builder-shared-resources

# Run this build on linux-amd32 and linux-arm:
#./bin/build.sh -m -p johnchase -u https://github.com/RatJuggler/developer-portfolio -c docker-compose-builders.yml

# Then create manifests with:
#./bin/build-manifest.sh -g docker.io -p johnchase -i builder-portfolio-map
#./bin/build-manifest.sh -g docker.io -p johnchase -i builder-portfolio-sql
#./bin/build-manifest.sh -g docker.io -p johnchase -i builder-portfolio-react
#./bin/build-manifest.sh -g docker.io -p johnchase -i builder-portfolio-combined

# Run this build on linux-amd32 and linux-arm:
#./bin/build.sh -m -p johnchase -u https://github.com/RatJuggler/developer-portfolio

# Then create manifests with:
#./bin/build-manifest.sh -g docker.io -p johnchase -i portfolio-map
#./bin/build-manifest.sh -g docker.io -p johnchase -i portfolio-sql
#./bin/build-manifest.sh -g docker.io -p johnchase -i portfolio-react
#./bin/build-manifest.sh -g docker.io -p johnchase -i portfolio-template
#./bin/build-manifest.sh -g docker.io -p johnchase -i portfolio-static
#./bin/build-manifest.sh -g docker.io -p johnchase -i portfolio-site
