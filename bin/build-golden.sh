# Build golden images.

export REGISTRY="docker.io/"
export REPOSITORY="johnchase/"
export IMAGE_TAG="linux-amd64"
export BUILD_TAG="local"

docker-compose -f ./docker/golden/nginx/docker-compose.yml build \
  --build-arg REGISTRY="$REGISTRY" \
  --build-arg REPOSITORY="$REPOSITORY" \
  --build-arg BUILD_TAG="$BUILD_TAG"

docker-compose -f ./docker/golden/nginx/docker-compose.yml push
