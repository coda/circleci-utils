import os
import requests
from requests.adapters import HTTPAdapter
from urllib3.util import Retry

CIRCLECI_TOKEN = os.getenv('CIRCLECI_TOKEN')
CIRCLE_WORKFLOW_ID = os.getenv('CIRCLE_WORKFLOW_ID')
CIRCLE_PROJECT_USERNAME = os.getenv('CIRCLE_PROJECT_USERNAME')
VCS="gh"
CIRCLE_PROJECT_REPONAME = os.getenv('CIRCLE_PROJECT_REPONAME')
BASE_URL="https://circleci.com/api/v2"
headers = {'Circle-Token': CIRCLECI_TOKEN}

current_wf_url = f'{BASE_URL}/workflow/{CIRCLE_WORKFLOW_ID}'
retry_strategy = Retry(
    total=6, status_forcelist=[429, 500, 502, 503, 504], allowed_methods=["POST", "GET"], backoff_factor=10)
adapter = HTTPAdapter(max_retries=retry_strategy)
http = requests.Session()

try:
    current_workflow = http.get(current_wf_url, headers=headers).json()
except requests.exceptions.RequestException as e:  
    raise SystemExit(e)
current_wf_created_timestamp = current_workflow['created_at']
print(f"Current workflow start time: {current_wf_created_timestamp}")
project=f"project/{VCS}%2F{CIRCLE_PROJECT_USERNAME}%2F{CIRCLE_PROJECT_REPONAME}"
pipeline_url = f"{BASE_URL}/{project}/pipeline"

try:
    print("Pipeline URL: "+ pipeline_url)
    print()
    current_workflow = http.get(pipeline_url, headers=headers).json()
except requests.exceptions.RequestException as e:  
    raise SystemExit(e)

for item in current_workflow['items']:
    id = item['id']
    try:
        workflow_url = f"{BASE_URL}/pipeline/{id}/workflow"
        response = http.get(workflow_url, headers=headers).json()
        workflow = response['items'][0]
        workflow_id, workflow_status, workflow_creation_timestamp = workflow['id'], workflow['status'], workflow['created_at']
    except requests.exceptions.RequestException as e: 
        raise SystemExit(e)
    print(f"Workflow data: {workflow_id}, {workflow_status}, {workflow_creation_timestamp}")
    if (workflow_creation_timestamp < current_wf_created_timestamp and workflow_status == "on_hold"):
        print(f"Canceling older workflow awaiting manual approval: {workflow_id}")
        cancel_url = f"{BASE_URL}workflow/{workflow_id}/cancel"
        try:
            http.post(cancel_url, headers=headers)
        except requests.exceptions.RequestException as e:  
            raise SystemExit(e)       
