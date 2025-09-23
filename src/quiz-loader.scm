(define-module (src quiz-loader)
  #:export (QNR-ERROR-FILE-NOT-FOUND
            qnr-load-quiz))

(define QNR-ERROR-FILE-NOT-FOUND 'qnr-error-file-not-found)


(define (qnr-load-quiz filename)
  (throw 'qnr-error-file-not-found))
