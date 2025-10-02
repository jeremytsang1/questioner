(define-module (src ui cli cli)
  #:use-module (ice-9 rdelim)
  #:use-module (src quiz quiz)
  #:use-module (src quiz quiz-loader)
  #:use-module (src quiz question)
  #:use-module (src quiz solution)
  #:export (qnr-run-cli))

(define EXPECTED-ARGUMENT-FOR-JSON-FILE 1)
(define HR-LENGTH 80)
(define HR-CHAR #\-)
(define MSG-QUESTIONS-REMAINING "Questions remaining: ")
(define MSG-QUESTION-PROMPT "Question")
(define MSG-ROUND-CORRECT "CORRECT!")
(define MSG-ROUND-INCORRECT "INCORRECT!")
(define INITIAL-RESPONSE-NUMBER 1) ;; Start numbering response from "1".

(define (qnr-run-cli)
  (let* ((path (read-json-file))
         (quiz (qnr-make-quiz (qnr-load-quiz-file path))))
    (run-quiz quiz)))

(define (run-quiz quiz)
  (unless (qnr-quiz-questions-remaining? quiz)
    (display-round-info quiz)
    (let* ((question (qnr-quiz-get-next-question quiz))
           (solution (qnr-question-solution question)))
      (display-query-to-user question)
      (let* ((responses (read-examinee-response solution))
             (wrong-answers (qnr-find-wrong-answers solution responses)))
        (display-round-results solution wrong-answers))
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

(define (read-examinee-response solution)
  (define* (read-single-response
            #:optional
            (response-number INITIAL-RESPONSE-NUMBER)
            (responses '()))
    (cond ((= (length responses)
              (qnr-solution-expected-response-count solution))
           responses)
          (else (begin (format #t "~a) " response-number)
                       (read-single-response (1+ response-number)
                                             (cons (read-line) responses))))))
  (read-single-response))

(define (display-round-results solution wrong-answers)
  (define (format-primary-correct-answers)
    (string-join
     (map
      (lambda (pair)
        (let ((answer (car pair)) (answer-number (cdr pair)))
          (format #f "~a) ~a" answer-number answer)))
      (qnr-number-elements (qnr-get-primary-correct-answers solution)))
     "\n"))

  (if (null? wrong-answers)
      (format #t "\n~a\n" MSG-ROUND-CORRECT)
      (format #t "\n~a\n~a\n" MSG-ROUND-INCORRECT (format-primary-correct-answers))))
