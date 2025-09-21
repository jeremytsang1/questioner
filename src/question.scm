(define-module (src question)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:export (QNR-VALID-QUESTION-NO-ERROR
            QNR-ERROR-NON-QUESTION
            QNR-ERROR-QUERY-NON-STRING
            QNR-ERROR-QUERY-EMPTY
            QNR-ERROR-QUESTION-NUMBER-WRONG-TYPE
            QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE
            QNR-ERROR-QUESTION-NUMBER-NEGATIVE
            qnr-make-question
            qnr-query
            qnr-solution
            qnr-question-number
            qnr-validate-question))

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define DOC-QNR-MAKE-QUESTION
  "Create a record representing a quiz question.

QUERY is a string of text to be shown to users. It represents the question that
needs to be answered.

SOLUTION is a record object of <solution>. See module (src solution).")

;; DESIGN CHOICE: Would have preferred to use symbols and exceptions for the
;; below but since since the Guile implementation of srfi-64 does not match
;; error types (see https://debbugs.gnu.org/cgi/bugreport.cgi?bug=66776 and
;; https://wolfsden.cz/blog/post/state-of-srfi-64.html) it is not feasible to
;; use those in srfi-64 tests since there would be no way to verfiy if the
;; correct error is being caught or not, only that an error is being caught.
(define QNR-VALID-QUESTION-NO-ERROR "")
(define QNR-ERROR-NON-QUESTION "passed object is not a <question>")
(define QNR-ERROR-QUERY-NON-STRING
  "<question> has non-string `query`")
(define QNR-ERROR-QUERY-EMPTY
  "<question> has `query` that is empty")
(define QNR-ERROR-QUESTION-NUMBER-WRONG-TYPE
  "<question> `question-number` has wrong type")
(define QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE
  "<question> has non-positive `question-number`")
(define QNR-ERROR-QUESTION-NUMBER-NEGATIVE
  "<question> has negative `question-number`")

;; Record Definition ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-record-type <question>
  (qnr-make-question query solution question-number)
  qnr-question?
  (query qnr-query)
  (solution qnr-solution)
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
     ;; validators may assume the earlier validators pass.
     (if (not (string-null? prev-error-message))
         prev-error-message
         (validator question)))
   QNR-VALID-QUESTION-NO-ERROR ;; Begin assuming question is valid
   (list validate-question-is-<record>
         validate-query
         validate-question-number))) ;; TODO: validate solution.

(define (validate-question-is-<record> question)
  (if (not (qnr-question? question)) QNR-ERROR-NON-QUESTION ""))

(define (validate-query question)
  (let ((question (qnr-query question)))
    (cond ((not (string? question)) QNR-ERROR-QUERY-NON-STRING)
          ((string-null? question) QNR-ERROR-QUERY-EMPTY)
          (else QNR-VALID-QUESTION-NO-ERROR))))

(define (validate-question-number question)
  (let ((question-number (qnr-question-number question)))
    (cond ((not (integer? question-number)) QNR-ERROR-QUESTION-NUMBER-WRONG-TYPE)
          ((= question-number 0) QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE)
          ((< question-number 0) QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE)
          (else QNR-VALID-QUESTION-NO-ERROR))))
