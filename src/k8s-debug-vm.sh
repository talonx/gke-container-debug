#!/usr/bin/env bash

set -e

if [[ "$#" -ne 3 ]]; then
  echo "Expected pod-name action (heap-dump) and bucket to push the dump to"
  exit 1
fi
pod_name=$1
action=$2
bucket=$3

echo "Taking ${action} on ${pod_name}"
#Assumes one Java process container per pod
container_id=`docker ps | grep ${pod_name} | grep -v "POD" | awk '{print $1}'`
echo "Container id ${container_id}"
#Supports only heap dump for now
docker exec ${container_id} sh -c "jmap -dump:format=b,file=/heap.dump 1"
dttime=`echo $(date '+%d-%b-%Y-%H-%M-%S')`
filename=${pod_name}-${dttime}.hdump
echo "Copying heap dump to node"
docker cp ${container_id}:/heap.dump ${filename}
echo "Heap dump at ${filename}"
/usr/bin/toolbox bash /media/root/home/${USER}/k8s-debug-toolbox.sh ${filename} ${bucket} ${USER}

#This is the container's init process id as seen from the host machine. We cannot use this
#as java is not present on the host machine. If it had, we need not have entered the container.
#cpid=`docker inspect -f '{{.State.Pid}}' ${container_id}`
