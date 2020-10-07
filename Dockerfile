# Nginx base image.
FROM nginx
# Nginx configuration.
COPY config /etc/nginx
# Copy sites and certificates.
RUN mkdir -p /srv
COPY srv srv/
# Protect private keys.
RUN chmod 400 /srv/certs/*.key
