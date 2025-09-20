;;; (tests question-test) --- Test for module (src question)
;; Usage: guile -L . tests/answer-test.scm LOG-DIRECTORY # From project root.
#!/usr/local/bin/guile -s
!#

(use-modules (srfi srfi-64)
             (util test)
             (src question))

(define TEST-SUITE-NAME (qnr-generate-log-file-name))

(define QUERY-VALID "foo")
(define QUERY-INVALID-NON-STRING '())
(define QUERY-INVALID-WRONG-TYPE "")

(define SOLUTIONS-VALID-SINGLE-CHOICE '(("bar")))
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

(define EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE 1)

(define QUESTION-NUMBER-VALID-POSITIVE-INTEGER 123)
(define QUESTION-NUMBER-INVALID-TYPE "hello") ;; Not an integer.
(define QUESTION-NUMBER-INVALID-ZERO 0)
(define QUESTION-NUMBER-INVALID-NEGATIVE -43)

;; Tests ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-begin TEST-SUITE-NAME)

(test-assert "<question> fieldname access"
  (let ((question (qnr-make-question "a" "b" "c" "d")))
    (and (string=? (qnr-query question) "a")
         (string=? (qnr-solutions question) "b")
         (string=? (qnr-expected-response-count question) "c")
         (string=? (qnr-question-number question) "d"))))

;; Validation Tests ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(test-equal "valid single response <question>"
  QNR-VALID-QUESTION-NO-ERROR
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-VALID-SINGLE-CHOICE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate an object that is not a <question>"
  QNR-ERROR-NON-QUESTION
  (qnr-validate-question '(foo bar baz bop)))

(test-equal "validate <question> with field `query` that is non-string"
  QNR-ERROR-QUERY-NON-STRING
  (qnr-validate-question
   (qnr-make-question QUERY-INVALID-NON-STRING
                      SOLUTIONS-VALID-SINGLE-CHOICE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with field `query` that is an empty string"
  QNR-ERROR-QUERY-EMPTY
  (qnr-validate-question
   (qnr-make-question QUERY-INVALID-WRONG-TYPE
                      SOLUTIONS-VALID-SINGLE-CHOICE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with string for `solutions` instead of list"
  QNR-ERROR-SOLUTIONS-WRONG-TYPE
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-INVALID-WRONG-TYPE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with an empty list for `solutions`"
  QNR-ERROR-SOLUTIONS-NO-CHOICES-FOUND
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-INVALID-NO-CHOICES
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with `solutions` has non-list members"
  QNR-ERROR-SOLUTIONS-CHOICES-WRONG-TYPE
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-INVALID-CHOICES-WRONG-TYPE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with `solutions` that has an empty sublist"
  QNR-ERROR-SOLUTIONS-CHOICES-EMPTY
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-INVALID-EMPTY-CHOICE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with `solutions` that has a sublist containing a non-string"
  QNR-ERROR-SOLUTIONS-ALTERNATIVE-WRONG-TYPE
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-INVALID-ALTERNATIVE-WRONG-TYPE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with `solutions` with empty string in sublist"
  QNR-ERROR-SOLUTIONS-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-INVALID-EMPTY-ALTERNATIVE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with `solutions` with entirely spaces alternative"
  QNR-ERROR-SOLUTIONS-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-INVALID-EMPTY-ALTERNATIVE-SPACES
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with alternatives containing only tabs"
  QNR-ERROR-SOLUTIONS-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-INVALID-EMPTY-ALTERNATIVE-TABS
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with duplicate alternatives across choices"
  QNR-ERROR-SOLUTIONS-DUPLICATE-ALTERNATIVES-ACROSS-CHOICES
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-INVALID-DUPLICATE-ALTERNATIVES-ACROSS-CHOICES
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))


(test-equal "validate <question> with field `question-number` that is non-integer"
  QNR-ERROR-QUESTION-NUMBER-WRONG-TYPE
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-VALID-SINGLE-CHOICE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-INVALID-TYPE)))

(test-equal "validate <question> with field `question-number` that is 0"
  QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-VALID-SINGLE-CHOICE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-INVALID-ZERO)))

(test-equal "validate <question> with field `question-number` that is negative"
  QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-VALID-SINGLE-CHOICE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-INVALID-NEGATIVE)))



(test-end TEST-SUITE-NAME)
