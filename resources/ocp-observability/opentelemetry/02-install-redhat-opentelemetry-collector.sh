#!/usr/bin/env bash

# /!\ PRE-REQUISITES: /!\
# - You have access to the cluster as a user with the cluster-admin cluster role.

#Environment variables
OBSERVABILITY_NS="observability"
RH_OPENTELEMETRY_NS="openshift-opentelemetry-operator"
RH_OPENTELEMETRY_CSV_NAME="opentelemetry-operator"

# Install operators using the OLM
## The _Red Hat build of OpenTelemetry operator_ 
oc apply -f ./manifests/openshift-opentelemetry-operator_sub.yaml

## Loop until the Red Hat build of OpenTelemetry Operator CSV is in the 'Succeeded' phase
while true; do
  # Check if the CSV is in the 'Succeeded' phase
  if oc get csv -o jsonpath="{range .items[*]}{.metadata.name}:{.status.phase}{'\n'}{end}" | grep "^${RH_OPENTELEMETRY_CSV_NAME}.*:Succeeded"; then
    echo "Operator $RH_OPENTELEMETRY_CSV_NAME is successfully installed."
    break
  else
    echo "Waiting for Operator $RH_OPENTELEMETRY_CSV_NAME to be installed..."
  fi
  # Sleep for 10 seconds before checking again
  sleep 10
done

# Create the observability namespace if not already created
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

# ClusterRole and ClusterRoleBinding objects have to be created to enable reading and writing data to the multi-tenant tempoStack
oc apply -f ./manifests/tempostack_read-and-write_rbac.yaml

# Create the OpenTelemetry Collector instance in the observability namespace
oc apply -f ./manifests/opentelemetry-collector_cr.yaml -n $OBSERVABILITY_NS

# Add permissions to the Red Hat build of OpenTelemetry Operator to configure RBAC resources for some collector components
oc apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: generate-processors-rbac
rules:
- apiGroups:
  - rbac.authorization.k8s.io
  resources:
  - clusterrolebindings
  - clusterroles
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: generate-processors-rbac
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: generate-processors-rbac
subjects:
- kind: ServiceAccount
  name: opentelemetry-operator-controller-manager
  namespace: openshift-opentelemetry-operator
EOF

# Watch for the pods being created
watch oc get po -n $OBSERVABILITY_NS