#!/bin/bash

function run_main() {
    rm -f ~/.aws/credentials
    mkdir -p ~/.aws
    set | grep ^CTX_AWS_BASE_64_CREDS_ | cut -d= -f2- | while read -r base64creds; do \
        echo "$base64creds" | base64 -d >> ~/.aws/credentials; \
    done;
}

function get_line() {
    read -r line < ~/.aws/credentials
    echo "$line"
}

# Will not run if sourced for bats.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    run_main
fi