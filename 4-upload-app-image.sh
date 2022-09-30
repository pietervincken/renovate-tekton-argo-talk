#!/bin/bash


temp=$(mktemp -d)

cd $temp

git clone https://github.com/pietervincken/renovate-talk-java-demo-app.git
cd renovate-talk-java-demo-app
latest_tag=$(git tag | sort -V | tail -1 | sed 's|v||') # remove v from tag name!
echo "Using tag $latest_tag"

az acr import --name renovatetalkacr --source docker.io/pietervincken/renovate-talk-java-demo-app:base --image renovate-talk-java-demo-app:$latest_tag