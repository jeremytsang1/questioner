(define-module (src ui cli cli)
  #:use-module (ice-9 rdelim)
  #:use-module (src quiz quiz)
  #:use-module (src quiz quiz-loader)
  #:use-module (src quiz question)
  #:export (qnr-run-cli))

(define EXPECTED-ARGUMENT-FOR-JSON-FILE 1)
(define HR-LENGTH 80)
(define HR-CHAR #\-)
(define MSG-QUESTIONS-REMAINING "Questions remaining: ")
(define MSG-QUESTION-PROMPT "Question")

(define (qnr-run-cli)
  (let* ((path (read-json-file))
         (quiz (qnr-make-quiz (qnr-load-quiz-file path))))
    (run-quiz quiz)))

(define (run-quiz quiz)
  (unless (qnr-quiz-questions-remaining? quiz)
    (display-round-info quiz)
    (let ((question (qnr-quiz-get-next-question quiz)))
      (display-query-to-user question)
      ;; TODO: Read Examinee's Response
      ;; TODO: Compare to Solution
      ;; TODO: IF incorrect, re-add the question
      ;; TODO: Re-run the quiz
      (run-quiz quiz))))

(define (read-json-file)
  (when (<= (length (program-arguments)) EXPECTED-ARGUMENT-FOR-JSON-FILE)
    (throw 'qnr-no-json-path-passed))
  (cadr (command-line)))

(define (display-round-info quiz)
  (format #t "~a\n~a~a\n\n"
          (hr)
          MSG-QUESTIONS-REMAINING
          (qnr-quiz-length quiz)))

(define (display-query-to-user question)
  (format #t
          "~a ~a:\n~a\n"
          MSG-QUESTION-PROMPT
          (qnr-question-question-number question)
          (qnr-question-query question)))

(define* (hr #:optional (length HR-LENGTH) (char HR-CHAR))
  (make-string length char))
