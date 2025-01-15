## Deploying Applications

In this section, we'll explore ways to turn a container image into a running pod.

We've already seen the first one, which is via the Web Console.

You must have already noticed that instantiating an Image into a running pod wasn't the only action taken by the deployment process, and here is why it's not enough:

[Introduction to network traffic and pod networking on Openshift](../ocp/ocp-svcroute.md)

### Deploying from the Web Console

#### Deploying from the Developer perspective

```plaintext
click +Add
Select Container image and click Create
Select Image Stream Tag from the Internal Registy
Point to the right Image Stream within the right Project
Give the application a proper name and click Create
```

The process will create the appropriate standard Deployment, Service and Route elements that you can explore, and a pod will be instantiated as per the properties inside the Deployment object.

```plaintext
oc get deployments
oc get services
oc get routes
oc get pods
```

#### Deploy from the Administrator perspective

The Developer perspective offers shortcuts to accelerate the development lifecycle.

But each of th above mentioned elements, Deployment, Service, Route, can be created one by one.

For example, in the Administrator perspective, under Workloads then Deployments, you'll see a “Create Deployment” buttton on the top right.  This will open a standard, prefilled Deployment object that you can interact with in its yaml form or through th graphical reprsentation of the object in the UI.

Notice that the yaml view also provides th documentation of the yaml schema.

This is a documentation you can have as well from the command line:

```plaintext
oc explain deployment
oc explain deployment.spec
```

Similarly, you'll find Create Service and Create Route button as well in their respective page, under the Networking tab of the Administrator perspective.

### Deploying from yaml file

As seen, the above methods create a set of Openshift objects (Deployment, Service and Route) which all have a yaml representation for human readability.

```plaintext
oc describe deployments/cargo-app
oc get deployment/cargo-app -o yaml
```

So, another method could be to prepare a set of yaml files and deploy those files manually to the platform.

```plaintext
oc apply -f resources/deploy/cargo/cargo-deployment-yaml.yaml
oc apply -f resources/deploy/cargo/cargo-sevrice-yaml.yaml
oc apply -f resources/deploy/cargo/cargo-route-yaml.yaml
```

Notice that any yaml definition can be applied to the platform via the Web Console by using the ‘+’ sign on the right of the top menu bar, in any perspective.  Additionnaly, the Developer perspective has a “yaml import” entry in the menu of th +Add page.

#### Deploy with templates

Using yaml files instead of the command-line presents the advantage of enabling automation, which we'll explor in a further chapter.

Looking into the details of the files, and taking, for example, the Deployment object, we realize it will be very similar fo a lot of applications, and having to create them again for each application would be a huge burden.  It would be much easier if we could make, for instance, the application name and image name an external variable to fill in at runtime.

The Openshift Templates represent a mechanism to combine multiple objects at once with variabilization.

Take a look at the resources/deploy/cargo/cargo-template.yaml file

The template needs to be "processed" before it can be applied.  Applying the template itself to the cluster won't create the objects defined inside the template but will register the template into the platfom for further use.  The processing of the template, on the other hand, will output the list of objects to be applied to the cluster, once the variable are replaced:

```plaintext
oc process -f resources/deploy/cargo/cargo-template.yaml -p APP_NAME=cargo-app-tmpl -p APP_IMAGE=cargo-app:latest 

oc process -f resources/deploy/cargo/cargo-template.yaml -p APP_NAME=cargo-app-tmpl -p APP_IMAGE=cargo-app:latest | oc create -f -
```

#### Openshift templates

Openshift actually comes with several already prepared templates that can be used to build and deploy applications.

As part of the system, they are stored in the “openshift” namespace.

```plaintext
oc get templates -n openshift
```

You can see for instance that MySQL, Postgres or MariaDB databases can be deployed with already-existing Templates.

Some Templates can be seen on the Web console, in the Developer perspective:

```plaintext
Click +Add
Select Databases
Type "postgres" in the search field
```

You'll see 2 options, and they are both labelled as "Openshift Templates".

If you want to display all the available Templates:

```plaintext
Click +Add
Select “All Services”
Filter out “Templates” on the left menu
```

As Templates basically contain a list of objects, they could be used to create Builds as well.

More info on Openshift Templates can be found here:

[https://docs.openshift.com/container-platform/4.9/openshift_images/using-templates.html](https://docs.openshift.com/container-platform/4.9/openshift_images/using-templates.html)

#### Working with Databases

Having seen that templates can be used to create databases, let's have a look at a "production-ready" vrsion of the tracker application, using an external database to enable horizontal scaling.

[Working with databases](cargo-db.md)

#### Deploy with Helm

Templates can only do basic variable substitutions.  They are files, so doing proper versioning with them is a hard task.

Helm Charts introduce another level of intelligence with conditional logic and support for versioning. 

[Introduction to Helm Charts](../ocp/helm.md)

We can use a Helm Chart to perform deployments

Let's see here how to create a new Helm chart in oder to deploy an application

```plaintext
helm create cargo-from-helm
```

```plaintext
rm -rf cargo-from-helm/templates/*.yaml
rm -rf cargo-from-helm/templates/*.yaml
rm -rf cargo-from-helm/templates/tests
rm -rf cargo-from-helm/templates/NOTES.txt

cp resources/deploy/cargo/cargo-deployment-helm.yaml cargo-from-helm/templates/
cp resources/deploy/cargo/cargo-service-helm.yaml cargo-from-helm/templates/
cp resources/deploy/cargo/cargo-route-helm.yaml cargo-from-helm/templates/

cp resources/deploy/cargo/cargo-deployment-helm.yaml cargo-from-helm/templates/
cp resources/deploy/cargo/cargo-service-helm.yaml cargo-from-helm/templates/
cp resources/deploy/cargo/cargo-route-helm.yaml cargo-from-helm/templates/
```

Edit values.yaml to set a value for the “app.name” and “app.image” parameters.

```plaintext
echo "app:" > cargo-from-helm/values.yaml
echo "  name: cargo-app-helm" >> cargo-from-helm/values.yaml
echo "  image: 'cargo-app:latest'" >> cargo-from-helm/values.yaml
```

```plaintext
cat cargo-from-helm/values.yaml
```

This should give the following output:

```plaintext
app:
  name: cargo-app-helm
  image: cargo-app:latest
```

```plaintext
helm install cargo-from-helm ./cargo-from-helm
helm list
```

Instead of diting th values file, we could also set the parameters directly on the command line

```plaintext
helm install cargo-from-helm ./cargo-from-helm --set app.name=cargo-app-helm --set app.image=cargo-app:latest
```

Let's have a quick look at the versioning and kubernetes integration of Helm:

```plaintext
oc get pods | grep helm

helm upgrade cargo-from-helm ./cargo-from-helm --set app.name=cargo-app-helm-v2 --set app.image=cargo-app:latest

helm list  # notic th revision number

oc get pods | grep helm

helm history cargo-app-helm

helm rollback cargo-from-helm

oc get pods | grep cargo-app-helm

helm history 

helm uninstall cargo-from-helm

oc get pods | grep cargo-app-helm
```

### Back to building applications

We've just seen multiple ways to create deployments from yaml files.  As every Openshift object has a yaml representation we can use to create it, let's go back to the build phase and see more options to creating images. 

[Creating Builds with files](cargo-build-files.md)

### Deploying from the Command line 

#### Deploying with the “create”command

We previously used the “Create Deployment", "Create Service" and "Create Route” buttons on the Administrator perspective of the Web Console. 

Those buttons have their equivalent on the command line:

```plaintext
oc create deployment cargo-app-cli --image cargo-app:latest
oc create service clusterip cargo-app-cli --tcp=8080:8080
oc create route edge cargo-app-cli --service=cargo-app-cli
```

Actually, Services and Routes don't have to be created from scratch:

```plaintext
oc expose deployment cargo-app-cli    # create a Service from a deployment
oc expose service cargo-app-cli       # create a Route from a service
```

#### Deploying with the new-app command

We also previously used the Developer perspective of the Web Console to create deployment artifacts from an existing Image.  This action also has its equivalent on the command line with the “new-app” command that can take many forms:

*   Deploy from an existing (external) Image

```plaintext
oc new-app <registry-route>/<namespace>/cargo-newapp:latest
```

*   Deploy from an existing (internal) Image using the ImageStream reference

```plaintext
oc new-app cargo-newapp:latest
```

*   Deploy fom a template registerd in Openshift

```plaintext
oc new-app mysql-ephemeral
oc get pods | grep mysql
```

*   Deploy from a template file

```plaintext
oc new-app -f resources/deploy/cargo/cargo-template.yaml 
```

### Back to building applications

We've just seen multiple ways to create deployments with some commands from the command lines.  

Let's go back again to the build phase to see yet other options to creating images. 

[Creating Builds with files](cargo-build-cli.md)

### Deploying with an Operator

[Introduction to Openshift Operators](../ocp/ocp-operators.md)

Operators are made to manage Products rather than Applications.  They are management objects that automate Day2 operations, allowing administrators to perform transparent install, update, upgrade, scale up, scale down operations while guaranteeing consistency, backups duing topology migrations.

In the particular case of EAP, Openshift comes with an associated Operator.

From the Administrator perspective of the Web Console:

```plaintext
Go to the Operators tab on th left
Select "Installed Operators"
Select "Jboss EAP"
Go to the WildflyServer tab
Click on "Create WildflyServer"
If not yet the case, switch to the Form view
```

Then

```plaintext
Give th instance the name “cargo-app-op”
Set 1 replicas
Use "cargo-app:latest" as the Application Image
Then click "Create"
```

Check that the application has been deployed

```plaintext
oc get wildflyserver
```

We can verify that a pod is now running

```plaintext
oc get pods | grep cargo-app-op
```

Which we can access with the Route link, appending /cargo-tracker to the shown URL

```plaintext
oc get route | grep cargo-app-op
```

We can see that, though the esult seems to be the same, things seem to have been done much differently.

a. Similarly to th EAP Helm Chart and the EAP Template, healthchecks have been automatically configured

[Monitoring the Cargo Tracker application](cargo-monitor.md)

b. Multiple Services have been created

    There is a Service for the application, an admin one, and a headless one that does not have any IP

```plaintext
oc get services  | grep cargo-app-op
```

[Introduction to network traffic and pod networking on Openshift](../ocp/ocp-svcroute.md)

c. The pod is not named wihth a random string but with a fixed name, ending with a 0

```plaintext
oc get pods | grep cargo-app | grep Running
```

[Introduction to Statefulness on Openshift](ocp/ocp-net.md) 

d. Volumes have been configured

[Managing application data and application configuration](cargo-config.md)