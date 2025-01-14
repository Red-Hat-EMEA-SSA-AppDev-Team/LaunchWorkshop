Openshift offers multiple ways to mak a Conainer Image from an application.

One way is to use the Openshift S2I process.

### Openshift S2I

#### From the source code

```plaintext
oc new-build eap74-openjdk11-openshift-rhel8~https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker#jee7-eap7 --name=cargo-app-source

oc get builds
oc get images | grep cargo-app-source
oc get is
oc describe is cargo-app-source
```

We'll explore multiple ways to deploy an application later.  For now, let's just use the simplest one to check that the application image was built successfully.

From the Web Console, in the Developer perspective:

```plaintext
Click +Add
Select Container Image
Choose Image steam tag from internal registry
Make sure to select the right project and the image stream named cargo-app-source with the “latest” tag
```

A pod should be deploying.  From the Topology view, click on the cargo-app-source application.  On the right side, you should see Pods, Builds, Services and Routes.

Copy the Route URL and copy in onyour web browser, appending /cargo-tracker.

**From a java archive (.war)**

Sometimes it's prefered to execute the Java/maven build externally

```plaintext
oc import-image registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8 --confirm
oc new-build --binary=true  --image-stream=eap74-openjdk11-openshift-rhel8  --name=cargo-app
```

A new BuildConfig object should have been created in the namespace

```plaintext
oc get bc
```

Now that the process exists, we can use a .war file to trigger it

```plaintext
git clone https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker
cd cargotracker
git checkout jee7-eap7

mvn package
mkdir ocp ; mkdir ocp/deployments/
mv target/*.war  ocp/deployments/

oc start-build cargo-app --from-dir=./ocp --follow
```

The build should start and create a new Container Image

```plaintext
oc get builds
oc get images | grep cargo-app
oc get is
oc describe is cargo-app
```

We can use a similar process to dploy and check the application, this time using cargo-app as the image steam name

### External builds

An alternative could be to build the entire image externally, then pushing the image into a Container Image registry accessible from the Openshift cluster.

#### Building images with podman

Fo podman, we can use the following ContainerFile

\--- Container file ---

```plaintext
FROM registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8:latest
COPY ocp/deployments/* /deployments
ENTRYPOINT /opt/eap/bin/standalone.sh -c standalone-openshift.xml -bmanagement 0.0.0.0 -Djboss.server.data.dir=/opt/eap/standalone/data -Dwildfly.statistics-enabled=true
```

\---

```plaintext
podman login registry.redhat.io
podman build . -t cargo-app-podman
```

The image should be built locally.

```plaintext
podman images
```

We can test it locally to see if the build procss was ok.

```plaintext
podman run <imageID>
```

If so, we can push the image to a remote registry.

In th case of the internal registry of the Openshift cluster, we need to first make sure the rgistry is exposed

```plaintext
oc get pods -n openshift-image-registry
oc get routes -n openshift-image-registry
```

If not, we can xpose the registry by altering the Operator that manages it (we'll look at the Operator technology later).

```plaintext
oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge
oc get routes -n openshift-image-registry
```

As the internal registry is secured, we also need a user with the appropriate permission to use it.  On Openshift, it corresponds to the registry-editor role.

```plaintext
oc policy add-role-to-user registry-editor <user_name>
```

Use the following user name and password during this workshop:

TODO: \<username> \<password-token>

Once done, we can push the image to the registry.

```plaintext
podman login <user> <token>

podman tag localhost/cargo-app-podman:latest default-route-openshift-image-registry.apps.<domain>/<namespace>/cargo-app-podman:latest

podman push default-route-openshift-image-registry.apps.<domain>/<namespace>/cargo-app-podman:latest

oc get images | grep cargo-app-podman
oc get is
```

You can deploy and test the application using the same technique as before.

TODO

→ try to get metrics

\-Dwildfly.statistics-enabled=true

### Templates and Helm

[Introduction to using Openshift Templates and Helm Charts](../ocp/helmtmpl.md)

#### Using Templates

We saw that a build is simply represented by a BuildConfig object, possibly along with an ImageStream that gives a name to a newly created image.

Of course w could use a yaml representation of a BuildConfig and ImageStream and apply them to the platform using oc apply -f \<yaml\_file>.

Also, we could combine those 2 yaml definitions in a single “Template” file and apply that unique file.

In the case of EAP, the platform directly ships with a ready-to-use template.

**To access the template from the Web Console, inside the Developer perspective:**

```plaintext
Click +Add
Select “All Services”
Filter out Templates from the left menu
Type “eap” in the search box
```

You should see a Template named Jboss EAP 7.4.0.

By instantiating this template, you'll have the opportunity, on the next page, to set appropirate values for the Git repository and branch.

As an exercise, build and deploy th cargo tracker application using this method, giving it the name “cargo-app-tmpl-ui”.

The actual name of the template, which can differ from the displayed name, is eap74-basic-s2i.

You can confirm that on the command line:

```plaintext
oc get templates -n openshift | grep eap74
```

If you prefer, you can instantiate the template from th command line, using the -p option to set the Git repository URL and branch parameters.

#### **Using Helm**

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

Openshift new-app command

We've already see a deployment from the Web Console, and how it already automated a few tasks such as the creation of Services and Routes.

The Openshift new-app command is behind that.  This is a command that acts as a shortcut to perform build and deployment steps altogether quickly.

The command can take many forms:

*   Build and deploy from source

oc new-app [eap74-openjdk11-openshift-rhel8](http://registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8)~https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker#jee7-eap7 --name=cargo-newapp-source

*   From an existing build

TODO

We'll see more forms later in the context of deploying images

Notice that the "-o yaml" option allows to make a dry-run.

```plaintext
oc new-app … -o yaml
```

Using BuilderImage directly

Some BuilderImage are directly accssible from th WebConsole, within the Developer perspective.

```plaintext
Click +Add
Select “All Services”
Filter out “Builder image” from th left meny
Type “eap” in th search box
```

 You won't see the JBoss EAP 7 BuilderImage exposed, but you should see the JBoss EAP XP images.

JBoss EAP XP is a JBoss EAP server with additional Microprofile libraries.

\<doc JBoss EAP XP>