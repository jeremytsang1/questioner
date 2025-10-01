;;; (tests question-test) --- Test for module (src quiz question)
;; Usage: guile -L . tests/answer-test.scm LOG-DIRECTORY # From project root.
#!/usr/local/bin/guile -s
!#

(use-modules (srfi srfi-64)
             (util test)
             (src quiz question))

(define TEST-SUITE-NAME (qnr-generate-log-file-name))

(define QUERY-VALID "foo")
(define QUERY-INVALID-NON-STRING '())
(define QUERY-INVALID-WRONG-TYPE "")

(define CHOICES-VALID-SINGLE '(("bar"))) ;; TODO

(define EXPECTED-RESPONSE-COUNT-VALID-SINGLE 1)

(define QUESTION-NUMBER-VALID-POSITIVE-INTEGER 123)
(define QUESTION-NUMBER-INVALID-TYPE "hello") ;; Not an integer.
(define QUESTION-NUMBER-INVALID-ZERO 0)
(define QUESTION-NUMBER-INVALID-NEGATIVE -43)

;; Tests ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-begin TEST-SUITE-NAME)

(test-assert "<qnr-question> fieldname access"
  (let ((question (qnr-make-question QUERY-VALID
                                     CHOICES-VALID-SINGLE
                                     EXPECTED-RESPONSE-COUNT-VALID-SINGLE
                                     QUESTION-NUMBER-VALID-POSITIVE-INTEGER)))
    (and (string=? (qnr-question-query question) QUERY-VALID)
         (= (qnr-question-question-number question) QUESTION-NUMBER-VALID-POSITIVE-INTEGER))))

;; Validation Tests ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-equal "valid constructing single response <qnr-question> without error"
  'completed-without-throwing-any-errors
  (begin
    (qnr-make-question QUERY-VALID
                       CHOICES-VALID-SINGLE
                       EXPECTED-RESPONSE-COUNT-VALID-SINGLE
                       QUESTION-NUMBER-VALID-POSITIVE-INTEGER)
    'completed-without-throwing-any-errors))

(qnr-test-error-message
 "validate an object that is not a <qnr-question>"
 QNR-ERROR-KEY-QUESTION
 QNR-ERROR-NON-QUESTION
 (lambda () (qnr-validate-question '(foo bar baz bop))))

(qnr-test-error-message
 "validate <qnr-question> with field `query` that is non-string"
 QNR-ERROR-KEY-QUESTION
 QNR-ERROR-QUERY-NON-STRING
 (lambda () (qnr-validate-question
             (qnr-make-question QUERY-INVALID-NON-STRING
                                CHOICES-VALID-SINGLE
                                EXPECTED-RESPONSE-COUNT-VALID-SINGLE
                                QUESTION-NUMBER-VALID-POSITIVE-INTEGER))))

(qnr-test-error-message
 "validate <qnr-question> with field `query` that is an empty string"
 QNR-ERROR-KEY-QUESTION
 QNR-ERROR-QUERY-EMPTY
 (lambda () (qnr-validate-question
             (qnr-make-question QUERY-INVALID-WRONG-TYPE
                                CHOICES-VALID-SINGLE
                                EXPECTED-RESPONSE-COUNT-VALID-SINGLE
                                QUESTION-NUMBER-VALID-POSITIVE-INTEGER))))

(qnr-test-error-message
 "validate <qnr-question> with field `question-number` that is non-integer"
 QNR-ERROR-KEY-QUESTION
 QNR-ERROR-QUESTION-NUMBER-WRONG-TYPE
 (lambda () (qnr-validate-question
             (qnr-make-question QUERY-VALID
                                CHOICES-VALID-SINGLE
                                EXPECTED-RESPONSE-COUNT-VALID-SINGLE
                                QUESTION-NUMBER-INVALID-TYPE))))

(qnr-test-error-message
 "validate <qnr-question> with field `question-number` that is 0"
 QNR-ERROR-KEY-QUESTION
 QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE
 (lambda () (qnr-validate-question
             (qnr-make-question QUERY-VALID
                                CHOICES-VALID-SINGLE
                                EXPECTED-RESPONSE-COUNT-VALID-SINGLE
                                QUESTION-NUMBER-INVALID-ZERO))))

(qnr-test-error-message
 "validate <qnr-question> with field `question-number` that is negative"
 QNR-ERROR-KEY-QUESTION
 QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE
 (lambda () (qnr-validate-question
             (qnr-make-question QUERY-VALID
                                CHOICES-VALID-SINGLE
                                EXPECTED-RESPONSE-COUNT-VALID-SINGLE
                                QUESTION-NUMBER-INVALID-NEGATIVE))))

;; Tests for Helpers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-equal "qnr-nested-vector->nested-list: empty list"
  '()
  (qnr-nested-vector->nested-list #()))

(test-equal "qnr-nested-vector->nested-list: multiple vectors"
  '((a b c) (x y z))
  (qnr-nested-vector->nested-list (vector (vector 'a 'b 'c)
                                          (vector 'x 'y 'z))))

(test-equal "qnr-nested-vector->nested-list: empty sub-vectors"
  '((a b c) (x y z) ())
  (qnr-nested-vector->nested-list (vector (vector 'a 'b 'c)
                                          (vector 'x 'y 'z)
                                          (vector))))

(test-end TEST-SUITE-NAME)
