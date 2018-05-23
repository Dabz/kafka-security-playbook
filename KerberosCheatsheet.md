# Kerberos Cheat Sheet

## Introduction 

This cheat sheet contains common commands regarding Kerberos administration and troubleshooting.

## User commands

### List current principal and ticket held in credential cache

```bash
$> klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: kafka_producer/producer@TEST.CONFLUENT.IO

Valid starting     Expires            Service principal
05/23/18 08:56:59  05/24/18 08:56:59  krbtgt/TEST.CONFLUENT.IO@TEST.CONFLUENT.IO
``` 

### Obtaining and caches a token for principal

```bash
$> kinit  kafka/admin
Password for kafka/admin@TEST.CONFLUENT.IO: 
```

### Obtaining and caches a token for principal from a keytab 

```bash
$> kinit -k -t /var/lib/secret/kafka.key kafka/admin 
```

### List credentials contains in a keytab

```bash
$> klist -k -t /var/lib/secret/kafka.key 
Keytab name: FILE:/var/lib/secret/kafka.key
KVNO Timestamp         Principal
---- ----------------- --------------------------------------------------------
   2 05/23/18 08:56:43 zookeeper/zookeeper.kerberos_default@TEST.CONFLUENT.IO
   2 05/23/18 08:56:43 zookeeper/zookeeper.kerberos_default@TEST.CONFLUENT.IO
   2 05/23/18 08:56:43 kafka/admin@TEST.CONFLUENT.IO
   2 05/23/18 08:56:43 kafka/admin@TEST.CONFLUENT.IO
   2 05/23/18 08:56:43 kafka/kafka.kerberos_default@TEST.CONFLUENT.IO
   2 05/23/18 08:56:43 kafka/kafka.kerberos_default@TEST.CONFLUENT.IO
   2 05/23/18 08:56:43 kafka/zookeeper@TEST.CONFLUENT.IO
   2 05/23/18 08:56:43 kafka/zookeeper@TEST.CONFLUENT.IO
   2 05/23/18 08:56:43 kafka_consumer/consumer@TEST.CONFLUENT.IO
   2 05/23/18 08:56:43 kafka_consumer/consumer@TEST.CONFLUENT.IO
   2 05/23/18 08:56:43 kafka_producer/producer@TEST.CONFLUENT.IO
   2 05/23/18 08:56:43 kafka_producer/producer@TEST.CONFLUENT.IO
```

### Destroy credential cache

```baseh
$> kdestroy
```

## Administration commands

### Adding a new principal to the KDC database 

```bash
$> kadmin.local -w password -q "add_principal -pw my_password kafka/zookeeper@TEST.CONFLUENT.IO" 
WARNING: no policy specified for test@TEST.CONFLUENT.IO; defaulting to no policy
Principal "kafka/zookeeper@TEST.CONFLUENT.IO" created
```

### Adding a new principal to the KDC database with a random key

```bash
$> kadmin.local -w password -q "add_principal -randkey kafka/zookeeper@TEST.CONFLUENT.IO" 
WARNING: no policy specified for test@TEST.CONFLUENT.IO; defaulting to no policy
Principal "kafka/zookeeper@TEST.CONFLUENT.IO" created
```

### Exporting principals to a keytab

```bash
$> kadmin.local -w password -q "ktadd  -k /var/lib/secret/kafka.key -glob kafka/*"
Entry for principal kafka/admin@TEST.CONFLUENT.IO with kvno 3, encryption type aes256-cts-hmac-sha1-96 added to keytab FILE:/etc/krb5.keytab.
Entry for principal kafka/admin@TEST.CONFLUENT.IO with kvno 3, encryption type aes128-cts-hmac-sha1-96 added to keytab FILE:/etc/krb5.keytab.
Entry for principal kafka/kafka.kerberos_default@TEST.CONFLUENT.IO with kvno 3, encryption type aes256-cts-hmac-sha1-96 added to keytab FILE:/etc/krb5.keytab.
Entry for principal kafka/kafka.kerberos_default@TEST.CONFLUENT.IO with kvno 3, encryption type aes128-cts-hmac-sha1-96 added to keytab FILE:/etc/krb5.keytab.
Entry for principal kafka/zookeeper@TEST.CONFLUENT.IO with kvno 3, encryption type aes256-cts-hmac-sha1-96 added to keytab FILE:/etc/krb5.keytab.
Entry for principal kafka/zookeeper@TEST.CONFLUENT.IO with kvno 3, encryption type aes128-cts-hmac-sha1-96 added to keytab FILE:/etc/krb5.keytab
```
