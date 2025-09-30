;;; (src solution)
;; Description: Defines a `<solution>` for a `<qnr-question>`. A `<solution>`
;; represents a set of `<choice>`s and the the expected number of responses the
;; testee can be expected to respond with for their answer to be considered
;; correct.

(define-module (src solution)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-9)
  #:use-module (src choice)
  #:use-module (src answer)
  #:export
  (QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
   QNR-ERROR-KEY-SOLUTION
   QNR-VALID-SOLUTION-NO-ERROR
   QNR-ERROR-MSG-SOLUTION-CHOICES-WRONG-TYPE
   QNR-ERROR-MSG-SOLUTION-CHOICES-EMPTY
   QNR-ERROR-MSG-SOLUTION-DUPLICATE-CHOICES
   QNR-ERROR-MSG-SOLUTION-EXPECTED-RESPONSE-COUNT-WRONG-TYPE
   QNR-ERROR-MSG-SOLUTION-NON-POSITIVE-EXPECTED-RESPONSE-COUNT
   QNR-ERROR-MSG-SOLUTION-EXPECTED-RESPONSE-COUNT-EXCEEDS-CHOICES-LENGTH
   QNR-ERROR-MSG-SOLUTION-FIND-WRONG-ANSWERS-FROM-EMPTY-RESPONSE
   QNR-ERROR-MSG-SOLUTION-RESPONSES-LENGTH-MISMATCH
   QNR-ERROR-MSG-SOLUTION-RESPONSE-MADE-OF-WHITESPACE
   qnr-make-solution
   qnr-solution?
   qnr-solution-choices
   qnr-expected-response-count
   qnr-get-primary-correct-answers
   qnr-find-wrong-answers))

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define QNR-ERROR-KEY-SOLUTION-CONSTRUCTION 'qnr-error-solution-construction)
(define QNR-ERROR-KEY-SOLUTION 'qnr-error-solution)

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

(define QNR-ERROR-MSG-SOLUTION-FIND-WRONG-ANSWERS-FROM-EMPTY-RESPONSE
  "<solution> no responses passed")
(define QNR-ERROR-MSG-SOLUTION-RESPONSES-LENGTH-MISMATCH
  "responses length not equal to solution's field `expected-response-count`")
(define QNR-ERROR-MSG-SOLUTION-RESPONSE-MADE-OF-WHITESPACE
  "response contains a string made entirely of whitespace")

;; Constructors ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-record-type <qnr-solution>
  (raw-make-solution choices expected-response-count)
  qnr-solution?
  (choices qnr-solution-choices)
  (expected-response-count qnr-expected-response-count))

(define (qnr-make-solution list-of-list-of-strings expected-response-count)
  "Create a new <solution> record with choices formed by
LIST-OF-LIST-OF-STRINGS and EXPECTED-RESPONSE-COUNT being the number of choices
that must answered for the responses to be considered correct.

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
  (map car (qnr-solution-choices solution)))

(define (qnr-find-wrong-answers solution list-of-strings)
  "Return a list of wrong answers in LIST-OF-STRINGS.

SOLUTION should be a valid solution.

LIST-OF-STRINGS is a non-empty list of strings that are not completely composed
of whitespace. It should have length equal to SOLUTION's field
`expected-response-count` (and hence be non-empty since that field should never
be non-positive)."
  (let ((responses (make-responses list-of-strings
                                   (qnr-expected-response-count solution))))
    (collect-wrong-answers (qnr-solution-choices solution) responses)))

(define (collect-wrong-answers choices responses)
  "Return a subset of RESPONSES that only contains the responses that were not
only (1) not in any choice but also (2) not in any choice that contains another
member."
  (if (null? responses)
      '()
      (let ((choice-containing-response
             (find (lambda (choice) (member (car responses) choice))
                   choices)))
        ;; If a response is in a choice, then remove that choice from further
        ;; consideration and also don't add that response to the result (since
        ;; it is not a wrong answer).
        (cond (choice-containing-response
               (collect-wrong-answers (delete choice-containing-response choices)
                                      (cdr responses)))
              ;; If a response is not any is not in any choice then it
              ;; is an incorrect responses, so add it to the list.
              (else (cons (car responses)
                          (collect-wrong-answers choices (cdr responses))))))))

(define (make-responses list-of-strings expected-response-count)
  (let ((responses (map qnr-remove-excess-whitespace list-of-strings)))
    (when (null? responses)
      (throw QNR-ERROR-KEY-SOLUTION
             QNR-ERROR-MSG-SOLUTION-FIND-WRONG-ANSWERS-FROM-EMPTY-RESPONSE))
    (when (not (= (length responses) expected-response-count))
      (throw QNR-ERROR-KEY-SOLUTION
             QNR-ERROR-MSG-SOLUTION-RESPONSES-LENGTH-MISMATCH))
    (when (any string-null? responses)
      (throw QNR-ERROR-KEY-SOLUTION
             QNR-ERROR-MSG-SOLUTION-RESPONSE-MADE-OF-WHITESPACE))
    responses))
