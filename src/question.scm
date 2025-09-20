(define-module (src question)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:export (QNR-VALID-QUESTION-NO-ERROR
            QNR-ERROR-NON-QUESTION
            QNR-ERROR-QUERY-NON-STRING
            QNR-ERROR-QUERY-EMPTY-STRING
            QNR-ERROR-SOLUTIONS-NON-LIST
            QNR-ERROR-SOLUTIONS-EMPTY-TOP-LEVEL
            QNR-ERROR-SOLUTIONS-NON-LIST-TOP-LEVEL-MEMBER
            QNR-ERROR-SOLUTIONS-CONTAINS-EMPTY-SUBLIST
            QNR-ERROR-SOLUTIONS-SUBLIST-CONTAINS-NON-STRING
            QNR-ERROR-SOLUTIONS-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
            QNR-ERROR-SOLUTIONS-DUPLICATE-ALTERNATIVES-ACROSS-CHOICES
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
(define QNR-ERROR-QUERY-EMPTY-STRING
  "<question> has `query` that is an empty string")
(define QNR-ERROR-SOLUTIONS-NON-LIST
  "<question> has a non-list for `solutions`")
(define QNR-ERROR-SOLUTIONS-EMPTY-TOP-LEVEL
  "<question> has an empty list for `solutions`")
(define QNR-ERROR-SOLUTIONS-NON-LIST-TOP-LEVEL-MEMBER
  "<question> `solutions` has a non-list top-level member")
(define QNR-ERROR-SOLUTIONS-CONTAINS-EMPTY-SUBLIST
  "<question> `solutions` contains an empty sublist")
(define QNR-ERROR-SOLUTIONS-SUBLIST-CONTAINS-NON-STRING
  "<question> `solutions` contains a sublist with a non-string element.")
(define QNR-ERROR-SOLUTIONS-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
  "<question> `solutions` contains an alternative made entirely of whitespace")
(define QNR-ERROR-SOLUTIONS-DUPLICATE-ALTERNATIVES-ACROSS-CHOICES
  "<question> `solutions` contains duplicate alternatives across choices")
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
  (let ((question (qnr-query question)))
    (cond ((not (string? question)) QNR-ERROR-QUERY-NON-STRING)
          ((string-null? question) QNR-ERROR-QUERY-EMPTY-STRING)
          (else QNR-VALID-QUESTION-NO-ERROR))))

(define (validate-solutions question)
  (let ((solutions (qnr-solutions question)))
    (cond ((not (list? solutions)) QNR-ERROR-SOLUTIONS-NON-LIST)
          ((null? solutions) QNR-ERROR-SOLUTIONS-EMPTY-TOP-LEVEL)
          ((contains-non-list solutions)
           QNR-ERROR-SOLUTIONS-NON-LIST-TOP-LEVEL-MEMBER)
          ((contains-empty-sublist solutions)
           QNR-ERROR-SOLUTIONS-CONTAINS-EMPTY-SUBLIST)
          ((members-contain-non-string solutions)
           QNR-ERROR-SOLUTIONS-SUBLIST-CONTAINS-NON-STRING)
          ((members-contain-empty-string solutions)
           QNR-ERROR-SOLUTIONS-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE)
          ((members-contain-entirely-spaces-string solutions)
           QNR-ERROR-SOLUTIONS-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE)
          ((members-contain-entirely-tabs-string solutions)
           QNR-ERROR-SOLUTIONS-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE)
          ((contains-duplicates-across-sublists? solutions)
           QNR-ERROR-SOLUTIONS-DUPLICATE-ALTERNATIVES-ACROSS-CHOICES)
          (else QNR-VALID-QUESTION-NO-ERROR))))

(define (contains-non-list lst)
  (find (lambda (element) (not (list? element))) lst))

(define (contains-empty-sublist lst)
  (find (lambda (element) (null? element)) lst))

(define (members-contain-non-string list-of-lists)
  (find (lambda (sublist)
          (find (lambda (alternative) (not (string? alternative)))
                sublist))
        list-of-lists))

(define (members-contain-empty-string list-of-lists)
  (find (lambda (sublist)
          (find (lambda (alternative) (string-null? alternative))
                sublist))
        list-of-lists))

(define (members-contain-entirely-spaces-string list-of-lists)
  (find (lambda (sublist)
          (find (lambda (alternative)
                  (string-every (lambda (char)
                                  (char=? #\space char)) alternative))
                sublist))
        list-of-lists))

(define (members-contain-entirely-tabs-string list-of-lists)
  (find (lambda (sublist)
          (find (lambda (alternative)
                  (string-every (lambda (char)
                                  (char=? #\tab char)) alternative))
                sublist))
        list-of-lists))

(define (contains-duplicates-across-sublists? list-of-lists)
  "Uses eqv? to make the comparisons."
  (define (check-for-duplicates lst seen)
    (cond ((null? lst) #f)
          ((not (null? (lset-intersection eqv? (car lst) seen))) #t)
          (else (check-for-duplicates (cdr lst)
                                      (lset-union eqv? seen (car lst))))))
  (check-for-duplicates list-of-lists '()))

(define (validate-question-number question)
  (let ((question-number (qnr-question-number question)))
    (cond ((not (integer? question-number)) QNR-ERROR-QUESTION-NUMBER-NON-INTEGER)
          ((= question-number 0) QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE)
          ((< question-number 0) QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE)
          (else QNR-VALID-QUESTION-NO-ERROR))))
