## **Builds with Helm**

As the same way as tampltes can be used to apply yaml files to the cluster, we can use Helm for the same purpose.

Similarly, for EAP, Openshift directly ships with a ready-to-use Helm Chart.

**To use the Helm Chart the Web Console, inside the Developer perspective:**

```plaintext
Click +Add
Select Helm Chart
Type "eap"  in the search box
```

You should see an Helm Chart  called Jboss EAP 7.4

On the next page, you'll have the opportunity to set the GIT repository URL and branch.

Deploy again a Cargo app as an exercise, calling it “cargo-app-helm-ui”

You'll see your Helm releases from the Developer perspective, under the Helm tab of th left menu.

**Using Helm Chart locally**

To use those Helm Chart locally:

```plaintext
helm repo add openshift https://charts.openshift.io/
helm search repo | grep -i eap
helm pull openshift/redhat-eap74 --untar
```

A look at the values file will tell you that the Chart expect a build URI and ref parameters

```plaintext
cat eap74/values.yaml
```

They can be set on the command line

```plaintext
helm install cargo-app-helm openshift/redhat-eap74 --set build.uri=https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker --set build.ref=jee7-eap7
```

Alternatively, you can define those values in a yaml file

\--- helm.yaml ---

```plaintext
build:
  uri: https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker
  ref: jee7-eap7
```

\---

```plaintext
helm upgrade --install cargo-app-helm -f helm.yaml openshift/redhat-eap74
```

Looking into the details of the Helm Chart, inside the templates directory, we can see that the Helm Chart does not stop at the build process, but also publishes some deployment objects such as Deployment and Service.

What is also interresting is to see that it performs 2 builds, not only one.  This is called a chained build.  When building from a source code, a chain build is the best practice for security.

[Performing Chained Builds to improve security](../ocp/chainbuilds.md)