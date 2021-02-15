# Build for the ingress proxy.
# IMPORTANT: We must *NOT* push the ingress proxy image to a public repository whilst it contains our certificate keys!

export REGISTRY="docker.io/"
export REPOSITORY="johnchase/"
export IMAGE_TAG="latest"
export BUILD_TAG="local"

docker-compose -f ./docker/ingress/test/docker-compose.yml build \
  --build-arg REGISTRY="$REGISTRY" \
  --build-arg REPOSITORY="$REPOSITORY" \
  --build-arg BUILD_TAG="$BUILD_TAG"

docker-compose -f ./docker/ingress/production/docker-compose.yml build \
  --build-arg REGISTRY="$REGISTRY" \
  --build-arg REPOSITORY="$REPOSITORY" \
  --build-arg BUILD_TAG="$BUILD_TAG"
