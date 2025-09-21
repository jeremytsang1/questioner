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

(define CHOICE-SINGLE-ALTERNATIVE-EXTRA-EXTERIOR-WHITESPACE-FORMATTED
  '("extra-exterior-whitespace"))
(define CHOICE-SINGLE-ALTERNATIVE-EXTRA-EXTERIOR-WHITESPACE
  '("       extra-exterior-whitespace   "))
(define CHOICE-SINGLE-ALTERNATIVE-EXTRA-INTERIOR-WHITESPACE-FORMATTED
  '("extra interior whitespace"))
(define CHOICE-SINGLE-ALTERNATIVE-EXTRA-INTERIOR-WHITESPACE
  '("extra   interior     whitespace"))
(define CHOICE-MULTIPLE-ALTERNATIVE-EXTRA-WHITESPACE-FORMATTED
  '("alfa" "bravo charlie" "delta"))
(define CHOICE-MULTIPLE-ALTERNATIVE-EXTRA-WHITESPACE
  '("  alfa   " "bravo    charlie  " "  delta"))

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
  CHOICE-SINGLE-ALTERNATIVE-EXTRA-EXTERIOR-WHITESPACE-FORMATTED
  (qnr-format-choice CHOICE-SINGLE-ALTERNATIVE-EXTRA-EXTERIOR-WHITESPACE))

(test-equal "format single alternative with extra interior whitespace"
  '("extra interior whitespace")
  (qnr-format-choice '("extra   interior     whitespace")))

(test-equal "format single alternative with extra interior whitespace"
  CHOICE-SINGLE-ALTERNATIVE-EXTRA-INTERIOR-WHITESPACE-FORMATTED
  (qnr-format-choice CHOICE-SINGLE-ALTERNATIVE-EXTRA-INTERIOR-WHITESPACE))

(test-equal "format multiple alternatives with extra whitespace"
  CHOICE-MULTIPLE-ALTERNATIVE-EXTRA-WHITESPACE-FORMATTED
  (qnr-format-choice CHOICE-MULTIPLE-ALTERNATIVE-EXTRA-WHITESPACE))

(test-equal "format duplicates with extra whitespace away"
  '("pencil sharpener")
  (qnr-format-choice
   '("pencil sharpener  " "   pencil sharpener" "   pencil     sharpener   ")))

(test-equal "format duplicates with extra whitespace away"
  '("rock" "paper" "scissors")
  (qnr-format-choice
   '("rock    " "paper" "scissors" "  paper " "  paper " "rock   ")))

;; Answer Checking ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-equal "fail to find an answer among the alternatives"
  #f
  (qnr-choice-includes-answer? '("head" "shoulders" "knees" "toes") "hand"))

;; Construction ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; WARNING: test-error is not completely implemented in Guile Scheme (See
;; https://wolfsden.cz/blog/post/state-of-srfi-64.html). It is good enough to
;; know when any error is thrown but not a specific error. So here we are using
;; the first argument is just a non-functional descriptor.
(test-error "Fail to construct choice from empty list"
            QNR-ERROR-KEY-CHOICE-CONSTRUCTION
            (qnr-make-choice '()))

(test-error "Fail to construct choice from wrong type: integer"
            QNR-ERROR-KEY-CHOICE-CONSTRUCTION
            (qnr-make-choice 1231))

(test-error "Fail to construct choice from wrong type: string"
            QNR-ERROR-KEY-CHOICE-CONSTRUCTION
            (qnr-make-choice "foo"))

(test-error "Fail to construct choice from wrong type: list of lists"
            QNR-ERROR-KEY-CHOICE-CONSTRUCTION
            (qnr-make-choice ("foo" ("bar"))))

(test-error "Fail to construct choice due to duplicates"
            QNR-ERROR-KEY-CHOICE-CONSTRUCTION
            (qnr-make-choice ("foo" "bar" "foo")))

(test-equal "Constuct single alternative choice"
  '("foo")
  (qnr-make-choice '("foo")))

(test-equal "Constuct single unformatted alternative choice"
  '("foo")
  (qnr-make-choice '("foo    ")))

(test-equal "Constuct multiple unformatted alternatives choice"
  '("foo" "bar" "baz" "bop")
  (qnr-make-choice '("foo" "   foo   " "bar" "baz" "bop" "bar")))

(test-end TEST-SUITE-NAME)
