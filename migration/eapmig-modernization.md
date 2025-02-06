## Modernizing the Cargo Tracker legacy application

### Externalizing the Datasource

The application uses an internal database, making it unsuitable for scaling.

Here we'll do an exercice to perform the changes required to externalize the database, and we'll switched from the H2 in memory technology to a persistent PostgreSQL one.

The web.xml contains the declaration of a datasource that needs to be found by JNDi internally:

```plaintext
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

We'll modify it by a reference instead of a plain declaration:

```plaintext
 <resource-ref>
 <description>Reference to production DB</description>
 <res-ref-name>java:app/jdbc/CargoTrackerDatabase</res-ref-name>
 <res-type>javax.sql.DataSource</res-type>
 <res-auth>Container</res-auth>
</resource-ref>
```

The reference will look for a declaration in the jboss-web.xml file, that is used by the EAP application server.

```plaintext
<jboss-web>
   <resource-ref>
       <res-ref-name>java:app/jdbc/CargoTrackerDatabase</res-ref-name>
       <jndi-name>java:/jdbc/CargoTrackerDatabase</jndi-name>
   </resource-ref>
</jboss-web>
```

Finally, we need a proper declaration of the datasource in the EAP server's configuration file.  On Openshift, this file is named standalone-openshift.xml with EAP 7 and was renamed to the original standalone.xml with the EAP 8 images).

```plaintext
<subsystem xmlns="urn:jboss:domain:datasources:6.0">
    <datasources>
        <drivers>
            <driver name="postgresql" module="org.postgresql">
                <xa-datasource-class>org.postgresql.xa.PGXADataSource</xa-datasource-class>
            </driver>
         </drivers>
         <datasource jndi-name="java:/jdbc/CargoTrackerDatabase" pool-name="postgresDS" enabled="true" jta="false" use-java-context="true" use-ccm="false">
             <connection-url>jdbc:postgresql://${env.CARGO_POSTGRES_HOST}:${env.CARGO_POSTGRES_PORT}/${env.CARGO_POSTGRES_NAME}</connection-url>
             <driver-class>org.postgresql.Driver</driver-class>
             <driver>postgresql</driver>
             <pool>
                 <min-pool-size>2</min-pool-size>
                 <max-pool-size>20</max-pool-size>
             </pool>
             <security>
                 <user-name>${env.CARGO_POSTGRES_USERNAME}</user-name>
                 <password>${env.CARGO_POSTGRES_PASSWORD}</password>
             </security>
           </datasource>
     </datasources>
</subsystem>
```

For this to work best, we also need to updated the Database initialization strategy to drop before creating tables.

For more information on configuring the server at build time and deploying the application on top of it, see:

[Working with external databases](../cargo/cargo-db.md)

### Externalizing ActiveMQ

### Microservices

### Compatibility with cloud and containerized environments

#### MTA

The Migration Toolkit for Applications can also be used to assess a migration from traditional runtimes to containers.

[Running MTA to migrate from VM to Containers](mta-openshift.md)

The migration toolkit for application should detect the presence of a call to localhost in the declaration of a variable in the pom.xml

```plaintext
<webapp.graphTraversalUrl>
   http://localhost:8080/cargo-tracker/rest/graph-traversal/shortest-path
</webapp.graphTraversalUrl>
```

This local call would prevent the application from scaling.  On Openshift, this hostname should be the Openshift Service name.  As it's defined at deployment time, the best option is to make this parameter dynamic using an environment variable:

```plaintext
<webapp.graphTraversalUrl>
  ${env.CARGO_ENDPOINT:http://localhost:8080}/cargo-tracker/rest/graph-traversal/shortest-path
</webapp.graphTraversalUrl>
```

This variable will be substituted at compile time in the web.xml file:

```plaintext
 <env-entry>
   <env-entry-name>java:app/configuration/GraphTraversalUrl</env-entry-name>
   <env-entry-type>java.lang.String</env-entry-type>
   <env-entry-value>${webapp.graphTraversalUrl}</env-entry-value>
</env-entry>
```

The actual value will become :

```plaintext
<env-entry-value>${env.CARGO_ENDPOINT:http://localhost:8080}/cargo-tracker/rest/graph-traversal/shortest-path</env-entry-value>
```

The default configuration of EAP 8 does not allow variable substitution at runtime.  This has to be set explicitely, ideally in the dockerfile that builds the image.

Create a file named extensions.cli with the following:

```plaintext
embed-server --std-out=echo  --server-config=standalone.xml
/subsystem=ee:write-attribute(name="spec-descriptor-property-replacement",value=true)
```

Copy the file to the image under the /tmp folder within the Dockerfile, then make it execute the command:

```plaintext
COPY extensions.cli /tmp
RUN $JBOSS_HOME/bin/jboss-cli.sh -f /tmp/extensions.cli
```