(define-module (src question)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:export (QNR-VALID-QUESTION-NO-ERROR
            QNR-ERROR-NON-QUESTION
            QNR-ERROR-QUERY-NON-STRING
            QNR-ERROR-QUERY-EMPTY-STRING
            QNR-ERROR-SOLUTIONS-NON-LIST
            QNR-ERROR-QUESTION-NUMBER-NON-INTEGER
            QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE
            QNR-ERROR-QUESTION-NUMBER-NEGATIVE
            qnr-make-question
            qnr-query
            qnr-solutions
            qnr-expected-response-count
            qnr-question-number
            qnr-validate-question))

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define DOC-QNR-MAKE-QUESTION
  "Create a record representing a quiz question.

QUERY is a string of text to be shown to users. It represents the question that
needs to be answered.

SOLUTIONS is a list of list of non-empty strings. Each sublist of string
represents a valid answer to the question where elements of a given sublist
represent equivalent versions of a particular answer.

EXPECTED-RESPONSE-COUNT is a positive integer representing how many answers
users must guess from SOLUTIONS to have been considered answering the question.")

(define QNR-VALID-QUESTION-NO-ERROR "")
(define QNR-ERROR-NON-QUESTION "passed object is not a <question>")
(define QNR-ERROR-QUERY-NON-STRING
  "<question> has non-string `query`")
(define QNR-ERROR-QUERY-EMPTY-STRING
  "<question> has `query` that is an empty string")
(define QNR-ERROR-SOLUTIONS-NON-LIST
  "<question> has a non-list for `solutions`")
(define QNR-ERROR-QUESTION-NUMBER-NON-INTEGER
  "<question> has non-integer `question-number`")
(define QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE
  "<question> has non-positive `question-number`")
(define QNR-ERROR-QUESTION-NUMBER-NEGATIVE
  "<question> has negative `question-number`")

;; Record Definition ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-record-type <question>
  (qnr-make-question query solutions expected-response-count question-number)
  qnr-question?
  (query qnr-query)
  (solutions qnr-solutions)
  (expected-response-count qnr-expected-response-count)
  (question-number qnr-question-number))

(set-procedure-property!
 qnr-make-question
 'documentation
 DOC-QNR-MAKE-QUESTION)

;; Validation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (qnr-validate-question question)
  (fold
   (lambda (validator prev-error-message)
     ;; Return early when already have a previous error message. Don't bother
     ;; doing any more checks once a validation error is found becuase later
     ;; validators may assume the earlier validators pass (e.g. can't check
     ;; expected-response-count if solutions is not a list).
     (if (not (string-null? prev-error-message))
         prev-error-message
         (validator question)))
   QNR-VALID-QUESTION-NO-ERROR ;; Begin assuming question is valid
   (list validate-question-is-<record>
         validate-query
         validate-question-number
         validate-solutions)))

(define (validate-question-is-<record> question)
  (if (not (qnr-question? question)) QNR-ERROR-NON-QUESTION ""))

(define (validate-query question)
  (cond ((not (string? (qnr-query question))) QNR-ERROR-QUERY-NON-STRING)
        ((string-null? (qnr-query question)) QNR-ERROR-QUERY-EMPTY-STRING)
        (else QNR-VALID-QUESTION-NO-ERROR)))

(define (validate-solutions question)
  (cond ((not (list? (qnr-solutions question)))
         QNR-ERROR-SOLUTIONS-NON-LIST)
        (else QNR-VALID-QUESTION-NO-ERROR)))

(define (validate-question-number question)
  (cond ((not (integer? (qnr-question-number question)))
         QNR-ERROR-QUESTION-NUMBER-NON-INTEGER)
        ((= (qnr-question-number question) 0)
         QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE)
        ((< (qnr-question-number question) 0)
         QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE)
        (else QNR-VALID-QUESTION-NO-ERROR)))
