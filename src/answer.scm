(define-module (src answer)
  #:export (qnr-remove-excess-whitespace
            QNR-EMPTY-STRING
            QNR-SINGLE-SPACE))

(define QNR-EMPTY-STRING "")
(define QNR-SINGLE-SPACE " ")

(define (qnr-remove-excess-whitespace answer)
  "Format ANSWER to be in a more comparable form.

Remove excess internal/external whitespace from ANSWER and convert it entirely
to lowercase.

Note if ANSWER is entirely composed of whitespace it is collapsed down to an
empty string."
  (string-downcase (remove-excess-whitespace answer)))

(define (remove-excess-whitespace answer)
  (string-join
   ;; Filter on empty strings because splitting on whitespace generates empty
   ;; strings in the resulting list of delimited substrings.
   (filter string-non-null? (string-split answer char-whitespace?))
   QNR-SINGLE-SPACE))

(define (char-whitespace? char)
  (char-set-contains? char-set:whitespace char))

(define (string-non-null? str)
  (not (string-null? str)))
