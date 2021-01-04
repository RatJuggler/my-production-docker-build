# my-production-docker-build

This is my attempt at a unified build process for the various projects I'm running on my Pi farm.

Assuming you have Docker installed, and the daemon running, then to do a full build you would use the following from the root folder:

    ./build.sh IMAGE-NAME

The generated images can then be run with the usual command:

    docker run -d --restart unless-stopped -p 80:80 -p 443:443 IMAGE-NAME

The script pulls down the site sources and then any building and copying is done in the multi-stage docker file. This includes the 
Nginx configuration files (see [Nginx HTTP server boilerplate configs](https://github.com/RatJuggler/server-configs-nginx/tree/production)).

Note, the site certificates and private keys are bundled with the image so this is not an ideal solution from a security 
perspective. Anyone with access to the generated Docker image can retrieve them. This also makes updating the certificates 
automatically harder as the Docker image must be re-created to include the updates and any running containers then restarted with 
the new image.
