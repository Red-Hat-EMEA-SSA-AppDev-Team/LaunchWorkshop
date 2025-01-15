### **Logging**

#### **Pod logs**

Console → logs

oc logs \<pod>

TODO : Container → logs to stdout instead of files (ex: eap logging module/appender)

#### Centralized logging

### **Debugging**

#### **Pod Terminal**

#### **Exec**

```plaintext
oc exec <pod> curl localhost:8080
```

#### **RSH**

```plaintext
oc rsh <pod>
curl localhost:8080
```

#### **Port forwarding**

```plaintext
oc port-forward pod/cargo-app 9000:8080
```

Open your browser at  http://localhost:9000/cargo-tacker

#### **Pod Debugger**

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
oc get pods | grep debug
```

Go to the Terminal of the debugging pod

```plaintext
curl localhost:8080
```

TODO: is the PV and configmap there ??

#### Debugging with root access

```plaintext
oc debug deployment/cargo-app
oc exec <debug-pod> id
```

```plaintext
oc debug deployment/cargo-app --as-root
oc exec <debug-pod> id
```

### Inspection

#### Describe

```plaintext
oc describe pod <pod>
```

#### Status and skopeo

```plaintext
oc status
skopeo login <user> <token>
skopeo inspect docker://<registry_route>/<ns>/<img>
```

#### Node access

```plaintext
oc get nodes
oc debug nodes/<node_address>
&gt;ls 
&gt;ls /host/var/lib/containers/storage/overlay
```

```plaintext
oc get pods --all-namespaces | grep ‘-debug-’
```

```plaintext
oc debug nodes/<node_address>
oc version
podman version
id
chroot /host
oc version
podman version
```

### **Others**

#### **Events**

Web Console → pods → events

Web Console → events

```plaintext
oc events
oc events --all-namespaces
```

#### Copy

```plaintext
oc exec <pod_name> ls /tmp
oc cp ./test.txt <pod_name>:/tmp 
oc exec <pod_name> ls /tmp
```

```plaintext
oc delete pod
oc exec <pod_name> ls /tmp
```

TODO:

*   **Permission to access oc debug, exec…**