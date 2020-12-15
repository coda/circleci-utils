#!/bin/bash
set -eo pipefail
USER_EMAIL=""
SLACK_USER_ID=""
function run_main() {
    # fetch all user information from coda doc
    TABLE_INFO=$(curl -s -H "Authorization: Bearer ${CODA_API_TOKEN}" \
      -G --data-urlencode "query=${CODA_CIRCLECI_USER_NAME_COL}:\"${CIRCLE_USERNAME}\"" \
      "${CODA_USER_ROSTER_TABLE_URL}")
    # parse username from coda table
    USER_ALIAS=$(echo "$TABLE_INFO" | \
      jq --arg CODA_CIRCLECI_USER_ALIAS_COL "$CODA_CIRCLECI_USER_ALIAS_COL" \
      '.items[0].values."'"$CODA_CIRCLECI_USER_ALIAS_COL"'"' | \
      tr -d '"')

    if [ "$USER_ALIAS" != "null" ]; then
        USER_EMAIL=$([[ "${USER_ALIAS}" == *@* ]] && echo "$USER_ALIAS" || echo "${USER_ALIAS}@${EMAIL_DOMAIN}")
        echo "$USER_EMAIL"
        echo "export USER_EMAIL=${USER_EMAIL}" >> "$BASH_ENV"
    fi

    if [ -n "$SLACK_BOT_TOKEN" ]; then
        echo "$USER_EMAIL"
        SLACK_USER_ID=$(curl -s -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
            "https://slack.com/api/users.lookupByEmail?email=${USER_EMAIL}" \
            | jq '.user.id' | tr -d '"')
        echo "$SLACK_USER_ID"
        echo "export SLACK_USER_ID=${SLACK_USER_ID}" >> "$BASH_ENV"
    fi
}

# Will not run if sourced for bats.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    run_main
fi
