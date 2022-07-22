#!/bin/bash

if [ -z $rgruntime ]; then
    echo "Could not find rgruntime. Stopping!"
    exit 1
fi

az aks get-credentials -g $rgruntime -n renovate-talk-k8s --admin

# kubectl apply -k k8s/aad-pod-identity # first attempt will fail due to missing crds
# kubectl apply -k k8s/aad-pod-identity

# kubectl apply -k k8s/external-secrets-operator # first attempt will fail due to missing crds
# kubectl wait deployment -n external-secrets external-secrets-webhook --for condition=Available=True --timeout=120s
# kubectl apply -k k8s/external-secrets-operator

kubectl apply -k k8s/tekton # first attempt will fail due to missing crds
kubectl apply -k k8s/tekton

# kubectl apply -k k8s/external-dns # first attempt will fail due to missing crds
# kubectl apply -k k8s/external-dns

# kubectl apply -k k8s/traefik # first attempt will fail due to missing crds
# kubectl apply -k k8s/traefik


# kubectl apply -k k8s/certmanager # first attempt will fail due to missing crds
# kubectl wait deployment -n cert-manager cert-manager-webhook --for condition=Available=True --timeout=120s
# kubectl apply -k k8s/certmanager

kubectl apply -k k8s/tekline