(define-module (src solution)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:use-module (src answer)
  #:export (QNR-ERROR-CHOICES-WRONG-TYPE
            QNR-ERROR-CHOICES-NO-CHOICES-FOUND
            QNR-ERROR-SINGLE-CHOICE-WRONG-TYPE
            QNR-ERROR-CHOICES-EMPTY
            QNR-ERROR-CHOICES-ALTERNATIVE-WRONG-TYPE
            QNR-ERROR-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
            QNR-ERROR-DUPLICATE-ALTERNATIVES-ACROSS-CHOICES
            qnr-validate-choices))

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define QNR-VALID-CHOICE-NO-ERROR "") ;; TODO: Remove duplicate definition.
(define QNR-ERROR-CHOICES-WRONG-TYPE
  "`choices` has wrong type")
(define QNR-ERROR-CHOICES-NO-CHOICES-FOUND
  "`choices` empty")
(define QNR-ERROR-SINGLE-CHOICE-WRONG-TYPE
  "A top-level member of `choices` was given wrong type")
(define QNR-ERROR-CHOICES-EMPTY
  "`choices` contains an empty list choice")
(define QNR-ERROR-CHOICES-ALTERNATIVE-WRONG-TYPE
  "`choices` contains a choice with an alternative that has wrong type")
(define QNR-ERROR-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
  "`choices` contains a choice with a completely whitespace alternative")
(define QNR-ERROR-DUPLICATE-ALTERNATIVES-ACROSS-CHOICES
  "`choices` contains duplicate alternatives across choices")

;; Validation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (qnr-validate-choices choices)
  "Return a string containing why CHOICES has invalid choices, otherwise
return QNR-VALID-CHOICE-NO-ERROR

CHOICES is valid if the following are true:
- It is a non-empty list of non-empty lists of strings (these strings are
  called `alternatives`). Each of the non-empty lists represents a single
  choice.
- None of the strings (alternatives) in the sublists are made
  entirely of whitespacel.
- There are no duplicate alternatives across choices
  (one string in one sublist does not show up in another sublist)."
  ;; Order matters in the following `cond`.
  (cond ((not (list? choices)) QNR-ERROR-CHOICES-WRONG-TYPE)
        ((null? choices) QNR-ERROR-CHOICES-NO-CHOICES-FOUND)
        ((contains-non-list choices)
         QNR-ERROR-SINGLE-CHOICE-WRONG-TYPE)
        ((contains-empty-sublist choices)
         QNR-ERROR-CHOICES-EMPTY)
        ((sublist-members-contain-non-string choices)
         QNR-ERROR-CHOICES-ALTERNATIVE-WRONG-TYPE)
        ((sublist-members-composed-entirely-of-whitespace choices)
         QNR-ERROR-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE)
        ((contains-duplicates-across-sublists? choices)
         QNR-ERROR-DUPLICATE-ALTERNATIVES-ACROSS-CHOICES)
        (else QNR-VALID-CHOICE-NO-ERROR)))

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
