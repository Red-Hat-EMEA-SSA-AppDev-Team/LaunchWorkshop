Principle

*   GitOps
*   Declarative appraoch, Ansible state and ConfigAsCode

ArgoCD

*   App & sync
*   Introduction to Kustomize
*   Using Helm
*   pull-request vs pipeline automation

Best practices

*   repository structure
    *   with Kustomize
    *   with Helm
*   multi-clusters deployment (user management, projects…)
*   permissions

Features

*   auto-create namespace
*   prune propagation
*   sync policy
*   out-of-syn only
*   sync waves, blacklist, replicas…

Install fixes:

*   apikeys
*   host
*   oc adm policy add-role-to-user edit system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller -n development