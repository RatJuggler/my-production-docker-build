# Add Certbot and the Gandi authentication plugin to base alpine image.
FROM alpine:3.13 AS golden-certbot

ARG BUILD_TAG=local
LABEL build_tag=${BUILD_TAG}
LABEL description="My Certbot Golden Image"
LABEL maintainer="John Chase <ratteal@gmail.com>"

RUN apk add certbot py3-pip
RUN pip3 install --no-cache-dir -U certbot-plugin-gandi
