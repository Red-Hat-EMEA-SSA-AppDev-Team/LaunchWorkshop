#!/usr/bin/env bash

# /!\ PRE-REQUISITES: /!\
# - Using the MinIO admin console, create a bucket named `loki-storage`
# - You have access to the cluster as a user with the cluster-admin cluster role.

#Environment variables
CLUSTER_LOGGING_NS="openshift-logging"
CLUSTER_LOGGING_CSV_NAME="cluster-logging"
CLUSTER_OBSERVABILITY_CSV_NAME="cluster-observability-operator"
LOKI_OPERATOR_CSV_NAME="loki-operator"

# Install operators using the OLM
## The _Cluster Logging Operator_ 
oc apply -f ./manifests/cluster-logging-operator_sub.yaml

## Loop until the Cluster Logging Operator CSV is in the 'Succeeded' phase
while true; do
  # Check if the CSV is in the 'Succeeded' phase
  if oc get csv -o jsonpath="{range .items[*]}{.metadata.name}:{.status.phase}{'\n'}{end}" | grep "^${CLUSTER_LOGGING_CSV_NAME}.*:Succeeded"; then
    echo "Operator $CLUSTER_LOGGING_CSV_NAME is successfully installed."
    break
  else
    echo "Waiting for Operator $CLUSTER_LOGGING_CSV_NAME to be installed..."
  fi
  # Sleep for 10 seconds before checking again
  sleep 10
done

## The _Cluster Observability Operator_ 
oc apply -f ./manifests/cluster-observability-operator_sub.yaml

## Loop until the Cluster Observability Operator CSV is in the 'Succeeded' phase
while true; do
  # Check if the CSV is in the 'Succeeded' phase
  if oc get csv -o jsonpath="{range .items[*]}{.metadata.name}:{.status.phase}{'\n'}{end}" | grep "^${CLUSTER_OBSERVABILITY_CSV_NAME}.*:Succeeded"; then
    echo "Operator $CLUSTER_OBSERVABILITY_CSV_NAME is successfully installed."
    break
  else
    echo "Waiting for Operator $CLUSTER_OBSERVABILITY_CSV_NAME to be installed..."
  fi
  # Sleep for 10 seconds before checking again
  sleep 10
done

## The _Loki Operator_ 
oc apply -f ./manifests/loki-operator_sub.yaml

## Loop until the Loki Operator CSV is in the 'Succeeded' phase
while true; do
  # Check if the CSV is in the 'Succeeded' phase
  if oc get csv -o jsonpath="{range .items[*]}{.metadata.name}:{.status.phase}{'\n'}{end}" | grep "^${LOKI_OPERATOR_CSV_NAME}.*:Succeeded"; then
    echo "Operator $LOKI_OPERATOR_CSV_NAME is successfully installed."
    break
  else
    echo "Waiting for Operator $LOKI_OPERATOR_CSV_NAME to be installed..."
  fi
  # Sleep for 10 seconds before checking again
  sleep 10
done

# Create the 'logging-loki-s3' secret in the openshift-logging namespace
oc apply -f ./manifests/logging-loki-s3_secret.yaml -n $CLUSTER_LOGGING_NS

# Create a LokiStack custom resource (CR) in the openshift-logging namespace
oc apply -f ./manifests/logging-lokistack_cr.yaml -n $CLUSTER_LOGGING_NS

# Create a service account for the collector:
oc apply -n $CLUSTER_LOGGING_NS -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: collector
EOF

oc project -n $CLUSTER_LOGGING_NS
# Allow the collector’s service account to write data to the LokiStack CR:
oc adm policy add-cluster-role-to-user logging-collector-logs-writer -z collector

# Allow the collector’s service account to collect logs:
oc adm policy add-cluster-role-to-user collect-application-logs -z collector
oc adm policy add-cluster-role-to-user collect-audit-logs -z collector
oc adm policy add-cluster-role-to-user collect-infrastructure-logs -z collector

# Create a UIPlugin CR to enable the Log section in the Observe menu:
oc apply -f ./manifests/coo-loggingui-plugin_cr.yaml

# Create a ClusterLogForwarder CR to configure log forwarding:
oc apply -f ./manifests/logging-clusterlogforwarder_cr.yaml -n $CLUSTER_LOGGING_NS

# Verify the Cluster Logging deployment
watch oc get po -n $CLUSTER_LOGGING_NS
