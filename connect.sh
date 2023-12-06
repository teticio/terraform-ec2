#!/bin/bash

ssh ubuntu@$(terraform output -json | jq -r '.public_ip.value')
