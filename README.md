# nginx-docker-build

This is a basic outline for building a Nginx docker image for one, or more, static web sites.

Assuming you have Docker installed and the daemon running then to build the container use from the roor folder:

  $ docker build -t IMAGE-NAME .

And then run it with the usual commands:

  $ docker run -d IMAGE-NAME

The docker build context includes the Nginx configuration files (see [Nginx HTTP server boilerplate configs](https://github.com/RatJuggler/server-configs-nginx/tree/add-misc-headers))
under the `config` folder and a `srv` folder for the sites to serve.

This is not currently an ideal solution as site specific configurations are mixed into the general Nginx configuration and the
web site files to serve need to be manually copied to the required folders. However, it will suffice for my simple static sites
until I can develop something more suited to an automated build.

In addition because any site certificates and private keys are also bundled with the image this is not an ideal solution from a
security perspective. Anyone with access to the generated Docker image can retrieve them. This also makes updating certificates
automatically harder as the Docker image must be re-created to include any updates and any running containers then restarted with
the new image.
