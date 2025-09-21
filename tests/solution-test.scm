;;; (tests solution-test) --- Test for module (src solution)
;; Usage: guile -L . tests/answer-test.scm LOG-DIRECTORY # From project root.
#!/usr/local/bin/guile -s
!#

(use-modules (srfi srfi-64) (util test) (src solution))

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define TEST-SUITE-NAME (qnr-generate-log-file-name))

(define SINGLE-CHOICE-CHOICES '("blue"))
(define SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT)

;; Tests ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-begin TEST-SUITE-NAME)
(test-equal "verify record type after construction"
  #t
  (qnr-solution? (qnr-make-solution SINGLE-CHOICE-CHOICES
                                    SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT)))

(test-end TEST-SUITE-NAME)
