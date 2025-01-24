#!/usr/bin/env bash

# /!\ PRE-REQUISITES: /!\
# - You have access to the cluster as a user with the cluster-admin cluster role.

#Environment variables
OBSERVABILITY_NS="observability"
CSV_NAME="grafana-operator"

# Create the $OBSERVABILITY_NS namespace
oc apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    openshift.io/description: ""
    openshift.io/display-name: Observability Tools
  name: ${OBSERVABILITY_NS}
spec: {}
EOF

# Install the `Grafana` operator (clusterwide-scoped)
oc apply -f ./manifests/grafana-operator_subscription.yaml

## Loop until the CSV is in the 'Succeeded' phase
while true; do
  # Check if the CSV is in the 'Succeeded' phase
  if oc get csv -o jsonpath="{range .items[*]}{.metadata.name}:{.status.phase}{'\n'}{end}" | grep "^grafana-operator.*:Succeeded"; then
    echo "Operator $CSV_NAME is successfully installed."
    break
  else
    echo "Waiting for Operator $CSV_NAME to be installed..."
  fi
  # Sleep for 10 seconds before checking again
  sleep 10
done

# Deploy grafana instance
oc apply -f ./manifests/grafana.yaml -n $OBSERVABILITY_NS

# Deploy the EAP Grafana Dashboards
# oc apply -f ./manifests/TODO -n $OBSERVABILITY_NS
