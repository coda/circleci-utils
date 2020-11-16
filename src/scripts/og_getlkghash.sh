#!/bin/bash
CIRCLE_FETCH_PAGE_SIZE=100
CIRCLE_FETCH_MAX_PAGES=100
response=""
function get_recent_builds() {
    offset=$(($1*$CIRCLE_FETCH_PAGE_SIZE))
    # url_format="https://circleci.com/api/v1/project/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/tree/${CIRCLEC_BRANCH}?circle-token=${CIRCLE_LOCK_API_TOKEN}&limit=100&offset=${offset}&filter=successful"
    # url="https://circleci.com/api/v1/project/kr-project/experimental/tree/gv-ci-alerts?circle-token=f1a834f6ac40d3222412d94383a805d441ac9a31&limit=100&offset=${offset}&filter=successful"
    url="https://circleci.com/api/v1/project/kr-project/experimental/tree/gv-ci-alerts?circle-token=f1a834f6ac40d3222412d94383a805d441ac9a31&limit=100&offset=0&filter=successful"

    # url="https://circleci.com/api/v1/project/kr-project/experimental/tree/gv-ci-alerts?circle-token=f1a834f6ac40d3222412d94383a805d441ac9a31&limit=100&offset=0&filter=successful"
    response=$(curl $url | jq '.')
}

job_name="coda-user"
latest_build_num=0
latest_git_hash=""
# job_name=$CIRCLE_JOB
# && [[ $(echo $build | jq  '.workflows.job_name') == $job_name ]]; 
page=0
i=0
while [[ $latest_git_hash == "" ]] && [[ $page < $CIRCLE_FETCH_MAX_PAGES ]]
do
    # echo $i
    i=$((i+1))
    IFS=$'\n'
    get_recent_builds $page
    for build in $(echo $response | jq -c '.[]')
    do
        if [[ $(echo $build | jq -r '.outcome') != "success" ]]; then
            continue
        fi
        # To Do: Change to jq instead of grep?
        if [[ $(echo $build | grep 'workflows') == "" ]]; then 
            continue 
        fi 
        if (( $(echo $build | jq  -r '.build_num') > $latest_build_num ))\
            && [[ $(echo $build | jq  -r '.workflows.job_name') == $job_name ]]; then
            latest_build_num=$(echo $build | jq  -r '.build_num') 
            latest_git_hash=$(echo $build | jq  -r '.vcs_revision')
        fi
    done
    if [ -z $latest_git_hash ]; then
        page=$((page+1))
    fi
    echo $latest_git_hash
done


