#!/usr/bin/env python
import os
import sys
import requests
USER_EMAIL=""
SLACK_USER_ID=""
GITHUB_SUFFIX="-codaio"
EMAIL_DOMAIN="@coda.io"
CIRCLE_USERNAME = "gita-codaio"
SLACK_BOT_TOKEN = os.getenv('SLACK_BOT_TOKEN')
if GITHUB_SUFFIX not in CIRCLE_USERNAME:
    print(f"{CIRCLE_USERNAME}  has incorrect git username -- please add -codaio and update in go/roster")
    sys.exit(0)
user_email = CIRCLE_USERNAME.split(GITHUB_SUFFIX)[0] + EMAIL_DOMAIN

if SLACK_BOT_TOKEN:
    headers = {"Authorization": f"Bearer {SLACK_BOT_TOKEN}"}
    try:
        response = requests.get(f"https://slack.com/api/users.lookupByEmail?email={user_email}", headers=headers)
        user_id = response.json()['user']['id']
        os.environ['USER_EMAIL'] = user_email
        os.environ['SLACK_USER_ID'] = user_id
    except requests.exceptions.RequestException as e:  # This is the correct syntax
        raise SystemExit(e)