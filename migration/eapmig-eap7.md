The Cargo Tracker application is stored in the following GIT repository:

https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker/

The  “javaee7” branch contains the original JEE7 application, prepared to run on a Glassfish server ove a Java8 runtime.

The jee7-eap7 branch contains a slightly modified version of the application, that can run on a Jboss EAP 7.4 server over a java 11 runtime.

Here is the list of the changes perfomed to achieve this migration:

*   pom.xml java compilation 11
*   Ephemeral DB changed from Derby to H2: src/main/webapp/WEB-INF/web.xml 
*   H2 runtime dependency declared via src/main/webapp/WEB-INF/jboss-deployment-structure.xml
*   JMS resource adapter dependency removed (useless in JBoss context) \<resource-adapter>jmsra\</resource-adapter> for web.xml
*   JAX-RS Configuration classes: removed
*   Removal of annotation: orphanRemoval = true - it caused javax.persistence.PersistenceException: org.hibernate.HibernateException: Don't change the reference to a collection with delete-orphan enabled
    *   Code would require a redesign, but it’s not in the current scope.
*   Enabling lazy loading out of transactional session: src/main/resources/META-INF/persistence.xml
*   Payara maven configuration was updated: it can run on the same code base and jdk 11
*   Adding Mapping internal datasource reference to global configured at EAP level
    *   Configure in EAP a datasource with the following jndi: java:/jdbc/CargoTrackerDatabase
    *   If you remove the configuration file: src/main/webapp/WEB-INF/jboss-web.xml  
        EAP will use the default in memory DB
*   Podman kube play provided to run postgres in a container.
*   Updated the DB initialization strategy to drop before creating tables