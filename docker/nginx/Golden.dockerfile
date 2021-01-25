# Image with git.
FROM alpine/git:latest AS builder

# Create a work area we'll be able to copy files from.
WORKDIR /src

# Clone the production bracnch of the Nginx configuration files repo.
RUN git clone --single-branch --depth 1 --branch production https://github.com/RatJuggler/server-configs-nginx.git .


# Create the Nginx web server golden image and include the configuration files.
FROM nginx:stable-alpine AS golden-nginx

ARG BUILD_TAG=local
LABEL build_tag=${BUILD_TAG}
LABEL description="My Nginx Golden Image"
LABEL maintainer="John Chase <ratteal@gmail.com>"

EXPOSE 80

# Create a folder to serve the site(s) from.
WORKDIR /srv

# Copy the Nginx configuration files.
COPY --from=builder src/h5bp/ /etc/nginx/h5bp/
COPY --from=builder src/mime.types src/nginx.conf /etc/nginx/
