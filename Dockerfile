# Nginx base image.
FROM nginx
# Nginx configuration.
COPY config/ /etc/nginx
# Site sites and certificates.
COPY srv /
# Protect private key.
RUN chmod 400 /srv/certs/jurassic-john.site.key
