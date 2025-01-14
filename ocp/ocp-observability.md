Any Openshift cluster emits metrics information that are stored in a Prometheus-compatible database.  

Therefore, a Prometheus instance as well as a Grafana user interface are always available as part of an Openshift cluster to obseve the behaviour of the cluster infrastructure.

This same set of tooling can be used to gather application information as well as cluster infrastructure information.

The Prometheus metrics format has become a recognized standard.

Of course you're free to use any other Observability tools, running on or outside of Openshift, but to show what metrics are about, we'll use the embedded solution, and we'll enable the existing Cluster monitoring tool to the application scope fo the time of the workshop.

### Enabling the observability for applications

First, create a ConfigMap in the openshift-monitoring namespace that enable the user workload monitoring.

```plaintext
oc -n openshift-monitoring apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
 name: cluster-monitoring-config
 namespace: openshift-monitoring
data:
 config.yaml: |
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
   enableUserWorkload: true
EOF
```

Pods should have been created in a new openshift-user-workload-monitoring namespace.

oc get pods -n  openshift-user-workload-monitoring