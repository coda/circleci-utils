
#!/usr/bin/env python3

import re
import sys

file_name = sys.argv[1]

file_name_bash = file_name.strip(".py") + '_py.sh'

with open(file_name) as fp:
   contents = fp.read()

with open(file_name_bash, "a") as out:
   out.write(f'''cat > Pipfile <<EOF
[packages]
requests = "*"
EOF

pipenv install
pipenv run python3 - << EOF
{contents}
EOF
''')