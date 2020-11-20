# Runs prior to every test
setup() {
    # Load our script file.
    source ./src/scripts/fetch_user_handles.sh
}
  CODA_USER_ROSTER_TABLE_URL:
    description: |
      Fully qualified API URL to a table containing CIRCLECI_USERNAMEs to email aliases.    Must be of the form
      https://coda.io/apis/v1/docs/<DOCID>/tables/<TABLEID>/rows.
    type: string
    default: 
  coda_api_token:
    description: |
      Env var of a token granted read access to the CODA_USER_ROSTER_TABLE_URL document.
    type: string
    default: ${STAGING_CODA_TOKEN}
  CODA_CIRCLECI_USER_NAME_COL:
    description: |
      Coda columnId of the column storing the CircleCI username in the CODA_USER_ROSTER_TABLE_URL document.
    type: string
    default: c-6ni4kHGNwE

  EMAIL_DOMAIN:
    description: |
      Optional email domain for users within the workspace.   Must be specified if user aliases are not fully qualified.
    type: string
    default: coda.io
  slack_bot_token:
    type: string
    description: |
      Token used by Slack bot application.   Must have scopes `users:read`, `users:read.email`, and `chat:write`.
    default: ${PUSH_REMINDER_BOT_TOKEN}

@test '2: Check Coda Email Exists' {
    export CIRCLE_USERNAME="gita-v"
    export CODA_API_TOKEN=$STAGING_CODA_API_TOKEN
    export CODA_CIRCLECI_USER_ALIAS_COL="c-26If9Zttyp"
    export CODA_CIRCLECI_USER_NAME_COL="c-6ni4kHGNwE"
    export CODA_USER_ROSTER_TABLE_URL="https://staging.coda.io/apis/v1/docs/s2i6oFeghW/tables/grid-QGyaiXZDwu/rows"
    export EMAIL_DOMAIN="coda.io"
    result=$(run_main)
    [[ "$result" == *"gita@coda.io"* ]]
}

@test '3: Check Coda Email DNE' {
    export CIRCLE_USERNAME="nonexistant_user"
    export CODA_API_TOKEN=$STAGING_CODA_API_TOKEN
    export CODA_CIRCLECI_USER_ALIAS_COL="c-26If9Zttyp"
    export CODA_CIRCLECI_USER_NAME_COL="c-6ni4kHGNwE"
    export CODA_USER_ROSTER_TABLE_URL="https://staging.coda.io/apis/v1/docs/s2i6oFeghW/tables/grid-QGyaiXZDwu/rows"
    export EMAIL_DOMAIN="coda.io"
    result=$(run_main)
    [[ "$result" != "coda@io" ]]

}

@test '4: Check Codas Slack Handle Exists' {
    export CIRCLE_USERNAME="gita-v"
    export CODA_API_TOKEN=$STAGING_CODA_API_TOKEN
    export CODA_CIRCLECI_USER_ALIAS_COL="c-26If9Zttyp"
    export CODA_CIRCLECI_USER_NAME_COL="c-6ni4kHGNwE"
    export CODA_USER_ROSTER_TABLE_URL="https://staging.coda.io/apis/v1/docs/s2i6oFeghW/tables/grid-QGyaiXZDwu/rows"
    export EMAIL_DOMAIN="coda.io"
    export SLACK_BOT_TOKEN=$PUSH_REMINDER_BOT_TOKEN
    result=$(run_main)
    [[ "$result" == *"U01DJE1DABE"* ]]
    
}