Principle

*   App & sync
*   Introduction to Kustomize
*   Using Helm

Best practices

*   repository structure 
    *   with Kustomize
    *   with Helm
*   multi-clusters deployment (user management, projects…)
*   permissions
*   pull-request vs automation

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