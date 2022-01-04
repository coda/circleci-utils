SHELL = /bin/bash
ROOTDIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: wrap-python-files
wrap-python-files:
	for f in $(shell ls ${ROOTDIR}/src/scripts); do \
		if [[ $$f == *.py ]]; then \
			python ${ROOTDIR}/reformat_python.py ${ROOTDIR}/src/scripts/$$f; \
		fi; \
	done; \

.PHONY: rewrap-py-files
rewrap-py-files: delete-python-wrapped-files
	$(MAKE) delete-python-wrapped-files 
	$(MAKE) wrap-python-files

.PHONY: delete-python-wrapped-files 
delete-python-wrapped-files: 
	-rm -f ${ROOTDIR}/src/scripts/*_py.sh
