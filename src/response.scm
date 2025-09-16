(define-module (src response)
  #:export (qnr-format-response
            EMPTY-STRING))

(define EMPTY-STRING "")

(define (qnr-format-response response)
  (if (white-space? response) EMPTY-STRING response))

(define (white-space? response)
  (char-set-every
   (lambda (char) (char-set-contains? char-set:whitespace char))
   (->char-set response)))

