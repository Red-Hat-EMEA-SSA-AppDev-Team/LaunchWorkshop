### Building from files

#### Building from yamls

We saw that a build is simply represented by a BuildConfig object, possibly along with an ImageStream that gives a name to a newly created image.

So we could simply use a yaml representation of a BuildConfig and ImageStream and apply them to the platform.

Obviously that will work only in the cases of a build from source cod or from a dockerfile (passed inline) but not in the case of a binary build.  In the case of a binary build, the binary will be missing from the definition  and will be uploaded separately via the start-build command to trigger the build.

```plaintext
oc apply -f resources/build/cargo/cargo-is-source.yaml
oc apply -f resources/build/cargo/cargo-app-bc-source.yaml
oc get builds | grep cargo-app-bc-source
oc get images | grep cargo-app-bc-source
```

#### Builds from Templates

Another option would be to place th above 2 objects (ImageStream and BuildConfig) into a template then procss and execute the template.

In the case of EAP, such a Template is already present on the platform:

```plaintext
oc get template -n openshift | grep eap74
oc get template -n openshift eap74-basic-s2i -o yaml
```

Having a ook at the parameters dfind at th end of the file, you'll see that you need to set at least the application name and GIT URL

```plaintext
oc process eap74-basic-s2i -p SOURCE_REPOSITORY_REF=https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker#db2 -p APPLICATION_NAME=cargo-app-eaptmpl | oc apply -f -
```

As we know, Templates are also accessible from the Developer perspective of the Web Console

```plaintext
Click +Add
Select "All Services"
Filter out "Templates" from the left menu
Type "eap" in the search box
```

You should see a Template named “Jboss EAP 7.4.0” which is the displayed name of the eap74-basic-s2i template.

By instantiating this template on the Web Console, you'll have the opportunity, on the next page, to set the appropriate values for the Git repository, branch and application name

As an exercise, build and deploy th cargo tracker application using this method, giving it the name “cargo-app-tmpl-ui”.

The above mentioned template does not stop at the build process but will also create the deployment artifacts.  It can therefore be used to automate the entire build and deploy cycle.

If you go into the details of this Template, you'll see that it adds more configuration elements that we did so far.

For example, the Deployment object contains Liveness and Readiness probes (more on that in the Day 2 operations chapter).

What is interresting to see is that it does not trigger one build, but 2 builds that executes on on top of the other.  This mechanism is called a chained build and is the recommended approach to improve the security of builds executed from source code.

 [Performing Chained Builds to improve security](../ocp/chainbuilds.md)

#### **Building with Helm**

In the same way as Templates can be used to apply yaml files to the cluster, we can use Helm for the same purpose.

Similarly, for EAP, Openshift directly ships a ready-to-use Helm Chart.

*   **Using Helm Chart on the Developer perspective of the Web Console**

```plaintext
Click +Add
Select Helm Chart
Type "eap"  in the search box
```

You should see an Helm Chart  called Jboss EAP 7.4

On the next page, you'll have the opportunity to set the GIT repository URL and branch.

Deploy again the Cargo Tracker application with th name “cargo-app-helm-ui”

The Helm tab of the left menu will prsent to you the Helm releases you can do upgrade and rollbacks with.

*   **Using Helm Chart locally**

To use those Helm Chart locally:

```plaintext
helm repo add openshift https://charts.openshift.io/
helm search repo | grep -i eap
helm pull openshift/redhat-eap74 --untar
```

A look at the values file will show that the Chart sources the wildfly-common parent Chart and that the build uri and ref parameters can be customized

[https://github.com/wildfly/wildfly-charts](https://github.com/wildfly/wildfly-charts)

The values of the ‘uri’ and ‘ref’ parameters can be set in a file

\--- helm.yaml ---

```plaintext
build:
 uri: https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker
 ref: jee7-eap7
```

\---

```plaintext
helm upgrade --install cargo-app-helm-s2i -f helm.yaml openshift/redhat-eap74
```

Alternatively, they can also be set on the command line

```plaintext
helm install cargo-app-helm-s2i openshift/redhat-eap74 --set build.uri=https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker --set build.ref=db2
```

Looking into the details of the Helm Chart, inside the “templates” directory, we can see that, like the previously used Template, the Helm Chart does not stop at the build process, but also publishes deployment objects such as Deployment and Service.

It also performs the same chained build to improve the security of the build process.

 [Performing Chained Builds to improve security](../ocp/chainbuilds.md)