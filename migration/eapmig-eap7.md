## Migration from Glassfish Payara to JBoss EAP 7

The Cargo Tracker application is stored in the following GIT repository:

```plaintext
https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker/
```

The  “javaee7” branch contains the original JEE7 application, prepared to run on a Glassfish server over a Java 8 runtime.

The jee7-eap7 branch contains a slightly modified version of the application, that can run on a Jboss EAP 7.4 server over a Java 11 runtime.

JBoss EAP v7.4 support Jakarta EE v8, however Jakarta EE 8 remains backwards compatible with other Jakarta EE versions as well.  
In few words, it is still possible to deploy Java EE v7 applications.

Here is the list of the changes perfomed to achieve the migration from Payara to EAP7.

### Java upgrade to version 11

Just `pom.xml` configuration:

```xml
<maven.compiler.source>11</maven.compiler.source>
<maven.compiler.target>11</maven.compiler.target>
```

### Internal Database changed from Derby to H2

Running a Derby database inside EAP7 will show some difficulties.  However it's possible to simply change it toward an H2 database with no effect on the application.

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

*   H2 runtime dependency declared via a new file: src/main/webapp/WEB-INF/jboss-deployment-structure.xml

```plaintext
<jboss-deployment-structure>
   <deployment>
       <dependencies>
           <!-- <module name="org.apache.derby" /> -->
           <module name="com.h2database.h2">
       </module></dependencies>
   </deployment>
</jboss-deployment-structure>
```

### Removing JMS adapter

The element links the JMS destination (queue or topic) to a specific Resource Adapter implementation. This allows the application server to know which adapter to use when managing connections and resources for that destination.

With EAP, when the application server holds only one configuration of a resource adapter (named “default”), it's possible to just remove any reference to it from the application and thus avoid static reference to a specific resource that might not be available or portable to other application servers.

Removed:

```xml
<resource-adapter>jmsra</resource-adapter>
```

### MOXy Removal

MOXy: MOXy is EclipseLink's JAXB implementation, which also provides JSON binding capabilities. It was commonly used in Java EE 7 for JSON processing.

JSON-B: JSON-B (Java API for JSON Binding) was introduced in Java EE 8 and is part of Jakarta EE 8. It provides a standardized way to convert Java objects to JSON and vice versa.

For such reason, it's safe to remove the class JsonMoxyConfigurationContextResolver and his references.  
The class RestConfiguration now extends javax.ws.rs.core.Application and the constructor can be deleted.

### Persistence layer change

At runtime, the application server will raise the following exception: 

```plaintext
javax.persistence.PersistenceException: org.hibernate.HibernateException: Don't change the reference to a collection with delete-orphan enabled
```

JBoss EAP persistence layer (Hibernate) is more strict on this side a simple workaround is to relax the constraint in the class: `org.eclipse.cargotracker.domain.model.cargo.Itinerary` deleting `orphanRemoval = true` from the following annotation:

```java
@OneToMany(cascade = CascadeType.ALL)
```

Another runtime issue will show up due to lazy-loading of classes outside of transactions   
Enabling lazy loading out of transactional session: src/main/resources/META-INF/persistence.xml

```xml
<property name="hibernate.enable_lazy_load_no_trans" value="true">
```