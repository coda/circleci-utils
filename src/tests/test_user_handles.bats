# Runs prior to every test
setup() {
    # Load our script file.
    source ./src/scripts/fetch_user_handles.sh
}

@test '2: Check Coda Email Exists' {
    export CIRCLE_USERNAME="gita-codaio"
    export EMAIL_DOMAIN="coda.io"
    result=$(run_main)
    [[ "$result" == *"gita@coda.io"* ]]
}

@test '3: Check Coda Email DNE' {
    export CIRCLE_USERNAME="nonexistant_user"
    export EMAIL_DOMAIN="coda.io"
    result=$(run_main)
    [[ "$result" != "@coda.io" ]]
}

@test '4: Check Codas Slack Handle Exists' {
    export CIRCLE_USERNAME="gita-codaio"
    export EMAIL_DOMAIN="coda.io"
    export SLACK_BOT_TOKEN=$PUSH_REMINDER_BOT_TOKEN
    result=$(run_main)
    [[ "$result" == *"U01DJE1DABE"* ]]
}
