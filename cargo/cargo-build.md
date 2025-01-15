## Building applications

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

### Using BuilderImage directly

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