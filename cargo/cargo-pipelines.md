## Pipelines automation

Openshift ships with a supported version of the Open Source Tekton framework that allows creating cloud-native pipelines.

[Introduction to Openshift Pipelines](../ocp/ocp-pipelines.md)

### Creating a Build pipeline

Any kind of build we've performed so far can be automated with a pipeline.  

For this workshop we'll just use one of them.  Let's for example automate a build that performs:

*   git clone
*   mvn package
*   generate a dockerfile
*   Execute that dockerfile

#### Preparing the pipeline

Go the the PersistentVolumeClaim menu of the Administrator's pesrpective of the Web Console and create a new PVC with, for example, the name: “source-code-pvc” and 1GB of size.

The Tekton "s2i binary" task is not supported by Red Hat because it performs the generation of a dockerfile followed by its execution using buildah, which requires priviledged permissions which are not allowed on Openshift.  There is however a supported version of a buildah build task.Task customization is a important aspect of Tekton pipelines.  So, what we're going to do is to create a simplified version of the tekton's s2i task that only generate the dockerfile and we'll pass that dockerfile to the next, supported buildah task. 

```plaintext
oc apply -f $/resources/automate/cargo/pipeline/cargo-s2i-task.yaml
```

*   Buildah will need to provide authentication credentials to be able to push the built image to the registry.  For that, it accepts a docker-config entry that can be linked to a workspace.  This entry is supposed to be a config.json file with registry credentials information.  With podman on linux, this can be generated with:

```plaintext
podman login -u $USER -p $TOKEN default-route-openshift-image-registry.apps.$OPENSHIFT_DOMAIN
cp /run/user/…/containers/auth.json /tmp/config.json
oc create secret generic pipeline-registry-auth --from-file=config.json=/tmp/config.json
```

#### Creating the pipeline

Openshift provides a graphical pipeline editor.

From the left panel of the administrator's perspective of the Web Console, click "Pipelines".  Then, click on the Pipelines submenu and, on the top right “Create Pipeline”.

Start by adding a workspace, at the botton of the editor, and name is for instance “source-code”.

Add a task, and select the task named "git-clone".  Fill it with:

*   url : [https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker](https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker)
*   revision: jee7-eap7

Then select the “source-code” workspace for the ‘output’ directory, which basically will be the directory where the "git clone" command complete.

Hover over the git-clone task, and click on the '+' sign on its right, then select the new task box.

Add the task named “maven” and link its source directory to the 'source-code' workspace.  The ‘source’ directory is where the “mvn” command will happen, and here we're telling the task to execute it from where the source code was extracted.

On the right side of the workflow, continue by adding the cargo-s2i task, and link its workspace to the source-code workspace.

This task creates a dockerfile to be used by the next task: the Buildah task.  This means that the name of the file needs to be known by the Buildah task.

One common way to pass information from one task to another is by using the “task results” fields.  If you explore the yaml of the cargo-s2i task, you'll see that it writes into a result field named DOCKER\_FILENAME.  The results fields are visible at the pipeline level so their value can be passed from task to task.  

Add a buildah task on the right of the workflow.

Link  its “source” directory to the "source-code" workspace and its “dockerconfig” directory to the "pipeline-registry-auth" Secret.

Set the dockerfile parameter to

```plaintext
 $(tasks.cargo-s2i.results.DOCKER_FILENAME)
```

For the target image, use :

```plaintext
default-route-openshift-image-registry.apps.$OPENSHIFT_DOMAIN/<namespace-dev>/cargo-pipeline:latest
```

Save the pipeline.

#### Executing the pipeline

Start the pipeline manually by clicking on ‘Action’ / ‘Start’ in the top right menu.

The first time the pipeline starts, the workspaces need to be defined:

*   For the “source-code” workspace, select PersistentVolumeClaim and use the ‘source-code’ PersistentVolumeClaim we've prepared
*   For the "docker-config" workspace select Secret and chose the pipeline-registry-auth Secret we prepared

Once done, any other execution of the pipeline will reuse those workspace definitions and they won't have to be re-entered again.

Explore the interface where you can follow the pipeline, see its logs, see individual tasks and their logs.

### Creating a Deployment pipeline

So far the pipeline automatically builds an image, which is equivalent to executing a BuildConfig.

Let's continue and let's automate the deployment phase for the ‘development’ environment

Any of the deployment mechanisms we've experienced can be automated by the pipeline.

Again, we'll just take one, and let's create the deployment artifact for the deployment environment with an “oc new-app”.

From the Pipelines menu, open the top right panel and click on “Edit Pipeline”.

Add the ‘openshift-client' task after the buidah task.

In the command, type: 

```plaintext
oc new-app cargo-pipeline:latest -n <namespace-dev>
```

### Promoting applications

So far, the pipeline automate the Inner Loop.

It's a good practice to use the “latest” tag in the image name in this loop, as it accelerate the cycle.

Once the testing is completed in the “development” environment, the application can be promoted to the next environment, for example “test”.

Let's harcode v1 here, but in theory the target version would be a parameter of the pipeline, and should directly come from a git tag.

**Pipeline permission**

The "Inner loop" pipeline was created in the “development” environment and created artifacts in that environment so it didn't require any adjustment in the permissions.  The promotion step involves at least 2 environments, and the “test” one is remote to the pipeline.  Openshift  requires that explicit permissions are set for Service Account to perfom actions in remote namespaces.

```plaintext
oc adm policy add-role-to-user edit system:serviceaccount:cargo-pipeline:pipeline -n <namespace-test>
```

#### Promotion pipeline

Create a new pipeline, named cargo-promote.

Add an “openshift-client” task and set the command to :

```plaintext
oc tag <namespace-dev>/cargo-pipeline:latest <namespace-test>/cargo-pipeline:v1
```

Now that the image exists in the “test” environment, the pipeline can deploy it there, for instance using again the "oc new-app" command.

Add another “openshift-client” task and set the command to : 

```plaintext
oc new-app cargo-pipeline:v1 -n <namespace-test>
```

Run the pipeline and check that pods are created in the target namespace:

```plaintext
oc get pods -n <namespace-test>
```

## Creating pipelines with Yaml

Of course, as any other Openshift object, Pipelines are represented by yaml files that can be deployed from the command line:

```plaintext
oc apply -f cargo-pipeline.yaml
```

## Triggering Pipeline

### Triggering pipelines from files

Pipeline can be triggered by applying a yaml file containing the pipelineRun object.  The PipelineRun object is similar to the Pipeline one, but contains details about how to link the workspaces as well as execution status.

```plaintext
oc apply -f cargo-pipelinerun.yaml
```

### Managing pipelines from the command line

You can use the ‘tkn’ command line tool to manage pipelines (accessible from the Web Console in the “help” section on the top right bar):

```plaintext
tkn pipeline list
tkn pipeline describe cargo-pipeline
```

To trigger the pipeline from the command-line:

```plaintext
tkn start cargo-pipeline
tkn pipelinerun list
tkn pipelinerun logs cargo-pipeline -a
```

### Tekton triggers

The execution of a pipeline can be triggered automatically by a webhook using Pipeline triggers.

Depending on the trigger type and source code repository technology, different variables are sent by the remote source code repository in the json payload.  They can be used as parameters within the pipeline, using the syntax: $(tt.params.xyz).

Adding a trigger results in the creation of an Event Listener that you can see in the pipeline details page.  For example: http://el-event-listener-…

This is the URL to place in the webhook configuration of the source code repository.

Also, event listeners can be checked from the command line :

```plaintext
oc get eventlistener
oc get pods | grep ^el
```

#### Creating triggers

Click on the cargo-pipeline pipeline, go to the Actions menu and select “Add Trigger”.

Link the 2 workspaces.  Select a trigger type such as Git push.

You could now for example modify the “git-clone” task, and for example replace the “revision” field with `$(tt.params.parameter.git-revision)`

Click on the cargo-promote pipeline, go to the Actions menu and select “Add Trigger”.

Select a trigger type such as Git push.  You can use the created URL in the webhook configuration of the SCM corresponding to the creation of a new tag and use the git-revision field as a dynamic parameter for the target image version.

## Declarative approach

For now our pipeline execute actions in a procedural way.

Let's now see a better approach to managing the deployment of applications

#### [Using a GitOps approach for deployments](cargo-gitops.md)