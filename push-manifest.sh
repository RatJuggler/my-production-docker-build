#!/bin/bash

function show_usage() {
   printf "My Docker Multi-Architecture Manifest Builder\n\n"
   printf "'linux-amd' and 'linux-arm' images must have already been created and tagged.\n\n"
   printf "Usage: push-manifest [-h] [-i IMAGE_NAME] [-g REGISTRY] [-p REPOSITORY] [-t IMAGE_TAG]\n\n"
   printf "Options:\n"
   printf "  -h             display this help and exit\n"
   printf "  -i IMAGE_NAME  name of the image to make multi-architecture, required\n"
   printf "  -g REGISTRY    set the docker registry to use, does NOT default to 'docker.io', required\n"
   printf "  -p REPOSITORY  set the docker repository (id) to use, required\n"
   printf "  -t IMAGE_TAG   set the manifest image tag to use, defaults to 'latest'\n"
}

function pull_image() {
  PULL=$(docker image pull "$IMAGE":"$1" 2>&1)
  if [[ $? -eq 1 ]]; then
    printf "push-manifest: no '%s' image found with a '%s' tag!\n" "$IMAGE" "$1"
    exit 1
  fi
  printf "%s" "$PULL"
}

function create_and_push() {
  IMAGE="$REGISTRY$REPOSITORY$1"
  # Pull the latest images for each architecture.
  pull_image 'linux-amd64'
  pull_image 'linux-arm'
  # Create the manifest.
  docker manifest create "$IMAGE":latest "$IMAGE":linux-amd64 "$IMAGE":linux-arm
  # Only push it and clear down if a registry and a repository have been set.
  if [[ -n "$REGISTRY" && -n "$REPOSITORY" ]]; then
    docker manifest push --purge "$IMAGE":"$IMAGE_TAG"
  fi
}

# ======================
# Main code starts here.
# ======================

# Process options and validate combinations.

while getopts :g:hi:p:t: OPTION
do
  case "${OPTION}" in
    g)
      REGISTRY=${OPTARG}/
      ;;
    h)
      show_usage
      exit 0
      ;;
    i)
      IMAGE_NAME=${OPTARG}
      ;;
    p)
      REPOSITORY=${OPTARG}/
      ;;
    t)
      IMAGE_TAG=${OPTARG}
      ;;
    ?)
      printf "push-manifest: invalid option -- '%s'\n" "${OPTARG}"
      printf "Try 'push-manifest -h' for more information.\n"
      exit 1
      ;;
  esac
done

if [[ -z "$REGISTRY" || -z "$REPOSITORY" || -z "$IMAGE_NAME" ]]; then
  printf "push-manifest: A registry, repository (docker id) and image name must be supplied!\n"
  exit 1
fi

# Processing started.

printf "My Docker Multi-Architecture Manifest Builder\n"
printf "=============================================\n\n"

# Show how options will be used.

printf -v REGISTRY_USED "Registry '%s' will be used to source images and store manifest" "$REGISTRY"

printf -v REPOSITORY_USED "Manifest image will be tagged with repository '%s'" "$REPOSITORY"

if [[ -n "$IMAGE_TAG" ]]; then
  printf -v TAG_USED "Manifest image will be tagged with '%s'" "$IMAGE_TAG"
else
  IMAGE_TAG=latest
  printf -v TAG_USED "Not set, default manifest image tag '%s' will be used" "$IMAGE_TAG"
fi

printf "Docker Registry         : %s\n" "$REGISTRY_USED"
printf "Docker Repository (Id)  : %s\n" "$REPOSITORY_USED"
printf "Image Tag               : %s\n" "$TAG_USED"

# Create and push the manifest.

create_and_push "$IMAGE_NAME"

# Post processing and exit.

printf "\nAll Done!\n"

exit 0
