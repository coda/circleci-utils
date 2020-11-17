# Runs prior to every test
setup() {
    # Load our script file.
    source ./src/scripts/
}

@test '1: Get a Diff URL' {
    # Mock environment variables or functions by exporting them (after the script has been sourced)
    export CIRCLE_BRANCH="master"
    export CIRCLE_PROJECT_REPONAME="experimental"
    export CIRCLE_JOB="commit_validation"
    result=$(LATEST_GIT_HASH)
    [ "$result" != "" ]
}