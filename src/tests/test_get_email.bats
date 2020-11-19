# Runs prior to every test
setup() {
    # Load our script file.
    source ./src/scripts/get_coda_email.sh
}


@test '2: Check Coda Email DNE' {
    export CIRCLE_USERNAME="nonexistant_user"
    result=$(run_main)
    [ "$result" == "" ]
}