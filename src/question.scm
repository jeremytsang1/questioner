(define-module (src question)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:use-module (src solution)
  #:export (QNR-ERROR-KEY-QUESTION
            QNR-VALID-QUESTION-NO-ERROR
            QNR-ERROR-NON-QUESTION
            QNR-ERROR-QUERY-NON-STRING
            QNR-ERROR-QUERY-EMPTY
            QNR-ERROR-QUESTION-NUMBER-WRONG-TYPE
            QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE
            QNR-ERROR-QUESTION-NUMBER-NEGATIVE
            qnr-make-question
            qnr-question-query
            qnr-question-solution
            qnr-question-question-number
            qnr-validate-question))

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DESIGN CHOICE: Would have preferred to use symbols and exceptions for the
;; below but since since the Guile implementation of srfi-64 does not match
;; error types (see https://debbugs.gnu.org/cgi/bugreport.cgi?bug=66776 and
;; https://wolfsden.cz/blog/post/state-of-srfi-64.html) it is not feasible to
;; use those in srfi-64 tests since there would be no way to verfiy if the
;; correct error is being caught or not, only that an error is being caught.
(define QNR-ERROR-KEY-QUESTION 'qnr-error-question)

(define QNR-VALID-QUESTION-NO-ERROR "")
(define QNR-ERROR-NON-QUESTION "passed object is not a <qnr-question>")
(define QNR-ERROR-QUERY-NON-STRING
  "<qnr-question> has non-string `query`")
(define QNR-ERROR-QUERY-EMPTY
  "<qnr-question> has `query` that is empty")
(define QNR-ERROR-QUESTION-NUMBER-WRONG-TYPE
  "<qnr-question> `question-number` has wrong type")
(define QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE
  "<qnr-question> has non-positive `question-number`")
(define QNR-ERROR-QUESTION-NUMBER-NEGATIVE
  "<qnr-question> has negative `question-number`")

;; Record Definition ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-record-type <qnr-question>
  (raw-make-question query solution question-number)
  qnr-question?
  (query qnr-question-query)
  (solution qnr-question-solution)
  (question-number qnr-question-question-number))

(define (qnr-make-question query
                           choices
                           expected-response-count
                           question-number)
  "Create a record representing a quiz question.

QUERY is a string of text to be shown to users. It represents the question that
needs to be answered.

CHOICE-LIST is a non-empty list of list of strings. None of the strings
should be made entirely from whitespace or empty (see (src choice)). They
should not be duplicates across sublists (see (src solution)).

EXPECTED-RESPONSE-COUNT is a positive integer that is less than or equal
to `(length CHOICES)`. This represents the number of answers the user must
provide when answering a question. For example for a question like \"Name two
primary colors?\" where the choices c '((\"red\") (\"yellow\") (\"blue\")) the
EXPECTED-RESPONSE-COUNT would be 2 and the user could answer any 2 combination
of the 3 possible choices (e.g. red and blue, red and yellow, or blue and
yellow).

QUESTION-NUMBER is a positive integer."
  (let* ((solution (qnr-make-solution choices expected-response-count)))
    (raw-make-question query solution question-number)))

;; Validation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (qnr-validate-question question)
  (let ((error-message
         (fold
          (lambda (validator prev-error-message)
            ;; Return early when already have a previous error message. Don't bother
            ;; doing any more checks once a validation error is found becuase later
            ;; validators may assume the earlier validators pass.
            (if (not (string-null? prev-error-message))
                prev-error-message
                (validator question)))
          QNR-VALID-QUESTION-NO-ERROR ;; Begin assuming question is valid
          (list validate-question-is-<record>
                validate-query
                validate-question-number))))

    (unless (string=? error-message QNR-VALID-QUESTION-NO-ERROR)
      (throw QNR-ERROR-KEY-QUESTION error-message))))

(define (validate-question-is-<record> question)
  (if (not (qnr-question? question)) QNR-ERROR-NON-QUESTION ""))

(define (validate-query question)
  (let ((question (qnr-question-query question)))
    (cond ((not (string? question)) QNR-ERROR-QUERY-NON-STRING)
          ((string-null? question) QNR-ERROR-QUERY-EMPTY)
          (else QNR-VALID-QUESTION-NO-ERROR))))

(define (validate-question-number question)
  (let ((question-number (qnr-question-question-number question)))
    (cond ((not (integer? question-number)) QNR-ERROR-QUESTION-NUMBER-WRONG-TYPE)
          ((= question-number 0) QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE)
          ((< question-number 0) QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE)
          (else QNR-VALID-QUESTION-NO-ERROR))))
