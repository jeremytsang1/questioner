(define-module (src quiz quiz)
  #:use-module (srfi srfi-9)
  #:use-module (ice-9 q)
  #:use-module (src quiz quiz-loader)
  #:use-module (src quiz question)
  #:export (qnr-make-quiz
            qnr-quiz-get-next-question
            qnr-quiz-questions-remaining?
            qnr-quiz-length
            ;; Helpers
            qnr-number-elements))


;; Record Definition ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-record-type <qnr-quiz>
  (raw-make-quiz questions-unanswered)
  qnr-quiz?
  (questions-unanswered qnr-quiz-questions-unanswered))

(define (qnr-make-quiz dto-questions)
  "Create a <qnr-quiz> from DTO-QUESTIONS.

DTO-QUESTIONS must be a list <qnr-dto-question>. Each created <qnr-question>
takes its question number to be its 1-indexed position in DTO-QUESTIONS."
  (let ((questions-unanswered (make-q))
        (numbered-qnr-dto-questions (qnr-number-elements dto-questions)))

    ;; TODO: shuffle `numbered-qnr-dto-questions`

    (for-each
     (lambda (pair)
       (let ((dto (car pair)) (question-number (cdr pair)))
         (enq! questions-unanswered
               (qnr-make-question-from-dto dto question-number))))
     numbered-qnr-dto-questions)

    (raw-make-quiz questions-unanswered)))

;; Methods ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (qnr-quiz-questions-remaining? quiz)
  (q-empty? (qnr-quiz-questions-unanswered quiz)))

(define (qnr-quiz-get-next-question quiz)
  (deq! (qnr-quiz-questions-unanswered quiz)))

(define (qnr-quiz-length quiz)
  (q-length (qnr-quiz-questions-unanswered quiz)))

;; Helpers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-module (src quiz quiz)
  #:export (qnr-number-elements))

(define* (qnr-number-elements lst #:optional (current-number 1))
  "Return an alist with each key being an element of DTO-QUESTIONS and the value
its number in the overall list with numbers starting at CURRENT-NUMBER.

When CURRENT-NUMBER is ommitted, counting starts at 1."
  (cond ((null? lst) '())
        (else (cons (cons (car lst) current-number)
                    (qnr-number-elements (cdr lst) (1+ current-number))))))
