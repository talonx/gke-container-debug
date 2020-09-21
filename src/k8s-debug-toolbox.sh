#!/usr/bin/env bash

set -e

if [[ "$#" -ne 3 ]]; then
  echo "Expected filename bucket and user"
  exit 1
fi
filename=$1
bucket=$2
user=$3

echo "Uploading to bucket"
/google-cloud-sdk/bin/gsutil cp /media/root/home/${user}/${filename} gs://${bucket}/kdev-debug/${filename}
echo "Final location ${bucket}/kdev-debug/$filename"
