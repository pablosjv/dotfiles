#!/usr/bin/env bash

# TODO: List based on arguments
aws-ec2-list () {
    aws ec2 describe-instances --query 'Reservations[*].Instances[*].[$@]' --filters Name=instance-state-name,Values=running --output table
}

aws-pip-login (){
    aws codeartifact login --tool pip --domain "${1}" --repository "${2:-python}"
}
