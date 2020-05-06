#!/usr/bin/env bash

input=$1
while IFS= read -r line
do
  fields=($(echo $line | tr "," "\n"))
  #./support-scripts/create-cert.sh ${fields[0]} ${fields[1]}
  echo "./support-scripts/create-cert.sh ${fields[0]} ${fields[1]}"
done < "$input"
