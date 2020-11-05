#!/bin/zsh
export PATH="$HOME/.krew/bin:$PATH"

export KUBEHOME=~/.kube

function kubeconfig() {
    unset KUBECONFIG
    setopt +o nomatch
    for filename in ${KUBEHOME}/configs/*.yml; do
        if [[ -z "${KUBECONFIG}" ]]; then
            export KUBECONFIG=${filename}
        else
            export KUBECONFIG=${filename}:${KUBECONFIG}
        fi
    done
    # NOTE: Automatically generated config for docker kubernetes
    KUBECONFIG=${KUBECONFIG}:${KUBEHOME}/config
}

kubeconfig
