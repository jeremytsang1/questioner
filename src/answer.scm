(define-module (src answer)
  #:export (qnr-remove-excess-whitespace
            EMPTY-STRING
            SINGLE-SPACE))

(define EMPTY-STRING "")
(define SINGLE-SPACE " ")

(define (qnr-remove-excess-whitespace answer)
  "Remove any excess internal/external whitespace from ANSWER."
  (string-join
   ;; Filter on empty strings because splitting on whitespace generates empty
   ;; strings in the resulting list of delimited substrings.
   (filter string-non-null? (string-split answer char-whitespace?))
   SINGLE-SPACE))

(define (char-whitespace? char)
  (char-set-contains? char-set:whitespace char))

(define (string-non-null? str)
  (not (string-null? str)))
