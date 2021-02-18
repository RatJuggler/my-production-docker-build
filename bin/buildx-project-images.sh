#!/bin/bash

./bin/buildx.sh -p johnchase -u https://github.com/RatJuggler/sync-gandi-dns
./bin/buildx.sh -p johnchase -u https://github.com/RatJuggler/guinea-bot
./bin/buildx.sh -p johnchase -u https://github.com/RatJuggler/dinosauria-bot
./bin/buildx.sh -p johnchase -u https://github.com/RatJuggler/f4rside-site

#./bin/buildx.sh -p johnchase -u https://github.com/RatJuggler/developer-portfolio -c docker-compose-shared.yml

#./bin/buildx.sh -p johnchase -u https://github.com/RatJuggler/developer-portfolio -c docker-compose-builders.yml

#./bin/buildx.sh -p johnchase -u https://github.com/RatJuggler/developer-portfolio
