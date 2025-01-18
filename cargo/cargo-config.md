## Working with data and configuration

An applicationuse can use configuration and parameters.  When those parameters are subject to change between envionments, they have to be externalized .  Indeed, accoding to the Image Immutability Principle, keeping them inside th image will imply that different image will need to be deployed in different environment, and this contradicts the whole nature of Containers.

### Environment variables

One of the main way to externalize configuration outside of the image is via environment variables.

Indeed, the platform can inject environment variables inside the running pod at the moment of the instantiation of the pod, based on the definition of the pod contained in th Deployment object.

Of course, it's up to the application contained inside the image to take those environment variable into account.

```plaintext
System.getenv("CUSTOM_VAR")         # Java ; EAP

@ConfigProperty(name = "custom.var" # Microprofile ; EAP-XP
```

Environment variables can be set

*   From the “Environment" tab of the Deployment object as displayed on the Web Console
*   By modifying the yaml representation of the object

```plaintext
spec:
   containers:
   - name: cargo-container
     image: cargo-app:latest
     imagePullPolicy: Always
     ports:
     - containerPort: 8080
       protocol: TCP
     env:
     - name: CUSTOM_VAR
       value: "myCustomValue"
```

*   From the command-line:

```plaintext
oc set env deployment/cargo-app CUSTOM_VAR=myCustomValue
```

The pod will automatically be restarted.

You can check the prsenc of the environment variable in the Deployment object.

You can also check its prsenc inside the pod by entering the pod terminal and typing:

```plaintext
~ env | grep CUSTOM
```

TODO 

*   EAP XP (standalone-microprofile.xml) → microprofile-config-api
*   QUARKUS ??

### Configuration files

Sometimes, the configuration is not just an environment variable but an entire file (xml, .config, .properties…).

Like environment variables, files can be stored on the platform and be injected to the image at deployment time.  The object at play are the ConfigMaps and Secrets.

```plaintext
cat resouces/config/cargo/app.properties
-----
eap.serverName: myServer
eap.serverVersion: 7.4
```

Let's add this file to the platform

```plaintext
oc create cm cargo-cm --from-file resouces/config/cargo/app.properties
oc get cm 
oc get cm cargo-cm -o yaml
```

You can see a ConfigMap was added to the Namespace by going to the Workloads/ConfigMaps tab of the Administrator perspective.

Again, it's the role of the Deployment object to describe what will be the configuration of the pod after instantiation.  We therefore need to add the created ConfigMap as an lment of the future pod:

```plaintext
spec:
  containers:
  - name: cargo-app-cm
    image: cargo-app:latest
    volumeMounts:
    - mountPath: /tmp
      name: cargo-cm-conf
  volumes:
  - name: cargo-cm-conf
    configMap: 
      name: cargo-cm
      items:
      - key: app.properties
        path: app.properties
```

Apply the new deployment:

```plaintext
oc apply -f resources/config/cargo/cargo-deployment-cm.yaml
```

From the Web Console, check that th file was injected in the Pod terminal:

```plaintext
ls /tmp 
cat /tmp/app.properties
```

This technique can be used to replace the existing configuration files of an application or a product.

### Making environment variables more flexible

Going back to the use of environment variables, having them set directly into the Deployment object is not ideal either as, even though the image will now remain identical across environments, it's the Deployment object that will have to be created differently for each environment.  And as it can contains a lot ofother pieces of pod configuration, there is a risk that the applicaion behaves differently between environment, which breaks the purpose of using Containers.

As a best practice, the value of the envionment variables, when they may vary, should come from an element external to the Deployment object.  

We can rely on a ConfigMap to do that.

The Deployment object will now look like:

```plaintext
spec:
 containers:
 - name: cargo-container
   image: cargo-app:latest
   env: 
   - name: SERVER_NAME 
     valueFrom:
       configMapKeyRef:
         name: cargo-cmenv 
         key: eap.serverName
   - name: SERVER_VERSION
     valueFrom:
       configMapKeyRef:
         name: cargo-cmenv 
         key: eap.serverVersion
```

```plaintext
oc create configmap cargo-cmenv --from-literal=eap.serverName=MyName --from-literal=eap.serverVersion=7.4
oc get cm
oc get cm cargo-cmenv -o yaml
```

```plaintext
oc deploy -f resources/config/cargo/cargo-deployment-cmenv.yaml
```

Go to the terminal of the newly created pod to check the presence of the variables with

```plaintext
env | grep -i server
```

Though the values of the variables may change between environments, the key elements will remain identical.  At the end, only the ConfigMap object will vary from an environment to the other.  ConfigMaps are therfore the core element that represents the context of the application.

#### Environment files

Having a Deployment object with a lot of "ConfigMapKeyRef" entry makes it hard to maintain, and it can happen that some keys change, are added or removed over time.  When we have many moving environment variables, rather than declaring them all one by one in the Deployment object, we can have the platform taking care of this action in a single step.  To achieve that, we need a configuration file with a key-value format, such as a Java properties file.

cat resources/config/cago/env.properties

```plaintext
EAP_SERVER_NAME: cargo
EAP_SERVER_ID: eap_0
EAP_SERVER_VERSION: 7.4
EAP_SERVER_RELEASE: 7.4.0
EAP_APP_NAME: cargo
EAP_APP_VERSION: 1.0
EAP_PLATFORM: container
EAP_RUNTIME: java11
```

```plaintext
oc create cm cargo-cm-env --from-file env.properties
```

The deploymentConfig will now look like this:

```plaintext
spec:
  containers:
  - name: cargo-app-envprop
    image: cargo-app:latest
    envFrom: 
    - configMapRef:
      name: cargo-cm-env
```

```plaintext
oc apply -f resources/config/cargo/cargo-deployment-props.yaml
```

Go to the terminal of the newly created pod to check the presence of the variables with

```plaintext
env | grep -i eap_
```

### Volumes, filesystems and storage

Some applications or products might need to use the filesystem to read and write files. 

This is obviously the case for databases, that use block storage.  That is also the case for the internal Image registry, that uses object storage.  Other applications might also need to use file storage.

At install time, Openshift should integrate with one or more network-based Storage solution.

The platform abstracts by an object called PersistentVolume, which are the responsibility of the administrators.  Developers use PersistentVolumeClaim objects, which maps to PersistentVolume.

[Introduction to Openshift storage](../ocp/ocp-storage.md)

Those objects can be created and/or displayed in the Administrator perspective of the Web Console, under the “Storage” tab.

Again, the Deployment object, responsible for configuring the pod at the moment of its instantiation, will be the object containing the information about what filesystem to mount and where.

 The Deployment object will contain the below configuration.

```plaintext
spec:
  containers:
  - name: cargo-app-pvc
    image: cargo-app:latest
    volumeMounts:
    - mountPath: /mydata
      name: cargo-volume
  volumes:
  - persistentVolumeClaim:
      claimName: cargo-claim
      name: cargo-volume
```

The PersistentVolumeClaim can be create from the Administrator perspective of the web console, under the Storage/PersistentVolumeClaim tab, using the “Create PersistentVolumeClaim” button.

The properties will be:

```plaintext
storage-class: ##default
name: cargo-claim
size: 1GB
mode: filesystem
```

Alternatively, as any Openshift object, it can be created from its yaml definition:

```plaintext
oc apply -f resources/config/cargo/cargo-claim.yaml
```

```plaintext
oc apply -f resources/config/cargo/cargo-deployment-pvc.yaml
```

You can check that the pod has been created with an additional filesystem directory by going to the pod terminal

```plaintext
~ ls /  # directory name = /mydata
```

Let's create a file in that new filesystem.

```plaintext
~ echo “Is it still here ?” &gt; /mydata/file1
```

Then let's restart the pod:

```plaintext
oc delete pod cargo-app-pvc-…
```

From the Web Console terminal, check the filesystem of the new instance of the pod to ensure it was persisted

```plaintext
~ ls /mydata
~ cat /mydata/file1
```

TODO : 

*   ID and permission for volume writing and sharing

To close this part of th workshop, let's now go back to headless services and named pod with the next chapter

[Stateful applications on Openshift](cargo-net.md)