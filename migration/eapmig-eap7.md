# Migration from Glassfish Payara to JBoss EAP 7

The Cargo Tracker application is stored in the following GIT repository:

https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker/

The  “javaee7” branch contains the original JEE7 application, prepared to run on a Glassfish server over a Java 8 runtime.

The jee7-eap7 branch contains a slightly modified version of the application, that can run on a Jboss EAP 7.4 server over a Java 11 runtime.

JBoss EAP v7.4 support Jakarta EE v8, however Jakarta EE 8 remains backwards compatible with other Jakarta EE versions as well.
In few words, it is still possible to deploy Java EE v7 application.

Here is the list of the changes perfomed to achieve this migration.

## Java upgrated to version 11

Just `pom.xml` configuration:

```xml
<maven.compiler.source>11</maven.compiler.source>
<maven.compiler.target>11</maven.compiler.target>
```

## Ephemeral DB changed from Derby to H2

Reference in `web.xml`:

```xml
<data-source>
    <name>java:app/jdbc/CargoTrackerDatabase</name>
    <class-name>org.h2.jdbcx.JdbcDataSource</class-name>
    <url>jdbc:h2:mem:test;DB_CLOSE_DELAY=-1</url>
    <user>sa</user>
    <password>sa</password>
    <max-pool-size>32</max-pool-size>
    <min-pool-size>2</min-pool-size>
</data-source>
```

*   H2 runtime dependency declared via src/main/webapp/WEB-INF/jboss-deployment-structure.xml

## Removing JMS adapter

The <resource-adapter> element links the JMS destination (queue or topic) to a specific Resource Adapter implementation. This allows the application server to know which adapter to use when managing connections and resources for that destination.

When the application server has only one implementation available, it's possible to remove it and avoid static reference to a specific resource adapter which is not available in all application server implementation.

Removed:

```xml
<resource-adapter>jmsra</resource-adapter>
```

## MOXy Removal

MOXy: MOXy is EclipseLink's JAXB implementation, which also provides JSON binding capabilities. It was commonly used in Java EE 7 for JSON processing.

JSON-B: JSON-B (Java API for JSON Binding) was introduced in Java EE 8 and is part of Jakarta EE 8. It provides a standardized way to convert Java objects to JSON and vice versa.

For such reason, it's safe to remove the class JsonMoxyConfigurationContextResolver and his references.
The class RestConfiguration now extends javax.ws.rs.core.Application and the constructor can be deleted.

## Persistence layer change

At runtime, the application server has raised the following exception: `javax.persistence.PersistenceException: org.hibernate.HibernateException: Don't change the reference to a collection with delete-orphan enabled`

JBoss EAP persistence layer (Hibernate) is more strict on this side a simple workaround is to relax the constraint in the class: `org.eclipse.cargotracker.domain.model.cargo.Itinerary` deleting `orphanRemoval = true` from the following annotation:

```java
@OneToMany(cascade = CascadeType.ALL)
```

Another runtime issue 
Enabling lazy loading out of transactional session: src/main/resources/META-INF/persistence.xml
```xml
<property name="hibernate.enable_lazy_load_no_trans" value="true"/>
```

## DataSource

Configuration to run on PostgreSQL.

*   Adding Mapping internal datasource reference to global configured at EAP level
    *   Configure in EAP a datasource with the following jndi: java:/jdbc/CargoTrackerDatabase
    *   If you remove the configuration file: src/main/webapp/WEB-INF/jboss-web.xml  
        EAP will use the default in memory DB
*   Updated the DB initialization strategy to drop before creating tables

## Payara upgrade

*   Payara maven configuration was updated: it can run on the same code base and jdk 11
