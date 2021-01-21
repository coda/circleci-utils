# Runs prior to every test
setup() {
    # Load our script file.
    source ./src/scripts/fetch_user_handles.sh
}

@test '2: Check Coda Email Exists' {
    export CIRCLE_USERNAME="gita-v"
    export CODA_PROD_TOKEN=$CODA_PROD_TOKEN
    export CODA_CIRCLECI_USER_NAME_COL="c-HWxgJukgCs"
    export CODA_USER_EMAIL_COL="c-l3XSvkG3vB"
    export CODA_GITHUB_COL="c-HWxgJukgCs"
    export CODA_USER_ROSTER_TABLE_URL="https://coda.io/apis/v1/docs/CBRzjlr8md/tables/table-x-ueLEkU_Q/rows"
    result=$(run_main)
    [[ "$result" == *"gita@coda.io"* ]]
}

@test '3: Check Coda Email DNE' {
    export CIRCLE_USERNAME="nonexistant_user"
    export CODA_PROD_TOKEN=$CODA_PROD_TOKEN
    export CODA_CIRCLECI_USER_NAME_COL="c-HWxgJukgCs"
    export CODA_USER_EMAIL_COL="c-l3XSvkG3vB"
    export CODA_GITHUB_COL="c-HWxgJukgCs"
    export CODA_USER_ROSTER_TABLE_URL="https://coda.io/apis/v1/docs/CBRzjlr8md/tables/table-x-ueLEkU_Q/rows"
    result=$(run_main)
    [[ "$result" != "coda@io" ]]

}

@test '4: Check Codas Slack Handle Exists' {
    export CIRCLE_USERNAME="gita-v"
    export CODA_PROD_TOKEN=$CODA_PROD_TOKEN
    export CODA_CIRCLECI_USER_NAME_COL="c-HWxgJukgCs"
    export CODA_USER_EMAIL_COL="c-l3XSvkG3vB"
    export CODA_GITHUB_COL="c-HWxgJukgCs"
    export CODA_USER_ROSTER_TABLE_URL="https://coda.io/apis/v1/docs/CBRzjlr8md/tables/table-x-ueLEkU_Q/rows"
    export SLACK_BOT_TOKEN=$PUSH_REMINDER_BOT_TOKEN
    result=$(run_main)
    [[ "$result" == *"U01DJE1DABE"* ]]

}
