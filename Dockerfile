# Create the Nginx ingress proxy image.
FROM johnchase/golden-nginx:latest AS ingress-proxy

ARG BUILD_TAG=local
LABEL build_tag=${BUILD_TAG}
LABEL description="My Ingress Proxy"

# Copy the certificates.
COPY nginx/certs/ /etc/nginx/certs/
# Protect any private keys.
RUN chmod 400 /etc/nginx/certs/*.key
# Copy the site specific Nginx configuration files.
COPY nginx/conf.d/ /etc/nginx/conf.d/
