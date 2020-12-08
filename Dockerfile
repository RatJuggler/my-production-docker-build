# Build any applications requiring Node.
FROM node:12.20.0 AS builder

# developer-portfolio build.

# Location of source code.
WORKDIR /developer-portfolio
# Install dependencies.
COPY src/developer-portfolio/package.json .
RUN npm install
# Copy the sources and run the build.
COPY src/developer-portfolio .
RUN node_modules/.bin/gulp build


# Create the Nginx application image.
FROM nginx

# Create a folder to server the site(s) from.
WORKDIR /srv

# Copy f4rside-site distribution files.
COPY src/f4rside-site/src/ /srv/f4rside.com/

# Copy developer-portfolio distribution files.
COPY --from=builder /developer-portfolio/dist/public/ /srv/jurassic-john.site/

# Copy Nginx configuration files.
COPY config/ /etc/nginx/

# Copy the certificates.
COPY nginx/certs/ certs/

# Protect any private keys.
RUN chmod 400 /srv/certs/*.key
