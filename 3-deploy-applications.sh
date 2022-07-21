#!/bin/bash

SLEEP=1

az aks get-credentials -g $rgruntime -n renovate-talk-k8s --admin

kubectl apply -k k8s/aad-pod-identity # first attempt will fail due to missing crds
sleep $SLEEP
kubectl apply -k k8s/aad-pod-identity

kubectl apply -k k8s/external-secrets-operator # first attempt will fail due to missing crds
sleep $SLEEP
kubectl apply -k k8s/external-secrets-operator

# kubectl apply -k k8s/tekton
