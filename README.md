# renovate-tekton-argo-talk

Disclaimer: this repository is for demo purposes only.
The setup is **NOT** production ready. 
**USE AT YOUR OWN RISK.**

## Setup Github PAT

Generate a PAT as described [here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) and [here](https://docs.renovatebot.com/modules/platform/github/). 


## Example .env file

```bash
export location="westeurope" #changeme if desired
export rgstate="rg-renovate-talk-state" #changeme if desired
export sastate="sarenovatetalkstate" #changeme as this needs to be globally unique ;) Be creative!
export subscription="xxxx1234-1234-1234-1234-xxxxxx123456" #changeme to your own subscription
export ARM_TENANT_ID="" # add your tenant id here. Required for setting up rights to k8s
```


## TODO

- Setup AAD pod identity / workload identity for external secrets operator
- Create secrets template for Renovate secrets (Github access)
- Create secrets template for ArgoCD secrets (Github access)
- Create secrets template for Tekton secrets (Github access)
- Setup ingress controller
- Create webhook ingress for Tekton
- Setup repositories for Demo applications. 
- Configure Renovate
- Configure ArgoCD
- Configure Tekton
- Create Github secret in TF