#!/bin/bash

set -e pipefail

cd k8s/aad-pod-identity
rm -rf resources/render resources/crds
mkdir -p resources/render resources/crds 
helm repo add aad-pod-identity https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts

helm template aad-pod-identity \
    aad-pod-identity/aad-pod-identity \
    -n aad-pod-identity \
    --create-namespace \
    | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -

curl -s https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts/aad-pod-identity/crds/crd.yaml | yq -s '"resources/crds/" + .metadata.name + ".yml"' -
cd resources/render
kustomize create app --recursive --autodetect
cd ../crds
kustomize create app --recursive --autodetect
cd ../../../..
echo "Upgraded aad-pod-identity"

cd k8s/external-secrets-operator
rm -rf resources/render/
mkdir -p resources/render
helm repo add external-secrets https://charts.external-secrets.io
helm template external-secrets \
   external-secrets/external-secrets \
    -n external-secrets \
    --create-namespace \
    --set installCRDs=true | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
cd resources/render
kustomize create app --recursive --autodetect
cd ../../../..
echo "Upgraded external-secrets-operator"

cd k8s/argocd
rm -rf resources/render/
mkdir -p resources/render
kubectl create ns argocd -o yaml --dry-run=client > resources/render/ns.yaml
curl -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
cd resources/render/
kustomize create app --recursive --autodetect
cd ../../../..

echo "Upgraded argocd"

cd k8s/tekton
rm -rf resources/render/
mkdir -p resources/render
curl -s https://storage.googleapis.com/tekton-releases/operator/latest/release.yaml | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
curl -s https://raw.githubusercontent.com/tektoncd/operator/main/config/crs/kubernetes/config/all/operator_v1alpha1_config_cr.yaml | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
rm .yml
cd resources/render/
kustomize create app --recursive --autodetect
cd ../../../..

echo "Upgraded tekton"