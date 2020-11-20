#!/bin/bash
set -eo pipefail
CODA_CIRCLECI_USER_NAME_COL="c-6ni4kHGNwE"
CODA_CIRCLECI_USER_ALIAS_COL="c-26If9Zttyp"
USER_EMAIL=""
CIRCLE_USERNAME=$CIRCLE_USERNAME
SLACK_BOT_TOKEN=$PUSH_REMINDER_BOT_TOKEN
function run_main() {
    USER_ALIAS=$(curl -s -H "Authorization: Bearer ${CODA_API_TOKEN}" \
    -G --data-urlencode "query=${CODA_CIRCLECI_USER_NAME_COL}:\"${CIRCLE_USERNAME}\"" \
    'https://staging.coda.io/apis/v1/docs/s2i6oFeghW/tables/grid-QGyaiXZDwu/rows' \
    | jq --arg CODA_CIRCLECI_USER_ALIAS_COL "$CODA_CIRCLECI_USER_ALIAS_COL" '.items[0].values."'$CODA_CIRCLECI_USER_ALIAS_COL'"' | tr -d '"')
    if [ "$USER_ALIAS" != "null" ]; then
        USER_EMAIL=$([[ "${USER_ALIAS}" == *@* ]] && echo "$USER_ALIAS" || echo "${USER_ALIAS}@coda.io")
        echo "$USER_EMAIL"
        echo "export USER_EMAIL=${USER_EMAIL}" >> "$BASH_ENV"
        
    fi
    
    if [ -n "$SLACK_BOT_TOKEN" ]; then 
        SLACK_USER_ID=$(curl -s -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
            "https://slack.com/api/users.lookupByEmail?email=${USER_EMAIL}" \
            | jq '.user.id' | tr -d '"')
        echo "export SLACK_USER_ID=${SLACK_USER_ID}" >> "$BASH_ENV"
    fi
}

ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    run_main
fi