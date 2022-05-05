#!/bin/sh
set -o errexit

kind delete cluster || true

echo "==> Creating a cluster"
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
EOF

kubectl get pods -n openfaas

echo  "==> Creating cluster policies"
kubectl create clusterrolebinding cluster-system-anonymous --clusterrole=cluster-admin --user=system:anonymous

echo  "==> Creating cluster policies"
kubectl port-forward -n openfaas svc/gateway 8080:8080
