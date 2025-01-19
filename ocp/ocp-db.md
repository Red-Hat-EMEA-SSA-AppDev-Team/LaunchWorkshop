Databases are products, so are best to be managed with Operators.

As any application on Openshift, there are various ways to create a database.  

The only difference is that databases don't have source code.

So, they can be directy instantiated from existing packaged image, which means only a Deployment object is required, but not a BuildConfig.

A Service object will also be required to expose the database on the Openshift network, but a Route, however, won't be needed as databases are not accessed externally through the HTTP protocol.