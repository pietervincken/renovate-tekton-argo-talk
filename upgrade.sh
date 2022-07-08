#!/bin/bash


cd k8s/external-secrets-operator
rm -rf kustomization.yaml resources/render/
mkdir -p resources/render
helm repo add external-secrets https://charts.external-secrets.io
helm template external-secrets \
   external-secrets/external-secrets \
    -n external-secrets \
    --create-namespace \
    --set installCRDs=true | yq -s '"resources/render/" + .metadata.name + ".yml"' -
kustomize create app --recursive --autodetect
cd ../..
echo "Upgraded external-secrets-operator"

cd k8s/argocd
rm -rf kustomization.yaml resources/render/
mkdir -p resources/render
kubectl create ns argocd -o yaml --dry-run=client > resources/render/ns.yaml
curl -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml | yq -s '"resources/render/" + .metadata.name + ".yml"' -
kustomize create app --recursive --autodetect
cd ../..

echo "Upgraded argocd"

cd k8s/tekton
rm -rf kustomization.yaml resources/render/
mkdir -p resources/render
curl -s https://storage.googleapis.com/tekton-releases/operator/latest/release.yaml | yq -s '"resources/render/" + .metadata.name + ".yml"' -
curl -s https://raw.githubusercontent.com/tektoncd/operator/main/config/crs/kubernetes/config/all/operator_v1alpha1_config_cr.yaml | yq -s '"resources/render/" + .metadata.name + ".yml"' -
kustomize create app --recursive --autodetect
cd ../..

echo "Upgraded tekton"