import os
import requests
import json

STATUS = os.getenv('STATUS')
OPSGENIE_BODY = json.loads(os.path.expandvars(os.getenv('OPSGENIE_BODY')))
URI_ALIAS = os.getenv('URI_ALIAS')
OPS_GENIE_API_KEY = os.getenv('OPS_GENIE_API_KEY')
BASH_ENV = os.getenv('BASH_ENV')
print(STATUS)
print(bool(STATUS))
print(bool(int(STATUS)))

if bool(int(STATUS)):
    print("Success")
    requests.post(f"https://api.opsgenie.com/v2/alerts/{URI_ALIAS}/close?identifierType=alias",
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
    requests.post("https://api.opsgenie.com/v2/alerts",
            headers={
            'Authorization': f'GenieKey {OPS_GENIE_API_KEY}',
            'Content-Type': 'application/json',
        },
        json = OPSGENIE_BODY
    )            
    response =  requests.get(f"https://api.opsgenie.com/v2/alerts/{URI_ALIAS}?identifierType=alias",
            headers={
            'Authorization': f'GenieKey {OPS_GENIE_API_KEY}',
            'Content-Type': 'application/json',
        })      
    request_id = response.json()['data']['id']
    OPSGENIE_URL = f"https://krypton.app.opsgenie.com/alert/detail/{request_id}"
env_file = open(BASH_ENV, "a")
env_file.write(f"export OPSGENIE_URL={OPSGENIE_URL}\n")
env_file.close()