#!/bin/sh
function docker-prune() {
    # Remove all docker data not used by a running container
    docker system prune --volumes -fa
}

function docker-clean() {
    # Clean docker trash generated more than five days ago
    echo "Old Containers\t=> $(docker container prune -f --filter until=120h)"
    echo "Old Networks\t=> $(docker network prune -f)"
    echo "Dangling images\t=> $(docker image prune -f)"
    docker rmi -f $(docker images -f "dangling=true" -q) 2>/dev/null
    echo "Unused volumes\t=> $(docker volume prune -f)"
}

function dit() {
    local cmd="${2:-bash}"
    docker run -it --rm $1 $cmd
}

alias docker-it="docker run -it --rm"

function docker-watch() {
    watch 'docker ps --format "table {{.ID}}\t{{.Names}}\t{{.RunningFor}}"'
}
