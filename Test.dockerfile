# Create the Nginx test ingress proxy image.
ARG DOCKER_REGISTRY=""
ARG DOCKER_ID=""
FROM ${DOCKER_REGISTRY}${DOCKER_ID}golden-nginx:latest AS ingress-proxy-test

ARG BUILD_TAG=local
LABEL build_tag=${BUILD_TAG}
LABEL description="My Test Ingress Proxy"

# Copy the site specific Nginx test configuration files.
COPY nginx/conf.d/test/ /etc/nginx/conf.d/
