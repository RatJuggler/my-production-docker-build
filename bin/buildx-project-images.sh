#!/bin/bash

./bin/buildx.sh -p johnchase -u https://github.com/RatJuggler/sync-gandi-dns
./bin/buildx.sh -p johnchase -u https://github.com/RatJuggler/guinea-bot
./bin/buildx.sh -p johnchase -u https://github.com/RatJuggler/dinosauria-bot
./bin/buildx.sh -p johnchase -u https://github.com/RatJuggler/f4rside-site

# The following image builds are returning an error related to the libseccomp2 issue:
# OpenJDK Server VM warning: No monotonic clock was available - timed services may be adversely affected if the time-of-day clock changes

./bin/buildx.sh -p johnchase -u https://github.com/RatJuggler/developer-portfolio -c docker-compose-shared.yml

./bin/buildx.sh -p johnchase -u https://github.com/RatJuggler/developer-portfolio -c docker-compose-builders.yml

./bin/buildx.sh -p johnchase -u https://github.com/RatJuggler/developer-portfolio
