(define-module (src solution)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:use-module (src answer)
  #:export (QNR-ERROR-SOLUTIONS-WRONG-TYPE
            QNR-ERROR-SOLUTIONS-NO-CHOICES-FOUND
            QNR-ERROR-SOLUTIONS-CHOICES-WRONG-TYPE
            QNR-ERROR-SOLUTIONS-CHOICES-EMPTY
            QNR-ERROR-SOLUTIONS-ALTERNATIVE-WRONG-TYPE
            QNR-ERROR-SOLUTIONS-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
            QNR-ERROR-SOLUTIONS-DUPLICATE-ALTERNATIVES-ACROSS-CHOICES
            qnr-validate-solution))

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define QNR-VALID-QUESTION-NO-ERROR "") ;; TODO: Remove duplicate definition.
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

;; Validation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (qnr-validate-solution solutions)
  "Return a string containing why QUESTION has invalid solutions, otherwise
return QNR-VALID-QUESTION-NO-ERROR.

The solutions field of a <question> is a valid if the following are true:
- it is a non-empty list of non-empty lists of strings
- none of the strings (alternatives) in  the sublists (choices) are made
  entirely of whitespace
- there are no duplicate alternatives across choices
  (one string in one sublist does not show up in another sublist)"
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
        (else QNR-VALID-QUESTION-NO-ERROR)))

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
