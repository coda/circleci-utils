#!/bin/bash
set -eo pipefail
USER_ALIAS=$(curl -s -H "Authorization: Bearer ${CODA_API_TOKEN}" \
-G --data-urlencode "query=c-6ni4kHGNwE:\"${CIRCLE_USERNAME}\"" \
'https://staging.coda.io/apis/v1/docs/s2i6oFeghW/tables/grid-QGyaiXZDwu/rows' \
| jq '.items[0].values."c-26If9Zttyp"' | tr -d '"')
if [ "$USER_ALIAS" != "null" ]; then
    USER_EMAIL=$([[ "${USER_ALIAS}" == *@* ]] && echo "$USER_ALIAS" || echo "${USER_ALIAS}@coda.io")
    echo "export USER_EMAIL=${USER_EMAIL}" >> "$BASH_ENV"
else
    echo "export USER_EMAIL=''" >> "$BASH_ENV"
fi
echo "$USER_EMAIL"