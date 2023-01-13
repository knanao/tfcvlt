#!/usr/bin/env bash

set -e

credentials=$(echo $1 | sed 's/\"//g')
sleep $2

echo "{\"credentials\":\"${credentials}\"}" | jq .
