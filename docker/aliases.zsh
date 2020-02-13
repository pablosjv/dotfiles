#!/bin/sh
function docker-prune {
	docker system prune --volumes -fa
}

function docker-clean {
  docker rmi $(docker images -q -f dangling=true)
}
