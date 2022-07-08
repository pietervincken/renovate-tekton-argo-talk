#!/bin/bash

az aks get-credentials -g $rgruntime -n renovate-talk-k8s --admin

kubectl apply -k k8s/external-secrets-operator # first attempt will fail due to missing crds
kubectl apply -k k8s/external-secrets-operator

# kubectl apply -k k8s/tekton
