import os
import requests
import logging
from requests.adapters import HTTPAdapter
from urllib3.util import Retry

CIRCLECI_TOKEN = os.getenv('CIRCLECI_TOKEN')
CIRCLE_PROJECT_USERNAME = os.getenv('CIRCLE_PROJECT_USERNAME')
CIRCLE_PROJECT_REPONAME = os.getenv('CIRCLE_PROJECT_REPONAME')
CIRCLE_BRANCH = os.getenv('CIRCLE_BRANCH')
CIRCLE_WORKFLOW_JOB_ID = os.getenv('CIRCLE_WORKFLOW_JOB_ID')

def ensure_parallel_job_success():
    retry_strategy = Retry(
    total=6, status_forcelist=[429, 500, 502, 503, 504], allowed_methods=["GET"], backoff_factor=10)
    adapter = HTTPAdapter(max_retries=retry_strategy)
    http = requests.Session()

    CIRCLE_NODE_INDEX = os.getenv('CIRCLE_NODE_INDEX')

    url = f'https://circleci.com/api/v2/project/gh/{CIRCLE_PROJECT_USERNAME}/{CIRCLE_PROJECT_REPONAME}/job/{CIRCLE_WORKFLOW_JOB_ID}'
    headers = {'Circle-Token': CIRCLECI_TOKEN}
    try:
        response = http.get(url, headers=headers)
        response.raise_for_status()
        # if a previous job has failed; then do not report 
        # the last successful job will report success
        # the first failure will report failure
        failed_jobs = list(filter(lambda job: job["status"] == "failed" and job["index"] != CIRCLE_NODE_INDEX, response.json()["parallel_runs"]))
        
    except requests.exceptions.HTTPError as err:
        logging.warning(err)
        logging.warning(response.json())

    if failed_jobs:
        logging.info("At least one previous failure has been reported")
        return 0

    else:
        return 1


if int(os.getenv('CIRCLE_NODE_TOTAL', 0)) > 1:
    REPORT = ensure_parallel_job_success()
else: 
    REPORT = 1
    

BASH_ENV = os.getenv('BASH_ENV')

env_file = open(BASH_ENV, "a")
env_file.write(f"export REPORT={REPORT}\n")
env_file.close()
