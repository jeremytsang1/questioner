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

(define SOLUTION-VALID-SINGLE-CHOICE '(("bar"))) ;; TODO

(define EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE 1)

(define QUESTION-NUMBER-VALID-POSITIVE-INTEGER 123)
(define QUESTION-NUMBER-INVALID-TYPE "hello") ;; Not an integer.
(define QUESTION-NUMBER-INVALID-ZERO 0)
(define QUESTION-NUMBER-INVALID-NEGATIVE -43)

;; Tests ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-begin TEST-SUITE-NAME)

(test-assert "<question> fieldname access"
  (let ((question (qnr-make-question "a" "b" "c")))
    (and (string=? (qnr-query question) "a")
         (string=? (qnr-solution question) "b")
         (string=? (qnr-question-number question) "c"))))

;; Validation Tests ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-equal "valid single response <question>"
  QNR-VALID-QUESTION-NO-ERROR
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTION-VALID-SINGLE-CHOICE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate an object that is not a <question>"
  QNR-ERROR-NON-QUESTION
  (qnr-validate-question '(foo bar baz bop)))

(test-equal "validate <question> with field `query` that is non-string"
  QNR-ERROR-QUERY-NON-STRING
  (qnr-validate-question
   (qnr-make-question QUERY-INVALID-NON-STRING
                      SOLUTION-VALID-SINGLE-CHOICE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with field `query` that is an empty string"
  QNR-ERROR-QUERY-EMPTY
  (qnr-validate-question
   (qnr-make-question QUERY-INVALID-WRONG-TYPE
                      SOLUTION-VALID-SINGLE-CHOICE
                      QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))

(test-equal "validate <question> with field `question-number` that is non-integer"
  QNR-ERROR-QUESTION-NUMBER-WRONG-TYPE
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTION-VALID-SINGLE-CHOICE
                      QUESTION-NUMBER-INVALID-TYPE)))

(test-equal "validate <question> with field `question-number` that is 0"
  QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTION-VALID-SINGLE-CHOICE
                      QUESTION-NUMBER-INVALID-ZERO)))

(test-equal "validate <question> with field `question-number` that is negative"
  QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTION-VALID-SINGLE-CHOICE
                      QUESTION-NUMBER-INVALID-NEGATIVE)))

(test-end TEST-SUITE-NAME)
