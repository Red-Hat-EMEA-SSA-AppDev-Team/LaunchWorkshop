## Migration from JBoss EAP 7 to JBoss EAP 8

### Introduction

The Cargo Tracker application is stored in the following GIT repository:

```plaintext
https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker/
```

The  `jee7-eap7` branch is the code of the application that can be run on Jboss EAP 7.4 over Java 11.

The following page describes the migration toward JBoss EAP 8, which requires Jakarta EE 10 on Java 17+.

The result is contained in the `jee10-eap10` branch.

### MTA

To accelerate the migration, we'll use a Red Hat tool named Migration Toolkit for Applications.

[Running MTA to migrate from EAP 7 to EAP 8](mta-eap8.md)

### Updates that can be automated

The Migration Toolkit for Application tool offers a set of automated changes:

*   Jakarta imports
*   Jakarta xml
*   EAP 8 xml

#### Jakarta imports

Unfortunately [not all `javax` package are part of Jakarta](https://github.com/jakartaee/platform/blob/main/namespace/unaffected-packages.adoc), so a massive find-and-replace on the source might be harmful.

The tools was able to find and fix all the import declaration in Java code.

Example of java changes:

```java
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
```

The tool also add some required dependencies in the `pom.xml` file: 

```plaintext
jakarta.annotation-api, jakarta.inject-api, jakarta.jms-api, jakarta.json-api, jakarta.persistence-api, jakarta.transaction-api, jakarta.websocket-api.
```

#### Jakarta xml

Some deployment descriptors contains also references to `javax` names.

The tool updated `persistence.xml` changing the version and changing the names of the properties.

#### EAP 8 xml

The tool updated the files: `web.xml` and `test-web.xml`

### Manual updates

> [!TIP]  
> A full scan for the `javax` and `javaee` strings in the source highlights other possible changes.

#### Jakarta

To correctly compile the project, other **Jakarta dependencies** had to be introduced manually: 

```plaintext
jakarta.ejb-api, jakarta.enterprise.cdi-api, jakarta.websocket-client-api, jakarta.faces-api, jakarta.batch-api, jakarta.xml.bind-api, jakarta.ws.rs-api, jakarta.validation-api
```

To avoid specifing the version for each dependencies and to make sure the versions are all supported, the Red Hat bom was introduced:

```xml
<properties>
        <version.server.bom>8.0.5.GA-redhat-00005</version.server.bom>
</properties>

<dependencymanagement>
    <dependencies>
        <dependency>
            <groupid>org.jboss.bom</groupid>
            <artifactid>jboss-eap-ee-with-tools</artifactid>
            <version>${version.server.bom}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencymanagement>
```

Some annotations have **references** to old javax classes in the properties. 

In the project were found 5 instances related to the messaging driven beans, e.g.

```java
@MessageDriven(activationConfig = {
    @ActivationConfigProperty(propertyName = "destinationType", propertyValue = "jakarta.jms.Queue"),
    @ActivationConfigProperty(propertyName = "destinationLookup", propertyValue = "java:app/jms/HandlingEventRegistrationAttemptQueue") 
})
public class HandlingEventRegistrationAttemptConsumer implements MessageListener {
```

`**web.xml**` deploy descriptor contained other `javax` references, e.g.

```xml
<context-param>
    <param-name>jakarta.faces.PROJECT_STAGE</param-name>
    <param-value>Development</param-value>
</context-param>
<jms-destination>
    <name>java:app/jms/CargoHandledQueue</name>
    <interface-name>jakarta.jms.Queue</interface-name>
    <destination-name>CargoHandledQueue</destination-name>
</jms-destination>
```

**JEE Batch APIs** relies on their own deploy descriptor which requires updated:

```xml
<!--?xml version="1.0" encoding="UTF-8"?-->
<job id="EventFilesProcessorJob" xmlns="https://jakarta.ee/xml/ns/jakartaee" version="2.0">
```

**CDI Bean** deployment descriptor needs to be updated manually:

```xml
<!--?xml version="1.0" encoding="UTF-8"?-->
<beans xmlns="https://jakarta.ee/xml/ns/jakartaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemalocation="https://jakarta.ee/xml/ns/jakartaee
                           https://jakarta.ee/xml/ns/jakartaee/beans_3_0.xsd" version="3.0" bean-discovery-mode="all">
</beans>
```

**Java Server Faces** deployment descriptor needs to be updated manually:

```xml
<faces-config version="4.0" xmlns="https://jakarta.ee/xml/ns/jakartaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemalocation="https://jakarta.ee/xml/ns/jakartaee https://jakarta.ee/xml/ns/jakartaee/web-facesconfig_4_0.xsd">
       <application>
```

\> \[!WARNING\]  
\> The `javax.sql.DataSource` class **is not part** of Jakarta and for such reason MUST NOT be touched!

#### Primefaces

A dependency that required a special care was **Primefaces**, this popular UI framework was originally at version `8.0`, but since it relies on Java Server Faces which are part of Jakarta Enterprise APIs, it needs to be updated in order to work correctly. Fortunately, this framework is actively developed and provides a variant that works with JEE 10 starting from version `12` with classifier `jakarta`:

```xml
<dependency>
    <groupid>org.primefaces</groupid>
    <artifactid>primefaces</artifactid>
    <version>12.0.0</version>
    <classifier>jakarta</classifier>
</dependency>
```

The version change had another side-effect: the previously used UI theme `omega` was retired. So, the following change in `web.xml` was necessary:

```xml
<context-param>
    <param-name>primefaces.THEME</param-name>
    <param-value>saga</param-value>
</context-param>
```

\> \[!NOTE\]  
\> Due to the new theme, some other changes have been made to the css content. These changes are only meant to slightly improve the aesthetics, so they can be ignored.

#### Dropping legacy code

Reviewing the code, the `@PrivateOwned` annotation was found:

*   It is an extension to JPA, specific of the _EclipseLink_ implementation.
*   It has no equivalent in JEE 10 or in _Hibernate_ which is the JPA implementation of JBoss EAP.
*   Looking at the \[documentation\]\[2\], it can be considered a sort of extra constraint but has no functional side effects.

Given the above considerations, it has been removed from the code.

\[2\]: [https://eclipse.dev/eclipselink/documentation/4.0/jpa/extensions/jpa-extensions.html#privateowned](https://eclipse.dev/eclipselink/documentation/4.0/jpa/extensions/jpa-extensions.html#privateowned)

## JBoss EAP 8 on Openshift

Let's first look at the particularity of this [new version of EAP on Openshift](../ocp/ocp-eap8.md).

Now let's see [how to deploy EAP 8 on Openshift](../cargo/cargo-eap8.md)
