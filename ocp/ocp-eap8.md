## JBoss EAP 8 on Openshift

### Galleon

EAP was already a very modular application server, with features represented by modules that could be enabled or disabled when needed.  

The installation of the server itself was however done in one shot, usually from a zip file.

To further increase its modularity and decrease its footprint when containerized, the JBoss EAP server has been repackaged with Galleon, allowing it to be installed fractions by fractions with just the strict necessary features.

The capability that can be installed in isolation are called “layers”.

Together, some layers can be grouped in “feature packs”.

Layers and feature packs are packaged as maven artifacts.

### Red Hat Builder Image

The Red Hat eap8-openjdk17-builder-openshift-rhel8 exploits Galleon to download and install an minimalistic EAP server at runtime based on environment variables:

```plaintext
ENV GALLEON_PROVISION_CHANNELS
ENV GALLEON_PROVISION_FEATURE_PACKS
ENV GALLEON_PROVISION_LAYERS
```