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
(define QUERY-INVALID-EMPTY-STRING "")

(define SOLUTIONS-VALID-SINGLE-RESPONSE '(("bar")))
(define SOLUTIONS-INVALID-NON-LIST "not a list")
(define SOLUTIONS-INVALID-EMPTY-TOP-LEVEL '())
(define SOLUTIONS-INVALID-CONTAINS-NON-LIST-TOP-LEVEL-MEMBER
  '(("foo") "bar" "bop"))
(define SOLUTIONS-INVALID-CONTAINS-EMPTY-SUBLIST
  '(("foo" "bar") () '("baz" "bop")))
(define SOLUTIONS-INVALID-SUBLIST-CONTAINS-NON-STRING
  '((("abc")) ("1" "2" "3")))

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

(test-equal "valid single response <question>"
  QNR-VALID-QUESTION-NO-ERROR
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-VALID-SINGLE-RESPONSE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate an object that is not a <question>"
  QNR-ERROR-NON-QUESTION
  (qnr-validate-question '(foo bar baz bop)))

(test-equal "validate <question> with field `query` that is non-string"
  QNR-ERROR-QUERY-NON-STRING
  (qnr-validate-question
   (qnr-make-question QUERY-INVALID-NON-STRING
                      SOLUTIONS-VALID-SINGLE-RESPONSE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with field `query` that is an empty string"
  QNR-ERROR-QUERY-EMPTY-STRING
  (qnr-validate-question
   (qnr-make-question QUERY-INVALID-EMPTY-STRING
                      SOLUTIONS-VALID-SINGLE-RESPONSE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with string for `solutions` instead of list"
  QNR-ERROR-SOLUTIONS-NON-LIST
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-INVALID-NON-LIST
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with an empty list for `solutions`"
  QNR-ERROR-SOLUTIONS-EMPTY-TOP-LEVEL
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-INVALID-EMPTY-TOP-LEVEL
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with `solutions` has non-list members"
  QNR-ERROR-SOLUTIONS-NON-LIST-TOP-LEVEL-MEMBER
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-INVALID-CONTAINS-NON-LIST-TOP-LEVEL-MEMBER
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with `solutions` that has an empty sublist"
  QNR-ERROR-SOLUTIONS-CONTAINS-EMPTY-SUBLIST
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-INVALID-CONTAINS-EMPTY-SUBLIST
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with `solutions` that has a sublist containing a non-string"
  QNR-ERROR-SOLUTIONS-SUBLIST-CONTAINS-NON-STRING
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-INVALID-SUBLIST-CONTAINS-NON-STRING
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with `solutions` with empty string in sublist"
  "<question> `solutions` contains empty string in a sublist"
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      '(("foo" "baz" "bop") ("baz") ("alpha" "" "beta"))
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with field `question-number` that is non-integer"
  QNR-ERROR-QUESTION-NUMBER-NON-INTEGER
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-VALID-SINGLE-RESPONSE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-INVALID-TYPE)))

(test-equal "validate <question> with field `question-number` that is 0"
  QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-VALID-SINGLE-RESPONSE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-INVALID-ZERO)))

(test-equal "validate <question> with field `question-number` that is negative"
  QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-VALID-SINGLE-RESPONSE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-INVALID-NEGATIVE)))

(test-end TEST-SUITE-NAME)
