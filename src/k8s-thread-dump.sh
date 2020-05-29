#!/usr/bin/env bash
############################################################################
#This script takes thread dumps from pods and uploads them to a GCS bucket.
#Note that this uses kubectl instead of the custom code in the other debug scripts
############################################################################
set -e

if [[ "$#" -lt 3 ]]; then
  echo "Usage: k8s-thread-dump.sh [pod-name] [bucket-name/directory-name] [namespace] (container-name)"
  exit 1
fi
pod_name=$1
bucket=$2
namespace=$3

if [[ "$#" -eq 4 ]]; then
  container=$4
  echo "Container name set to ${container}"
fi

echo "Taking a thread dump from ${pod_name} in namespace ${namespace}"

dttime=`echo $(date '+%d-%b-%Y-%H-%M-%S')`
filename=${pod_name}-${dttime}.tdump
filepath="/tmp/${filename}"

for i in {0..11}
do
  if [[ -z "${container+x}" ]]; then
    kubectl exec ${pod_name} -n ${namespace} -it -- jstack 1 >> ${filepath}
  else
    kubectl exec ${pod_name} -n ${namespace} -c ${container} -it -- jstack 1 >> ${filepath}
  fi
  echo "Took $(($i + 1)), sleeping"
  sleep 5
done

cd /tmp/
tar zvcf ${filename}.tar.gz ${filename}
gsutil cp ${filename}.tar.gz gs://${bucket}/
echo "Thread dump uploaded to gs://${bucket}/${filename}.tar.gz"
rm -rf ${filename}.*