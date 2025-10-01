(define-module (src quiz quiz)
  #:export (qnr-number-elements))

(define* (qnr-number-elements lst #:optional (current-number 1))
  "Return an alist with each key being an element of DTO-QUESTIONS and the value
its number in the overall list with numbers starting at CURRENT-NUMBER.

When CURRENT-NUMBER is ommitted, counting starts at 1."
  (cond ((null? lst) '())
        (else (cons (cons (car lst) current-number)
                    (qnr-number-elements (cdr lst) (1+ current-number))))))
