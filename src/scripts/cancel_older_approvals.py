import os
import requests

circleci_api_token = os.getenv('CIRCLECI_TOKEN')
CIRCLE_WORKFLOW_ID = os.getenv('CIRCLE_WORKFLOW_ID')
CIRCLE_PROJECT_USERNAME = os.getenv('CIRCLE_PROJECT_USERNAME')
VCS="gh"
CIRCLE_PROJECT_REPONAME = os.getenv('CIRCLE_PROJECT_REPONAME')
BASE_URL="https://circleci.com/api/v2"
TOKEN=f'circle-token={circleci_api_token}'

current_wf_url = f'{BASE_URL}/workflow/{CIRCLE_WORKFLOW_ID}?{TOKEN}'


try:
    print(current_wf_url)
    current_workflow = requests.get(current_wf_url).json()
except requests.exceptions.RequestException as e:  
    raise SystemExit(e)
print(current_workflow)
current_wf_created_timestamp = current_workflow['created_at']
print(f"Current workflow start time: {current_wf_created_timestamp}")
project=f"project/{VCS}%2F{CIRCLE_PROJECT_USERNAME}%2F{CIRCLE_PROJECT_REPONAME}"
pipeline_url = f"{BASE_URL}/{project}/pipeline?{TOKEN}"

try:
    print("Pipeline URL: "+ pipeline_url)
    print()
    current_workflow = requests.get(pipeline_url).json()
except requests.exceptions.RequestException as e:  
    raise SystemExit(e)

for item in current_workflow['items']:
    id = item['id']
    try:
        workflow_url = f"{BASE_URL}/pipeline/{id}/workflow?{TOKEN}"
        response = requests.get(workflow_url).json()
        workflow = response['items'][0]
        workflow_id, workflow_status, workflow_creation_timestamp = workflow['id'], workflow['status'], workflow['created_at']
    except requests.exceptions.RequestException as e: 
        raise SystemExit(e)
    print(f"Workflow data: {workflow_id}, {workflow_status}, {workflow_creation_timestamp}")
    if (workflow_creation_timestamp < current_wf_created_timestamp and workflow_status == "on_hold"):
        print(f"Canceling older workflow awaiting manual approval: {workflow_id}")
        cancel_url = f"{BASE_URL}workflow/{workflow_id}/cancel?{TOKEN}"
        try:
            requests.post(cancel_url)
        except requests.exceptions.RequestException as e:  
            raise SystemExit(e)       
