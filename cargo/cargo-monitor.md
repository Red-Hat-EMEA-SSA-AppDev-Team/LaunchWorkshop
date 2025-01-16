## Monitoring Pods

### Monitoring pods via the Web Console

The Web console offers several ways to help with the monitoring activities

The Developer perspective in general

It is similar to the Administrator perspective,  Project tab; select a project and go to the Workload tab

The Developer perspective and its Observe tab

The Administrator perspective and its Observe menu

Any perspective and the Metrics tab inside a selected Pod 

### Healthchecks

Openshift automatically performs the self-healing of all pods it runs.

[Introduction to Openshift self healing](ocp-healthchecks.md)

The healthchecks, that are part of the deployment object, can rely on 3 mechanisms

*   Commands run inside the container

```plaintext
containers:
- name: cargo-app-health
  ...
  readinessProbe:
    exec:
      command:
      - curl
      - '-sw'
      - '%{http_code}'
      - 'localhost:8080'
      - '-o'
      - /dev/null
    timeoutSeconds: 5
    periodSeconds: 10
    successThreshold: 1
    failureThreshold: 3  
```

*   HTTP calls, from inside the container (the port does not have to be exposed on the Openshift SDN network)

```plaintext
containers:
- name: cargo-app-health
  ...
  livenessProbe:
    httpGet:
      scheme: HTTP
      path: /
      port: 8080
    timeoutSeconds: 5
    periodSeconds: 10
    successThreshold: 1
    failureThreshold: 3
```

*   TCP calls

```plaintext
containers:
- name: cargo-app -health
  ...
  startupProbe:
    tcpSocket:
      port: 8080
    timeoutSeconds: 3
    periodSeconds: 10
    successThreshold: 1
    failureThreshold: 3
    periodSeconds: 10
```

#### Adding healthchecks via the Web Console.

Healthchecks can be added from the  Developer perspective.

In the Topology view, select a pod and go to Actions → Add/Edit Healthchecks

### Healthchecks with EAP

The EAP server provides an HTTP health endpoint out of the box 

Go to the Terminal of an EAP-based pod and type:

```plaintext
> curl localhost:9990/health 
> curl localhost:9990/health/live 
> curl localhost:9990/health/ready
```

Therefore, a probe could have been defined as follows:

```plaintext
  livenessProbe:
    httpGet:
      scheme: HTTP
      path: /health/live
      port: 9990
```

But the EAP server image also embeds more complete probes in local scripts, which are recommended to use:

For example:

```plaintext
containers:
- name: cargo-app-health-cmd
  ...
  readinessProbe:
    exec:
      command:
      - /bin/bash
      - '-c'
      - /opt/eap/bin/readinessProbe.sh
    initialDelaySeconds: 10
    timeoutSeconds: 5
    periodSeconds: 10
    successThreshold: 1
    failureThreshold: 3
  livenessProbe:
    exec:
      command:
      - /bin/bash
      - '-c'
      - /opt/eap/bin/livenessProbe.sh
    initialDelaySeconds: 10
    timeoutSeconds: 5
    periodSeconds: 10
    successThreshold: 1
    failureThreshold: 3  
```

#### Enhancing healthchecks

The healthchecks we saw above are provided by the application runtime thus mainly checks this runtime.  

A developer can decide to add more information to the HTTP healthchecks programmatically, using the “microprofile-health-smallrye” library, which is part of the EAP XP version of the product.

### Metrics

The EAP server provides a prometheus-compatible metrics endpoint out of the box.

Go to the Terminal of an EAP-based pod and type:

```plaintext
curl localhost:9990/metrics
```

The Prometheus and Grafana based dashboards shipped with Openshift, or another similar solution, can be used to display those metrics.  

[Introduction to Openshift metrics](../ocp/ocp-metrics.md)

To enable the scraping of metrics by Prometheus, we need to add an object that can provide the scraping configuration specific to the application to Prometheus.  

This object is a ServiceMonitor, located in the same Namespace as the application.

```plaintext
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
 labels:
   app: cargo-app-monitor
 name: cargo-app-monitor
spec:
 selector:
   matchLabels:
     app: cargo-app
 endpoints:
 - port: 9990-tcp
   path: /metrics
   interval: 10s
   honorLabels: true
```

As we saw it, the EAP metrics are hidden behind an admin port: 9990.  Contrary to the healthchecks, Prometheus does not scrap information directly within the pod, but remotely uses the Openshift SDN network to access the pod's metrics on its HTTP interface.  Therefore, the admin port 9990 must be exposed at the Service level.