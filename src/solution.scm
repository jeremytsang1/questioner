;;; (src solution)
;; Description: Defines a `<solution>` for a `<question>`. A `<solution>`
;; represents a set of `<choice>`s and the the expected number of responses the
;; testee can be expected to respond with for their answer to be considered
;; correct.

(define-module (src solution)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:use-module (src choice)
  #:export
  (QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
   QNR-VALID-SOLUTION-NO-ERROR
   QNR-ERROR-MSG-SOLUTION-CHOICES-WRONG-TYPE
   QNR-ERROR-MSG-SOLUTION-CHOICES-EMPTY
   QNR-ERROR-MSG-SOLUTION-DUPLICATE-CHOICES
   QNR-ERROR-MSG-SOLUTION-EXPECTED-RESPONSE-COUNT-WRONG-TYPE
   QNR-ERROR-MSG-SOLUTION-NON-POSITIVE-EXPECTED-RESPONSE-COUNT
   QNR-ERROR-MSG-SOLUTION-EXPECTED-RESPONSE-COUNT-EXCEEDS-CHOICES-LENGTH
   qnr-make-solution
   qnr-solution?
   qnr-choices
   qnr-expected-response-count
   qnr-get-primary-correct-answers
   qnr-find-wrong-answers))

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define QNR-ERROR-KEY-SOLUTION-CONSTRUCTION 'qnr-error-solution-construction)

(define QNR-VALID-SOLUTION-NO-ERROR "")

(define QNR-ERROR-MSG-SOLUTION-CHOICES-WRONG-TYPE
  "<solution> field `choices` has wrong type")
(define QNR-ERROR-MSG-SOLUTION-CHOICES-EMPTY
  "<solution> field `choices` is empty")
(define QNR-ERROR-MSG-SOLUTION-DUPLICATE-CHOICES
  "<solution> field `choices` has duplicate alternatives across choices")


(define QNR-ERROR-MSG-SOLUTION-EXPECTED-RESPONSE-COUNT-WRONG-TYPE
  "<solution> field `expected-response-count` is wrong type")
(define QNR-ERROR-MSG-SOLUTION-NON-POSITIVE-EXPECTED-RESPONSE-COUNT
  "<solution> field `expected-response-count` is non-positive")
(define QNR-ERROR-MSG-SOLUTION-EXPECTED-RESPONSE-COUNT-EXCEEDS-CHOICES-LENGTH
  "<solution> `expected-response-count` is larger than length of `choices`")

;; Constructors ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-record-type <qnr-solution>
  (raw-make-solution choices expected-response-count)
  qnr-solution?
  (choices qnr-choices)
  (expected-response-count qnr-expected-response-count))

(define (qnr-make-solution list-of-list-of-strings expected-response-count)
  "Create a new <solution> record with choices formed by
LIST-OF-LIST-OF-STRINGS and EXPECTED-RESPONSE-COUNT being the number of choices
that must answered for the response to be considered correct.

LIST-OF-LIST-OF-STRINGS should be a list where each element is itself a list of
strings that conforms to `choice` specification as per module (src choice).

EXPECTED-RESPONSE-COUNT should be a positive integer that is less than or equal
to `(length CHOICES)`. This represents the number of answers the user must
provide when answering a question. For example for a question like \"Name two
primary colors?\" where the choices c '((\"red\") (\"yellow\") (\"blue\")) the
EXPECTED-RESPONSE-COUNT would be 2 and the user could answer any 2 combination
of the 3 possible choices (e.g. red and blue, red and yellow, or blue and
yellow)."
  (let ((choices (construct-choices list-of-list-of-strings)))
    (validate-expected-response-count expected-response-count choices)
    (raw-make-solution choices expected-response-count)))

(define (construct-choices list-of-list-of-strings)
  (validate-before-choice-creation list-of-list-of-strings)
  (let ((choices (map qnr-make-choice list-of-list-of-strings)))
    (when (has-duplicate-alternatives-across-choices? list-of-list-of-strings)
      (throw QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
             QNR-ERROR-MSG-SOLUTION-DUPLICATE-CHOICES))
    choices))

(define (validate-before-choice-creation choices-candidate)
  (unless (list? choices-candidate)
    (throw QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
           QNR-ERROR-MSG-SOLUTION-CHOICES-WRONG-TYPE))
  (when (null? choices-candidate)
    (throw QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
           QNR-ERROR-MSG-SOLUTION-CHOICES-EMPTY)))

(define (validate-expected-response-count ecr choices)
  (let ((error-message
         (cond
          ((expected-response-count-wrong-type? ecr)
           QNR-ERROR-MSG-SOLUTION-EXPECTED-RESPONSE-COUNT-WRONG-TYPE)
          ((expected-response-count-out-of-domain? ecr)
           QNR-ERROR-MSG-SOLUTION-NON-POSITIVE-EXPECTED-RESPONSE-COUNT)
          ((expected-response-impossible-for-given-choices? ecr choices)
           QNR-ERROR-MSG-SOLUTION-EXPECTED-RESPONSE-COUNT-EXCEEDS-CHOICES-LENGTH)
          (else QNR-VALID-SOLUTION-NO-ERROR))))

    (unless (string=? error-message QNR-VALID-SOLUTION-NO-ERROR)
      (throw QNR-ERROR-KEY-SOLUTION-CONSTRUCTION error-message))))

(define (expected-response-count-wrong-type? ecr) (not (integer? ecr)))

(define (expected-response-count-out-of-domain? ecr) (<= ecr 0))

(define (expected-response-impossible-for-given-choices? ecr choices)
  (> ecr (length choices)))

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

;; Quiz Logic ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (qnr-get-primary-correct-answers solution)
  "Collect answers to show testee after they miss a question with SOLUTION.

The answers collected will be the first alternative of each choice in
<soluntion> field `choices`. Retrurns a list of strings with of the same length
as `choices`.

SOLUTION must be a well form <solution>."
  ;; ASSUME: SOLUTION is a valid <solution>
  (map car (qnr-choices solution)))

(define (qnr-find-wrong-answers solution response)
  '())
