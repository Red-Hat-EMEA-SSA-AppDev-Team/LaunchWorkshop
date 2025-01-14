### Monitoring pods via the Web Console

Dev perspective

Dev Perspective → Observe

Admin perspective → Project → Workload

Admin perspective → Pod → metrics

Admin perspective → Observe

### Healthchecks

[ocp-healthchecks.md](ocp-healthchecks.md)

#### Using commands inside a pod

#### Adding healthchecks via the Web Console.

From the  Developer perspective, in the Topology view, select a pod and go to Actions → Add/Edit Healthchecks

Using container commands to manage pod health

```plaintext
containers:
- name: cargo-container
  ...
  readinessProbe:
 &nbsp;  exec:
    command:
     - curl
     - '-sw'
     - '%{http_code}'
     - 'localhost:8080'
     - '-o'
     - /dev/null
 &nbsp;  timeoutSeconds: 5
 &nbsp;  periodSeconds: 10
 &nbsp;  successThreshold: 1
 &nbsp;  failureThreshold: 3  
```

#### Using HTTP calls to manage pod health

```plaintext
containers:
  - name: cargo-container
  ...
    livenessProbe:
      httpGet:
 &nbsp;&nbsp;     scheme: HTTP
 &nbsp;&nbsp;     path: /
 &nbsp;&nbsp;     port: 8080
 &nbsp;    timeoutSeconds: 5
 &nbsp;    periodSeconds: 10
 &nbsp;    successThreshold: 1
 &nbsp;    failureThreshold: 3  &nbsp;&nbsp;  
```

Using TCP calls to manage pod health

```plaintext
containers:
- name: cargo-container
  ..
  startupProbe:
    tcpSocket:
 &nbsp;&nbsp;&nbsp;&nbsp; port: 8080
 &nbsp;&nbsp; timeoutSeconds: 3
 &nbsp;&nbsp; periodSeconds: 10
 &nbsp;&nbsp; successThreshold: 1
 &nbsp;&nbsp; failureThreshold: 3
    periodSeconds: 10
```

Healthchecks with EAP

The EAP server provides an health endpoint out of the box (health subsystem)

Go to the Terminal of an EAP-based pod

```plaintext
curl localhost:9990/health 
curl localhost:9990/health/live 
curl localhost:9990/health/ready
```

The endpoint is behind the admin port 9990 rather than behind the application port (8080).  It's discourage to expose the Admin endpoint at the service level.  Moreover, EAP also has more complete probes in scripts, that make more checks than the HTTP one and that are recommended to use:

/opt/eap/bin/livenessProbe.sh

/opt/eap/bin/readinessProbe.sh

```plaintext
containers:
- name: cargo-container
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

Enhancing healthchecks

The healthchecks we saw above mainly checks the runtime.  The application can be checked as well, fo example with he HTTP probe.

But a developer can add more information to the HTTP healthchecks programmatically, using the microprofile-health-smallrye library (which is shipped with the EAP XP version)

### Metrics monitoring

The EAP server provides a prometheus-compatible metrics endpoint out of the box (metrics subsystem)

Go to the Terminal of an EAP-based pod

```plaintext
curl localhost:9990/metrics
```

The Prometheus and Grafana based dashboards shipped with Openshift can be used to display those metrics.  To enable the scraping of metrics by Prometheus, we need to add the Scraping configuration inside the application namespace.  It can be represented either by a PodMonitor, that will observe a Pod, or a ServiceMonitor, that will find the pods from the Service object.

#### ServiceMonitor