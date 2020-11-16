offset=$page*100
url_format="https://circleci.com/api/v1/project/${CIRCLE_PROJECT_REPONAME}/${CIRCLE_PR_REPONAME}/tree/${CIRCLE_BRANCH}?circle-token=${CIRCLE_LOCK_API_TOKEN}&limit=100&offset=${offset}&filter=successful"
url_format='https://circleci.com/api/v1/project/{}/{}/tree/{}?circle-token={}&limit={}&offset={}' + \
response = requests.get(url)
response.raise_for_status()
build = response.json()
# curl url_format

job_name="deploy-head"
latest_build_num=0
latest_git_hash=None
page = 0

while latest_git_hash is None and page < CIRCLE_FETCH_MAX_PAGES:
    for build:
        if build['outcome'] != 'success':
            continue
        if not 'workflows' in build:
            continue
        if build['build_num'] > latest_build_num and build['workflows']['job_name'] == job_name:
            latest_build_num = build['build_num']
            latest_git_hash = build['vcs_revision']

    if not latest_git_hash:
        page = page + 1
print (latest_git_hash)
os.environ["GITHASH"] = latest_git_hash
git_hash = latest_git_hash

if not git_hash:
    print('Failed to find a LKG build')
    sys.exit(1)

print(git_hash)
sys.exit(0)