#!/bin/bash
set -e

cd terraform
terraform init -backend-config=config.azurerm.tfbackend
terraform apply
terraform output -json > output.json
cd ..