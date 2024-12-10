#!/usr/bin/env bash

function last-py() {
    package_name=${1}
    n_versions=${2:-5}
    echo "Last ${n_versions} versions of ${package_name} <https://pypi.org/project/${package_name}/>"
    echo
    curl -Ls "https://pypi.org/pypi/${package_name}/json" |
        jq -r '
            .releases |
            to_entries |
            map(.key as $version |
            .value[] |
            {version: $version, upload_time: .upload_time_iso_8601}) |
            sort_by(.upload_time) |
            group_by(.version) |
            map(max_by(.upload_time)) |
            reverse |
            .[:'$n_versions'] |
            map([.version, .upload_time]) |
            (["Version", "Upload Time"] | (., map(length*"-"))), .[] | @tsv
        ' |
        column -t -s $'\t'
}
