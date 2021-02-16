# Build golden images.

# The build must be run on intel with the image tag set to 'linux-amd64', then on arm with the image tag set to 'linux-arm'.
# Multi-architecture images can then be created using:
#./bin/build-manifest.sh -g docker.io -p johnchase -i golden-nginx

export REGISTRY="docker.io/"
export REPOSITORY="johnchase/"
export IMAGE_TAG="linux-amd64"
export BUILD_TAG="local"

docker-compose -f ./docker/golden/nginx/docker-compose.yml build \
  --build-arg REGISTRY="$REGISTRY" \
  --build-arg REPOSITORY="$REPOSITORY" \
  --build-arg BUILD_TAG="$BUILD_TAG"

docker-compose -f ./docker/golden/nginx/docker-compose.yml push
