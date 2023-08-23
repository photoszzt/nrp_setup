#!/bin/bash

# This script follows instruction from: https://docs.pacificresearchplatform.org/userdocs/running/scripts/
set -euo pipefail
set -x

ROLE="admin"
SERVICE_ACCOUNT="zzt"
USER=$(kubectl config view -o jsonpath='{.users[0].name}')
NAMESPACE="utaustin-osa"

if [[ "$NAMESPACE" = "" ]]; then
	echo "NAMESPACE should be set"
fi
if [[ "$ROLE" = "" ]]; then
	echo "ROLE should be set"
fi
if [[ "$SERVICE_ACCOUNT" = "" ]]; then
	echo "SERVICE_ACCOUNT should be set"
fi
if [[ "$USER" = "" ]]; then
	echo "USER should be set"
fi

kubectl create serviceaccount ${SERVICE_ACCOUNT} -n $NAMESPACE
TOKENNAME=`kubectl get serviceaccount/${SERVICE_ACCOUNT} -n $NAMESPACE -o jsonpath='{.secrets[0].name}'` 
echo $TOKENNAME
TOKEN=`kubectl get secret $TOKENNAME -o jsonpath='{.data.token}' -n $NAMESPACE | base64 --decode` 
echo $TOKEN

cp $HOME/.kube/config $HOME/.kube/config_sa
kubectl --kubeconfig=$HOME/.kube/config_sa config set-credentials ${SERVICE_ACCOUNT} --token=$TOKEN
kubectl --kubeconfig=$HOME/.kube/config_sa config set-context --current --user=${SERVICE_ACCOUNT}
kubectl --kubeconfig=$HOME/.kube/config_sa config view
kubectl --kubeconfig=$HOME/.kube/config_sa config unset users.${USER}

kubectl create rolebinding ${SERVICE_ACCOUNT}-sa --clusterrole=${ROLE} --serviceaccount=${NAMESPACE}:${SERVICE_ACCOUNT} -n $NAMESPACE

kubectl --kubeconfig=$HOME/.kube/config_sa get pods -n $NAMESPACE
