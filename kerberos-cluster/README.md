# Kerberos configuration demo

This demo sets up a basic Kafka cluster secured with Kerberos authentication, and sets up some basic ACLs to demonstrate authorisation.
The documentation below introduces the relevant components you need to understand to set up Kerberos.

## Kerberos authentication process

Before configuring Kafka for Kerberos authentication, it is useful to understand the basic Kerberos authentication process and some key terms.
Let's work through the process for a client application making a connection into Kafka.

Kerberos involves three parties:

- a Kerberos Client, in this case our client application.
- a Kerberized Service, in this case Kafka.
- the Kerberos **Key Distribution Center (KDC)**

An important point to understand in this process is that Client and Service shares their own cryptographic key with the KDC.
By using this key to encrypt/decrypt tokens passed over the network, two network systems can verify each other's identities.
The Client and Service trust that they have only shared their secret with the KDC and so any correctly signed token must have originated from the KDC.
This is crucial.
During the Kerberos process the Client requests a token from the KDC _signed with the Service's key_ and presents this when making a connection.
The Service can then trust that the Client has valid credentials with the KDC and can be authenticated.

Other information is shared during the process to enable integrity checking and protection against various spoofing attacks.
For example, each signed token is:

* timestamped to bound the window for which it is valid
* linked to a network IP so that it is valid only from a single host

The first stage is that the Client application must authenticate itself with the Kerberos **Key Distribution Center (KDC)** service.

The KDC is one of two core services required by Kerberos and authenticates that the Client knows the private credentials relating to the client's Kerberos **Principal**.
The Principal is a a unique identity in the form {primary}/{instance}@{REALM} (more on these later).
The KDC authenticates the client using their shared cryptographic key and results in the client receiving a **Ticket Granting Ticket (TGT)**.
This is a cryptographic token that the Client may now use to prove that it has recently authenticated with the KDC.
The TGT is timestamped and includes an expiry time, typically a day.
The TGT is cached by the client to avoid having to re-authenticate unnecessarily.

Next, the Client wants to authenticate itself to the Kerberized Service.
For this to happen, the client must get a cryptographic token encrypted with the Kerberized Service's key - this token is a **Service Ticket** and is requested by the client from the KDC using the TGT and the requested service's principal name.
Including the TGT in this request is sufficient to prove that the client has already authenticated with the KDC allowing the service ticket to be returned.

Here is an important point to note - how does the client know the service principal name? Simply it builds the principal with:

- {primary} = a client-side configured name for the service
- {instance} = the network address used to connect to the service
- {REALM} = the realm of the client and KDC.

In our example, our Client attempts to connect to the `kafka` Service on the host `kafka1.kerberos-demo.com` in the realm `TEST.CONFLUENT.IO`.
Therefore, the service must be configured with a Service Principal Name of `kafka/kafka1.kerberos-demo.com@TEST.CONFLUENT.IO`.

Now the Client can connect directly to the Kerberized Service, and include the Service Ticket.
As the Service ticket is signed with the Service principal's key, the Service can decrypt the token to authenticate the request.

Based on the above, each connection in the cluster must be established with the following in place:

* On the Kerberos Client:
** A client principal and key to authenticate with the KDC, `{client name}@REALM`
** a configured name for the service to connect to, `{service name}`
** the network address for the service, `{network address}`.
* On the server:
** a principal name & key in the form `{service name}/{network address}@REALM`.

As can be seen, the service principal must be constructed correctly to work.
However, the `{client name}` format is not mandated in the same way and is not bound to a network address.
Often the client name is a simple alphanumeric username, let's say 'john'.
However, you may sometimes see a client principal such as 'john/admin'.
In this form, 'admin' is called an _instance_ of the 'john' principal and can be used by 'john' to run services on the system with different credentials and privileges from the main account.
From the Kerberos perspective, the two principals are completely separate, but it can nonetheless be convenient to use this naming convention.


# Technical Components
## KDC
The KDC could be provided by MIT Kerberos, Windows Active Directory, Redhat Identity Manager and many others.
In this demo we use MIT kerberos.

Cheatsheet ....

## Kerberos libraries and tools

All the hosts must include Kerberos libraries and a shared configuration (krb5.conf) in order to use and trust the same KDC.

`kinit` is used to authenticate to the Kerberos server as principal, or if none is given, a system generated default (typically your login name at the default realm), and acquire a ticket granting ticket that can later be used to obtain tickets for other services.

`klist` reads and displays the current tickets in the credential cache (also known as the ticket file).

`kvno` acquires a service ticket for the specified Kerberos principals and prints out the key version numbers of each.


keytabs ....


## Simple Authentication and Security Layer (SASL)

SASL is a framework for authentication in network communications which in principle decouples authentication concerns from the application protocol.

Kafka and Zookeeper can use SASL as the authentication layer in communications (Mutual TLS being the notable alternative).

When SASL has been enabled, you must further specify a SASL *mechanism* to use - the process and protocol to use when authenticating a connection.
Applications must build support for each SASL mechanism - Kafka supports SCRAM(-SHA-256 | -SHA-512), PLAIN, OAUTHBEARER and GSSAPI.
*GSSAPI is the SASL mechanism which implements Kerberos*.


## Java Authentication and Security Services (JAAS)

JAAS is a Java's integrated, pluggable security service and Kafka uses the JAAS apis to implement SASL authentication. SASL authentication is configured using JAAS.
Kerberos is configured using the JAAS *LoginModule* `com.sun.security.auth.module.Krb5LoginModule`.

JAAS may be configured in a couple of places:

* By default it uses a .jaas file, a reference to which is passed in the `-Djava.security.auth.login.config=<file path` JVM flag.
Each jaas file includes multiple named stanzas, representing different login contexts.

* An application can override this configuration and configure JAAS from application config.
Kafka configurations expose this option using properties `sasl.jaas.config`, which can variously be prefixed.
The value is the inline configuration for a single login context and, in Kafka, takes precedence over entries in a .jaas files.

https://docs.oracle.com/javase/8/docs/jre/api/security/jaas/spec/com/sun/security/auth/module/Krb5LoginModule.html


A Kerberos enabled Client or Service can be initiated in two ways:

. Use kinit to cache a TGT locally, and then launch the process with this shared cache.
. Configure a keytab to be used directly.

Configuration of the former is straight-forward as follows:

```
SomeLoginContext {
  com.sun.security.auth.module.Krb5LoginModule required
  useTicketCache = true;
};
```

The `useTicketCache = true` setting specifies that the TGT cache should be used.

By comparison, the latter approach has `useTicketCache = false` (the default) and then continues to specify details for using a keytab file:

```
SomeLoginContext {
    com.sun.security.auth.module.Krb5LoginModule required
    useKeyTab=true
    storeKey=true
    keyTab="/var/lib/secret/kafka1.key"
    principal="kafka/kafka1.kerberos_default@TEST.CONFLUENT.IO";
};
```

The login context, as identified with `SomeLoginContext` above, can be used by a Client, a Service or both.
For Kafka, the names are defined in the application code as we will describe later.


# Kerberizing Kafka

To fully understand the steps required to Kerberize Kafka, we should understand each Client -> Service connection which we wish to Configure.
Each of these connections has a prototypical set of configurations required on the Client side and on the Service side.

The following are values you must decide upon at the cluster level:

* `{kafka-kerberos-service-name}` - name for the Kerberized Kafka service.
Typically `kafka` or `cp-kafka`.
* `{zookeeper-kerberos-service-name}` - name for the Kerberized Zookeeper service.
By default this is `zookeeper`.
* `{security-protocol}` - either `SASL_PLAINTEXT` of `SASL_SSL` if using in conjunction with TLS.

## Service Configuration

In the cluster there are two Kerberized services running: Kafka Broker and Zookeeper.
We will configure these first and then the clients.

### Kafka Service

* Broker JAAS:
    * Login Context: `KafkaServer`
    * Use *keytab* method.
    * Ensure that the principal is a correctly formed service principal for each node: `{kafka-kerberos-service-name}/{FQDN}@{realm}`.    
* Broker Server Properties:
    * `sasl.enabled.mechanisms=GSSAPI` (more SASL mechanisms may be specified in a comma-separated list)

### Zookeeper Service

* Zookeeper JAAS:
    * Client API - Kerberize access to ZooKeeper data.
        * Login Context: `Server`
        * Use *keytab* method.
        * Ensure that the principal is a correctly formed service principal for each node: `{zookeeper-kerberos-service-name}/{FQDN}@{realm}`.
    * Quorum Server - ???
        * Login Context: `QuorumServer`
        * Use *keytab* method.
        * Ensure that the principal is a correctly formed service principal for each node: `zkquorum/{FQDN}@{realm}`.
    * Quorum Learner -
        * Login Context: `QuorumLearner`
        * Use *keytab* method.
        * Ensure that the principal is a correctly formed service principal for each node: `learner/{FQDN}@{realm}`.
* Zookeeper Properties:
    * TODO

## Client -> Kafka Service
Clients connecting in to Kafka may be any of:

* A Kafka producer
* A Kafka consumer
* A Kafka Admin client

Note that many applications are a combination of many of these - notably Streams applications.

* Client JAAS:
    * Login Context: `KafkaClient`
    * Can use *kinit* or *keytab* method.
* Client Properties:
    * `sasl.kerberos.service.name={kafka-kerberos-service-name}`
    * `security.protocol={security-protocol}`


## Kafka Broker -> Zookeeper Service
Brokers connect to Zookeeper for cluster operations.

* Broker JAAS:
    * Login Context: `Client`
    * Use *keytab* method.
    * *Ensure that the same principal is configured for use on each broker.*

* Broker JVM flags:
    * `-Dzookeeper.sasl.client.username={zookeeper-kerberos-service-name}` (OPTIONAL)


## Kafka Broker -> Kafka Service
Each Kafka broker connects to other brokers in the cluster, primarily for replication, but also for cluster management operations.

* JAAS:
    * Same JAAS configuration as for the Kafka Service, i.e. the `KafkaServer` LoginContext and service principal name.
* Properties:
    * `sasl.kerberos.service.name={kafka-kerberos-service-name}`


## Client -> Zookeeper (Optional)
Historically, clients needed to connect directly to ZooKeeper for service discovery and admin operations.
However, the new Kafka Admin API allows all this functionality via Client -> Kafka Broker connection, so this direct connection should not be required.

* JAAS:
   * LoginContext: `Client`
   * Can use *kinit* or *keytab* method.


## Zookeeper -> ZooKeeper Service (Replication)
Zookeeper nodes must communication with each other for replication and leadership election.

* Reuses JAAS configuration for Zookeeper Service


## Zookeeper -> ZooKeeper (Leadership Election)
Zookeeper nodes must communication with each other for replication and leadership election.

* Reuses JAAS configuration for Zookeeper Quorum and Learner Services
(NB this is TODO in the demo!)

## Confluent Metrics Reporter (Optional)

TODO

## Confluent Interceptor (Optional)

TODO



# Authentication is not enough

The steps above are sufficient to support Kerberos authenticated connections within the cluster. This does not make your cluster secure though! The following should also be reviewed:


* zookeeper.set.acl=true
* super.users must include a user User:{kafka-kerberos-service-name}




# References:

* https://www.youtube.com/watch?v=KD2Q-2ToloE Video overview of Kerberos authentication process.
