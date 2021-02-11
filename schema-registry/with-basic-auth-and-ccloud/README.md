## Pre-Reqs

1. CCloud Service Account
2. CCloud API Key and Secret for Service Account
3. Service Account authorized to read/write/create the following topics. You can pre-create these topics if you'd like to reduce the AuthO rules to just read/write.
   - `_confluent-license` - License Topic
   - `schemas-security-plugin` - Schemas Topic
   - `schemas-security-plugin_acl` - ACLs Topic
4. The following Env Vars Defined
   -  `CLUSTER_BOOTSTRAP_SERVERS`
   -  `CLUSTER_API_KEY`
   -  `CLUSTER_API_SECRET`

### Sample Commands

*Create ACLs Needed in CCloud*
```
ccloud kafka acl create --allow --service-account ... --operation READ --operation WRITE --operation CREATE --operation DESCRIBE --operation DESCRIBE-CONFIGS --topic schemas-security-plugin
ccloud kafka acl create --allow --service-account ... --operation READ --operation WRITE --operation CREATE --operation DESCRIBE --operation DESCRIBE-CONFIGS --topic schemas-security-plugin_acl
ccloud kafka acl create --allow --service-account 181693 --operation READ --operation WRITE --operation CREATE --operation DESCRIBE --operation DESCRIBE-CONFIGS --topic _confluent-license
ccloud kafka acl create --allow --service-account 181693 --operation READ --operation WRITE --consumer-group schema-registry
```

*Define Env Vars*
```
export CLUSTER_BOOTSTRAP_SERVERS="....confluent.cloud:9092"
export CLUSTER_API_KEY="..."
export CLUSTER_API_SECRET="..."
```

## Users

| User  | Pass  | Desc                |
|-------|-------|---------------------|
| read  | read  | Global Read Access  |
| write | write | Global Write Access |
| admin | admin | Global Admin Access |