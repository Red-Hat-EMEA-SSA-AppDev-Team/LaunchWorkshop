#!/usr/bin/env bash

#Environment variables
CARGO_APP_NS=eap7

# Create the java auto-instrumentation resource for the cargo-app
oc apply -f ./manifests/cargo-app_autoinstrumentation.yaml -n $CARGO_APP_NS

# Add the java auto-instrumentation annotation to the cargo-app deployment pods
# This will inject the OpenTelemetry Java agent into the cargo-app pods. 
# Behind the scenes, the Red Hat build of OpenTelemetry Operator does the following:
# - It attaches a new emptyDir volume (opentelemetry-auto-instrumentation-java)
# - It adds a new init container (opentelemetry-auto-instrumentation-java), which copies javaagent.jar to this volume
# - This volume is mounted in the container of the application
# - The JAVA_TOOL_OPTIONS environment variable is modified to load javaagent.jar
oc patch deploy/cargo-app \
  --type='merge' \
  -p '{"spec":{"template":{"metadata":{"annotations":{"instrumentation.opentelemetry.io/inject-java":"cargo-app"}}}}}' \
  -n $CARGO_APP_NS

# Watch for the pods being created
watch oc get po -n $CARGO_APP_NS