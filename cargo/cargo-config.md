Applications use configuration and parameters.  When those parameters are subject to change between envionments, they have to be externalized from the image, otherwise a different image will have to be used in different environment, which contradicts the whole idea of using Containers.

### Environment variables

One of the main way to externalize the configuration is via Environment variables.

They are referenced as part of the Deployment object.

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
         - name: HTTP_PORT
           value: "8080"
         - name: HTTPS_PORT
           value: "8081"
```

They can be manipulated in the Deployment object from the Web Console, o from the command-line:

```plaintext
oc set env pod/cargo-app-... --list
oc set env pod/cargo-app-...  KEY_1=VAL_1 ... KEY_N=VAL_N
```

When done in the above way, the envionment variables are altered inside the pod.  They are not altered in the configuration of the Deployment.  Therefore, they won't survived the restart of the pod.  
 

```plaintext
oc delete pod cargo-app-...
oc get pods
oc set env pod/cargo-app-... --list
```

For the change to persist, they have to be modified at the Deployment level

```plaintext
oc set env deployment/cargo-app KEY=VAL
```

  
TODO 

*   EAP XP (standalone-microprofile.xml) → microprofile-config-api
*   QUARKUS ??

### ConfigMaps & Secrets

Sometimes, the configuration is not just an environment variable but an entire file (xml, .config, .properties…).

Files can be associated to applications externally using ConfigMaps or Secrets.

```plaintext
cd…
cat app.properties
oc create cm cargo-cm --from-file app.properties
oc get cm 
oc get cm cargo-cm -o yaml
```

In the Deployment object, the file can be referenced for the platform to place it in any folder inside the container at the Image instantiation time.

```plaintext
spec:
  containers:
  - name: cargo-container
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

From the Web Console, in the Pod terminal:

```plaintext
ls /tmp 
cat /tmp/app.properties
```

### Combining ConfigMaps/Secrets and environment variables

Configuring the environment variables directly is not ideal either as now, even though the image remains the same across environments, the Deployment will be different between environments and as it contains more than just the application configuration, risks are present that other things behave differently across environments.

As an alternative, the value of the envionment variables can come from an external file, which will be the only one element to differ across environments.

```plaintext
oc create configmap cargo-config --from-literal=cargo.var1=val1 --from-literal=cargo.var2=val2
oc get cm
oc get cm cargo-config -o yaml
```

The Deployment object will now contain:

```plaintext
spec:
  containers:
    - name: cargo-container
      image: cargo-app:latest
      env: 
        - name: ENV_VAR1 
          valueFrom:
            configMapKeyRef:
              name: cargo-config 
              key: cargo.var1
        - name: ENV_VAR2
          valueFrom:
            configMapKeyRef:
              name: cargo-config 
              key: cargo.var2
```

When environment variables are many, rather than setting them all one by one, it's possible to let the Deployment system do that, with the following configuration:

```plaintext
oc create cm cargo-env-config --from-file env.properties
```

```plaintext
spec:
  containers:
    - name: cargo-container
      image: cargo-app:latest
      envFrom: 
        - configMapRef:
            name: cargo-env-config
```

### Volumes and NFS

Some applications needs to use the filesystem to read and write files.  Ephemeral data can be place on the filesystem of the pods, which would not suvive a pod restart.  Persistent data, however, must be in a storage that persist across pod restarts.  It cannot be the node filesystem either, as there is no guarantee that the pod will be assigned to the same node upon restarts.  It has to be a emote filesystem.

[ocp-pv.md](ocp-pv.md) 

A new or existing data folder can be added to an application Image with the below configuration:

```plaintext
spec:
    containers:
     - name: cargo-container
       image: cargo-app:latest
       volumeMounts:
       - mountPath: /data
         name: cargo-volume
       - mountPath: /data2
         name: cargo-volume2
    volumes:
     - persistentVolumeClaim:
       claimName: cargo-claim
       name: cargo-volume
     - emptyDir: {}
       name: cargo-volume2
```

From the Web Console terminal, check that the filesystems are mounted:

```plaintext
ls /
echo “Is it there” > /data/file1
echo “Is it there” > /data2/file2
```

Restart the pod and go back to the pod Terminal

```plaintext
ls /data
cat /data/file1
ls /data2
```

TODO : 

*   RWO vs RWX
*   ID and permission for volume writing and sharing