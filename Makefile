SHELL = /bin/bash
ROOTDIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: wrap-python-files
wrap-python-files:
	for f in $(shell ls ${ROOTDIR}/src/scripts); do \
		if [[ $$f == *.py ]]; then \
			python ${ROOTDIR}/reformat_python.py ${ROOTDIR}/src/scripts/$$f; \
		fi; \
	done; \
		

