(use-modules (srfi srfi-64)
             (util test)
             (src quiz-loader))

;; Test Helpers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (construct-path dirname basename)
  "Assumes DIRNAME ends in appropriate file-name-separator-string."
  (string-concatenate (list dirname basename)))

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define TEST-SUITE-NAME (qnr-generate-log-file-name))

(define PROJECT-ROOT ".")
(define DIR-TEST "tests")
(define DIR-INPUT-FILES "input-files")
(define PREFIX
  (string-concatenate (list
                       PROJECT-ROOT
                       file-name-separator-string
                       DIR-TEST
                       file-name-separator-string
                       DIR-INPUT-FILES
                       file-name-separator-string)))
(define PATH-NON-EXISTENT-FILE
  (construct-path PREFIX "does-not-exist.txt"))
(define PATH-EMPTY-FILE
  (construct-path PREFIX "empty-quiz.json"))
(define PATH-LOREM-IPSUM
  (construct-path PREFIX "invalid-json-lorem-ipsum.json"))
(define PATH-MISSING-CLOSING-BRACKET
  (construct-path PREFIX "invalid-json-missing-closing-bracket.json"))
(define PATH-VALID-SINGLE-QUERY
  (construct-path PREFIX "valid-single-question.json"))


;; Tests ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-begin TEST-SUITE-NAME)

(qnr-test-error "open invalid file: non-existent file"
                QNR-ERROR-FILE-NOT-FOUND
                (lambda () (qnr-load-quiz-file PATH-NON-EXISTENT-FILE)))

(qnr-test-error "open empty invalid JSON: empty file"
                QNR-ERROR-JSON-PARSING
                (lambda () (qnr-load-quiz-file PATH-EMPTY-FILE)))

(qnr-test-error "open empty invalid JSON: lorem ipsum paragraphs"
                QNR-ERROR-JSON-PARSING
                (lambda () (qnr-load-quiz-file PATH-LOREM-IPSUM)))

(qnr-test-error "open empty invalid JSON: missing closing bracket"
                QNR-ERROR-JSON-PARSING
                (lambda () (qnr-load-quiz-file PATH-MISSING-CLOSING-BRACKET)))

(test-equal "access query of valid json"
  "Name one of the two longest rivers in the United Stated."
  (qnr-dto-question-query
   (car
    (qnr-dto-question-list-questions
     (qnr-load-quiz-file PATH-VALID-SINGLE-QUERY)))))

(test-equal "access choices of valid json"
  #(#("Missouri" "Missouri River") #("Mississippi" "Mississippi River"))
  (qnr-dto-question-choices
   (car
    (qnr-dto-question-list-questions
     (qnr-load-quiz-file PATH-VALID-SINGLE-QUERY)))))

(test-equal "access expected response count of valid json"
  1
  (qnr-dto-question-expected-response-count
   (car
    (qnr-dto-question-list-questions
     (qnr-load-quiz-file PATH-VALID-SINGLE-QUERY)))))

(test-assert "empty quiz"
  (null?
   (qnr-dto-question-list-questions
    (qnr-load-quiz-file "./tests/input-files/valid-empty-questions-array.json"))))

(test-end TEST-SUITE-NAME)
