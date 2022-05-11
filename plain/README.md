
* Start to produce:

```bash
$ kafka-console-producer --broker-list localhost:9093 --producer.config producer.properties --topic test
[2022-05-11 13:23:05,822] WARN [Producer clientId=console-producer] Error while fetching metadata with correlation id 3 : {test=TOPIC_AUTHORIZATION_FAILED} (org.apache.kafka.clients.NetworkClient)
[2022-05-11 13:23:05,824] ERROR [Producer clientId=console-producer] Topic authorization failed for topics [test] (org.apache.kafka.clients.Metadata)
[2022-05-11 13:23:05,825] ERROR Error when sending message to topic test with key: null, value: 3 bytes with error: (org.apache.kafka.clients.producer.internals.ErrorLoggingCallback)
org.apache.kafka.common.errors.TopicAuthorizationException: Not authorized to access topics: [test]
```

* Start to consume:

```bash
$ kafka-console-consumer --bootstrap-server localhost:9093 --consumer.config consumer.properties --topic test --from-beginning

[2022-05-11 13:12:11,085] WARN [Consumer clientId=consumer-console-consumer-16928-1, groupId=console-consumer-16928] Error while fetching metadata with correlation id 2 : {test=TOPIC_AUTHORIZATION_FAILED} (org.apache.kafka.clients.NetworkClient)
[2022-05-11 13:12:11,087] ERROR [Consumer clientId=consumer-console-consumer-16928-1, groupId=console-consumer-16928] Topic authorization failed for topics [test] (org.apache.kafka.clients.Metadata)
[2022-05-11 13:12:11,088] ERROR Error processing message, terminating consumer process:  (kafka.tools.ConsoleConsumer$)
org.apache.kafka.common.errors.TopicAuthorizationException: Not authorized to access topics: [test]
```

* Let's fix the producer:

```bash
$ kafka-acls --bootstrap-server localhost:9093 --command-config ~/projects/confluent/kafka-security-playbook/plain/admin.properties --add --allow-principal User:producer --producer --topic=test
Adding ACLs for resource `ResourcePattern(resourceType=TOPIC, name=test, patternType=LITERAL)`:
 	(principal=User:producer, host=*, operation=CREATE, permissionType=ALLOW)
	(principal=User:producer, host=*, operation=WRITE, permissionType=ALLOW)
	(principal=User:producer, host=*, operation=DESCRIBE, permissionType=ALLOW)

Current ACLs for resource `ResourcePattern(resourceType=TOPIC, name=test, patternType=LITERAL)`:
 	(principal=User:producer, host=*, operation=WRITE, permissionType=ALLOW)
	(principal=User:producer, host=*, operation=DESCRIBE, permissionType=ALLOW)
	(principal=User:producer, host=*, operation=CREATE, permissionType=ALLOW)
```

```bash
$ kafka-console-producer --broker-list localhost:9093 --producer.config producer.properties --topic test
```

* Let's fix the consumer:

```bash
$ kafka-acls --bootstrap-server localhost:9093 --command-config ~/projects/confluent/kafka-security-playbook/plain/admin.properties --add --allow-principal User:consumer --consumer --topic=test --group=group1
[2022-05-11 13:13:25,727] WARN The configuration 'sasl.jaas.config' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
Adding ACLs for resource `ResourcePattern(resourceType=TOPIC, name=test, patternType=LITERAL)`:
 	(principal=User:consumer, host=*, operation=DESCRIBE, permissionType=ALLOW)
	(principal=User:consumer, host=*, operation=READ, permissionType=ALLOW)

Adding ACLs for resource `ResourcePattern(resourceType=GROUP, name=group1, patternType=LITERAL)`:
 	(principal=User:consumer, host=*, operation=READ, permissionType=ALLOW)

Current ACLs for resource `ResourcePattern(resourceType=GROUP, name=group1, patternType=LITERAL)`:
 	(principal=User:consumer, host=*, operation=READ, permissionType=ALLOW)

Current ACLs for resource `ResourcePattern(resourceType=TOPIC, name=test, patternType=LITERAL)`:
 	(principal=User:producer, host=*, operation=CREATE, permissionType=ALLOW)
	(principal=User:producer, host=*, operation=DESCRIBE, permissionType=ALLOW)
	(principal=User:consumer, host=*, operation=DESCRIBE, permissionType=ALLOW)
	(principal=User:producer, host=*, operation=WRITE, permissionType=ALLOW)
	(principal=User:consumer, host=*, operation=READ, permissionType=ALLOW)
```

* Oops, consumer does not work yet:

```bash
$ kafka-console-consumer --bootstrap-server localhost:9093 --consumer.config consumer.properties --topic test --from-beginning

[2022-05-11 13:13:58,359] ERROR Error processing message, terminating consumer process:  (kafka.tools.ConsoleConsumer$)
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: console-consumer-54689
Processed a total of 0 messages
```

* We need to specify the consumer group 

```bash
$ kafka-console-consumer --bootstrap-server localhost:9093 --consumer.config consumer.properties --topic test --group group1 --from-beginning 
```

* List permissions

```bash
$ kafka-acls \
  --bootstrap-server localhost:9093 \
  --list \
  --command-config --command-config ~/projects/confluent/kafka-security-playbook/plain/admin.properties
  
Current ACLs for resource `ResourcePattern(resourceType=GROUP, name=group1, patternType=LITERAL)`:
 	(principal=User:consumer, host=*, operation=READ, permissionType=ALLOW)

Current ACLs for resource `ResourcePattern(resourceType=TOPIC, name=test, patternType=LITERAL)`:
 	(principal=User:producer, host=*, operation=CREATE, permissionType=ALLOW)
	(principal=User:producer, host=*, operation=DESCRIBE, permissionType=ALLOW)
	(principal=User:consumer, host=*, operation=DESCRIBE, permissionType=ALLOW)
	(principal=User:producer, host=*, operation=WRITE, permissionType=ALLOW)
	(principal=User:consumer, host=*, operation=READ, permissionType=ALLOW)  
```

* Remove permissions

```bash
$ kafka-acls --bootstrap-server localhost:9093 --command-config ~/projects/confluent/kafka-security-playbook/plain/admin.properties --remove --allow-principal User:producer --producer --topic=test
$ kafka-acls --bootstrap-server localhost:9093 --command-config ~/projects/confluent/kafka-security-playbook/plain/admin.properties --remove --allow-principal User:consumer --consumer --topic=test --group=group1
```

* Deny rule:

```bash

```
