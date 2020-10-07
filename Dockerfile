# Nginx base image.
FROM nginx
# Nginx configuration.
COPY config /etc/nginx
# Create a folder to server the site(s) from.
WORKDIR /srv
# Copy the site(s) and certificates.
COPY srv .
# Protect any private keys.
RUN chmod 400 /srv/certs/*.key
