(define-module (src ui cli cli)
  #:use-module (src quiz quiz)
  #:use-module (src quiz quiz-loader)
  #:export (qnr-run-cli))

(define EXPECTED-ARGUMENT-FOR-JSON-FILE 1)

(define (qnr-run-cli)
  (let* ((path (read-json-file))
         (quiz (qnr-make-quiz (qnr-load-quiz-file path))))
    (display (qnr-quiz-get-next-question quiz))))

(define (read-json-file)
  (when (<= (length (program-arguments)) EXPECTED-ARGUMENT-FOR-JSON-FILE)
    (throw 'qnr-no-json-path-passed))
  (cadr (command-line)))
