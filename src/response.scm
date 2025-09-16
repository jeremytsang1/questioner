(define-module (src response)
  #:export (qnr-format-response))

(define (qnr-format-response response)
  (if (char-set-every
       (lambda (char) (char-set-contains? char-set:whitespace char))
       (->char-set response))
      ""
      response))

