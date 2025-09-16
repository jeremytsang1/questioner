(define-module (src response)
  #:export (qnr-format-response
            EMPTY-STRING
            SINGLE-SPACE))

(define EMPTY-STRING "")
(define SINGLE-SPACE " ")

(define (qnr-format-response response)
  (string-join
   ;; Filter on empty strings because splitting on whitespace generates empty
   ;; strings in the resulting list of delimited substrings.
   (filter string-non-null? (string-split response char-whitespace?))
   SINGLE-SPACE))

(define (char-whitespace? char)
  (char-set-contains? char-set:whitespace char))

(define (string-non-null? str)
  (not (string-null? str)))
