## Pipelines automation

### Automating Builds

Openshift ships with a Pipeline server based on the open-source cloud-native pipeline model: Tekton.

[Introduction to Openshift Pipelines](../ocp/ocp-pipelines.md)

#### Creating pipelines with the UI

Openshift provides a graphical pipeline editor.

From the left panel of the administrator's perspective of the Web Console:

```plaintext
Click Pipelines, then Pipelines, then Create/Pipelines
```

Select the task "git-clone" and fill it with:

Select the task “maven” and fill it with:

Select the task "oc" to perform a binary build and fill it with:

As an alternative, you can also select the task “buildah” to perform a Docker build

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

#### Deploying with Pipelines

#### Using a GitOps approach for deployments

#### Release management with Pipelines

#### Release management with Pipelines and GitOps