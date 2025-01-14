1.  **Building from a war using S2I binary**

  
 

[https://catalog.redhat.com/software/containers/jboss-eap-7/eap74-openjdk11-openshift-rhel8/6054ceca93acb006e7349a98?q=jboss%20eap%207.4&architecture=amd64&image=676028144a112c1ff1b4dedd](https://catalog.redhat.com/software/containers/jboss-eap-7/eap74-openjdk11-openshift-rhel8/6054ceca93acb006e7349a98?q=jboss%20eap%207.4&architecture=amd64&image=676028144a112c1ff1b4dedd)

  
 

[https://docs.redhat.com/fr/documentation/openshift_container_platform/3.0/html/creating_images/creating-images-s2i#s2i-scripts](https://docs.redhat.com/fr/documentation/openshift_container_platform/3.0/html/creating_images/creating-images-s2i#s2i-scripts)

  
  
 

oc import-image [registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8](http://registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8) --confirm

  
 

oc new-build --binary=true  --image-stream=eap74-openjdk11-openshift-rhel8  --name=cargo-app

  
 

mvn package

  
 

mkdir ocp && mkdir ocp/deployments/

mv target/\*.war  ocp/deployments/

  
 

oc start-build cargo-app --from-dir=./ocp --follow

  
 

\=> show buildconfig + strategies + build volume + incremental builds

 show build pod + oc get images | grep cargo-app + oc describe image

  
 

\=> Show developer console (add image)

  
  
  
 

1.  **Building from a war using a dockerfile**

  
 

—-------Container file —----------------------

FROM registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8:latest

  
 

COPY ocp/deployments/\* /deployments

  
 

ENTRYPOINT /opt/eap/bin/standalone.sh -c standalone-openshift.xml -bmanagement 0.0.0.0 -Djboss.server.data.dir=/opt/eap/standalone/data -Dwildfly.statistics-enabled=true

—-----------------------

  
 

podman login registry.redhat.io

  
 

podman build . -t my-cargo-app

  
 

podman images

  
 

podman run -it \<imageID>

  
  
 

podman login \<user> \<token>

podman login -u mthirion https://default-route-openshift-image-registry.apps.ocp4.mthirion.eu/

  
 

podman tag localhost/my-cargo-app:latest  \<route>/…

→ \<registry route> needs to be exposed

  
 

oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge

  
 

podman tag localhost/my-cargo-app:latest default-route-openshift-image-registry.apps.ocp4.mthirion.eu/proa/my-cargo-app:latest

  
 

podman push \<route>  → need push permission

  
 

oc policy add-role-to-user registry-editor \<user\_name>

  
 

podman push default-route-openshift-image-registry.apps.ocp4.mthirion.eu/proa/my-cargo-app:latest

  
 

oc images | grep my-cargo-app

oc get is

  
 

\<deploy>

→ try to get metrics

\-Dwildfly.statistics-enabled=true

  
  
 

1.  **Using buildah & kaniko**

Buildah → to build from scratch or from an existing container/image without using a containerfile

  
 

Kaniko → to build and push docker images from inside a container 

  
  
 

1.  **Building from source**

  
 

oc new-build [eap74-openjdk11-openshift-rhel8](http://registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8)~https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker#jee7-eap7 --name=my-cargo-app-source

  
 

oc get builds

oc get images | grep cargo-app-source

  
 

\<deploy>

  
 

1.  **Building with Helm**
2.  Developer perspective

Chart ->Release -> Upgrade => build uri

  
  
 

1.  Manual

helm repo add openshift https://charts.openshift.io/

  
 

helm search repo

helm search repo | grep -i eap

  
 

helm pull openshift/redhat-eap74 --untar

cat eap74/values.yaml

  
  
 

helm install cargo-app-helm openshift/redhat-eap74 --set build.uri=[https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracke](https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker/tree/jee7-eap7)r --set build.ref=[jee7-eap7](https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker/tree/jee7-eap7)

  
  
 

Helm (helm.yaml)

—----

build:

  uri: [https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker](https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker/tree/jee7-eap7)

  ref: [jee7-eap7](https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker/tree/jee7-eap7)

—----

helm upgrade --install cargo-app-helm -f helm.yaml openshift/redhat-eap74

  
 

→ Explain chained builds !!

  
  
 

1.  **Building with new-app**

[https://access.redhat.com/node/2389381/chapter-7-builds](https://access.redhat.com/node/2389381/chapter-7-builds)

  
 

oc new-app … -o yaml (dry-run)

  
 

1.  ù£+From Source

oc new-app [eap74-openjdk11-openshift-rhel8](http://registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8)~https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker#jee7-eap7 --name=my-cargo-newapp-source

  
 

1.  From binary

oc new-app \<oc\_start-build-name>

oc new-app cargo-app

  
  
 

1.  **Building from the developer perspective**

Add → All services → builder images → EAP XP