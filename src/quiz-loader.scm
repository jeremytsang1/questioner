(define-module (src quiz-loader)
  #:use-module (json)
  #:export (QNR-ERROR-FILE-NOT-FOUND
            QNR-ERROR-INVALID-JSON
            qnr-load-quiz))

(define QNR-ERROR-FILE-NOT-FOUND 'qnr-error-file-not-found)
(define QNR-ERROR-INVALID-JSON 'qnr-error-invalid-json)

(define (qnr-load-quiz filename)
  (catch 'json-invalid
    (lambda ()
      (let* ((questions-port
              (catch 'system-error
                (lambda () (open-input-file filename))
                (lambda (key . args) (throw QNR-ERROR-FILE-NOT-FOUND))))
             (questions-json (json->scm questions-port #:ordered #t)))
        (close-port questions-port)
        questions-json))
    (lambda (key . args) (throw 'qnr-error-invalid-json))))
