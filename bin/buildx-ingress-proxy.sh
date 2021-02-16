# Build for the ingress proxy.

export REGISTRY="docker.io/"
export REPOSITORY="johnchase/"
export IMAGE_TAG="latest"
export BUILD_TAG="buildx"

docker buildx bake -f ./docker/ingress/test/docker-compose.yml --set *.platform=linux/amd64 --set *.platform=linux/arm/v7 --push

docker buildx bake -f ./docker/ingress/production/docker-compose.yml --set *.platform=linux/amd64 --set *.platform=linux/arm/v7 --push
