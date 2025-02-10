## Deploying Cargo Tracker on Openshift on the EAP 8 image

You can deploy the Cargo Tracker application with the provided dockerfile.

Galleon is used to download maven artifacts, so it's recommended to proceed with a chained build, using first the eap8-openjdk17-builder-openshift-rhel8 image then the eap8-openjdk17-runtime-openshift-rhel8 one.

[EAP8 Dockerfile](../resources/build/cargo/cargo-eap8-Dockerfile)