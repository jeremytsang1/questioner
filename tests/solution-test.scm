;;; (tests solution-test) --- Test for module (src solution)
;; Usage: guile -L . tests/answer-test.scm LOG-DIRECTORY # From project root.
#!/usr/local/bin/guile -s
!#

(use-modules (srfi srfi-64)
             (util test)             
             (src solution))

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define TEST-SUITE-NAME (qnr-generate-log-file-name))

(define CHOICES-INVALID-WRONG-TYPE "not a list")
(define CHOICES-INVALID-NO-CHOICES '())
(define CHOICES-INVALID-CHOICES-WRONG-TYPE
  '(("foo") "bar" "bop"))
(define CHOICES-INVALID-EMPTY-CHOICE
  '(("foo" "bar") () '("baz" "bop")))
(define CHOICES-INVALID-ALTERNATIVE-WRONG-TYPE
  '((("abc")) ("1" "2" "3")))
(define CHOICES-INVALID-EMPTY-ALTERNATIVE
  '(("foo" "baz" "bop") ("baz") ("alpha" "" "beta")))
(define CHOICES-INVALID-EMPTY-ALTERNATIVE-SPACES
  '(("a" "b" " c ") ("d " "        " "e") ("f")))
(define CHOICES-INVALID-EMPTY-ALTERNATIVE-TABS
  '(("a" "b" " c ") ("d " "\t\t\t\t" "e") ("f")))
(define CHOICES-INVALID-DUPLICATE-ALTERNATIVES-ACROSS-CHOICES
  '(("alpha" "beta" "gamma")
    ("delta")
    ("kappa" "lambda" "alpha" "mu")))

;; Tests ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-begin TEST-SUITE-NAME)

(test-equal "validate `choices` with list value"
  QNR-ERROR-SOLUTIONS-WRONG-TYPE
  (qnr-validate-solution CHOICES-INVALID-WRONG-TYPE))

(test-equal "validate empty list `choices`"
  QNR-ERROR-SOLUTIONS-NO-CHOICES-FOUND
  (qnr-validate-solution CHOICES-INVALID-NO-CHOICES))

(test-equal "validate `choices` with non-list members"
  QNR-ERROR-SOLUTIONS-CHOICES-WRONG-TYPE
  (qnr-validate-solution CHOICES-INVALID-CHOICES-WRONG-TYPE))

(test-equal "validate `choices` with empty sublist"
  QNR-ERROR-SOLUTIONS-CHOICES-EMPTY
  (qnr-validate-solution CHOICES-INVALID-EMPTY-CHOICE))

(test-equal "validate `choices` with sublist containing non-string"
  QNR-ERROR-SOLUTIONS-ALTERNATIVE-WRONG-TYPE
  (qnr-validate-solution CHOICES-INVALID-ALTERNATIVE-WRONG-TYPE))

(test-equal "validate `choices` with empty string in sublist"
  QNR-ERROR-SOLUTIONS-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
  (qnr-validate-solution CHOICES-INVALID-EMPTY-ALTERNATIVE))

(test-equal "validate `choices` with alternative made entirely of spaces"
  QNR-ERROR-SOLUTIONS-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
  (qnr-validate-solution CHOICES-INVALID-EMPTY-ALTERNATIVE-SPACES))

(test-equal "validate `choices` with alternative made entirely of tabs"
  QNR-ERROR-SOLUTIONS-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
  (qnr-validate-solution CHOICES-INVALID-EMPTY-ALTERNATIVE-TABS))

(test-equal "validate `choices` with duplicate alternatives across sublists"
  QNR-ERROR-SOLUTIONS-DUPLICATE-ALTERNATIVES-ACROSS-CHOICES
  (qnr-validate-solution CHOICES-INVALID-DUPLICATE-ALTERNATIVES-ACROSS-CHOICES))

(test-end TEST-SUITE-NAME)
