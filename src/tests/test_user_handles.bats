# Runs prior to every test
setup() {
    # Load our script file.
    source ./src/scripts/fetch_user_handles.sh
}


@test '2: Check Coda Email Exists' {
    export CIRCLE_USERNAME="gita-v"
    export CODA_API_TOKEN=$CODA_API_TOKEN
    export CODA_CIRCLECI_USER_ALIAS_COL="c-26If9Zttyp"
    export CODA_CIRCLECI_USER_NAME_COL="c-6ni4kHGNwE"
    export CODA_USER_EMAIL_COL="c-JXKd1-s5HB"
    export CODA_CIRCLECI_USER_NAME_COL="c-RJw2-9igCT"
    export GITHUB_TOKEN=$GITHUB_TOKEN
    export CODA_USER_ROSTER_TABLE_URL="https://staging.coda.io/apis/v1/docs/s2i6oFeghW/tables/grid-QGyaiXZDwu/rows"
    result=$(run_main)
    [[ "$result" == *"gita@coda.io"* ]]
}

@test '3: Check Coda Email DNE' {
    export CIRCLE_USERNAME="nonexistant_user"
    export CODA_API_TOKEN=$CODA_API_TOKEN
    export CODA_CIRCLECI_USER_ALIAS_COL="c-26If9Zttyp"
    export CODA_CIRCLECI_USER_NAME_COL="c-6ni4kHGNwE"
    export CODA_USER_EMAIL_COL="c-JXKd1-s5HB"
    export CODA_CIRCLECI_USER_NAME_COL="c-RJw2-9igCT"
    export GITHUB_TOKEN=$GITHUB_TOKEN
    export CIRCLE_PR_REPONAME=$CIRCLE_PR_REPONAME
    export CIRCLE_SHA1=$CIRCLE_SHA1
    export CODA_USER_ROSTER_TABLE_URL="https://staging.coda.io/apis/v1/docs/s2i6oFeghW/tables/grid-QGyaiXZDwu/rows"
    result=$(run_main)
    [[ "$result" != "coda@io" ]]

}

@test '4: Check Codas Slack Handle Exists' {
    export CIRCLE_USERNAME="gita-v"
    export CODA_API_TOKEN=$CODA_API_TOKEN
    export CODA_CIRCLECI_USER_ALIAS_COL="c-26If9Zttyp"
    export CODA_CIRCLECI_USER_NAME_COL="c-6ni4kHGNwE"
    export CODA_USER_EMAIL_COL="c-JXKd1-s5HB"
    export CODA_CIRCLECI_USER_NAME_COL="c-RJw2-9igCT"
    export GITHUB_TOKEN=$GITHUB_TOKEN
    export CODA_USER_ROSTER_TABLE_URL="https://staging.coda.io/apis/v1/docs/s2i6oFeghW/tables/grid-QGyaiXZDwu/rows"
    export SLACK_BOT_TOKEN=$PUSH_REMINDER_BOT_TOKEN
    result=$(run_main)
    [[ "$result" == *"U01DJE1DABE"* ]]

}
