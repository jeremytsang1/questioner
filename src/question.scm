(define-module (src question)
  #:use-module (srfi srfi-9)
  #:export (QNR-ERROR-NON-QUESTION
            QNR-ERROR-NON-INTEGER-QUESTION-NUMBER
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


(define QNR-ERROR-NON-QUESTION "passed object is not a <question>")
(define QNR-ERROR-NON-INTEGER-QUESTION-NUMBER
  "<question> has non-integer value")

;;  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
  (cond ((not (qnr-question? question)) QNR-ERROR-NON-QUESTION)
        ((not (integer? (qnr-question-number question)))
         QNR-ERROR-NON-INTEGER-QUESTION-NUMBER)
        (else "")))
