#!/bin/bash

rgruntime=$(cat terraform/output.json| jq --raw-output '.rg_runtime.value')

if [ -z $rgruntime ]; then
    echo "Could not find rgruntime. Stopping!"
    exit 1
fi

az aks get-credentials -g $rgruntime -n renovate-talk-k8s --admin

kubectl apply -k k8s/aad-pod-identity # first attempt will fail due to missing crds
kubectl apply -k k8s/aad-pod-identity

kubectl apply -k k8s/external-secrets-operator # first attempt will fail due to missing crds
kubectl wait deployment -n external-secrets external-secrets-webhook --for condition=Available=True --timeout=120s
kubectl apply -k k8s/external-secrets-operator

kubectl apply -k k8s/argocd # first attempt will fail due to missing crds
kubectl apply -k k8s/argocd