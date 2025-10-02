(use-modules (srfi srfi-64)
             (util test)
             (src quiz quiz)
             (src quiz quiz-loader)
             (src quiz question)
             (src quiz solution))

(define TEST-SUITE-NAME (qnr-generate-log-file-name))

(test-begin TEST-SUITE-NAME)

(test-equal "qnr-number-elements: empty list"
  '()
  (qnr-number-elements '()))

(test-equal "qnr-number-elements: single element list"
  '((a . 1))
  (qnr-number-elements '(a)))

(test-equal "qnr-number-elements: multi element list"
  '((a . 1) (b . 2) (c . 3) (d . 4))
  (qnr-number-elements '(a b c d)))

(test-equal "qnr-quiz: query single question"
  "Name one of the two longest rivers in the United Stated."
  (qnr-question-query
   (qnr-quiz-get-next-question
    (qnr-make-quiz (qnr-load-quiz-file "./tests/input-files/valid-single-question.json")))))

(test-equal "qnr-quiz: choices single question"
  '(("Missouri" "Missouri River")
    ("Mississippi" "Mississippi River"))
  (qnr-solution-choices
   (qnr-question-solution
    (qnr-quiz-get-next-question
     (qnr-make-quiz (qnr-load-quiz-file "./tests/input-files/valid-single-question.json"))))))

(test-equal "qnr-quiz: expected response count single question"
  1
  (qnr-solution-expected-response-count
   (qnr-question-solution
    (qnr-quiz-get-next-question
     (qnr-make-quiz (qnr-load-quiz-file "./tests/input-files/valid-single-question.json"))))))

(test-equal "qnr-quiz: question number single question"
  1
  (qnr-question-question-number
   (qnr-quiz-get-next-question
    (qnr-make-quiz (qnr-load-quiz-file "./tests/input-files/valid-single-question.json")))))

(test-end TEST-SUITE-NAME)
