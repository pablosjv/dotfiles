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
    local image="${1:-alpine}"
    local cmd="${2:-sh}"
    docker run -it --rm -v ${PWD}:/project --workdir /project $image $cmd
}

function docker-watch() {
    watch 'docker ps --format "table {{.ID}}\t{{.Names}}\t{{.RunningFor}}"'
}

alias doco='docker-compose'

corun() {
    case "$1" in
    start)
        colima start \
            --cpu ${COLIMA_CPU} \
            --memory ${COLIMA_MEMORY} \
            --disk ${COLIMA_DISK} \
            --mount $HOME/projects:w \
            --mount $HOME/.docker:w
        ;;
    status)
        colima status
        ;;
    stop)
        colima stop
        ;;
    delete)
        colima delete
        ;;
    help)
        echo "Container runtime helper script. Currently using colima under the hood."
        echo ""
        echo "Usage:
corun [command]

Available Commands:
start     start the runtime image.
stop      stop the runtime image.
status    show the status of the runtime image.
delete    delete and teardown runtime image. It's like a fresh start.
help      Help about any command.
"
        ;;
    *)
        echo "\033[0;31mUnrecognized subcommad\033[0m"
        echo ""
        corun help
        ;;
    esac
}
