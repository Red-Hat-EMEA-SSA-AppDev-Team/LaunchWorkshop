Local

*   Java 8
*   Java 11
*   Java 17
*   podman
*   oc and tkn (can be installed on the fly)

Openshift

*   Access to the OCP cluster by dev and ops from a networking point of view
*   Users created 
    *   3 namespaces per user (cargo-dev\<user>, cargo-test-\<user> and cargo-prod-\<user>)
*   Generic system user with registry-editor right
*   One cluster-admin user for Red Hat, with the aggreement of the customer, or a cluster-admin person in the room
*   One platform engineer user account (with acces to CRDs such as EAP, Pipelines and Gitops + ability to create namespaces)
*   EAP Operator installed
*   Pipelines and GitOps operators installed (+ArgoCD access fixes)

Us

*   An open environment with MTA installed
*   An open environment with Gitea setup with Route access
    *   2 repos per user (named as user + pswd = 'openshift')
        *   Repo for kustomize (/gitops-\<user>)
        *   Repo for Helm (/helm-\<user>) 
            *   “pipeline” subdirectory with empty helm chart for the gitops pipeline example

Choices

*   Using the internal or an external registry ?
*   Using existing Prometheus User Workload monitoring, and it is installed ?
*   Using Loki (requires object storage by a supported provided, e.g. [Red Hat OpenShift Data Foundation](https://www.redhat.com/en/technologies/cloud-computing/openshift-data-foundation) or [MinIO](https://min.io/)), or an external solution ?
*   Using Tempo (requires object storage by a supported provided, e.g. [Red Hat OpenShift Data Foundation](https://www.redhat.com/en/technologies/cloud-computing/openshift-data-foundation) or [MinIO](https://min.io/)), or an external solution ?
*   Storage class allowing the on-demand creation of RWO PV ?