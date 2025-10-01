CC := guile
DIR_PROJECT_ROOT := .
DIR_SRC := ./src
DIR_TESTS := ./tests
DIR_LOGS := ./logs
DIR_EXAMPLE := ./example-questions
EXAMPLE_QUESTIONS_FILE := 2008-civics-test.json
PATH_QUESTIONS = $(DIR_EXAMPLE)/$(EXAMPLE_QUESTIONS_FILE)

SRCS := $(wildcard $(DIR_SRC)/*.scm)

# Match any .scm in the TOP level of the test directory. This simple wildcard
# matching does not search subdirectories. Use GNU `find` if that is needed.
TESTS := $(wildcard $(DIR_TESTS)/*.scm)

# ASSUME: There is exactly one log file generated for each test file.
LOGS := $(patsubst $(DIR_TESTS)/%.scm,$(DIR_LOGS)/%.log,$(TESTS))

HORIZONTAL_RULE := \
"--------------------------------------------------------------------------------"

all:
	$(CC) -L  $(DIR_PROJECT_ROOT) main.scm $(PATH_QUESTIONS)

# Compile Tests ###############################################################
# Goal of test compilation is to generate test log files.
test: $(LOGS)

# Match test log files using "Static Pattern Rule". The first (which can be
# referenced by `$<`) prerequisite for each log file is its corresponding test
# file used to generate it as well as all source files.

# ASSUME: Test files are independent from each other. Editing one will not
# force a recompile of any of the others.

# ASSSUME: Each test is dependent on ALL of the source files. Changing any
# source file will force rerunning all test files.

# ASSUME: Test scripts read 1 mandatory argument (directory which to write log
# file).

$(LOGS): $(DIR_LOGS)/%.log: $(DIR_TESTS)/%.scm $(SRCS)
	@echo $(HORIZONTAL_RULE)
	mkdir --parents $(DIR_LOGS)
	$(CC) -L $(DIR_PROJECT_ROOT) \
	$< \
	$(DIR_LOGS)

#  ############################################################################

.PHONY: clean
clean:
	rm -rf $(DIR_LOGS)
