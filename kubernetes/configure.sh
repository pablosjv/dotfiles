#!/bin/sh

export KUBEHOME=~/.kube

mkdir -p ${KUBEHOME}/completions
mkdir -p ${KUBEHOME}/configs/

kubectl completion zsh > ${KUBEHOME}/completions/_kubectl
