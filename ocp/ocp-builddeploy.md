## Introduction to application build and deployment with Openshift

Openshift runs applications packaged only as Container Images.

The process of “deploying” an application on Openshift means instantiating an existing Image, stored in an Image registry, which can be the one embedded inside the cluster or an external one accessible from the cluster. 

The result of the instantiation of an Image is a running container. 

On the Openshift platform, the instantiation is represented by an element called a Deployment.  

### Generating Images

Products, such as databases, messaging systems… are made available to developers directly as Images.  In theory, they should be backed by an Operator, with is a tool that manages the management and maintenance of products on Openshift.

Applications are fomed by source code.  For applications, an additional Build process needs to be completed in order to turn the souce code into an Image, that could later on be instantiated.

In he next sections, we'e going to look at the different possibilities to build and deploy existing or new applications on Openshift.