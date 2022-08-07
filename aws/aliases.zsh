#!/bin/sh

alias aws-ec2-running="aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,InstanceType]' --filters Name=instance-state-name,Values=running --output table"
alias aws-ec2-running-count="aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --filters Name=instance-state-name,Values=running --output text | wc -l"

# TODO: List based on arguments
# aws-ec2-list () {
#     aws ec2 describe-instances --query 'Reservations[*].Instances[*].[$@]' --filters Name=instance-state-name,Values=running --output table
# }

alias s3="aws s3"
alias ec2="aws ec2"
alias emr="aws emr"
alias sm-train-logs="aws logs tail /aws/sagemaker/TrainingJobs --since 5m --follow --log-stream-name-prefix"

aws-pip-login (){
    aws codeartifact login --tool pip --domain ${1} --repository ${2:-python}
}
