#!/usr/bin/env bash

docker-prune() {
    # Remove all docker data not used by a running container
    docker system prune --volumes -fa
}

docker-clean() {
    # Clean docker trash generated more than five days ago
    echo -e "Old Containers\t=> $(docker container prune -f --filter until=120h)"
    echo -e "Old Networks\t=> $(docker network prune -f)"
    echo -e "Dangling images\t=> $(docker image prune -f)"
    docker rmi -f '$(docker images -f "dangling=true" -q)' 2>/dev/null
    echo -e "Unused volumes\t=> $(docker volume prune -f)"
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
