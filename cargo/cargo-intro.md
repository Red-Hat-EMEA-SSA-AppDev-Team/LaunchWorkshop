## The orginal Cargo Tracker application

The Cargo Tracker application is a JEE7 legacy monolith that runs on a Glassfish and requires a java 8 runtime.

The source code is available here, under the javaee7 branch:

[https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker/tree/javaee7](https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker/tree/jee7-eap7)

### Running the Cargo Tracker application locally

```plaintext
git clone https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker
cd cargotracker
git checkout javaee7

javac -version
sudo update-alternatives --config javac     # select java 8
javac -version                              # ensure java 8 is selected
echo $JAVA_HOME                             # should point to a Java 8 untime

mvn clean package
mvn cargo:run

Then, open a web bowser to http://localhost:8080/cargo-tracker
```

### Running the Cargo Tracker application in a container

```plaintext
FROM docker.io/payara/server-full:6.2023.12
COPY target/*.war ?
```

## The Cargo Tracker application on EAP 7

The Cargo Tracker application also has a slighly modified version that can be run on a JBoss EAP 7.4 server over a java 11 runtime.

The source code is available here, under the jee7-eap7 branch.  

There is a specific tag pointing to the version of the application using an internal database.

[https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker/tree/jee7-eap7](https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker/tree/jee7-eap7)

You can explore the migration steps [here](../migration/eapmig-eap7.md).

### Running the Cargo Tracker EAP 7 application locally

```plaintext
git clone https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker
cd cargotracker
git checkout db2

javac -version
sudo update-alternatives --config javac     # select java 11
javac -version                              # ensure java 11 is selected
echo $JAVA_HOME                             # should point to a Java 11 untime

mvn clean package

If you have a JBoss EAP 7.4 server installed locally, just copy the .war file from the ./target folder to the EAP 7.4 "/deployment" folder.

Then, open a web bowser to http://localhost:8080/cargo-tracker
```

### Running the Cargo Tracker EAP 7 application on Openshift

Let's start [exploring the Openshift's Build and Deployment process for the CargoTracker application.](cargo-build.md)

### Note

#### EAP 8 migration

This workshop also contains a section exploring how to migrate the Cargo Tracker application from EAP 7.4 to EAP 8.0.

#### Payara upgrade

Along the migration journey to EAP7 then EAP8, the Payara server, through the maven configuration, was updated to make the Cargo Tracker application back-compatible with Payara.

```plaintext
Cargo Tracker EE7  → Payara 4.1.2.181 (jdk 8)
Cargo Tracker EAP7 → Payara 5.2022.5 (jdk 11)
Cargo Tracker EAP8 → Payara 6.2023.12
```

#### Microservices and modernization

This workshop also contains a section to explore the modernization of legacy applications (like database and messaging system migration) as well as a microservices breakdown strategy.

[Modernizing legacy JEE workload](../migration/eapmig-modernition.md)