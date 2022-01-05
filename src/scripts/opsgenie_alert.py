import os
import requests
import json
from requests.adapters import HTTPAdapter
from urllib3.util import Retry

STATUS = os.getenv('STATUS')
OPSGENIE_BODY = json.loads(os.path.expandvars(os.getenv('OPSGENIE_BODY')))
URI_ALIAS = os.getenv('URI_ALIAS')
OPS_GENIE_API_KEY = os.getenv('OPS_GENIE_API_KEY')
BASH_ENV = os.getenv('BASH_ENV')

retry_strategy = Retry(
total=6, status_forcelist=[429, 500, 502, 503, 504], allowed_methods=["GET", "POST"], backoff_factor=10)
adapter = HTTPAdapter(max_retries=retry_strategy)
http = requests.Session()

if bool(int(STATUS)):
    print("Success")
    http.post(f"https://api.opsgenie.com/v2/alerts/{URI_ALIAS}/close?identifierType=alias",
            headers={
            'Authorization': f'GenieKey {OPS_GENIE_API_KEY}',
            'Content-Type': 'application/json',
        },
        json = OPSGENIE_BODY
    )
    OPSGENIE_URL = f"https://krypton.app.opsgenie.com"
    print(OPSGENIE_BODY)
else:
    print("Failing")
    http.post("https://api.opsgenie.com/v2/alerts",
            headers={
            'Authorization': f'GenieKey {OPS_GENIE_API_KEY}',
            'Content-Type': 'application/json',
        },
        json = OPSGENIE_BODY
    )            
    response =  http.get(f"https://api.opsgenie.com/v2/alerts/{URI_ALIAS}?identifierType=alias",
            headers={
            'Authorization': f'GenieKey {OPS_GENIE_API_KEY}',
            'Content-Type': 'application/json',
        })      
    request_id = response.json()['data']['id']
    OPSGENIE_URL = f"https://krypton.app.opsgenie.com/alert/detail/{request_id}"
env_file = open(BASH_ENV, "a")
env_file.write(f"export OPSGENIE_URL={OPSGENIE_URL}\n")
env_file.close()