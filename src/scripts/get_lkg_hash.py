'''Grab last known good git hash'''
from __future__ import print_function

import os
import sys

import requests
from requests.adapters import HTTPAdapter
from urllib3.util import Retry

CIRCLECI_TOKEN = os.getenv('CIRCLECI_TOKEN')
CIRCLE_PROJECT_USERNAME = os.getenv('CIRCLE_PROJECT_USERNAME')
CIRCLE_PROJECT_REPONAME = os.getenv('CIRCLE_PROJECT_REPONAME')
CIRCLE_BRANCH = os.getenv('CIRCLE_BRANCH')
CIRCLE_JOB = os.getenv('CIRCLE_JOB')
CIRCLE_SHA1 = os.getenv('CIRCLE_SHA1')
ACTIVE_JOB_STATES = ['running', 'pending', 'queued']

CIRCLE_FETCH_PAGE_SIZE = 100
CIRCLE_FETCH_MAX_PAGES = 100


def get_recent_builds(page=0):
    '''Retrieve a set of recent builds from CircleCI.'''
    offset = page * CIRCLE_FETCH_PAGE_SIZE
    # note: do not use shallow=true -- this strips out critical information such as cancelation status
    url_format = 'https://circleci.com/api/v1/project/{}/{}/tree/{}?circle-token={}&limit={}&offset={}&filter=successful'
    url = url_format.format(CIRCLE_PROJECT_USERNAME, CIRCLE_PROJECT_REPONAME, CIRCLE_BRANCH, CIRCLECI_TOKEN, CIRCLE_FETCH_PAGE_SIZE,
                            offset)

    response = http.get(url)
    response.raise_for_status()
    return response.json()


def get_latest_hash():
    '''Determine the git hash of the latest successful run of the given job name.'''
    latest_build_num = 0
    latest_git_hash = None
    page = 0

    while latest_git_hash is None and page < CIRCLE_FETCH_MAX_PAGES:
        for build in get_recent_builds(page):
            if build['outcome'] != 'success':
                continue
            if not 'workflows' in build:
                continue
            if build['build_num'] > latest_build_num and build['workflows']['job_name'] == CIRCLE_JOB:
                latest_build_num = build['build_num']
                latest_git_hash = build['vcs_revision']

        if not latest_git_hash:
            page = page + 1

    return latest_git_hash

retry_strategy = Retry(
total=6, status_forcelist=[429, 500, 502, 503, 504], allowed_methods=['GET'], backoff_factor=10)
adapter = HTTPAdapter(max_retries=retry_strategy)
http = requests.Session()

git_hash = get_latest_hash()
if not git_hash:
    print('Failed to find a LKG build')
    DIFF_URL = f'https://github.com/{CIRCLE_PROJECT_USERNAME}/{CIRCLE_PROJECT_REPONAME}/commit/{CIRCLE_SHA1}'
else: 
    DIFF_URL = f'https://github.com/{CIRCLE_PROJECT_USERNAME}/{CIRCLE_PROJECT_REPONAME}/compare/{git_hash}...{CIRCLE_SHA1}'

BASH_ENV = os.getenv('BASH_ENV')

env_file = open(BASH_ENV, 'a')
env_file.write(f'export DIFF_URL={DIFF_URL}\n')
env_file.close()
