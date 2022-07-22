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


edClientId=$(cat terraform/output.json| jq --raw-output '.external_dns_client_id.value')
edResourceId=$(cat terraform/output.json| jq --raw-output '.external_dns_resource_id.value')

if [ -z $edClientId ]; then
    echo "Could not find edClientId. Stopping!"
    exit 1
fi

if [ -z $edResourceId ]; then
    echo "Could not find edResourceId. Stopping!"
    exit 1
fi

yq -i ".spec.resourceID |= \"$edResourceId\"" k8s/external-dns/resources/azureidentity.yaml 
yq -i ".spec.clientID |= \"$edClientId\"" k8s/external-dns/resources/azureidentity.yaml 

if [ -z $subscription ]; then
    echo "Could not find subscription. Stopping!"
    exit 1
fi

if [ -z $tenant ]; then
    echo "Could not find tenant. Stopping!"
    exit 1
fi

cat <<EOF > k8s/external-dns/secrets/azure.json
{
    "tenantId": "$tenant",
    "subscriptionId": "$subscription",
    "resourceGroup": "rg-renovate-talk",
    "useManagedIdentityExtension": true,
    "userAssignedIdentityID": "$edClientId"
}
EOF

domain=$(cat terraform/output.json| jq --raw-output '.domain.value')

if [ -z $domain ]; then
    echo "Could not find domain. Stopping!"
    exit 1
fi

yq -i ".[0].value.[\"external-dns.alpha.kubernetes.io/hostname\"] |= \"*.$domain\"" k8s/traefik/patches/service.yaml 

