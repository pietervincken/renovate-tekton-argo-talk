# renovate-tekton-argo-talk

Disclaimer: this repository is for demo purposes only.
The setup is **NOT** production ready. 
**USE AT YOUR OWN RISK.**

## Manual actions required

### Setup Github PAT

Generate a PAT as described [here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) and [here](https://docs.renovatebot.com/modules/platform/github/).

### Setup DNS zone NS records for subdomain

After the Terraform run, go to the portal, copy out the NS records for the DNS zone and add these to your domain registrar.

### Setup webhooks for repositories

- Use the tekline webhook configuration (Default `https://your.sub.domain/tekline`) and add this to your repositories.
- Use the argocd configuration (Default `https://your.sub.domain/argocd`) and add this to your repositories.

### Add public part of SSH key to Github Account

- https://docs.github.com/articles/generating-an-ssh-key/

## Example .env file

```bash
export location="westeurope" #changeme if desired
export rgstate="rg-renovate-talk-state" #changeme if desired
export sastate="sarenovatetalkstate" #changeme as this needs to be globally unique ;) Be creative!
export subscription="xxxx1234-1234-1234-1234-xxxxxx123456" #changeme to your own subscription
export tenant="" # add your tenant id here. Required for setting up rights to k8s
export ARM_TENANT_ID=$tenant # needed in both formats
export githubpat="ghp_xxx" # GitHub PAT token. Needs write access to read and update your github repos.
export githubmail="xxx" # public email of github account. (github email, not private email). Used for SSH key generation
export githubtrigger="xxx" # Token used to validate push webhooks from Github. 
```

## TODO

- Split into multiple application repositories
- (Optional) Deploy Prometheus/Thanos

- Add NodeJS app as demo app. 
- Setup SSH key for Tekline remote pipeline tasks