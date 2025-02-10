### Building from the command line

#### Using the new-app command to build

We've already see a few examples of th new-app command to perform deployments.

This command can actually also be used to start the cycle at the build phase, and thus to proceed to both a build and deployment process at the same time, starting from the source code

```plaintext
oc new-app eap74-openjdk11-openshift-rhel8~https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker#db2 --name=cargo-newapp-source
```

### Build Triggers

BuildConfig are objects holding configuration information for builds, which basically are an association between application code and base images.

It might be interresting that a new build is automatically initiated if the BuildConfig object changes, or if the base image changes (for example when a security patch is applied to it).

This can be done using Build Triggers, that Openshift supports based on Annotations.  Rather than manipulating annotations directly, it's easier to use the command line:

```plaintext
oc set triggers bc/cargo-app --from-config
oc set triggers bc/cargo-app --from-image=eap74-openjdk11-openshift-rhel8:latest
```

New builds can also be triggered directly from a change in the source code.

```plaintext
oc set triggers bc/cargo-app --from-webhook=true
```

The URL to use to configure the webhook in the source code repository can be found on the BuildConfig description:

```plaintext
oc describe bc/cargo-app
```

It should be somthing similar to:

```plaintext
https://api.<ocp-domain>:443/apis/build.openshift.io/v1/namespaces/<namespace>/buildconfigs/<name>/webhooks/<secret>/github
```