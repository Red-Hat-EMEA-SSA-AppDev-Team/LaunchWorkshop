Any Openshift cluster emits metrics information that are stored in a Prometheus-compatible database.  

Therefore, a Prometheus instance as well as Grafana-based dashboards are always available as part of an Openshift cluster to obseve the behaviour of the cluster infrastructure.

This same set of tooling can be used to gather application information as well as cluster infrastructure information.

The Prometheus metrics format has become a recognized standard.

Of course you're free to use any other Observability tools, running on or outside of Openshift, but to show what metrics are about, we'll use the embedded solution, and we'll enable the existing Cluster monitoring tool to the application scope, also known as OpenShift monitoring for user-defined projects, for the time of the workshop.

### Enabling OpenShift monitoring for user-defined projects

As a user with cluster-admin privileges:

1. Create the `cluster-monitoring-config` configMap in the `openshift-monitoring` namespace:
    ```shell
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
    ```

2. Verify the activation of the user-defined project monitoring. Check that the `prometheus-operator`, `prometheus-user-workload` and `thanos-ruler-user-workload` pods are running in the `openshift-user-workload-monitoring` namespace:
    ```shell
    oc get pods -n  openshift-user-workload-monitoring
    ```