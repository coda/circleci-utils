
#!/usr/bin/env python3

import re
import sys
import os
curr_dir = os.getcwd()

file_name = sys.argv[1]

file_name_bash = curr_dir + file_name.strip(".py") + '_py.sh'

with open(file_name) as fp:
   contents = fp.read()

with open(file_name_bash, "w+") as out:
   out.write(f"""cat > Pipfile <<EOF
[packages]
requests = "*"
urllib3 = "*"
EOF

pipenv install
pipenv run python3 - << EOF
{contents}
EOF
""")



