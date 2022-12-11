#!/usr/bin/env bash

function last-py() {
    package_name=${1:-"pandas"}
    echo "Listing last version for ${package_name}"
    echo
    curl -Ls "https://pypi.org/pypi/${package_name}/json" | jq -r '.releases | keys | reverse[:5]'
}
