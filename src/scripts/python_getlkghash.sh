#!/usr/bin/env bash
pipenv run python3 - << END

"""Use the CircleCI v1.1 API to determine the Last Known Good build's git hash."""
from __future__ import print_function

import argparse
import logging
import os
import sys

import requests

ACTIVE_JOB_STATES = ['running', 'pending', 'queued']

CIRCLE_FETCH_PAGE_SIZE = 100
CIRCLE_FETCH_MAX_PAGES = 100


def get_recent_builds(args, page=0):
    '''Retrieve a set of recent builds from CircleCI.'''
    offset = page * CIRCLE_FETCH_PAGE_SIZE
    check_if_last_was_green = args.check_if_last_was_green
    url_format = 'https://circleci.com/api/v1/project/{}/{}/tree/{}?circle-token={}&limit={}&offset={}' + \
        ('' if check_if_last_was_green else '&filter=successful')
    url = url_format.format(args.project_name, args.repo_name, args.branch_name, args.token, CIRCLE_FETCH_PAGE_SIZE,
                            offset)

    response = requests.get(url)
    response.raise_for_status()
    return response.json()


def get_latest_hash(args):
    '''Determine the git hash of the latest successful run of the given job name.'''
    job_name = args.job_name
    latest_build_num = 0
    latest_git_hash = None
    page = 0

    while latest_git_hash is None and page < CIRCLE_FETCH_MAX_PAGES:
        for build in get_recent_builds(args, page):
            if build['outcome'] != 'success':
                continue
            if not 'workflows' in build:
                continue
            if build['build_num'] > latest_build_num and build['workflows']['job_name'] == job_name:
                latest_build_num = build['build_num']
                latest_git_hash = build['vcs_revision']

        if not latest_git_hash:
            page = page + 1

    LATEST_GIT_HASH="https://github.com/kr-project/{}/compare/{}...{}".format(os.getenv('CIRCLE_PROJECT_REPONAME'),latest_git_hash,os.getenv('CIRCLE_SHA1'))
    os.environ['LATEST_GIT_HASH'] = LATEST_GIT_HASH
    os.system('echo "export LATEST_GIT_HASH=$LATEST_GIT_HASH" >> $BASH_ENV')
    return LATEST_GIT_HASH


def parse_args():
    """Define and parse command line arguments"""
    parser = argparse.ArgumentParser(
        description='LKG utility for CircleCI workflows', formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument(
        '--project-name', help='CircleCI project username', default=os.environ.get('CIRCLE_PROJECT_USERNAME'))
    parser.add_argument('--repo-name', help='CircleCI repository name', default=os.environ.get('CIRCLE_PROJECT_REPONAME'))
    parser.add_argument('--branch-name', help='GitHub branch name', default=os.environ.get('CIRCLE_BRANCH'))
    parser.add_argument('--token', help='CircleCI API token', default=os.environ.get('CIRCLE_LOCK_API_TOKEN'))
    parser.add_argument('--job-name', help='Find the LKG build for this job name', default=os.environ.get('CIRCLE_JOB'))
    parser.add_argument('--verbose', help='Verbose output', action='store_true')
    parser.add_argument('--check-if-last-was-green', help='Checks if last completed job was green', action='store_true')

    args = parser.parse_args()
    return args


def print_last_green(args):
    '''Prints the hash of the last green build if one can be found.'''
    git_hash = get_latest_hash(args)
    if not git_hash:
        print('Failed to find a LKG build')
        sys.exit(1)

    print(git_hash)
    sys.exit(0)


def print_if_last_was_green(args):
    '''Prints 1 if the last completed build with the job_name was green. Skips cancelled jobs.'''

    current_branch = os.environ.get('CIRCLE_BRANCH')
    if current_branch and 'revert-' in current_branch:
        print('Skipping branch {} for green check'.format(current_branch))
        return

    job_name = args.job_name
    builds = get_recent_builds(args)
    sorted_builds = sorted(builds, key=lambda build: -build['build_num'])

    for build in sorted_builds:
        if build['canceled']:
            continue
        if not 'workflows' in build:
            continue
        if build['workflows']['job_name'] != job_name:
            continue
        if not build['outcome']:
            # skip if the build is still in flight and doesn't have an outcome
            continue
        if build['outcome'] == 'failed':
            print('last {0} job failed - {1}'.format(job_name, build['build_url']))
            sys.exit(1)
        else:
            print('last {0} job passed - {1}'.format(job_name, build['build_url']))
            sys.exit(0)

    # Could not find a build that passed with the given job-name
    print('last build not found')
    sys.exit(1)


def main():
    args = parse_args()
    log_level = logging.DEBUG if args.verbose else logging.INFO
    logging.basicConfig(format='%(asctime)s - %(levelname)s: %(message)s', level=log_level)
    print (args.branch_name)
    if args.check_if_last_was_green:
        print_if_last_was_green(args)
    else:
        print_last_green(args)


if __name__ == "__main__":
    main()
END
echo $LATEST_GIT_HASH
# echo "export LATEST_GIT_HASH=$LATEST_GIT_HASH" >> $BASH_ENV
source $BASH_ENV