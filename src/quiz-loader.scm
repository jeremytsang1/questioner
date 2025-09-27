(define-module (src quiz-loader)
  #:use-module (json)
  #:export (QNR-ERROR-FILE-NOT-FOUND
            QNR-ERROR-INVALID-JSON
            qnr-load-quiz-file
            qnr-question-dto-query
            qnr-question-dto-list-questions))

(define QNR-ERROR-FILE-NOT-FOUND 'qnr-error-file-not-found)
(define QNR-ERROR-INVALID-JSON 'qnr-error-invalid-json)
(define TOP-LEVEL-KEY-NAME "questions")


(define (qnr-load-quiz-file path)
  "Read the file given by PATH and return a list of `qnr-question-dto` inside a
field inside an `qnr-quetsion-dto-list` record."
  (catch 'json-invalid
    (lambda ()
      (let* ((parsed-json (get-parsed-json-from-file path)))
        (scm->qnr-question-dto-list parsed-json)))
    (lambda (key . args) (throw 'qnr-error-invalid-json))))

(define (get-parsed-json-from-file path)
  (catch 'system-error
    (lambda ()
      (call-with-input-file path (lambda (port) (parse-quiz-json-file port))))
    (lambda (key . args) (throw QNR-ERROR-FILE-NOT-FOUND))))

(define (parse-quiz-json-file port)
  (json->scm port #:ordered #t))

;; JSON Records ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-json-type <qnr-question-dto>
  (query)
  (choices)
  (expected-response-count))

(define-json-type <qnr-question-dto-list>
  (questions TOP-LEVEL-KEY-NAME #(<qnr-question-dto>)))

;;  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
