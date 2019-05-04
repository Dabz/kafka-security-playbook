#!/usr/bin/env bash

##
# This script builds a Certificate Authority of the form:
# Root CA -> intermediate CA
#
# In the CA_ROOT_DIR, this script will create the necessary directory strucures
# and generate the certificates, all signed using the value provided as an
# argument to this script, or confluent by default.
##

DEFAULT_PASSWORD=DEFAULT_PASSWORD=${1:-confluent}
export CA_ROOT_DIR=`pwd`

echo -e "Building the CA root setup\n"

./utils/build-ca.sh $DEFAULT_PASSWORD

echo -e "Building the intemedite CA root setup:\n"

./utils/build-intermediate-ca.sh $DEFAULT_PASSWORD
