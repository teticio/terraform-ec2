#!/bin/bash

if [ $# -eq 0 ]; then
    echo "./create.sh <instance_type>"
    exit 1
fi
terraform apply -auto-approve -var "instance_type=$1"
