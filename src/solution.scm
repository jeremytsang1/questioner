;;; (src solution)
;; Description: Defines a `<solution>` for a `<question>`. A `<solution>`
;; represents a set of `<choice>`s and the the expected number of responses the
;; testee can be expected to respond with for their answer to be considered
;; correct.

(define-module (src solution)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:use-module (src choice)
  #:export (QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
            QNR-ERROR-MSG-SOLUTION-CHOICES-WRONG-TYPE
            QNR-ERROR-MSG-SOLUTION-CHOICES-EMPTY
            qnr-make-solution
            qnr-solution?
            qnr-choices
            qnr-expected-response-count))

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define QNR-ERROR-KEY-SOLUTION-CONSTRUCTION 'qnr-error-solution-construction)

(define QNR-ERROR-MSG-SOLUTION-CHOICES-WRONG-TYPE
  "<solution> field `choices` has wrong type")
(define QNR-ERROR-MSG-SOLUTION-CHOICES-EMPTY
  "<solution> field choices is empty")


;; Constructors ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-record-type <qnr-solution>
  (raw-make-solution choices expected-response-count)
  qnr-solution?
  (choices qnr-choices)
  (expected-response-count qnr-expected-response-count))

(define (qnr-make-solution list-of-list-of-strings expected-response-count)
  "Create a new <solution> record with choices select from formed by LIST-OF-LIST-OF-STRINGS
 and EXPECTED-RESPONSE-COUNT being the number of choices that must answered for
the response to be considered correct.

LIST-OF-LIST-OF-STRINGS should be a list where each element is a list of
strings that creates a valid choice as per module (src choice).

EXPECTED-RESPONSE-COUNT should be a positive integer that is less than or equal
to (length CHOICES). Represents the number of answers the user must provide
when answering a question. For example for a question like \"Name two primary
colors?\" where the choices c '((\"red\") (\"yellow\") (\"blue\")) the
EXPECTED-RESPONSE-COUNT would be 2 and the user could answer any 2 combination
of the 3 possible choices (e.g. red and blue, red and yellow, or blue and
yellow)."
  (unless (list? list-of-list-of-strings)
    (throw QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
           QNR-ERROR-MSG-SOLUTION-CHOICES-WRONG-TYPE))

  (when (null? list-of-list-of-strings)
    (throw QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
           QNR-ERROR-MSG-SOLUTION-CHOICES-EMPTY))

  (let ((choices (map qnr-make-choice list-of-list-of-strings)))
    (when (has-duplicate-alternatives-across-choices? list-of-list-of-strings)
      (throw QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
             "<solution> field `choices` has duplicate alternatives across choices"))
  (raw-make-solution choices expected-response-count)))

;; This function is necessary because if there are duplicates, the use can use
;; a single alternative to answer a multi-response question.
(define (has-duplicate-alternatives-across-choices? choices)
  "Return #t if there is an alternative which is a member of two or more members
of CHOICES.

CHOICES is a list of `choice` as defined by (src choice)."
  (define (has-duplicates? choices-left seen)
    (cond ((null? choices-left) #f)
          ((not (null? (lset-intersection eqv? (car choices-left) seen))) #t)
          (else (has-duplicates? (cdr choices-left)
                                 (lset-union eqv? seen (car choices-left))))))

  (has-duplicates? choices '()))
