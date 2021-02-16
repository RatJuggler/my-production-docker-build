#!/bin/bash

./bin/build.sh -m -p johnchase -u https://github.com/RatJuggler/sync-gandi-dns
./bin/build.sh -m -p johnchase -u https://github.com/RatJuggler/guinea-bot
./bin/build.sh -m -p johnchase -u https://github.com/RatJuggler/dinosauria-bot
./bin/build.sh -m -p johnchase -u https://github.com/RatJuggler/f4rside-site

./bin/build.sh -m -p johnchase -u https://github.com/RatJuggler/developer-portfolio -c docker-compose-builders.yml
./bin/build.sh -m -p johnchase -u https://github.com/RatJuggler/developer-portfolio
