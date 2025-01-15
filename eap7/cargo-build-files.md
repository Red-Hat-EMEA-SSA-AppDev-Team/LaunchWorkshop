## Builds from files

### Builds with yamls

### Builds with th command line

We saw that a build is simply represented by a BuildConfig object, possibly along with an ImageStream that gives a name to a newly created image.

Of course w could use a yaml representation of a BuildConfig and ImageStream and apply them to the platform using oc apply -f \<yaml\_file>.

### Builds with Templates

For EAP, such a Template is already provided by the platform:

```plaintext
oc get template -n openshift | grep eap74
oc get template -n openshift eap74-basic-s2i -o yaml
```

You can look at the template parameters then:

```plaintext
oc process eap74-basic-s2i -pSOURCE_REPOSITORY_REF=https://github.com/Red-Hat-EMEA-SSA-AppDev-Team/cargotracker#jee7-eap7 -p APPLICATION_NAME=cargo-app-template | oc apply -f -
```

Of couse this can be done on the Web Console by selecting the `eap74-basic-s2i&nbsp;`  template and clicking Create

Also, we could combine those 2 yaml definitions in a single “Template” file and apply that unique file.

In the case of EAP, the platform directly ships with a ready-to-use template.

**To access the template from the Web Console, inside the Developer perspective:**

```plaintext
Click +Add
Select “All Services”
Filter out Templates from the left menu
Type “eap” in the search box
```

You should see a Template named Jboss EAP 7.4.0.

By instantiating this template, you'll have the opportunity, on the next page, to set appropirate values for the Git repository and branch.

As an exercise, build and deploy th cargo tracker application using this method, giving it the name “cargo-app-tmpl-ui”.

The actual name of the template, which can differ from the displayed name, is eap74-basic-s2i.

You can confirm that on the command line:

```plaintext
oc get templates -n openshift | grep eap74
```

If you prefer, you can instantiate the template from th command line, using the -p option to set the Git repository URL and branch parameters.\</yaml\_file>