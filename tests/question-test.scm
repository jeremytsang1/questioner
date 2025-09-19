;;; (tests question-test) --- Test for module (src question)
;; Usage: guile -L . tests/answer-test.scm LOG-DIRECTORY # From project root.
#!/usr/local/bin/guile -s
!#

(use-modules (srfi srfi-64)
             (util test)
             (src question))

(define TEST-SUITE-NAME (qnr-generate-log-file-name))
(define QUERY-VALID "foo")
(define SOLUTIONS-VALID-SINGLE-RESPONSE '(("bar")))
(define EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE 1)
(define QUESTION-NUMBER-INVALID-TYPE "hello") ;; Not an integer.

;; Tests ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-begin TEST-SUITE-NAME)

(test-equal "valid single response question"
  QNR-VALID-QUESTION-LACK-OF-ERROR-MESSAGE
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-VALID-SINGLE-RESPONSE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      123)))

(test-assert "question fieldname access"
  (let ((question (qnr-make-question "a" "b" "c" "d")))
    (and (string=? (qnr-query question) "a")
         (string=? (qnr-solutions question) "b")
         (string=? (qnr-expected-response-count question) "c")
         (string=? (qnr-question-number question) "d"))))

(test-equal "validate an object that is not a <question>"
  QNR-ERROR-NON-QUESTION
  (qnr-validate-question '(foo bar baz bop)))

(test-equal "validate <question> with field number that is non-integer"
  QNR-ERROR-NON-INTEGER-QUESTION-NUMBER
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-VALID-SINGLE-RESPONSE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      QUESTION-NUMBER-INVALID-TYPE)))

(test-equal "validate <question> with field number that is 0"
  "<question> has non-positive question-number"
  (qnr-validate-question
   (qnr-make-question QUERY-VALID
                      SOLUTIONS-VALID-SINGLE-RESPONSE
                      EXPECTED-RESPONSE-COUNT-VALID-SINGLE-REPONSE
                      0)))

(test-end TEST-SUITE-NAME)
