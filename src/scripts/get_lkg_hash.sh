#!/bin/bash
CIRCLE_FETCH_PAGE_SIZE=100
CIRCLE_FETCH_MAX_PAGES=100
response=""
function get_recent_builds() {
    offset=$(($1*CIRCLE_FETCH_PAGE_SIZE))
    url="https://circleci.com/api/v1/project/kr-project/experimental/tree/gv-ci-alerts?circle-token=2792acd76580898bb91df9a550692be18c0f559f&limit=100&offset=0&filter=successful"

    # url="https://circleci.com/api/v1/project/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/tree/${CIRCLE_BRANCH}?circle-token=${CIRCLE_TOKEN}&limit=100&offset=${offset}&filter=successful"

    response=$(curl -s "$url" | jq '.')
    response_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
}

function run_main() {
    latest_build_num=0
    latest_git_hash=""
    job_name="coda-user"
    page=0
    DIFF_URL=""

    # while latest hash still not found and pages gone through less than max page search
    while [[ $latest_git_hash == "" ]] && [[ $page < $CIRCLE_FETCH_MAX_PAGES ]]
    do
        # get response json of the page and parse
        get_recent_builds $page
        if [[ $response_code != 200 ]]; then 
            echo "Error: CircleCI page not found"
            exit 0
        fi
        for build in $(echo "'$response'" | jq -c '.[]')
        do
            # if [[ $(echo "$build" | jq -r '.outcome') != "success" ]]; then
            #     continue
            # fi
            # if [[ $(echo "$build" | grep 'workflows') == "" ]]; then 
            #     continue 
            # fi 
            echo $(echo "'$build'" | jq  -c -r '.')
            # echo $(echo "$build" | jq  -r '.build_num')
            # if (( $(echo "$build" | jq  -r '.build_num') > latest_build_num )) && [[ $(echo "$build" | jq -r '.workflows.job_name') == "$job_name" ]]; then
            #     latest_build_num=$(echo "$build" | jq -r '.build_num') 
            #     latest_git_hash=$(echo "$build" | jq -r '.vcs_revision')
            # fi
        done
        if [ -z "$latest_git_hash" ]; then
            # if latest_git_hash is empty then increase page and keep looking
            page=$((page+1))
        fi
    done
    if [ -n "$latest_git_hash" ]; then
        # if latest_git_hash was found set DIFF_URL
        #DIFF_URl is printed for bats test, exported for ci
        DIFF_URL="https://github.com/kr-project/${CIRCLE_PROJECT_REPONAME}/compare/${latest_git_hash}...${CIRCLE_SHA1}"
        echo "export DIFF_URL=$DIFF_URL" >> "$BASH_ENV"
        echo "$DIFF_URL"
    else
        echo "No last good commit hash for this branch"
    fi
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    run_main
fi
