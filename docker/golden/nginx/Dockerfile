# Add git to base alpine image.
FROM alpine:3.11 AS builder-golden-nginx

RUN apk --no-cache add git

# Create a work area we'll be able to copy files from.
WORKDIR /src

# Clone the Nginx configuration files repo.
RUN git clone --single-branch --no-tags --depth 1 https://github.com/RatJuggler/server-configs-nginx.git .


# Create the Nginx web server golden image and copy over the configuration files.
FROM nginx:stable-alpine AS golden-nginx

ARG BUILD_TAG=local
LABEL build_tag=${BUILD_TAG}
LABEL description="My Nginx Golden Image"
LABEL maintainer="John Chase <ratteal@gmail.com>"

HEALTHCHECK --interval=5m --timeout=10s --start-period=60s --retries=3 \
    CMD ["curl", "--silent", "--fail", "http://localhost:8000/health"]

# Image should be used with default HTTP/HTTPS ports and 8000 port for health/metrics.
EXPOSE 80 443 8000

# Copy the Nginx configuration files.
COPY --from=builder-golden-nginx src/h5bp/ /etc/nginx/h5bp/
COPY --from=builder-golden-nginx src/mime.types src/nginx.conf /etc/nginx/
COPY --from=builder-golden-nginx src/conf.d/metrics.default.conf /etc/nginx/conf.d/metrics.conf
