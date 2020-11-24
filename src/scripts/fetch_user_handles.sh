#!/bin/bash
set -eo pipefail
USER_EMAIL=""
function run_main() {
    USER_ALIAS=$(curl -s -H "Authorization: Bearer ${CODA_API_TOKEN}" \
    -G --data-urlencode "query=${CODA_CIRCLECI_USER_NAME_COL}:\"${CIRCLE_USERNAME}\"" \
    "${CODA_USER_ROSTER_TABLE_URL}" \
    | jq --arg CODA_CIRCLECI_USER_ALIAS_COL "$CODA_CIRCLECI_USER_ALIAS_COL" '.items[0].values."'"$CODA_CIRCLECI_USER_ALIAS_COL"'"' | tr -d '"')

    if [ "$USER_ALIAS" != "null" ]; then
        USER_EMAIL=$([[ "${USER_ALIAS}" == *@* ]] && echo "$USER_ALIAS" || echo "${USER_ALIAS}@${EMAIL_DOMAIN}")
        echo "$USER_EMAIL"
        echo "export USER_EMAIL=${USER_EMAIL}" >> "$BASH_ENV"
    else
        echo "export USER_EMAIL=false" >> "$BASH_ENV"
    fi
    
    if [ -n "$SLACK_BOT_TOKEN" ]; then 
        echo "$USER_EMAIL"
        SLACK_USER_ID=$(curl -s -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
            "https://slack.com/api/users.lookupByEmail?email=${USER_EMAIL}" \
            | jq '.user.id' | tr -d '"')
        echo "$SLACK_USER_ID"
        echo "export SLACK_USER_ID=${SLACK_USER_ID}" >> "$BASH_ENV"
    else
        echo "export SLACK_USER_ID=false" >> "$BASH_ENV"

    fi
}

# Will not run if sourced for bats.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    run_main
fi