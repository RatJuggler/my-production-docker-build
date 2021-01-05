# my-production-docker-build

This is still a work in progress and is my attempt at a unified build process for the various projects I'm running on my Pi farm.

The goal to start with is to build all the images I want by cloning repos and running all the builds with a single command:

    ./build.sh

Currently, the script pulls down the sources and then any building and copying is done in the multi-stage docker file. This 
includes the Nginx configuration files from [Nginx HTTP server boilerplate configs](https://github.com/RatJuggler/server-configs-nginx/tree/production).

Note, the site certificates and private keys are bundled with the image so this is not an ideal solution from a security 
perspective. Anyone with access to the generated Docker image can retrieve them. This also makes updating the certificates 
automatically harder as the Docker image must be re-created to include the updates and any running containers then restarted with 
the new image.
