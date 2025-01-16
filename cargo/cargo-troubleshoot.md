## **Troubleshooting Applications**

### Logs

[Introduction to container logging best practice](../ocp/ocp-logs.md)

#### **Pod logs**

Logs can be seen on the Web Console, under the Logs tab of any pod.

With the command line:

```plaintext
oc logs <pod>
```

#### Centralized logging

TODO

### **Debugging**

#### **Pod Terminal**

Debugging actions can be taken be entering the Terminal of the pod, that gives access to the shell of the pod

You'll get access to the pod with the same user ID as the one running the pod

```plaintext
> id
```

#### **Exec command**

The “exec” command allows executing a command in a running pod

```plaintext
oc exec <pod> -- curl localhost:8080
```

#### **RSH**

The “rsh” command allows accessing the pod in a remote shell.  It's equivalent to the pod's Terminal, but accessed remotely from the command line

```plaintext
oc rsh <pod>
> curl localhost:8080
```

#### **Port forwarding**

The port forwarding command allows to access pod's services remotely by creating a tunnel up to the pod's container

```plaintext
oc port-forward pod/cargo-app 9000:8080
curl localhost:9000
```

#### **Debugger pod**

The “oc debug” command creates a pod with the same definition as per a Deployment object for troubleshooting purpose.

```plaintext
oc debug deployment/cargo-app
```

Go to the Terminal of the debugging pod

```plaintext
curl localhost:8080
```

TODO: is the PV and configmap there ??

```plaintext
oc debug pod
```

On another shell, type

```plaintext
oc get pods | grep debugcurl localhost:8080
```

You'll see that indeed a separate pod was created.  We're not accessing the application's pod.

Still in the Terminal of the debugging pod, you can try

```plaintext
curl localhost:8080
```

You'll see that the service is not available.  This is because the debugging pod overrides the container's Entrypoint, and therefore the JBoss EAP server startup command didn't run.

#### Debugging with root access

Launch a debugger pod

```plaintext
oc debug deployment/cargo-app
```

Then check which ID you have inside this debugger pod, from another shell

```plaintext
oc exec <debug-pod> id
```

Now exit the debugger pod and create another one with the following command:

```plaintext
oc debug deployment/cargo-app --as-root
```

From another shell, check which ID you have now

```plaintext
oc exec <debug-pod> id
```

#### Copy command

The “oc cp” command allows remote interactions with a pod in order to send or retrieve files

```plaintext
oc exec <pod_name> ls /tmp

echo "This is a remote file" > test.txt
oc cp ./test.txt <pod_name>:/tmp 

oc exec <pod_name> ls /tmp
oc exec <pod_name> cat /tmp/test.txt
```

The copy command copies files into an already running pod, which means that the state will not survive the restart of the pod

```plaintext
oc delete pod <pod_name>
oc exec <new_pod_name> cat /tmp/test.txt  # no such file or directory
```

### Inspection

#### Describe command

Details of a pod, including its status, can be visualized with: 

```plaintext
oc describe pod <pod>
```

#### Status

The “oc status” command gives you a lot of information about what's running in your namespace, including details of the images.

```plaintext
oc status
```

You can also do further inspection with skopeo:

```plaintext
skopeo login <user> <token>
skopeo inspect docker://<registry_route>/<ns>/<full_image_reference>
```

#### Node access

You can access the physical nodes directly:

```plaintext
oc get nodes
oc debug nodes/<node_address>
```

A debugger pod will start, but this time to debug the node.  This pod is a system pod and therefore is in a system Namespace.  

From another shell, type:

```plaintext
oc get pods --all-namespaces | grep ‘-debug-’
```

Running the following command inside this debugger pod will demonstrate that it mounted the node filesystem inside it.  You'll also see that you are “root” inside such a pod, so the command you'd type could have an impact on the physical node itself, and not only on the running pod where the command is typed.

```plaintext
> ls  # notice the presence of the /host directory, that is the underlying filesystem of the node
> ls /host/var/lib/containers/storage/overlay

> id
```

The “oc” command is available in this pod.  However, commands such as "podman", to access underlying physical resources directly, are not:

```plaintext
> oc version      # ok
> podman version  # command does not exist
```

Commands such as podman would however be available inside the node operating system namespace:

```plaintext
chroot /host
ls              # we are in /host ; so /host is no longer there
podman version  # ok
```

### **Events**

Openshift emits notifications in a lot of circumstances.  Those events can be seen on the Web Console:

*   From the Administrator perspective, the Workload/Pods → Events tab shows events related to this specific pod
*   From the Administrator perspective, the Home/Events tab shows events scoped at the entire cluster

From the command line:

```plaintext
oc events
oc events --all-namespaces
```