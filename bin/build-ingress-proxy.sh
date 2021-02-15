# Build for the ingress proxy.
# IMPORTANT: We must *NOT* push the ingress proxy image to a public repository whilst it contains our certificate keys!

export REGISTRY="docker.io/"
export REPOSITORY="johnchase/"
export BUILD_TAG="test"

cd ./docker/ingress/test || exit
docker-compose -f docker-compose.yml build \
  --build-arg REGISTRY="$REGISTRY" \
  --build-arg REPOSITORY="$REPOSITORY" \
  --build-arg BUILD_TAG="$BUILD_TAG"
cd ../../..
cd ./docker/ingress/production || exit
docker-compose -f docker-compose.yml build \
  --build-arg REGISTRY="$REGISTRY" \
  --build-arg REPOSITORY="$REPOSITORY" \
  --build-arg BUILD_TAG="$BUILD_TAG"
cd ../../..
