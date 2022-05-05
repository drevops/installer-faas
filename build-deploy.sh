#!/bin/sh
set -o errexit

YAML_CONFIG="${1:?"YAML config file name is required"}"

TEST_DATA_REQUEST="guest"
TEST_DATA_RESPONE="HI guest BYE"

#--------------------------------------------------------------------

echo "==> Building"
faas-cli build -f "${YAML_CONFIG}"

echo "==> Pushing to the registry"
faas-cli push -f "${YAML_CONFIG}"

echo "==> Authenticating with FaaS"
kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode | faas-cli login --username admin --password-stdin

echo "==> Deploying"
faas-cli deploy -f "${YAML_CONFIG}" -g http://127.0.0.1:8080

echo "==> Waiting for rollout"
kubectl get pods -n openfaas-fn
sleep 5
kubectl get pods -n openfaas-fn
sleep 5
kubectl get pods -n openfaas-fn
sleep 5
kubectl get pods -n openfaas-fn
sleep 5

echo "== Probing"
curl -X POST http://127.0.0.1:8080/function/my-function -d "${TEST_DATA_REQUEST}"| grep "${TEST_DATA_RESPONE}" && echo "OK" || echo "Not ready"
