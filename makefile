CC := guile
DIR_PROJECT_ROOT := .
DIR_SRC := ./src
DIR_TESTS := ./tests
DIR_LOGS := ./logs

SRCS := $(wildcard $(DIR_SRC)/*.scm)

# Match any .scm in the TOP level of the test directory. This simple wildcard
# matching does not search subdirectories. Use GNU `find` if that is needed.
TESTS := $(wildcard $(DIR_TESTS)/*.scm)

# ASSUME: There is exactly one log file generated for each test file.
LOGS := $(patsubst $(DIR_TESTS)/%.scm,$(DIR_LOGS)/%.log,$(TESTS))

all:
	$(CC) -L  $(DIR_PROJECT_ROOT) main.scm

# Compile Tests ###############################################################
# Goal of test compilation is to generate test log files.
test: $(LOGS)

# Match test log files using "Static Pattern Rule". The prerequisite for each
# log file is its corresponding test file used to generate it as well as all
# source files.

# ASSUME: Test files are independent from each other. Editing one will not
# force a recompile of any of the others.

# ASSSUME: Each test is dependent on ALL of the source files. Changing any
# source file will force rerunning all test files.

$(LOGS): $(DIR_LOGS)/%.log: $(DIR_TESTS)/%.scm $(SRCS)
	mkdir --parents $(DIR_LOGS)
	$(CC) -L $(DIR_PROJECT_ROOT) $<

#  ############################################################################

.PHONY: clean
clean:
	rm -r $(DIR_LOGS)

