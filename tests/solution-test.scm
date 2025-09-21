;;; (tests solution-test) --- Test for module (src solution)
;; Usage: guile -L . tests/answer-test.scm LOG-DIRECTORY # From project root.
#!/usr/local/bin/guile -s
!#

(use-modules (srfi srfi-64)
             (util test)             
             (src solution))

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define TEST-SUITE-NAME (qnr-generate-log-file-name))

(define SOLUTIONS-INVALID-WRONG-TYPE "not a list")
(define SOLUTIONS-INVALID-NO-CHOICES '())
(define SOLUTIONS-INVALID-CHOICES-WRONG-TYPE
  '(("foo") "bar" "bop"))
(define SOLUTIONS-INVALID-EMPTY-CHOICE
  '(("foo" "bar") () '("baz" "bop")))
(define SOLUTIONS-INVALID-ALTERNATIVE-WRONG-TYPE
  '((("abc")) ("1" "2" "3")))
(define SOLUTIONS-INVALID-EMPTY-ALTERNATIVE
  '(("foo" "baz" "bop") ("baz") ("alpha" "" "beta")))
(define SOLUTIONS-INVALID-EMPTY-ALTERNATIVE-SPACES
  '(("a" "b" " c ") ("d " "        " "e") ("f")))
(define SOLUTIONS-INVALID-EMPTY-ALTERNATIVE-TABS
  '(("a" "b" " c ") ("d " "\t\t\t\t" "e") ("f")))
(define SOLUTIONS-INVALID-DUPLICATE-ALTERNATIVES-ACROSS-CHOICES
  '(("alpha" "beta" "gamma")
    ("delta")
    ("kappa" "lambda" "alpha" "mu")))

;; Tests ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-begin TEST-SUITE-NAME)

(test-equal "validate <question> with string for `solutions` instead of list"
  QNR-ERROR-SOLUTIONS-WRONG-TYPE
  (qnr-validate-solution SOLUTIONS-INVALID-WRONG-TYPE))

(test-equal "validate <question> with an empty list for `solutions`"
  QNR-ERROR-SOLUTIONS-NO-CHOICES-FOUND
  (qnr-validate-solution SOLUTIONS-INVALID-NO-CHOICES))

(test-equal "validate <question> with `solutions` has non-list members"
  QNR-ERROR-SOLUTIONS-CHOICES-WRONG-TYPE
  (qnr-validate-solution SOLUTIONS-INVALID-CHOICES-WRONG-TYPE))

(test-equal "validate <question> with `solutions` that has an empty sublist"
  QNR-ERROR-SOLUTIONS-CHOICES-EMPTY
  (qnr-validate-solution SOLUTIONS-INVALID-EMPTY-CHOICE))

(test-equal "validate <question> with `solutions` that has a sublist containing a non-string"
  QNR-ERROR-SOLUTIONS-ALTERNATIVE-WRONG-TYPE
  (qnr-validate-solution SOLUTIONS-INVALID-ALTERNATIVE-WRONG-TYPE))

(test-equal "validate <question> with `solutions` with empty string in sublist"
  QNR-ERROR-SOLUTIONS-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
  (qnr-validate-solution SOLUTIONS-INVALID-EMPTY-ALTERNATIVE))

(test-equal "validate <question> with `solutions` with entirely spaces alternative"
  QNR-ERROR-SOLUTIONS-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
  (qnr-validate-solution SOLUTIONS-INVALID-EMPTY-ALTERNATIVE-SPACES))

(test-equal "validate <question> with alternatives containing only tabs"
  QNR-ERROR-SOLUTIONS-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
  (qnr-validate-solution SOLUTIONS-INVALID-EMPTY-ALTERNATIVE-TABS))

(test-equal "validate <question> with duplicate alternatives across choices"
  QNR-ERROR-SOLUTIONS-DUPLICATE-ALTERNATIVES-ACROSS-CHOICES
  (qnr-validate-solution SOLUTIONS-INVALID-DUPLICATE-ALTERNATIVES-ACROSS-CHOICES))

(test-end TEST-SUITE-NAME)
