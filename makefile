CC := guile
DIR_PROJECT_ROOT := .
DIR_SRC := ./src
DIR_TESTS := ./tests
DIR_LOGS := ./logs
DIR_EXAMPLE := ./example-questions
EXAMPLE_QUESTIONS_FILE := 2008-civics-test.json
PATH_QUESTIONS = $(DIR_EXAMPLE)/$(EXAMPLE_QUESTIONS_FILE)

# Use `find` (from GNU findutils) due to nested directory structure of source
# and test file locations. Due to nested nature, simple wildcard won't
# suffice. Would need more sophisticated technique.
SRCS := $(shell find $(DIR_SRC) -name '*.scm')
TESTS := $(shell find $(DIR_TESTS) -name '*.scm')

# ASSUME: There is exactly one log file generated for each test file.
# ASSUME: Log files are written by test file when test file is given
# path/file-name to write the log to.
LOGS := $(patsubst $(DIR_TESTS)/%.scm,$(DIR_LOGS)/%.log,$(TESTS))

# Target-specific variable. This generates variables DIR_CONTAINING_LOG_FILE
# that varies for each filename in LOGS, for each log file makefile target. It
# does this by taking the directory name of the file. $@ is an automatic
# variable.
$(LOGS): DIR_CONTAINING_LOG_FILE = $(dir $@)

HORIZONTAL_RULE := \
"--------------------------------------------------------------------------------"

all:
	$(CC) -L  $(DIR_PROJECT_ROOT) main.scm $(PATH_QUESTIONS)

# Compile Tests ###############################################################
# Goal of test compilation is to generate test log files.
test: $(LOGS)

# Match test log files using "Static Pattern Rule". The first prerequisite for
# each log file (which can be referenced by automatic variable `$<`) is its
# corresponding test file used to generate it as well as all source files.

# ASSUME: Test files are independent from each other. Editing one will not
# force a recompile of any of the others.

# ASSSUME: Each test is dependent on ALL of the source files. Changing any
# source file will force rerunning all test files.

# ASSUME: Test scripts read 1 mandatory argument (directory which to write log
# file).

$(LOGS): $(DIR_LOGS)/%.log: $(DIR_TESTS)/%.scm $(SRCS)
	@echo $(HORIZONTAL_RULE)
	mkdir --parents $(DIR_CONTAINING_LOG_FILE)
	$(CC) -L $(DIR_PROJECT_ROOT) \
	$< \
	$(DIR_CONTAINING_LOG_FILE)

#  ############################################################################

.PHONY: clean
clean:
	rm -rf $(DIR_LOGS)
