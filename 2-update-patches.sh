#!/bin/bash

set -e pipefail

esClientId=$(cat terraform/output.json| jq --raw-output '.external_secrets_client_id.value')
esResourceId=$(cat terraform/output.json| jq --raw-output '.external_secrets_resource_id.value')

if [ -z $esClientId ]; then
    echo "Could not find esClientId. Stopping!"
    exit 1
fi

if [ -z $esResourceId ]; then
    echo "Could not find esResourceId. Stopping!"
    exit 1
fi

yq -i ".spec.resourceID |= \"$esResourceId\"" k8s/external-secrets-operator/resources/azureidentity.yaml 
yq -i ".spec.clientID |= \"$esClientId\"" k8s/external-secrets-operator/resources/azureidentity.yaml 
