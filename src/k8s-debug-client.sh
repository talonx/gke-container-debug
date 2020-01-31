#!/usr/bin/env bash

#######################################
# Supports heap dump only as of now
######################################

set -e

if [[ "$#" -ne 5 ]]; then
  echo "Expected pod-name action (heap-dump) keyfile ssh user and GCS bucket"
  exit 1
fi
pod_name=$1
action=$2
keyfile=$3
user=$4
bucket=$5

if [[ "${action}" == "heap-dump" ]];
then
  echo "Taking heap dump dump on ${pod_name}"
  #Find the node where the pod is running
  node_name=`kubectl get pod ${pod_name} -o json | jq '. | .spec.nodeName'`
  echo "Node name for ${pod_name} is ${node_name}"
  public_ip=`gcloud compute instances list --filter="name=(${node_name})" --format="value(networkInterfaces[].accessConfigs[0].natIP)"`
  echo "Public IP is ${public_ip}, pushing scripts"
  scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${keyfile} k8s-debug-vm.sh k8s-debug-toolbox.sh ${user}@${public_ip}:
  echo "Running scripts"
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${keyfile} ${user}@${public_ip} sh k8s-debug-vm.sh ${pod_name} ${action} ${bucket}
  exit 0
else
  echo "Unsupported action ${action}"
fi

