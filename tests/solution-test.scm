;;; (tests solution-test) --- Test for module (src solution)
;; Usage: guile -L . tests/answer-test.scm LOG-DIRECTORY # From project root.
#!/usr/local/bin/guile -s
!#

(use-modules (srfi srfi-64) (src solution))

(test-begin "solution-test.log")

(test-equal "verify record type after construction"
  #t
  (qnr-solution? (qnr-make-solution '("blue") 1)))

(test-end "solution-test.log")
