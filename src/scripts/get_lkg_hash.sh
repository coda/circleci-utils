#!/bin/bash
CIRCLE_FETCH_PAGE_SIZE=100
CIRCLE_FETCH_MAX_PAGES=100
response=""
function get_recent_builds() {
    offset=$(($1*CIRCLE_FETCH_PAGE_SIZE))
    url="https://circleci.com/api/v1/project/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/tree/${CIRCLE_BRANCH}?circle-token=${CIRCLE_TOKEN}&limit=100&offset=${offset}&filter=successful"
    http_response=$(curl --write-out '%{http_code}' --silent --output /dev/null "$url")
    if [[ $http_response != "200" ]]; then
        echo "Error: CircleCI page not found"
        exit 0
    fi
    response=$(curl "$url" | jq '.')

}

function run_main() {
    latest_build_num=0
    latest_git_hash=""
    job_name=$CIRCLE_JOB
    page=0
    DIFF_URL=""
    while [[ $latest_git_hash == "" ]] && [[ $page < $CIRCLE_FETCH_MAX_PAGES ]]
    do
        # https://unix.stackexchange.com/questions/184863/what-is-the-meaning-of-ifs-n-in-bash-scripting
        IFS=$'\n'
        get_recent_builds $page
        for build in $(echo "$response" | jq -c '.[]')
        do
            if [[ $(echo "$build" | jq -r '.outcome') != "success" ]]; then
                continue
            fi
            # To Do: Change to jq instead of grep?
            if [[ $(echo "$build" | grep 'workflows') == "" ]]; then 
                continue 
            fi 
            if (( $(echo "$build" | jq  -r '.build_num') > latest_build_num )) && [[ $(echo "$build" | jq -r '.workflows.job_name') == "$job_name" ]]; then
                latest_build_num=$(echo "$build" | jq -r '.build_num') 
                latest_git_hash=$(echo "$build" | jq -r '.vcs_revision')
            fi
        done
        if [ -z "$latest_git_hash" ]; then
            page=$((page+1))
        fi

    done
    if [ -n "$latest_git_hash" ]; then
        DIFF_URL="https://github.com/kr-project/${CIRCLE_PROJECT_REPONAME}/compare/${latest_git_hash}...${CIRCLE_SHA1}"
        echo "$DIFF_URL"
        echo "export DIFF_URL=$DIFF_URL" >> "$BASH_ENV"
    fi
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    run_main
fi
