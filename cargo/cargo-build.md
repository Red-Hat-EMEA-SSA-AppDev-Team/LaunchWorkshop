## Building applications

Openshift offers multiple ways to make a Container Image from an application.

One way is to use the Openshift S2I process.

### Openshift S2I

The Openshift Build process is based on an Object called a `BuildConfig`.

This can be created from the command line with nthe “oc new-build” command, or graphically from the Web Console, under the 'Build' menu of both the Administrator and Developer perspective.

#### From the source code

The following command triggers an image build process from the source repo:

```sh
oc new-build https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker#db2 --name=cargo-app-source --image="registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8:latest"
```

> [!NOTE]
> The source repo ends with `#db2` to select a specific commit with the `db2` tag: in fact, this specific release relies on the default effimeral db in EAP (H2).

List the build:

```sh
oc get builds
```

Inspect the build logs (find the log name from the previous result):

```sh
oc logs -f cargo-app-source-1-build
```

When the build is completed you can inspect the outcome with the following commands:

```sh
oc get images | grep cargo-app-source
oc get is
oc describe is cargo-app-source
```

##### Running the application

We'll explore multiple ways to deploy an application later. For now, let's just use the simplest one to check that the application image was built successfully.

1. **Open** the OpenShift Web Console and make sure that the `Developer` perspective is **selected**.

2. **Click** `+Add`.

3. **Select** `Container Images` tile.

4. **Choose** `Image stream tag from internal registry` option.

    - Make sure that the **correct project** is selected.
    - **Select** `cargo-app-source` under _Image Stream_.
    - **Select** `latest` under _Tag_.

5. **Click** `Create` in the bottom bar.

    A pod should be deploying.  From the `Topology` view, **click** on the `cargo-app-source` application.  On the right side, you should see `Pods`, `Builds`, `Services` and `Routes`.

6. Open the application in your browser:

    - **Copy** the Route URL and in your web browser address bar.
    - **Append** `/cargo-tracker`.

#### From a Java archive (.war)

In some cases, it may be preferable to run the Java/Maven build externally. This option is also known as _binary 2 image_.

```sh
oc import-image registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8 --confirm
oc new-build --binary=true --image-stream=eap74-openjdk11-openshift-rhel8 --name=cargo-app
```

A new BuildConfig object should have been created in the namespace

```sh
oc get bc
```

Now that the process exists, we can use a .war file to trigger it

```sh
git clone https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker
cd cargotracker
git checkout db2

mvn clean package
mkdir -p ocp/deployments/
mv target/*.war ocp/deployments/

oc start-build cargo-app --from-dir=./ocp --follow
```

The build should start and create a new Container Image

```sh
oc get builds
oc get images | grep cargo-app
oc get is
oc describe is cargo-app
```

We can use a similar process to dploy and check the application, this time using cargo-app as the image steam name

### External builds

An alternative could be to build the entire image externally, then pushing the image into a Container Image registry accessible from the Openshift cluster.

#### Building images with podman

Under the folder `ocp` **create** a new file named `Containerfile` and add the following content:

```dockerfile
FROM registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8:latest
COPY deployments/*.war $JBOSS_HOME/standalone/deployments/
```

From the source code directory:

```sh
podman login registry.redhat.io
podman build ocp -t cargo-app-podman
```

The image should be built locally, here how you can list all the local images:

```sh
podman images
```

We can test it locally to see if the build procss was fine.

```sh
podman run -p 8080:8080 <imageid>
```

If so, we can push the image to a remote registry.

In th case of the internal registry of the Openshift cluster, we need to first make sure the registry is running and exposed:

```sh
oc get pods -n openshift-image-registry
oc get routes -n openshift-image-registry
```

If there is no route, we can expose the registry by altering the _Operator Custom Resource_ that manages it (we'll look at the Operator technology later).

```sh
oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge
oc get routes -n openshift-image-registry
```

As the internal registry is secured, we also need a user with the appropriate permission to use it.  On Openshift, it corresponds to the registry-editor role.

```sh
oc policy add-role-to-user registry-editor <user_name>
```

These commands will allow Podman to log in to the OpenShift registry:

```sh
export REGISTRY=$(oc registry info)
podman login -u $(oc whoami) -p $(oc whoami --show-token) $REGISTRY
```

Once done, we can push the image to the registry:

> [!WARNING]
> The image publication is going to upload a rather heavy file, for such a reason your network bandwidth could suffer concegestion.

```sh
podman tag localhost/cargo-app-podman:latest $REGISTRY/cargo-tracker-prj/cargo-app-podman:latest

podman push $REGISTRY/cargo-tracker-prj/cargo-app-podman:latest

oc get images | grep cargo-app-podman
oc get is
```

You can deploy and test the application using the same technique as before.

#### Chained builds

The registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8 is a builder image and, as such, contains building tools (such as the ‘assemble’ script) that are not recommended to be present on a production image as it increases the surface of attack.

When performing external docker builds, it's recommended to perform a "chained build" to:

*   first, build an EAP server using the builder image
*   then, copy the built artifacts from the first image to a minimalist runtime image

Here is an example of such a dockerfile:

```dockerfile
FROM registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8 AS builder
COPY deployments/*.war $JBOSS_HOME/standalone/deployments/

FROM registry.redhat.io/jboss-eap-7/eap74-openjdk11-runtime-openshift-rhel8 AS runtime
COPY --from=builder --chown=jboss:root $JBOSS_HOME $JBOSS_HOME
```

Execute the build:

```sh
podman build ocp -t cargo-app-podman-chained -f ocp/Containerfile-chained
```

Publish the image:

```sh
podman tag localhost/cargo-app-podman-chained:latest $REGISTRY/cargo-tracker-prj/cargo-app-podman-chained:latest
podman push $REGISTRY/cargo-tracker-prj/cargo-app-podman-chained:latest
```

### Using BuilderImage directly

Some BuilderImage are directly accssible from th WebConsole, within the Developer perspective.

```
Click +Add
Select “All Services”
Filter out “Builder image” from th left meny
Type “eap” in th search box
```

 You won't see the JBoss EAP 7 BuilderImage exposed, but you should see the JBoss EAP XP images.

JBoss EAP XP is a JBoss EAP server with additional Microprofile libraries.

\<doc jboss="" eap="" xp="">