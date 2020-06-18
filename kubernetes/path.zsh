#!/bin/sh
export PATH="$HOME/.krew/bin:$PATH"

export KUBEHOME=~/.kube

KUBECONFIG=

for filename in ${KUBEHOME}/config/*.yml; do
    KUBECONFIG=${KUBECONFIG}:${filename}
done
