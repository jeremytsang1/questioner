(define-module (src response)
  #:export (qnr-format-response
            EMPTY-STRING
            SINGLE-SPACE))

(define EMPTY-STRING "")
(define SINGLE-SPACE " ")

(define (qnr-format-response response)
  (let* ((tokens
          (filter
           ;; Filter on empty strings because splitting on whitespace generates
           ;; empty strings in the resulting list of delimited substrings.
           (lambda (str) (not (string-null? str)))
           (string-split response char-whitespace?)))
         (formatted (string-join tokens SINGLE-SPACE)))
    (if (string-whitespace? formatted) EMPTY-STRING (string-trim-both formatted))))

(define (string-whitespace? response)
  (char-set-every
   char-whitespace?
   (->char-set response)))

(define (char-whitespace? char)
  (char-set-contains? char-set:whitespace char))
