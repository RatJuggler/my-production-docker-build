# Create the Nginx ingress proxy image.
FROM johnchase/golden-nginx:latest AS ingress-proxy

ARG BUILD_TAG=local
LABEL build_tag=${BUILD_TAG}
LABEL description="My Ingress Proxy"

# Create a folder to serve the site(s) from.
WORKDIR /srv

# Copy the certificates.
COPY nginx/certs/ certs/
# Protect any private keys.
RUN chmod 400 certs/*.key
# Copy the site specific Nginx configuration files.
COPY nginx/conf.d/ /etc/nginx/conf.d/
