import os
import requests
import logging
CIRCLECI_TOKEN = os.getenv('CIRCLECI_TOKEN')
CIRCLE_PROJECT_USERNAME = os.getenv('CIRCLE_PROJECT_USERNAME')
CIRCLE_PROJECT_REPONAME = os.getenv('CIRCLE_PROJECT_REPONAME')
CIRCLE_BRANCH = os.getenv('CIRCLE_BRANCH')
CIRCLE_WORKFLOW_JOB_ID = os.getenv('CIRCLE_WORKFLOW_JOB_ID')

def ensure_parallel_job_success():
    url = f'https://circleci.com/api/v2/project/gh/{CIRCLE_PROJECT_USERNAME}/{CIRCLE_PROJECT_REPONAME}/job/{CIRCLE_WORKFLOW_JOB_ID}'
    headers = headers = {'Circle-Token': CIRCLECI_TOKEN}
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        failed_jobs = list(filter(lambda job: job["status"] == "failed", response.json()["parallel_runs"]))
    except requests.exceptions.HTTPError as err:
        logging.warning(err)
        logging.warning(response.json())

    if failed_jobs:
        logging.info("At least one parallel job failed -- bailing out.")
        REPORT=0

    else:
        REPORT=1


if os.getenv('STATUS') and int(os.getenv('CIRCLE_NODE_TOTAL', 0)) > 1:
    ensure_parallel_job_success()
else:
    REPORT=1

BASH_ENV = os.getenv('BASH_ENV')

env_file = open(BASH_ENV, "a")
env_file.write(f"export REPORT={REPORT}\n")
env_file.close()

print(os.getenv('REPORT'))