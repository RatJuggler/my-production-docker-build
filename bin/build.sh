#!/bin/bash

function show_usage() {
   printf "My Project Docker Image Builder\n\n"
   printf "Usage: build [-h] [-g GIT_REPO] [-m] [-r REGISTRY] [-p REPOSITORY] [-t IMAGE_TAG]\n\n"
   printf "Options:\n"
   printf "  -h             display this help and exit\n"
   printf "  -u GIT_URL     the URL of the git repo to run a build for, required\n"
   printf "  -m             set the image tag according to the local architecture, overrides '-t'\n"
   printf "  -g REGISTRY    set the docker registry to use, defaults to 'docker.io'\n"
   printf "  -p REPOSITORY  set the docker repository (id) to use, images will be pushed if set\n"
   printf "  -t IMAGE_TAG   set the image tag to use, defaults to 'latest', overridden by '-m'\n"
}

function checkout_and_build() {
  URL=$1
  REPO=$2
  # Checkout the bare source from repo, no history
  git clone --single-branch --no-tags --depth 1 "$URL".git src/"$REPO"
  # Make repo the CWD.
  cd src/"$REPO" || exit
  # env_file entries must exist for some compose files to be validated so we create a dummy one for building.
  touch "$REPO".env
  # Do the build.
  docker-compose -f docker-compose.yml --profile="builders" build \
    --build-arg REGISTRY="$REGISTRY" \
    --build-arg REPOSITORY="$REPOSITORY" \
    --build-arg BUILD_TAG="$BUILD_TAG"
  # Only do a push if a repository have been set.
  if [[ -n "$REPOSITORY" ]]; then
    docker-compose -f docker-compose.yml --profile="builders" push
  fi
  # Restore previous CWD.
  cd ../.. || exit
}

# ======================
# Main code starts here.
# ======================

# Process options and validate combinations.

while getopts :g:hmp:t:u: OPTION
do
  case "${OPTION}" in
    g)
      export REGISTRY=${OPTARG}/
      ;;
    h)
      show_usage
      exit 0
      ;;
    m)
      MULTI_ARCH=true
      ;;
    p)
      export REPOSITORY=${OPTARG}/
      ;;
    t)
      export IMAGE_TAG=${OPTARG}
      ;;
    u)
      GIT_URL=${OPTARG}
      # Extract the repo name from the URL.
      REPO_NAME=$(basename "$GIT_URL" .git)
      ;;
    ?)
      printf "build: invalid option -- '%s'\n" "${OPTARG}"
      printf "Try 'build -h' for more information.\n"
      exit 1
      ;;
  esac
done

if [[ -z "$GIT_URL" ]]; then
  printf "build: git URL of project must be supplied!\n"
  exit 1
fi

if [[ -n "$MULTI_ARCH" && -n "$IMAGE_TAG" ]]; then
  printf "build: image tag cannot be set when multi-architecture option selected!\n"
  exit 1
fi

if [[ -n "$REGISTRY" && -z "$REPOSITORY" ]]; then
  printf "build: docker repository (id) must also be set when specifying a registry!\n"
  exit 1
fi

# Processing started.

printf "My Docker Builder\n"
printf "=================\n\n"

# Determine architecture for build tag and use in multi-architecture builds.

ARCH=$(uname -m)
case "$ARCH" in
  x86_64)
    export BUILD_TAG="linux-amd64"
    ;;
  armv7l)
    export BUILD_TAG="linux-arm"
    ;;
  *)
    printf "Unexpected architecture '%s' found!\n" "$ARCH"
    exit 1
    ;;
esac

printf "Architecture Identified : %s\n" "$ARCH"
printf "Using Build Tag         : %s\n" "$BUILD_TAG"

if [[ -n "$MULTI_ARCH" ]]; then
  export IMAGE_TAG=$BUILD_TAG
fi

# Show how options will be used.

if [[ -z "$REGISTRY" ]]; then
  printf -v REGISTRY_USED "Not set, default registry will be used"
else
  printf -v REGISTRY_USED "Images will be pushed to registry '%s'" "$REGISTRY"
fi

if [[ -z "$REPOSITORY" ]]; then
  printf -v REPOSITORY_USED "Not set, local image only"
else
  printf -v REPOSITORY_USED "Images will be tagged with repository '%s' and pushed" "$REPOSITORY"
fi

if [[ -n "$MULTI_ARCH" ]]; then
  printf -v TAG_USED "Multi-architecture selected, images will be tagged with '%s'" "$IMAGE_TAG"
elif [[ -z "$IMAGE_TAG" ]]; then
  printf -v TAG_USED "Not set, default image tag will be used"
else
  printf -v TAG_USED "Images will be tagged with '%s'" "$IMAGE_TAG"
fi

printf "Project Git URL         : %s\n" "$GIT_URL"
printf "Project Name            : %s\n" "$REPO_NAME"
printf "Docker Registry         : %s\n" "$REGISTRY_USED"
printf "Docker Repository (Id)  : %s\n" "$REPOSITORY_USED"
printf "Image Tag               : %s\n" "$TAG_USED"

# Pre-builds processing.

printf "\nClearing down any previous builds...\n"
rm -rf src
mkdir src

# Build the project images.

checkout_and_build "$GIT_URL" "$REPO_NAME"

# Post builds processing and exit.

printf "\nAll Done!\n"

exit 0
