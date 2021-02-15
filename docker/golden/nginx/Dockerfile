# Add git to base alpine image.
FROM alpine:3.11 AS builder-golden-nginx

RUN apk --no-cache add git

# Create a work area we'll be able to copy files from.
WORKDIR /src

# Clone the production bracnch of the Nginx configuration files repo.
RUN git clone --single-branch --no-tags --depth 1 --branch my-production https://github.com/RatJuggler/server-configs-nginx.git .


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
COPY --from=builder-golden-nginx src/h5bp/ /etc/nginx/h5bp/
COPY --from=builder-golden-nginx src/mime.types src/nginx.conf /etc/nginx/
