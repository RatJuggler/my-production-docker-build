# Build for the ingress proxy.

export REGISTRY="docker.io/"
export REPOSITORY="johnchase/"
export IMAGE_TAG="latest"
export BUILD_TAG="buildx"

cd docker/ingress/test || exit
docker buildx bake -f docker-compose.yml --set *.platform=linux/amd64 --set *.platform=linux/arm/v7 --push
cd ../../.. || exit

cd docker/ingress/production || exit
docker buildx bake -f docker-compose.yml --set *.platform=linux/amd64 --set *.platform=linux/arm/v7 --push
cd ../../.. || exit
