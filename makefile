CC := guile
DIR_PROJECT_ROOT := .
DIR_TESTS := ./tests
DIR_LOGS := ./logs

# Match any .scm in the TOP level of the test directory. This simple wildcard
# matching does not search subdirectories. Use GNU `find` if that is needed.
TESTS := $(wildcard $(DIR_TESTS)/*.scm)

# ASSUME: There is exactly one log file generated for each test file.
LOGS := $(patsubst $(DIR_TESTS)/%.scm,$(DIR_LOGS)/%.log,$(TESTS))

all:
	$(CC) -L  $(DIR_PROJECT_ROOT) main.scm

test: $(LOGS)

# Match test log files using "Static Pattern Rule". The prerequisite for each
# log file is its corresponding test file used to generate it.
# ASSUME: Test files are independent from each other. Editing one will not
# force a recompile of any of the others.
$(LOGS): $(DIR_LOGS)/%.log: $(DIR_TESTS)/%.scm
	mkdir --parents $(DIR_LOGS)
	$(CC) -L $(DIR_PROJECT_ROOT) $<

.PHONY: clean
clean:
	rm -r $(DIR_LOGS)

