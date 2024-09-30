#!/usr/bin/env sh

alias kx='kubectx'
alias kn='kubens'

alias k='kubectl'
alias sk='kubectl -n kube-system'
alias ke='EDITOR=vim kubectl edit'
alias klbaddr="kubectl get svc -ojsonpath='{.status.loadBalancer.ingress[0].hostname}'"

alias kdebug='kubectl run -i -t debug --rm --image=alpine:latest --restart=Never'
alias knrunning='kubectl get pods --field-selector=status.phase!=Running'
alias kfails='kubectl get pods --field-selector="status.phase!=Succeeded,status.phase!=Running" -o custom-columns="POD:metadata.name,PHASE:status.phase,STATE:status.containerStatuses[*].state.waiting.reason"'
alias kimg="kubectl get deployment --output=jsonpath='{.spec.template.spec.containers[*].image}'"
alias kvs="k get secret -o jsonpath-as-json='{.data}'"
alias kpp="kubectl get pod -o jsonpath='{.spec.containers[*].ports}'"
alias ksp="kubectl get service -o jsonpath='{.spec.ports[*].ports}'"
