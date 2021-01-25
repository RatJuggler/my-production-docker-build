# Applications requiring a build.
FROM node:lts-alpine AS builder

# developer-portfolio build.

# Location of the source code.
WORKDIR /developer-portfolio
# Install the build dependencies.
COPY src/developer-portfolio/package.json .
RUN npm install
# Copy the sources and run the build.
COPY src/developer-portfolio .
RUN node_modules/.bin/gulp build


# Create the Node application image.
FROM node:lts-alpine AS node-application

ENV NODE_ENV=production

ARG BUILD_TAG=local
LABEL build_tag=${BUILD_TAG}

EXPOSE 3000
CMD ["node", "./app/app.js", "app/"]

# Create a folder to serve the application from.
WORKDIR /srv
# Install the runtime dependencies.
COPY src/developer-portfolio/package.json .
RUN npm install
# Copy the developer-portfolio application files from the build.
COPY --from=builder /developer-portfolio/dist/ .


# Create the Nginx web server image.
FROM johnchase/golden-nginx:latest AS nginx-public-files

ARG BUILD_TAG=local
LABEL build_tag=${BUILD_TAG}

EXPOSE 80

# Create a folder to serve the site(s) from.
WORKDIR /srv

# Copy the certificates.
COPY nginx/certs/ certs/
# Protect any private keys.
RUN chmod 400 /srv/certs/*.key
# Copy the site specific Nginx configuration files.
COPY nginx/conf.d/ /etc/nginx/conf.d/

# Copy the static f4rside-site distribution files directly from the project.
COPY src/f4rside-site/src/ /srv/f4rside.com/

# Copy the static developer-portfolio distribution files from the build.
COPY --from=builder /developer-portfolio/dist/public/ /srv/jurassic-john.site/
