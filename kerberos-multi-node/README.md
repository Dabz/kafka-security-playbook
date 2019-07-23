# Kerberos multi-node deployment example

This example shows how-to deploy multiple kafka nodes in an example kerberos enabled environment.

The only thing that's different then your normal environment is that this example uses a different principal for each zookeeper client.

https://issues.apache.org/jira/browse/KAFKA-7710 Jira contains a more information.  
TLDR; we have to set two configs in the zookeeper.properties to make this work

```
kerberos.removeHostFromPrincipal = true
kerberos.removeRealmFromPrincipal = false
```

The first removes the hostname from the principal name.  
So that anyone authenticated with the principal 'kafka/*@REALM' is allowed by ZK ACLs.