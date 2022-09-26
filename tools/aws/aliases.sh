#!/usr/bin/env sh

alias aws-ec2-running="aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,InstanceType]' --filters Name=instance-state-name,Values=running --output table"
alias aws-ec2-running-count="aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --filters Name=instance-state-name,Values=running --output text | wc -l"


alias s3="aws s3"
alias ec2="aws ec2"
alias emr="aws emr"

alias sm-train-logs="aws logs tail /aws/sagemaker/TrainingJobs --since 5m --follow --log-stream-name-prefix"
