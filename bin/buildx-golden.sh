# Build golden images.

export REGISTRY="docker.io/"
export REPOSITORY="johnchase/"
export IMAGE_TAG="latest"
export BUILD_TAG="buildx"

docker buildx bake -f ./docker/golden/nginx/docker-compose.yml --set *.platform=linux/amd64 --set *.platform=linux/arm/v7 --push
