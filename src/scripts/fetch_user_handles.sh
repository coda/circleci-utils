#!/bin/bash
set -eo pipefail
USER_EMAIL=""
SLACK_USER_ID=""
GITHUB_SUFFIX="-codaio"
# TO DO; change w/ github migration
function run_main() {
    if [[ "$CIRCLE_USERNAME" != *"$GITHUB_SUFFIX"* ]]; then
      echo "${CIRCLE_USERNAME} has incorrect git username -- please add -codaio and update in go/roster"
      exit 0
    fi
     # shellcheck disable=SC2001
    USER_EMAIL=$(echo "${CIRCLE_USERNAME}" | sed "s/${GITHUB_SUFFIX}$/@${EMAIL_DOMAIN}/")

    if [ -n "$SLACK_BOT_TOKEN" ]; then
        SLACK_USER_ID=$(curl -s -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
            "https://slack.com/api/users.lookupByEmail?email=${USER_EMAIL}" \
            | jq -r '.user.id')
    fi
    
    # need to echo result for bats test to capture
    echo "$USER_EMAIL"
    echo "$SLACK_USER_ID"
    # need to export for rest of steps to pick it up
    echo "export USER_EMAIL=${USER_EMAIL}" >> "$BASH_ENV"
    echo "export SLACK_USER_ID=${SLACK_USER_ID}" >> "$BASH_ENV"
}
# Will not run if sourced for bats.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    run_main
fi
