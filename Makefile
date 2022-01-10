SHELL = /bin/bash
ROOTDIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: wrap-python-files
wrap-python-files:
	find . -name \*.py -exec python3 ${ROOTDIR}/reformat_python.py {} \;

.PHONY: rewrap-py-files
rewrap-py-files: delete-python-wrapped-files
	$(MAKE) delete-python-wrapped-files 
	$(MAKE) wrap-python-files

.PHONY: delete-python-wrapped-files 
delete-python-wrapped-files: 
	-rm -f ${ROOTDIR}/src/scripts/*_py.sh


.PHONY: build
build:
ifdef CIRCLECI_TOKEN
	$(MAKE) rewrap-py-files
	circleci orb pack ./src > ./src/orb.yml 
	circleci orb publish ./src/orb.yml coda/utils@dev:alpha --token ${CIRCLECI_TOKEN}
else
	echo "CIRCLECI_TOKEN not defined"
endif


.PHONY: validate
validate:
	$(MAKE) rewrap-py-files
	circleci orb pack ./src > ./src/orb.yml 
	circleci orb validate ./src/orb.yml