;;; (tests choice-test) --- Test for module (src choice)
;; Usage: guile -L . tests/answer-test.scm LOG-DIRECTORY # From project root.
#!/usr/local/bin/guile -s
!#

(use-modules (srfi srfi-64) (util test) (src choice))

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define TEST-SUITE-NAME (qnr-generate-log-file-name))

(define CHOICE-VALID-CHOICE-SINGLE-ALTERNATIVES '("hello"))
(define CHOICE-VALID-CHOICE-MULTIPLE-ALTERNATIVES '("foo" "bar" "baz" "bop"))
(define CHOICE-INVALID-EMPTY-CHOICE '())
(define CHOICE-INVALID-ALTERNATIVE-WRONG-TYPE '(("abc")))
(define CHOICE-INVALID-EMPTY-ALTERNATIVE '("alpha" "" "beta"))
(define CHOICE-INVALID-EMPTY-ALTERNATIVE-SPACES '("d " "        " "e"))
(define CHOICE-INVALID-EMPTY-ALTERNATIVE-TABS '("d " "\t\t\t\t" "e"))

;; Tests ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-begin TEST-SUITE-NAME)

;; Validation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-equal "validate valid `choice` with single alternative"
  QNR-VALID-CHOICE-NO-ERROR
  (qnr-validate-choice CHOICE-VALID-CHOICE-SINGLE-ALTERNATIVES))

(test-equal "validate valid `choice` with multiple alternatives"
  QNR-VALID-CHOICE-NO-ERROR
  (qnr-validate-choice CHOICE-VALID-CHOICE-MULTIPLE-ALTERNATIVES))

(test-equal "validate `choice` cannot be empty"
  QNR-ERROR-CHOICE-EMPTY
  (qnr-validate-choice CHOICE-INVALID-EMPTY-CHOICE))

(test-equal "validate `choice` containing non-string alternative"
  QNR-ERROR-CHOICE-ALTERNATIVE-WRONG-TYPE
  (qnr-validate-choice CHOICE-INVALID-ALTERNATIVE-WRONG-TYPE))

(test-equal "validate `choice` with empty string alternative"
  QNR-ERROR-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
  (qnr-validate-choice CHOICE-INVALID-EMPTY-ALTERNATIVE))

(test-equal "validate `choice` with alternative made entirely of spaces"
  QNR-ERROR-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
  (qnr-validate-choice CHOICE-INVALID-EMPTY-ALTERNATIVE-SPACES))

(test-equal "validate `choice` with alternative made entirely of tabs"
  QNR-ERROR-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
  (qnr-validate-choice CHOICE-INVALID-EMPTY-ALTERNATIVE-TABS))

;; Formatting ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-equal "format single alternative with extra exterior whitespace"
  '("extra-exterior-whitespace")
  (qnr-format-choice '("       extra-exterior-whitespace   ")))

(test-equal "format single alternative with extra interior whitespace"
  '("extra interior whitespace")
  (qnr-format-choice '("extra   interior     whitespace")))

(test-equal "format single alternative with extra interior whitespace"
  '("extra interior whitespace")
  (qnr-format-choice '("extra   interior     whitespace")))

(test-equal "format multiple alternatives with extra whitespace"
  '("alfa" "bravo charlie" "delta")
  (qnr-format-choice '("  alfa   " "bravo    charlie  " "  delta")))

(test-end TEST-SUITE-NAME)
