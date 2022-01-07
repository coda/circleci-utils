'''Set env var REPORT as 0/1 if current job in parallel build should be reported or wait'''
import os
import requests
import logging
from requests.adapters import HTTPAdapter
from urllib3.util import Retry
import re

CIRCLECI_TOKEN = os.getenv('CIRCLECI_TOKEN')
CIRCLE_PROJECT_USERNAME = os.getenv('CIRCLE_PROJECT_USERNAME')
CIRCLE_PROJECT_REPONAME = os.getenv('CIRCLE_PROJECT_REPONAME')
CIRCLE_BRANCH = os.getenv('CIRCLE_BRANCH')
CIRCLE_BUILD_NUM = os.getenv('CIRCLE_BUILD_NUM')
CURRENT_JOB_STATUS = int(os.getenv('CURRENT_JOB_STATUS'), 10)
CIRCLE_NODE_INDEX = os.getenv('CIRCLE_NODE_INDEX')

print (f"CURRENT_JOB_STATUS : {CURRENT_JOB_STATUS}")

def check_parallel_jobs():
    retry_strategy = Retry(
    total=6, status_forcelist=[429, 500, 502, 503, 504], allowed_methods=['GET'], backoff_factor=10)
    http = requests.Session()


    url = f'https://circleci.com/api/v2/project/gh/{CIRCLE_PROJECT_USERNAME}/{CIRCLE_PROJECT_REPONAME}/job/{CIRCLE_BUILD_NUM}'
    headers = {'Circle-Token': CIRCLECI_TOKEN}
    failed_jobs = []
    try:
        response = http.get(url, headers=headers)
        response.raise_for_status()

        # grab all running jobs and failed jobs
        failed_jobs = list(filter(lambda job: (job['status'] == 'failed' and job['index'] != CIRCLE_NODE_INDEX), response.json()['parallel_runs']))
        running_jobs = list(filter(lambda job: job['status'] == 'running' and job['index'] != CIRCLE_NODE_INDEX, response.json()['parallel_runs']))

    except requests.exceptions.HTTPError as err:
        logging.warning(err)
        logging.warning(response.json())
        return 0

    # if the current job failed and it's the first failure; then report 
    if not CURRENT_JOB_STATUS:
        if not failed_jobs:
            return 1
        else:
            print (f"Previous failed job found: {failed_jobs}")
            return 0
            
    # if the current job is successful; only report if it is the last successful job
    if CURRENT_JOB_STATUS:
        if running_jobs or failed_jobs:
            print(f"Found failed or running jobs: {running_jobs} {failed_jobs}")
            return 0
        return 1

regex_search_pattern = "f^main$|^release$|^preflight$"
match = re.match(regex_search_pattern, CIRCLE_BRANCH)
BRANCH_MATCH = 0
if match:
    BRANCH_MATCH = 1

if int(os.getenv('CIRCLE_NODE_TOTAL', 0)) > 1: # if parallel build
    REPORT = check_parallel_jobs()
else: 
    REPORT = 1

if REPORT:
    print("Current job will be reported")
else:
    print("Current job will not be reported")

BASH_ENV = os.getenv('BASH_ENV')

# 0 is false, 1 is true
env_file = open(BASH_ENV, 'a')
print(f'REPORT={REPORT}')
print(f'BRANCH_MATCH={BRANCH_MATCH}')
env_file.write(f'export REPORT={REPORT}\n')
env_file.write(f'export BRANCH_MATCH={BRANCH_MATCH}\n')
env_file.close()
