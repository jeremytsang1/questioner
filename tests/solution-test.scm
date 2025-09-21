;;; (tests solution-test) --- Test for module (src solution)
;; Usage: guile -L . tests/answer-test.scm LOG-DIRECTORY # From project root.
#!/usr/local/bin/guile -s
!#

(use-modules (srfi srfi-64)
             (util test)             
             (src solution))

(define TEST-SUITE-NAME (qnr-generate-log-file-name))

(test-begin TEST-SUITE-NAME)
(test-end TEST-SUITE-NAME)
