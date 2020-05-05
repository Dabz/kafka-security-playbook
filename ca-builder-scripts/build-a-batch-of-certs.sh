#!/usr/bin/env bash

CONFIG_FILE=$1

while read data; do
  fields=($(echo $data | tr "," "\n"))
  echo "Building a cert for ${fields[0]} and ${fields[1]}"
  ./support-scripts/create-cert.sh "${fields[0]}" "${fields[1]}"
done <$CONFIG_FILE
