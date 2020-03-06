# README

This playbook is an example of configuration where Schema Registry is configured for accepting request on `http` and `https`.
This repo as well add mTLS as a mutual authentication mechanism via TLS.
Requests on the `http` endpoint are actually identified as the `ANONYMOUS` user. This is possible thanks to the `confluent.schema.registry.anonymous.principal=true` option.

The following ACLs are configured:
- `sr-acl-cli --config /etc/schema-registry/schema-registry.properties --add -s '*' -p 'ANONYMOUS' -o 'SUBJECT_READ'`
- `sr-acl-cli --config /etc/schema-registry/schema-registry.properties --add -p 'ANONYMOUS' -o 'GLOBAL_SUBJECTS_READ'`
- `sr-acl-cli --config /etc/schema-registry/schema-registry.properties --add -p 'ANONYMOUS' -o 'GLOBAL_COMPATIBILITY_READ'`
- `sr-acl-cli --config /etc/schema-registry/schema-registry.properties --add -s '*' -p 'CN=schema-registry,O=Confluent Ltd,L=Berlin,ST=Berlin,C=DE' -o '*'`

With this configuration, ` curl  -X GET http://localhost:8089/subjects/` is successful, but the `ANONYMOUS` user does not have the privileges to write new schemas.
Only the client with the TLS client certificate `CN=schema-registry,O=Confluent Ltd,L=Berlin,ST=Berlin,C=DE` can write new schemas, this could be for example your CI tool or an admin user.

Use the _verify.sh_ script to verify the http mTLS authentication

## Producing and consuming data from Schema Registry with HTTPs and mTLS (v5.4.1 or older)

**NOTE**: If using an Schema Registry version <= 5.4.1 there is no option to disable the host verification algorithm.
Disable host verification is **NOT recommended** and **highly discouraged**, but teams can find in a situation where this append.

In this playbook there are certificate generated with *subjectAltName* and *CN* like:

```
SubjectAlternativeName [
  DNSName: localhost
  DNSName: schema-registry
]
```

```
SubjectAlternativeName [
  DNSName: localhost
  DNSName: client
]
```

```
Owner: CN=client, O=Confluent Ltd, L=Berlin, ST=Berlin, C=DE
Issuer: CN=intermediate-ca, O=Confluent Ltd, ST=Berlin, C=DE
```

### Produce/Consume messages from Schema Registry

In versions of Schema Registry < 5.4 as a user have to pass the keystore and truststore using a system variable in this form:

```bash
export SCHEMA_REGISTRY_OPTS="-Djavax.net.ssl.trustStore=/etc/kafka/secrets/schema-registry.truststore \
           -Djavax.net.ssl.trustStorePassword=confluent \
           -Djavax.net.ssl.keyStore=/etc/kafka/secrets/schema-registry.keystore \
           -Djavax.net.ssl.keyStorePassword=confluent"
```

#### With certificates without valid subject names

if you client configuration is using the basic trustore and keystore configuration:

```bash
docker-compose exec client ./scripts/mtls/produce.sh /data/one-doc.txt
[2020-03-06 16:20:07,647] ERROR Failed to send HTTP request to endpoint: https://schema-registry:8082/subjects/topic-tls-value/versions (io.confluent.kafka.schemaregistry.client.rest.RestService:203)
javax.net.ssl.SSLHandshakeException: java.security.cert.CertificateException: No name matching schema-registry found
	at sun.security.ssl.Alerts.getSSLException(Alerts.java:192)
	at sun.security.ssl.SSLSocketImpl.fatal(SSLSocketImpl.java:1946)
  ...
  at io.confluent.kafka.formatter.AvroMessageReader.readMessage(AvroMessageReader.java:181)
	at kafka.tools.ConsoleProducer$.main(ConsoleProducer.scala:55)
	at kafka.tools.ConsoleProducer.main(ConsoleProducer.scala)
Caused by: java.security.cert.CertificateException: No name matching schema-registry found
	at sun.security.util.HostnameChecker.matchDNS(HostnameChecker.java:231)
	at sun.security.util.HostnameChecker.match(HostnameChecker.java:96)
	at sun.security.ssl.X509TrustManagerImpl.checkIdentity(X509TrustManagerImpl.java:462)
	at sun.security.ssl.X509TrustManagerImpl.checkIdentity(X509TrustManagerImpl.java:442)
	at sun.security.ssl.X509TrustManagerImpl.checkTrusted(X509TrustManagerImpl.java:209)
	at sun.security.ssl.X509TrustManagerImpl.checkServerTrusted(X509TrustManagerImpl.java:132)
	at sun.security.ssl.ClientHandshaker.serverCertificate(ClientHandshaker.java:1621)
	... 24 more
```  

but there is the option to disable the host verification via a java agent. The reader can see the code within this project.

```bash
docker-compose exec client /scripts/mtls/produce-with-agent.sh /data/one-doc.txt
Initialize the VerificationAgent
```

the configuration for this example looks like:

```bash
export SCHEMA_REGISTRY_OPTS="-Djavax.net.ssl.trustStore=/etc/kafka/secrets/avocado.truststore \
           -Djavax.net.ssl.trustStorePassword=confluent \
           -Djavax.net.ssl.keyStore=/etc/kafka/secrets/avocado.keystore \
           -Djavax.net.ssl.keyStorePassword=confluent \
           -javaagent:/plugins/verification.jar"


kafka-avro-console-producer --broker-list kafka:29092 --topic topic-tls \
  --property value.schema='{"type":"record","name":"myrecord","fields":[{"name":"f1","type":"string"}]}' \
  --property schema.registry.url=https://schema-registry:8082 < $1
```

The java agent looks like:

```java
public class VerificationAgent {

  public static void premain(String args, Instrumentation inst) {
    System.out.println("Initialize the VerificationAgent");
    HttpsURLConnection.setDefaultHostnameVerifier((s, sslSession) -> true);
  }

}
```

if the reader add this agent either to the SR and/or the client, it will disable the _hostnameVerifier_ process.


#### With certificates with correct subject names

If hostname verification can finish successfully the execution will looks like:

```bash
export SCHEMA_REGISTRY_OPTS="-Djavax.net.ssl.trustStore=/etc/kafka/secrets/client.truststore \
           -Djavax.net.ssl.trustStorePassword=confluent \
           -Djavax.net.ssl.keyStore=/etc/kafka/secrets/client.keystore \
           -Djavax.net.ssl.keyStorePassword=confluent"
```

```bash
docker-compose exec client  /scripts/mtls/produce.sh /data/one-doc.txt
```

#### Consume data from schema registry

To consume data from a topic using as well the schema registry the reader can use a command like:

```bash
docker-compose exec client  /scripts/mtls/consume.sh
```

this script looks like:

```bash
export SCHEMA_REGISTRY_OPTS="-Djavax.net.ssl.trustStore=/etc/kafka/secrets/client.truststore \
           -Djavax.net.ssl.trustStorePassword=confluent \
           -Djavax.net.ssl.keyStore=/etc/kafka/secrets/client.keystore \
           -Djavax.net.ssl.keyStorePassword=confluent \
           -javaagent:/plugins/verification.jar"

kafka-avro-console-consumer --topic topic-tls  --from-beginning \
  --bootstrap-server kafka:29092 \
  --property schema.registry.url=https://schema-registry:8082
```

the same concepts apply to the consumer as with the producer.



#### What happens when using a user without the right permissions

In this example the principal guacamole will have no permissions access the Schema Registry.
An error like the one seen here will pop up.  

```bash
docker-compose exec client  /scripts/mtls/produce-exception.sh /data/one-doc.txt
Initialize the VerificationAgent
org.apache.kafka.common.errors.SerializationException: Error registering Avro schema: {"type":"record","name":"myrecord","fields":[{"name":"f1","type":"string"}]}
Caused by: io.confluent.kafka.schemaregistry.client.rest.exceptions.RestClientException: Unrecognized token 'User': was expecting ('true', 'false' or 'null')
at [Source: (sun.net.www.protocol.http.HttpURLConnection$HttpInputStream); line: 1, column: 6]; error code: 50005
 at io.confluent.kafka.schemaregistry.client.rest.RestService.sendHttpRequest(RestService.java:230)
 at io.confluent.kafka.schemaregistry.client.rest.RestService.httpRequest(RestService.java:256)
 at io.confluent.kafka.schemaregistry.client.rest.RestService.registerSchema(RestService.java:356)
 at io.confluent.kafka.schemaregistry.client.rest.RestService.registerSchema(RestService.java:348)
 at io.confluent.kafka.schemaregistry.client.rest.RestService.registerSchema(RestService.java:334)
 at io.confluent.kafka.schemaregistry.client.CachedSchemaRegistryClient.registerAndGetId(CachedSchemaRegistryClient.java:168)
 at io.confluent.kafka.schemaregistry.client.CachedSchemaRegistryClient.register(CachedSchemaRegistryClient.java:222)
 at io.confluent.kafka.schemaregistry.client.CachedSchemaRegistryClient.register(CachedSchemaRegistryClient.java:198)
 at io.confluent.kafka.serializers.AbstractKafkaAvroSerializer.serializeImpl(AbstractKafkaAvroSerializer.java:70)
 at io.confluent.kafka.formatter.AvroMessageReader.readMessage(AvroMessageReader.java:181)
 at kafka.tools.ConsoleProducer$.main(ConsoleProducer.scala:55)
 at kafka.tools.ConsoleProducer.main(ConsoleProducer.scala)
 ```
This is a known issue (https://github.com/confluentinc/schema-registry/issues/733)
