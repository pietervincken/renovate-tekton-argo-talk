#!/bin/bash

echo "Make sure to update to latest tag! Using 1.4.4 now."

az acr login -n renovatetalkacr
docker pull pietervincken/renovate-talk-java-demo-app:base
docker tag pietervincken/renovate-talk-java-demo-app:base renovatetalkacr.azurecr.io/renovate-talk-java-demo-app:1.4.4
docker push renovatetalkacr.azurecr.io/renovate-talk-java-demo-app:1.4.4