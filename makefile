CC := guile
DIR_PROJECT_ROOT := .
DIR_TEST := tests
# Must have same static pattern rule "stem" as corresponding .scm test file.
LOGS = answer-test.log

tests: $(LOGS)

# Match test log files using "Static Pattern Rule". The prerequisite for each
# log file is its corresponding test file used to generate it.
$(LOGS): %.log: $(DIR_TEST)/%.scm
	$(CC) -L $(DIR_PROJECT_ROOT) $<
