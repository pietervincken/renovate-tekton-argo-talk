#!/bin/bash

set -e pipefail

userAssignedMSIClientID=$(cat terraform/output.json| jq --raw-output '.external_secrets_client_id.value')
nodeRG=$(cat terraform/output.json| jq --raw-output '.aks_node_rg.value')

if [ -z $userAssignedMSIClientID ]; then
    echo "Could not find userAssignedMSIClientID. Stopping!"
    exit 1
fi

if [ -z $nodeRG ]; then
    echo "Could not find nodeRG. Stopping!"
    exit 1
fi

if [ -z $subscription ]; then
    echo "Could not find subscription. Stopping!"
    exit 1
fi

if [ -z $tenant ]; then
    echo "Could not find tenant. Stopping!"
    exit 1
fi

cd k8s/aad-pod-identity
rm -rf kustomization.yaml resources/render/
mkdir -p resources/render
helm repo add aad-pod-identity https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts

touch values.yaml
 yq -i '.adminsecret.cloud |= "AzurePublicCloud"' values.yaml
 yq -i ".adminsecret.subscriptionID |= \"${subscription}\"" values.yaml
 yq -i ".adminsecret.resourceGroup |= \"${nodeRG}\"" values.yaml
 yq -i ".adminsecret.vmType |= \"vmss\"" values.yaml
 yq -i ".adminsecret.tenantID |= \"${tenant}\"" values.yaml
 yq -i ".adminsecret.clientID |= \"msi\"" values.yaml
 yq -i ".adminsecret.clientSecret |= \"msi\"" values.yaml
 yq -i ".adminsecret.useMSI |= \"true\"" values.yaml
 yq -i ".adminsecret.userAssignedMSIClientID |= \"${userAssignedMSIClientID}\"" values.yaml
 yq -i ".forceNamespaced |= true" values.yaml

helm template aad-pod-identity \
    aad-pod-identity/aad-pod-identity \
    -n aad-pod-identity \
    --create-namespace \
    -f values.yaml \
    | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -

rm values.yaml

curl -s https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts/aad-pod-identity/crds/crd.yaml | yq -s '"resources/crds/" + .metadata.name + ".yml"' -
kustomize create app --recursive --autodetect
cd ../..
echo "Upgraded aad-pod-identity"

cd k8s/external-secrets-operator
rm -rf kustomization.yaml resources/render/
mkdir -p resources/render
helm repo add external-secrets https://charts.external-secrets.io
helm template external-secrets \
   external-secrets/external-secrets \
    -n external-secrets \
    --create-namespace \
    --set installCRDs=true | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
kustomize create app --recursive --autodetect
cd ../..
echo "Upgraded external-secrets-operator"

cd k8s/argocd
rm -rf kustomization.yaml resources/render/
mkdir -p resources/render
kubectl create ns argocd -o yaml --dry-run=client > resources/render/ns.yaml
curl -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
kustomize create app --recursive --autodetect
cd ../..

echo "Upgraded argocd"

cd k8s/tekton
rm -rf kustomization.yaml resources/render/
mkdir -p resources/render
curl -s https://storage.googleapis.com/tekton-releases/operator/latest/release.yaml | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
curl -s https://raw.githubusercontent.com/tektoncd/operator/main/config/crs/kubernetes/config/all/operator_v1alpha1_config_cr.yaml | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
rm .yml
kustomize create app --recursive --autodetect
cd ../..

echo "Upgraded tekton"