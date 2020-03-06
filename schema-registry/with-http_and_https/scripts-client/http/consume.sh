#!/usr/bin/env bash

docker-compose exec -T schema-registry kafka-avro-console-consumer --topic topic  --from-beginning \
  --bootstrap-server kafka:29092 \
  --property schema.registry.url=http://schema-registry:8081
