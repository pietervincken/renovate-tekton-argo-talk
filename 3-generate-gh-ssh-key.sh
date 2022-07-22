#!/bin/bash

set -e pipefail

keyvault=$(cat terraform/output.json| jq --raw-output '.keyvault.value')

if [ -z $keyvault ]; then
    echo "Could not find keyvault. Stopping!"
    exit 1
fi


if [ -z $githubmail ]; then
    echo "Could not find githubmail. Stopping!"
    exit 1
fi


tempdir=$(mktemp -d)

ssh-keygen -t ed25519 -C $githubmail -f $tempdir/gh-key -q -N ""
ssh-keyscan -t rsa github.com > $tempdir/known_hosts 2> /dev/null

az keyvault secret set -f $tempdir/gh-key -n github-private-key --vault-name $keyvault > /dev/null
az keyvault secret set -f $tempdir/gh-key.pub -n github-public-key --vault-name $keyvault > /dev/null
az keyvault secret set -f $tempdir/known_hosts -n github-known-hosts --vault-name $keyvault > /dev/null