setup() {
    export CTX_AWS_BASE_64_CREDS_TEST=Q3JlZHMgVGVzdCAxMjM=

    source ./src/scripts/bootstrap_aws_context_creds.sh
}

@test '1: Unpack test variable' {
    $(run_main)
    first_line=$(head -n 1 ~/.aws/credentials)
    [[ "$first_line" == "Creds Test 123" ]]
}
