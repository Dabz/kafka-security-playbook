# README

This playbook is an example of configuration where Schema Registry is configured for accepting request on `http` and `https`.
Requests on the `http` endpoint are actually identified as the `ANONYMOUS` user. This is possible thanks to the `confluent.schema.registry.anonymous.principal=true` option.

The following ACLs are configured:
- `sr-acl-cli --config /etc/schema-registry/schema-registry.properties --add -s '*' -p 'ANONYMOUS' -o 'SUBJECT_READ'`
- `sr-acl-cli --config /etc/schema-registry/schema-registry.properties --add -p 'ANONYMOUS' -o 'GLOBAL_SUBJECTS_READ'`
- `sr-acl-cli --config /etc/schema-registry/schema-registry.properties --add -p 'ANONYMOUS' -o 'GLOBAL_COMPATIBILITY_READ'`
- `sr-acl-cli --config /etc/schema-registry/schema-registry.properties --add -s '*' -p 'C=UK,O=Confluent,L=London,CN=schema-registry' -o '*'`

With this configuration, ` curl  -X GET http://localhost:8089/subjects/` is successful, but the `ANONYMOUS` user does not have the privileges to write new schemas.
Only the client with the TLS client certificate `C=UK,O=Confluent,L=London,CN=schema-registry` can write new schemas, this could be for example your CI tool or an admin user.
