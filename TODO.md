v0 scope

*   Cargo application
*   MTA

V1 scope

*   Cloud services (database)
*   Microservices migration

Vx scope

*   .NET app (And OCP Virt ?)
*   Improved Spring monolith
*   Quarkus
*   Python, Node
*   Operator-driven database

Backlog v0

*   Limits and requests
*   Centralized logging (Loki)
*   MTA
*   Cargo with exernal database
    *   \+ Secrets and ServiceBindings
*   Jenkins, Tekton and GitOps
    *   Pipeline best practices  → Optimization workshop ?
        *   exernal registry (multi-cluster)
        *   image tag
    *   In case of External registry
        *   Adapt cargo-build
        *   Adapt cargo-deploy
*   Use of the JEE 7 glassfish app on OCP
    *   SCC security on Openshift
    *   ID and permission for volume writing and sharing (fsgroup…)  --cargo-config.md
*   multi-containers pods (init and sidecar)
*   enhance cargo-build.md
    *   \-Dwildfly.statistics-enabled=true
*   \<doc JBoss EAP XP>
*   Add explanation about Image stream security (lookupStrategy)
*   copy to Strangler
*   ocp/\* documentations
*   EAP XP
*   Extras on Developer Console
    *   add pipeline
    *   add jar
*   Network policy exercice