#!/bin/bash

az aks get-credentials -g $rgruntime -n renovate-talk-k8s --admin



kubectl apply -k k8s/aad-pod-identity # first attempt will fail due to missing crds
kubectl apply -k k8s/aad-pod-identity

kubectl apply -k k8s/external-secrets-operator # first attempt will fail due to missing crds
kubectl wait deployment -n external-secrets external-secrets-webhook --for condition=Available=True --timeout=120s
kubectl apply -k k8s/external-secrets-operator


kubectl apply -k k8s/tekton # first attempt will fail due to missing crds
# kubectl wait deployment -n external-secrets external-secrets-webhook --for condition=Available=True --timeout=120s
kubectl apply -k k8s/tekton
# kubectl apply -k k8s/tekton
