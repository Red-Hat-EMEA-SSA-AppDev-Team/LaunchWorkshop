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

*   Centralized logging (Loki)
*   MTA
*   Cargo with exernal database :: Secrets and ServiceBindings
*   Staged builds with Containerfile
*   Tekton and GitOps
*   Jenkins pipelines
*   External registry
    *   In case of External registry
        *   Adapt cargo-build
        *   Adapt cargo-deploy
*   Use of the JEE 7 glassfish app on OCP
    *   SCC security on Openshift
    *   ID and permission for volume writing and sharing (fsgroup…)  --cargo-config.md
*   multi-containers pods (init and sidecar)
*   enhance cargo-build.md
    *   \-Dwildfly.statistics-enabled=true
*   \<doc jboss="" eap="" xp="">
*   Add explanation about Image stream security (lookupStrategy)
*   Add “Best practices for Platform Engineers" in cargo-db.md
*   copy to Strangler
*   ocp/\* documentations
*   EAP XP
*   Extras on Developer Console
    *   add pipeline
    *   add jar

Optimization workshop

*   Pod placement
    *   Database on the same nodes
    *   Taints and Tolerations for GPU
*   Network policy exercice
*   Multi-staged podman build
*   TSSC