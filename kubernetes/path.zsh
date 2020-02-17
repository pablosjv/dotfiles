#!/bin/sh
export PATH="$HOME/.krew/bin:$PATH"

export KUBEHOME=~/.kube
export KUBECONFIG=${KUBEHOME}/config/dev.yml:${KUBEHOME}/config/pre.yml:${KUBEHOME}/config/prod.yml:${KUBEHOME}/config/mgmt.yml
