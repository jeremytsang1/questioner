;;; (src choice)
;; Description: Defines a `choice` in a `<solution>`. A choice represents a set
;; of equivalent answers any of which would satisfy a single response to a
;; question.
(define-module (src choice)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:use-module (src answer)
  #:export (QNR-VALID-CHOICE-NO-ERROR
            QNR-ERROR-CHOICE-WRONG-TYPE
            QNR-ERROR-CHOICE-EMPTY
            QNR-ERROR-CHOICE-ALTERNATIVE-WRONG-TYPE
            QNR-ERROR-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
            QNR-ERROR-DUPLICATE-ALTERNATIVES-ACROSS-CHOICES
            qnr-validate-choice
            qnr-format-choice
            qnr-make-choice
            qnr-choice-includes-answer?))

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define QNR-VALID-CHOICE-NO-ERROR "")

(define QNR-ERROR-CHOICE-WRONG-TYPE
  "`choice` has wrong type")
(define QNR-ERROR-CHOICE-EMPTY
  "`choice` is empty")
(define QNR-ERROR-CHOICE-ALTERNATIVE-WRONG-TYPE
  "`choice` an alternative that has wrong type")
(define QNR-ERROR-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE
  "`choice` contains alternative made completely of whitespace")

;; Validation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (qnr-validate-choice choice)
  "Return a string containing why CHOICE is invalid, otherwise return
QNR-VALID-CHOICE-NO-ERROR.

CHOICE is valid if the following are true:

- It is a non-empty lists of strings (these strings are called `alternatives`).

- None of the strings (alternatives) are made entirely of whitespace."
  ;; Order matters in the following `cond`.
  (cond ((not (list? choice)) QNR-ERROR-CHOICE-WRONG-TYPE)
        ((null? choice) QNR-ERROR-CHOICE-EMPTY)
        ((find-non-string choice)
         QNR-ERROR-CHOICE-ALTERNATIVE-WRONG-TYPE)
        ((find-whitespace-string choice)
         QNR-ERROR-ALTERNATIVE-MADE-ENTIRELY-OF-WHITESPACE)
        (else QNR-VALID-CHOICE-NO-ERROR)))

(define (find-non-string choice)
  (find (lambda (alternative) (not (string? alternative))) choice))

(define (find-whitespace-string choice)
  (find (lambda (alternative)
          (string-null? (qnr-remove-excess-whitespace alternative)))
        choice))

(define (qnr-format-choice choice)
  "Remove extra whitespace from all the alternatives in CHOICE and remove all
 duplicates.

Preserves order and removes duplicates after removing whitespace.

CHOICE must be a valid choice per qnr-validate-choice."
  (delete-duplicates (map qnr-remove-excess-whitespace choice)))

;; Creation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (qnr-make-choice list-of-strings)
  (unless (string-null? (qnr-validate-choice list-of-strings))
    (throw 'qnr-choice-construction-failure))
  list-of-strings)

;;  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (qnr-choice-includes-answer? choice answer)
  (if (member answer choice) #t #f))
