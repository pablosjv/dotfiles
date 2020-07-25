#!/bin/zsh
export PATH="$HOME/.krew/bin:$PATH"

export KUBEHOME=~/.kube

unset KUBECONFIG

setopt +o nomatch
for filename in ${KUBEHOME}/configs/*.yml; do
    if [[ -z "${KUBECONFIG}" ]]; then
        export KUBECONFIG=${filename}
    else
        export KUBECONFIG=${filename}:${KUBECONFIG}
    fi
done
