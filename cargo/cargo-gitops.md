## Using a GitOps approach

[Introduction to Openshift GitOps and ArgoCD](../ocp/ocp-gitops.md)

### Deploying Cargo Tracker with ArgoCD the GitOps way

We've installed Openshift GitOps to showcase the principle of GitOps.

Let's reuse some of the yaml files already used in the workshop.  

They will be:

*   cargo-app-bc-source  : a BuildConfig that builds from a GitHub repository
*   cargo-is-source  : The ImageStream built by the BuildConfig
*   cargo-deployment-yaml  : a Deployment object that instantiates the ImageStream
*   cargo-service-yaml  : The Service object that points to the instantiated pod
*   cargo-route-yaml  : The Route object that exposes the Service to the external world

We're going to simulate the deployment of the Cargo Tracker application in 2 different namespaces: one represneting the development environment (Inner Loop) and one representing a production-ready one (Outer loop).

A Kustomize-ready example has been deploy to the Git repo:

```plaintext
<url_without_user_suffix>/gitops-<user>
```

#### Configuring ArgoCD Applications

The platform engineer would prepare the synchronization between a specific source code and a specific namespace using the ArgoCD Application object.

Let's first complete the setup of ArgoCD:

*   Create the namespaces for the users

```plaintext
oc process -f resources/automate/cargo/argo/argo-namespaces.yaml -p USER=<user> | oc apply -f -
```

*   Allow ArgoCD to edit those namespaces

```plaintext
oc process -f resources/automate/cargo/argo/argo-roles.yaml -p USER=<user> | oc apply -f -
```

Alternatively:

```plaintext
oc new-project cargo-dev-<user>
oc new-project cargo-prod-<user>
```

```plaintext
oc adm policy add-role-to-user edit system:serviceaccount:openshift-gitops:openshift-
gitops-argocd-application-controller -n cargo-dev-<user>
oc adm policy add-role-to-user edit system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller -n cargo-prod-<user>
```

_**ArgoCD  Appliciations using the ArgoCD UI**_

Open the ArgoCD UI: https://openshift-gitops-server-openshift-gitops.apps.\<ocp\_domain>

On the main page, click on the "+NewApp"

Provide the following information

```plaintext
Application Name: cargo-dev-<user>
Project Name: default

SOURCE repository URL: <url_without_user_suffix>/gitops-<user>
SOURCE path: <user>/dev/overlays

DESTINATION cluster URL:https://kubernetes.default.svc
DESTINATION namespace: cargo-dev-<user>
```

Do the same for the second “environment”

```plaintext
Application Name: cargo-prod-<user>
Project Name: default

SOURCE repository URL: <url_without_user_suffix>/gitops-<user>
SOURCE path: <user>/prod/overlays

DESTINATION cluster URL:https://kubernetes.default.svc
DESTINATION namespace: cargo-prod-<user>
```

_**ArgoCD  Applications using the Operator**_

From the Administrative perspective of the WebConsole:

```plaintext
Go to Installed Operators, then Openshift Gitops
Make sure you are in the openshift-gitops namespace
Select the Application tab and click "Create"
```

Provide the following instructions to the form:

```plaintext
name: cargo-dev-<user>
destination:
  namespace: cargo-dev-<user>
  server: https://kubernetes.default.svc
project: default
source:
  path: <user>/dev/overlays
  repoURL: <url_without_user_suffix>
```

Do the same for the second “environment”.

```plaintext
name: cargo-prod-<user>
destination:
  namespace: cargo-prod-<user>
  server: https://kubernetes.default.svc
project: default
source:
  path: <user>/prod/overlays
  repoURL: <url_without_user_suffix>
```

The Application will appear on the ArgoCD UI.

_**ArgoCD  Applications using a yaml file**_

```plaintext
oc process -f resources/automate/cargo/argo/argo-apps.yaml -p USER=user1 | oc apply -f -
```

#### Operating deployments with ArgoCD

Now is the turn of the Developers, to push changes to the Gith repository.

```plaintext
cd /tmp
git clone <url_without_user_suffix>/gitops-<user>
cd <user>
cp $/resources/automate/cargo/kustomize/dev/base/cargo-*.yaml  dev/base/
git add . --all
git commit -m "add files to dev"
git push <user> openshift
```

Go to the ArgoCD UI, select your cargo-dev-\<user> Application and click on ‘refresh’.

The Display should discover the objects automatically.

Unless you created the Argo Application from the yaml, “auto sync” should be disabled so that all resources will remain out of sync.  You can sync the entire application at once, or sync the resources one by one.

Look into the Openshift namespace at the same time to see the creation of the resources within the namespace.

Synchronize at least the BuildConfig and the ImageStream, as they are needed for the next step.

You can monitor the synchronization status in the UI or via the command line:

```plaintext
oc get applications.argoproj.io -n openshift-gitops
```

#### Promoting the Cargo applications

We can now promote the application to a “production” environment.

In production, the deployment would however not use the “latest” tag of the image but will expect a specific version, such as “v1”.  An extra step is therefore needed in order to promote the application correctly:

```plaintext
oc tag cargo-dev-<user>/cargo-app-gitops:latest cargo-dev-<user>/cargo-app-gitops:v1
oc tag cargo-dev-<user>/cargo-app-gitops:v1 cargo-prod-<user>/cargo-app-gitops:v1
```

Observe that an ImageStream and a tag was created in the “production” namespace:

```plaintext
oc get is -n cargo-prod-<user>
```

Once the tag exists, we can deploy the application in this “production” environment.

Of course, in this environment, we don't need the build artifacts

```plaintext
cp $/resources/automate/cargo/kustomize/prod/base/cargo-deployment-*.yaml  prod/base/
cp $/resources/automate/cargo/kustomize/prod/base/cargo-service*.yaml  prod/base/
cp $/resources/automate/cargo/kustomize/prod/base/cargo-route*.yaml  prod/base/
git add prod/base --all
git commit -m "promote files to prod"
git push <user> openshift
```

Refresh the Application in the ArgoCD UI.  ArgoCD should discover the 3 new resources.

Proceed with the synchronization of the Deployment and look at the pods created in the cargo-prod-\<user> namespace.

```plaintext
oc get pods -n cargo-prod-<user>
```

You'll see that there are 2 pods created.  This is what the Kustomize overlays feature is for.  It allows to modify parts of a yaml from an environment to another.

Try to change the number of replicas within the Deployment object of Openshift.  

In the ArgoCD UI, you'll see that ArgoCD marks the Deployment as out-of-sync, as it differs from what exist in the source.  If you sync it again from ArgoCD, the number of pods will come back to 2.  When auto-sync is enabled, the state will be continuously restored by ArgoCD.

This can be a problem in a real production or load testing environment, as you might want to use an autoscaler to dynamically adjust the number of replicas based on the workload.

Thge ArgoCD  Application can be configured to ignore this parameter

```plaintext
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  labels:
    app.kubernetes.io/name: cargo-prod-${USER}
    name: cargo-prod-${USER}
    namespace: openshift-gitops
spec: 
  ...
  ignoreDifferences:
  - group: "apps"
    kind: "Deployment"
    jsonPointers:
    - /spec/replicas
  syncPolicy:
    syncOptions:
    - RespectIgnoreDifferences=true
```

#### Using Helm

If you are more familiar with Helm, you can use Helm instead of Kustomize as the packaging format for the files in the Git source of ArgoCD.

You can find an example already prepared with a dev helm chart in the Git repo:

```plaintext
<url_without_user_suffix>/helm-<user>
```

To synchronize this one:

*   Remove the ArgoCD application, either from the ArgoCD UI, the Openshift Operator,  or the command line:

```plaintext
oc delete applications.argoproj.io cargo-dev-<user> -n openshift-gitops
```

*   delete the objects created by ArgoCD

```plaintext
oc delete all -l app=cargo-app-gitops
```

Create an ArgoCD application in the ArgoCD UI, now specifying “dev/cargo-dev-helm” as the path directory within the source code repository.

You'll see that the number of pod created is now 3, which comes from the Helm's Values file.

## Full Application lifecycle

We proceeded with "GIT push" commands.  When GitOps is operated manually, it's highly recommended, for security reasons, to proceed with pull-requests.

But the lifecycle can also be fully automated with a pipeline making modification in a GIT repository that ArgoCD will synchronize.

Ideally the deployment artifacts would be prepared and stored as part of the source code, and the pipeline will propagate those yaml files from one directory to another within the AgoCD GIT repository, setting some of the parameters, such as the image tag and the number of replicas, dynamically.

Let's reuse the \<url\_without\_user\_suffix>/helm-\<user> repository.

Using the ArgoCD UI, create an ArgoCD Application that synchronize a “pipeline/cargo-gitops-dev-pipeline” subdirectory within this repository with the cargo-test-\<user> environment.

We're going to create a pipeline with the following tasks:

*   git-clone : clone the source code of the application in a subdirectory of the workspace
*   git-clone :  clone the gitops helm repository in a subdirectory of the workspace
*   generic shell : this is a custom task that we'll create, and that will be used to copy openshift deployment files from the source code to the gitops repository
*   git-cli : to perform a commit and push in the gitops repository

Let's first create our generic shell task:

```plaintext
oc apply -f $/resources/automate/cargo/pipeline/shell-task.yaml
```

Let's also create a new PVC, named "source-code-gitops-pvc" to materialize the workspace.

The "git push" action will require authentication.  We can use the “basic auth” directory of the task, that expects a .git-credentials file.

We can create the Secret with the following command, then update the username, password and hostname fields accordingly with the UI:

```plaintext
oc apply -f $/resources/automate/cargo/pipeline/git-basic-auth-secret.yaml
```

Let's then create the pipeline.

We can begin by creating the 2 workspaces: source-code-gitops and git-basic-auth-secret

For the first git-clone task, we'll link the source-code-gitops workspace to the "output" folder and set:

```plaintext
url = https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker
revision = jee7-eap7
subdirectory = app
```

For the second git-clone task, we'll link the source-code-gitops workspace to the “output” folder and set:

```plaintext
url = <url_without_user_suffix>/helm-<user>
subdirectory = gitops
```

For the shell task, we'll link the source-code-gitops workspace to the “source” folder and use the command : 

```plaintext
cp workspace/source/app/openshift/*.yaml workspace/source/gitops/pipeline/cargo-gitops-pipeline-helm/templates/
```

Then, for the git-cli, we'll link the source-code-gitops workspace to the “source” folder as well as the git-basic-auth-secret Secret to the “basic-auth” folder.

Then, for the GIT SCRIPT parameter:

```plaintext
cd /workspace/source/gitops && git add pipeline --all && git commit -m "pipeline commit" && git push origin HEAD:main
```

DONT FORGET TO SET THE “DELETE EXISTING” PARAMETER TO FALSE.

Let's start the pipeline, linking the source-code-gitops-pvc and the git-push-secret Secret to the workspaces.

Check that the pipeline wrote to the Git repository, that the ArgoCD server picked up the changes, and that pods have been created in the cargo-test-\<user> namespace.

```plaintext
oc get pods -n cargo-test-<user> 
```