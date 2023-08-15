#!/usr/bin/env bash

docker-prune() {
    # Remove all docker data not used by a running container
    docker system prune --volumes -fa
}

docker-clean() {
    docker image prune -f
    docker builder prune -af
    # Clean docker trash generated more than five days ago
    docker system prune -f --filter until=120h
}

docker-image-arch() {
    # Get the architecture of a docker image
    DOCKER_IMAGE=$1
    docker inspect "${DOCKER_IMAGE}" | jq ".[0].Architecture"
}

dit() {
    local image="${1:-alpine}"
    local cmd="${2:-sh}"
    docker run -it --rm \
        -v "${PWD}":/project \
        --env-file=.env \
        --workdir /project \
        "${image}" "${cmd}"
}

dit-aws() {
    local image="${1:-alpine}"
    local cmd="${2:-sh}"
    docker run -it --rm -v "${PWD}":/project \
        --env-file=.env \
        -v "${HOME}/.aws/credentials":/root/.aws/credentials:ro \
        -v "${HOME}/.aws/config":/root/.aws/config:ro \
        --workdir /project \
        "${image}" "${cmd}"
}

docker-watch() {
    watch 'docker ps --format "table {{.ID}}\t{{.Names}}\t{{.RunningFor}}"'
}
