(define-module (src quiz-loader)
  #:use-module (json)
  #:export (QNR-ERROR-FILE-NOT-FOUND
            QNR-ERROR-INVALID-JSON
            qnr-load-quiz
            qnr-question-dto-query
            qnr-question-dto-list-questions))

(define QNR-ERROR-FILE-NOT-FOUND 'qnr-error-file-not-found)
(define QNR-ERROR-INVALID-JSON 'qnr-error-invalid-json)
(define TOP-LEVEL-KEY-NAME "questions")


(define (qnr-load-quiz filename)
  (catch 'json-invalid
    (lambda ()
      (let* ((questions-port
              (catch 'system-error
                (lambda () (open-input-file filename))
                (lambda (key . args) (throw QNR-ERROR-FILE-NOT-FOUND))))
             (parsed-json (json->scm questions-port #:ordered #t)))
        (close-port questions-port)
        (scm->qnr-question-dto-list parsed-json)))
    (lambda (key . args) (throw 'qnr-error-invalid-json))))

;; JSON Records ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-json-type <qnr-question-dto>
  (query)
  (choices)
  (expected-response-count))

(define-json-type <qnr-question-dto-list>
  (questions TOP-LEVEL-KEY-NAME #(<qnr-question-dto>)))

;;  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
