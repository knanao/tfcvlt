#!/bin/bash

set -e

eval "$(jq -r '@sh "CREDENTIALS=\(.credentials)"')"

VAL="${CREDENTIALS}"

sleep 5

jq -n --arg val "${VAL}" '{"credentials":$val}'
