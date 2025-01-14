## Building the Spring-based stangler application

### Build using Openshift S2I binary

One way to create an Image on Openshift is to associate a packaged application, such as a war file, to an Openshift Builder Image.  The Builder Image contains a runtime, such as a Tomcat server, and takes care of making all the steps required to deploy the binary package onto that runtime.

As the Spring application is a Java 11 application running on a Tomcat server, we can use the Red Hat JBoss Web Server 5.8 for OpenJDK 11 to build an Image compatible with the application requirements.

```plaintext
oc login…
oc import-image registry.redhat.io/jboss-webserver-5/jws58-openjdk11-openshift-rhel8:latest --confirm
oc new-build --binary=true --image-stream=jws58-openjdk11-openshift-rhel8 --name=jws-app
mvn package
mkdir ocp ; mkdir ocp/deployments
cp -r target/*.war  ocp/deployments/
oc start-build jws-app --from-dir=./ocp --follow
oc get images | grep jws-app
```

[ocp-builderimage.md](ocp-builderimage.md)

We'll dig into the different ways of deploying an Image later.  For now, let's just use the easiest one.

In the Openshift Web Console, from the Developer perspective:

```plaintext
click +Add
Select Container images
Select Image Stream tag fom internal registry
Select your Project, then find the jws-app Image Stream with the latest tag and click Create
In the Topology view, click on the newly created jws-app.
On the right side, you'll see pointers to he Pods, Builds, Services and Routes.
Click on the Route to open and check the application on your browser.
```

### Build using a Docker/Container file

You can use the following content to create a Containerfile that will build the image externally from the cluster.

```plaintext
FROM registry.redhat.io/jboss-webserver-5/jws58-openjdk11-openshift-rhel8:latest
COPY ocp/deployments/* /opt/jws-5.8/tomcat/webapps/
RUN cd /opt/jws-5.8/tomcat/webapps/ && jar -xvf *.war
ENTRYPOINT /opt/jws-5.8/tomcat/bin/catalina.sh run
```

Then you can use podman to build the image locally and push it to a registry.

```plaintext
podman login registry.redhat.io
podman build . -t jws-app-podman
podman images
```

Check hat the image is valid, which means it instantiates the applicaion correctly.

```plaintext
podman run -it <imageID>
```

`Access http://localhost:8080`

Then push the image to a registry:

```plaintext
podman login oc whoami `oc whoami -t` <registry>
```

The registry must be accessible from outside of the cluster, which means a Route needs to be associated to it.

[ocp-svcroute.md](ocp-svcroute.md)

The registry is a product, and is therefore managed by an Operator.

```plaintext
oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge
```

But this is not enough.

The registry is secured.  We therefore need to add the proper permission to the user running the podman command

```plaintext
oc policy add-role-to-user registry-editor <user_name>
```

TODO: Bad practice to use a non-system-dedicated user !

```plaintext
podman tag localhost:jws-app-podman:latest <registry-route>/<your-project>/jws-app-podman:latest
podman push <registry-route>/<your-project>/jws-app-podman:latest
oc get images | grep podman
```

You can instantiate that new image using the web console again, selecting the Image Stream jws-app-podman.

### Build directly from source code

Instead of building from the packaged war, it's also possible to simply directly pass the source code to the Builder Image.

```plaintext
oc new-build jws58-openjdk11-openshift-rhel8~https://github.com/georgwittberger/strangler-web-components-example --context-dir strangler-monolith --name=jws-app-source
oc get builds
oc get images | grep jws-app-source
```

You can instantiate that new image using the web console again, selecting the Image Stream jws-app-source.

### Build with yaml files

Every single elements of the Openshift platfom have a yaml and json repesentation.

Any command, such as oc new-build or oc-import-image used above end up modifying a yaml /json document.

Therefore, it's also possible to create appropriate yaml descriptors and apply them to the platform configuration.  They can be written from scratch or we can take existing definitions and modify them.

While the "Deployment" is the object representing the instantiation of an Image, the BuildConfig is the object representing the pocess of building an Application Image.

Here's an example of getting such a description in a file.

```plaintext
oc get bc
oc get bc -o yaml jws-app
oc get bc jws-app -o yaml > jws-app-bc.yaml
```

You can use such files to create BuildConfig element, thus to trigger builds on Openshift

```plaintext
cd …
oc apply -f …
oc get builds
oc get images | grep jws-app-yaml
```

Instead of using the command-line, the Web Console can be used to apply definition in yaml.

From any perspective, click on the + sign on the very top right of the Web Console and copy-paste the yaml document there.

### **Build with "new-app"**

[https://access.redhat.com/node/2389381/chapter-7-builds](https://access.redhat.com/node/2389381/chapter-7-builds)

The “oc new-app” command is a shortcut to build and deploy applications.  It's actually the command behind the +Add button of the Openshift Web Console (Developer perspective)

The command can be used to build applications from a variety of sources:

From sourrce code:

```plaintext
oc new-app jws58-openjdk11-openshift-rhel8~https://github.com/georgwittberger/strangler-web-components-example --context-dir strangler-monolith --name=jws-newapp-source
```

From a packaged application file (.war)

```plaintext
oc new-app jws-newapp-binary (name of the BuildConfig element → oc get bc)
```