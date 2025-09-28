(define-module (src quiz-loader)
  #:use-module (json)
  #:export (QNR-ERROR-FILE-NOT-FOUND
            QNR-ERROR-JSON-PARSING
            qnr-load-quiz-file
            qnr-question-dto-query
            qnr-question-dto-choices
            qnr-question-dto-expected-response-count
            qnr-question-dto-list-questions))

;; Built-in Errors
(define BUILT-IN-ERROR-SYSTEM-ERROR 'system-error)
;; Dependency Errors
(define MODULE-ERROR-INVALID-JSON 'json-invalid) ;; Exception from guile-json.

(define QNR-ERROR-FILE-NOT-FOUND 'qnr-error-file-not-found)
(define QNR-ERROR-JSON-PARSING 'qnr-error-invalid-json)
(define TOP-LEVEL-KEY-NAME "questions")


(define (qnr-load-quiz-file path)
  "Read the file given by PATH and return a list of `qnr-question-dto` inside a
field inside an `qnr-quetsion-dto-list` record."
  ;; Nested Helpers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (define (create-records-from-parsed-json)
    (scm->qnr-question-dto-list (get-parsed-json-from-file path)))
  (define (handle-failure-to-parse-json key . args)
    (throw QNR-ERROR-JSON-PARSING))
  ;;  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (catch MODULE-ERROR-INVALID-JSON
    create-records-from-parsed-json
    handle-failure-to-parse-json))

(define (get-parsed-json-from-file path)
  ;; Nested Helpers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (define (read-quiz-json-file)
    (call-with-input-file path (lambda (port) (parse-quiz-json-file port))))
  (define (handle-failure-to-open-file key . args)
    (throw QNR-ERROR-FILE-NOT-FOUND))
  ;;  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (catch BUILT-IN-ERROR-SYSTEM-ERROR
    read-quiz-json-file
    handle-failure-to-open-file))

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
