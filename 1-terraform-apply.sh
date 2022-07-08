#!/bin/bash
set -e

cd terraform
terraform init -backend-config=config.azurerm.tfbackend
terraform apply
cd ..