### Building from the command line

#### Using the new-app command to build

We've already see a few examples of th new-app command to perform deployments.

This command can actually also be used to start the cycle at the build phase, and thus to proceed to both a build and deployment process at the same time, starting from the source code

```plaintext
oc new-app eap74-openjdk11-openshift-rhel8~https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker#db2 --name=cargo-newapp-source
```