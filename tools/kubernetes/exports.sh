#!/usr/bin/env sh

export KUBEHOME=~/.kube

kubeconfig() {
    unset KUBECONFIG
    setopt +o nomatch
    for filename in "${KUBEHOME}"/configs/*.yml; do
        if [ -z "${KUBECONFIG}" ]; then
            export KUBECONFIG="${filename}"
        else
            export KUBECONFIG="${filename}:${KUBECONFIG}"
        fi
    done
    # NOTE: Automatically generated config for docker kubernetes
    KUBECONFIG=${KUBECONFIG}:${KUBEHOME}/config
}

kubeconfig
