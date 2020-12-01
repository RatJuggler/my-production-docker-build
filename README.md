# nginx-docker-build

This is a basic outline for building a Nginx docker image for one, or more, static web sites.

Assuming you have Docker installed, and the daemon running, then to pull all the resources, build the site and finally build the 
container use the following from the root folder:

    ./build IMAGE-NAME

Then run it with the usual commands:

    docker run -d --restart unless-stopped -p 80:80 -p 443:443 IMAGE-NAME

The script includes all the commands for pulling down the site sources and building them, but removes the original sources before 
starting the docker build. This leaves the build context with the Nginx configuration files (see [Nginx HTTP server boilerplate configs](https://github.com/RatJuggler/server-configs-nginx/tree/production))
under a `config` folder and a `srv` folder for the sites to serve.

Ideally I need to move more of the build process into a multi-stage docker file.

Also, because the site certificates and private keys are bundled with the image this is not an ideal solution from a security 
perspective. Anyone with access to the generated Docker image can retrieve them. This also makes updating certificates automatically 
harder as the Docker image must be re-created to include any updates and any running containers then restarted with the new image.
