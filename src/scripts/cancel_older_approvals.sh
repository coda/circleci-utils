#!/bin/bash
set -eo pipefail

BASE_URL="https://circleci.com/api/v2"
TOKEN="circle-token=${CIRCLECI_TOKEN}"
vcs="gh"
CURRENT_WORKFLOW=$(curl -s -H "Accept: application/json" "${BASE_URL}/workflow/${CIRCLE_WORKFLOW_ID}?${TOKEN}")
CURRENT_WORKFLOW_TIMESTAMP=$(echo "$CURRENT_WORKFLOW" | jq -r ".created_at")
echo "Current workflow start time: ${CURRENT_WORKFLOW_TIMESTAMP}"

PROJECT_SLUG="project/${vcs}%2F${CIRCLE_PROJECT_USERNAME}%2F${CIRCLE_PROJECT_REPONAME}"
PIPELINE_IDS=$(curl -s -H "Accept: application/json" "${BASE_URL}/${PROJECT_SLUG}/pipeline?${TOKEN}" | jq -r ".items[].id")

for PIPELINE_ID in $PIPELINE_IDS; do
    WORKFLOW=$(curl -s -H "Accept: application/json" "${BASE_URL}/pipeline/${PIPELINE_ID}/workflow?${TOKEN}" | jq ".items[0]")

    WORKFLOW_ID=$(echo "$WORKFLOW" | jq -r ".id")
    WORKFLOW_STATUS=$(echo "$WORKFLOW" | jq -r ".status")
    WORKFLOW_CREATION_TIMESTAMP=$(echo "$WORKFLOW" | jq -r ".created_at")

    echo "Workflow data: ${WORKFLOW_ID}, ${WORKFLOW_STATUS}, ${WORKFLOW_CREATION_TIMESTAMP}"

    if [[ $WORKFLOW_CREATION_TIMESTAMP < $CURRENT_WORKFLOW_TIMESTAMP && "$WORKFLOW_STATUS" == "on_hold" ]]; then
    echo "Canceling older workflow waiting for manual approval: ${WORKFLOW_ID}"
    curl -s -X POST -H "Accept: application/json" "${BASE_URL}/workflow/${WORKFLOW_ID}/cancel?${TOKEN}"
    fi
done
