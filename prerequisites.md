Local

*   Java 8
*   Java 11
*   Java 17
*   podman
*   oc and tkn (can be installed on the fly)

Openshift

*   Access by dev and ops
*   Namespaces and users created
*   Generic user with registry-editor right
*   One cluster-administrator user (for Red Hat)
*   One platform engineer user (acces to EAP, Pipelines and Gitops CRDs + namesapce creation)
*   EAP Operator installed
*   Pipelines and GitOps operators installed (+GitOps fixes)

Us

*   An open environment with MTA installed
*   An open environment with Gitea setup
    *   One repo for each user (named as user + pswd = 'openshift')
*   Create a gitea server for GitOps with one repo per user → adapt argocd Apps

Choices

*   Using the internal or an external registry ?
*   Using existing Prometheus User Workload monitoring, and it is installed ?
*   Using Loki (requires object storage by a supported provided, e.g. [Red Hat OpenShift Data Foundation](https://www.redhat.com/en/technologies/cloud-computing/openshift-data-foundation) or [MinIO](https://min.io/)), or an external solution ?
*   Using Tempo (requires object storage by a supported provided, e.g. [Red Hat OpenShift Data Foundation](https://www.redhat.com/en/technologies/cloud-computing/openshift-data-foundation) or [MinIO](https://min.io/)), or an external solution ?
*   Storage class allowing the on-demand creation of RWO PV ?