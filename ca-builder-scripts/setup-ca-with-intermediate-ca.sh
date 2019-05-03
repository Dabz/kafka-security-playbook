#!/usr/bin/env bash

DEFAULT_PASSWORD=confluent
export CA_ROOT_DIR=`pwd`

echo "Building the CA root setup"

./utils/build-ca.sh $DEFAULT_PASSWORD

echo "Building the intemedite CA root setup:"

./utils/build-intermediate-ca.sh $DEFAULT_PASSWORD
