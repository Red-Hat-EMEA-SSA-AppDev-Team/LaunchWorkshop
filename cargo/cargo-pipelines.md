## Pipelines automation

Openshift ships with a supported version of the Open Source Tekton framework that allows creating cloud-native pipelines.

[Introduction to Openshift Pipelines](../ocp/ocp-pipelines.md)

### Creating a Build pipeline

#### Binary builds with pipelines

We're going to create a pipeline consisting in 3 tasks, to perform a binary S2I build:  

*   git clone
*   mvn package
*   buildah build

Let's first add a new BuildConfig to distinghish the pipeline builds.

```plaintext
oc new-build --binary=true --image-stream=eap74-openjdk11-openshift-rhel8 --name=cargo-app-pipeline
```

Openshift provides a graphical pipeline editor.

From the left panel of the administrator's perspective of the Web Console, click "Pipelines".  Then, click on the Pipelines submenu and, on the top right “Create Pipeline”.

Start by adding a workspace, at the botton of the editor, and name is for instance “source-code”.

Add a task, and select the one named "git-clone".  Fill it with:

*   url : [https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker](https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker)
*   revision: jee-eap7

Then select the “source-code” workspace for the ‘output’ directory, which basically will be the directory where the "git clone" command complete.

Hover over the git-clone task, and click on the '+' sign on its right, then select the new task box.

Add the task named “maven” and link its source directory to the 'source-code' workspace.  The ‘source’ directory is where the “mvn” command will happen, and here we're telling the task to execute it from where the source code was extracted.

\---- ADD Buildah ---

Save the pipeline.

Go the the PersistentVolumeClaim menu of the Administrator's pesrpective of the Web Console and create a new PVC with, for example, the name: “source-code-pvc” and 1GB of size.

Go back to the pipeline and manually start it by going to ‘Action’ / ‘Start’ on its top left menu.

For the “source-code” workspace, select PersistentVolumeClaim and use the PVC you just created.

Explore the interface where you can follow the pipeline, see its logs and individual tasks.

#### Deploying with Pipelines

So far the pipeline only performed the build of the image, which is equivalent to a BuildConfig.

Let's continue to automate the entire lifecycle, starting with the deployment

#### Promoting applications with pipelines

#### Creating pipelines with Yaml

Of course, as any other Openshift object, Pipelines are represented by yaml files that can be deployed from the command line:

```plaintext
oc apply -f pipeline-build.yaml
```

Pipeline can be triggered by applying a yaml file containing the pipelineRun object.

```plaintext
oc apply -f pipelinerun-build.yaml
```

#### Managing pipelines from the command line

You can use the ‘tkn’ command line tool to manage pipelines:

```plaintext
tkn pipeline list
tkn pipeline  describe mypipeline
```

To trigger the pipeline from the command-line:

```plaintext
tkn start mypipeline
tkn pipelinerun list
tkn pipelinerun logs mypipelinerun -a
```

#### Using a GitOps approach for deployments

#### Release management with Pipelines

#### Release management with Pipelines and GitOps