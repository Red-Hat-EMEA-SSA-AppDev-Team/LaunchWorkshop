## State support on Openshift

[Introduction to Statefulness on Openshift](ocp/ocp-net.md)

Statefulness is a topic more related to Products than to Applications, as indeed applications developed for a Containerized environment should be stateless, thus highly scalable.

As EAP is considered a Product, the application deployed with the EAP Operator has taken quite a different shape then the ones created before.  

For instance, we can't find a trace of its Deployment, though a pod is running:

```plaintext
oc get wildflyserver
oc get deployment | grep cargo-app-op
```

The reason is that the pod hasn't been instantiated by a Deployment, which holds a stateless application, but by a StatefulSet object

```plaintext
oc get statefulset
```

### Exploring StatefulSets

Let's pick up one of the cargo application previously deployed with a Deployment object and let's pay attention to th pod name:

```plaintext
oc get pods  # show pod cargo-app-<xyz>
```

Let's now restart that pod:

```plaintext
oc delete pod cargo-app-<xyz>
oc get pod cargo-app-<xyz>  # this name does not exist anymore
oc get pods                 # shows another name
```

Let's now create another Cargo instance from an unmanaged StatefulSet and do the same

```plaintext
oc apply -f resources/scale/cargo/cargo-stateful.yaml
```

```plaintext
oc get pods  #cargo-app-state-0
oc delete pod cago-app-state-0
oc get pod cago-app-state-0    # the pod is still there
```

You can see that the pod has been recreated with a the exact same name.

### Scaling up applications on Openshift

The Deployment object manages the scalability of the pods it instantiates via the “replicas” variable, which can be modified in the yaml description of the Deployment object or in the Deployment details page of the Web Console.

Applications can also be scaled via the command line.

```plaintext
oc scale --replicas=2 deployment/cargo-app
oc get pods
```

There are now 2 independent pods.

Notice that the scaled Cargo Tracker application will not work in the version where it uses an internal embedded database as the 2 copies will have a different database while the Openshift Service object will load-balance the requests over the 2 copies.

Let's do the same with the Stateful application, which holds the scalability in the exact same way.

```plaintext
oc scale --replicas=2 statefulset/cargo-app-state
oc get pods
```

We can see that the pods are created in an order with an index, and the name can be predicted in advance.

If we scale down the statefulset, the destruction of the pods will always occur in the exact reverse order of their creation.

```plaintext
oc scale --replicas=1 statefulset/cargo-app-state
oc get pods
```

Because the name of the pod can be predicted in advance, another application could talk directly to each pods, without going through the Service object, and that's what the headless service will do:

```plaintext
oc apply -f resources/scale/cargo/cargo-headless.yaml
```

From the Terminal of another pod, such as the first cargo-app one, let's try to reach those 2 pods.

```plaintext
oc scale --replicas=2 statefulset/cargo-app-state

curl cargo-app-state-0.cargo-app-state-headless:9990/health
curl cargo-app-state-1.cargo-app-state-headless:9990/health
```

To make sure that each call falls on the target pod, repeat the operation after having scaled down the application

```plaintext
oc scale --replicas=1 statefulset/cargo-app-state

~ curl cargo-app-state-0.cargo-app-state-headless:9990/health 
~ curl cargo-app-state-1.cargo-app-state-headless:9990/health #unkown host
```

Let's go back to the other statefulset we had, named cargo-app-op.

Let's try to change the number of replicas of this application:

```plaintext
oc scale --replicas=0 statefulset/cargo-app-op
oc get pods
```

The pod is back and doesn't want to disappear.  The reason is that the Operator is managing and maintaining the StatefulSet object based on its own configuration.

The only way to modify this StatefulSet is to tell the Operator object to do it.

With the Administrator perspective of the Web Console, 

```plaintext
Go to Operators > Installed Operators
Select the Jboss EAP Operator
Go to the Wildfly Server tab
Go to the yaml definition of the Wildfly server 
Change the “replicas” number to 0
```

```plaintext
oc get pods
```

The StatefulSet has been recreated with a replicas value of 0, which triggered the scale-down operations and the pod is now gone.