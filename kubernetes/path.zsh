#!/bin/zsh
export PATH="$HOME/.krew/bin:$PATH"

export KUBEHOME=~/.kube

KUBECONFIG=

setopt +o nomatch
for filename in ${KUBEHOME}/config/*.yml; do
    KUBECONFIG=${KUBECONFIG}:${filename}
done
