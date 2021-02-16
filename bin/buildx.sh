#!/bin/bash

function show_usage() {
   printf "My Project Multi-Arch Docker Image Builder\n\n"
   printf "Usage: buildx [-h] [-g GIT_REPO] [-c COMPOSE] [-r REGISTRY] [-p REPOSITORY] [-t IMAGE_TAG]\n\n"
   printf "Options:\n"
   printf "  -h             display this help and exit\n"
   printf "  -u GIT_URL     the URL of the git repo to run a build for, required\n"
   printf "  -c COMPOSE     the docker-compose file to build from, defaults to 'docker-compose.yml'\n"
   printf "  -g REGISTRY    set the docker registry to use, defaults to 'docker.io'\n"
   printf "  -p REPOSITORY  set the docker repository (id) to use, required\n"
   printf "  -t IMAGE_TAG   set the image tag to use, defaults to 'latest'\n"
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
  docker buildx bake -f "$COMPOSE" --set *.platform=linux/amd64 --set *.platform=linux/arm/v7 --push

  # Restore previous CWD.
  cd ../.. || exit
}

# ======================
# Main code starts here.
# ======================

# Process options and validate combinations.

while getopts :c:g:hp:t:u: OPTION
do
  case "${OPTION}" in
    c)
      export COMPOSE=${OPTARG}
      ;;
    g)
      export REGISTRY=${OPTARG}/
      ;;
    h)
      show_usage
      exit 0
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
      printf "buildx: invalid option -- '%s'\n" "${OPTARG}"
      printf "Try 'buildx -h' for more information.\n"
      exit 1
      ;;
  esac
done

if [[ -z "$GIT_URL" ]]; then
  printf "buildx: git URL of project must be supplied!\n"
  exit 1
fi

if [[ -z "$COMPOSE" ]]; then
  export COMPOSE="docker-compose.yml"
fi

if [[ -z "$REPOSITORY" ]]; then
  printf "buildx: docker repository (id) must be set!\n"
  exit 1
fi

# Processing started.

printf "My Docker Builder\n"
printf "=================\n\n"

# Set a static build tag for the moment.

export BUILD_TAG="buildx"

printf "Using Build Tag         : %s\n" "$BUILD_TAG"

# Show how options will be used.

if [[ -z "$REGISTRY" ]]; then
  printf -v REGISTRY_USED "Not set, default registry will be used"
else
  printf -v REGISTRY_USED "Images will be pushed to registry '%s'" "$REGISTRY"
fi

if [[ -z "$IMAGE_TAG" ]]; then
  printf -v TAG_USED "Not set, default image tag will be used"
else
  printf -v TAG_USED "Images will be tagged with '%s'" "$IMAGE_TAG"
fi

printf "Project Git URL         : %s\n" "$GIT_URL"
printf "Project Name            : %s\n" "$REPO_NAME"
printf "Compose File            : %s\n" "$COMPOSE"
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
