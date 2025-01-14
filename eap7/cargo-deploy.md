In this section, we'll explore several ways to turn a container image into a running pod.

We've already seen the first one.

### Deploy an Image from the Web Console

From the Develope perspective:

```plaintext
click +Add
Select Container image and click Create
Select Image Stream Tag from the Internal Registy
Point to the right Image Stream within the right Project and click Create
```

### Deploy from a Yaml file

In the same way as we could use a BuildConfig in its yaml representation to create a Build, we can use a yaml representation of a Deployment to instantiate an existing Image.

To look at an existing definition:

```plaintext
oc get deployments
oc get deployment/cargo-app -o yaml
```

Using a similar file, you can create another deployment definition.

```plaintext
cat resources/deploy/eap/deployment-yaml.yaml
oc apply -f resources/deploy/deployment-yaml.yaml
```

From the Web Console

The Image has been instantiated

```plaintext
oc get pods | grep cargo-app-deploy
```

However, i's not enough for the application to be usable.

[ocp-svcroutes.md](ocp-svcroutes.md)  

#### Explore Service

Services can also of course be created by applying the associated yaml description.

```plaintext
cd …
oc apply -f …
```

On the Web Console, under the Services element of the Networking tab of the Administrator perspective lies a Create Service button that generates a piece of yaml that can easily be directly edited there.

Services can also be generated automatically from a Deployment object.

```plaintext
oc get services
oc apply -f cargo-app-dc-expose.yaml
oc expose dc cargo-app-dc-expose
oc get services
```

#### Use NetworkPolicies

#### Openshift Route

Routes can also of course be created by applying the associated yaml description.

```plaintext
cd …
oc apply -f …
```

On the Web Console, under the Routes element of the Networking tab of the Administrator perspective lies a Create Route button that generates a piece of yaml that can easily be directly edited there.

Routes can also be generated automatically from a Service object.

```plaintext
oc get routes
oc apply -f cargo-app-svc-expose.yaml
oc expose svc cargo-app-svc-expose
oc get routes
```

TODO: adapt ports…. via oc expose

### Using NodePort

### Deploy with Templates

[https://docs.openshift.com/container-platform/4.9/openshift_images/using-templates.html](https://docs.openshift.com/container-platform/4.9/openshift_images/using-templates.html)

As we saw it, the complete setup of an application can require multiple objects; for instance a Deployment, a Service and a Route.  In some cases, the setup of an application can slightly differ from one envionment to the other when the application goes from Development to Production.

Openshift Templates are mechanisms that allow the application of one or multiple objects (from their yaml description) at the same time, with possible variable substitutions.

Explore the Template file that compiles a Deployment, Service and Route object.

```plaintext
cd …
cat …
```

In this templaete, for the sake of the example, the name and image name of the applications have been turned into variable.  It means this single template file can be used to setup any application.

The “oc process" command execute variable substitution in a template and generates the required objects

```plaintext
oc process -f template.yaml -p NAME=<name> -p IMAGE=<img>
```

The resulting output is a set of yaml descriptors that can be applied to the platform.

```plaintext
oc process -f template.yaml | oc create -f -
```

Applying the template document without pocessing it will not create any element on the platform.

oc apply -f template.yaml

Instead, the template iself, as an object, will be stored on the cluster.

The cluster actually comes with several already prepared templates that can be used to build and deploy applications.

They are stored in the “openshift” namespace.

```plaintext
oc get template -n openshift | grep postgre
```

Some databases, like the Postgres one, can be deployed with a Template.

Actually, when you go o he Developer perspective of the Web Console, click on +Add, select databases and search fo Postgre, you'll see 2 options, and you could see they are both labels as "Openshift Templates".

You can see all the Templates available by selecting +Add, then All Services and filter out the Templates on the left.

Templates are basically a list of objects with some extra intelligence, so we've just discovered another way of building an application, which is to use a Template that conains BuildConfig and ImageStreams objects, to complete the list of options left over at the Helm Chart.

For EAP, such a Template is already provided by the platform:

```plaintext
oc get template -n openshift | grep eap74
oc get template -n openshift eap74-basic-s2i -o yaml
```

You can look at the template parameters then:

```plaintext
oc process eap74-basic-s2i -pSOURCE_REPOSITORY_REF=https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker#jee7-eap7 -p APPLICATION_NAME=cargo-app-template | oc apply -f -
```

Of couse this can be done on the Web Console by selecting the `eap74-basic-s2i&nbsp;`  template and clicking Create

### Deploy with Helm Charts

We saw the use of an existing Helm Chart to build an EAP application.

Let's see here how to create a new Helm chart in oder to deploy an application

```plaintext
helm create cargo-app-deploy-from-helm
cp …/*.yaml cargo-app-deploy-from-helm/templates
```

Edit values.yaml to add the “name” and “image” parameters that are variables of the deployment, service and route yaml objects that we copied into the Chart.

```plaintext
app:
  name: 
  image: 
```

```plaintext
helm upgrade
```

### Deploy with new-app

We saw “oc new-app” in use as a shortcut to execute builds and deployments.  Let's explore it further for the use cases of deployments:

#### Deployment directly from an existing (external) Image

```plaintext
oc new-app <registry-route>/<namespace>/cargo-app:latest
```

#### Deployment from an existing (internal) Image using the ImageStream reference

```plaintext
oc new-app jws-app:latest
```

#### Combining new-app with templates

`plaintext oc new-app -f template.yaml oc new-app <template-name>`