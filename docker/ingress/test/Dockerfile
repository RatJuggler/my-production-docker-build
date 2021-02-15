# Create the Nginx test ingress proxy image.
ARG REGISTRY=""
ARG REPOSITORY=""
FROM ${REGISTRY}${REPOSITORY}golden-nginx:latest AS ingress-proxy-test

ARG BUILD_TAG=local
LABEL build_tag=${BUILD_TAG}
LABEL description="My Test Ingress Proxy"

# Copy the site specific Nginx test configuration files.
COPY ./nginx/conf.d /etc/nginx/conf.d/
