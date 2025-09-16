(define-module (src answer)
  #:export (qnr-format-answer
            EMPTY-STRING
            SINGLE-SPACE))

(define EMPTY-STRING "")
(define SINGLE-SPACE " ")

(define (qnr-format-answer answer)
  "Format ANSWER to be in a more comparable form.

Remove excess internal/external whitespace from ANSWER and convert it entirely
to lowercase."
  (string-downcase (remove-excess-whitespace answer)))

(define (remove-excess-whitespace answer)
  (string-join
   ;; Filter on empty strings because splitting on whitespace generates empty
   ;; strings in the resulting list of delimited substrings.
   (filter string-non-null? (string-split answer char-whitespace?))
   SINGLE-SPACE))

(define (char-whitespace? char)
  (char-set-contains? char-set:whitespace char))

(define (string-non-null? str)
  (not (string-null? str)))
