#!/usr/bin/env bash

# https://docs.docker.com/docker-hub/usage/pulls
# Pull rate limit per 6 hours: 200

set -eEuo pipefail

: "${USERNAME_1:?missing USERNAME_1}"
: "${USERNAME_2:?missing USERNAME_2}"
: "${USERNAME_3:?missing USERNAME_3}"
: "${USERNAME_4:?missing USERNAME_4}"
: "${USERNAME_5:?missing USERNAME_5}"
: "${REGISTRY_IMAGE:?missing REGISTRY_IMAGE}"
: "${DOCKER_PASSWORD:?missing DOCKER_PASSWORD}"

USERNAMES=(
    "$USERNAME_1"
    "$USERNAME_2"
    "$USERNAME_3"
    "$USERNAME_4"
    "$USERNAME_5"
)

VERSION="$(skopeo list-tags "docker://$REGISTRY_IMAGE" | jq -r '.Tags[]? | select(test("^v?[0-9]+(?:\\.[0-9]+)*"))' | sort -V | tail -n 1)"

for u in "${!USERNAMES[@]}"; do
    docker login -u "${USERNAMES[$u]}" --password-stdin <<< "$DOCKER_PASSWORD" 2> /dev/null
    for ((i = 1; i <= 50; i++)); do
        docker pull "$DOCKER_REPO":"$VERSION"
        docker rmi --force "$DOCKER_REPO":"$VERSION"
    done
    docker logout > /dev/null 2>&1
done
