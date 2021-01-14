#!/bin/bash
set -eo pipefail
USER_EMAIL=""
SLACK_USER_ID=""
# TO DO; change w/ github migration
GITHUB_API="https://api.github.com/repos/kr-project/${CIRCLE_PROJECT_REPONAME}"
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

        #get pull requests from pr
        GITHUB_PRS_FROM_COMMIT=$(curl -s "${GITHUB_API}/commits/${CIRCLE_SHA1}/pulls" \
          -H "Accept: application/vnd.github.groot-preview+json" \
          -H "Authorization: Bearer ${GITHUB_TOKEN}")

        # get first pr number from list pull requests
        GITHUB_PR_NUMBER=$(echo "$GITHUB_PRS_FROM_COMMIT" | tr '\r\n' ' ' | jq '.[0].number')
        # get associated information from that pr
        GITHUB_GET_PR=$(curl -s "${GITHUB_API}/pulls/${GITHUB_PR_NUMBER}" \
        -H "Authorization: Bearer ${GITHUB_TOKEN}")
        # get the author of that pr
        PR_AUTHOR=$(echo "$GITHUB_GET_PR" | jq '.user.login')
        # if it is not a bot then set it as the look up user from table
        if [[ "$PR_AUTHOR" != *"[bot]"* ]]; then
          LOOKUP_USER=$PR_AUTHOR
        else #else get the reviewer of that pr
          GITHUB_GET_PR_REVIEWERS=$(curl -s "${GITHUB_API}/pulls/${GITHUB_PR_NUMBER}/reviews" \
          -H "Authorization: token ${GITHUB_TOKEN}")
          # and get the first reviewer of that pr
          LOOKUP_USER=$(echo "$GITHUB_GET_PR_REVIEWERS" | jq '.[0].user.login')
        fi

        # look up email of Codan using Author name from github
        TABLE_INFO=$(curl -s -H "Authorization: Bearer ${CODA_API_TOKEN}" \
          -G --data-urlencode "query=${CODA_GITHUB_COL}:\"${LOOKUP_USER}\"" \
          "${CODA_USER_ROSTER_TABLE_URL}")

        # look up the email from that Codan
        USER_EMAIL=$(echo "$TABLE_INFO" | \
        jq --arg CODA_USER_EMAIL_COL "$CODA_USER_EMAIL_COL" \
        '.items[0].values."'"$CODA_USER_EMAIL_COL"'"' | \
        tr -d '"')
        # potentially null if dependabot
        if [ "$USER_EMAIL" == "null" ]; then
            USER_EMAIL=""
        fi
    fi

    if [ -n "$SLACK_BOT_TOKEN" ]; then
        SLACK_USER_ID=$(curl -s -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
            "https://slack.com/api/users.lookupByEmail?email=${USER_EMAIL}" \
            | jq '.user.id' | tr -d '"')
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
