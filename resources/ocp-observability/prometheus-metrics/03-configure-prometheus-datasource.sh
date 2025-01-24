#!/usr/bin/env bash

#Environment variables
OBSERVABILITY_NS="observability"

# Deploy the Prometheus Grafana Datasource
# /!\ RECOMMENDED: Make sure you obtain the bound service account token using the TokenRequest API
# E.g for a service account token creation with a one-year (365 days) expiry: oc create token <service_account_name> --duration=$((365*24))h
# Reference: https://access.redhat.com/solutions/7025261
oc apply -f ./manifests/prometheus_grafanadatasource.yaml -n $OBSERVABILITY_NS