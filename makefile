CC := guile
DIR_PROJECT_ROOT := .
DIR_SRC := ./src
DIR_EXAMPLE := ./example-questions
EXAMPLE_QUESTIONS_FILE := 2008-civics-test.json
PATH_QUESTIONS = $(DIR_EXAMPLE)/$(EXAMPLE_QUESTIONS_FILE)

# Use `find` (from GNU findutils) due to nested directory structure of source
# file locations. Due to nested nature, simple wildcard won't suffice. Would
# need more sophisticated technique.
SRCS := $(shell find $(DIR_SRC) -name '*.scm')

all: $(SRCS)
	$(CC) -L  $(DIR_PROJECT_ROOT) main.scm $(PATH_QUESTIONS)

# Compile Tests ###############################################################
# Goal of test compilation is to generate test log files.
test: FORCE
	$(MAKE) --file srfi-64-utils/makefile

FORCE:

.PHONY: clean_test
clean_test:
	$(MAKE) --file srfi-64-utils/makefile clean
