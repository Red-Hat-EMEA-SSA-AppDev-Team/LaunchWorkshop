### Building from the command line

#### Using the new-app command to build

We've already see a few examples of th new-app command to perform deployments.

This command can actually also be used to start the cycle at the build phase, and thus to proceed to both a build and deployment process at the same time, starting from the source code

```plaintext
oc new-app eap74-openjdk11-openshift-rhel8~https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker#jee7-eap7 --name=cargo-newapp-source
```

#### Using the create command to build

BUG !!!

```plaintext
oc apply -f cargo-is-build.yaml
oc create build cargo-app-build --strategy=Source --source-git=https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker --source-revision=jee7-eap7 --from-image=eap74-openjdk11-openshift-rhel8 --to-image-stream=cargo-app-build:latest 
```