(define-module (src question)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:use-module (src answer)
  #:export (QNR-VALID-QUESTION-NO-ERROR
            QNR-ERROR-NON-QUESTION
            QNR-ERROR-QUERY-NON-STRING
            QNR-ERROR-QUERY-EMPTY
            QNR-ERROR-SOLUTIONS-WRONG-TYPE
            QNR-ERROR-SOLUTIONS-NO-CHOICES-FOUND
            QNR-ERROR-SOLUTIONS-CHOICES-WRONG-TYPE
            QNR-ERROR-SOLUTIONS-CHOICES-EMPTY
            QNR-ERROR-SOLUTIONS-ALTERNATIVE-WRONG-TYPE
            QNR-ERROR-SOLUTIONS-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
            QNR-ERROR-SOLUTIONS-DUPLICATE-ALTERNATIVES-ACROSS-CHOICES
            QNR-ERROR-QUESTION-NUMBER-WRONG-TYPE
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
(define QNR-ERROR-QUERY-EMPTY
  "<question> has `query` that is empty")
(define QNR-ERROR-SOLUTIONS-WRONG-TYPE
  "<question> `solutions` was given wrong type")
(define QNR-ERROR-SOLUTIONS-NO-CHOICES-FOUND
  "<question> `solutions` has no choices")
(define QNR-ERROR-SOLUTIONS-CHOICES-WRONG-TYPE
  "<question> `solutions` choices was given wrong type")
(define QNR-ERROR-SOLUTIONS-CHOICES-EMPTY
  "<question> `solutions` has a choice list that is empty")
(define QNR-ERROR-SOLUTIONS-ALTERNATIVE-WRONG-TYPE
  "<question> `solutions` alternative given wrong type")
(define QNR-ERROR-SOLUTIONS-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
  "<question> `solutions` contains an alternative made entirely of whitespace")
(define QNR-ERROR-SOLUTIONS-DUPLICATE-ALTERNATIVES-ACROSS-CHOICES
  "<question> `solutions` contains duplicate alternatives across choices")
(define QNR-ERROR-QUESTION-NUMBER-WRONG-TYPE
  "<question> `question-number` has wrong type")
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
          ((string-null? question) QNR-ERROR-QUERY-EMPTY)
          (else QNR-VALID-QUESTION-NO-ERROR))))

(define (validate-solutions question)
  "Return a string containing why QUESTION has invalid solutions, otherwise
return QNR-VALID-QUESTION-NO-ERROR.

The solutions field of a <question> is a valid if the following are true:
- it is a non-empty list of non-empty lists of strings
- none of the strings (alternatives) in  the sublists (choices) are made
  entirely of whitespace
- there are no duplicate alternatives across choices
  (one string in one sublist does not show up in another sublist)"
  (let ((solutions (qnr-solutions question)))
    ;; Order matters in the following `cond`.
    (cond ((not (list? solutions)) QNR-ERROR-SOLUTIONS-WRONG-TYPE)
          ((null? solutions) QNR-ERROR-SOLUTIONS-NO-CHOICES-FOUND)
          ((contains-non-list solutions)
           QNR-ERROR-SOLUTIONS-CHOICES-WRONG-TYPE)
          ((contains-empty-sublist solutions)
           QNR-ERROR-SOLUTIONS-CHOICES-EMPTY)
          ((sublist-members-contain-non-string solutions)
           QNR-ERROR-SOLUTIONS-ALTERNATIVE-WRONG-TYPE)
          ((sublist-members-composed-entirely-of-whitespace solutions)
           QNR-ERROR-SOLUTIONS-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE)
          ((contains-duplicates-across-sublists? solutions)
           QNR-ERROR-SOLUTIONS-DUPLICATE-ALTERNATIVES-ACROSS-CHOICES)
          (else QNR-VALID-QUESTION-NO-ERROR))))

(define (contains-non-list lst)
  (find (lambda (element) (not (list? element))) lst))

(define (contains-empty-sublist lst)
  (find (lambda (element) (null? element)) lst))

(define (sublist-members-contain-non-string list-of-lists)
  (find (lambda (sublist)
          (find (lambda (alternative) (not (string? alternative)))
                sublist))
        list-of-lists))

(define (sublist-members-composed-entirely-of-whitespace list-of-lists-of-strings)
  (find (lambda (sublist)
          (find (lambda (alternative)
                  (string-null? (qnr-format-answer alternative)))
                sublist))
        list-of-lists-of-strings))

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
    (cond ((not (integer? question-number)) QNR-ERROR-QUESTION-NUMBER-WRONG-TYPE)
          ((= question-number 0) QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE)
          ((< question-number 0) QNR-ERROR-QUESTION-NUMBER-NON-POSITIVE)
          (else QNR-VALID-QUESTION-NO-ERROR))))
