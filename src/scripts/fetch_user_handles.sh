#!/bin/bash
set -eo pipefail
USER_EMAIL=""
SLACK_USER_ID=""

function run_main() {
    # fetch all user information from coda doc based on users CircleCI username
    TABLE_INFO=$(curl -s -H "Authorization: Bearer ${CODA_API_TOKEN}" \
      -G --data-urlencode "query=${CODA_CIRCLECI_USER_NAME_COL}:\"${CIRCLE_USERNAME}\"" \
      "${CODA_USER_ROSTER_TABLE_URL}")
    # parse email from coda table
    USER_EMAIL=$(echo "$TABLE_INFO" | \
      jq --arg CODA_CIRCLECI_USER_ALIAS_COL "$CODA_USER_EMAIL_COL" \
      '.items[0].values."'"$CODA_USER_EMAIL_COL"'"' | \
      tr -d '"')

    # if CircleCI username returned no email (ex; bot) get author of last git commit
    if [ "$USER_EMAIL" == "null" ]; then
        # get author of the PR using last commit
        GITHUB_COMMIT_INFO=$(curl -i -s -H "Authorization: token ${GITHUB_TOKEN}" \
        "https://api.github.com/repos/kr-project/${CIRCLE_PR_REPONAME}/git/commits/${CIRCLE_SHA1}")
        AUTHOR=$(echo "$GITHUB_COMMIT_INFO" | tr '\r\n' ' '  | jq '.author.name')

        # look up email of Codan using Author name from github
        TABLE_INFO=$(curl -s -H "Authorization: Bearer ${CODA_API_TOKEN}" \
          -G --data-urlencode "query=${CODA_USER_EMAIL_COL}:\"${AUTHOR}\"" \
          "${CODA_USER_ROSTER_TABLE_URL}")
        USER_EMAIL=$(echo "$TABLE_INFO" | \
        jq --arg CODA_USER_EMAIL_COL "$CODA_USER_EMAIL_COL" \
        '.items[0].values."'"$CODA_USER_EMAIL_COL"'' | \
        tr -d '"')

        # potentially null if dependabot
        if [ "$USER_EMAIL" == "null" ]; then
            USER_EMAIL=""
        fi
        # need to echo result for bats test to capture
        echo "$USER_EMAIL"
    fi

    if [ -n "$SLACK_BOT_TOKEN" ]; then
        SLACK_USER_ID=$(curl -s -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
            "https://slack.com/api/users.lookupByEmail?email=${USER_EMAIL}" \
            | jq '.user.id' | tr -d '"')

        # need to echo result for bats test to capture
        echo "$SLACK_USER_ID"
    fi
    echo "export USER_EMAIL=${USER_EMAIL}" >> "$BASH_ENV"
    echo "export SLACK_USER_ID=${SLACK_USER_ID}" >> "$BASH_ENV"
}
# Will not run if sourced for bats.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    run_main
fi
