#!/usr/bin/env bash

#Environment variables
CARGO_APP_NS=eap7

# Deploy a dedicated Service resource for metrics 
# and the ServiceMonitor resource to scrap prometheus metrics from the cargo-app
oc apply -n $CARGO_APP_NS -f - <<EOF
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: cargo-app
  name: cargo-app-metrics
spec:
  clusterIP: None
  selector:
    app: cargo-app
    deployment: cargo-app
  ports:
  - name: metrics
    port: 9990
    protocol: TCP
    targetPort: 9990
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    app: cargo-app
  name: cargo-app
spec:
  selector:
    matchLabels:
      app: cargo-app
  endpoints:
  - port: metrics
    path: /metrics
    interval: 10s
    honorLabels: true
EOF