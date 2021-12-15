

import re
import sys

file_name = sys.argv[1]
fp = open(file_name)
contents = fp.read()

prepend = '''cat > Pipfile <<EOF
[packages]
requests = "*"

EOF
pipenv install
pipenv run python3 - << EOF'''
append = "EOF"

file_name_bash = file_name.strip(".py") + '_py.sh'
bash_contents = '\n'.join([prepend,contents,append])

f = open(file_name_bash, "a")
f.write(bash_contents)

f.close()