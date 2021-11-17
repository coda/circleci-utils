#!/usr/bin/env python
import os
import requests

circleci_api_token = os.getenv('CIRCLECI_API_TOKEN')
CIRCLE_WORKFLOW_ID = os.getenv('CIRCLE_WORKFLOW_ID')
CIRCLE_PROJECT_USERNAME = os.getenv('CIRCLE_PROJECT_USERNAME')
VCS="gh"
CIRCLE_PROJECT_REPONAME = os.getenv('CIRCLE_PROJECT_REPONAME')
BASE_URL="https://circleci.com/api/v2"
TOKEN=f'circle-token={circleci_api_token}'

WORKFLOW_ID_URL = f'{BASE_URL}/workflow/{CIRCLE_WORKFLOW_ID}?{TOKEN}'
print(WORKFLOW_ID_URL)
try:
    CURRENT_WORKFLOW = requests.get(WORKFLOW_ID_URL).json()
except requests.exceptions.RequestException as e:  # This is the correct syntax
    raise SystemExit(e)

CURRENT_WORKFLOW_TIMESTAMP = CURRENT_WORKFLOW['created_at']
print(f"Current workflow start time: {CURRENT_WORKFLOW_TIMESTAMP}")
PROJECT_SLUG=f"project/{VCS}%2F{CIRCLE_PROJECT_USERNAME}%2F{CIRCLE_PROJECT_REPONAME}"
PIPELINE_IDS = f"{BASE_URL}/{PROJECT_SLUG}/pipeline?{TOKEN}"

try:
    CURRENT_WORKFLOW = requests.get(PIPELINE_IDS).json()
except requests.exceptions.RequestException as e:  # This is the correct syntax
    raise SystemExit(e)
for item in CURRENT_WORKFLOW['items']:
    print(item)
    # print(f"Workflow data: {item['id']}, {item['status']}, {item['created_at']}")

# PIPELINE_IDS_LIST = [item['id'] for item in CURRENT_WORKFLOW['items'] ]
# print(PIPELINE_IDS_LIST)
# for PIPELINE_ID in $PIPELINE_IDS; do
#     WORKFLOW=$(curl -s -H "Accept: application/json" "${BASE_URL}/pipeline/${PIPELINE_ID}/workflow?${TOKEN}" | jq ".items[0]")

#     WORKFLOW_ID=$(echo "$WORKFLOW" | jq -r ".id")
#     WORKFLOW_STATUS=$(echo "$WORKFLOW" | jq -r ".status")
#     WORKFLOW_CREATION_TIMESTAMP=$(echo "$WORKFLOW" | jq -r ".created_at")

#     echo "Workflow data: ${WORKFLOW_ID}, ${WORKFLOW_STATUS}, ${WORKFLOW_CREATION_TIMESTAMP}"

#     if [[ $WORKFLOW_CREATION_TIMESTAMP < $CURRENT_WORKFLOW_TIMESTAMP && "$WORKFLOW_STATUS" == "on_hold" ]]; then
#     echo "Canceling older workflow waiting for manual approval: ${WORKFLOW_ID}"
#     curl -s -X POST -H "Accept: application/json" "${BASE_URL}/workflow/${WORKFLOW_ID}/cancel?${TOKEN}"
#     fi
# done
