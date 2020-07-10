# A guide to having a secure JMX connection

The need of having a secure JMX connection is very common in big organisations. There are a few ways of implementing this, but in this example we offer one of them:

In Apache Kafka, you can pass a JVM option like this:

```java
KAFKA_JMX_OPTS=-Dcom.sun.management.config.file=/var/ssl/private/jmxremote.properties
```

this would instruct the JXM to configure jmx using the referenced file.

This file should look like:

```java
com.sun.management.jmxremote=true
com.sun.management.jmxremote.port=9999
com.sun.management.jmxremote.rmi.port=9999
com.sun.management.jmxremote.password.file=/var/ssl/private/jmxremote.password
com.sun.management.jmxremote.access.file=/var/ssl/private/jmxremote.access
com.sun.management.jmxremote.registry.ssl=true
com.sun.management.jmxremote.ssl.config.file=/var/ssl/private/jmxremote.properties

javax.net.ssl.keyStore=/var/ssl/private/kafka.keystore
javax.net.ssl.keyStorePassword=confluent
javax.net.ssl.trustStore=/var/ssl/private/kafka.truststore
javax.net.ssl.trustStorePassword=confluent
```

in this example we set:

* An SSL secured JMX connection.
* That has authentication using configured user and password files.

Other options to handle authentication are possible, like having LDAP and/or other login modules. They are not covered in this example.
