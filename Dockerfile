# Applications requiring a build.
FROM node:12-alpine AS builder

# developer-portfolio build.

# Location of source code.
WORKDIR /developer-portfolio
# Install build dependencies.
COPY src/developer-portfolio/package.json .
RUN npm install
# Copy the sources and run the build.
COPY src/developer-portfolio .
RUN node_modules/.bin/gulp build


# Create the Nginx application image.
FROM nginx:alpine

# Create a folder to serve the site(s) from.
WORKDIR /srv

# Copy the f4rside-site distribution files.
COPY src/f4rside-site/src/ /srv/f4rside.com/

# Copy the developer-portfolio distribution files.
COPY --from=builder /developer-portfolio/dist/public/ /srv/jurassic-john.site/

# Copy the Nginx configuration files.
COPY src/server-config-nginx/h5bp/ /etc/nginx/h5bp/
COPY src/server-config-nginx/mime.types src/server-config-nginx/nginx.conf /etc/nginx/
COPY nginx/conf.d/ /etc/nginx/conf.d/

# Copy the certificates.
COPY nginx/certs/ certs/

# Protect any private keys.
RUN chmod 400 /srv/certs/*.key
