#!/bin/bash
set -e;

temp=$(mktemp -d)

cd $temp

git clone https://github.com/pietervincken/renovate-talk-java-demo-app.git
cd renovate-talk-java-demo-app
latest_tag=$(git tag | sort -V | tail -1 | sed 's|v||') # remove v from tag name!
echo "Using tag $latest_tag"

docker build --build-arg=APP_VERSION=$latest_tag -t renovatetalkacr.azurecr.io/renovate-talk-java-demo-app:$latest_tag .
az acr login -n renovatetalkacr

docker push renovatetalkacr.azurecr.io/renovate-talk-java-demo-app:$latest_tag