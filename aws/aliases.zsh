#!/bin/sh

alias aws-ec2-running="aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,InstanceType]' --filters Name=instance-state-name,Values=running --output table"

# TODO: List based on arguments
# aws-ec2-list () {
#     aws ec2 describe-instances --query 'Reservations[*].Instances[*].[$@]' --filters Name=instance-state-name,Values=running --output table
# }

alias aws-ec2-running-count="aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --filters Name=instance-state-name,Values=running --output text | wc -l"
