# Kafka Audit Log

This playbook add an example of using the confluent audit log trail.
The present example works with SASL/SCRAM but this example can be extended to other authentication methods such as RBAC, other SASL flavours or TLS.

## Playbook.

1.- start all the components running the _./up_ script.

```bash
./up
Creating zookeeper ... done
Creating kafka     ... done
Completed updating config for entity: user-principal 'kafka'.
Completed updating config for entity: user-principal 'consumer'.
Completed updating config for entity: user-principal 'producer'.
[2020-05-12 12:20:50,405] WARN The configuration 'sasl.jaas.config' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
Adding ACLs for resource `ResourcePattern(resourceType=TOPIC, name=*, patternType=LITERAL)`:
 	(principal=User:producer, host=*, operation=DESCRIBE, permissionType=ALLOW)
	(principal=User:producer, host=*, operation=WRITE, permissionType=ALLOW)
	(principal=User:producer, host=*, operation=CREATE, permissionType=ALLOW)

[2020-05-12 12:20:51,026] WARN The configuration 'sasl.jaas.config' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
Current ACLs for resource `ResourcePattern(resourceType=TOPIC, name=*, patternType=LITERAL)`:
 	(principal=User:producer, host=*, operation=DESCRIBE, permissionType=ALLOW)
	(principal=User:producer, host=*, operation=CREATE, permissionType=ALLOW)
	(principal=User:producer, host=*, operation=WRITE, permissionType=ALLOW)

[2020-05-12 12:20:53,986] WARN The configuration 'sasl.jaas.config' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
Adding ACLs for resource `ResourcePattern(resourceType=TOPIC, name=*, patternType=LITERAL)`:
 	(principal=User:consumer, host=*, operation=DESCRIBE, permissionType=ALLOW)
	(principal=User:consumer, host=*, operation=READ, permissionType=ALLOW)

Adding ACLs for resource `ResourcePattern(resourceType=GROUP, name=*, patternType=LITERAL)`:
 	(principal=User:consumer, host=*, operation=READ, permissionType=ALLOW)

[2020-05-12 12:20:54,538] WARN The configuration 'sasl.jaas.config' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
Current ACLs for resource `ResourcePattern(resourceType=TOPIC, name=*, patternType=LITERAL)`:
 	(principal=User:producer, host=*, operation=CREATE, permissionType=ALLOW)
	(principal=User:producer, host=*, operation=DESCRIBE, permissionType=ALLOW)
	(principal=User:consumer, host=*, operation=DESCRIBE, permissionType=ALLOW)
	(principal=User:producer, host=*, operation=WRITE, permissionType=ALLOW)
	(principal=User:consumer, host=*, operation=READ, permissionType=ALLOW)

Current ACLs for resource `ResourcePattern(resourceType=GROUP, name=*, patternType=LITERAL)`:
 	(principal=User:consumer, host=*, operation=READ, permissionType=ALLOW)

[2020-05-12 12:20:57,354] WARN The configuration 'sasl.jaas.config' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
Adding ACLs for resource `ResourcePattern(resourceType=TOPIC, name=confluent-audit-log-events, patternType=PREFIXED)`:
 	(principal=User:confluent-audit, host=*, operation=DESCRIBE, permissionType=ALLOW)
	(principal=User:confluent-audit, host=*, operation=WRITE, permissionType=ALLOW)
	(principal=User:confluent-audit, host=*, operation=CREATE, permissionType=ALLOW)

[2020-05-12 12:20:57,928] WARN The configuration 'sasl.jaas.config' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
Current ACLs for resource `ResourcePattern(resourceType=TOPIC, name=confluent-audit-log-events, patternType=PREFIXED)`:
 	(principal=User:confluent-audit, host=*, operation=WRITE, permissionType=ALLOW)
	(principal=User:confluent-audit, host=*, operation=DESCRIBE, permissionType=ALLOW)
	(principal=User:confluent-audit, host=*, operation=CREATE, permissionType=ALLOW)

Example configuration:
-> docker-compose exec kafka kafka-console-producer --broker-list kafka:9092 --producer.config /etc/kafka/producer-user.properties --topic test
-> docker-compose exec kafka kafka-console-consumer --bootstrap-server kafka:9092 --consumer.config /etc/kafka/consumer-user.properties --topic test --from-beginning
```

2.- Explore the currently created topics.

```
./scripts/describe-topics.sh
[2020-05-12 12:21:55,868] WARN The configuration 'sasl.jaas.config' was supplied but isn't a known config. (org.apache.kafka.clients.admin.AdminClientConfig)
Topic: _confluent-license	PartitionCount: 1	ReplicationFactor: 1	Configs: min.insync.replicas=1,cleanup.policy=compact
	Topic: _confluent-license	Partition: 0	Leader: 1	Replicas: 1	Isr: 1	Offline:
Topic: __confluent.support.metrics	PartitionCount: 1	ReplicationFactor: 1	Configs: retention.ms=31536000000
	Topic: __confluent.support.metrics	Partition: 0	Leader: 1	Replicas: 1	Isr: 1	Offline:
Topic: confluent-audit-log-events	PartitionCount: 12	ReplicationFactor: 1	Configs: retention.ms=7776000000,message.timestamp.type=CreateTime,retention.bytes=-1,segment.ms=14400000
	Topic: confluent-audit-log-events	Partition: 0	Leader: 1	Replicas: 1	Isr: 1	Offline:
	Topic: confluent-audit-log-events	Partition: 1	Leader: 1	Replicas: 1	Isr: 1	Offline:
	Topic: confluent-audit-log-events	Partition: 2	Leader: 1	Replicas: 1	Isr: 1	Offline:
	Topic: confluent-audit-log-events	Partition: 3	Leader: 1	Replicas: 1	Isr: 1	Offline:
	Topic: confluent-audit-log-events	Partition: 4	Leader: 1	Replicas: 1	Isr: 1	Offline:
	Topic: confluent-audit-log-events	Partition: 5	Leader: 1	Replicas: 1	Isr: 1	Offline:
	Topic: confluent-audit-log-events	Partition: 6	Leader: 1	Replicas: 1	Isr: 1	Offline:
	Topic: confluent-audit-log-events	Partition: 7	Leader: 1	Replicas: 1	Isr: 1	Offline:
	Topic: confluent-audit-log-events	Partition: 8	Leader: 1	Replicas: 1	Isr: 1	Offline:
	Topic: confluent-audit-log-events	Partition: 9	Leader: 1	Replicas: 1	Isr: 1	Offline:
	Topic: confluent-audit-log-events	Partition: 10	Leader: 1	Replicas: 1	Isr: 1	Offline:
	Topic: confluent-audit-log-events	Partition: 11	Leader: 1	Replicas: 1	Isr: 1	Offline:
```

3.- Explore the audit log topics

```
./scripts/explore-audit-topic.sh


```
empty at the beginning.

Keep this open and it will start showing the generated events as we're issuing them.


4.- Create some topics and acls.

```
./scripts/create-topics.sh
Create topic foo with User:kafka
NOTE: this topic creation will be ignored because uses a user inside the ignore list.
Created topic foo.
Create topic bar with User:producer
NOTE: This action will be noted in the audit log.

Created topic bar.
Adding ACLs for resource `ResourcePattern(resourceType=TOPIC, name=bar, patternType=LITERAL)`:
 	(principal=User:producer, host=*, operation=ALTER_CONFIGS, permissionType=ALLOW)

Current ACLs for resource `ResourcePattern(resourceType=TOPIC, name=bar, patternType=LITERAL)`:
 	(principal=User:producer, host=*, operation=ALTER_CONFIGS, permissionType=ALLOW)
Adding ACLs for resource `ResourcePattern(resourceType=TOPIC, name=bar, patternType=LITERAL)`:
 	(principal=User:producer, host=*, operation=DELETE, permissionType=ALLOW)
Current ACLs for resource `ResourcePattern(resourceType=TOPIC, name=bar, patternType=LITERAL)`:
 	(principal=User:producer, host=*, operation=ALTER_CONFIGS, permissionType=ALLOW)
	(principal=User:producer, host=*, operation=DELETE, permissionType=ALLOW)

Change of a configuration
NOTE: This action will be noted in the audit log.

Completed updating config for topic bar.
```

Now the audit log topic should reflect the information about the generated actions.

```
./scripts/explore-audit-topic.sh
{"data":{"serviceName":"crn:///kafka=STOiZ_jWTxqgum3T5zEoqA","methodName":"kafka.CreateTopics","resourceName":"crn:///kafka=STOiZ_jWTxqgum3T5zEoqA/topic=bar","authenticationInfo":{"principal":"User:producer"},"authorizationInfo":{"granted":true,"operation":"Create","resourceType":"Topic","resourceName":"bar","patternType":"LITERAL","aclAuthorization":{"permissionType":"ALLOW","host":"*"}},"request":{"correlation_id":"4","client_id":"adminclient-1"},"requestMetadata":{"client_address":"/172.27.0.3"}},"id":"b17cc9c7-96f0-413a-b94c-124e21834a55","source":"crn:///kafka=STOiZ_jWTxqgum3T5zEoqA","specversion":"0.3","type":"io.confluent.kafka.server/authorization","time":"2020-05-12T12:24:37.838Z","datacontenttype":"application/json","subject":"crn:///kafka=STOiZ_jWTxqgum3T5zEoqA/topic=bar","confluentRouting":{"route":"confluent-audit-log-events"}}
{"data":{"serviceName":"crn:///kafka=STOiZ_jWTxqgum3T5zEoqA","methodName":"kafka.IncrementalAlterConfigs","resourceName":"crn:///kafka=STOiZ_jWTxqgum3T5zEoqA/topic=bar","authenticationInfo":{"principal":"User:producer"},"authorizationInfo":{"granted":true,"operation":"AlterConfigs","resourceType":"Topic","resourceName":"bar","patternType":"LITERAL","aclAuthorization":{"permissionType":"ALLOW","host":"*"}},"request":{"correlation_id":"4","client_id":"adminclient-1"},"requestMetadata":{"client_address":"/172.27.0.3"}},"id":"93e94659-8b45-4f44-b691-f284192ebe42","source":"crn:///kafka=STOiZ_jWTxqgum3T5zEoqA","specversion":"0.3","type":"io.confluent.kafka.server/authorization","time":"2020-05-12T12:24:47.700Z","datacontenttype":"application/json","subject":"crn:///kafka=STOiZ_jWTxqgum3T5zEoqA/topic=bar","confluentRouting":{"route":"confluent-audit-log-events"}}
```

5.- Write some messages

```
./scripts/write-msg.sh bar
Write messages to topic bar
```

More messages coming into the audit log.

```
{"data":{"serviceName":"crn:///kafka=STOiZ_jWTxqgum3T5zEoqA","methodName":"kafka.Produce","resourceName":"crn:///kafka=STOiZ_jWTxqgum3T5zEoqA/topic=bar","authenticationInfo":{"principal":"User:producer"},"authorizationInfo":{"granted":true,"operation":"Write","resourceType":"Topic","resourceName":"bar","patternType":"LITERAL","aclAuthorization":{"permissionType":"ALLOW","host":"*"}},"request":{"correlation_id":"6","client_id":"rdkafka"},"requestMetadata":{"client_address":"/172.27.0.4"}},"id":"7789d492-df1c-404a-b494-3dc44fb01b24","source":"crn:///kafka=STOiZ_jWTxqgum3T5zEoqA","specversion":"0.3","type":"io.confluent.kafka.server/authorization","time":"2020-05-12T12:26:49.353Z","datacontenttype":"application/json","subject":"crn:///kafka=STOiZ_jWTxqgum3T5zEoqA/topic=bar","confluentRouting":{"route":"confluent-audit-log-events"}}
```

6.- Delete of messages

```
./scripts/delete-records.sh
Executing records delete operation
Records delete operation completed:
partition: bar-0	low_watermark: 3
```

new messages in the audit trail.

```
{"data":{"serviceName":"crn:///kafka=STOiZ_jWTxqgum3T5zEoqA","methodName":"kafka.DeleteRecords","resourceName":"crn:///kafka=STOiZ_jWTxqgum3T5zEoqA/topic=bar","authenticationInfo":{"principal":"User:producer"},"authorizationInfo":{"granted":true,"operation":"Delete","resourceType":"Topic","resourceName":"bar","patternType":"LITERAL","aclAuthorization":{"permissionType":"ALLOW","host":"*"}},"request":{"correlation_id":"4","client_id":"adminclient-1"},"requestMetadata":{"client_address":"/172.27.0.3"}},"id":"f6664ede-fbd4-4425-873a-d31df5eb0b7f","source":"crn:///kafka=STOiZ_jWTxqgum3T5zEoqA","specversion":"0.3","type":"io.confluent.kafka.server/authorization","time":"2020-05-12T12:27:34.425Z","datacontenttype":"application/json","subject":"crn:///kafka=STOiZ_jWTxqgum3T5zEoqA/topic=bar","confluentRouting":{"route":"confluent-audit-log-events"}}
```

## More information

This is only a summary and playbook of this functionality, more intel can be found in the reference documentation.

1.- https://docs.confluent.io/current/security/audit-logs.html
