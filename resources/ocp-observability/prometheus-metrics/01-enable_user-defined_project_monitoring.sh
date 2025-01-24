#!/usr/bin/env bash

# /!\ PRE-REQUISITES: /!\
# - You have access to the cluster as a user with the cluster-admin cluster role.

# Create the cluster-monitoring-config configMap in the openshift-monitoring namespace:
oc -n openshift-monitoring apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
 name: cluster-monitoring-config
 namespace: openshift-monitoring
data:
 config.yaml: |
   ## Configure Persistent Storage for Prometheus Stack
   # The Prometheus stack consists of the Prometheus database and the Alertmanager data.
   # Persisting both is considered a best practice because data loss on either of these can result
   # in losing your collected metrics and alerting data.
   prometheusK8s:
     volumeClaimTemplate:
       metadata:
         name: prometheusdb
       spec:
         resources:
           requests:
             storage: 200Gi
   alertmanagerMain:
     volumeClaimTemplate:
       metadata:
         name: alertmanager
       spec:
         resources:
           requests:
             storage: 100Gi
   ## /!\ Enabling monitoring for user-defined projects
   #      Reference: https://docs.openshift.com/container-platform/4.17/observability/monitoring/enabling-monitoring-for-user-defined-projects.html
   enableUserWorkload: true
EOF

# List the new PVCs in the openshift-monitoring namespace
oc get -n openshift-monitoring pvc

# Verify the activation of the user workload monitoring
# Check that the prometheus-operator, prometheus-user-workload and thanos-ruler-user-workload pods are running 
# in the openshift-user-workload-monitoring project
watch oc -n openshift-user-workload-monitoring get po