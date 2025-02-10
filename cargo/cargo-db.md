## Working with Databases

[Introduction to databases management on Openshift](../ocp/ocp-db.md)

The Glassfish's Cargo Tracker application is a monolith that uses an internal Derby database.

We've already modified it to use an internal DB2 database to make it compatible with the EAP server

But this remains a constraint because it prevents the application from scaling, which means the application will enventually suffer from load issues.

Thus, we again modified the application to externalize the database.  

Basically:

*   we modified the “web.xml” file to use a referenced datasource instead of a inline-declared datasource.
*   we declared the reference in the jboss-web.xml to allow the EAP server to make the link between the reference and the internal JNDI name
*   We added the datasource to the EAP7 image with the appropriate JNDI name

For this workshop, we'll first use a simple self-managed Postgres database.

[Using the Operator-driven Crunchy Postgres for Kubernetes](cargo-crunchy.md)

### Creating the Postgresql databases

Red Hat ships several supported databases images: Postgres, MariaDB, MySQL…

#### Creating a database from the image on the command line

We've seen that the oc new-app command could be used to launch deployment processes directly from an image.  

The image is configured to use a few environment variables.

```plaintext
oc get images | grep postgres
oc new-app registry.redhat.io/rhel9/postgresql-15@sha256:<imageid> -e POSTGRESQL_USER=username -e POSTGRESQL_PASSWORD=password -e POSTGRESQL_DATABASE=cargodb-test
oc get pods
```

Of course, databases need persistent block storage.

If you explore their Deployment object, you'll see there is no reference to a PVC.  This means this instance of the database is ephemeral, and data will be lost on Pod restart.

A template is also provided for the creation of Postgres databases

#### Creating a database from a template on the command line

```plaintext
oc get templates -n openshift | grep ^postgresql
```

You can see that 2 Templates are there: one for an ephemeral and one for a persistent database.

Let's create a persistent database:

```plaintext
oc process postgresql-persistent -n openshift -p DATABASE_SERVICE_NAME=cargo-postgres -p POSTGRESQL_USER=username -p POSTGRESQL_PASSWORD=password -p POSTGRESQL_DATABASE=cargodb | oc create -f -
```

#### Customize the EAP server from the source code to use an external database

The source code of the application that contains proper web.xml and jboss-web.xml to use an external database is stored in the "postgres" branch.

But the EAP server needs to be customized with the resources needed to load the database driver.

This type of customization is dependent on the runtime.

On EAP 7.4, this is facilitated by the Openshift Builder image.  

This builde image will:

*   automatically detect a /configuration folder in the source code and copy anything from there to the EAP server's configuration directory
*   automatically detect a /modules folder in the source code and copy any driver placed there to the EAP server's dependency directory

With the appropriate files placed in the source code, we therefore only have to trigger a new build:

```plaintext
oc new-app eap74-openjdk11-openshift-rhel8~https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker#postgres --name=cargo-newapp-postgres -e CARGO_POSTGRES_HOST=cargo-postgres -e CARGO_POSTGRES_PORT=5432 -e CARGO_POSTGRES_NAME=cargodb -e CARGO_POSTGRES_USERNAME=username -e CARGO_POSTGRES_PASSWORD=password
```

To verify that this new instance uses the external database, go to the database DeploymentConfig object and scale the database down to 0.  You'll see that the Administration page of the Cargo Tracker app now shows errors, and you can find the database-related errors in the new Cargo Tracker pod's logs.

To restore the state of the application, scale the database back to 1 and restart the Cargo Tracker application.

\<best practices="" for="" platform="" engineers="">

#### Scaling the Cargo Tracker application

Though the database itself, being a relational database, cannot scale (cf. CAP theorem), now that the database is externalized, the “front-end” part of the Cargo Tracker application can scale horizontally to support an increasing load (as long as the database allows for the number of sessions that are required by the front-end).

You can make some test with the oc scale command:

```plaintext
oc scale --replicas=3 deployment/cargo-app-postgres
```

#### Using Secrets

Applications usually rely on environment variables to store informations related to accessing external system.  We've already seen that ConfigMaps are the best practice to move the configuration outside of the application.  But ConfigMap contains plain-text information.  When it's about storing credentials, the best practice is to use Secrets, which simply are encrypted ConfigMap.  Secrets have a type.  They are 3 types of Secrets:

*   TLS : they are Secrets to store TLS certificates
*   docker-registry: They are secrets to store dockerconfig files
*   generic: to store anything else, which, like ConfigMap, can be any file or any key-value pair

Like ConfigMaps, Secrets can be created from the WebConsole in both the Developers and Administrators perspectives, or from the command line.  

In our case:

```plaintext
oc create secret generic cargo-secret --from-literal=CARGO_POSTGRES_HOST=cargo-postgres --from-literal=CARGO_POSTGRES_PORT=5432 --from-literal=CARGO_POSTGRES_NAME=cargodb --from-literal=CARGO_POSTGRES_USERNAME=username --from-literal=CARGO_POSTGRES_PASSWORD=password
```

Let's create another image from the Postgres baseline:

```plaintext
oc new-build eap74-openjdk11-openshift-rhel8~https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker#postgres --name=cargo-app-postgres
```

You can then deploy a Deployment object similar to the one used for the example of the ConfigMap, where we would simply have replaced ConfigMapKeyRef by SecretKeyRef.

```plaintext
oc apply -f resources/config/cargo/cargo-deployment-secret.yaml
```