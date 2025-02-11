## Introduction to application build and deployment with Openshift

Openshift runs applications packaged only as Container Images.

The process of “deploying” an application on Openshift means instantiating an existing Image, stored in an Image registry, which can be the one embedded inside the cluster or an external one accessible from the cluster. 

The result of the instantiation of an Image is a running container. 

On the Openshift platform, the instantiation is represented by an element called a Deployment.  

Here a brief recap of the resources involved:

*   **Image:** This is the foundation.  It's a read-only template containing your application code, runtime, system tools, system libraries, and settings.  Think of it like a blueprint for your application.  Images can be built using Docker, Podman or Buildah.

*   **Pod:** A pod is the smallest deployable unit in OpenShift. It can contain one or more containers (which use the image you built) that share storage and network resources.  Essentially, a pod is a running instance of your application.

*   **Deployment:**  Deployments manage the desired state of your application. They describe how many replicas of your pod should be running, how updates should be rolled out (e.g., rolling updates), and how to handle rollbacks.  Deployments ensure that the specified number of pods are running and healthy.

*   **Config Maps:** ConfigMaps store configuration data as key-value pairs.  This decouples configuration from your application code, making it easier to manage and change settings without rebuilding your image.  Your application can then access these configuration values at runtime.

*   **Secrets:** Secrets are similar to ConfigMaps but are specifically designed to store sensitive information like passwords, API keys, and certificates.  Secrets are encrypted at rest and provide a more secure way to manage sensitive data.

In short, you build an *Image*, define how it should run in a *Pod*, manage the desired number of pods and updates with a *Deployment*, and externalize configuration using *ConfigMaps* and sensitive data with *Secrets*.  These elements work together to bring your application to life in OpenShift.

### Existing Images

Products, such as databases, messaging systems… are made available to developers directly as Images.

They are often complex application with many dependencies and require a special care, in such circumstances the software vendor can offer a specialized **Operator** that automates the management:

*   **Extends OpenShift:** Operators add new capabilities to OpenShift, allowing it to understand and manage specific applications beyond the basics.

*   **Automates Management:** They handle tasks like installation, configuration, updates, scaling, and even dealing with failures, all automatically. This reduces manual effort and ensures consistency.

*   **Encodes Expertise:** Operators capture the knowledge of how to run a complex application and turn it into code. This means you don't need to be an expert yourself to manage it.

*   **Lifecycle Management:** They oversee the entire lifecycle of an application, from deployment to upgrades and eventual decommissioning.

Essentially, Operators simplify the operation of complex applications on OpenShift by automating the tasks that would normally require a skilled administrator. They make it easier to deploy and manage sophisticated software, freeing you to focus on other things.

### Generating Images

Developers can build and upload their images in the registry.

However, delegating the build process to OpenShift offers several advantages:

*   **Automation:** Builds are automated, triggered by code changes or schedules, streamlining the development pipeline.
*   **Centralized Management:** OpenShift provides a single platform to manage all builds, improving tracking and control.
*   **Reproducibility:** Builds are consistent and reproducible, ensuring the same output from the same source.
*   **Integration:** Builds are tightly integrated with other OpenShift features like deployments and image streams.
*   **Security:** OpenShift offers secure build environments and manages image vulnerabilities.
*   **Simplified Workflow:**  S2I builds, in particular, simplify the process for developers, reducing the need for deep Docker knowledge.

In the next sections, we'e going to look at the different possibilities to build and deploy existing or new applications on Openshift.