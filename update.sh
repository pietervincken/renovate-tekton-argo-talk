#!/bin/bash

set -e pipefail

tempdir=$(mktemp -d)

### Helper
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases" |                 # Get latest release from GitHub api
  jq --raw-output 'map(select(.tag_name |  test("^v.*"))) | map(select(.prerelease | not)) | map(select(.tag_name | test(".*beta.*")|not)) | map(select(.tag_name | test(".*alpha.*")|not)) | map(select(.tag_name | test(".*rc.*")|not)) | first | .tag_name'  # get the tag from tag_name
}

# helm repo add traefik https://helm.traefik.io/traefik
# helm repo add external-secrets https://charts.external-secrets.io
# helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

argoCDVersion=$(get_latest_release "argoproj/argo-cd")
cd k8s/argocd
rm -rf resources/render/
mkdir -p resources/render
kubectl create ns argocd -o yaml --dry-run=client > resources/render/ns.yaml
curl -s https://raw.githubusercontent.com/argoproj/argo-cd/$argoCDVersion/manifests/install.yaml | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
cd resources/render/
kustomize create app --recursive --autodetect
cd ../../../..
echo "Upgraded argocd to $argoCDVersion"

cd k8s/tekton
rm -rf resources/render/
mkdir -p resources/render
curl -s https://storage.googleapis.com/tekton-releases/operator/latest/release.yaml | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
curl -s https://raw.githubusercontent.com/tektoncd/operator/main/config/crs/kubernetes/config/all/operator_v1alpha1_config_cr.yaml | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
rm .yml
cd resources/render/
kustomize create app --recursive --autodetect
kustomize edit set namespace tekton-operator
cd ../../../..
echo "Upgraded tekton"

certManagerVersion=$(get_latest_release "cert-manager/cert-manager")
cd k8s/certmanager
rm -rf resources/render/
mkdir -p resources/render
curl -sL https://github.com/cert-manager/cert-manager/releases/download/$certManagerVersion/cert-manager.yaml | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
cd resources/render/
kustomize create app --recursive --autodetect
cd ../../../..
echo "Upgraded certmanager to $certManagerVersion"

cd k8s/traefik
rm -rf resources/render/
mkdir -p resources/render
helm template traefik traefik/traefik \
  -n traefik \
  --set globalArguments= \
  --set providers.kubernetesIngress.publishedService.enabled=true \
  | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
curl -sL https://raw.githubusercontent.com/traefik/traefik/master/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml  | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
curl -sL https://raw.githubusercontent.com/traefik/traefik/master/docs/content/reference/dynamic-configuration/kubernetes-crd-rbac.yml | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
cd resources/render/
kustomize create app --recursive --autodetect
cd ../../../..
echo "Upgraded traefik"

mkdir -p k8s/prometheus-operator || true
cd k8s/prometheus-operator
rm -rf resources/render/ || true
mkdir -p resources/render
prometheusOperator=$(get_latest_release "prometheus-operator/prometheus-operator")
# curl -sL https://github.com/prometheus-operator/prometheus-operator/releases/download/${prometheusOperator}/bundle.yaml \
  # | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
git clone -q --depth=1 https://github.com/prometheus-operator/prometheus-operator.git --branch $prometheusOperator $tempdir/prometheus-operator 2> /dev/null
cp $tempdir/prometheus-operator/example/prometheus-operator-crd/* resources/render
cp $tempdir/prometheus-operator/example/rbac/prometheus-operator/prometheus-operator-deployment.yaml resources/render
cp $tempdir/prometheus-operator/example/rbac/prometheus-operator/prometheus-operator-service.yaml resources/render
cp $tempdir/prometheus-operator/example/rbac/prometheus-operator/prometheus-operator-service-account.yaml resources/render
cp $tempdir/prometheus-operator/example/rbac/prometheus-operator/prometheus-operator-service-monitor.yaml resources/render
cp $tempdir/prometheus-operator/example/rbac/prometheus-operator/prometheus-operator-cluster-role.yaml resources/render
cp $tempdir/prometheus-operator/example/rbac/prometheus-operator/prometheus-operator-cluster-role-binding.yaml resources/render
cp $tempdir/prometheus-operator/example/rbac/prometheus-operator-crd/prometheus-operator-crd-cluster-roles.yaml resources/render
cd resources/render
kustomize create app --recursive --autodetect
cd ../../../..
echo "Upgraded prometheus-operator to $prometheusOperator"

mkdir -p k8s/monitoring || true
cd k8s/monitoring
rm -rf resources/render/ || true
mkdir -p resources/render
kubePrometheus=$(get_latest_release "prometheus-operator/kube-prometheus")
git clone -q --depth=1 https://github.com/prometheus-operator/kube-prometheus.git --branch $kubePrometheus $tempdir/kube-prometheus 2> /dev/null
mkdir -p resources/render/kube-state-metrics/ || true
mkdir -p resources/render/blackbox-exporter/ || true
mkdir -p resources/render/kubernetes/ || true
mkdir -p resources/render/node-exporter/ || true
mkdir -p resources/render/prometheus/ || true
mkdir -p resources/render/alertmanager/ || true
cp $tempdir/kube-prometheus/manifests/kubeStateMetrics-* resources/render/kube-state-metrics/
cp $tempdir/kube-prometheus/manifests/blackboxExporter-* resources/render/blackbox-exporter/
cp $tempdir/kube-prometheus/manifests/kubernetes* resources/render/kubernetes/
cp $tempdir/kube-prometheus/manifests/nodeExporter-* resources/render/node-exporter/
cp $tempdir/kube-prometheus/manifests/alertmanager-* resources/render/alertmanager/

# needed to be selective to take all namespaces easily
cp $tempdir/kube-prometheus/manifests/prometheus-* resources/render/prometheus/
cp $tempdir/prometheus-operator/example/rbac/prometheus/prometheus-cluster-role-binding.yaml resources/render/prometheus/prometheus-clusterRoleBinding.yaml
cp $tempdir/prometheus-operator/example/rbac/prometheus/prometheus-cluster-role.yaml resources/render/prometheus/prometheus-clusterRole.yaml
rm resources/render/prometheus/prometheus-*SpecificNamespaces.yaml

cd resources/render
kustomize create app --recursive --autodetect
cd ../../../..
echo "Upgraded kube-prometheus to $kubePrometheus"

mkdir -p k8s/grafana-operator || true
rm -rf resources/render/ || true
mkdir -p resources/render
cd k8s/grafana-operator
rm -rf resources/render/
mkdir -p resources/render
helm template grafana-operator \
  bitnami/grafana-operator \
  -n grafana-operator \
  --set namespaceOverride=grafana-operator \
  --set operator.prometheus.serviceMonitor.enabled=true \
  --set grafana.enabled=false | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
cd resources/render
kustomize create app --recursive --autodetect
cd ../../../..
echo "Upgraded grafana-operator"

mkdir -p k8s/dashboarding || true
cd k8s/dashboarding
rm -rf resources/render/
mkdir -p resources/render
helm template grafana-operator \
  bitnami/grafana-operator \
  -n grafana-operator \
  --set namespaceOverride=grafana \
  --set operator.enabled=false \
  --set grafana.enabled=true | yq -s '"resources/render/" + .metadata.name + "-" + .kind + ".yml"' -
cd resources/render
kustomize create app --recursive --autodetect
cd ../../../..
echo "Upgraded dashboarding"

# # Cleanup
rm -rf $tempdir