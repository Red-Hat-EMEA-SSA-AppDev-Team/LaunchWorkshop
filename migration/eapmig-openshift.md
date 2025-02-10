## Compatibility with the cloud and containerized environments

#### MTA

The Migration Toolkit for Applications can also be used to assess a migration from traditional runtimes to containers.

[Running MTA to migrate from VM to Containers](mta-openshift.md)

The migration toolkit for application should detect the presence of a call to localhost in the declaration of a variable in the pom.xml

```plaintext
<webapp.graphtraversalurl>
   http://localhost:8080/cargo-tracker/rest/graph-traversal/shortest-path
</webapp.graphtraversalurl>
```

This local call would prevent the application from scaling.  On Openshift, this hostname should be the Openshift Service name.  As it's defined at deployment time, the best option is to make this parameter dynamic using an environment variable:

```plaintext
<webapp.graphtraversalurl>
  ${env.CARGO_ENDPOINT:http://localhost:8080}/cargo-tracker/rest/graph-traversal/shortest-path
</webapp.graphtraversalurl>
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