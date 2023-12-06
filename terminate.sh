#!/bin/bash

instance_id=$(terraform output -json | jq -r '.instance_id.value')
aws ec2 terminate-instances --instance-ids $instance_id
aws ec2 wait instance-terminated --instance-ids $instance_id
