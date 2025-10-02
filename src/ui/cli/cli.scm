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
(define SEPARATOR-RESPONSE-NUMBER-SINGLE-EXPECTED-RESPONSE-COUNT ">")
(define SEPARATOR-RESPONSE-NUMBER-MULTI-EXPECTED-RESPONSE-COUNT ")")
(define SEPARATOR-RESULT-SINGLE-CHOICE "-")
(define SEPARATOR-RESULT-MULTI-CHOICE ")")
(define SEPARATOR-SPACING " ")

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
        (display-round-results solution wrong-answers)
        (unless (null? wrong-answers)
          (qnr-quiz-add-question quiz question)))
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
          "~a~a~a:\n~a\n"
          MSG-QUESTION-PROMPT
          SEPARATOR-SPACING
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
          (else (begin (display-prompt response-number)
                       (read-single-response (1+ response-number)
                                             (cons (read-line) responses))))))
  (define (display-prompt response-number)
    (let ((prompt
           ;; Use a different response prompt for single response count
           ;; (i.e. ECR = 1) than multiresponse count. The latter should
           ;; include numbers to help examinee keep track of which responses
           ;; they have previously input.
           (if (= (qnr-solution-expected-response-count solution) 1)
               SEPARATOR-RESPONSE-NUMBER-SINGLE-EXPECTED-RESPONSE-COUNT
               (format #f
                       "~a~a"
                       response-number
                       SEPARATOR-RESPONSE-NUMBER-MULTI-EXPECTED-RESPONSE-COUNT))))
      (format #t "~a~a" prompt SEPARATOR-SPACING)))
  (read-single-response))

(define (display-round-results solution wrong-answers)
  (define (format-single-correct-answer)
    (format #f "~a~a~a"
            SEPARATOR-RESULT-SINGLE-CHOICE
            SEPARATOR-SPACING
            (car (qnr-get-primary-correct-answers solution))))
  (define (format-multiple-correct-answers)
    (string-join
     (map
      (lambda (pair)
        (let ((answer (car pair)) (answer-number (cdr pair)))
          (format #f
                  "~a~a~a~a"
                  answer-number
                  SEPARATOR-RESPONSE-NUMBER-MULTI-EXPECTED-RESPONSE-COUNT
                  SEPARATOR-SPACING
                  answer)))
      (qnr-number-elements (qnr-get-primary-correct-answers solution)))
     "\n"))
  (if (null? wrong-answers) (format #t "\n~a\n" MSG-ROUND-CORRECT)
      (format #t "\n~a\n~a\n"
              MSG-ROUND-INCORRECT
              (if (= (length (qnr-solution-choices solution)) 1)
                  (format-single-correct-answer)
                  (format-multiple-correct-answers)))))
