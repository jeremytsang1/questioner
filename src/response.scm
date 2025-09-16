(define-module (src response)
  #:export (qnr-format-response
            EMPTY-STRING
            SINGLE-SPACE))

(define EMPTY-STRING "")
(define SINGLE-SPACE " ")

(define (qnr-format-response response)
  (let* ((tokens
          (filter (lambda (str) (not (white-space? str)))
                  (string-split
                   response
                   (lambda (char)
                     (char-set-contains? char-set:whitespace char)))))
         (formatted (string-join tokens SINGLE-SPACE)))
    (if (white-space? formatted) EMPTY-STRING (string-trim-both formatted))))

(define (white-space? response)
  (char-set-every
   (lambda (char) (char-set-contains? char-set:whitespace char))
   (->char-set response)))
