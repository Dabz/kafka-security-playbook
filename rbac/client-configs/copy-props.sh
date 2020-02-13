#!/bin/bash
first=$1
second=$2

cp ${first}.properties ${second}.properties
sed -i '' "s/${first}/${second}/g" ${second}.properties
