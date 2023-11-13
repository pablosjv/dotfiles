#!/usr/bin/env bash

git-reset (){
    git reset --soft HEAD~"${1}"
}
