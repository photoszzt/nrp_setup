#!/bin/bash

NUM_VM=1
SECRET_NAME=zzt-pub-key
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
VIRTCTL="kubectl virt"
NAMESPACE="utaustin-osa"

for ((i=0; i<${NUM_VM}; i++)); do
	SECRET_NAME=${SECRET_NAME} NUM=${i} NAMESPACE=${NAMESPACE} envsubst < $SCRIPT_DIR/yamls/vmi.yaml | kubectl apply -f -
	$VIRTCTL start vm-$i -n $NAMESPACE
done
