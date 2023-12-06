#!/bin/bash

if [ $# -eq 0 ]; then
    terraform apply -auto-approve
else
    terraform apply -auto-approve -var "instance_type=$1"
fi
