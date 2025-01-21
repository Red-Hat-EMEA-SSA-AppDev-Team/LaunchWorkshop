## The Cargo Tracker application

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

### The Cargo Tracker EAP app

The Cargo Tracker application also has a slighly modified version that can be run on a JBoss EAP 7.4 server over a java 11 runtime.

The source code is available here, under the jee7-eap7 branch.  

There is a specific tag pointing to the version of the application using an internal database.

[https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker/tree/jee7-eap7](https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker/tree/jee7-eap7)

### Running the Cargo Tracker EAP application locally

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