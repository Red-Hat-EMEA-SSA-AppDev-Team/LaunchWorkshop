#!/usr/bin/env bash

#Environment variables
MINIO_NS="minio"

oc apply -f ./manifests/minio-dep.yaml

# Verify the MinIO deployment
watch oc get po -n $MINIO_NS

# List credentials
echo "MinIO credentials:"
oc extract secret/minio-secret --to=- -n $MINIO_NS
