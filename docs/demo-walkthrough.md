# Prepare
1. Delete repo
    1. pietervincken/renovate-talk-java-demo-app
1. Recreate repo
    1. renovate-talk-java-demo-app
    1. Don’t set up any files!
1. Push main
    1. `git push -u origin main`
1. Push tags
    1. `git push --tags`
1. Setup webhook
    1. https://tekline.renovate-talk.pietervincken.com
    1. application/json

# Run
1. Go to https://demo-java-app.renovate-talk.pietervincken.com/info
    1. Simple Java (Spring Boot) application
    1. Runs on Azure Kubernetes Service
    1. Version x.x.x
1. Go to app repo PRs
    1. Show list of PRs (empty)
    1. https://github.com/pietervincken/renovate-talk-java-demo-app/pulls
1. Go to k9s
    1. Trigger renovate
1. Go to Github, app repo
    1. https://github.com/pietervincken/renovate-talk-java-demo-app
    1. Show pom.xml
    1. https://github.com/pietervincken/renovate-talk-java-demo-app/blob/main/pom.xml
    1. Show Dockerfile
    1. https://github.com/pietervincken/renovate-talk-java-demo-app/blob/main/Dockerfile
1. Go to Github
    1. Show list of PRs (2)
    1. https://github.com/pietervincken/renovate-talk-java-demo-app/pulls
1. Pick a PR
    1. Merge the PR
1. Show build in Tekton
    1. https://tekton.renovate-talk.pietervincken.com/#/namespaces/tekline-renovate-talk-java-demo-app-main/pipelineruns 
    1. When finished, show new tag (github + docker build)
1. Show deploy repo empty PR list
    1. https://github.com/pietervincken/renovate-talk-java-demo-app-deploy/pulls
1. Go to k9s 
    1. Trigger renovate
1. Go to Github, deploy repo
    1. Show kustomize setup 
    1. https://github.com/pietervincken/renovate-talk-java-demo-app-deploy/blob/main/kustomize/kustomization.yaml
    1. https://github.com/pietervincken/renovate-talk-java-demo-app-deploy/blob/main/kustomize/resources/deployment.yaml
1. Show deploy repo PR list
    1. https://github.com/pietervincken/renovate-talk-java-demo-app-deploy/pulls
    1. Explain that update has been detected
1. Merge PR 
1. Navigate to ArgoCD to see rollout
    1. https://argocd.renovate-talk.pietervincken.com/applications/demo-java-app?resource=
1. Go to App UI 
    1. Show new version number
    1. https://demo-java-app.renovate-talk.pietervincken.com/info